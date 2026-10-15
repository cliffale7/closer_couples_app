"""Load The Closer Project markdown tree. A draft never becomes owner-approved here.

The loader reads chapters, signatures, front matter, part introductions, and artwork.
It does not walk journal/private or any other private directory.
"""

from __future__ import annotations

import re
import shutil
from pathlib import Path
from typing import Any

from book_ingest import CONTENT_SCHEMA_VERSION
from book_ingest.catalog import REQUIRED_SIGNATURES
from book_ingest.common import EditionRejected, normalize_apostrophes, sha256_file, sha256_text
from book_ingest.pack import empty_metadata

EDITION_ID = "v1-draft"
ART_PREFIX = "content/canonical/v1-draft/art"


def build_book_project_pack(
    project: Path,
    catalog: dict[str, Any],
    *,
    require_complete: bool = True,
) -> dict[str, Any]:
    project = project.resolve()
    if not (project / "chapters").is_dir():
        raise EditionRejected(f"{project} has no chapters directory")

    catalog_by_id = {
        f"{int(item['id']):03d}": item for item in catalog.get("experiences") or []
    }
    parts = _parts(project, catalog)
    experiences = []
    assets = []
    for path in sorted((project / "chapters").rglob("*.md")):
        _refuse_private(project, path)
        meta, body = _split_front_matter(path.read_text(encoding="utf-8"))
        stable_id = str(meta.get("id") or "").strip()
        if not re.fullmatch(r"\d{3}", stable_id):
            raise EditionRejected(f"{path.name} has no three-digit id")
        catalog_item = catalog_by_id.get(stable_id)
        if catalog_item is None:
            raise EditionRejected(f"{stable_id} is not in the baseline catalog")
        title = str(meta.get("title") or "").strip()
        if normalize_apostrophes(title) != normalize_apostrophes(str(catalog_item.get("title") or "")):
            raise EditionRejected(
                f"{stable_id} title {title!r} does not match the catalog title {catalog_item.get('title')!r}"
            )
        part_number = int(meta.get("part") or catalog_item.get("part_number") or 0)
        part_title = str(meta.get("part_title") or "")
        expected_part = next(
            (part for part in catalog.get("parts") or [] if int(part["part_number"]) == part_number),
            None,
        )
        if expected_part is None:
            raise EditionRejected(f"{stable_id} is in unknown part {part_number}")
        if part_title and normalize_apostrophes(part_title) != normalize_apostrophes(
            str(expected_part.get("part_title") or "")
        ):
            raise EditionRejected(f"{stable_id} part title {part_title!r} does not match the catalog")
        experiences.append(
            _experience(
                project,
                stable_id=stable_id,
                numeric_id=int(stable_id),
                title=title,
                part_id=f"part-{part_number:02d}",
                meta=meta,
                body=body,
                assets=assets,
                art_name=f"{stable_id}.svg",
            )
        )

    experiences.sort(key=lambda item: item["stable_id"])
    signatures = []
    for path in sorted((project / "signature").glob("S*.md")):
        _refuse_private(project, path)
        meta, body = _split_front_matter(path.read_text(encoding="utf-8"))
        stable_id = str(meta.get("id") or path.name[:3]).strip()
        signatures.append(
            _experience(
                project,
                stable_id=stable_id,
                numeric_id=None,
                title=str(meta.get("title") or stable_id),
                part_id=None,
                meta=meta,
                body=body,
                assets=assets,
                art_name=f"{stable_id}.svg",
            )
        )
    signatures.sort(key=lambda item: item["stable_id"])

    if require_complete:
        _require_complete(project, experiences, signatures, parts)

    source_paths = [
        path
        for folder in ("chapters", "signature", "frontmatter", "parts", "assets")
        if (project / folder).exists()
        for path in sorted((project / folder).rglob("*"))
        if path.is_file() and not _is_private(project, path)
    ]
    pack = {
        "content_schema_version": CONTENT_SCHEMA_VERSION,
        "edition": {
            "source_book_id": "the-closer-project",
            "edition_id": EDITION_ID,
            "version": "1.0.0-draft",
            "publication_date": None,
            "source_hashes": {"book_project": _fingerprint(source_paths)},
            "imported_at": None,
            "provenance": "Copyedited v1 draft from The Closer Project markdown. Not owner-approved.",
            "locale": "en",
            "approval_state": "draft",
            "completeness": "copyedited_draft",
            "app_compatibility": ">=0.1.0 <2.0.0",
            "checksum": None,
            "cover_asset": _stage_named(project, assets, "assets/covers/cover-front.svg", "cover-front.svg"),
            "back_cover_asset": _stage_named(project, assets, "assets/covers/cover-back.svg", "cover-back.svg"),
        },
        "parts": parts,
        "experiences": experiences,
        "signatures": signatures,
        "front_matter": _front_matter(project),
        "prompts": [],
        "assets": assets,
        "legacy_archive": [],
        "required_signature_ids": list(REQUIRED_SIGNATURES),
    }
    for part in parts:
        opener = project / "assets" / "parts" / f"{int(part['ordinal']):02d}-opener.svg"
        if opener.exists():
            part["art_asset"] = _stage_named(
                project, assets, str(opener.relative_to(project)).replace("\\", "/"), f"part-{int(part['ordinal']):02d}.svg"
            )
    return pack


