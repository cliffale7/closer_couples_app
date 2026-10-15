"""Validate the v0.1 experience catalog. It is an inventory, not chapter prose."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from book_ingest.common import EditionRejected, normalize_apostrophes, read_json

EXPECTED_PARTS: dict[int, tuple[str, range]] = {
    1: ("The Art of Really Knowing Someone", range(1, 9)),
    2: ("Vulnerability and the Courage to Be Seen", range(9, 17)),
    3: ("The Science and Experience of Closeness", range(17, 25)),
    4: ("Love, Affection, and Feeling Chosen", range(25, 33)),
    5: ("Desire, Attraction, and Sensual Intimacy", range(33, 41)),
    6: ("Playfulness, Laughter, and a Little Mischief", range(41, 49)),
    7: ("The Inner World: Dreams, Meaning, and Identity", range(49, 57)),
    8: ("Trust, Communication, and Emotional Safety", range(57, 65)),
    9: ("Shared Adventures and New Experiences", range(65, 73)),
    10: ("The Past, the Present, and the Story of Us", range(73, 81)),
    11: ("Radical Curiosity and the Surprising Stuff", range(81, 89)),
    12: ("Building a Closer Future Together", range(89, 97)),
    13: ("The Inventor's Workshop: Original Proposals", range(97, 109)),
}

REQUIRED_SIGNATURES = ["S01", "S02", "S03", "S04", "S05", "S06"]

SOURCE_GAPS = [
    "full_chapter",
    "setup",
    "steps",
    "variants",
    "debrief",
    "journal_prompts",
    "artwork",
    "duration_metadata",
]


def load_catalog(path: Path) -> dict[str, Any]:
    catalog = read_json(path)
    errors = validate_catalog(catalog)
    if errors:
        raise EditionRejected("baseline catalog failed validation:\n- " + "\n- ".join(errors))
    return catalog


def validate_catalog(catalog: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    experiences = catalog.get("experiences")
    parts = catalog.get("parts")
    if not isinstance(experiences, list) or not isinstance(parts, list):
        return ["catalog is missing experiences or parts lists"]
    if catalog.get("total_experiences") != 108:
        errors.append("total_experiences is not 108")
    if catalog.get("total_parts") != 13:
        errors.append("total_parts is not 13")
    if len(parts) != 13:
        errors.append(f"expected 13 parts, found {len(parts)}")
    if len(experiences) != 108:
        errors.append(f"expected 108 experiences, found {len(experiences)}")

    seen_ids: set[int] = set()
    seen_display: set[str] = set()
    by_part: dict[int, list[int]] = {number: [] for number in EXPECTED_PARTS}
    for item in experiences:
        if not isinstance(item, dict):
            errors.append("experience entry is not an object")
            continue
        numeric = item.get("id")
        display = item.get("display_id")
        title = item.get("title") or ""
        premise = item.get("source_premise") or ""
        part_number = item.get("part_number")
        if not isinstance(numeric, int):
            errors.append(f"non-integer id on {title!r}")
            continue
        if numeric in seen_ids:
            errors.append(f"duplicate id {numeric}")
        seen_ids.add(numeric)
        expected_display = f"{numeric:03d}"
        if display != expected_display:
            errors.append(f"id {numeric} display_id is {display!r}, expected {expected_display}")
        else:
            if display in seen_display:
                errors.append(f"duplicate display_id {display}")
            seen_display.add(display)
        if not str(title).strip():
            errors.append(f"{expected_display} has an empty title")
        if not str(premise).strip():
            errors.append(f"{expected_display} has an empty source_premise")
        if part_number not in EXPECTED_PARTS:
            errors.append(f"{expected_display} has unknown part {part_number}")
        else:
            by_part[part_number].append(numeric)
            if numeric not in EXPECTED_PARTS[part_number][1]:
                errors.append(f"{expected_display} is outside part {part_number} range")

    expected_ids = set(range(1, 109))
    missing = sorted(expected_ids - seen_ids)
    extra = sorted(seen_ids - expected_ids)
    if missing:
        errors.append(f"missing ids: {missing}")
    if extra:
        errors.append(f"unexpected ids: {extra}")

    parts_by_number = {}
    for part in parts:
        if not isinstance(part, dict):
            errors.append("part entry is not an object")
            continue
        number = part.get("part_number")
        parts_by_number[number] = part
    for number, (title, id_range) in EXPECTED_PARTS.items():
        part = parts_by_number.get(number)
        if part is None:
            errors.append(f"missing part {number}")
            continue
        actual_title = str(part.get("part_title") or "")
        if normalize_apostrophes(actual_title) != title:
            errors.append(f"part {number} title {actual_title!r} != {title!r}")
        listed = part.get("ids")
        expected_list = list(id_range)
        if listed != expected_list:
            errors.append(f"part {number} id list {listed} != {expected_list}")
        if sorted(by_part[number]) != expected_list:
            errors.append(f"part {number} experience assignments {sorted(by_part[number])}")
    return errors
