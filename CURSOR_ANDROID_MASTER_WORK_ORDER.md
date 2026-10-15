# MASTER PRODUCTION WORK ORDER FOR CURSOR
## THE CLOSER PROJECT — COMPLETE ANDROID COMPANION APP
### Book-faithful interactive experiences, private/shared memoir, original visual world, and repeatable book-to-app publishing system

**Project identity:** The Closer Project — Android. Separate code repository/workspace from the book production project, with an explicit, versioned link to the book as its authoritative content source.

**Commission:** Build a **complete, polished, offline-first Android application** that brings the *entire finished illustrated book* to life as an interactive experience for two adults. This is **not** a PDF reader wrapped in an app, a collection of 108 summary cards, a prototype, or a generic relationship quiz. It is the full content, interactive activities, substantial original artwork, all navigation modes, six signature sessions, every associated game material, and a genuinely useful personal and shared journaling/memoir system.

**Dependency:** The **first completed, approved book edition must exist before the app's content is declared complete**. The included v0.1 book manuscript is a **scope baseline only**, NOT the completed source edition. Preliminary project architecture, source audits, component prototypes and tests can be prepared before the book is completed; never fabricate, truncate, or prematurely declare the published book's chapters finished. When the completed book is provided, import and adapt **all** of it. Thereafter, accepting a **replacement or revised book file** must trigger an extremely low-friction, repeatable agent-assisted update workflow that carries the changes into the app without harming existing memories or notes.

**Audience and tone:** Thoughtful, mature, open-minded adults, specifically designed to work wonderfully for a couple building more intimacy, deeper knowledge, trust, playfulness, desire, affection, and connection. Warm, witty, irreverent where appropriate, intelligent, romantic at times, adventurous at others; never condescending, clinical by default, or written as if the relationship is broken. Keep adult sensual themes candid and consent-centered. **This is not connected to any scavenger hunt or any other unrelated project.**

---

# 0. EXECUTIVE DIRECTIVE AND DEFINITIONS OF REAL COMPLETION

Cursor, act as the **executive producer, coordinating engineering lead, product owner, and integration manager** of this multi-agent production. Coordinate the people/agents, tools, source packages, release pipeline, audits, test devices, and deliverables. Delegate real work and integrate it. Do not merely plan, scaffold, summarize, show mockups, or stop after a demo. Deliver a **working, installable, tested Android app** once the completed first edition of the book is provided.

Non-negotiables:

1. **Book parity:** All **108 experiences** (IDs 001–108) in their 13 thematic parts, **all six completed signature experiences** (S01–S06, or the actual official IDs), complete chapter copy, complete instructions, optional paths, examples, questions, game mechanics, debriefs, and important front/back matter from the finished book. Every item is readable offline. Any future book-added experiences must also be imported, without a hard-coded 108 limit.
2. **Interactive adaptation:** Convert activities into thoughtful digital experiences with steps, prompts, timers, turn-taking, selection cards, scoring only when meaningful, randomized scenarios, choices, checklists, and replay—while preserving the book's full prose in a readable **Full Chapter** mode. No functionality that contradicts or oversimplifies the book.
3. **Serious memoir functionality:** For every experience, provide dated **Partner A personal notes**, **Partner B personal notes**, **our shared reflections**, optional answers to prompts, completion/revisit records, photos or other selected keepsakes, and a chronological **Our Story** timeline. Unlimited revisits, comparison with past answers, searching, exporting, importing, and recoverable backups. Never invent private user memories.
4. **Useful discovery:** All six agreed browsing systems: time, desired feeling/outcome, energy, emotional depth, format, and filtered **Surprise Us**. Also themes/parts, A–Z, recently visited, unfinished, favorites, and revisit recommendations.
5. **Visual production:** A cohesive mature visual design informed by the book, with artwork and textures integrated into the real app. Reuse approved book assets where appropriate; produce mobile-specific derivatives, interactive diagrams, controls, and new illustrations when needed. Graphics must actually be present in screen builds, not just an art folder.
6. **Privacy & autonomy:** App works without internet, login, server, paid account, subscription, analytics or forced cloud sync. Journals are kept locally by default, with privacy controls, user-selected export/backup, and a tested recovery path. No intimate content embedded in logs or transmitted by default.
7. **Maintainable synchronization:** Book content and personal data live in **separate storage domains**. Importing a new book must never erase or overwrite journal entries. Implement stable IDs, versioned content, structured change reports, schema migrations, staged release packages, rollback, and repeatable validation.
8. **Real release:** Deliver reproducible Flutter/Android source, debug APK, properly signed release APK/AAB **where appropriate signing credentials are available**, screenshots, build logs, test report, import pipeline, example sanitized fixtures, and written install/update instructions. Do not invent signing keys for the user's production identity or promise a Play Store launch without the necessary owner-controlled accounts.
9. **Do not confuse authoring update with device update:** Sharing a revised book with the *Cursor app project* causes the agents to revise the **source project and produce an app/content update** after running the ingestion workflow. It does **not magically update an installed APK** unless a separate install/distribution mechanism has been configured. Build a painless one-command/one-message process, plus an optional compatible in-app content-pack import if feasible and properly verified.
10. **Persistence across sessions:** Source-controlled work, agent handoffs, status boards, acceptance matrices, tests, and resumable work batches. If a tool limit or dependency blocks completion, save real state and explicitly identify the missing item; do not silently downgrade the finish line.

**First release target:** A complete Android **v1.0 first draft**, not a sample or MVP. The editorial wording “first draft” allows future refinement—not missing screens, placeholder content, broken imports or unimplemented activities.

---

# 1. AUTHORITATIVE INPUTS, SOURCE ORDER, AND DEPENDENCY GATE

### Provided with this production work order

- `source/book_baseline/The_Closer_Project_Working_Manuscript_v0.1.docx`: original 33-page structural manuscript and complete 108-item baseline inventory.
- `source/book_baseline/The_Closer_Project_Concept_and_Feedback_Invitation.docx`: intent, philosophy, audience, reader experience, and feedback brief.
- `source/book_baseline/experience_catalog.json`: machine-readable original stable ID/title/part/premise inventory.
- `source/book_baseline/ORIGINAL_IDEAS_EXPANDED.md`: distinguishing twists and expanded intentions for activities 097–108.
- `source/book_baseline/BOOK_MASTER_WORK_ORDER_REFERENCE.md`: binding book-production requirements for illustrations, research, expanded writing, signature sessions, journaling and publishing.

### Book delivery: what to look for later

The finished book project may supply a complete DOCX, EPUB, PDF, Markdown chapter directory, accompanying image files, publication manifest, metadata, research ledger, journals, worksheets, game cards and signature sessions. **Prefer the canonical completed book content package over a PDF-only extraction**. Never demand a format the user did not receive: support a DOCX-only or EPUB-only finished book as an ingestion path, with an extraction verification report. In a PDF-only case, inspect text and embedded graphics, flag anything genuinely not recoverable and do not invent missing paragraphs.

### Source authority order

1. The **latest owner-approved, completed book release** in `book_inbox/` or `book_sources/approved/` (canonical chapter Markdown/JSON and corresponding assets take precedence when included with release).
2. Its companion release manifest, approved worksheets, journals, game decks, signature materials, and references.
3. The completed DOCX / EPUB edition to cross-check exact prose, headings, typography intent, and ordering.
4. Its PDF edition for visual/layout fidelity and missing assets, not as a preferred structured-text parser.
5. Baseline v0.1 manuscript/catalog for **identity matching and coverage checking**, not as a replacement for missing finished writing.
6. This work order for functional Android requirements, even when the print book has no app-specific guidance.

