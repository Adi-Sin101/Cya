# Cya! — Comprehensive Product Requirements Document

**Version:** 2.0 — Product direction extension, aligned to the existing repository  
**Date:** 15 October 2026  
**Repository:** https://github.com/Adi-Sin101/Cya  
**Existing app:** Cya! — Flutter/Dart, Android-first, with native Android capture surfaces and local encrypted SQLite storage already present  
**Status:** Proposed extension PRD; reconcile with the existing master PRD and implementation audit before coding

> **Important:** This document extends the current Cya! product; it does not rename the app or replace its existing architecture. The repository already has a master PRD (`docs/Cya_Master_PRD_and_Development_Bible.md`), native DB contract (`docs/native_db_contract.md`), plans, and a build log. These remain important sources of implementation truth. Resolve conflicts explicitly and record decisions in the existing ADR/living log.

---

## 1. Executive summary

Cya! already focuses on capturing postponed intentions quickly and resurfacing them later. This proposal extends that core into a **private, offline personal memory and intention system**: preserve spontaneous thoughts, connect related knowledge, help the user return to a selected priority, and let the user inspect how their thinking changes over time.

The user's main problem is not merely forgetting a to-do. Ideas arrive while working and can pull attention away from the current task. Routines can break when motivation changes or an unexpected event occurs. Notes can become hard to retrieve, and a long vertical conversation is not always the best way to explore a particular idea. The desired app should help the user retain ideas without following every new idea immediately, maintain a flexible view of commitments, and explore their own knowledge through links and branches.

Cya! must remain an **instrument, not an authority**. The user does the thinking and makes the decisions. The app can preserve, organize, retrieve, link, and remind based on user-provided information. It must not invent personal facts, decisions, prior conversations, or replies. **EmbeddingGemma 2 is part of the intended core memory architecture:** it supplies local semantic and cross-modal representations that let Cya! connect and retrieve saved thoughts. Similarity is a lead for exploration, not proof that two memories are related.

**Hard constraints:** local-only data for V1; no account, backend, cloud sync, remote AI API, telemetry upload, or required internet connection. **EmbeddingGemma 2-powered local semantic/multimodal retrieval is a core product capability, not an optional add-on.** The app must still safely capture, store, browse, and use keyword search if the model is temporarily unavailable, but the product-direction work is not complete until EmbeddingGemma 2 integration and meaningful retrieval behavior are implemented and tested. Performance is critical: the capture path must not wait for the Flutter engine, transcription, embedding generation, or any model inference.

**Existing code context inspected at the repository level:** `Adi-Sin101/Cya` is a substantial Flutter/Dart app with a master PRD, `AGENTS.md`, `CLAUDE.md`, Drift/SQLite data files, native Kotlin capture/reminder/widget/tile code, and tests. The current public README and master PRD describe a promise/intention manager, quick capture, native-thin Android path, reminders, categories, search, gamification, and local storage. This new direction must extend those capabilities rather than replace them. A detailed local code audit and test run are still required before implementation.

## 2. Product vision

**Cya! is a private external memory that helps people capture what matters, connect their own knowledge, and return to their chosen priorities.**

Product promise: **“Capture now. Remember later. Find the connections. Return to what matters.”**

Cya! should help users:
- capture a thought, intention, or idea before it disappears;
- preserve source/context and original wording/audio, then embed supported material locally with EmbeddingGemma 2 so related thoughts can be retrieved across modalities;
- return to their chosen priority after a capture instead of drifting into a new idea;
- organize thoughts without requiring perfect taxonomy at capture time;
- retrieve personal notes by keyword and by EmbeddingGemma 2 semantic similarity as a first-class capability;
- explore a thought horizontally through branches and related entries;
- study a topic through a connected network of notes;
- retain historical beliefs and decisions while showing the current user-designated view;
- adapt plans when real life changes;
- move their data manually between devices without a cloud account.

### 2.1 What Cya! is not
- Not a generic to-do app clone or a compulsory routine engine.
- Not a chatbot that must generate an answer for every interaction.
- Not an autonomous agent that executes tasks or replies to people.
- Not a surveillance tool that watches screens, reads private messages, or infers intent from app usage in V1.
- Not a cloud service.
- Not an AI-first app where capture waits for model loading or inference. Model-based semantic retrieval is core, but it must run after durable capture and never block the capture path.
- Not a replacement of the current Flutter architecture without evidence that the architecture is a blocker.

## 3. User problem and product outcomes

