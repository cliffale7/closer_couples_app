"""Scan book_inbox without treating a timestamp as approval."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def find_approved_editions(inbox: Path) -> list[dict[str, Any]]:
    if not inbox.exists():
        return []
    found: list[dict[str, Any]] = []
    for child in inbox.iterdir():
        if not child.is_dir():
            continue
        if child.name.startswith("."):
            continue
        manifest_path = child / "manifest.json"
        if not manifest_path.exists():
            continue
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        approval = str(manifest.get("approval") or manifest.get("approval_state") or "")
        if approval != "owner_approved":
            continue
        found.append(
            {
                "path": child,
                "edition_id": manifest.get("edition_id") or child.name,
                "version": str(manifest.get("version") or "0"),
                "approval": approval,
                "manifest": manifest,
            }
        )
    found.sort(key=lambda item: (_version_key(item["version"]), item["edition_id"]))
    return found


def _version_key(version: str) -> tuple[int, ...]:
    parts: list[int] = []
    for piece in version.split("."):
        digits = ""
        for char in piece:
            if char.isdigit():
                digits += char
            else:
                break
        parts.append(int(digits) if digits else 0)
    return tuple(parts)
