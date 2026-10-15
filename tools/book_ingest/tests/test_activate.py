"""Activation, rollback, approval detection, and the command line."""

from __future__ import annotations

import copy
import io
import json
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path

from book_ingest.activate import activate_pack, load_active_pack, read_pointer, rollback
from book_ingest.cli import main
from book_ingest.common import EditionRejected, write_json
from book_ingest.inbox import find_approved_editions
from book_ingest.pack import build_baseline_pack

ROOT = Path(__file__).resolve().parents[3]
CATALOG = ROOT / "source" / "book_baseline" / "experience_catalog.json"


class ActivationTests(unittest.TestCase):
    def test_failed_and_incompatible_imports_leave_the_active_pack(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            pack = build_baseline_pack(CATALOG)
            activate_pack(
                root,
                pack,
                relative_dir="content/canonical/baseline-v0.1",
                publication_gate="BLOCKED_PENDING_APPROVED_BOOK",
            )
            again = activate_pack(
                root,
                pack,
                relative_dir="content/canonical/baseline-v0.1",
                publication_gate="BLOCKED_PENDING_APPROVED_BOOK",
            )
            self.assertTrue(again["idempotent"])
            bad = {"edition": {"edition_id": "broken"}}
            with self.assertRaises(EditionRejected):
                activate_pack(root, bad, relative_dir="content/canonical/broken", publication_gate="BLOCKED")
            self.assertEqual(read_pointer(root)["edition_id"], "baseline-v0.1")

            incompatible = copy.deepcopy(pack)
            incompatible["content_schema_version"] = "2.0.0"
            incompatible["edition"]["edition_id"] = "too-new"
            with self.assertRaises(EditionRejected):
                activate_pack(
                    root,
                    incompatible,
                    relative_dir="content/canonical/too-new",
                    publication_gate="BLOCKED",
                )
            self.assertEqual(load_active_pack(root)["edition"]["edition_id"], "baseline-v0.1")

    def test_rollback_restores_previous_pointer_only(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            first = build_baseline_pack(CATALOG)
            activate_pack(root, first, relative_dir="content/canonical/baseline-v0.1", publication_gate="BLOCKED_PENDING_APPROVED_BOOK")
            second = copy.deepcopy(first)
            second["edition"]["edition_id"] = "fixture-next"
            second["edition"]["approval_state"] = "owner_approved"
            activate_pack(root, second, relative_dir="content/canonical/fixture-next", publication_gate="BLOCKED_PENDING_APPROVED_BOOK")
            self.assertEqual(read_pointer(root)["edition_id"], "fixture-next")
            restored = rollback(root)
            self.assertEqual(restored["edition_id"], "baseline-v0.1")
            self.assertEqual(load_active_pack(root)["edition"]["edition_id"], "baseline-v0.1")


class InboxTests(unittest.TestCase):
    def test_newer_unapproved_folder_does_not_win(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            inbox = Path(temp)
            older = inbox / "2020-approved"
            newer = inbox / "2099-draft"
            older.mkdir()
            newer.mkdir()
            write_json(older / "manifest.json", {"edition_id": "approved-one", "version": "1.0.0", "approval": "owner_approved"})
            write_json(newer / "manifest.json", {"edition_id": "draft-two", "version": "9.0.0", "approval": "draft"})
            found = find_approved_editions(inbox)
            self.assertEqual([item["edition_id"] for item in found], ["approved-one"])

    def test_cli_apply_without_approval_is_blocked(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "book_inbox").mkdir()
            buffer = io.StringIO()
            with redirect_stdout(buffer):
                code = main(["--repo-root", str(root), "--apply"])
            self.assertEqual(code, 2)
            payload = json.loads(buffer.getvalue())
            self.assertEqual(payload["publication_gate"], "BLOCKED_PENDING_APPROVED_BOOK")
            self.assertIsNone(read_pointer(root))

    def test_explicit_draft_marker_cannot_be_overridden(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            edition = root / "book_inbox" / "draft-edition"
            edition.mkdir(parents=True)
            write_json(
                edition / "manifest.json",
                {"edition_id": "draft", "version": "0.2.0", "approval": "draft"},
            )
            write_json(edition / "content_pack.json", {"edition": {"edition_id": "draft"}})
            buffer = io.StringIO()
            with redirect_stdout(buffer):
                code = main(["--repo-root", str(root), "--edition", str(edition), "--approved", "--apply"])
            self.assertEqual(code, 2)
            self.assertIsNone(read_pointer(root))

    def test_markdown_edition_dry_run_reports_added_chapters(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            baseline = build_baseline_pack(CATALOG)
            activate_pack(
                root,
                baseline,
                relative_dir="content/canonical/baseline-v0.1",
                publication_gate="BLOCKED_PENDING_APPROVED_BOOK",
            )
            edition = root / "book_inbox" / "md-1"
            (edition / "chapters").mkdir(parents=True)
            write_json(
                edition / "manifest.json",
                {
                    "edition_id": "md-1.0.0",
                    "version": "1.0.0",
                    "approval": "owner_approved",
                    "completeness": "incomplete",
                    "parts": [
                        {
                            "stable_id": "part-04",
                            "ordinal": 4,
                            "name": "Love",
                            "intro": None,
                            "experience_ids": ["027"],
                        }
                    ],
                },
            )
            (edition / "chapters" / "027.md").write_text(
                "---\nstable_id: \"027\"\ntitle: \"The Moment I Knew\"\npart_id: part-04\n---\n\nA verbatim imported paragraph.\n",
                encoding="utf-8",
            )
            buffer = io.StringIO()
            with redirect_stdout(buffer):
                code = main(["--repo-root", str(root), "--dry-run", "--report"])
            self.assertEqual(code, 0)
            payload = json.loads(buffer.getvalue())
            self.assertEqual(payload["publication_gate"], "BLOCKED_PENDING_APPROVED_BOOK")
            self.assertIn("027", payload["text_changed"])
            self.assertTrue((root / "planning" / "updates" / "baseline-v0.1_to_md-1.0.0" / "DIFF.md").exists())
            self.assertEqual(read_pointer(root)["edition_id"], "baseline-v0.1")


if __name__ == "__main__":
    unittest.main()