### 3.1 Problems to solve
1. The user gets new ideas while focused on a task and can switch to the new idea, losing the original task's momentum.
2. The user needs a frictionless place to dump ideas before organizing them.
3. The user needs a reasonably strict reminder of their own selected priority after capturing an idea.
4. Planning systems often work briefly then fall apart; the day is unpredictable and the system must support recovery.
5. Notes and reflections become scattered and difficult to query later.
6. Long vertical chats/notes are hard to explore by subtopic; users want to branch horizontally from a specific thought without changing the original context.
7. The history of a changed belief matters. Current state should evolve without silently erasing the reasoning that came before.
8. The user wants reminders and storage, not fabricated advice or the app making choices on their behalf.
9. Everything needs to run locally and efficiently, including on lower-resource Android devices.

### 3.2 Outcome metrics (measure locally; no telemetry upload)
- Time from opening a capture surface to durable save.
- Percentage of captures completed without adding metadata.
- Percentage of reminders opened/resolved/snoozed.
- How often the user returns to the selected priority after capture (only measure via explicit app interactions, not background surveillance).
- Retrieval success in manually designed test cases.
- Export/import integrity.
- Startup, capture, search latency, memory, storage, battery/thermal cost.
- Optional AI quality metrics measured with synthetic or user-consented local test data.

Do not optimize solely for streaks, time tracked, or task count. The goal is useful follow-through and preserved thinking, not maximizing app engagement.

## 4. User and operating context

Initial target user: the owner of the existing Cya! app. Design for their day-to-day tasks across academics/research, English/IELTS, career, creative work, relationships, household tasks, rest, and other personal areas. The app must not assume only schoolwork matters.

The target device discussed is a Samsung Galaxy A52 4G with 8 GB RAM and 128 GB storage. Treat it as the primary initial benchmark device if available. “Works on almost all devices” is an aspiration; support must be established by explicit minimum requirements and tests, not claimed without evidence.

Initial language requirements:
- Bangla text.
- English text.
- Banglish/code-switched text (Bangla speech expressed in Latin characters or mixed Bangla-English content).
- Voice capture of original audio independent of transcription.
- Offline transcription is a candidate requirement to investigate, not something to claim until an engine passes accuracy and performance tests for Bangla, English, and Banglish.

## 5. Core product principles

### P1. Capture first; organize later
No title, folder, tag, project, transcript, embedding, classification, or model response is required to save a thought.

### P2. Fast paths stay dumb
Capture code performs only the work necessary for durable local storage and any explicitly selected reminder behavior. Enrichment, transcription, embeddings, and link suggestions run asynchronously after save. Never place AI inference or a network operation on a critical capture path.

### P3. Local source of truth
The local database remains the source of truth. The Flutter app and native capture surfaces must keep respecting the shared storage contract. Data changes must be versioned and migrated safely.

### P4. Fully offline for V1 core
No required account, server, network API, telemetry upload, cloud sync, or service dependency. Core flows must work in airplane mode. EmbeddingGemma 2 is required for the core semantic/multimodal memory feature. Its model artifact must be available locally through bundling or a user-controlled local import/setup flow; never call a remote inference API or silently download model files in the background. A one-time, explicit model-file installation may be used during setup, but all personal content and inference remain on device.

### P5. User owns their thoughts and decisions
The user's original words and audio take precedence over machine-generated derivatives. Preserve original text/audio. AI must not silently rewrite, merge, or replace source content.

### P6. Suggestions are not facts
Suggested relationships/categories are labeled as suggestions and can be accepted or rejected. Embedding similarity is not certainty. AI should say “not found in your saved material” rather than fabricate personal history.

### P7. History plus current state
Preserve historic reflections and decisions, but allow the user to identify a current view or decision and explicitly link it to what it updates/supersedes. The old view remains available.

### P8. Adaptable routine, not brittle schedule
Users can reprioritize, defer, cancel, or reschedule when life changes. Missed tasks should not create shame or invalidate the rest of the day.

### P9. Respect user agency
A firm reminder can point back to the user's own selected priority but must not block other apps or prevent a change of mind. No screen watching or automatic distraction claims in V1.

### P10. Lightweight, responsive and low overhead
Do not load large models at startup without proven need. Avoid continuous background model execution. Measure actual performance in release mode and keep fallback paths for low-spec devices.

### P11. Preserve existing Cya!
Inspect the current repository, existing Master PRD, architecture, native-thin capture path, database contract, reminders, widgets/tile, Memory Garden, categories, search, and tests. Reuse what works. Any divergence must be justified with evidence and logged.

## 6. Scope and priorities

Priority levels: **P0 — core first release; P1 — planned enhancement; P2 — experimental/later.**

