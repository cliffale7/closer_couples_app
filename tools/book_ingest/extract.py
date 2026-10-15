"""Extract text from DOCX, EPUB, Markdown, JSON, and a cautious PDF fallback.

PDF extraction without a parser library is low confidence and is labeled as such.
Archives are rejected before any file is written to disk.
"""

from __future__ import annotations

import re
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

from book_ingest.common import ArchiveRejected, sha256_file

WORD_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
MAX_FILES = 10_000
MAX_ENTRY_BYTES = 80 * 1024 * 1024
MAX_TOTAL_BYTES = 400 * 1024 * 1024
MAX_RATIO = 100
RATIO_FLOOR_BYTES = 5 * 1024 * 1024

_FRONT_MATTER = re.compile(r"\A---\r?\n(.*?)\r?\n---\r?\n", re.DOTALL)
_BRIEF_HEADING = re.compile(r"^##\s+(\d{3})\.\s+(.+?)\s*$", re.MULTILINE)


def assert_safe_zip(
    path: Path,
    *,
    max_files: int = MAX_FILES,
    max_entry_bytes: int = MAX_ENTRY_BYTES,
    max_total_bytes: int = MAX_TOTAL_BYTES,
    max_ratio: int = MAX_RATIO,
    ratio_floor_bytes: int = RATIO_FLOOR_BYTES,
) -> zipfile.ZipFile:
    if not zipfile.is_zipfile(path):
        raise ArchiveRejected(f"not a zip archive: {path.name}")
    archive = zipfile.ZipFile(path)
    try:
        infos = archive.infolist()
        if len(infos) > max_files:
            raise ArchiveRejected("archive has too many entries")
        total = 0
        for info in infos:
            name = info.filename.replace("\\", "/")
            parts = [part for part in name.split("/") if part not in ("", ".")]
            if name.startswith("/") or re.match(r"^[A-Za-z]:", name) or ".." in parts:
                raise ArchiveRejected(f"unsafe archive path: {info.filename}")
            if info.file_size < 0 or info.file_size > max_entry_bytes:
                raise ArchiveRejected(f"entry exceeds size limit: {info.filename}")
            total += info.file_size
            if total > max_total_bytes:
                raise ArchiveRejected("archive uncompressed size exceeds limit")
            if (
                info.compress_size > 0
                and info.file_size > ratio_floor_bytes
                and (info.file_size / info.compress_size) > max_ratio
            ):
                raise ArchiveRejected(f"suspicious compression ratio: {info.filename}")
        return archive
    except Exception:
        archive.close()
        raise


def extract_docx(path: Path) -> dict[str, object]:
    archive = assert_safe_zip(path)
    try:
        try:
            xml = archive.read("word/document.xml")
        except KeyError as exc:
            raise ArchiveRejected("DOCX is missing word/document.xml") from exc
    finally:
        archive.close()
    root = ET.fromstring(xml)
    paragraphs: list[str] = []
    headings: list[str] = []
    for paragraph in root.iter(f"{{{WORD_NS}}}p"):
        style = ""
        style_el = paragraph.find(f"{{{WORD_NS}}}pPr/{{{WORD_NS}}}pStyle")
        if style_el is not None:
            style = style_el.attrib.get(f"{{{WORD_NS}}}val", "")
        chunks: list[str] = []
        for node in paragraph.iter():
            if node.tag == f"{{{WORD_NS}}}t" and node.text:
                chunks.append(node.text)
            elif node.tag == f"{{{WORD_NS}}}tab":
                chunks.append("\t")
            elif node.tag == f"{{{WORD_NS}}}br":
                chunks.append("\n")
        text = "".join(chunks).strip()
        if not text:
            continue
        paragraphs.append(text)
        if "Heading" in style or style.lower().startswith("heading"):
            headings.append(text)
    body = "\n".join(paragraphs)
    return {
        "format": "docx",
        "confidence": "high",
        "paragraph_count": len(paragraphs),
        "word_count": len(body.split()),
        "headings": headings,
        "text": body,
        "sha256": sha256_file(path),
    }


def extract_epub(path: Path) -> dict[str, object]:
    archive = assert_safe_zip(path)
    try:
        names = [
            name
            for name in archive.namelist()
            if name.lower().endswith((".xhtml", ".html", ".htm"))
        ]
        names.sort()
        parts: list[str] = []
        for name in names:
            parts.append(_html_to_text(archive.read(name).decode("utf-8", errors="replace")))
    finally:
        archive.close()
    body = "\n\n".join(part for part in parts if part.strip())
    return {
        "format": "epub",
        "confidence": "high",
        "paragraph_count": len([line for line in body.splitlines() if line.strip()]),
        "word_count": len(body.split()),
        "text": body,
        "sha256": sha256_file(path),
    }


