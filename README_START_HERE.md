# The Closer Project — Android App Cursor Production Kit

This folder is an **implementation brief and Cursor agent scaffold**, not a completed Android app. It follows the separate **The Closer Project** finished-book production. Do NOT release a purportedly complete app based only on the included v0.1 structural manuscript.

## What's inside

- `CURSOR_ANDROID_MASTER_WORK_ORDER.md` — complete Android specification, app architecture, book-to-app parity, UX, 108 experiences, 13 parts, signature sessions, all six browse modes, interactive mechanics, artwork, privacy, journaling, QA and upgrade contract.
- `.cursor/agents/*.md` — **18 defined specialists** with real output responsibilities.
- `AGENTS.md` — enduring project rules.
- `CURSOR_ANDROID_QUICK_START_PROMPT.txt` — prompt to use when you first open the folder in Cursor.
- `CURSOR_IMPORT_UPDATED_BOOK_PROMPT.txt` — one-message prompt for all future book editions.
- `docs/BOOK_UPDATE_PLAYBOOK.md` — the exact upgrade workflow and limits.
- `docs/QA_ACCEPTANCE_MATRIX.md` — comprehensive parity and no-data-loss tests.
- `source/book_baseline/` — original 108-item inventory, initial manuscript and philosophy; **baseline reference only**.
- `book_inbox/` — place the first **completed** book version here, and later updated versions. This starts empty except for an instruction file.

## Initial use

1. Unzip this kit into a **new, separate Cursor project directory**; don't overlay the book project repository.
2. Open that folder in Cursor Agent mode.
3. Paste the text from `CURSOR_ANDROID_QUICK_START_PROMPT.txt`.
4. If the complete book is NOT ready, ask Cursor to do the intake/setup/import/update tooling and Android framework work **without pretending all book chapters are finished**.
5. When at least one complete edition exists, add the book release ZIP or complete DOCX/EPUB/PDF (and associated media if separate) to `book_inbox/<edition>/`, then paste `CURSOR_IMPORT_UPDATED_BOOK_PROMPT.txt`.
6. Once ready, install/test the resulting APK on an Android phone. A new source book does not update an installed APK until a compatible pack is explicitly imported or an updated APK is installed.

## The continuing relationship between projects

**Book authoring repo:** editorial authority and finished text/art/research.

**Android repo:** importer, mobile adaptations, UI, offline storage, companion journal, app assets, tests, release APK and revision-to-revision conversion.

The app's private personal writings are **never** stored in the book source repo, mixed into a public build, or destroyed by updating the book.

## Major distinction

The first finished book is needed to fully populate the app. Later books **must be updateable with minimal work**: one new release file/package into `book_inbox/`, one Cursor instruction, automated diff, impacted agents, tests, new content pack or app binary. The work order is intentionally explicit that this is a tool-supported workflow—not magical self-modifying software.