def copy_staged_art(pack: dict[str, Any], project: Path, destination: Path) -> int:
    """Copy only the artwork records already staged on the pack."""

    destination.mkdir(parents=True, exist_ok=True)
    copied = 0
    for asset in pack.get("assets") or []:
        source = project / str(asset.get("source_relative") or "")
        target_name = Path(str(asset.get("path") or "")).name
        if not source.is_file() or not target_name:
            raise EditionRejected(f"artwork record {asset.get('asset_id')} has no source file")
        shutil.copyfile(source, destination / target_name)
        copied += 1
    return copied


def _experience(
    project: Path,
    *,
    stable_id: str,
    numeric_id: int | None,
    title: str,
    part_id: str | None,
    meta: dict[str, Any],
    body: str,
    assets: list[dict[str, Any]],
    art_name: str,
) -> dict[str, Any]:
    sections = _section_blocks(stable_id, body)
    if not sections:
        raise EditionRejected(f"{stable_id} has no chapter prose")
    deck = str(meta.get("deck") or "").strip()
    blocks = []
    if deck:
        blocks.append(
            {
                "block_id": f"{stable_id}-deck",
                "kind": "deck",
                "heading": "In short",
                "text": deck,
                "origin": "verbatim_markdown",
            }
        )
    blocks.extend(sections)
    motif = str(meta.get("motif") or "").strip().replace("\\", "/")
    art_asset = None
    asset_ids = []
    if motif:
        source = project / motif
        if not source.is_file():
            raise EditionRejected(f"{stable_id} motif is missing: {motif}")
        asset_id = f"motif-{stable_id}"
        art_asset = f"{ART_PREFIX}/{art_name}"
        asset_ids.append(asset_id)
        assets.append(
            {
                "asset_id": asset_id,
                "kind": "motif",
                "path": art_asset,
                "source_relative": motif,
                "checksum": sha256_file(source),
                "alt_text": f"Motif for {title}",
            }
        )
    metadata = empty_metadata()
    time_band = str(meta.get("time_band") or "").strip()
    energy = str(meta.get("energy") or "").strip()
    depth = str(meta.get("emotional_intensity") or "").strip()
    metadata.update(
        {
            "time_buckets": [time_band] if time_band else [],
            "outcomes": _string_list(meta.get("moods")),
            "energy": [energy] if energy else [],
            "depth": [depth] if depth else [],
            "formats": _string_list(meta.get("formats")),
            "materials_required": _string_list(meta.get("materials")),
            "duration_summary": _duration_summary(meta.get("durations")),
            "primary_minutes": meta.get("primary_minutes"),
        }
    )
    return {
        "stable_id": stable_id,
        "numeric_id": numeric_id,
        "title": title,
        "aliases": [],
        "part_id": part_id,
        "provenance": "v1_draft_markdown",
        "prose_blocks": blocks,
        "preparation": [],
        "materials": _string_list(meta.get("materials")),
        "steps": [],
        "variants": [],
        "debrief": None,
        "prompt_ids": [],
        "reference_ids": [],
        "asset_ids": asset_ids,
        "art_asset": art_asset,
        "metadata": metadata,
        "interaction_definition": None,
        "interaction_version": None,
        "source_gaps": [],
    }