### 6.1 P0 — required core
- Repository audit, feature matrix, baseline tests/build.
- Preserve Cya!'s current working promise/intention capture/resurfacing behavior, native capture surfaces and event-log integrity.
- Minimal-friction text capture with durable local persistence.
- Local voice recording and playback, separately from transcription.
- Bangla/English/Banglish text entry and storage.
- Local memory browse/edit/archive/delete and keyword search.
- **EmbeddingGemma 2 local semantic embeddings and semantic retrieval for text and audio memories**, including text-query-to-audio-memory retrieval and similarity-based discovery across the shared embedding space. This is a required product capability, not optional polish.
- A locally persisted embedding index with model/version metadata, rebuild support, background processing, and deletion consistency.
- Tasks/intention/commitment handling, due dates and text notifications, respecting current data model where possible.
- User-selected current priority/focus session and capture-then-return reminder.
- Preserve historical reflections/decisions; explicit update/supersede relation.
- Basic explicit note-to-note links and branch/drill-down flow; the graph view can be staged, but connections must be navigable from the first connected-memory release.
- User-controlled export/import/backup with validation and no silent overwrite.
- Privacy, offline, regression, performance, and data migration tests.

### 6.2 P1 — staged delivery after the P0 memory engine
- Offline speech-to-text for Bangla, English, and Banglish (separate from EmbeddingGemma 2).
- Image/video capture and indexing with EmbeddingGemma 2 vision/video encoders, so text, images, video, and audio can be retrieved in a shared embedding space. The model/runtime may load only the modality encoders needed for a particular operation.
- Connected topic exploration and local graph/tree UI, including bounded local-neighborhood views.
- Local text-to-speech for optional spoken reminders.
- Expanded study-oriented browsing: topic pages, branch notes, and links among sources.

P1 indicates delivery order, not that EmbeddingGemma 2 is optional: text+audio semantic memory is P0; expanded image/video UX and graph visualization are staged after the core index works.

### 6.3 P2 / explicitly later
- Optional app-usage insights, only if user explicitly opts in and after feasibility/privacy review; not needed now.
- Cross-device synchronization. V1 instead supports manual local export/import.
- Cloud AI, online accounts, server features, analytics, remote APIs.
- Generative conversational life coach, autonomous agents, automatic replies, screen surveillance, automatic app blocking.
- Automatic categorization that silently commits to the database without user review.

## 7. Information architecture and screens

The repo currently has a designed home shell and screens for home, capture, promises, details, digest, garden, achievements, profile, and onboarding. The product should evolve this structure where sensible rather than blindly add a new navigation stack. Codex must map current screens to the below conceptual capabilities and propose the smallest coherent redesign.

Conceptual areas:
1. **Today / Focus** — user's current priority, open intentions/tasks, deadlines and upcoming reminders; editable plan for the day.
2. **Capture** — the fastest possible typed/audio thought capture. Existing share sheet, Quick Settings Tile, and widget remain part of this story.
3. **Memory** — all saved thoughts, voice recordings, text, imported notes, and past decisions, with keyword search/filter.
4. **Explore** — links, branches, related notes, current-vs-historic views, optional graph/tree.
5. **Projects / Topics** — optional contexts for grouping, never required at capture time.
6. **Review / Digest** — optional review of open commitments and thoughts, in line with current digest behavior.
7. **Settings & Data** — privacy, permissions, model status/management, notifications, export/import, local storage diagnostics.

These are conceptual capabilities, not a mandatory seven-item bottom nav. Keep the interface concise and clear. Avoid duplicate destinations and preserve the existing visual identity, motion and Memory Garden where they serve user value and performance.

## 8. Detailed workflows

### 8.1 Thought capture while working
1. User has selected or started a task/focus session.
2. A new thought appears.
3. User opens a quick capture surface and types or records the thought.
4. The app saves raw text/audio locally immediately, with timestamp and optional context. No organization is required.
5. Once durable storage succeeds, the app confirms the save.
6. If a current priority is active, show a concise firm reminder grounded in that user-selected priority, e.g. “Saved. Your current priority is reading the thesis paper. Return when you're ready.”
7. The user can dismiss, ignore, change priority, or switch tasks.
8. Any transcription, embedding, classification, or related-link suggestions occur after save and may fail without affecting the saved entry.

### 8.2 Two-minute idea dump
The user may explicitly indicate that they are taking a short capture window to explain a thought. The app should allow a short recording or text entry and then return to the previous task context. The length should be configurable or use a simple user-set default; do not assume or force two minutes in all cases. Once saved, show current priority. Don't block task switching.

### 8.3 Flexible daily planning
- All life areas may be represented.
- The user manually selects priority; optional suggestions must be explainable and dismissible.
- Tasks/intentions can have due dates, reminder times, status and source links.
- If something unexpected happens, allow reprioritize/defer/reschedule/cancel.
- A changed plan should not be portrayed as failure.
- Timer data must never be represented as proof that user was working.

