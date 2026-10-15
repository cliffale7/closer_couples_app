# Production board

Source edition: `v1-draft` from `C:\Users\cliff\.cursor\The_Closer_Project`. App `0.1.0+2`. Content schema `1.0.0`. Journal schema `1`.
Active pack checksum: `244f38b274574b10879b88f500c5945fc1d0f855d34b5ee279c610fe11b063fc`.
Publication gate: `BLOCKED_PENDING_APPROVED_BOOK`. Approval state: `draft`. Completeness: `copyedited_draft`.

The active pack has 108 copyedited chapters, six signature sessions, six front-matter pieces, 13 part introductions, and 129 SVG artworks. The v0.1 inventory remains available at `content/canonical/baseline-v0.1` and is no longer the pack the app loads. Chapter rows in `planning/chapter_status.json` are `copyedited_draft`. `book_validated` stays false.

## Project gates

- [x] Source baseline validated (108 IDs / 13 parts) — catalog test plus the real manuscript audit. This does not validate finished prose.
- [ ] First FULL approved book received — the loaded edition is the copyedited v1 draft. Its own export manifest says it is not finished, and it is not `owner_approved`.
- [x] Import/diff system built and tested — 27 Python tests, including draft import, private-path refusal, and the earlier approval and rollback cases.
- [ ] UI design system and Android framework tested — `flutter analyze` is clean and 14 Flutter tests pass. The debug build is on a phone. No TalkBack pass yet.
- [ ] 18 agents delegated and producing artifacts
- [x] All full book content/adaptations integrated — draft prose, filters, signatures, motifs, and a chapter-guided visit are in the app.
- [x] All 108 + signatures have runnable mobile modes — Begin this chapter walks that chapter’s own sections and Our Story pages. There is no separate scoring engine for each game.
- [ ] All original art integrated and mobile assets validated — 129 SVGs are bundled. They have not been checked on a device.
- [ ] Secure partner/shared journaling and backup/restore proven — owner-scoped notes, revisits, and plain JSON export/restore are tested. The file is not encrypted.
- [ ] Future book revision pipeline proven end-to-end — dry-run, activation, and this draft import pass. An owner-approved drop has not been run.
- [ ] Independent QA passes
- [ ] Real APK built, installed and tested — `flutter build apk --debug` produced `build/app/outputs/flutter-apk/app-debug.apk` (170,748,163 bytes). It is installed on SM G975U and the activity was started. A chapter was not walked on the device from here.

## Evidence this session

- Python: `python -m unittest discover -s tools/book_ingest/tests -t tools` — 27 passed on 2026-10-14. Not re-run for the session and export work.
- Flutter: `flutter analyze` — no issues. `flutter test` — 14 passed, including chapter 001’s Our Story prompts and a journal restore onto the matching profile slot.
- Import: `python tools/book_ingest/sync_latest_book.py --book-project C:\Users\cliff\.cursor\The_Closer_Project --apply --report`
- Pack: `content/canonical/v1-draft/content_pack.json` (1,940,339 bytes) and `content/canonical/v1-draft/art/` (129 SVG files).
- Diff from `baseline-v0.1`: 108 text changes, 108 metadata changes, 108 artwork changes. Journal rows were not opened.
- Install: `flutter install --debug -d R58M73YRFKF` on SM G975U, Android 12.

## Next checkpoint

On the phone, begin chapter 001, write one private page and one shared page, then use Settings to export the notes and restore them. The export file is plain JSON and is not encrypted.

The publication gate stays blocked until you say this draft is the approved book. `--approved` cannot promote a draft manifest or this book-project import.
