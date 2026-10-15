"""Shared hashing and errors. Journal text must never be logged here."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any


class IngestError(Exception):
    """Recoverable intake failure. Callers leave the active edition in place."""


class ArchiveRejected(IngestError):
    pass


class EditionRejected(IngestError):
    pass


class JournalMutationError(IngestError):
    pass


def canonical_dumps(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_text(text: str) -> str:
    return sha256_bytes(text.encode("utf-8"))


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def pack_checksum(pack: dict[str, Any]) -> str:
    """Checksum ignores volatile import timestamps."""

    clone = json.loads(json.dumps(pack))
    edition = clone.get("edition") or {}
    edition["checksum"] = None
    edition.pop("imported_at", None)
    clone["edition"] = edition
    return sha256_text(canonical_dumps(clone))


def stamp_checksum(pack: dict[str, Any]) -> dict[str, Any]:
    pack = json.loads(json.dumps(pack))
    pack.setdefault("edition", {})["checksum"] = None
    pack["edition"]["checksum"] = pack_checksum(pack)
    return pack


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def normalize_apostrophes(text: str) -> str:
    return (
        text.replace("\u2019", "'")
        .replace("\u2018", "'")
        .replace("\u2013", "-")
        .replace("\u2014", "-")
    )