### 8.4 Store and retrieve thoughts
- Keyword search must work when model inference is temporarily unavailable; semantic retrieval remains a required capability of the completed product.
- Search supports Bangla, English and Banglish text to the extent supported by chosen local index; test multilingual behavior.
- A voice recording with no transcript remains retrievable by date, title/metadata, explicit tags, and EmbeddingGemma 2 semantic retrieval. Do not claim keyword search over raw audio.
- Search results link to original content and show date, type, source/context and related project/topic if present.

### 8.5 Drill down / branch horizontally
The user can select a note, segment or topic and create a related branch for deeper exploration. The new branch has its own notes/links and does not mutate the source. Show the source/parent relation and easy navigation back. Model the graph as records plus explicit edges; graph UI is a visual projection of those edges, not the source of truth. Distinguish user-created, accepted, and machine-suggested edges. Provide list/tree navigation as fallback for low-spec devices or large graphs.

### 8.6 Belief and decision changes
- Store each reflection as a dated record.
- User can explicitly mark “updates”, “supersedes”, “supports”, “contradicts”, or “changed my mind about” relation.
- Show current user-designated belief/decision and allow access to prior versions/reflections.
- Do not auto-summarize conflicts into a single confident narrative.

### 8.7 Reminder behavior
- Continue supporting existing Cya! reminder presets, resurfacing, snooze/resolution behavior, and notification actions, unless the repo audit finds a specific conflict to resolve.
- For the new focus-return flow, text notification/banner is the default; it must not behave like a disruptive alarm.
- Optional voice output can be activated by tapping a notification or enabled explicitly in settings.
- Fixed reminders can use Android TTS without a generative model, but verify the installed voice can operate offline. Disclose if voice pack download is necessary.
- Android exact alarm and notification behavior must be described honestly; don't promise guarantees across OEM battery restrictions without testing.

### 8.8 Manual backup and transfer
- Single-device/local-only operation for V1.
- User can export a versioned package and manually copy it to another phone.
- Import validates schema, manifest, file paths, sizes, attachment references, and checksums.
- No silent overwrite. Prefer import into a new database or explicit merge/replace choices with backup first.
- Include/exclude audio attachments is a user-visible choice if size matters.
- Encryption behavior must be explicit. The existing repo references encrypted SQLite; verify actual implementation and ensure exported archive security is defined independently. Don't make ambiguous security claims.

## 9. Local AI and transcription architecture

### 9.1 Separate capabilities
- **Audio recording:** capture/store original audio; no model required.
- **Speech transcription:** model converts audio to text; must be verified offline and benchmarked for Bangla, English, Banglish/code-switching.
- **Embeddings:** convert supported text/media to vectors for similarity search and retrieval; does not itself produce transcripts or prose.
- **TTS:** speaks a provided text; no generative LLM needed for fixed reminders.
- **Generative model:** not required for V1 and must not be silently introduced as a dependency.

### 9.2 EmbeddingGemma 2 — required core semantic/multimodal memory engine
EmbeddingGemma 2 is the required model family for local semantic retrieval and cross-modal memory connections in this product direction. Google’s official model card describes a 740M-parameter open multimodal embedding model mapping text/code, images, video, and audio into a shared 768-dimensional embedding space, with modular configurations: 270M text-only, 440M text+vision, 570M text+audio, and 740M full multimodal. It is an embedding/retrieval model: it does not generate prose or produce a readable speech transcript. Verify the exact release artifact and compatible Android runtime before implementation. Official references: https://ai.google.dev/gemma/docs/embeddinggemma/model_card_2?hl=en and https://developers.googleblog.com/google-ai-edge-with-embeddinggemma-2/.

Required product behavior:
- Embed text memories locally and search them by meaning, not only literal keywords.
- Embed voice recordings directly with the audio encoder, allowing a text query to retrieve a related recording even when it has no transcript.
- Keep source audio/text intact; store embeddings only as derived, rebuildable index data.
- Use semantic similarity to surface related memories and candidate connections; clearly label these as suggestions, never facts.
- Use a shared vector space for future text/image/video/audio retrieval. Implement image/video indexing in the staged modality rollout, not as a substitute for the P0 text+audio memory path.
- Use task-specific instruction prefixes, correct normalization, consistent dimensions, and a validated distance metric as required by the chosen runtime/model card.
- Support rebuilding/reindexing after model-version changes and deleting vectors when source content is deleted.

Engineering must verify and document:
- exact model version/artifact, license and redistribution limits;
- modality support exposed by the specific LiteRT/MediaPipe/runtime artifact;
- package/model size and local installation strategy;
- Android API/ABI/device compatibility;
- cold startup, warm inference latency, peak RAM, disk footprint, CPU/GPU/NPU usage, battery and thermal behavior;
- selected vector dimensions, normalization and similarity metric;
- retrieval quality for Bangla, English, Banglish/code-switched text and voice recordings;
- behavior on the Samsung Galaxy A52 4G (8 GB RAM) and a lower-resource profile.

