# Independent QA / Release Acceptance Matrix

Use this as a literal checklist with evidence file paths, build logs, screen captures, unit tests and results. Do not merely tick boxes in advance.

| Area | Required test | Evidence to record |
|---|---|---|
| Source gate | A full finished book edition imported; baseline v0.1 not passed off as finished | Approved edition hash and completeness report |
| Original inventory | IDs 001–108 exactly matched, 13 parts, no missing original ideas | Count/assertions against baseline catalog |
| Signature sessions | S01–S06 (or official equivalents) fully imported and playable | Tested mechanics and screenshots |
| Full prose | Source chapter body not reduced to summary | Per-entry text fidelity diff + manual samples |
| Artwork | 13 opener, 108 chapter art, six signatures actually show in app | Image manifest check + screen captures |
| Reader | Full chapter, variants, materials, examples, debrief, references | Reader widget/integration tests |
| Guided sessions | Start/pause/resume/pass/end/log works for each pattern | Session grammar + catalog mechanic coverage |
| 6 browsing modes | Time, outcome, energy, depth, format, Surprise Us | Facet tests and screenshots |
| Time classification | All six buckets and actual short/long variants | Source-derived metadata test |
| Random selection | Never violates boundaries or duration; handles empty results | Seeded deterministic tests |
| Two partner notes | Partner A private, Partner B private, Shared deliberate | Scope/auth tests on all data surfaces |
| Long-term memory | Unlimited dated revisits and historical answers | DB fixtures, timeline and comparison tests |
| Journal quality | Long entries, autosave, keyboard/back, optional prompted/free text | UI device tests |
| Media keepsakes | User-selected photos and attachments backed up/restored | Round-trip hashed attachments |
| Export | Human-readable keepsake, archival export and encrypted backup | Inspect real exports/restore checksums |
| Full offline | Read, play, journal, search and export on airplane mode | Real Android installation test |
| App accessibility | TalkBack, text scaling, touch/contrast, reduced motion | Audit screen captures/issue log |
| Adult voice | Direct, warm, mature; no unwanted clinical filter | Editorial review |
| Book update | Changed text/metadata/art/rules imported with clear diff | v1 -> v1.1 fixture suite |
| No-loss migrations | Thousands of entries + photos survive rename/move/remove/upgrade | Before/after row/hashes |
| Failed import | Corrupt archive/unapproved edition leaves old version intact | Rollback tests |
| Prompt revision | Old answers keep old prompt context | Historical view tests |
| App version | New APK needed when code/native/schema changes | Binary compatibility report |
| Installable | Built debug APK actually installs and runs | adb/build/device logs |
| Release | Owner signing documented accurately; keys excluded from repo | Artifact hash/manifests |
| Privacy | No journals or secret keys in Git/logs/public artifacts | Repo and build content audit |

## Fixture requirements

Prepare fictional data with: Partner A and B with distinct private notes, shared entries, >100 repeated sessions, future-dated/old sessions, edited entries, notes tied to an old renamed chapter, media attachments, changing prompt language, removed chapter, extra activity 109, huge multiline text, invalid archive, encrypted backup with correct and wrong passwords, and partial update error.

Never satisfy tests by clearing the database or regenerating fictional records in place of existing real entries. The success condition is **identity and content preservation**, not mere row counts.
