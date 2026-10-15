"""Catalog, extraction, and baseline pack tests."""

from __future__ import annotations

import io
import tempfile
import unittest
import zipfile
from pathlib import Path

from book_ingest.catalog import validate_catalog
from book_ingest.common import ArchiveRejected, read_json
from book_ingest.extract import (
    assert_safe_zip,
    audit_manuscript,
    extract_docx,
    extract_epub,
    extract_pdf,
    load_expansion_briefs,
)
from book_ingest.pack import build_baseline_pack, publication_blockers

ROOT = Path(__file__).resolve().parents[3]
CATALOG = ROOT / "source" / "book_baseline" / "experience_catalog.json"
MANUSCRIPT = ROOT / "source" / "book_baseline" / "The_Closer_Project_Working_Manuscript_v0.1.docx"
BRIEFS = ROOT / "source" / "book_baseline" / "ORIGINAL_IDEAS_EXPANDED.md"


class CatalogTests(unittest.TestCase):
    def test_baseline_catalog_matches_108_and_13_parts(self) -> None:
        catalog = read_json(CATALOG)
        self.assertEqual(validate_catalog(catalog), [])

    def test_duplicate_id_is_reported(self) -> None:
        catalog = read_json(CATALOG)
        catalog["experiences"][1]["id"] = 1
        catalog["experiences"][1]["display_id"] = "001"
        errors = validate_catalog(catalog)
        self.assertTrue(any("duplicate" in error for error in errors))


class ExtractionTests(unittest.TestCase):
    def test_real_manuscript_is_inventory_not_finished_prose(self) -> None:
        extraction = extract_docx(MANUSCRIPT)
        catalog = read_json(CATALOG)
        titles = {item["display_id"]: item["title"] for item in catalog["experiences"]}
        audit = audit_manuscript(extraction, titles)
        self.assertTrue(audit["declares_not_finished_prose"])
        self.assertFalse(audit["finished_book"])
        self.assertGreater(audit["word_count"], 7000)
        self.assertLess(audit["word_count"], 15000)
        self.assertGreaterEqual(audit["titles_found"], 100)
        self.assertIn("The Stranger Across From Me", extraction["text"])

    def test_minimal_docx_epub_and_pdf(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            docx_path = root / "sample.docx"
            document = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>A finished paragraph that must stay verbatim.</w:t></w:r></w:p>
  </w:body>
</w:document>"""
            with zipfile.ZipFile(docx_path, "w") as archive:
                archive.writestr("word/document.xml", document)
            self.assertIn("must stay verbatim", extract_docx(docx_path)["text"])

            epub_path = root / "sample.epub"
            with zipfile.ZipFile(epub_path, "w") as archive:
                archive.writestr(
                    "OEBPS/ch.xhtml",
                    "<?xml version='1.0'?><html><body><p>Verbatim epub paragraph.</p></body></html>",
                )
            self.assertIn("Verbatim epub paragraph.", extract_epub(epub_path)["text"])

            pdf_path = root / "sample.pdf"
            pdf_path.write_bytes(
                b"%PDF-1.1\n"
                b"1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n"
                b"4 0 obj << /Length 44 >> stream\n"
                b"BT (Chapter 027 keeps this sentence.) Tj ET\n"
                b"endstream endobj\n%%EOF\n"
            )
            pdf = extract_pdf(pdf_path)
            self.assertIn("Chapter 027 keeps this sentence.", pdf["text"])
            self.assertIn(pdf["confidence"], ("low_literal_scan", "library"))

    def test_path_traversal_and_compression_ratio_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            unsafe = root / "unsafe.zip"
            with zipfile.ZipFile(unsafe, "w") as archive:
                archive.writestr("../escape.txt", b"bad")
            with self.assertRaises(ArchiveRejected):
                assert_safe_zip(unsafe)

            bomb = root / "bomb.zip"
            with zipfile.ZipFile(bomb, "w", compression=zipfile.ZIP_DEFLATED) as archive:
                archive.writestr("zeros.bin", b"\0" * 20000)
            with self.assertRaises(ArchiveRejected):
                assert_safe_zip(bomb, ratio_floor_bytes=1000, max_ratio=5)

            nonsense = root / "notes.txt"
            nonsense.write_text("hello", encoding="utf-8")
            with self.assertRaises(ArchiveRejected):
                extract_docx(nonsense)

    def test_oversized_declared_entry_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "big.zip"
            with zipfile.ZipFile(path, "w") as archive:
                archive.writestr("note.txt", b"tiny")
            with self.assertRaises(ArchiveRejected):
                assert_safe_zip(path, max_entry_bytes=1)


class BaselinePackTests(unittest.TestCase):
    def test_pack_preserves_titles_and_marks_gaps(self) -> None:
        pack = build_baseline_pack(CATALOG, manuscript_path=MANUSCRIPT, briefs_path=BRIEFS)
        self.assertEqual(len(pack["experiences"]), 108)
        self.assertEqual(len(pack["parts"]), 13)
        self.assertEqual(pack["signatures"], [])
        self.assertEqual(pack["edition"]["approval_state"], "baseline_inventory_only")
        catalog = read_json(CATALOG)
        for source, built in zip(catalog["experiences"], pack["experiences"], strict=True):
            self.assertEqual(built["title"], source["title"])
            self.assertEqual(built["prose_blocks"][0]["text"], source["source_premise"])
            self.assertIn("full_chapter", built["source_gaps"])
            self.assertEqual(built["metadata"]["time_buckets"], [])
        blockers = publication_blockers(pack)
        self.assertTrue(blockers)
        self.assertTrue(any("S01" in blocker for blocker in blockers))
        brief = next(item for item in pack["experiences"] if item["stable_id"] == "097")
        kinds = [block["kind"] for block in brief["prose_blocks"]]
        self.assertIn("design_brief", kinds)
        self.assertIn("full_chapter", brief["source_gaps"])
        self.assertIn("Signature twist", brief["prose_blocks"][1]["text"])
        self.assertEqual(len(load_expansion_briefs(BRIEFS)), 12)
        again = build_baseline_pack(CATALOG, manuscript_path=MANUSCRIPT, briefs_path=BRIEFS)
        self.assertEqual(pack["edition"]["checksum"], again["edition"]["checksum"])


if __name__ == "__main__":
    unittest.main()