**The performance test gates the implementation strategy, not whether the feature is optional.** Optimize with modular encoder loading, supported quantized artifacts, lazy model initialization, bounded background jobs, and incremental indexing. Do not run inference during capture or block startup. If a tested artifact/runtime still fails the device budget, report the measured blocker and alternatives and ask for a product decision; do not silently demote EmbeddingGemma 2 to optional or claim this product direction complete. Keyword search remains available as a reliability fallback if inference fails, but it is not a replacement for the required semantic-memory capability.

### 9.3 Offline speech recognition
Android's platform `SpeechRecognizer`/intent APIs must not be assumed offline: offline availability and behavior vary by service, OS, installed language packs, and device. Do not use them for strict offline compliance unless network independence is concretely verified on supported configurations. Evaluate a genuinely bundled/local engine (e.g., a compatible Whisper.cpp or other offline ASR build) only after measuring APK/model size and target-device performance. Benchmark real representative samples for:
- Bangla speech;
- English speech;
- code-switched Bangla-English/Banglish;
- noisy room, quiet room, short/long recordings;
- transcription speed and memory/thermal pressure.

Always preserve original audio. Let the user edit transcript. Store transcript provenance/status and never treat a generated transcript as the original utterance. If local ASR is not good enough, allow manual text alongside original audio rather than sending data to an API.

### 9.4 No remote service
No remote API calls to transcribe, embed, categorize, generate summaries, or sync in V1. If model files need initial download, that must be a separate explicitly initiated and explained setup path; preferably include/import the files to support a strict no-network deployment.

## 10. Functional requirements

| ID | Requirement | Priority | Acceptance summary |
|---|---|---:|---|
| FR-01 | Fast text capture | P0 | Save with timestamp without mandatory metadata; durable confirmation; no AI wait. |
| FR-02 | Local audio capture | P0 | Record/stop/play original audio locally independent of ASR; gracefully handle permissions/storage/errors. |
| FR-03 | Multilingual text | P0 | Bangla, English and Banglish typed content persists/searches as supported by index. |
| FR-04 | Memory management | P0 | Browse, edit, archive, explicitly delete; source content and derivatives remain distinguishable. |
| FR-05 | Local-first persistence | P0 | Core flows work in airplane mode; use current DB/migration strategy; no data loss. |
| FR-06 | Keyword search | P0 | Search text and metadata without any model; results link to source. |
| FR-07 | Intention/task reminders | P0 | Preserve Cya!'s current intention/promise loop, reminder, snooze, completion and history behavior. |
| FR-08 | Current priority/focus | P0 | User can choose priority/start/end a timer; timer is user-driven, no surveillance. |
| FR-09 | Capture then return | P0 | During explicit focus session, save first, then show a reminder of the user's own current priority; dismissible. |
| FR-10 | Adaptive day planning | P0 | Reschedule/defer/reprioritize/cancel with non-shaming recovery. |
| FR-11 | Historical decisions | P0 | Old records remain; newer decision links as a change; current view is separate. |
| FR-12 | Manual data export/import | P0 | Versioned, validated, attachment-aware, no silent overwrite, safe failure handling. |
| FR-13 | Explicit knowledge links | P0 | User can link notes/tasks/projects and follow links. |
| FR-14 | Branch/drill-down | P0 baseline | Branch from source without changing it; navigate back; horizontal exploration of related thought. Graph canvas can be staged. |
| FR-15 | EmbeddingGemma 2 semantic/multimodal memory | P0, required | Local embeddings for text and audio; text-to-audio semantic retrieval; background indexing; model/version metadata; keyword fallback for failures. |
| FR-16 | Suggested connections | P0, required baseline | EmbeddingGemma 2 surfaces semantically related memories as reviewable suggestions; user can accept/dismiss; never auto-merge. |
| FR-17 | Offline ASR | P1, gated | Separate offline speech-to-text engine; language benchmark; audio preserved; transcript editable. Not provided by EmbeddingGemma 2 itself. |
| FR-18 | Graph/tree UI | P1/P2 | Local neighborhood/topic view, source navigation, list fallback, performant on low-end devices. |
| FR-19 | Optional TTS | P2 | Opt-in or tap-to-speak, offline availability checked, not required for capture. |
| FR-20 | Local diagnostics | P0 | Storage use and errors visible; no data upload or telemetry. |
| FR-21 | Privacy controls | P0 | Clear local storage location, mic/notification permissions, deletion, export, and controls to pause/resume local model processing. |

## 11. Existing Cya! invariants to preserve