When these disagree, record a reconciliation ticket and choose the correct authority **per topic**. Never quietly shorten a completed chapter just to fit a screen. Never let a text extraction algorithm reword emotional nuance unnoticed. Preserve author-approved wording unless a mobile-specific adaptation is clearly separately labeled as UX copy.

### Mandatory first-edition gate

- Validate that the supplied edition really contains fully written chapters for all 108 IDs, 13 parts, and six signature experiences or explicitly record any incomplete source areas.
- Compare substantive chapter length, expected sections, appendices and artwork against the book's own production checklist. Detect placeholders and missing modules.
- The app can have a *development build* before the book is ready; it **must not be labeled full-book v1.0** until authoritative complete content is imported and all acceptance criteria pass.
- If the book hasn't yet been supplied, build the tooling, schema, UI framework and source-aware tests now, leaving the publication gate **BLOCKED_PENDING_APPROVED_BOOK**. Do not pad the empty space with fabricated “completed” book content.

---

# 2. TEAM OF SPECIALIST AGENTS — USE AND DELEGATE

Use the installed project `.cursor/agents/*.md` agent definitions (update syntax only if required by the installed Cursor version). Use actual delegation/parallel execution when available. Parent coordinator owns scheduling and integration. Agents work in separable files/branches, not over the same UI or dataset at once. Each handoff must write a durable file/artifact and pass validation. Research comes before content interpretation; UI contracts before implementation; independent verification after integration.

**Agent roster and obligations:**

1. **Source Librarian & Book Ingestor** — ingest approved releases, inspect DOCX/EPUB/PDF/JSON/Markdown, extract assets, match IDs, preserve exact source, build normalized records and report uncertain extraction.
2. **Research & Provenance Verifier** — cross-check the book's claims, source notes, evidence classification, attribution and adult-exercise cautions; flag doubtful statements rather than making up studies.
3. **Editorial Content Adaptation Lead** — preserve every finished chapter and adapt navigation, prompt cards, reflective questions and UI microcopy without changing meaning, voice or substantive material.
4. **Interactive Games & Activity Designer** — implement playable mechanics, turn logic, timers, chance mechanics, optional intensity paths, and physical-world instructions for each of the 108 experiences and signature sessions.
5. **Romance / Sensuality Experience Specialist** — ensure adult relationship content remains mature and unawkward on mobile; clarify consent, optional touch, shared/private responses, and pause/skip features without censoring the book's legitimate tone.
6. **Product & UX Architect** — own journeys, information architecture, low-friction session starts, accessibility flows, dual-person navigation and design coherence; make the app more useful than an ebook viewer.
7. **Flutter / Android Architect** — select/pin maintainable technology, define feature/domain layers, app lifecycle, platform interfaces, DI, navigation, state, performance and build configuration.
8. **Flutter UI Implementation Engineer** — create the actual screens, components, animations, microinteractions, forms, filters and navigation; use modular components and meaningful state.
9. **Content Model & Migration Engineer** — define stable schema, content bundles, import transactions, metadata, version migrations, semantic diffs and compatibility checks.
10. **Private Data / Security Engineer** — engineer journal database, encryption/key storage, profile boundaries, data export and verified restoration, safe files, privacy, and protection against logging/uploading intimate content.
11. **Memoir & Journaling Experience Designer** — define per-experience prompts, free-writing, partner/private/shared journals, dated replay, cross-session insights, memory timeline and long-term keepsake exports.
12. **Art Direction & Asset Adaptation Lead** — derive and maintain app design tokens from book design, optimize covers/part art/chapter imagery/textures, and produce asset map/alt text.
13. **Illustration / Animation / Sensory Asset Producer** — make original in-app art, diagrams, card faces, discreet animation, sound/haptic ideas where helpful; retain licenses and editable sources.
14. **Accessibility & Usability Specialist** — screen reader, dynamic type, contrast, motion sensitivity, alternatives for eye-gazing/touch/blindfold/audio exercises, tappable controls and offline usability.
15. **Copyeditor & Content Consistency Checker** — ensure exact title/ID/prose mapping, consistent phrasing, sane links, errors corrected, and high-quality readable prose on devices.
16. **Automation & Update Pipeline Engineer** — implement drop-in book update, diff reports, deterministic generation, manual/CI update trigger, migration staging and repeatable release.
17. **Test Engineer / Independent QA Auditor** — run unit, widget, integration, device, performance, accessibility, backup/restore and update-regression tests; explicitly try to break the app.
18. **Android Release & Distribution Engineer** — configure build flavors, signing instructions, release artifacts, reproducible builds, application icon, versioning, screenshots and installation/update guide.

Do not create an army of agents who only write plans. Every role must produce source code, edited copy, structured data, visuals, tests, reports, or concrete approved assets. Expand agents or combine roles only if there is a clear practical reason; preserve their handoff contracts in documentation.

### Required handoff artifacts

- Ingestion -> `planning/intake/EDITION_<version>.md`, `content/imports/<version>/`, and an exact-ID reconciliation CSV.
- Research -> `research/` claims/source ledger or a documented pointer to the verified book team's existing ledger; **reuse**, don't blindly redo legitimate research.
- Content adaptation -> `content/canonical/`, `content/adapted/`, `content/metadata/`; side-by-side fidelity diff and UI-specific copy list.
- Interaction -> `content/interactions/NNN.json` or structured equivalent, playable instructions, fixtures and mechanic tests.
- Art -> `assets/source/`, Flutter asset directories, `assets/ASSET_MANIFEST.csv`, responsive size variants, meaningful alt-text map.
- Journal -> data schema, example **fictional** records, widgets, memoir layouts, export templates and privacy review.
- Engineering -> implementation plus tests and design decision records in `docs/adr/`.
- QA -> `review/QA_REPORT.md` with evidence, unresolved defects, rebuild logs, and go/no-go verdict.

**Concurrency:** Research and art exploration can run alongside app shell work. Different part batches can be adapted in parallel after their full source has been validated. Database schema and stable IDs must be approved before scattered feature implementations begin. Restrict schema modifications to one integration owner.

---

# 3. BOOK PARITY, IDENTITY, AND ALL 13 PARTS

Retain all 108 original IDs/titles, part assignments and conceptual substance even if the finished book improves chapter names or adds cross-references. A canonical chapter record must preserve both `stable_id` and current display title; an old title becomes a searchable alias after a rename.

- Part 01 — The Art of Really Knowing Someone: `001–008`.
- Part 02 — Vulnerability and the Courage to Be Seen: `009–016`.
- Part 03 — The Science and Experience of Closeness: `017–024`.
- Part 04 — Love, Affection, and Feeling Chosen: `025–032`.
- Part 05 — Desire, Attraction, and Sensual Intimacy: `033–040`.
- Part 06 — Playfulness, Laughter, and a Little Mischief: `041–048`.
- Part 07 — The Inner World: Dreams, Meaning, and Identity: `049–056`.
- Part 08 — Trust, Communication, and Emotional Safety: `057–064`.
- Part 09 — Shared Adventures and New Experiences: `065–072`.
- Part 10 — The Past, the Present, and the Story of Us: `073–080`.
- Part 11 — Radical Curiosity and the Surprising Stuff: `081–088`.
- Part 12 — Building a Closer Future Together: `089–096`.
- Part 13 — The Inventor's Workshop: Original Proposals: `097–108`.
- Additional completed signature experiences `S01–S06` or their published IDs; distinguish these from 001–108 and do not displace original numbering.