def extract_pdf(path: Path) -> dict[str, object]:
    data = path.read_bytes()
    library_text = _try_pypdf(path)
    if library_text is not None:
        text = library_text
        confidence = "library"
    else:
        text = _pdf_literal_strings(data)
        confidence = "low_literal_scan"
    return {
        "format": "pdf",
        "confidence": confidence,
        "paragraph_count": len([line for line in text.splitlines() if line.strip()]),
        "word_count": len(text.split()),
        "text": text,
        "sha256": sha256_file(path),
        "note": (
            "Literal PDF scan recovers simple parenthesized strings only. "
            "Prefer DOCX, EPUB, or canonical JSON when the book team can supply them."
            if confidence != "library"
            else "Extracted with the optional pypdf library."
        ),
    }


def parse_markdown_chapter(text: str) -> tuple[dict[str, str], str]:
    match = _FRONT_MATTER.match(text)
    meta: dict[str, str] = {}
    body = text
    if match:
        for line in match.group(1).splitlines():
            if ":" not in line:
                continue
            key, value = line.split(":", 1)
            meta[key.strip()] = value.strip().strip('"').strip("'")
        body = text[match.end() :]
    return meta, body.strip()


def load_expansion_briefs(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    matches = list(_BRIEF_HEADING.finditer(text))
    briefs: dict[str, str] = {}
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        stable_id = match.group(1)
        body = text[start:end].strip()
        if body:
            briefs[stable_id] = body
    return briefs


def audit_manuscript(extraction: dict[str, object], titles_by_id: dict[str, str]) -> dict[str, object]:
    text = str(extraction.get("text") or "")
    found = [stable_id for stable_id, title in titles_by_id.items() if title and title in text]
    editorial_not_finished = "NOT the finished prose" in text
    return {
        "format": extraction.get("format"),
        "confidence": extraction.get("confidence"),
        "paragraph_count": extraction.get("paragraph_count"),
        "word_count": extraction.get("word_count"),
        "sha256": extraction.get("sha256"),
        "titles_found": len(found),
        "titles_expected": len(titles_by_id),
        "missing_title_ids": [stable_id for stable_id in titles_by_id if stable_id not in found],
        "declares_not_finished_prose": editorial_not_finished,
        "finished_book": False,
        "reason": (
            "The manuscript's own editorial status says this is an inventory, not finished prose."
            if editorial_not_finished
            else "No approved complete-book marker is present in this extraction."
        ),
    }


def _html_to_text(html: str) -> str:
    without_blocks = re.sub(r"(?is)<(script|style).*?>.*?</\1>", " ", html)
    with_breaks = re.sub(r"(?i)</(p|div|h1|h2|h3|li|br)\s*>", "\n", without_blocks)
    no_tags = re.sub(r"(?s)<[^>]+>", "", with_breaks)
    lines = [re.sub(r"\s+", " ", line).strip() for line in no_tags.splitlines()]
    return "\n".join(line for line in lines if line)


def _try_pypdf(path: Path) -> str | None:
    try:
        from pypdf import PdfReader  # type: ignore

        reader = PdfReader(str(path))
        return "\n".join((page.extract_text() or "") for page in reader.pages)
    except Exception:
        return None


def _pdf_literal_strings(data: bytes) -> str:
    chunks: list[str] = []
    index = 0
    length = len(data)
    while index < length:
        if data[index] != 0x28:  # (
            index += 1
            continue
        index += 1
        chars: list[str] = []
        while index < length:
            current = data[index]
            index += 1
            if current == 0x5C:  # backslash
                if index >= length:
                    break
                escaped = data[index]
                index += 1
                mapping = {ord("n"): "\n", ord("r"): "\r", ord("t"): "\t", ord("("): "(", ord(")"): ")", ord("\\"): "\\"}
                chars.append(mapping.get(escaped, chr(escaped)))
                continue
            if current == 0x29:  # )
                break
            if current >= 32 or current in (9, 10, 13):
                chars.append(chr(current))
        text = "".join(chars).strip()
        if text and not text.startswith("%"):
            chunks.append(text)
    return "\n".join(chunks)