Repository docs identify these as critical and they take precedence unless a deliberate, logged product decision changes them:
- Native-thin capture path: capture surface writes the minimum required data locally and schedules intended reminders without a Flutter-engine boot, network call, or model inference.
- Shared local SQLite source of truth between native Kotlin capture components and Flutter/Drift.
- Native and Dart DB contracts must remain equivalent; review `docs/native_db_contract.md` before changing schema.
- Append-only intention event log. Mutations should have corresponding event records in the same transaction, as specified in current master PRD.
- Do not put FTS5 operations in Android system SQLite native writer; current contract assigns Dart-owned FTS index handling because Android system SQLite may not include FTS5.
- Keep current reminder/resurface/snooze/resolution loop, Quick Settings Tile, share capture, widget, Memory Garden, achievements and visual system unless audit shows a clear reason to change.
- Read the entire existing master PRD and relevant plans/build log before non-trivial work; update status/decision/lesson logs according to repository conventions.

## 12. Data model concepts

Do not duplicate existing entities if the current model can safely extend. Current repo already has intention/event, preferences, categories/statuses and a database contract. Add the smallest required schema changes only after mapping the current schema and migrations.

Conceptual additions may include:

### Memory record or generalized capture
- stable ID, timestamps;
- type: typed thought, audio thought, transcript, imported note, decision/reflection, source context;
- raw user text and/or original audio attachment reference;
- optional title, language hint, source, topic/project, tags;
- processing state for transcription/embedding;
- archive/deletion state, as consistent with current deletion model.

### Task/current priority
Reuse the existing `Intention`/`Promise` model where semantically appropriate. Avoid two parallel task engines. Where a pure thought is not an intention, either extend with a type safely or add a separate memory entity with explicit link to intention. Record the design decision.

### Knowledge link
- source and target IDs;
- relationship type (`related`, `branch_of`, `follows_up`, `supports`, `contradicts`, `changed_mind_about`, `supersedes`, `belongs_to`);
- origin (`user` / `model_suggested`);
- status (`suggested`, `accepted`, `dismissed`);
- created timestamp and optional model metadata/confidence where useful.

### Derived artifacts
- transcript references original audio and has provenance/status;
- embedding references exact source record/segment and model version;
- derived data is rebuildable and must be removed when its source is deleted according to policy.

Schema design must respect the current encrypted database/shared-native-storage contract and safe migration rules. Never use an illustrative schema from this PRD as permission to replace the existing DB.

## 13. Performance, reliability and compatibility

“Blazing fast” must be measured, not merely claimed. Initial goals for release builds on a named primary device:
- quick capture interaction should complete under 2 seconds (preserve existing product promise); target toward under 1 second where measurement supports it;
- text save should return immediately after durable local write and not await enrichment;
- capture UI should open rapidly and no model should initialize on the capture path;
- normal scrolling/navigation should aim for stable 60 FPS on the benchmark device;
- memory, storage, battery, thermal effect and model inference must be measured separately.

Report measurements with phone/model, Android version, release/debug build, database size, record count, audio size, model cold/warm status, and procedure. Test at least the primary Galaxy A52 profile if available and a lower-resource profile/emulator. Do not promise universal performance without a supported-device matrix.

Reliability cases: process death, interrupted recording, low storage, denied microphone/notification permissions, reboot and rescheduling, database migration, corrupted import archive, attachment loss, missing model, failed model initialization, airplane mode, and model-unavailable fallback workflows.

## 14. Privacy and security

- No account, backend, or runtime API required.
- Core operation fully offline.
- No analytics upload or content transmission.
- No screen capture, accessibility scraping, notification listener, location, contacts, or app-usage permission for this v1 scope unless a separate future opt-in feature is explicitly approved.
- Microphone is accessed only during user-initiated recording and with permission.
- Use a scoped/user-mediated file picker for export/import.
- Verify the existing encrypted database implementation in code and current tests. Export encryption is a separate decision; clearly disclose what the export contains and whether it is encrypted.
- Do not claim encryption or secure deletion unless tested.
- Import files are untrusted: validate file paths, sizes, format/version and integrity. Protect existing data from partial or silent overwrite.
- Deletion should cover source record and its associated audio, transcript, embedding, local index entries and links according to the product's deletion policy.
- Keep privacy and security decisions in docs/PRD decision log.

## 15. UX and content guidance

- Capture must be obvious and minimal.
- Do not shame users for missed tasks.
- Focus reminder can be strict but respectful and based on the user's chosen task.
- Preserve raw user text; do not automatically “clean up” their thoughts.
- Offer structure after capture, not as a prerequisite.
- A graph is optional navigation, never the only way to access information.
- Visually separate current state, historical record, transcript, and AI-generated derivative.
- Distinguish user-created links from suggestions.
- Maintain Cya!'s existing visual identity and performance-conscious design where it supports clarity.

## 16. Implementation phases