**The catalog JSON in the package is the baseline machine-verifiable inventory.** Match it item by item. The first complete book release is the source of all longform content and its artwork. All substantive front matter, explanations of evidence/provenance, note-taking guides, repeatable rituals, worksheets, game cards, author/editor notes appropriate for readers, selected references, and thematic part openers belong in the digital edition too. The full-text chapter must never disappear behind an abbreviated activity wizard.

For each ID, the app record must include or link to, when supplied by book: title, stable ID, part, subtitle, introduction, purpose/outcomes, research/context notes, setup/materials, detailed steps, rounds/cards/prompts, short/long variants, optional intensity paths, safety/consent instructions, example walkthroughs, aftermath/debrief, specific journaling prompts, related entries, author/source attributions, asset refs/alt text, and metadata for all indexes. Mark anything truly not present as source gap; do not silently invent a “book chapter” and pass it off as canonical.

### Fidelity rules

- **READ** = complete readable content, with embedded artwork, rich formatting, in-chapter navigation and sensible offline typography.
- **DO** = guided interactive adaptation of the same material; allow pausing/resuming, skipping optional parts and saving session steps.
- **REMEMBER** = documented experience, real individual/shared responses, dated revisit comparison and keepsake exports.
- Activities not requiring a digital interaction still get a valuable mobile companion: preparation checklist, unobtrusive step navigator, prompts/debrief and journal. Never force unnatural timers/scoring onto every chapter.
- Avoid requiring participants to stare at phones during presence, movement, affection, eye-contact or sensual activities. Offer **screen-off / put-phone-down cues** and gentle nonintrusive ways to resume.
- Mark app-only editorial prompts as `app_extension` and retain original source; do not quietly imply those prompts were published in the book.
- All rights/permission for external content need checking; the book's original text and art are primary.

---

# 4. PRODUCT EXPERIENCE AND REQUIRED SCREENS

Design and implement a complete, polished Android journey. Sensible baseline navigation (adapt if research shows better): **Today / Discover / Our Story / Library / Settings**, with persistent access to search and a session resume action. Never hide basic reading behind a gamified flow.

**Onboarding:** Welcome to the philosophy (celebrating connection, not fixing a relationship); create two optional local participant labels or nicknames; show privacy/consent basics; choose personal preferences and optional app lock; explain independent and shared journals; guided tour or skip. Avoid forced account creation. Allow single-participant reading and setup before both people are present.

**Home / Tonight:** Choose time in six buckets, a mood/desired outcome, energy level, emotional depth, format and optional practical constraints; surface eligible actual activities; remember filters locally. Include “Something Quick,” “We Have All Evening,” “We Tried This Before,” “Pick Up Where We Left Off,” and “Surprise Us!” Cards should clearly state actual time, participation requirements, intensity and materials.

**Discover / Filters:** Faceted filtering (AND across chosen constraints), theme browsing, text search over full chapters and aliases, A–Z, tags, favorites, new/untried, previously visited, related discoveries, and book-index shortcuts. Empty states suggest changing a constraint rather than secretly ignoring it. All 108 + signatures must be discoverable.

**Part / Collection screen:** Every part intro, related opener artwork, entry list, light/deep suggestions, and a concise link to the book's corresponding longform part introduction.

**Experience detail:** Hero mark/art, title+ID, truthful metadata, complete purpose, preparatory reading, estimated time variants, required materials, full chapter CTA, start guided session, journal history, bookmarks, and related experiences. Have a clear “how personal is this?” and “optional physical contact?” indicator where relevant.

**Full Chapter Reader:** Beautiful scroll reading, adjustable font size and line spacing, light/dark/sepia, accessible headings, illustrations, linked references where available, progress position, text selection where feasible, offline availability, jump to steps or worksheets, back to the session without losing place.

**Guided Session:** Clear setup, steps, prompts, turn-taking/Partner A/B role cues, timers only as the book requires, unobtrusive resume, pause/pass/skip/stop, materials/worksheets, branch choices, optional variants, debrief, and voluntary journaling. Structured questions should allow marking “talked about”, entering a response, or leaving blank. Respect that many activities happen offscreen.

**Interactive Game Mode:** For applicable entries, actually implement rules: random question decks without awkward repeats, turn order, scores/point budgets where specified, dice/coin/chance with reproducible seed where helpful, card reveals, progress through rounds, save/resume, end-of-game reveal and shared summary. Do not swap a sophisticated published game for a generic question spinner.

**Journal / Personal Memoir:** Per-activity journal, profiles and shared notes, rich/freeform editor, prompted answers, date/time, tags, mood (optional), attached images via user selection, memories timeline, search, private/shared privacy semantics, first-time vs revisits, comparison view, “letters to future us,” favorite moments and selected keepsakes.

**Our Story Dashboard:** Chronological life-and-activity timeline, activity-linked memories, milestone collection, partner perspectives, recurring discoveries, optional monthly/yearly retrospectives based **only on actual journal entries**, and meaningful export into readable keepsake editions. Do not manufacture emotional insights as facts.

**Library & Resources:** Completed six signature sessions, appendix materials, read-only game cards, printable/shareable worksheets where allowed, research notes and attribution, user guide, glossary, and help. If online source links are provided, allow them to open on demand; core app does not depend on them.

**Settings and Data Control:** Theme, text sizing, reduce motion, sounds/haptics, reminders opt-in, personal/partner privacy, app lock, export backup, import backup, preview of user data to be exported, delete options with confirmations, version/provenance information, content-update import/check status, and precise storage explanation.

### Gentle features to include when useful, not as gimmicks

- Favorite experiences, notes bookmarks, session continuation, “repeat that one,” streak-free completion history, optional no-pressure reminders, warm post-session debrief, quiet nighttime mode, optional offline text-to-speech/read-aloud using system support, haptic timer ends and accessibility announcements.
- Partner A/B perspective switch with obvious current role; do not misattribute a private note to the other partner.
- Optional physical workbook companion: an easy way to view/print materials, track which printed pages correspond to which digital chapter, and capture photos of handwritten pages by explicit user choice.
- Home screen quick entry can be useful, but should never expose intimate note contents in Android notifications, lock-screen previews or widgets by default.

---

# 5. SIX QUICK-REFERENCE / DISCOVERY SYSTEMS — COMPLETE

## A. Time available — REQUIRED AS FIRST-CLASS CONTROL

1. **5–10 min** — Quick Connections.
2. **10–20 min** — Little Discoveries.
3. **20–45 min** — Meaningful Sessions.
4. **45–90 min** — Deep Dives.
5. **90 min–3 hours** — Full Experiences.
6. **Multi-day / ongoing** — The Long Game.

An entry can offer 10-minute, 30-minute, full-length and revisit modes only if these have actual authored instructions. Filtering should consider supported modes and prep requirements. Don't categorize a 90-minute game as “10 minutes” just because someone can read the introduction in that time. Multi-day should appear distinctly and support saving progress.

## B. Desired emotional outcome

Laugh / play; discover a secret or new perspective; learn personal history; deepen vulnerability; build trust; feel loved/appreciated; reconnect; romance; sensuality; contemplate philosophy; create something together; adventure / novelty; support each other; develop a future vision. Allow sensible multi-select and aliases.

## C. Energy / effort

Low-energy/restful; medium/interactive; high-energy/active/outdoors. These are independent of duration and emotional depth.

## D. Emotional depth