def _parts(project: Path, catalog: dict[str, Any]) -> list[dict[str, Any]]:
    intros = _part_intros(project / "parts" / "INTRODUCTIONS.md")
    parts = []
    for part in catalog.get("parts") or []:
        number = int(part["part_number"])
        parts.append(
            {
                "stable_id": f"part-{number:02d}",
                "ordinal": number,
                "name": part["part_title"],
                "intro": intros.get(number),
                "intro_origin": "verbatim_markdown" if intros.get(number) else "source_gap",
                "experience_ids": [f"{int(item):03d}" for item in part.get("ids") or []],
                "art_asset": None,
            }
        )
    return parts


def _part_intros(path: Path) -> dict[int, str]:
    if not path.is_file():
        return {}
    _refuse_private(path.parents[1], path)
    text = path.read_text(encoding="utf-8")
    intros = {}
    matches = list(re.finditer(r"^##\s+(\d+)\s*$", text, re.M))
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        body = text[start:end].strip()
        if body:
            intros[int(match.group(1))] = body
    return intros


def _front_matter(project: Path) -> list[dict[str, Any]]:
    folder = project / "frontmatter"
    if not folder.is_dir():
        return []
    items = []
    for path in sorted(folder.glob("*.md")):
        _refuse_private(project, path)
        body = path.read_text(encoding="utf-8").strip()
        title = path.stem
        for line in body.splitlines():
            if line.startswith("# "):
                title = line[2:].strip()
                break
        stable_id = f"front-{path.stem.split('-')[0]}"
        items.append(
            {
                "stable_id": stable_id,
                "numeric_id": None,
                "title": title,
                "aliases": [],
                "part_id": None,
                "provenance": "v1_draft_front_matter",
                "prose_blocks": _section_blocks(stable_id, body) or [
                    {
                        "block_id": f"{stable_id}-body",
                        "kind": "section",
                        "heading": title,
                        "text": body,
                        "origin": "verbatim_markdown",
                    }
                ],
                "metadata": empty_metadata(),
                "interaction_definition": None,
                "source_gaps": [],
                "art_asset": None,
            }
        )
    return items


def _require_complete(
    project: Path,
    experiences: list[dict[str, Any]],
    signatures: list[dict[str, Any]],
    parts: list[dict[str, Any]],
) -> None:
    found = {item["stable_id"] for item in experiences}
    missing = [f"{number:03d}" for number in range(1, 109) if f"{number:03d}" not in found]
    if missing:
        raise EditionRejected(f"draft is missing {len(missing)} catalog chapters, starting {missing[0]}")
    short = []
    for item in experiences:
        words = len(" ".join(block["text"] for block in item["prose_blocks"] if block["kind"] == "section").split())
        if words < 1200:
            short.append(f"{item['stable_id']} ({words} words)")
    if short:
        raise EditionRejected("chapters under 1,200 words: " + ", ".join(short[:8]))
    found_signatures = {item["stable_id"] for item in signatures}
    missing_signatures = [item for item in REQUIRED_SIGNATURES if item not in found_signatures]
    if missing_signatures:
        raise EditionRejected("missing signatures " + ", ".join(missing_signatures))
    empty_intros = [part["stable_id"] for part in parts if not str(part.get("intro") or "").strip()]
    if empty_intros:
        raise EditionRejected("missing part introductions: " + ", ".join(empty_intros))
    if not (project / "assets" / "covers" / "cover-front.svg").is_file():
        raise EditionRejected("cover artwork is missing")


def _section_blocks(stable_id: str, body: str) -> list[dict[str, Any]]:
    blocks = []
    parts = re.split(r"\n(?=## )", body.strip())
    for index, part in enumerate(parts):
        part = part.strip()
        if not part:
            continue
        if part.startswith("## "):
            lines = part.splitlines()
            heading = lines[0][3:].strip()
            text = "\n".join(lines[1:]).strip()
        elif part.startswith("# "):
            lines = part.splitlines()
            heading = lines[0][2:].strip()
            text = "\n".join(lines[1:]).strip()
        else:
            heading = "Chapter"
            text = part
        if not text:
            continue
        blocks.append(
            {
                "block_id": f"{stable_id}-s{index:02d}",
                "kind": "section",
                "heading": heading,
                "text": text,
                "origin": "verbatim_markdown",
            }
        )
    return blocks