### Phase 0 — mandatory repository audit
1. Read `docs/Cya_Master_PRD_and_Development_Bible.md` in full, `AGENTS.md`, `CLAUDE.md`, `docs/native_db_contract.md`, `plans/README.md`, latest relevant plans, and `plans/BUILD_LOG.md`.
2. Inspect app entry, providers, routes, UI screens, DAOs/tables/migrations, native Kotlin shared DB writers, reminders, share sheet, widget, tile, encryption/key code, export service and tests.
3. Run baseline `flutter analyze`, `flutter test`, and Android release/debug build if available; record environment and exact results.
4. Create requirement coverage matrix for this PRD versus original PRD and implementation.
5. Identify architecture/data migration conflicts and existing features to preserve.
6. Audit runtime network use and app permissions; state what can and cannot be verified from code.
7. Recommend staged plan and stop before broad code changes or migrations for user review.

Deliverable: `docs/Cya_Product_Direction_Audit.md` plus an implementation plan in `plans/` using existing repo conventions. Update no app code in Phase 0 unless the user separately authorizes it.

### Phase 1 — core offline memory foundation
- Add minimal-friction text capture/browse/edit/search while preserving existing intention loop.
- Add local audio recording/playback independent of transcription.
- Add suitable memory-to-intention links if needed, with data migration tests.
- Ensure original content stays stable.
- Add tasks/current priority/focus reminder capture-return flow without surveillance.
- Keep reminders text-first and the existing reminder engine intact.

### Phase 2 — connections and personal history
- Explicit links, branch/drill-down, topic/project associations.
- Historical belief/decision relations and current state view.
- Local browse/list/tree views; graph view only after the data model and performance support it.

### Phase 3 — required EmbeddingGemma 2 semantic memory engine
- Benchmark exact EmbeddingGemma 2 artifact(s) and compatible local runtime on the target phone. The goal is to select the smallest performant configuration that still delivers the required semantic-memory feature, not to decide whether the feature should exist.
- Prototype with a locally generated/test corpus plus user-approved sample recordings, covering Bangla, English, Banglish/code-switching, long/short text and audio. Do not upload personal samples.
- Implement local text and audio embeddings, semantic text search, text-query-to-audio retrieval, similar-memory discovery, background/incremental indexing, and rebuild/delete handling.
- Add explicit metrics for embedding latency, retrieval quality, RAM, app/model storage, thermal/battery behavior, and model cold/warm state.
- Investigate supported quantized artifacts, modular loading, lower embedding dimensions with required re-normalization, and lazy loading if the first configuration is too heavy.
- If the exact runtime cannot meet the device budget, document measurements, try supported optimizations and alternate compatible runtime artifacts, then request an explicit product decision before substituting another model or reducing the core capability. Do not silently call semantic memory optional.
- Separately benchmark offline ASR for a readable transcript; failure of ASR must not prevent audio embedding/retrieval.

### Phase 4 — portable backup, hardening and polish
- Complete safe export/import and encryption choice.
- Exercise backup/restore across clean installation/test device.
- Offline/privacy audit; performance/thermal validation; accessibility and error-state polish.
- Update master PRD living log, plans and BUILD_LOG.md after each unit.

## 17. Acceptance criteria

V1 scope is accepted only when:
1. All existing Cya! behaviors selected for retention still work, with regression tests.
2. Text capture can be saved without metadata, is durable, and does not depend on AI.
3. Audio can be recorded/stored/played locally even if model inference is temporarily unavailable.
4. Bangla, English and Banglish typed text can be captured and retained.
5. Keyword search works without models.
6. The locally running EmbeddingGemma 2 index can retrieve semantically related text memories from a natural-language query.
7. A voice recording can be retrieved by a semantically related text query without requiring a transcript; source audio remains the source of truth.
8. Related-memory suggestions are visible, traceable to their source entries, and can be accepted or dismissed. The embedding model is not silently treated as a generative agent.
9. Users can manage intentions/tasks and due reminders without cloud services.
10. During a user-started focus session, new-thought capture saves first then shows the selected priority; user can dismiss or change priority.
11. No V1 app-usage or screen surveillance exists.
12. Earlier reflections survive when a newer decision supersedes them.
13. Export/import is versioned, validated, and never silently overwrites existing data.
14. Core flows work in airplane mode; no account/server required.
15. Model absence/failure never blocks launch, saving, or core navigation; however, the completed product-direction release must include working EmbeddingGemma 2 semantic retrieval, not merely this fallback.
16. EmbeddingGemma 2 semantic search can retrieve relevant text and voice memories; tests include text-query-to-audio retrieval with no transcript. Related-memory suggestions are visibly labeled and never merge records automatically.
17. Core performance measurements are recorded from release builds on named devices.
18. Migration tests protect the shared Dart/native database contract.
19. Documentation truthfully lists limitations, untested areas, and any model/download requirements.


## 18. Testing plan

