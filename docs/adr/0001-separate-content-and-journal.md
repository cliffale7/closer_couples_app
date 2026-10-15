# ADR 0001 — Separate content packs from the journal

The book edition and the couple's notes are different lifetimes. A revised chapter must not rewrite or delete a note, and a note must not be stored inside the content asset.

The content pack is versioned JSON addressed by stable experience ids. The journal is a separate SQLite database. Sessions remember `content_edition_id`, and answers remember `prompt_id` plus `prompt_revision`. Historical text is read from the edition that was active when the note was written, which remains on disk as an immutable pack.

Schema changes to the journal have a single owner, `lib/data/private/journal_database.dart`. An unknown upgrade throws rather than recreating the file.

Encrypted backup and Android auto-backup are not treated as done. Auto-backup is disabled until an explicit export exists and is tested.
