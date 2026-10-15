"""Build immutable content packs. Baseline packs stay marked incomplete."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from book_ingest import CONTENT_SCHEMA_VERSION
from book_ingest.catalog import REQUIRED_SIGNATURES, SOURCE_GAPS, load_catalog
from book_ingest.common import sha256_file, stamp_checksum
from book_ingest.extract import load_expansion_briefs

BASELINE_EDITION_ID = "baseline-v0.1"


def empty_metadata() -> dict[str, Any]:
    return {
        "time_buckets": [],
        "outcomes": [],
        "energy": [],
        "depth": [],
        "formats": [],
        "materials_required": [],
        "optional_contact": None,
        "personal_level": None,
    }


def build_baseline_pack(
    catalog_path: Path,
    *,
    manuscript_path: Path | None = None,
    briefs_path: Path | None = None,
) -> dict[str, Any]:
    catalog = load_catalog(catalog_path)
    briefs = load_expansion_briefs(briefs_path) if briefs_path else {}
    source_hashes = {"experience_catalog.json": sha256_file(catalog_path)}
    if manuscript_path and manuscript_path.exists():
        source_hashes[manuscript_path.name] = sha256_file(manuscript_path)

    parts = []
    for part in catalog["parts"]:
        number = int(part["part_number"])
        parts.append(
            {
                "stable_id": f"part-{number:02d}",
                "ordinal": number,
                "name": part["part_title"],
                "intro": None,
                "intro_origin": "source_gap",
                "asset_ids": [],
                "experience_ids": [f"{int(item):03d}" for item in part["ids"]],
            }
        )

    experiences = []
    for item in catalog["experiences"]:
        stable_id = str(item["display_id"])
        prose = [
            {
                "block_id": f"{stable_id}-premise",
                "kind": "source_premise",
                "text": item["source_premise"],
                "origin": "verbatim_baseline_catalog",
            }
        ]
        gaps = list(SOURCE_GAPS)
        if stable_id in briefs:
            prose.append(
                {
                    "block_id": f"{stable_id}-design-brief",
                    "kind": "design_brief",
                    "text": briefs[stable_id],
                    "origin": "verbatim_baseline_expansion_brief",
                }
            )
        experiences.append(
            {
                "stable_id": stable_id,
                "numeric_id": int(item["id"]),
                "title": item["title"],
                "aliases": [],
                "part_id": f"part-{int(item['part_number']):02d}",
                "subtitle": None,
                "provenance": "baseline_catalog",
                "prose_blocks": prose,
                "preparation": [],
                "materials": [],
                "steps": [],
                "variants": [],
                "debrief": None,
                "prompt_ids": [],
                "reference_ids": [],
                "asset_ids": [],
                "metadata": empty_metadata(),
                "interaction_definition": None,
                "interaction_version": None,
                "source_gaps": gaps,
            }
        )

    pack = {
        "content_schema_version": CONTENT_SCHEMA_VERSION,
        "edition": {
            "source_book_id": "the-closer-project",
            "edition_id": BASELINE_EDITION_ID,
            "version": "0.1.0",
            "publication_date": None,
            "source_hashes": source_hashes,
            "imported_at": None,
            "provenance": "v0.1 structural baseline; not an approved complete book",
            "locale": "en",
            "approval_state": "baseline_inventory_only",
            "completeness": "inventory_not_full_chapters",
            "app_compatibility": ">=0.1.0 <2.0.0",
            "checksum": None,
        },
        "parts": parts,
        "experiences": experiences,
        "signatures": [],
        "prompts": [],
        "assets": [],
        "legacy_archive": [],
        "required_signature_ids": list(REQUIRED_SIGNATURES),
    }
    return stamp_checksum(pack)


def publication_blockers(pack: dict[str, Any]) -> list[str]:
    blockers: list[str] = []
    edition = pack.get("edition") or {}
    if edition.get("approval_state") != "owner_approved":
        blockers.append(
            f"approval_state is {edition.get('approval_state')!r}, not owner_approved"
        )
    if edition.get("completeness") != "full_chapters":
        blockers.append(
            f"completeness is {edition.get('completeness')!r}, not full_chapters"
        )
    experiences = pack.get("experiences") or []
    ids = {item.get("stable_id") for item in experiences}
    missing = [f"{number:03d}" for number in range(1, 109) if f"{number:03d}" not in ids]
    if missing:
        blockers.append(f"missing {len(missing)} baseline experience ids, starting {missing[0]}")
    gapped = [
        item.get("stable_id")
        for item in experiences
        if "full_chapter" in (item.get("source_gaps") or [])
        or not any(block.get("kind") == "full_chapter" for block in item.get("prose_blocks") or [])
    ]
    if gapped:
        blockers.append(f"{len(gapped)} experiences have no finished full_chapter prose")
    present_signatures = {item.get("stable_id") for item in pack.get("signatures") or []}
    missing_signatures = [item for item in REQUIRED_SIGNATURES if item not in present_signatures]
    if missing_signatures:
        blockers.append("missing signature sessions " + ", ".join(missing_signatures))
    if any(not (part.get("intro") or "").strip() for part in pack.get("parts") or []):
        blockers.append("one or more part introductions are empty")
    return blockers


def structural_errors(pack: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if not isinstance(pack, dict):
        return ["content pack is not an object"]
    edition = pack.get("edition")
    if not isinstance(edition, dict) or not edition.get("edition_id"):
        errors.append("edition.edition_id is required")
    version = str(pack.get("content_schema_version") or "")
    if not version:
        errors.append("content_schema_version is required")
    experiences = pack.get("experiences")
    parts = pack.get("parts")
    if not isinstance(experiences, list):
        errors.append("experiences must be a list")
        experiences = []
    if not isinstance(parts, list):
        errors.append("parts must be a list")
        parts = []
    seen: set[str] = set()
    for item in experiences:
        stable_id = str(item.get("stable_id") or "")
        if not stable_id:
            errors.append("experience missing stable_id")
            continue
        if stable_id in seen:
            errors.append(f"duplicate experience id {stable_id}")
        seen.add(stable_id)
        if not item.get("title"):
            errors.append(f"{stable_id} missing title")
    part_ids = {part.get("stable_id") for part in parts}
    for item in experiences:
        part_id = item.get("part_id")
        if part_id and part_id not in part_ids:
            errors.append(f"{item.get('stable_id')} references unknown part {part_id}")
    known_prompts = {prompt.get("stable_id") for prompt in pack.get("prompts") or []}
    for item in experiences:
        for prompt_id in item.get("prompt_ids") or []:
            if prompt_id not in known_prompts:
                errors.append(f"{item.get('stable_id')} references missing prompt {prompt_id}")
    active_ids = seen
    for archived in pack.get("legacy_archive") or []:
        archived_id = archived.get("stable_id")
        if archived_id in active_ids:
            errors.append(f"{archived_id} is both active and archived")
    return errors
