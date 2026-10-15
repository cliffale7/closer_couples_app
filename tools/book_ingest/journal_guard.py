"""Prove a content upgrade does not rewrite fictional journal fixtures.

The real journal database is not opened by the importer. These helpers exist
so tests can fail if a future change starts returning mutated note text.
"""

from __future__ import annotations

import copy
from typing import Any

from book_ingest.common import JournalMutationError, canonical_dumps
from book_ingest.diff_engine import prepare_successor, resolve_experience, resolve_prompt


def attest_unchanged(before: list[dict[str, Any]], after: list[dict[str, Any]]) -> None:
    if canonical_dumps(before) != canonical_dumps(after):
        raise JournalMutationError("journal rows changed during a content upgrade")


def simulate_upgrade(
    old_pack: dict[str, Any] | None,
    new_pack: dict[str, Any],
    diff: dict[str, Any],
    journal_rows: list[dict[str, Any]],
    sessions: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    before_journal = copy.deepcopy(journal_rows)
    before_sessions = copy.deepcopy(sessions or [])
    prepared = prepare_successor(old_pack, new_pack, diff)
    attest_unchanged(before_journal, journal_rows)
    attest_unchanged(before_sessions, sessions or [])
    return {
        "pack": prepared,
        "journal_rows": journal_rows,
        "sessions": sessions or [],
    }


def historical_prompt_text(
    packs_by_edition: dict[str, dict[str, Any]],
    edition_id: str,
    prompt_id: str,
    revision: int,
) -> str | None:
    pack = packs_by_edition[edition_id]
    prompt = resolve_prompt(pack, prompt_id, revision)
    if prompt is None:
        return None
    return str(prompt.get("text"))


def historical_title(pack: dict[str, Any], stable_id: str) -> str | None:
    experience = resolve_experience(pack, stable_id)
    if experience is None:
        return None
    return str(experience.get("title"))
