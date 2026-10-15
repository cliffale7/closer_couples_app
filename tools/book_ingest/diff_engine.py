"""Stable-ID semantic diff. Titles are never primary keys."""

from __future__ import annotations

import copy
from typing import Any

from book_ingest.common import canonical_dumps


def diff_packs(old: dict[str, Any] | None, new: dict[str, Any]) -> dict[str, Any]:
    old_experiences = _by_id((old or {}).get("experiences") or [])
    new_experiences = _by_id(new.get("experiences") or [])
    old_ids = set(old_experiences)
    new_ids = set(new_experiences)

    added = []
    for stable_id in sorted(new_ids - old_ids):
        item = new_experiences[stable_id]
        added.append(
            {
                "stable_id": stable_id,
                "title": item.get("title"),
                "has_new_mechanics": item.get("interaction_definition") is not None,
            }
        )
    removed = [
        {"stable_id": stable_id, "title": old_experiences[stable_id].get("title")}
        for stable_id in sorted(old_ids - new_ids)
    ]

    renamed = []
    text_changed = []
    metadata_changed = []
    artwork_changed = []
    prompt_changes = []
    mechanics_changed = []
    part_moved = []

    for stable_id in sorted(old_ids & new_ids):
        before = old_experiences[stable_id]
        after = new_experiences[stable_id]
        if before.get("title") != after.get("title"):
            renamed.append(
                {
                    "stable_id": stable_id,
                    "old_title": before.get("title"),
                    "new_title": after.get("title"),
                }
            )
        if before.get("part_id") != after.get("part_id"):
            part_moved.append(
                {
                    "stable_id": stable_id,
                    "from": before.get("part_id"),
                    "to": after.get("part_id"),
                }
            )
        if _prose_fingerprint(before) != _prose_fingerprint(after):
            text_changed.append(stable_id)
        if canonical_dumps(before.get("metadata") or {}) != canonical_dumps(after.get("metadata") or {}):
            metadata_changed.append(stable_id)
        if _asset_fingerprint(old, before) != _asset_fingerprint(new, after):
            artwork_changed.append(stable_id)
        if canonical_dumps(before.get("interaction_definition")) != canonical_dumps(
            after.get("interaction_definition")
        ) or before.get("interaction_version") != after.get("interaction_version"):
            mechanics_changed.append(
                {
                    "stable_id": stable_id,
                    "old_version": before.get("interaction_version"),
                    "new_version": after.get("interaction_version"),
                }
            )
        prompt_changes.extend(_prompt_delta(old, new, stable_id, before, after))

    old_schema = str((old or {}).get("content_schema_version") or "")
    new_schema = str(new.get("content_schema_version") or "")
    schema_changed = major_version(old_schema) != major_version(new_schema) if old else False

    return {
        "from_edition": (old or {}).get("edition", {}).get("edition_id"),
        "to_edition": new.get("edition", {}).get("edition_id"),
        "added": added,
        "removed": removed,
        "renamed": renamed,
        "part_moved": part_moved,
        "text_changed": text_changed,
        "metadata_changed": metadata_changed,
        "artwork_changed": artwork_changed,
        "prompt_changes": prompt_changes,
        "mechanics_changed": mechanics_changed,
        "schema_changed": schema_changed,
        "old_schema": old_schema or None,
        "new_schema": new_schema or None,
    }


def classify_impact(diff: dict[str, Any]) -> dict[str, Any]:
    classes: list[str] = []
    if diff["text_changed"]:
        classes.append("text")
    if diff["metadata_changed"]:
        classes.append("metadata")
    if diff["artwork_changed"]:
        classes.append("artwork")
    if diff["prompt_changes"]:
        classes.append("journal_prompt")
    if diff["mechanics_changed"] or any(item["has_new_mechanics"] for item in diff["added"]):
        classes.append("game_mechanics")
    if diff["removed"] or diff["part_moved"]:
        classes.append("removed_or_moved")
    if diff["added"]:
        classes.append("added")
    if diff["renamed"]:
        classes.append("renamed")
    if diff["schema_changed"]:
        classes.append("schema")
    requires_apk = "game_mechanics" in classes or "schema" in classes
    return {
        "classes": classes,
        "requires_new_apk": requires_apk,
        "content_pack_sufficient": not requires_apk,
        "journal_action": "preserve_all_rows",
        "destructive_to_journals": False,
        "owner_decision_required": False,
    }


def prepare_successor(old: dict[str, Any] | None, new: dict[str, Any], diff: dict[str, Any]) -> dict[str, Any]:
    """Copy the new pack and keep retired chapters reachable for old notes."""

    prepared = copy.deepcopy(new)
    if not old:
        prepared.setdefault("legacy_archive", [])
        return prepared
    by_id = {item["stable_id"]: item for item in prepared.get("experiences") or []}
    for rename in diff["renamed"]:
        experience = by_id[rename["stable_id"]]
        aliases = list(experience.get("aliases") or [])
        old_title = rename["old_title"]
        if old_title and old_title not in aliases and old_title != experience.get("title"):
            aliases.append(old_title)
        experience["aliases"] = aliases
    archive = list(prepared.get("legacy_archive") or [])
    archived_ids = {item.get("stable_id") for item in archive}
    old_by_id = {item["stable_id"]: item for item in old.get("experiences") or []}
    for removed in diff["removed"]:
        stable_id = removed["stable_id"]
        if stable_id in archived_ids:
            continue
        archived = copy.deepcopy(old_by_id[stable_id])
        archived["archive_reason"] = "removed_or_deprecated"
        archived["archived_from_edition"] = old.get("edition", {}).get("edition_id")
        archive.append(archived)
    prepared["legacy_archive"] = archive
    return prepared