Light & playful; personal & revealing; deep & vulnerable; very emotionally intense. Allow explicit exclusions. Distinguish emotional intensity from physical affection or sexual topics.

## E. Activity format

Conversation; Q&A; cooperative game; competitive light game; creative writing; reflection; improv/roleplay; artistic/physical project; mindfulness/presence; affectionate touch; sensual/sensory date; outdoor/adventure; recurring ritual; multi-day challenge. Include materials, location and optional partner-presence facets.

## F. Surprise Us! — ACTUAL FILTERED RANDOMIZER

Partners choose a permitted time, energy, depth, mood, practical situation and content boundaries **before** random selection. The chooser samples **only eligible entries and eligible duration modes**, never disregards filters to fill a result. Include reroll, no recent repeats option, deterministic tests with a fixed random seed, a respectful decline/pass, and a link straight to session preparation. No invented chapter IDs, no “coming soon” results. If no eligible activities, show why and suggest a user-controlled way to loosen criteria.

**Other indexes**: theme/part; stable ID; alphabetical; favorites; untried; started/unfinished; completed; revisits by date; recent memories; short couch sessions; entire-evening options; matches to actual available materials; book-page cross-reference when page data exists. Support offline fast search with indexed data, not scanning giant text files on every keystroke.

---

# 6. MAKE ACTIVITIES DIGITAL WHILE KEEPING THEIR HUMAN POINT

Each experience has a declarative `interaction_definition` that can be rendered through tested reusable primitives: `prepare`, `read`, `question`, `answer_private`, `answer_shared`, `storytelling`, `reflection`, `free_write`, `timer`, `silent_presence`, `card_draw`, `random_choice`, `two_partner_choice`, `turns`, `score_budget`, `challenge`, `checklist`, `real_world_task`, `attachment`, `reveal`, `debrief`, `pause`, `end`. Extend deliberately for special mechanics rather than hardcoding one-off spaghetti screens.

Examples Cursor MUST implement as representative acceptance scenarios, then generalize across the catalog:

- **017 Four Minutes of Forever:** optional gentle four-minute timer; clear eyes-off-phone instructions; nonverbal alternative, pause/stop, afterward questions, journaling without requiring a camera pointed at faces.
- **020 The Listening Experiment:** speaking/listening turn cues, adjustable session lengths, reflective questions, avoid interrupting either person with noisy alerts.
- **034 The Yes, No, Maybe Game:** private per-partner answers, explicit mutual opt-in to reveal, category controls, show areas of overlap and respectful boundaries; don't assume a “maybe” is consent.
- **043 The Newlywed Game, Without the Wedding:** independently answered personal predictions, separate reveal, thoughtful scoring if the finished book uses it, variation decks, debrief.
- **047 Truth, Dare, or Discover:** actual multi-mode cards, agreed intensity, skip/re-roll, prompt depletion avoiding immediate repeats and a clear ending.
- **068 The Night of Random Decisions:** fair coin/dice/random mechanism applied to the book's actual table, ability to reject unsuitable choices, memorable decision log.
- **097 The Emotional Archaeologists:** interviewer/interviewee roles, layered voluntary questions, occasional hypothesis check, no app-diagnosed psychological conclusions, private reflection.
- **101 The Borrowed Brain Experiment:** both participants answer before comparison, reveal separated reasoning from selection, optional friendly score, no pressured disclosure.
- **102 The Museum of Unsaid Things:** create named exhibits, “what happened / what I wish you'd understood” fields, choose what is private vs shared, browse a personal gallery of consented exhibits.
- **103 The Relationship Escape Room:** actual clue sequences, answer-checking/hints where relevant, shared progress and clear paper/offscreen adaptations; **not** a scavenger hunt and not a repurposing of any unrelated project.
- **106 The Intimacy Negotiators:** allocate 100 points via accessible controls, private choices then agreed reveal, side-by-side comparisons, jointly draft an evening, no scoring of “compatibility.”
- **108 The Secret Door:** choose optional doors/topics, reveal prompts progressively, clearly reversible/passable boundaries; journal entries linked to selected doors.
- **S01–S06:** full-length guided sequences, save/resume over a long evening, access to required cards/worksheets, non-obtrusive timers, finished book parity.

For all 108: an assigned agent reviews chapter-specific mechanics and certifies an actual usable digital path, not just generic “start, read, finish.” Some sessions will be mostly offline physical activities: in those cases the guided phone view should simplify preparation, gracefully get out of the way, and support after-session reflection. Interactivity is a means, not the point of an intimate human experience.

---

# 7. THE LIVING MEMOIR: MAKE THIS A FIRST-CLASS PRODUCT

This is as important as the activities themselves. The app should become a credible, delightful archive of a relationship over months and years, and every update must protect that archive absolutely.

## Journaling at multiple levels

**Each activity session stores:** `session_uuid`, `experience_stable_id`, `content_edition_used`, selected variant, start/completion date and timezone, optional place label, both participants' optional attendance, session state (`planned/in_progress/completed/paused/skipped`), prompts encountered, any actual consented answers, and attached media references. No inferred real memories.

**Three intentional response spaces for each session:**

1. **My Notes (Partner A)**: private journal, selected answers, how I felt, what surprised me, what I learned, what I want to remember.
2. **My Notes (Partner B)**: same, separately owned. Never allow accidental disclosure through switching or automatic side-by-side presentation.
3. **Our Notes**: explicit shared reflections, favorite moments, quotes typed by participants, agreements, ideas for next time, mini scrapbook and meaningful keepsake captions.

If people share one phone, explain that profile switching **without a separate lock is organization, not strong confidentiality**. Offer genuinely separate credentials/lock scopes where feasible; app-level lock and device encryption should be appropriately used but cannot promise stronger privacy than actually engineered. If a PIN is lost, be truthful about recovery limitations. A partner can intentionally make an entry shared; the app must not quietly do it for them.

**Per-chapter prompted journaling:** import every exercise's actual journal prompts from the book, plus optional open-ended fields: Before, During, After, Something I didn't expect, What I learned about you, What I learned about myself, Something we want to try again. Prompts remain optional and can be skipped; all 108 map to at least one chapter-specific journal question where the book supplies it.

**Unlimited revisit architecture:** a revisit is a new session record, **not an overwrite of a prior one**. Show earlier answers alongside later answers on explicit request; retain timestamps, edition version and optional changes in outlook. Support revised notes as revisions with timestamped history or transparent edits, not mysterious disappearing words.

**Keepsake system:** timeline, private/shared searching, meaningful milestone grouping, photos/selected images, selected excerpts, yearly “Chapters of Us” export, themed compilation by part/activity, and a printable PDF / shareable Markdown/HTML/possibly DOCX export generated from **actually stored entries**. When no entries exist, display pleasant empty spaces rather than fiction.

**Writing experience:** autosave robustly (including on app background/crash), drafts vs submitted/shared distinction, spellcheck/platform text features, rich text only if it can be roundtripped safely, long notes without lag, accessibility labels for each field, predictable keyboard behavior, optional simple voice dictation via Android input method (no cloud transcriptions unless the user separately opts into that Android method).

**Media and artifacts:** Android photo picker/document picker, scoped URI grants, thumbnails, safe copied/private storage for attachments as appropriate, export/import of referenced attachments with checksums, duplicate detection, missing-file placeholders that preserve journal text. Avoid requesting broad storage permissions. No camera/microphone permission unless a defined optional feature truly needs it.

