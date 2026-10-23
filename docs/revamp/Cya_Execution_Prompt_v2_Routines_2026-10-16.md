Work in the existing Cya! repository (Adi-Sin101/Cya). The application is already built with Flutter and native Android components. Do not rename it Zia or Sia. Do not rewrite it from scratch.
Read docs/Cya_Master_PRD_and_Development_Bible.md, docs/native_db_contract.md, AGENTS.md, CLAUDE.md, plans/BUILD_LOG.md, and the approved docs/Cya_Product_Direction_PRD.md. Follow repository-specific planning/logging conventions. The current master PRD and schema contract remain important; any conflict must be written down and resolved via an explicit decision before implementation.
Core product direction
Extend Cya!'s current intention/promise manager into a fast, private, fully offline personal memory and adaptive productivity system. The user wants to capture spontaneous thoughts by text or voice, preserve original context, return to their own selected priority, connect related ideas, drill down into a branch without mutating the source, preserve historic decisions, and find their own material later.
Non-negotiable constraints
- No account, backend, cloud sync, runtime API, analytics uploads, or transmission of personal content.
- All core features function offline.
- Preserve the existing native-thin capture path and shared local SQLite/Drift contract. Never put model inference, network calls, or Flutter-engine boot on the critical native capture path.
- Capture original text/audio first; classification, transcription, embeddings and link suggestions run asynchronously after durable save.
- Preserve the existing intention/promise flow, reminder engine, event log, native capture surfaces, and useful UI/design components unless an approved audit proves a change is needed.
- No screen surveillance, app-usage tracking, notification listener, autonomous replies, task execution or cloud AI in this scope.
- Do not assume Android speech APIs are offline. Verify or use a truly local engine.
- EmbeddingGemma 2-powered local semantic/multimodal memory is a REQUIRED core product capability, not optional polish. Verify the exact artifact, modalities, runtime/API compatibility, licensing, packaging and real hardware performance so the implementation strategy is sound. A device benchmark can change modality loading, quantization, runtime or rollout order; it cannot silently remove the required semantic-memory capability.
- Preserve original reflections. New beliefs/decisions link to older history; never silently rewrite history.
- Related-note similarity is a suggestion, not truth. No automatic merges; user can accept/dismiss suggestions.
- Core operations such as capture, persistence, reminders, browsing and keyword search remain usable if the model is temporarily disabled or missing. However, the product-direction implementation is not complete until EmbeddingGemma 2 semantic retrieval and related-memory discovery are integrated and tested offline.
- Do not claim “encrypted,” “offline,” “fast on all devices,” or model support without validation.
- Ask before destructive changes or risky schema migrations.
Work in phases
Phase 0: audit first (required)
If docs/Cya_Product_Direction_Audit.md does not exist and has not been approved, execute the Audit Prompt task first and stop. Do not proceed into implementation.
Phase 1: approved core offline memory and productivity foundation
Implement in small changes based on the approved audit:
1. Fast typed thought capture, saved locally without required tags/folders/models.
2. Local voice recording/playback with original audio preserved independently of transcription. Every saved text/audio memory must enter the local EmbeddingGemma 2 semantic index asynchronously, with retries/rebuild support.
3. Memory browsing/editing/deleting/archive and keyword search, supporting Bangla, English and Banglish text. Keyword search is the fallback; semantic search via EmbeddingGemma 2 is required for completion.
4. Reuse/extensively integrate the existing intention/promise store where appropriate; avoid duplicate task engines.
5. Current priority/focus session chosen by the user; saving a new thought during a session saves first, then displays a concise firm-but-respectful reminder based on the user’s own chosen priority. Dismissible and never blocks switching apps.
6. Real routine management, not just timers: users can create/edit/pause/resume recurring routines; configure optional weekday recurrence, preferred time windows and steps; select which routines matter today; mark occurrences completed/skipped/deferred; and recover after disruptions by reprioritizing, shortening, pausing or rescheduling. No guilt-based streak pressure.
7. Lightweight optional daily/weekly reviews based only on locally recorded task/routine outcomes. Suggestions must explain their evidence and never silently modify a routine or priority.
8. Preserve old reflections/decisions and link new updates/supersessions to them.
9. Implement and test local EmbeddingGemma 2 text/audio embeddings, text-query-to-audio retrieval without a transcript, and related-memory suggestions as required product behavior.
10. Standard text notifications; optional tap-to-speak can be later. Do not introduce disruptive alarms for focus prompts.
11. Versioned export/import, validating records, attachments and integrity; no silent overwrite.
12. Appropriate tests and a safe DB migration that preserves native/Dart contract.
Phase 2: connections and branch exploration
- Add explicit user-created relationships between memories, tasks, topics and projects.
- Allow branching from a note or section into a separate exploration while retaining source link/context and leaving the source unchanged.
- Keep a navigable list/tree fallback. Graph visualization should be bounded (e.g. local neighborhood) and must not become the only access method.
- Distinguish user-created links from model suggestions.
Phase 3: required EmbeddingGemma 2 semantic/multimodal engine hardening
EmbeddingGemma 2 is a core requirement. This phase optimizes and broadens the tested engine; it is not a feature-approval gate.
- Read the official model card and Google AI Edge deployment docs. Verify current artifact variants, licensing, supported modalities, on-device runtime APIs, and any limitations before coding.
- Prototype and benchmark exact local artifacts on the target Samsung Galaxy A52 4G (8 GB RAM) when available. Measure model/package size, peak RAM, cold/warm latency, CPU/GPU/NPU path, battery/thermal behavior, and retrieval quality.
- Use supported modular encoder loading and quantized model artifacts where appropriate. Verify that the Android artifact exposes the required text/audio path.
- Build the index locally and asynchronously, store the model/version and vector dimensions, apply required normalization consistently, and support re-indexing after upgrades and deleting vectors with source records.
- Add image/video modality retrieval as the next modality expansion after the required text+audio path, without making the shared embedding-space vision optional in the long-term plan.
- If the first artifact is too heavy, optimize by selecting only required encoder(s), supported quantization, lazy loading and bounded background jobs. If no supported configuration meets the device budget, stop and report measured evidence plus options to the user—do not silently remove the capability or substitute another model.
- Offline ASR is separate: benchmark Bangla, English and code-switched Banglish with representative local samples, preserve original audio, and make any transcript editable. EmbeddingGemma 2 does not itself produce human-readable transcripts.
- Never require a remote inference API or background model download. Any model installation must be bundled or explicitly user-controlled and compatible with strict offline operation.
Phase 4: validation and polish
- Run all existing and new tests, analyzer and builds.
- Test airplane mode and disabled-model fallback workflows.
- Test process death, low storage, interrupted recording, corrupted imports, reboot/rescheduling, and DB migration.
- Measure release performance on named devices, including target Galaxy A52 if available. Record cold/warm model status, memory and thermal notes.
- Verify routine recurrence, day rollover, missed/paused routines, rescheduling and notification behavior.
- Update main PRD living log, decision log, module status, lesson log, plans, and plans/BUILD_LOG.md after each completed work unit.
Code quality and data rules
- Use the existing Flutter/Riverpod/Drift setup where it remains suitable; do not introduce a second architecture without evidence.
- Native code and Drift must agree on database schema/version. Read and update docs/native_db_contract.md in the same change as schema migrations; add contract/migration tests.
- Preserve event-log invariants: state mutation and event record should be transactionally consistent.
- Do not add FTS5 operations to Android's native system SQLite writer where current contract prohibits it.
- Store audio as managed local attachments with stable references if this matches audit recommendations. Never place large audio or model files as DB blobs without profiling/design justification.
- Delete derived transcripts, embeddings and indexes with the associated source as defined by the deletion policy.
- Keep background work bounded/cancellable where practical and don't load models at startup unnecessarily.
- Avoid placeholder UI presented as complete.
- Test routines across creation, recurrence, selecting for Today, completion/skipping/defer, disruption recovery, and daily/weekly review; do not claim routines are implemented merely because a timer exists.
- No new network permission/dependency without explicit approval and proof that it is not used for core data transfer.
Required reporting after each phase
List user-facing behavior delivered, exact files changed, requirements completed/deferred, migrations/data impact, tests/build commands and exact results, offline/network verification, device/performance measurements, remaining limitations and next step. Do not claim work was tested if it was not. Do not continue past a phase requiring approval.