def resolve_experience(pack: dict[str, Any], stable_id: str) -> dict[str, Any] | None:
    for collection in (pack.get("experiences") or [], pack.get("legacy_archive") or []):
        for item in collection:
            if item.get("stable_id") == stable_id:
                return item
    return None


def resolve_prompt(pack: dict[str, Any], prompt_id: str, revision: int | None) -> dict[str, Any] | None:
    for prompt in pack.get("prompts") or []:
        if prompt.get("stable_id") != prompt_id:
            continue
        if revision is None or prompt.get("revision") == revision:
            return prompt
    return None


def render_diff_markdown(diff: dict[str, Any], impact: dict[str, Any]) -> str:
    def ids(values: list[Any]) -> str:
        if not values:
            return "none"
        rendered = []
        for value in values:
            if isinstance(value, dict):
                rendered.append(str(value.get("stable_id")))
            else:
                rendered.append(str(value))
        return ", ".join(rendered)

    lines = [
        f"# Book diff {diff.get('from_edition') or 'none'} -> {diff.get('to_edition')}",
        "",
        f"Schema {diff.get('old_schema')} -> {diff.get('new_schema')}.",
        f"Impact classes: {', '.join(impact['classes']) or 'none'}.",
        f"New APK required: {str(impact['requires_new_apk']).lower()}.",
        f"Journal action: {impact['journal_action']}.",
        "",
        f"- Added: {ids(diff['added'])}",
        f"- Removed from the active catalog: {ids(diff['removed'])}",
        f"- Renamed: {ids(diff['renamed'])}",
        f"- Moved part: {ids(diff['part_moved'])}",
        f"- Text changed: {ids(diff['text_changed'])}",
        f"- Metadata changed: {ids(diff['metadata_changed'])}",
        f"- Artwork changed: {ids(diff['artwork_changed'])}",
        f"- Prompt changes: {ids(diff['prompt_changes'])}",
        f"- Mechanics changed: {ids(diff['mechanics_changed'])}",
        "",
        "Removed chapters stay in the legacy archive when this diff is applied.",
        "Private journal rows are not part of this diff and are not modified.",
        "",
    ]
    return "\n".join(lines)


def _by_id(experiences: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {str(item["stable_id"]): item for item in experiences}


def _prose_fingerprint(experience: dict[str, Any]) -> str:
    blocks = experience.get("prose_blocks") or []
    ordered = sorted(blocks, key=lambda block: str(block.get("block_id")))
    payload = [
        {"block_id": block.get("block_id"), "kind": block.get("kind"), "text": block.get("text")}
        for block in ordered
    ]
    return canonical_dumps(payload)


def _asset_fingerprint(pack: dict[str, Any], experience: dict[str, Any]) -> str:
    wanted = set(experience.get("asset_ids") or [])
    assets = [
        {
            "asset_id": asset.get("asset_id"),
            "checksum": asset.get("checksum"),
            "alt_text": asset.get("alt_text"),
        }
        for asset in pack.get("assets") or []
        if asset.get("asset_id") in wanted
    ]
    assets.sort(key=lambda item: str(item["asset_id"]))
    return canonical_dumps(assets)


def _prompt_delta(
    old: dict[str, Any] | None,
    new: dict[str, Any],
    stable_id: str,
    before: dict[str, Any],
    after: dict[str, Any],
) -> list[dict[str, Any]]:
    old_prompts = {
        item["stable_id"]: item
        for item in (old or {}).get("prompts") or []
        if item.get("stable_id") in set(before.get("prompt_ids") or [])
    }
    new_prompts = {
        item["stable_id"]: item
        for item in new.get("prompts") or []
        if item.get("stable_id") in set(after.get("prompt_ids") or [])
    }
    changes = []
    for prompt_id in sorted(set(old_prompts) | set(new_prompts)):
        left = old_prompts.get(prompt_id)
        right = new_prompts.get(prompt_id)
        if left is None:
            changes.append({"stable_id": stable_id, "prompt_id": prompt_id, "change": "added"})
        elif right is None:
            changes.append({"stable_id": stable_id, "prompt_id": prompt_id, "change": "removed"})
        elif left.get("text") != right.get("text") or left.get("revision") != right.get("revision"):
            changes.append(
                {
                    "stable_id": stable_id,
                    "prompt_id": prompt_id,
                    "change": "revised",
                    "old_revision": left.get("revision"),
                    "new_revision": right.get("revision"),
                }
            )
    return changes


def major_version(version: str) -> int | None:
    if not version:
        return None
    head = version.split(".", 1)[0]
    return int(head) if head.isdigit() else None
