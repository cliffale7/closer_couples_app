# The Closer Project — Android

This repository is the Android companion app. Start with `README_START_HERE.md` and `CURSOR_ANDROID_MASTER_WORK_ORDER.md`.

The current build is **app 0.1.0**, content edition `baseline-v0.1`. The publication gate is **BLOCKED_PENDING_APPROVED_BOOK**. The v0.1 manuscript is an inventory of 108 experiences, not finished chapters.

```powershell
flutter test
python -m unittest discover -s tools/book_ingest/tests -t tools
powershell -File tools\update_from_book.ps1 --baseline --dry-run
```

Architecture and the book-update commands are in `docs/ARCHITECTURE.md` and `docs/BOOK_UPDATE_PLAYBOOK.md`.