def _split_front_matter(text: str) -> tuple[dict[str, Any], str]:
    if not text.startswith("---"):
        return {}, text.strip()
    end = text.find("\n---", 3)
    if end < 0:
        return {}, text.strip()
    return _parse_front_matter(text[3:end]), text[end + 4 :].strip()


def _parse_front_matter(raw: str) -> dict[str, Any]:
    meta: dict[str, Any] = {}
    lines = raw.splitlines()
    index = 0
    while index < len(lines):
        line = lines[index]
        if not line.strip():
            index += 1
            continue
        if ":" not in line or line.startswith(" "):
            index += 1
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip()
        if value == "":
            nested: dict[str, Any] | list[Any]
            if index + 1 < len(lines) and lines[index + 1].lstrip().startswith("- "):
                nested = []
                index += 1
                while index < len(lines) and lines[index].startswith("  - "):
                    nested.append(_scalar(lines[index].strip()[2:]))
                    index += 1
                meta[key] = nested
                continue
            nested = {}
            index += 1
            while index < len(lines) and lines[index].startswith("  ") and ":" in lines[index]:
                child_key, child_value = lines[index].strip().split(":", 1)
                nested[child_key.strip()] = _scalar(child_value.strip())
                index += 1
            meta[key] = nested
            continue
        if value.startswith("[") and value.endswith("]"):
            meta[key] = [_scalar(item) for item in _split_list(value[1:-1]) if str(item).strip()]
        else:
            meta[key] = _scalar(value)
        index += 1
    return meta


def _split_list(value: str) -> list[str]:
    items: list[str] = []
    current: list[str] = []
    quote = ""
    for char in value:
        if quote:
            if char == quote:
                quote = ""
            else:
                current.append(char)
            continue
        if char in "\"'":
            quote = char
            continue
        if char == ",":
            items.append("".join(current).strip())
            current = []
            continue
        current.append(char)
    tail = "".join(current).strip()
    if tail:
        items.append(tail)
    return items


def _scalar(value: str) -> Any:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    if value == "true":
        return True
    if value == "false":
        return False
    if re.fullmatch(r"-?\d+", value):
        return int(value)
    return value


def _string_list(value: Any) -> list[str]:
    if isinstance(value, list):
        return [str(item) for item in value if str(item).strip()]
    if isinstance(value, str) and value.strip():
        return [value.strip()]
    return []


def _duration_summary(value: Any) -> str:
    if not isinstance(value, dict):
        return ""
    labels = (("short", "Short"), ("standard", "Standard"), ("extended", "Extended"))
    pieces = [f"{label} {value[key]}" for key, label in labels if value.get(key)]
    return " · ".join(pieces)


def _stage_named(project: Path, assets: list[dict[str, Any]], source_relative: str, art_name: str) -> str | None:
    source = project / source_relative
    if not source.is_file():
        return None
    asset_id = f"art-{Path(art_name).stem}"
    path = f"{ART_PREFIX}/{art_name}"
    assets.append(
        {
            "asset_id": asset_id,
            "kind": "edition_art",
            "path": path,
            "source_relative": source_relative.replace("\\", "/"),
            "checksum": sha256_file(source),
            "alt_text": Path(art_name).stem.replace("-", " "),
        }
    )
    return path


def _fingerprint(paths: list[Path]) -> str:
    lines = [f"{sha256_file(path)} {path.name}" for path in paths]
    return sha256_text("\n".join(lines))


def _is_private(project: Path, path: Path) -> bool:
    try:
        parts = path.resolve().relative_to(project).parts
    except ValueError:
        return True
    return any(part.casefold() == "private" for part in parts)


def _refuse_private(project: Path, path: Path) -> None:
    if _is_private(project, path):
        raise EditionRejected(f"refusing to read a private path: {path}")
