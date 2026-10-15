"""Semantic diffs and the journal-preservation contract."""

from __future__ import annotations

import copy
import unittest
from pathlib import Path

from book_ingest.common import JournalMutationError
from book_ingest.diff_engine import (
    classify_impact,
    diff_packs,
    prepare_successor,
    resolve_experience,
)
from book_ingest.journal_guard import historical_prompt_text, historical_title, simulate_upgrade
from book_ingest.pack import build_baseline_pack

ROOT = Path(__file__).resolve().parents[3]
CATALOG = ROOT / "source" / "book_baseline" / "experience_catalog.json"


def _pack() -> dict:
    return build_baseline_pack(CATALOG)


def _experience(pack: dict, stable_id: str) -> dict:
    return next(item for item in pack["experiences"] if item["stable_id"] == stable_id)


class BookUpdateFixtureTests(unittest.TestCase):
    def test_paragraph_edit_keeps_journal_text(self) -> None:
        old = _pack()
        _experience(old, "027")["prose_blocks"].append(
            {"block_id": "027-body", "kind": "full_chapter", "text": "Original paragraph.", "origin": "fixture"}
        )
        new = copy.deepcopy(old)
        new["edition"]["edition_id"] = "fixture-1.1"
        _experience(new, "027")["prose_blocks"][1]["text"] = "Edited paragraph."
        journal = [
            {
                "id": "j-027",
                "experience_stable_id": "027",
                "scope": "private",
                "owner": "A",
                "body": "fictional memory that must survive",
                "prompt_id": None,
                "prompt_revision": None,
            }
        ]
        diff = diff_packs(old, new)
        self.assertEqual(diff["text_changed"], ["027"])
        impact = classify_impact(diff)
        self.assertIn("text", impact["classes"])
        self.assertFalse(impact["requires_new_apk"])
        result = simulate_upgrade(old, new, diff, journal)
        self.assertEqual(result["journal_rows"][0]["body"], "fictional memory that must survive")

    def test_time_metadata_change_is_classified(self) -> None:
        old = _pack()
        _experience(old, "017")["metadata"]["time_buckets"] = ["45-90"]
        new = copy.deepcopy(old)
        _experience(new, "017")["metadata"]["time_buckets"] = ["20-45"]
        diff = diff_packs(old, new)
        self.assertEqual(diff["metadata_changed"], ["017"])
        self.assertNotIn("017", diff["text_changed"])

    def test_new_prompt_does_not_rewrite_old_answer(self) -> None:
        old = _pack()
        old["prompts"] = [
            {
                "stable_id": "034-boundary",
                "experience_id": "034",
                "revision": 1,
                "text": "Original boundary prompt",
                "privacy": "private",
                "optional": True,
            }
        ]
        _experience(old, "034")["prompt_ids"] = ["034-boundary"]
        new = copy.deepcopy(old)
        new["edition"]["edition_id"] = "fixture-1.1"
        new["prompts"][0]["revision"] = 2
        new["prompts"][0]["text"] = "Revised boundary prompt"
        new["prompts"].append(
            {
                "stable_id": "034-new",
                "experience_id": "034",
                "revision": 1,
                "text": "A new unanswered prompt",
                "privacy": "private",
                "optional": True,
            }
        )
        _experience(new, "034")["prompt_ids"] = ["034-boundary", "034-new"]
        journal = [
            {
                "id": "j-034",
                "experience_stable_id": "034",
                "prompt_id": "034-boundary",
                "prompt_revision": 1,
                "body": "fictional no",
                "scope": "private",
                "owner": "A",
            }
        ]
        diff = diff_packs(old, new)
        changes = {item["prompt_id"]: item["change"] for item in diff["prompt_changes"]}
        self.assertEqual(changes["034-boundary"], "revised")
        self.assertEqual(changes["034-new"], "added")
        simulate_upgrade(old, new, diff, journal)
        packs = {old["edition"]["edition_id"]: old, new["edition"]["edition_id"]: new}
        self.assertEqual(
            historical_prompt_text(packs, old["edition"]["edition_id"], "034-boundary", 1),
            "Original boundary prompt",
        )
        self.assertEqual(journal[0]["body"], "fictional no")
        self.assertEqual(journal[0]["prompt_revision"], 1)
        self.assertFalse(any(row.get("prompt_id") == "034-new" for row in journal))

    def test_scoring_and_point_changes_apply_only_to_new_sessions(self) -> None:
        old = _pack()
        _experience(old, "043")["interaction_definition"] = {"scoring": "match-or-miss"}
        _experience(old, "043")["interaction_version"] = "1"
        _experience(old, "106")["interaction_definition"] = {"points_total": 100}
        _experience(old, "106")["interaction_version"] = "1"
        new = copy.deepcopy(old)
        _experience(new, "043")["interaction_definition"] = {"scoring": "logic-first"}
        _experience(new, "043")["interaction_version"] = "2"
        _experience(new, "106")["interaction_definition"] = {"points_total": 80}
        _experience(new, "106")["interaction_version"] = "2"
        sessions = [
            {"id": "s-043", "experience_stable_id": "043", "rules_snapshot": {"scoring": "match-or-miss"}},
            {"id": "s-106", "experience_stable_id": "106", "rules_snapshot": {"points_total": 100}},
        ]
        diff = diff_packs(old, new)
        changed = {item["stable_id"] for item in diff["mechanics_changed"]}
        self.assertEqual(changed, {"043", "106"})
        self.assertTrue(classify_impact(diff)["requires_new_apk"])
        simulate_upgrade(old, new, diff, [], sessions)
        self.assertEqual(sessions[0]["rules_snapshot"]["scoring"], "match-or-miss")
        self.assertEqual(sessions[1]["rules_snapshot"]["points_total"], 100)

    def test_art_change_keeps_exhibit_text(self) -> None:
        old = _pack()
        old["assets"] = [
            {"asset_id": "102-hero", "checksum": "aaa", "alt_text": "old museum", "kind": "chapter_art"}
        ]
        _experience(old, "102")["asset_ids"] = ["102-hero"]
        new = copy.deepcopy(old)
        new["assets"][0]["checksum"] = "bbb"
        journal = [{"id": "exhibit", "experience_stable_id": "102", "body": "What I wish you'd understood", "scope": "shared", "owner": None}]
        diff = diff_packs(old, new)
        self.assertEqual(diff["artwork_changed"], ["102"])
        simulate_upgrade(old, new, diff, journal)
        self.assertEqual(journal[0]["body"], "What I wish you'd understood")

    def test_rename_keeps_stable_id_and_adds_alias(self) -> None:
        old = _pack()
        new = copy.deepcopy(old)
        _experience(new, "027")["title"] = "The Moment We Knew"
        journal = [{"id": "fav", "experience_stable_id": "027", "body": "bookmark target", "scope": "private", "owner": "B"}]
        diff = diff_packs(old, new)
        self.assertEqual(diff["renamed"][0]["old_title"], "The Moment I Knew")
        prepared = prepare_successor(old, new, diff)
        renamed = _experience(prepared, "027")
        self.assertIn("The Moment I Knew", renamed["aliases"])
        self.assertEqual(renamed["stable_id"], "027")
        simulate_upgrade(old, new, diff, journal)
        self.assertEqual(journal[0]["experience_stable_id"], "027")

    def test_removed_chapter_stays_in_archive_and_timeline(self) -> None:
        old = _pack()
        new = copy.deepcopy(old)
        new["experiences"] = [item for item in new["experiences"] if item["stable_id"] != "050"]
        new["parts"][6]["experience_ids"] = [
            stable_id for stable_id in new["parts"][6]["experience_ids"] if stable_id != "050"
        ]
        journal = [{"id": "old-note", "experience_stable_id": "050", "body": "still ours", "scope": "private", "owner": "A"}]
        diff = diff_packs(old, new)
        self.assertEqual(diff["removed"], [{"stable_id": "050", "title": _experience(old, "050")["title"]}])
        prepared = simulate_upgrade(old, new, diff, journal)["pack"]
        self.assertIsNone(next((item for item in prepared["experiences"] if item["stable_id"] == "050"), None))
        self.assertEqual(historical_title(prepared, "050"), _experience(old, "050")["title"])
        archived = resolve_experience(prepared, "050")
        self.assertEqual(archived["archive_reason"], "removed_or_deprecated")
        self.assertEqual(journal[0]["body"], "still ours")

    def test_new_chapter_109_does_not_rewrite_old_ids(self) -> None:
        old = _pack()
        new = copy.deepcopy(old)
        new["edition"]["edition_id"] = "fixture-1.2"
        added = copy.deepcopy(_experience(new, "108"))
        added["stable_id"] = "109"
        added["numeric_id"] = 109
        added["title"] = "A Later Invitation"
        new["experiences"].append(added)
        old_titles = {item["stable_id"]: item["title"] for item in old["experiences"]}
        diff = diff_packs(old, new)
        self.assertEqual(diff["added"][0]["stable_id"], "109")
        prepared = prepare_successor(old, new, diff)
        for stable_id, title in old_titles.items():
            self.assertEqual(_experience(prepared, stable_id)["title"], title)

    def test_identical_import_has_no_content_changes(self) -> None:
        pack = _pack()
        diff = diff_packs(pack, copy.deepcopy(pack))
        self.assertEqual(diff["added"], [])
        self.assertEqual(diff["removed"], [])
        self.assertEqual(diff["text_changed"], [])
        self.assertEqual(classify_impact(diff)["classes"], [])

    def test_schema_major_change_requires_apk(self) -> None:
        old = _pack()
        new = copy.deepcopy(old)
        new["content_schema_version"] = "2.0.0"
        diff = diff_packs(old, new)
        self.assertTrue(diff["schema_changed"])
        self.assertTrue(classify_impact(diff)["requires_new_apk"])

    def test_guard_detects_a_mutated_note(self) -> None:
        old = _pack()
        new = copy.deepcopy(old)
        journal = [{"id": "x", "body": "safe", "experience_stable_id": "001"}]
        changed = copy.deepcopy(journal)
        changed[0]["body"] = "rewritten"
        with self.assertRaises(JournalMutationError):
            from book_ingest.journal_guard import attest_unchanged

            attest_unchanged(journal, changed)


if __name__ == "__main__":
    unittest.main()