**Backup + restore:** one-tap manual encrypted export for personal data (and optionally book content pack info), explicit human-readable export, password/passphrase guidance, checkums/integrity, restore preview and **merge vs replace** warning, staged test restore on sample data, duplicate reconciliation, and no silent overwrite. Provide a controlled device-migration path. Ask before enabling Android auto-backup of sensitive journals; document and test backup policy. Support entirely offline backup via user-selected files.

**Privacy baseline:** no accounts, trackers, analytics, ad SDKs, external TTS upload or surprise cloud services; no intimate content in crash logs or push notifications; avoid plaintext journal records in screenshots or debug traces; encrypt local sensitive data at rest where feasible with vetted implementations and Android Keystore for key handling; lockscreen snapshot protection for private screens where practical; prevent unsecured export leakage; exclude backups/export files from Git and release bundles. An optional screen-lock is a real lock only after testing bypass and recovery behavior.

---

# 8. THE VISUAL WORLD: APP ART, NOT JUST BOOK PAGES ON A SCREEN

Inherit the book's chosen final art direction and treat it as a real design system. Baseline direction if the completed book hasn't fixed another: midnight blue or charcoal, warm ivory/parchment, muted copper/terracotta/gold, restrained dusky teal or burgundy; sophisticated editorial typography, intimate textured artwork, constellation/path/key/door motifs, grown-up warmth with a mischievous streak. Never use bad readability or neon-on-black merely because “dark mode.”

**Build a genuine visual system:** type scale, adaptive layout, color tokens, dark/bright/sepia reading themes, borders, whitespace, buttons, interaction focus states, cards, imagery containers, gradients/textures (subtle), progress language, accessible contrast, animation tempo, and app icon/splash. Surface the emotional distinctness of the 13 themes.

**Reuse/produce and integrate all needed visual assets:**

- App icon, polished splash, welcome/onboarding illustration, home artwork, discovery/empty-state designs, journal timeline/keepsake visual system.
- All 13 part opening illustrations in responsive/cropped forms.
- All 108 chapter-specific art marks/illustrations, preserving their identity from the completed book, with mobile-optimized resolution and asset licenses.
- All six signature-session hero pieces; any added official signatures likewise.
- Activity-specific illustrations, diagrams, choice cards, game cards, visual timers, doors/exhibits, point-allocation graphics, thematic backgrounds, journal stationery motifs, and printer-friendly export art.
- Optional minimal animation for transitions/reveals, with **Reduce Motion** and low-power alternatives; texture use should not degrade rendering or contrast.

Art agents may create **additional original mobile-specific art**, but must not silently replace finished-book cover/illustrations with unrelated art. Track asset lineage: book file/version, source image reference, approved derivative, size, format, crop choices, alt text, licensing. Use Flutter-supported formats with memory/performance budget (e.g. optimized raster, SVG only via verified supported renderer). No fake image “placeholders” in release. Avoid embedding all full-resolution print assets into a multi-gigabyte APK; downsample with preserved originals in source assets.

**Accessibility:** talkback semantics, high contrast, large fonts, left/right-handed ergonomic touch targets, usable landscape where sensible, tablet layouts, one-handed browsing, meaningful illustrations described or marked decorative, color-independent labels, reduced motion, no mandatory auditory instruction. Provide alternative interaction paths for gaze, touch, blindfolds, breathing, movement and other potentially inaccessible activities. The **book wording remains available**, while the app offers considerate adaptations.

---

# 9. TECHNICAL FOUNDATION — FLUTTER/DART AND ANDROID

Preferred stack: **Flutter + Dart**, targeting Android, organized so future iOS or desktop could be explored without rewriting the content model. Use the currently supported **Flutter stable** channel and compatible Android Gradle/SDK/JDK versions verified in this workspace at implementation time; pin reproducible dependencies/lockfile and log exact build environment. Do not assert a specific SDK/plugin release is current without checking it.

Recommended architectural boundaries:

- `app/` routing, app lifecycle, themes, DI/state wiring.
- `features/discover/`, `features/reader/`, `features/session/`, `features/games/`, `features/journal/`, `features/our_story/`, `features/settings/`, `features/import/`.
- `domain/` stable models/use cases independent of widgets.
- `data/content/` immutable versioned book data and image manifests; content repository.
- `data/private/` journal and profile repositories, encryption/backup adapters, session persistence.
- `tools/book_ingest/` reproducible Python/Dart import/validation/diff pipeline.
- `test/`, `integration_test/`, `test_fixtures/`, `docs/`, `review/`, `assets/`.

**Content and journal storage MUST be separate** even if both use SQLite-based technology: avoid one mega-JSON asset that contains personal notes; keep stable IDs linking databases. Choose SQLite/Drift or another vetted structured local store with robust migration support; document tradeoffs and tests. For encryption, use audited and compatible tools/Android Keystore integration; don't devise custom cryptography. Content remains accessible offline from packaged/installed assets. The latest content pack can be activated atomically after verification.

**State and architecture:** predictable state management (e.g. Riverpod/BLoC if appropriate), repository-level version boundaries, dependency injection, stable screen state, debounced search, lazy content loading, no long UI-thread parsing, resumable activities across background/process death and rotation. Widget trees and session mechanics should be testable without running the whole app.

**Android integration:** use Android's document access/picker framework for choosing new books and private backups; request only necessary permissions. Follow applicable platform storage and data-access expectations. App private data remains in app-private storage. Use an explicit content import staging area, not unrestricted background file-system scanning. Opt-in notifications only. Support physical back and Android navigation conventions.

**Offline definition:** All content, images, saved journals, games, random selection, timers, filtering and export of supported formats work without network. Only explicitly optional external links or future distribution features may require connectivity. Test in airplane mode from fresh installation through completed and revisited sessions.

**Security/quality:** sanitize imported rich text; reject scripts/malicious archive paths and zip bombs; validate file sizes, image formats, checksums and asset references; do not execute arbitrary downloaded book content. For an installed app, don't load arbitrary untrusted code from content packs—only validated data/resources against schema. Strip sensitive values from telemetry/logs. Ship with zero analytics SDKs unless owner asks for them later.

**Compatibility & performance:** choose a practical minimum Android version and record reason. Test on a real Android phone when available and at least one emulator/automated configuration; smooth low-memory performance and offline resilience matter more than unnecessary 3D animations. Measure cold start, large journal searches, asset decoding, restoring large backups, and battery impact for multi-hour sessions.

---

# 10. THE CRITICAL FEATURE: DROP-IN BOOK-TO-APP UPDATES

This is a **core product and developer-workflow feature**, not something to defer as a future enhancement. The owner wants to hand the app project a new completed book edition and have the agents turn all relevant changes into an updated app with minimal involvement. The solution has two layers:

**Layer A — Repeatable Cursor publishing workflow (mandatory):** Drop the revised book file/package into this project, invoke a single Cursor instruction (e.g. “Sync the latest approved book into the Android app”), and the agents inspect, compare, adapt, update assets, edit mechanics when necessary, test, generate new artifacts, and report the release. The importer should automatically do routine text/metadata/assets changes; the agents handle semantic/interactive/visual changes. No painful one-chapter-at-a-time copy/paste.

**Layer B — Optional in-app content-pack import (recommended where safe):** For **data/schema-compatible** updates, allow a user-approved signed or otherwise authenticated content bundle to be imported via Android's system file picker, validating release manifest, content schema, file integrity and stable IDs before activation. This can update **book text and compatible assets without rebuilding the APK**. Changes to app logic, complex mechanics, database schema or native code still require a compiled app update. Don't pretend a new DOCX dropped onto an Android phone can safely implement new code without a build.