### Functional/regression tests
- Existing Cya! baseline tests all run and their baseline result is recorded.
- Save text with no metadata; restart app and verify persistence.
- Record audio, stop, reopen, playback; verify original audio is retained.
- Deny microphone permission and verify recovery.
- Search Bangla, English, Banglish text; document tokenizer/index limitations.
- Create/edit/defer/complete/reschedule task or promise; reminder action still works.
- Start focus session, capture thought, verify save-before-reminder.
- Dismiss reminder; switch/stop/change current priority without restriction.
- Link two notes; create branch; source remains unchanged.
- Mark new belief/decision as update/supersession; both historical records remain.
- Export and import; compare records, attachments and checksums.
- Corrupt/incompatible import fails without changing current data.
- Airplane mode tests. Also test capture and basic browsing while the model is intentionally unavailable, plus successful on-device EmbeddingGemma 2 semantic retrieval in airplane mode.
- Migration contract tests cover Kotlin/Dart schema together.

### Performance/reliability tests
- cold/warm startup, quick capture launch, durable write latency, search latency, scrolling frame times;
- DB and attachment size scaling;
- audio capture interruption and low storage;
- reboot/reminder rescheduling; notification permission denied;
- model cold/warm latency and peak memory; battery/thermal notes;
- offline ASR corpus metrics for language/code-switching.

## 19. Risks and mitigations

| Risk | Mitigation |
|---|---|
| New memory model conflicts with existing intention schema | Audit first; preserve and extend current schema; migrations and contract tests |
| Feature expansion damages the fast capture path | Capture remains native-thin; all enrichment asynchronous |
| Embedding model too large or unsupported | Verify exact artifact/runtime and optimize configuration; keep keyword search as a failure fallback, but do not mark the required semantic-memory feature complete until EmbeddingGemma 2 works locally |
| Banglish ASR quality is inadequate | Benchmark; preserve audio; editable transcript; do not send to API |
| Similarity links are misleading | Label suggestions, require user confirmation, no auto-merge |
| Graph becomes slow/cluttered | Show local neighborhood; list/tree fallback; avoid full graph by default |
| Export leaks private material | Explicit inventory, optional encryption decision, user-mediated save, clear warnings |
| Migration corrupts existing data | Backups, transactional migrations, tests for both native and Drift writers |
| Reminder is intrusive | Text-first, dismissible, user-controlled, no automatic screen monitoring |
| “Offline” dependency unexpectedly calls network | Inspect code/dependencies/manifests and verify airplane-mode behavior |

## 20. Open technical decisions

Resolve through audit/benchmarks rather than guessing:
1. Exact existing DB schema/migration path for new memory, audio, link and branch records.
2. Whether audio is stored as managed attachment files referenced by DB or via another existing mechanism.
3. Whether export is a single archive, database plus attachments, or both.
4. Whether exports must be encrypted in first release; do not equate DB encryption with archive encryption.
5. Exact offline ASR engine/model/license/build size/ABI compatibility.
6. Exact EmbeddingGemma 2 artifact, supported modalities and local API compatibility.
7. Whether target device can run it within acceptable RAM/latency/thermal budgets.
8. Whether graph view is immediate P1 or follows explicit links/list view.
9. Precise performance targets based on current measured baseline.
10. Scope of iOS parity; first implementation may prioritize Android, aligned with existing repo.

## 21. Codex rules and definition of done

Codex must:
- inspect before edits; read existing project docs first;
- treat `docs/Cya_Master_PRD_and_Development_Bible.md` as the existing spec and this document as a proposed extension; identify conflicts rather than silently choose;
- avoid a rewrite or wholesale architecture change without evidence and approval;
- preserve app data and shared native/Drift DB invariants;
- write a dated plan before implementation and log outcomes in `plans/BUILD_LOG.md` and PRD living log per repository instructions;
- implement in small phases and run tests after each phase;
- add migration/regression tests;
- avoid new network dependencies and content uploads;
- never claim untested model support or performance;
- ask before destructive or irreversible change;
- report exact files changed, requirements completed/deferred, test commands/results, device/performance measurements, offline verification, data impacts, known limitations, and next step.

A unit is done only when acceptance criteria pass, tests and analyzer results are reported honestly, migrations are safe, offline use is preserved, performance is measured where relevant, and docs/logs are updated.

## 22. First implementation task

**Do not implement features yet.** Start with repository Phase 0. Read the existing Cya master PRD and code contract, inspect the current code, run baseline tests/build where possible, prepare `docs/Cya_Product_Direction_Audit.md` and a phased plan, then stop for review. The audit should specifically call out that the GitHub repo already contains a memory/intention foundation (promises, event history, reminders, local DB/encryption references, categories/search and capture surfaces) so the proposed extension reuses those capabilities rather than duplicating them.
