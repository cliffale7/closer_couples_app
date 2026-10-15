# ADR 0002 — Import and diff before hardcoded chapters

The v0.1 manuscript says it is an inventory, not finished prose. The app therefore ships a generated content pack and a publication gate instead of 108 authored chapters.

`tools/book_ingest/` validates the catalog, extracts DOCX, EPUB, Markdown, and a cautious PDF fallback, diffs by stable id, and activates a pack only after structural checks. A failed activation leaves the previous pointer in place. Rollback restores that pointer and does not touch the journal.

Interactive steps are data for a shared session runner. Until an approved book supplies them, the reader shows source gaps and labeled baseline text only. The settings preview is an app fixture and says so.

Flutter state is an `AppController` plus repository injection. That keeps widget tests able to open an in-memory journal without a device.