## Standard drop path and intake protocol

Create:

```
book_inbox/
  2026-10-first-complete-edition/
    The_Closer_Project.docx
    The_Closer_Project.epub       # optional
    The_Closer_Project.pdf        # optional
    book_content_export.zip       # strongly preferred if book team generated it
    manifest.json                 # optional if importer can derive it
  future-revision-v1.1/
    ...
```

The actual names are flexible. Detect newest unprocessed release in `book_inbox/`; **don't equate filesystem timestamp with editorial approval**. Require a predictable approved-version marker/confirmation in release manifest or explicit owner's instruction. Use a versioned read-only snapshot under `book_sources/approved/<edition>/`; never overwrite prior book snapshots.

## Import algorithm: DO THIS ON EVERY NEW BOOK

1. **Inventory input:** list files, hashes, sizes, detected formats, edition, candidate chapters/parts/signatures, licensed artwork and appendix resources. Validate archives against path traversal/oversize files.
2. **Extract canonical content:** prefer structural JSON/Markdown; otherwise parse DOCX (paragraph hierarchy, actual tables, embedded artwork, images, hyperlinks), EPUB XHTML and art, or PDF text/images as a fallback. Preserve exact text passages and illustration mappings. Normalize Unicode cautiously, preserving punctuation and paragraph boundaries.
3. **Stable identity matching:** match 001–108 plus official signature IDs, and identify truly new IDs; match by ID first, then title aliases/part with confidence when old books differ. A rename never causes prior journal associations to be lost. Do not use fragile title text as database primary key.
4. **Compare old -> new:** produce an explicit semantic difference report: added/removed/renamed/merged/split activities, moved parts, changed paragraphs, step counts, instructions, prompts, duration variants, tags, illustrations, assets, printable materials, signature sessions, attributions, research claims and author notes.
5. **Classify change impact:**
   - Text/typography/copy-only -> regenerate content pack + regression.
   - Metadata/time/filter changes -> rebuild indexes + check eligibility logic.
   - New image/graphic -> asset processing, app visual inspection and accessibility text.
   - New steps/rounds/prompts -> regenerate interaction definition and test the activity.
   - New or changed game mechanics -> assign interactive design + Flutter/game engineer.
   - New journal prompt -> add prompt definition without modifying past answers.
   - Removed/merged content -> archive legacy identity; never cascade-delete linked sessions.
   - Security/schema/native change -> require code migration/full APK update.
6. **Produce human-readable impact report:** what changed, what stayed unchanged, what will happen to journals, any low-confidence extraction, and whether it requires a new APK or only content import. Request owner input **only** for genuine ambiguous/destructive interpretation; otherwise use sensible defaults.
7. **Agent update execution:** dispatch impacted chapter ranges/assets/components to specialists. Reuse validated unaffected content and screens. No rewriting all 108 on every tiny edit.
8. **Staged content update:** build new immutable content snapshot; preflight against schemas, counts, referential integrity, artwork, prompt IDs, in-progress sessions, and metadata. Check sample screen renders.
9. **Personal data migration:** back up test data, run additive, idempotent migrations in a transaction, preserve all journal rows and attachments, map all old stable IDs, implement archival compatibility for legacy removed chapters. NEVER reset the private database as a migration shortcut.
10. **Test with realistic fixtures:** see test matrix below. No app update is released until existing intimate notes survive across upgrade/rollback paths.
11. **Package release:** assign semantic version, record source-book version/hash, build updated APK/AAB when necessary; optionally produce validated signed content pack; generate changelog and verification report.
12. **Roll back safely:** preserve last known-good content pack and original private DB; if import/migration fails, restore the previous active content and show a clear recoverable error. Personal note data is never rolled back silently from an older snapshot over newer writing.

## One-action developer workflow

Implement `tools/book_ingest/sync_latest_book.(py|dart)` with documented CLI args such as `--inbox book_inbox --dry-run`, `--apply`, `--report`, and `--edition` (exact flags can differ if documented). Provide `tools/update_from_book.sh` and Windows-friendly `tools/update_from_book.ps1` **or** equivalents, because the owner may develop on Windows. Also define `docs/BOOK_UPDATE_PLAYBOOK.md` and a simple Cursor launch prompt in this package. CI may validate automatically on approved package commits; **creative/semantic agent work needs actual Cursor execution**, not a falsely promised background watcher. Make the workflow simple enough that the owner can drop the new book into `book_inbox/` and send one instruction.

### Required update examples / regression fixtures

- v1 book chapter 027 paragraph edited; import text update, original journal unchanged.
- Chapter 017 time metadata changed; time filter reflects new value.
- Chapter 034 adds new prompt; earlier private Yes/No/Maybe answers remain and new prompt starts unanswered.
- Chapter 043 changed game scoring; the new rules apply to new sessions, older completed sessions remain interpretable with their original rule version.
- Chapter 102 new art and journaling fields; old museum exhibits remain readable and attached to the right person.
- Chapter 106 point budget changes in future official edition; existing allocation history still displays using the rules in effect when recorded.
- A chapter title changes; bookmarks, favorites, entries and past results still link by stable ID.
- A chapter is deprecated or moved; its old journal entries and media remain accessible in the archive and timeline.
- New chapter 109 appears in a future edition; generated app and filters incorporate it without modifying old ID range.
- New edition import fails mid-way or archive is malformed; original app content and all notes remain intact.
- User updates APK and then restores from an earlier private backup: display preview and resolve conflicts explicitly.
- Incompatible content pack is selected on-phone: reject non-destructively, explain need for updated app binary.

**Content migration policy:** book editorial revisions must not reinterpret or change the original meaning of a recorded response. Each journal answer refers to a **stable prompt ID plus the prompt revision present at the time**; render old prompts contextually in historical session views when needed.

---

# 11. CONTENT SCHEMA AND VERSION CONTRACT

Define and validate a documented schema before mass production. A recommended minimum set:

- `BookEdition`: source_book_id, edition_id, version, publication_date, source_hashes, imported_at, provenance, locale, approval state, app compatibility version, signature/checksum.
- `Part`: stable_id, ordinal, name, intro, imagery, ordered experience IDs, metadata.
- `Experience`: stable_id, content_revision, part_id, title, subtitle, aliases, provenance, complete structured prose blocks, preparation/materials, steps, variants, debrief, prompt IDs, references, media, metadata, interaction_definition version.
- `Prompt`: stable_id scoped to experience, revision, exact text, intended response privacy, options, attribution and optionality.
- `Asset`: canonical asset ID, source edition, kind, source file/license, alt text, responsive variants, checksum.
- `SignatureExperience`: separate stable ID and the same content/interaction capabilities.
- `LocalPartnerProfile`: random local ID, chosen display label, lock settings, privacy flags (never shipped in content packs).
- `Session`: UUID, experience ID, content revision used, variant, recorded timestamps, current step, participants, real notes linkage.
- `JournalEntry`: UUID, session UUID, partner owner or explicit shared scope, prompt ID+revision if applicable, rich/plain text and edit history, timestamps, attachment IDs, visibility status.
- `MemoryItem`: optional user-created independent event/quote/photo with provenance of who added it and sharing state.
- `Attachment`: UUID, owned local path/provider URI, type, private/shared scope, checksum, original label, export map, missing-file state.
- `BackupManifest`: schema version, backups/attachments/checksums, generated_at, envelope/encryption format.

