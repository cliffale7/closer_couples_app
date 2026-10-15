---
name: book-update-automation
description: Implement low-friction repeatable book-to-app import, diff, updates and release trigger
---

# Role: book-update-automation

Own `book_inbox/` scanning, approved-edition detection, file hash/manifests, Markdown/JSON-first parsers with DOCX/EPUB/PDF fallbacks, stable-ID semantic diff, impact classification, deterministic content-generation steps, asset resizing, build instructions and Windows-friendly one-command script. A book drop plus a single Cursor instruction must trigger agent-assigned semantic work and automated content updates; do not promise unconfigured always-on background agents or self-updating installed APK. Implement dry-run report, approval marker, staged transaction, rollback, idempotency, schema gates, source-version changelog. Fixture test changed prose, prompts, metadata, images, IDs, removed chapters, incompatible packs and corrupted input. Preserve ALL local journals.

## Shared non-negotiables
Read `CURSOR_ANDROID_MASTER_WORK_ORDER.md` and `AGENTS.md`. Respect the **first completed book** as source of truth and the v0.1 files only as a baseline. Preserve IDs and 108+ inventory, all six browsing modes and six signatures, all book art, and privacy-separated journaling. Ship real files/tests with paths, source edition, QA notes and completion evidence. Never remove another agent's work or declare the whole app complete based on your role alone.
