"""Human-readable intake and update reports."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from book_ingest.common import write_json
from book_ingest.pack import publication_blockers


def write_baseline_intake(
    root: Path,
    *,
    pack: dict[str, Any],
    manuscript_audit: dict[str, Any] | None,
    catalog_errors: list[str],
) -> Path:
    blockers = publication_blockers(pack)
    experience_count = len(pack.get("experiences") or [])
    part_count = len(pack.get("parts") or [])
    brief_count = sum(
        1
        for item in pack.get("experiences") or []
        if any(block.get("kind") == "design_brief" for block in item.get("prose_blocks") or [])
    )
    lines = [
        "# Intake — baseline v0.1",
        "",
        "This is a scope baseline. It is not an approved finished book, and it does not open the full-publication gate.",
        "",
        "## Gate",
        "",
        "- Full publication: **BLOCKED_PENDING_APPROVED_BOOK**",
        f"- Structural catalog errors: {len(catalog_errors)}",
        f"- Publication blockers: {len(blockers)}",
        "",
        "## Inventory",
        "",
        f"- Edition id: `{pack['edition']['edition_id']}`",
        f"- Approval state: `{pack['edition']['approval_state']}`",
        f"- Completeness: `{pack['edition']['completeness']}`",
        f"- Content schema: `{pack['content_schema_version']}`",
        f"- Checksum: `{pack['edition']['checksum']}`",
        f"- Experiences: {experience_count}",
        f"- Parts: {part_count}",
        f"- Signature sessions in the pack: {len(pack.get('signatures') or [])} (S01–S06 are still required)",
        f"- Part 13 expansion briefs attached as labeled design briefs, not as chapters: {brief_count}",
        "",
        "## Manuscript extraction",
        "",
    ]
    if manuscript_audit is None:
        lines.append("No manuscript file was supplied to this intake run.")
    else:
        lines.extend(
            [
                f"- Format: {manuscript_audit.get('format')} ({manuscript_audit.get('confidence')} confidence)",
                f"- Paragraphs: {manuscript_audit.get('paragraph_count')}",
                f"- Words: {manuscript_audit.get('word_count')}",
                f"- SHA-256: `{manuscript_audit.get('sha256')}`",
                f"- Experience titles found in the manuscript: {manuscript_audit.get('titles_found')} / {manuscript_audit.get('titles_expected')}",
                f"- Declares it is not finished prose: {manuscript_audit.get('declares_not_finished_prose')}",
                f"- Reason: {manuscript_audit.get('reason')}",
            ]
        )
    lines.extend(["", "## Publication blockers", ""])
    lines.extend(f"- {blocker}" for blocker in blockers)
    lines.extend(
        [
            "",
            "## What was not invented",
            "",
            "Full chapter prose, steps, debriefs, journal prompts, durations, and artwork are source gaps. Design briefs for 097–108 are copied verbatim from the baseline notes and labeled `design_brief`.",
            "",
        ]
    )
    path = root / "planning" / "intake" / "EDITION_v0.1_baseline.md"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines), encoding="utf-8")
    write_json(root / "planning" / "intake" / "EDITION_v0.1_baseline.json", {
        "edition_id": pack["edition"]["edition_id"],
        "checksum": pack["edition"]["checksum"],
        "publication_gate": "BLOCKED_PENDING_APPROVED_BOOK",
        "blockers": blockers,
        "manuscript": manuscript_audit,
        "catalog_errors": catalog_errors,
    })
    return path


def write_reconciliation_csv(root: Path, pack: dict[str, Any]) -> Path:
    path = root / "content" / "canonical" / pack["edition"]["edition_id"] / "reconciliation.csv"
    path.parent.mkdir(parents=True, exist_ok=True)
    rows = ["stable_id,title,part_id,provenance,full_chapter,source_gaps"]
    for item in pack.get("experiences") or []:
        title = str(item["title"]).replace('"', '""')
        gaps = "|".join(item.get("source_gaps") or [])
        full = "yes" if "full_chapter" not in (item.get("source_gaps") or []) else "no"
        rows.append(
            f'{item["stable_id"]},"{title}",{item["part_id"]},{item["provenance"]},{full},{gaps}'
        )
    path.write_text("\n".join(rows) + "\n", encoding="utf-8")
    return path


def write_chapter_status(
    root: Path,
    pack: dict[str, Any],
    *,
    content_mapped: str = "inventory_only",
    art_ready: bool = False,
    note: str = "False means the finished book has not supplied that layer. Inventory mapping is not book validation.",
) -> Path:
    chapters = []
    rows = list(pack.get("experiences") or []) + list(pack.get("signatures") or [])
    for item in rows:
        chapters.append(
            {
                "stable_id": item["stable_id"],
                "title": item["title"],
                "book_validated": False,
                "research_checked": False,
                "content_mapped": content_mapped,
                "interactive_ready": False,
                "art_ready": art_ready and bool(item.get("art_asset")),
                "journal_ready": False,
                "editor_reviewed": False,
                "tested": False,
                "released": False,
            }
        )
    path = root / "planning" / "chapter_status.json"
    write_json(
        path,
        {
            "edition_id": pack["edition"]["edition_id"],
            "note": note,
            "chapters": chapters,
        },
    )
    return path