The exact normalized models may differ, but all semantics above must be preserved. Include schema migrations for both content and private data; cover immutable book snapshots and data lineage. Store app extension copy separate from verbatim source prose. Include one machine-readable **content parity test** that walks every source chapter and asserts expected app fields and artwork exist.

---

# 12. EDITORIAL & RESEARCH RESPONSIBILITY FOR THE APP

Do not erase the book's research or nuanced emotional introductions for mobile brevity. Import and show the full book content with references. For convenience, agents may create **clearly app-authored** short teaser text, setup card snippets, short/long instructions and in-app onboarding microcopy.

The research verifier must check any new scientific or psychological claim added to the app and reuse the book's verified evidence ledger. Distinguish study findings, popular exercises, professional practice, and original designs. No promise that eye contact makes people fall in love, no bogus therapy authority, no dating metrics pretending to measure love. Remember some users can find gaze, touch, revealing secrets, or intimate subjects uncomfortable; offer skip/mute/alternate, preserve voluntariness and a dignified ending.

The writing and editorial team should make each activity delightful and comprehensible **as a mobile session**, not paste the print table of contents and call that an interactive design. Preserve **all** original longform text in the reader. Original 097–108 must retain their intentional distinguishing twists. Any new content needs provenance fields and author review.

---

# 13. QUALITY, QA, AND REAL DEVICE TESTS

### Inventory and content parity

- Every original 001–108 appears once with valid part mapping, exact or approved title, full chapter text, relevant intro, setup, complete steps, variants, debrief, journal integration and real artwork.
- 13 illustrated themed parts, 6 completed signature sessions and all available references/appendices/worksheets/card resources present. Test asset completeness mechanically; no images missing in release APK.
- Detect placeholders, lorem ipsum, shortened synopsis substitutes, stale “TODO/TBD” in reader surfaces. Longform vs source comparison must include paragraph counts/text hashes (normalize only safe whitespace) and manual sampling for rich formatting.
- All indexes populated and filtering honest. The randomizer may return only eligible IDs/modes and handles empty sets.

### Journaling and privacy

- Two partners, separate entry ownership, intentional sharing; long notes, drafts, unsaved app background, crash/process kill, phone rotation, app update and airplane mode.
- Unlimited revisits, two simultaneous sessions for same chapter, dated answer comparison, prompt revision preservation.
- Encrypted backup/restore, attachment round-trip, wrong password, corrupt backup, conflict merge, duplicate entry, insufficient storage, no inadvertent plaintext/analytics exposure.
- Historical records survive the ten book-update scenarios in Section 10. Validate counts/hashes **before and after** update for sample databases with thousands of entries and media.

### Usability and accessibility

- Real Android phone test (install actual APK) and emulator matrix. Small displays, large text scaling, screen reader/TalkBack, high-contrast, reduced-motion, device dark/light, long titles, landscape/tablet consideration, offline-only journey.
- Smooth animation and scrolling, no overflow/obscured submit controls with keyboard open, large touch targets, correct hardware/software back behavior, haptic cues not necessary to complete anything.
- User can find a 5–10 minute activity in a few taps; can begin/revisit an experience without account creation; can stop a vulnerable exercise instantly without data loss.
- Direct hands-off/walk-away mode for eye gazing, touch and real-world experiences.

### Engineering and reliability

- `flutter analyze` / formatting / dependency lock check; unit tests for schemas, filters, randomizer, game rules, backups, migrations; widget tests for core navigation; integration tests for core flow and book update.
- Automated tests for identical import idempotence, repeated book update and rollback, corrupt import, unknown chapter, removed chapter with existing notes, changed prompts, incompatible package.
- Test release APK install, launch, full offline content availability, complete one activity and save notes, kill/restart and recover, export/restore, upgrade APK to next version preserving notes.
- No secrets committed, no personal notes included in source control, logs, screenshots or the distributed app. No hard-coded pretend analytics or external endpoints.

### Editorial QA

- Independent human-readable walkthroughs of at least one entry in each part, all signature sessions, all unusual mechanics and challenging partner privacy scenarios. Agents must verify meaning and tone, not only lint.
- Accessibility audit and device screenshots demonstrate images and form layouts are genuinely integrated.
- `review/FINAL_ANDROID_QA_REPORT.md` includes test results, artifacts/build hashes, device versions, version of the source book, known limitations, bug status, and honest go/no-go.

---

# 14. VERSIONING, GIT, DISTRIBUTION AND PRIVATE DATA HYGIENE

Use a separate repository/working tree for the app while maintaining a read-only dependency pointer to the canonical book release. Store **public sample fixtures only** in Git. `.gitignore` must exclude `journal/private/`, `backups/private/`, temporary import files containing real notes, debug dumps, secret keys, keystores, and app signing secrets. Do not make the actual private journal part of a GitHub repository or publish it in release assets.

Maintain `APP_VERSION`, `BOOK_SOURCE_VERSION`, `CONTENT_SCHEMA_VERSION`, `JOURNAL_SCHEMA_VERSION`. Bump app version for executable/schema/UI changes; content version for imported book revisions; document which content pack is supported by which app binary.

Produce when book content and build environment permit:

- `release/android/TheCloserProject-vX.Y.Z-debug.apk` installable for testing.
- `release/android/TheCloserProject-vX.Y.Z-release.apk` signed using owner-controlled secure credentials when provided; if not, a **test-only signed release** clearly identified and secure instructions for production signing.
- `.aab` for possible distribution when owner elects that route and signing requirements are fulfilled.
- Complete Flutter/Dart source and required build dependencies/lockfiles.
- Sanitized example backup and example authored fictional journal entries for demonstration only.
- Optional app-importable content pack with validation/authenticity metadata.
- Screenshots of functional reader, chapter, game, timeline, private/shared journal and update wizard.
- `docs/INSTALL_AND_UPDATE_ANDROID.md`, `docs/BOOK_UPDATE_PLAYBOOK.md`, `docs/PRIVACY_AND_BACKUPS.md`, `docs/USER_GUIDE.md`, `docs/ARCHITECTURE.md`.
- `review/FINAL_ANDROID_QA_REPORT.md` and reproducible local build commands.

Don't promise automatic Google Play publication, push updates, or automatic cloud synchronization. Build the actual owner-controlled release process and note what needs account access.

---

# 15. EXECUTION ROADMAP — DO THE WORK, NOT A DEMO

**Phase 0 — Intake and dependency lock.** Audit the baseline source package, identify the book finish gate, establish project source structure/ID scheme, original catalog tests, research references and release readiness checklist. If approved full book is absent, mark this phase blocked for final content but continue tooling/design foundation.

**Phase 1 — Agents and product contracts.** Inspect agent definitions; establish design standards, stable data schemas, UX wireflows, content/source contracts, owner-facing update invocation, privacy baseline and acceptance tests. Commit checkpoint.

**Phase 2 — Book importer and change engine FIRST.** Build parsers/validators for canonical Markdown/JSON + DOCX/EPUB, tested PDF fallback, source checksums, stable ID matching, structural diff, metadata generation, asset pipeline and dry-run change reporting. Include v1->v1.1 fixtures now. This ensures book updates aren't an afterthought.

**Phase 3 — Design system and representative complete journeys.** Implement real polished full-reader and guided-session examples using the baseline only as a temporary fixture, plus journal and one playable game. Test rendering, TalkBack, offline persistence and artwork. Clearly identify fixture/demo status until authoritative book is ingested.

**Phase 4 — Import the first FULL approved book.** Verify completeness and ownership; ingest every chapter, theme, signature session and referenced asset; generate all models/tags/indexes. Research/editorial agents audit source-to-app fidelity. Reject fake “done” if text is incomplete.

