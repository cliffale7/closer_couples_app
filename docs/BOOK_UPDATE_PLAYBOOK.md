# The book-to-app update playbook

## Goal

The owner should be able to revise the BOOK independently and then hand the Android project's Cursor agents **one new approved book release**, with no manually transcribing/editing 108 existing activities. An importer performs routine extraction, mapping, diffing, rewriting of data bundles and validation; specialist agents update changed interactive rules, graphics and QA; the release engineer creates installable output when needed.

## The minimum viable owner action

1. Add **one new complete approved edition** to `book_inbox/<edition>/`. A DOCX is accepted; a complete canonical book release package (structured chapter files+assets+manifest) is much more reliable. EPUB and PDF fallback must be supported too.
2. Paste `CURSOR_IMPORT_UPDATED_BOOK_PROMPT.txt` into Cursor Agent (or invoke an equivalent documented update command and agent workflow).
3. Read an automatically generated *Book Update Report*: source edition, chapter/art/prompt changes, risk, whether content-only or new APK, test outcome, and the final explicit installation step.

## Coordinator's required procedure

- Find newest explicitly **approved** edition. Never infer approval from a timestamp or accidental file drag.
- Snapshot/hashes before parsing. Normalize chapter hierarchy while preserving original full prose and image placement.
- Compare against previous approved edition using stable IDs and content revisions; include all 13 themes, 108+ IDs, signatures, appendices and artworks.
- Produce `planning/updates/<from>_to_<to>/DIFF.md` and a machine-readable impact report with added, deleted, moved, renamed, text changed, metadata changed, artwork changed, prompt changed, game mechanics changed and schema changes.
- Delegate affected areas to content, game, art, UX, journal, security and QA agents. Reuse unchanged verified source and assets.
- Build new content bundle and only the required binary changes. Never delete original private/session data in response to removed or renamed chapter.
- Test duplicate import idempotence, source parity, app crash/restart, content-pack rollback, old journal readings and book revision mapping.
- Produce versioned release outputs and export a one-page summary for the owner.

## Three kinds of changes

**Content-only:** Text copy, supported markup and compatible artwork; eligible for validated signed/authenticated content pack import if implemented. Full APK also fine.

**UX/rule change:** Round logic, new activity components or navigation; requires app code change and APK build, even if source text was imported automatically.

**Incompatible schema/native change:** Requires migration, explicit compatibility tests, APK build and careful rollback. The owner may need to update the installed APK first.

## No-loss guarantee contract

- Personal journals are **not part of the book source**. They live in a separate private database and never travel to Cursor merely because a book edition was imported.
- Old session records reference `experience_id`, `book_edition` and `prompt_revision`; display the historical prompt and activity rules when reviewing old answers.
- Renames preserve IDs, moved chapters preserve IDs, removed chapters remain in a legacy archive if used by any personal records.
- Repeated imports are idempotent; a failed update leaves prior active content and private data intact.
- Backups are user-chosen, encrypted where implemented, and verified with round-trip tests.

## First-time setup vs ongoing updates

The first complete finished book **gates** full app content. The source v0.1 included in this package is the inventory baseline, not publishable content. Cursor may develop app architecture and importer before the final book arrives. An approved complete book then seeds the canonical content snapshot. Later complete editions produce diffs against it.

## Realistic automation scope

Dropping a book file into a repository does not by itself wake dormant Cursor agents or update an installed device. A human-triggered one-message agent workflow is the baseline; optional CI/remote project automation can be configured separately if available. Routine, structured content updates should be deterministic and testable without expensive wholesale AI regeneration. Model/agent work should concentrate on changed meaning, mechanics and imagery.

## Commands in this project

From the repository root:

```powershell
powershell -File tools\update_from_book.ps1 --baseline --dry-run
powershell -File tools\update_from_book.ps1 --baseline --apply --report
powershell -File tools\update_from_book.ps1 --inbox book_inbox --dry-run --report
powershell -File tools\update_from_book.ps1 --inbox book_inbox --apply
```

`powershell -File tools\update_from_book.ps1 --book-project C:\Users\cliff\.cursor\The_Closer_Project --apply --report` loads the copyedited markdown draft. That command does not set `owner_approved`, and the publication gate stays blocked.

`--baseline` rebuilds the v0.1 inventory and leaves the publication gate blocked. An inbox edition is eligible when its `manifest.json` has `"approval": "owner_approved"`. Folder timestamps are ignored. `"approval": "draft"` is not overridden by `--approved`.

`--dry-run` prints a JSON summary and, with `--report`, writes `planning/updates/<from>_to_<to>/DIFF.md`. `--apply` swaps `content/active/active_edition.json` only after the pack validates. The journal database is not opened.

Unix-style environments can use `tools/update_from_book.sh` with the same arguments. The Python entry point is `tools/book_ingest/sync_latest_book.py`. Tests live in `tools/book_ingest/tests/` and use the standard library only.

