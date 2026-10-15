# Architecture

The Closer Project Android app keeps the book and the couple's writing in separate stores.

## Content

`tools/book_ingest/` builds an immutable content pack from an approved edition, or from the v0.1 catalog when that is all that exists. The active pointer is `content/active/active_edition.json`. The app loads `content/canonical/baseline-v0.1/content_pack.json` as an asset. That pack is an inventory: 108 premises, 13 part names, and 12 labeled design briefs. It is not finished chapter prose.

Stable experience ids are the join key. Titles are display text and, after a rename, searchable aliases. Removed experiences move to `legacy_archive` so old notes can still show a title. They drop out of Surprise Us and the active catalog.

## Journal

`JournalDatabase` is a private SQLite file, schema version 1, owned by `lib/data/private/journal_database.dart`. A missing migration throws instead of deleting notes. Sessions record the content edition id in use at the time. Journal rows store prompt id and prompt revision. A later book import does not open this database.

Private rows have an owner profile. Shared rows are written only when that scope is chosen. Profile switching is organizational. Android auto-backup is off. Encrypted export is not implemented yet.

## Discovery and sessions

Time, feeling, energy, depth, and format filters are AND across groups. An experience with no metadata for a selected filter is not eligible. Surprise Us samples only the eligible list, with a seed, a reroll, and a pass list. The session runner is a small step engine. The settings preview is a labeled fixture, not a book chapter. Baseline experiences do not pretend to have guided steps.

## Versions in this build

- App `0.1.0+1`
- Book source `baseline-v0.1`
- Content schema `1.0.0`
- Journal schema `1`
- Publication gate `BLOCKED_PENDING_APPROVED_BOOK`

## Update command

```powershell
powershell -File tools\update_from_book.ps1 --inbox book_inbox --dry-run
powershell -File tools\update_from_book.ps1 --baseline --apply
```

An approved edition needs `manifest.json` with `"approval": "owner_approved"`. A draft marker is not overridden by a flag. Applying a pack does not change an installed APK until that build is installed or a future content-pack importer is verified.