**Phase 5 — Adapt every experience.** In batch lanes by parts/complexity, build actual app session contracts for 001–108 and S01–S06. Writers and interaction agents collaborate. The full chapter is always present even when interactive mechanics are still being integrated. No release until all mechanisms meet quality bar.

**Phase 6 — Journaling and memoir.** Finalize two-partner + shared privacy behavior, free writing, prompts, bookmarks, revisit logs, timeline, search, attachment picker, archival/provenance, user-selected export/import, backup encryption, restore and print-quality keepsake.

**Phase 7 — All artwork and sensory polish.** Import optimized book images, adapt 13 openers/108 chapter motifs/6 signatures, draw any original mobile-only graphics and icons, add subtle optional transitions, polish night reading, improve tablet mode. Render and visually inspect every part, games, journal and empty state.

**Phase 8 — Import/update stress tests and editorial QA.** Re-import same edition, import a revised edition with additions/removals, do upgrade rollback, preserve existing notes, test incompatible file, test off-grid usage. Run independent agents and repair failures. No journal deletion shortcuts.

**Phase 9 — Complete Android v1.0 first draft.** Build, sign appropriately, install, test core journeys end to end, generate release artifacts and final manifest, commit milestone, and give clear owner instructions for installation plus the **next time a revised book arrives**. Save status after each batch and keep a durable change queue.

**Batch/resume:** Maintain `planning/STATUS.json` and `planning/PRODUCTION_BOARD.md`; each chapter has states `book_validated`, `research_checked`, `content_mapped`, `interactive_ready`, `art_ready`, `journal_ready`, `editor_reviewed`, `tested`, `released`. Agent context resets must not erase progress. Each deliverable has owner, dependency, machine-verifiable acceptance check, and current evidence. If a session genuinely ends, preserve exact next steps for the next session; never claim background processing unless it is actually configured and running.

---

# 16. FINAL ACCEPTANCE / RELEASE GATES

The production is **not** finished until all boxes are proven, not merely asserted:

- [ ] The completed first book edition has been validated and its release/source hash recorded; original v0.1 was never misrepresented as full content.
- [ ] All 108 chapter texts, examples, detailed instructions and related prompts appear in the app **without summarization loss**.
- [ ] All 13 part introductions and six signature experiences are available, complete, illustrated and accessible.
- [ ] Every chapter offers Full Chapter reading and an appropriate usable Guided Experience, not a generic empty checklist.
- [ ] Specialized game/activity mechanics work for every applicable chapter and signatures; no fake click-only flows.
- [ ] Time-first discovery in all six buckets plus desired outcome, energy, depth, format, and filtered Surprise Us; plus A–Z, parts, bookmarks and revisit discovery.
- [ ] All book visuals integrated or responsibly mobile-adapted: cover, 13 part assets, 108 specific chapter artworks, six signature hero pieces, and necessary cards/diagrams/materials.
- [ ] Working two-partner/private/shared journal with autosave, chapter-specific prompts, optional notes, unlimited dated revisits, photographs/keepsakes, and Our Story timeline.
- [ ] Private notes survive app restarts, process death, content updates, APK upgrades, migrations and restore/import tests; can be exported into meaningful keepsake formats.
- [ ] Offline-first from first installation; no forced login/cloud; accurate privacy, PIN and backup capabilities.
- [ ] Reader and session accessibility, comfortable typography, TalkBack, adaptable movement/touch options, adult and consensual presentation.
- [ ] Book importer supports practical revised-edition submissions, produces reviewable diff, updates text/art/metadata/interactive rules, runs tests and releases updated artifacts with minimal owner interaction.
- [ ] Routine book content changes can follow deterministic sync; agent involvement is reserved for meaningful semantic/logic/art work; no pretend silent automation.
- [ ] Upgrade compatibility tests show old journal data survives deleted/renamed/revised chapters and prompt changes. Rollback is non-destructive.
- [ ] Actual Android APK built, installed and tested; secure signing/distribution limitations documented honestly.
- [ ] App source, content bundle, asset manifest, research references, unit/widget/integration tests, final QA evidence, release notes and one-message update playbook included.
- [ ] No sensitive or personal journal data in Git, packaged sample fixtures, release zip, logs or public cloud.

Any unchecked line means **there is still work to do**. Fix it, rerun automated tests, reproduce on device, and only then prepare a release.

---

# 17. THE NEXT TIME THE BOOK CHANGES — OWNER EXPERIENCE

Design for this real-world sequence:

1. The owner completes a revised book in the separate book project and copies **one new DOCX / EPUB / release ZIP** (ideally with its canonical content and images) into this app project's `book_inbox/`. No manual transcribing of 108 chapters.
2. The owner tells Cursor: **“Sync the latest approved book into The Closer Project Android app. Preserve every journal and rebuild/test what changed.”**
3. The coordinator triggers intake/diff and delegates only impacted content, image, interaction, accessibility and test work. The importer prints a clean, understandable change summary.
4. The app team's automated checks prove all 108+ chapters are still present, the changed parts match the book, and **all existing private/shared writings remain intact**.
5. The team produces a new tested APK or an importable compatible content pack, with a one-page update report explaining what changed and how to install it. Owner is consulted only on ambiguous/destructive changes or signoff decisions.

**Build this workflow into the project from day one.** Documentation alone doesn't count; an actual fixture-tested importer, migration and release path must exist. A new book supplied to Cursor cannot automatically change a device that has not received the resulting new build/content pack; make the final distribution step simple and explicit.

---

# 18. FIRST ACTIONS — EXECUTE, THEN KEEP MOVING

1. Read this work order and `README_START_HERE.md` completely. Inspect `.cursor/agents/` and the 108-ID JSON.
2. Confirm whether a **complete book edition** exists in `book_inbox/` or `book_sources/approved/`; if not, clearly track the completion gate while implementing project architecture, import/update tests and design system.
3. Set up Cursor subagents, shared `AGENTS.md` rules, issue/status tracking, Git repository and starter structure.
4. Implement the source validation + version diff engine **before** mass content screen hardcoding.
5. Build the immutable content store and durable, secure journaling persistence as separate domains.
6. Establish a polished reader + guided session + interactive game + individual/shared journal slice; test it on Android.
7. Once the full book arrives, import all its content/art and systematically expand across ALL 108 + six signature sessions with the agent team.
8. Run all QA, book update simulations, device installation, visual validation, backups and release builds. Do not stop after mockups or “MVP ready.”

**Mission: deliver the ENTIRE book as a truly native-feeling interactive Android experience AND a lasting private/shared memoir, then make each future book revision easy to translate into the app. Build it, verify it, and keep personal writings safe.**

---

# 19. AUTHORITATIVE DOCUMENTATION TO CONSULT AT IMPLEMENTATION TIME

Verify live/current requirements as you build. Official starting points:

- Flutter offline-first and app architecture: https://docs.flutter.dev/app-architecture/design-patterns/offline-first
- Flutter testing: https://docs.flutter.dev/testing/overview
- Android document picker/Storage Access Framework: https://developer.android.com/training/data-storage/shared/documents-files
- Android backup/data storage: https://developer.android.com/identity/data/backup
- Cursor subagents: https://cursor.com/docs/subagents
- Cursor agents/projects: https://cursor.com/docs/agent/overview

Treat docs as evolving technical guidance; pin exact release/package versions and verify license/behavior rather than blindly copying this brief's examples.
