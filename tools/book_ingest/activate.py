"""Stage a content pack and swap the active pointer only after validation.

A failed import leaves the previous pointer and does not touch private notes.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from book_ingest import SUPPORTED_SCHEMA_MAJOR
from book_ingest.common import EditionRejected, stamp_checksum, write_json
from book_ingest.diff_engine import major_version
from book_ingest.pack import publication_blockers, structural_errors

ACTIVE_POINTER = Path("content/active/active_edition.json")


def read_pointer(root: Path) -> dict[str, Any] | None:
    path = root / ACTIVE_POINTER
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def load_active_pack(root: Path) -> dict[str, Any] | None:
    pointer = read_pointer(root)
    if not pointer:
        return None
    path = root / pointer["pack_relative_path"]
    if not path.exists():
        raise EditionRejected(f"active pack missing: {pointer['pack_relative_path']}")
    return json.loads(path.read_text(encoding="utf-8"))


def activate_pack(
    root: Path,
    pack: dict[str, Any],
    *,
    relative_dir: str,
    publication_gate: str,
) -> dict[str, Any]:
    errors = structural_errors(pack)
    schema = str(pack.get("content_schema_version") or "")
    major = major_version(schema)
    if major != SUPPORTED_SCHEMA_MAJOR:
        errors.append(
            f"content schema {schema} is incompatible with supported major {SUPPORTED_SCHEMA_MAJOR}"
        )
    if errors:
        raise EditionRejected("activation refused:\n- " + "\n- ".join(errors))

    pack = stamp_checksum(pack)
    checksum = pack["edition"]["checksum"]
    relative_pack = str(Path(relative_dir) / "content_pack.json").replace("\\", "/")
    destination = root / relative_pack
    destination.parent.mkdir(parents=True, exist_ok=True)
    staged = destination.with_suffix(".json.staged")
    write_json(staged, pack)
    staged.replace(destination)

    previous = read_pointer(root)
    if previous and previous.get("checksum") == checksum and previous.get("pack_relative_path") == relative_pack:
        pointer = dict(previous)
        pointer["publication_gate"] = publication_gate
        pointer["idempotent"] = True
        _write_pointer(root, pointer)
        return pointer

    pointer = {
        "edition_id": pack["edition"]["edition_id"],
        "content_schema_version": schema,
        "pack_relative_path": relative_pack,
        "checksum": checksum,
        "previous": previous,
        "publication_gate": publication_gate,
        "journal_schema_version": "1",
        "idempotent": False,
    }
    _write_pointer(root, pointer)
    return pointer


def rollback(root: Path) -> dict[str, Any]:
    pointer = read_pointer(root)
    if not pointer or not pointer.get("previous"):
        raise EditionRejected("no previous content pack is available to restore")
    restored = dict(pointer["previous"])
    restored["previous"] = None
    restored["rolled_back_from"] = pointer.get("edition_id")
    _write_pointer(root, restored)
    return restored


def gate_for(pack: dict[str, Any]) -> str:
    if publication_blockers(pack):
        return "BLOCKED_PENDING_APPROVED_BOOK"
    return "READY_FOR_FULL_CONTENT_QA"


def _write_pointer(root: Path, pointer: dict[str, Any]) -> None:
    path = root / ACTIVE_POINTER
    path.parent.mkdir(parents=True, exist_ok=True)
    staged = path.with_suffix(".json.staged")
    write_json(staged, pointer)
    staged.replace(path)
