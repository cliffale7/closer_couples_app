"""The v1 draft loader keeps private notes out and does not approve itself."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from book_ingest.book_project import build_book_project_pack
from book_ingest.common import EditionRejected
from book_ingest.pack import publication_blockers


def _catalog() -> dict:
    return {
        "parts": [
            {
                "part_number": 1,
                "part_title": "The Art of Really Knowing Someone",
                "ids": [1],
            }
        ],
        "experiences": [
            {
                "id": 1,
                "display_id": "001",
                "title": "The Stranger Across From Me",
                "part_number": 1,
            }
        ],
    }


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _project(root: Path) -> None:
    _write(
        root / "chapters" / "part-01" / "001-the-stranger-across-from-me.md",
        """---
id: "001"
title: "The Stranger Across From Me"
part: 1
part_title: "The Art of Really Knowing Someone"
deck: "Interview the person you already know."
time_band: "20-45"
energy: low
emotional_intensity: personal
formats: [conversation, roleplay]
moods: [discover, play]
materials: ["two seats", "a visible timer"]
durations:
  short: "10 minutes"
  standard: "30 minutes"
motif: "assets/chapters/001/motif.svg"
---

## The hook

"""
        + ("A courteous question reaches a fact familiarity had filed away. " * 80),
    )
    _write(root / "assets" / "chapters" / "001" / "motif.svg", "<svg xmlns='http://www.w3.org/2000/svg'/>")
    _write(root / "parts" / "INTRODUCTIONS.md", "## 1\n\nSit down as if a polite stranger were allowed one good question.\n")
    _write(root / "journal" / "private" / "secret.md", "SECRET_NOTE_SHOULD_NOT_IMPORT\n")
    _write(root / "frontmatter" / "01-manifesto.md", "# Why this book exists\n\nFamiliarity is a gift and a trick.\n")


class BookProjectTests(unittest.TestCase):
    def test_draft_keeps_prose_metadata_and_private_notes_out(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            _project(root)
            pack = build_book_project_pack(root, _catalog(), require_complete=False)
        self.assertEqual(pack["edition"]["approval_state"], "draft")
        self.assertEqual(pack["edition"]["completeness"], "copyedited_draft")
        self.assertIn("approval_state is 'draft'", " ".join(publication_blockers(pack)))
        chapter = pack["experiences"][0]
        self.assertEqual(chapter["stable_id"], "001")
        self.assertEqual(chapter["metadata"]["time_buckets"], ["20-45"])
        self.assertEqual(chapter["metadata"]["outcomes"], ["discover", "play"])
        self.assertIn("courteous question", chapter["prose_blocks"][-1]["text"])
        self.assertTrue(chapter["art_asset"].endswith("001.svg"))
        self.assertEqual(pack["parts"][0]["intro"][:8], "Sit down")
        self.assertEqual(pack["front_matter"][0]["title"], "Why this book exists")
        blob = str(pack)
        self.assertNotIn("SECRET_NOTE_SHOULD_NOT_IMPORT", blob)

    def test_incomplete_tree_is_refused_when_completeness_is_required(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            _project(root)
            with self.assertRaises(EditionRejected):
                build_book_project_pack(root, _catalog(), require_complete=True)

    def test_private_path_is_refused(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            _project(root)
            secret = root / "chapters" / "private" / "001.md"
            secret.parent.mkdir(parents=True)
            secret.write_text("---\nid: \"001\"\n---\n", encoding="utf-8")
            with self.assertRaises(EditionRejected):
                build_book_project_pack(root, _catalog(), require_complete=False)


if __name__ == "__main__":
    unittest.main()
