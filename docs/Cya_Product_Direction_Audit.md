# Cya! product-direction implementation audit

**Date:** 15 October 2026, Asia/Dhaka. **Repository:** `Adi-Sin101/Cya`.
**Audited HEAD:** `17c2c8b2b57c5acfb62c59f65d27002f7cd90be1`, branch `main`.
**Disposition:** audit and proposed plan only; implementation requires review.

Cya! already has a working Android intention/promise foundation: shared local storage,
native capture, reminders and notification actions, search, local identity, encryption,
export, and event-derived progress. Extend it; do not build another task engine or app.
The proposed memory product is **not implemented**: neutral memories, original audio,
focus sessions, knowledge/history links, import and semantic indexing are missing.
EmbeddingGemma 2 text-and-audio semantic memory is **required P0**, including finding
audio from a text query without transcription. Keyword fallback is resilience, never
a substitute for delivering that capability.

## 1. Scope, evidence and baseline

### Documents and change boundary

Read the Master PRD, native DB contract, `AGENTS.md`, `CLAUDE.md`, `plans/README.md`,
the complete existing build log, iteration plans 1–6 and 9, and relocation plan.
The actual supplied extension is
[`revamp/Cya_Product_Direction_PRD.md`](revamp/Cya_Product_Direction_PRD.md), with
[`revamp/Cya_EmbeddingGemma2_Core_Requirement.md`](revamp/Cya_EmbeddingGemma2_Core_Requirement.md).
The root-level extension filename in the request does not exist. Both supplied
documents were read; neither supersedes the Master PRD without an explicit decision.

The checkout was already dirty from the preceding relocation work: `README.md`,
`android/.gitignore`, Master PRD and `plans/BUILD_LOG.md`, plus untracked proposal
documents and the relocation plan. Those are baseline state, not audit edits.
This audit adds this report, a proposed plan and supporting model research only.
Existing product documents, dependencies, schemas and app/test sources are preserved.
The user's audit-only boundary takes precedence over instructions to update existing
PRD/build-log files. This report records the audit outcome instead.

Evidence classes below are deliberately separate:

- **Observed:** commands or narrow synthetic probes executed during this audit.
- **Code-supported:** traced implementation, not a new physical-device acceptance test.
- **Historical:** earlier observations recorded in the existing build log.
- **Proposed / unknown:** future design, budgets or tests; no implementation implied.

### Exact environment and commands

| Item | Audited environment / result |
|---|---|
| Host | Windows 11 IoT Enterprise LTSC; OS version `10.0.26100`; Flutter reports build `26100.9711`; x64; 16,497,954,816 bytes physical RAM |
| Checkout / SDK | `C:\Code\Logarithm\cya`; Flutter at `C:\Flutter\flutter`; Android SDK at `D:\Android` |
| Flutter | Stable **3.44.4**, revision `ad70ec4617`; engine revision `a10d8ac38d`, content hash `700aebeca4c0e610f109a3979ee3e71b69d666bc` |
| Dart / Java | Dart **3.12.2**; Temurin OpenJDK **17.0.17+10** |
| Android build | SDK/build-tools 36; installed NDK includes `28.2.13676358`; AGP **9.0.1**, Gradle **9.1.0**, Kotlin plugin **2.3.20**; `dev.cya.app`, version `1.0.0+1` |
| Connected device | `emulator-5554`, `sdk_gphone64_x86_64`, Android **14 / API 34**; no physical A52 or Poco connected |
| `flutter analyze` | **Exit 0**, `No issues found! (ran in 79.7s)` |
| `flutter test --reporter expanded` | **Exit 0**, **183/183 pass**, test reporter elapsed **00:39** |
| `flutter build apk --debug` | **Exit 0**, Gradle **34.2 s**, `build/app/outputs/flutter-apk/app-debug.apk` |
| Supplementary audit probes | `flutter test .buildlog/audit_probes_test.dart --no-pub --reporter expanded`: **exit 0, 3/3**; observations below, not new product regression coverage |
| Dependency inspection | `dart pub deps --json`: exit 0; locked versions preserved |
| Artifact permission inspection | `D:\Android\build-tools\36.0.0\aapt.exe dump permissions` against current debug and existing ARM64 release APKs: succeeded; permissions described in section 6 |

Commands ran in PowerShell with the inherited stale Flutter PATH entry replaced in
the command environment by `C:\Flutter\flutter\bin`. Baseline command output is in
ignored `.buildlog/audit-analyze.log`, `audit-test.log`, `audit-debug-build.log`,
`audit-probes.log` and `audit-deps.json`. Build/dependency tooling may use the network;
this is distinct from runtime personal-content upload.

**Not run in this audit:** a fresh release build (debug satisfies the requested build
baseline); APK installation or destructive device operations; physical-phone tests;
OEM reboot/Doze tests; packet capture or airplane-mode acceptance; model inference,
model download, ASR, RAM/energy/thermal or retrieval-quality benchmarks; iOS/macOS
builds (no macOS/Xcode host); Windows desktop build (Visual Studio C++ tooling absent).
An unchanged-source ARM64 release artifact from the preceding relocation session was
available for read-only manifest inspection. That session built all three release
ABIs and recorded ARM64 **26.8 MB**, release native capture **239 ms**, warm debug
capture **106 ms**, and eventual onboarding rendering. These are **historical**,
not this audit's performance results or evidence for the Galaxy A52 budget.

### Audit probes: what actually happened

An ignored test harness exercised current code with synthetic inputs; it did not
edit existing tests, create a model prototype, or touch the user's device database.

1. **Bangla discrimination:** stored `কাল`, `কুল`, `আগামীকাল meeting`, `kal meeting`,
   `tomorrow meeting` through the actual DAO/in-memory SQLite. Searching either
   `কাল` or `কুল` returned `[কাল, কুল, আগামীকাল meeting]`; `আগামীকাল` found its
   own record, `kal` found `kal meeting`, and `meeting` found all three mixed/English
   records. Storage works; these results do **not** establish accurate Bangla lexical
   retrieval. `_toMatchQuery` excludes Unicode marks from tokens, and the FTS table
   uses default tokenizer settings. Both layers need joint evaluation.
2. **Key-fetch failure:** a mocked `PlatformException` sent to the actual
   `DatabaseKeyPort.rawKey()` returned `null`. Code then selects the unencrypted
   connection branch. This confirms exception handling; an Android plaintext write
   under injected Keystore failure was **not** performed.
3. **External-write visibility:** with real SQLite underlying Drift, an external SQL
   transaction inserted a second intention and event. A direct DAO count saw **2**
   records, while the existing `watchAllActive()` subscription still had only its
   **1 initial emission** after 100 ms. Native Android is a different writer too;
   this reproduces the invalidation problem at the DB seam, not a full Android
   process/resume test.

## 2. Current architecture and working behavior

### Evidence map

These links identify implementations actually read, not feature guesses from names.
References E01–E16 in the matrix refer to this map.

| Ref | Implementation and traced behavior |
|---|---|
| E01 | [`main.dart`](../lib/main.dart), [`cya_bootstrap.dart`](../lib/presentation/app/cya_bootstrap.dart), [`providers.dart`](../lib/core/di/providers.dart): `ProviderScope`, sprite splash, lazy database, debug-only seed, asynchronously watched enrichment/retirement passes |
| E02 | [`app_router.dart`](../lib/core/router/app_router.dart), [`route_paths.dart`](../lib/core/router/route_paths.dart), [`cya_app.dart`](../lib/presentation/app/cya_app.dart), [`home_shell.dart`](../lib/presentation/shell/home_shell.dart): four retained tab stacks, capture modal, onboarding redirect, lock overlay, custom deep links, resume scheduling |
| E03 | [`tables.dart`](../lib/data/db/tables.dart), [`cya_database.dart`](../lib/data/db/cya_database.dart), [`intention_dao.dart`](../lib/data/dao/intention_dao.dart), [`preference_dao.dart`](../lib/data/dao/preference_dao.dart): three domain tables, schema v2, transaction/event writes, Dart-owned FTS and export reads |
| E04 | [`drift_intention_repository.dart`](../lib/data/repositories/drift_intention_repository.dart), [`Intention`](../lib/domain/entities/intention.dart), [`usecases`](../lib/domain/usecases/), [`intention_providers.dart`](../lib/presentation/providers/intention_providers.dart): pure domain vocabulary and use cases, repository-backed streams, event-derived views |
| E05 | [`CaptureActivity.kt`](../android/app/src/main/kotlin/dev/cya/app/capture/CaptureActivity.kt), [`CyaStore.kt`](../android/app/src/main/kotlin/dev/cya/app/capture/CyaStore.kt), [`CyaDatabaseContract.kt`](../android/app/src/main/kotlin/dev/cya/app/capture/CyaDatabaseContract.kt), [`ReminderDefaults.kt`](../android/app/src/main/kotlin/dev/cya/app/capture/ReminderDefaults.kt): engine-free text share/selection capture, current-state row plus event, Tonight alarm |
| E06 | [`ReminderScheduler.kt`](../android/app/src/main/kotlin/dev/cya/app/reminders/ReminderScheduler.kt), [`ReminderReceiver.kt`](../android/app/src/main/kotlin/dev/cya/app/reminders/ReminderReceiver.kt), [`ReminderNotifications.kt`](../android/app/src/main/kotlin/dev/cya/app/reminders/ReminderNotifications.kt), [`NotificationActionReceiver.kt`](../android/app/src/main/kotlin/dev/cya/app/reminders/NotificationActionReceiver.kt), [`BootReceiver.kt`](../android/app/src/main/kotlin/dev/cya/app/reminders/BootReceiver.kt): native alarms, grouped notifications, escalation, Done/Snooze/Let it go, rearming |
| E07 | [`QuickCaptureActivity.kt`](../android/app/src/main/kotlin/dev/cya/app/tile/QuickCaptureActivity.kt), [`CyaTileService.kt`](../android/app/src/main/kotlin/dev/cya/app/tile/CyaTileService.kt), [`CyaWidgetProvider.kt`](../android/app/src/main/kotlin/dev/cya/app/widget/CyaWidgetProvider.kt): clipboard-prefilled native text dialog; tile and RemoteViews widget entry points |
| E08 | [`MainActivity.kt`](../android/app/src/main/kotlin/dev/cya/app/MainActivity.kt), [`reminder_port.dart`](../lib/native/reminder_port.dart), [`platform_reminder_scheduler.dart`](../lib/native/platform_reminder_scheduler.dart): `cya/reminders` bridge owns scheduling, permissions, icons, key retrieval, external links, drafts and document sharing |
| E09 | [`DatabaseKey.kt`](../android/app/src/main/kotlin/dev/cya/app/identity/DatabaseKey.kt), [`DatabaseCipher.kt`](../android/app/src/main/kotlin/dev/cya/app/capture/DatabaseCipher.kt), [`database_key_port.dart`](../lib/native/database_key_port.dart), E03: Keystore-wrapped DB key; Kotlin SQLCipher / Dart SQLite3 Multiple Ciphers |
| E10 | [`preference_lock_repository.dart`](../lib/data/repositories/preference_lock_repository.dart), [`pin_hasher.dart`](../lib/domain/services/pin_hasher.dart), [`identity_providers.dart`](../lib/presentation/providers/identity_providers.dart), [`lock_gate.dart`](../lib/presentation/screens/lock/lock_gate.dart), [`BiometricGate.kt`](../android/app/src/main/kotlin/dev/cya/app/identity/BiometricGate.kt): local PIN, cooldown, session lock and native fingerprint shortcut |
| E11 | [`data_export.dart`](../lib/domain/services/data_export.dart), [`privacy_providers.dart`](../lib/presentation/providers/privacy_providers.dart), [`system_share_port.dart`](../lib/native/system_share_port.dart), [`DocumentShare.kt`](../android/app/src/main/kotlin/dev/cya/app/privacy/DocumentShare.kt): JSON export, redaction, cache-file sharing and logical erase |
| E12 | [`enrichment.dart`](../lib/domain/services/enrichment.dart), [`enrich_intention.dart`](../lib/domain/usecases/enrich_intention.dart), [`aging_policy.dart`](../lib/domain/policies/aging_policy.dart), [`retire_stale_intentions.dart`](../lib/domain/usecases/retire_stale_intentions.dart): English rules, category/deadline writes and 30-day retirement |
| E13 | [`capture_sheet.dart`](../lib/presentation/screens/capture/capture_sheet.dart), [`promises_screen.dart`](../lib/presentation/screens/promises/promises_screen.dart), [`promise_detail_screen.dart`](../lib/presentation/screens/promise_detail/promise_detail_screen.dart): typed capture, filters/search, read/detail, completion, snooze, category, conditional archive and confirmed delete |
| E14 | [`home_screen.dart`](../lib/presentation/screens/home/home_screen.dart), [`garden_screen.dart`](../lib/presentation/screens/garden/garden_screen.dart), [`achievement_projection.dart`](../lib/domain/projections/achievement_projection.dart), [`xp_projection.dart`](../lib/domain/projections/xp_projection.dart), [`today_provider.dart`](../lib/presentation/providers/today_provider.dart): section-scoped views, painted garden, XP/achievements and midnight refresh |
| E15 | [`digest_screen.dart`](../lib/presentation/screens/digest/digest_screen.dart), [`DigestScheduler.kt`](../android/app/src/main/kotlin/dev/cya/app/reminders/DigestScheduler.kt), [`DigestReceiver.kt`](../android/app/src/main/kotlin/dev/cya/app/reminders/DigestReceiver.kt), [`profile_screen.dart`](../lib/presentation/screens/profile/profile_screen.dart), [`onboarding_screen.dart`](../lib/presentation/screens/onboarding/onboarding_screen.dart), [`DeviceReliability.kt`](../android/app/src/main/kotlin/dev/cya/app/identity/DeviceReliability.kt): Sunday review, recently retired restore, profile/privacy and permission/OEM setup |
| E16 | [`pubspec.yaml`](../pubspec.yaml), [`pubspec.lock`](../pubspec.lock), [`AndroidManifest.xml`](../android/app/src/main/AndroidManifest.xml), [`app/build.gradle.kts`](../android/app/build.gradle.kts), [`test/`](../test/), [`tool/metrics.dart`](../tool/metrics.dart): dependencies, packaging, permissions, coverage and export-based local metrics |

### Architecture and navigation

Flutter presentation calls domain use cases through Riverpod wiring; the Drift
repository maps to a DAO and handwritten immutable domain entities. `domain/` has
no Flutter imports. Drift generated files are checked in. `core/` supplies DI,
result/error types, clock and visual tokens. Native Kotlin owns critical Android
surfaces and the DB/key/OS integrations. There is no backend in app code.

The actual routes are `/home`, `/promises`, `/garden`, `/profile`, `/promise/:id`,
`/digest`, `/achievements`, `/welcome`, `/welcome/profile`, `/welcome/lock`, and
`/lock-settings`. The center capture button opens a bottom sheet, not a fifth
navigation branch. `cya://promise/<id>` and `cya://digest` are passed by Kotlin to
Dart; Flutter automatic deep-link routing is disabled. The PIN gate overlays the
router, preserving destinations behind it. First-run onboarding can redirect a
destination to setup; the code does not persist a deferred destination through that
flow. Do not claim universal deep-link preservation on first install.

Native capture receives `ACTION_SEND text/plain` or `ACTION_PROCESS_TEXT`, trims
text, preserves an optional subject, attributes source/package best-effort, extracts
the first HTTP(S) URL, commits an intention/event, schedules Tonight, refreshes any
placed widgets and dismisses. There is no Flutter engine or model initialization on
that path. Tile/widget capture uses another native activity with a text field and
clipboard prefill. “Dictate” in copy means an input method may offer dictation; there
is no recorder or local ASR implementation, and third-party keyboards have their own
privacy/network behavior. The widget body opens the app; its plus opens native capture.

In-app capture needs text only; reminder presets/custom date are optional refinement,
but an actual reminder is always supplied. The DAO can store null reminder values;
the current capture use case cannot create a neutral, unscheduled thought. Due time
and reminder time are not separate user-authored fields. Model-based work is absent.

The DB and alarm schedule are separate commits: an OS scheduling failure cannot roll
back an already saved row. Native capture may therefore report failure after durable
save; retry duplication is a risk. Dart's bridge swallows native platform errors,
so a successful use-case result does not itself prove an alarm exists.

### Feature inventory and limits

| Current capability | What is implemented / important limit |
|---|---|
| Home and promises | Today ring, source icons, preset/time display; Open/Done/All and category filters; “All” still excludes archives at the DAO |
| Promise actions | Done/undo, snooze options, source link, category and confirmed deletion. Archive is exposed in the snooze-limit prompt; no general archive browser. Content edit and arbitrary reschedule exist below UI but have no general edit/reschedule screen |
| Reminders | Exact/inexact fallback; tiers zero snoozes → first channel, one/two → banner, three → digest; three-hour default snooze; grouped notifications retain individual actions |
| Reminder qualification | `CHANNEL_QUIET` actually uses `IMPORTANCE_DEFAULT`, not low/silent; grouping uses child alerts, so visual grouping does not prove a single audible interruption. Receiver logs an attempt even if a notification cannot be seen |
| Weekly review | Next Sunday 18:00, inexact and rearmed after firing. Digest has waiting/stalled/kept and recent auto-retirements. Retired records are not globally browsable; recently retired query is limited to 14 days. No once-only acknowledgement is persisted for that section |
| Identity | Local display name/avatar, optional four-digit PIN, PBKDF2-HMAC-SHA256 100k, 16-byte salt, 32-byte result; five failed attempts start a 30-second cooldown doubling to five minutes; hashing runs off UI isolate |
| Lock | Native framework biometrics from API 28; PIN remains fallback; relock after a minute in background. It gates UI, not the database key, notification content or engine-free actions. No `FLAG_SECURE` or explicit notification-content hiding policy found |
| Progress/visuals | XP = 10/capture + 25/resolution event; painted Memory Garden and six achievements; kept-rate shown instead of a day streak; Flutter particle rewards, bundled fonts, motion/haptic tokens and reduced-motion paths |
| Enrichment | Bounded launch pass (up to 60 rows), pure English category/date rules; no ML Kit model, no persistent inference job queue, no durable “processed/no match” state |
| Export/privacy | Versioned readable JSON including archived rows/events and selected preferences; excludes PIN salt/hash/cost/failure/cooldown keys; chooser presentation counted as export success, not verified persistence at destination. No import |
| Platform parity | Android native implementation exists. iOS/macOS are Flutter host scaffolds, not equivalent native capture/reminder/encryption implementations; missing-channel fallbacks are not parity |

### Regression risks to address before extending the store

Severity here describes risk for the extension; it is not a claim that a failure was
reproduced on a physical device unless the evidence column says so.

| Risk | Evidence and implication | Proposed regression/acceptance work |
|---|---|---|
| **P0: encryption failure can select plaintext** | E09: `PlatformException`/missing plugin → null key; E03 opens without encryption when null. Null branch confirmed by probe, Android write not injected | Android production must fail closed with recoverable error; fresh/existing encrypted/legacy files and key loss tested; desktop/test fallback explicitly scoped |
| **P0: native migration errors can stamp success** | `CyaStore.open()` swallows every upgrade statement error, then updates `user_version`; creation transaction and version stamp are separate; newer-version DB is not rejected explicitly | Atomic migration/version stamp, only verified idempotency tolerated, fail unsupported future schema; inject disk/SQL/process-death failures and test both opener orders |
| **P0: plaintext conversion swap can lose live filename** | `DatabaseCipher` deletes original before rename. Rename failure/process death leaves `.migrating` without original; next `openOrCreateDatabase` can create an empty live file. No demonstrated recovery/lock protocol | Failure-injection recovery with original/candidate verification and recoverable swap; WAL/open-reader/concurrent opener coverage; do not rely on the optimistic comment |
| **P0: backup/privacy gap** | Manifest has no explicit backup/extraction exclusions; OS backup can include files/shared preferences independently of app network permission. Device-bound key makes raw-file restore unsafe | Define no-cloud and D2D policy, test backup rules/restore and local portable export separately |
| **P1: stale reactive UI after native writes** | Probe reproduces missing Drift watch invalidation; resume invalidates reminder-health only. Native paths do not notify Drift table updates. App restart/explicit queries can see changes | Native capture/Done while Flutter alive → UI and counts refresh without restart; use deliberate invalidation/revision signal, not continuous busy polling |
| **P1: Bangla lexical false matches** | Exact probe results above; query regex includes L/N but not M; default FTS tokenizer | Preserve combining marks in tested query/index policy; corpus with vowel/minimal pairs, conjuncts, mixed script and normalization; no silent original-text normalization |
| **P1: custom reminder may be overwritten** | E12's `worthMoving` tests only `snoozeCount == 0`, a future extracted deadline and a non-null reminder; it does not verify equality to Tonight or track user provenance | Custom-date and explicit-reschedule tests; retain user-vs-default provenance; review suggestion policy before automatic writes |
| **P1: permanently hidden memory if intentions generalized naively** | Capture automatically schedules; retirement archives open/snoozed rows; ordinary browse/search excludes archives; XP counts captures/resolutions | Non-action memories must not enter scheduling/aging/progress queries; archive browse and explicit retention rules |
| **P1: deletion/export completeness** | E11 uses sequential reads without a shared export snapshot; erase rows/FTS/preferences/OS alarms are separate steps; cached exports and wrapping key are not removed; digest alarm/posted notifications are not explicitly cleared | Consistent snapshot, interrupted erase/retry, caches/attachments/vector cleanup, digest and notification policy; logical deletion is not secure flash erasure |
| **P1: history is not full source revision history** | `updateContent` overwrites `raw_content`; event says `change: content` but omits old/new content. Repeated resolves add events/XP; log is not cryptographically authenticated | Explicit content revision and supersession semantics; preserve retained promise metrics; no claim of cryptographic tamper resistance |
| **P1: native test gap** | No Kotlin unit/instrumentation tests; `native_contract_test.dart` uses copied DDL and literal strings, not compiled Kotlin behavior | Real native tests plus paired Drift/native device integration, encryption/packaging and scheduler failure paths |
| **P2: lock/permission/error gaps** | Lock gate defaults unlocked while settings load; PIN fields written sequentially and incomplete credential verifies open; several UI callbacks ignore command errors; platform booleans default optimistically | Delayed/error/loading security tests, atomic PIN replacement, visible recoverable errors; no blanket security guarantee |

## 3. Extension requirement coverage

**Supported** means a traced current capability with relevant baseline coverage,
not certification of every OEM/performance criterion. **Partial** means reuse exists
but the extension acceptance is unmet. **Missing** means no implementation path was
found. **Unknown** means a specific quality/environment claim has not been verified.

| ID / priority | Current support | Evidence, gap and proposed destination |
|---|---|---|
| FR-01 P0 fast text capture | **Partial** | E05/E07/E13 save without filing metadata and without inference. Only promises, automatic reminder; no fresh A52 latency measurements. Preserve native capture; add neutral-memory mode |
| FR-02 P0 local audio | **Missing** | No recorder/player, microphone permission, attachment lifecycle or interruption handling. Native capture/save plus local playback needed independently of ASR |
| FR-03 P0 multilingual text | **Partial; quality unknown** | Unicode text persists; real Bangla probe exposes lexical false matches. No multilingual UI/font/readability/normalization regression corpus |
| FR-04 P0 memory management | **Partial** | E03/E13 provide intention browse/delete and internal edit/archive. No neutral memory, revisioned editor, general archive UI, audio management or derived/source separation |
| FR-05 P0 local persistence/offline | **Partial** | Shared local DB exists; no backend/client upload path found. Encryption fallback, default OS backup, future attachments and unrun airplane-mode checks prevent full acceptance |
| FR-06 P0 keyword search | **Partial** | E03/E13 FTS raw text/snippet, prefix tokens, ranked results, no model. Not source/package/category metadata search; no audio-derived text; archives excluded; multilingual discrimination incomplete |
| FR-07 P0 retained intention reminders | **Supported foundation; device acceptance unknown** | E04–E08 preserve current loop. Physical reboot/Doze, current channel/group alert behavior, failure acknowledgement and existing tests' native gaps remain |
| FR-08 P0 priority/focus | **Missing** | Today list is not a user-selected priority; no focus record/timer/start/end semantics |
| FR-09 P0 capture-return | **Missing** | Current confirmation is generic. No saved focus context or priority-grounded post-save reminder/dismiss/change flow |
| FR-10 P0 adaptive day planning | **Partial** | Completion/snooze/archive and internal reschedule exist; no ordered priority, explicit defer/cancel taxonomy, day planner or arbitrary reminder editing UI. Reuse intentions rather than second task engine |
| FR-11 P0 historical decisions | **Missing** | Event timestamps are not historic content revisions, explicit belief records/current-view designation or supersedes relations |
| FR-12 P0 export/import | **Partial** | E11 version 1 JSON export exists, with no importer, archive manifest/checksums, attachment validation, restore/merge/replace safety or portable encryption |
| FR-13 P0 explicit links | **Missing** | Saved external deep link is not a typed relationship among notes/promises/projects |
| FR-14 P0 branch/drill-down | **Missing** | No parent/segment/edge records, non-mutating branch creation or source/back navigation |
| FR-15 P0 required EmbeddingGemma 2 | **Missing** | No weights, compatible runtime binding, vectors/model metadata, processing queue/rebuild/deletion consistency or semantic text/direct-audio query path |
| FR-16 P0 related suggestions | **Missing** | Current categories are rule writes, not related-memory similarity with accept/dismiss provenance. Requires P0 index and explicit suggestion state |
| FR-17 P1 offline ASR | **Missing; feasibility unknown** | “Dictate” copy supplies no ASR. Separate local multilingual engine and measured corpus needed; original audio persists regardless |
| FR-18 P1/P2 graph/tree | **Missing** | Memory Garden is a progress visualization, not a knowledge graph. Begin with navigable explicit edges/list; bounded neighborhood canvas later |
| FR-19 P2 TTS | **Missing** | No TTS engine/voice policy. Proposal 6.2 calls this P1 while FR-19 says P2; delivery priority needs a decision, opt-in semantics stay fixed |
| FR-20 P0 diagnostics | **Partial** | `tool/metrics.dart`, event metadata, reminder-health banner and OEM checklist. No in-app storage/model/job/error diagnostics; no runtime model metrics |
| FR-21 P0 privacy controls | **Partial** | Local lock, notification permission, logical deletion and plaintext export exist. Mic, model pause/resume, storage-location disclosure and scoped import/export selection are missing |

### Requirements outside the FR table

| Proposal section(s) | Coverage / traceability |
|---|---|
| 1–5: instrument/agency, original source, local-only, no model startup | No generative agent or autonomous send exists. No original audio yet; capture trims original text. E12 automatic decisions require reconciliation. Required model failure fallback and pause controls must be added |
| 6.1 P0 index lifecycle | Missing source/model/preprocessing fingerprints, processing state, incremental/rebuild paths, source-delete cleanup and resumable queue; included in FR-15 production phase, not deferred polish |
| 6.2 image/video and shared space | Missing. Explicit staged P1 encoder/media/retrieval plan in sections 8–10; image/video cannot replace required audio |
| 6.2/7 topics/projects/study | Missing contexts and topic browse. Optional at capture; reuse links and unified source references rather than mandatory taxonomy |
| 6.3 exclusions | No accounts/cloud inference/sync/listener/app-usage/accessibility surveillance/autonomous sending in app code. Do not introduce them. Keep OS backup and user-mediated external shares distinct from this statement |
| 8.1–8.3 capture-return, configurable dump, flexible day | Existing fast promise capture is reusable; priority sessions, configurable capture window and adaptive planner are missing; timers must not claim observed work |
| 8.4 retrieval | Existing lexical search partial; no direct audio similarity; metadata/date browse and original-source result presentation need extension |
| 8.5–8.6 branches/history | Missing; links must distinguish suggested/accepted/dismissed and current vs historic views, including segment anchors and navigation back |
| 8.7 reminder behavior | Current reminders retained; focus-return needs a separate low-disruption policy, not reused escalation. Offline opt-in voice remains unverified |
| 8.8/12/14 portable data/privacy | Export foundation partial; no archive/import/attachment protection. Encryption of DB is not encryption of exported JSON or future recordings/vectors |
| 9.1–9.4 AI separation | Current app has no AI runtime. Recording, embedding, ASR, TTS remain separate; remote inference prohibited; local model setup cannot silently fetch files |
| 11 shared/native/event invariants | Existing design retained, with code-vs-document risks in sections 4–6; current native SQLCipher is not the historical system-SQLite implementation |
| 13 performance/reliability | Current baseline tools pass. A52, lower-resource physical device, energy, thermals, media interruptions and scale testing are unknown; benchmark plan below |
| 15 UX | Sage/mint identity and reduced motion exist; memory/derivative distinctions, accepted suggestions and focus UX are missing. Avoid seven competing bottom-nav items |
| 16/20/21 staged process and choices | This audit plus proposed plan; existing visions preserved; unresolved choices in section 11. No implementation authorization inferred |

**Proposal section 17 acceptance checklist:** AC1 and AC9 have a retained tested
foundation but incomplete native/OEM acceptance; AC2/4/5 are partial text capabilities;
AC3/6/7/8/10/12/13/15/16 are unmet; AC11 is code-supported absence of surveillance;
AC14 is code-supported offline architecture but unrun airplane-mode acceptance;
AC17 is unmet for named target-device performance; AC18 has partial copied-DDL
coverage, not real two-runtime migration certification; AC19 is fulfilled for this
audit's disclosures, not a completed product-direction release.

## 4. Storage, native ↔ Drift contract and migration risks

### Existing schema, exact encodings

`cya.db` is at Android `context.filesDir/cya.db`, matching Dart application-support
resolution. Both code constants are **schema version 2**. DateTime is SQLite INTEGER
Unix **seconds**; method-channel/alarm inputs use milliseconds, converted at the
native DB seam. Nullability/status wire values are cross-runtime contracts.

| Table | Existing columns and constraints |
|---|---|
| `intentions` | `id INTEGER` autoincrement PK; non-null `source_app TEXT`, `raw_content TEXT`, `captured_at INTEGER`, `updated_at INTEGER`; nullable `source_package`, `snippet`, `deep_link`, `category` TEXT; nullable `reminder_at`, `extracted_deadline` INTEGER; non-null `status TEXT DEFAULT 'open'`, `snooze_count INTEGER DEFAULT 0` |
| `intention_events` | Autoincrement integer `id`; non-null `intention_id` FK to intentions (no explicit cascade), `type TEXT`, `occurred_at INTEGER`; nullable `metadata TEXT` (JSON by convention, no JSON validity constraint) |
| `preferences` | `key TEXT` PK, `value TEXT`, both non-null; profile/theme/onboarding, PIN policy, search watermark and reliability confirmation |
| `intentions_fts` | Dart-created FTS5 external-content virtual table over `raw_content` and `snippet`, content rowid = intention id; derived, not in native creation statements |

Shared indexes: `idx_intentions_status`, `idx_intentions_reminder_at`,
`idx_intention_events_occurred_at`, `idx_intention_events_intention`.
Statuses: `open`, `snoozed`, `resolved`, `archived`. Events: `captured`, `snoozed`,
`resurfaced`, `resolved`, `archived`, `edited`; Kotlin does not currently need a
constant for every Dart-only edit. The table column does not enforce this vocabulary.

Version 1 → 2 adds nullable `source_package`. Dart applies `onUpgrade`; native code
applies `upgradeStatements` if it opens first. Either can create the shared tables.
`docs/native_db_contract.md` still says the creator stamps version **1** in its
“Who creates the file” paragraph despite a v2 header/history and v2 code. It also
describes the old system SQLite writer and contains no complete encryption contract.
These are documentation defects, preserved for an approved reconciliation change.

### Event and search invariants

Capture, status/snooze/category/reminder/content/enrichment/retirement/resurface writes
pair state change and event in a DB transaction. Explicit user deletion removes the
event history with the intention; preferences and derived FTS updates are not promise
events. SQL does not enforce the state/event pairing against arbitrary writers.
The log is application-append-only, not a cryptographically tamper-evident ledger.

Edits are not revision snapshots. An `edited` record can identify a content edit but
cannot reconstruct the old wording. Metadata for Dart capture interpolates the source
label without JSON escaping; native escaping is limited as well. Treat exported
metadata as potentially malformed and validate it before any importer relies on it.

FTS is reconciled on Dart open/search using `fts_indexed_through_id`; unknown state,
content edit and deletion trigger rebuilds. New native inserts are picked up by id,
not by comparing counts. Neither native capture nor a native trigger should depend on
FTS or vector indexing. Current native code now bundles SQLCipher; do not infer its
full extension capabilities from the historical system-SQLite failure, nor relax the
no-index-on-capture invariant without an approved contract change.

Retirement does not touch raw content, but archived rows disappear from normal search.
The watermark tracks inserts, not arbitrary native content edits/deletes. Concurrent
reconciliation/watermark updates also need a consistency test before adding index
workers. Native row mutation does not automatically invalidate Drift streams.

### Encryption and keys: implementation versus claims

Kotlin loads `libsqlcipher.so` from `net.zetetic:sqlcipher-android:4.6.1`; Dart's
`sqlite3:3.5.2` build hook supplies `libsqlite3mc.so` and configures SQLCipher v4
compatibility with cipher/legacy pragmas before the key. Different library names
avoid the historical JNI collision. A 32-byte random DB key is AES-GCM sealed with
Android Keystore alias `cya_db_wrapping_key`; IV plus ciphertext is stored in
`cya_secure` shared preferences. The raw SQLCipher literal crosses the process-local
method channel and is cached in native memory. Hardware backing is requested only
through the provider's defaults, not attested; no StrongBox guarantee was verified.
The wrapping key deliberately does not require user authentication, permitting
notifications/capture on a locked phone. The PIN does not derive the DB key.

Both cipher implementations have availability checks, but these do not close the
null-key fallback described above. Native `librariesLoaded` is set before the probe
check completes, and wrapped-key persistence ignores `commit()`'s boolean result:
failure/retry/process-death cases need tests. A four-digit PIN and UI overlay do not
provide strong encryption against a process already holding the DB key.

Native plaintext conversion uses `sqlcipher_export` into `.migrating`, preserves
`user_version`, then removes WAL/SHM and swaps files. Its failure/swap risks are in
section 2. Dart's connection comment assumes native conversion has happened, yet
the `databaseKey` channel branch only retrieves a key; bootstrap can open Drift first.
Legacy plaintext → Flutter-first migration ordering is therefore unproven and must
be exercised alongside native-first migration before extending schema or encryption.

No-key platforms deliberately open plaintext. This includes unsupported native
integrations, not just unit tests; do not advertise Android encryption as iOS/desktop
parity. The baseline's real in-memory SQLite tests do not prove Android Keystore,
SQLCipher JNI linkage or encrypted-file migration. Previous emulator evidence is
useful historical evidence, with the scope explicitly limited to that build/device.

### Future migration acceptance

Do not change schema in this audit. Before any extension migration: preserve v1/v2
fixtures and real encrypted copies, establish backup/recovery, specify one version
contract, test either runtime creating/upgrading first, test simultaneous/failed
openers, reject unknown future versions safely, verify all raw content/events remain,
and prove old/new native capture paths with compatible supported versions. Validate
foreign keys and derived-index rebuild separately. Do not copy a live encrypted DB
without snapshot/WAL coordination, or treat a device-wrapped key as portable backup.

## 5. Conflicts between existing contract and extension

| Existing vision/behavior | Proposed extension | Safe recommendation, awaiting decision |
|---|---|---|
| Master 1.2: intention manager; 6.4/10: semantics Later; 6.7: semantics in Pro | Private memory + intentions; EmbeddingGemma 2 text/audio required P0 | Explicitly approve scope/priority change in a future ADR. Keep the promise loop and make semantic memory mandatory for the extension release; no silent monetization gate |
| Every capture gets Tonight and current progress/aging semantics | Neutral text/audio thoughts; only selected reminder behavior | Distinct memory records linked to existing intentions; no forced alarm, XP or retirement for an ordinary memory |
| ADR-008 automatically writes categories/deadlines; guard is weaker than its comments | Suggestions labeled/reviewable; no silent filing/changed decisions | Retain current behavior until reviewed; require explicit policy/provenance for future memory suggestions and user-selected reminder protection |
| ADR-014 retires open/snoozed promises after 30 days | Persistent reflection/history and manual memory archive | Preserve retention of source memories; do not apply task aging to the memory library. Decide treatment of linked retired promises explicitly |
| Existing “append-only” log stores event summaries, not old source content | Historic beliefs/decisions and source originals remain accessible | Add version/relation concepts; do not claim current events provide content-version history |
| Master allows later opt-in notification listener/cloud/E2EE sync | No listener/surveillance/cloud services in this extension's V1 | Keep excluded; no new permissions based on the older future roadmap |
| Iteration 9 tunes to postponed content/conversations, not household errands | All life areas represented | Expand optional grouping/copy with approval; avoid mandatory taxonomy or replacing existing categories without migration |
| Master selected Rive/ML Kit/freezed/plugins; later ADRs implemented Flutter particles/rules/handwritten entities/native bridges | Preserve what works | Audit actual code/ADRs, not stale stack tables; no dependency restoration merely to match superseded prose |
| “Nothing leaves device,” plaintext share export and default backup | Explicit local-only data, user-controlled transfer and protected attachments | Distinguish app upload, OS backup and user-mediated transfer; define strict backup rules and portable export security |
| Proposal 6.2 lists TTS in P1; FR-19 labels P2 | Same optional voice feature | Decide delivery order; keep opt-in and offline validation either way |
| Proposal's sequence puts the model phase after foundational schema/UI | Required model has concrete artifact/runtime questions now | Move a **mandatory compatibility/quality/device POC** ahead of broad schema/UI work; production integration remains P0. This changes experiment order, not core scope |

No conflict was resolved by editing either PRD in this audit.

## 6. Dependencies, network and upload surfaces

Actual direct locked app packages: Riverpod **2.6.1**, go_router **14.8.1**, Drift
**2.34.3**, path_provider **2.1.6**, crypto **3.0.7**, sqlite3 **3.5.2**, Cupertino
icons **1.0.9**, plus Flutter. Native dependencies include SQLCipher **4.6.1** and
AndroidX SQLite **2.4.0**. Codegen/test tools include drift_dev **2.34.5**,
build_runner **2.15.1**, flutter_lints **6.0.0** and fake_async **1.3.3**. JNI
**1.0.3** / jni_flutter **1.0.2** arrive transitively through platform integration.
No app ML/ASR/recording/TTS/cloud SDK is configured.

| Surface | Evidence / what can cross a network or leave app storage |
|---|---|
| App-owned runtime code | Searches and traced paths found no `HttpClient`, Socket/WebSocket, HTTP/Dio, image-network load, remote inference, telemetry SDK, remote model setup or content uploader. This is source inspection, not exhaustive binary/transitive execution proof |
| Android release APK | `aapt dump permissions` confirms no `INTERNET` or `ACCESS_NETWORK_STATE`; includes exact-alarm, notifications, boot, biometric and AndroidX dynamic-receiver permission. No microphone, listener, usage, location, contact, accessibility or overlay permission |
| Debug/profile | Their source manifests add `INTERNET` for Flutter tooling; debug APK inspection confirms it. “No INTERNET permission” must be qualified by build mode |
| OS backup | `allowBackup`, `fullBackupContent` and `dataExtractionRules` are absent. Android documents backup enabled by default and inclusion of app files/shared preferences; its system can upload independently of Cya!'s own network permission. Actual device backup enablement/transfer has not been observed. Define cloud/D2D exclusions, key restore policy and tests. [Android backup documentation](https://developer.android.com/identity/data/autobackup) |
| File export | `DocumentShare` writes plaintext JSON under `cache/exports`, clears prior export files on the next export, and grants one content URI to a chooser-selected receiver. Drive/email/another receiver may upload it. Cya! does not choose or upload, but cannot promise the selected destination stays local |
| Source/draft handoff | `ACTION_VIEW` opens an external URI; `ACTION_SEND` passes user draft text to the source package/chooser. Browser or destination app may use network. No autonomous send; deep-link fallback does not guarantee draft insertion into a particular conversation |
| Keyboard/process-text | External input methods and selected text handlers are not audited dependencies; dictation cannot be called verified-offline Cya! ASR |
| Developer/build tooling | Pub/Maven/Gradle repositories, Flutter artifacts and sqlite3 build hooks can fetch binaries. `http_multi_server` and `web_socket_channel` appear in the dependency graph for tooling/transitive uses; presence alone is not a runtime upload finding. Build-hook/native dependency supply chain still needs pinned checksums/licenses |
| iOS/macOS/desktop/web | Android permission evidence does not constrain other hosts. macOS debug entitlements allow network server behavior; no app network-client code found. Cross-platform missing-channel fallbacks and `dart:io` database imports make scaffold presence insufficient to claim supported secure/offline web or desktop behavior |

**Verification limits:** no packet capture, DNS/socket instrumentation, transitive
binary security audit, dependency CVE audit, external-app privacy audit or physical
backup test occurred. Strict offline release acceptance must exercise a fresh install,
local model import, all capture/retrieval/data flows and missing-model recovery in
airplane mode, with observation that personal content is never sent to an app-owned
network path. A release manifest is strong evidence, not proof about OS or other apps.

## 7. Adding text/audio memory without duplicating promises

### Recommended domain direction — conceptual, not a schema change

Keep `Intention` as the commitment and reminder model. Introduce a distinct **Memory**
for material that is not a commitment, linked explicitly to an existing intention
when appropriate. Reuse the encrypted store, DI/repository patterns, clock/result
handling, native capture infrastructure, search coordination, source attribution and
visual shell. A memory library must not become another task repository/scheduler.

The alternative is a generalized capture-kind field in `intentions`. It looks smaller
but requires changing every pending/Today/retirement/progress/digest/native query,
text-only invariant and notification assumption. Without those changes, recording an
idea creates a promise, alarm, XP and future auto-archive. A separate memory entity
with a unified read/search projection is safer initially. Confirm this choice before
writing a v3 migration; it is not permission to clone old promise text into a second
library table.

Use typed source references so a memory id and intention id cannot collide. Existing
promise content remains authoritative for existing promises. A unified Memory screen
can include referenced promises without duplicating their text. If one thought leads
to one or several commitments, create explicit source relations and commitment wording,
not a second task engine. Decide snapshot-versus-reference behavior on promotion so
future promise edits cannot silently rewrite the retained source memory.

Concepts needing a reviewed contract, with no illustrative SQL prescribed here:

- Memory identity, creation/archive/deletion state, optional title/language/context,
  immutable original payload and explicit user edits/revisions. Never invent a
  transcript to satisfy the old non-null `raw_content` column for an audio memory.
- Managed attachment identity, original filename/type, relative private-storage
  location, byte length/checksum, duration/codec and readiness/integrity state.
- Content revisions and typed relations: branch/source, related, supports,
  contradicts, updates/supersedes and belongs-to; source segment/time anchors;
  current-view designation remains an explicit user choice.
- Derived transcripts with model/language/provenance/corrections; derived embedding
  segments with source/revision hash, model artifact/runtime/preprocessing/prompt
  fingerprint, dimensions/normalization and time/character spans.
- Durable bounded processing jobs with lease/retry/cancel/pause/status/error,
  source-version preconditions and idempotent result commit. A deleted/edited source
  must reject stale results and cannot be resurrected by a late worker.

### Durable audio and privacy

Record only after an explicit user gesture and microphone grant. Prefer a native
foreground capture activity for the initial short-recording path, preserving the
engine-free design. Recording is continuous file I/O; the promise's “single insert”
budget means no inference/enrichment or redundant writes at confirmation, not that
audio can magically become one database insert. Background recording/foreground
service behavior, interruption, lock-screen policy and Android-version requirements
need their own approved design if offered.

Managed app-private audio files referenced by DB metadata are preferable to large
SQLite BLOBs for recording/playback/streaming. SQLCipher does **not** encrypt files
outside the DB. Evaluate authenticated encrypted recording segments/per-file keys,
temporary-file policy and playback decryption cost; keep unique nonces and explicit
key lifecycle. Do not accumulate unencrypted microphone buffers or full recordings
in share/cache directories. Measure encryption overhead rather than remove protection
to make a benchmark pass.

Database transactions cannot atomically commit filesystem bytes. Use an explicit
staging/readiness/recovery protocol: flush durable source bytes, verify final file,
commit attachment/memory metadata and only then confirm success; recover interrupted
stages and orphans on restart. Test process death at each step. Low storage, revoked
permission, microphone contention, calls, background transitions and corrupt/missing
attachments must produce useful states without losing earlier confirmed recordings.

For storage planning only, mono PCM16 at 16 kHz is **32,000 bytes/s**, about **1.92 MB
per minute**; a hypothetical 64 kbit/s recording is about **0.48 MB/minute**. Neither
format/bitrate is selected yet. Preserve original audio; derive bounded decoded input
for embeddings/ASR. Playback and manual date/metadata access must work without a model.

### UI and focus reuse

Keep the current concise shell. Evolve Home into Today/Focus and reuse capture entry
points; add a memory browse/search destination deliberately rather than seven bottom
tabs. Garden remains progress over commitments, not a surrogate knowledge graph.
Explore initially means related/source/branch lists with back navigation. Recording
and keyboard capture modes must remain obvious and support denied permissions.

An explicit focus session stores the user's selected intention or free-text priority,
start/end and optional timer. It does not infer that the user worked. After durable
capture, read that chosen priority and display a dismissible confirmation/reminder;
never delay save waiting on the focus UI or model. A focus-return banner needs its
own non-escalating policy, separate from overdue-promise notifications. Changing,
stopping or ignoring priority must stay possible. Projects/topics are optional links,
never required capture fields.

## 8. Required EmbeddingGemma 2: compatibility and implementation strategy

Supporting primary-source research is in
[`Cya_Model_Feasibility_Research.md`](Cya_Model_Feasibility_Research.md). The facts below
were verified against current official documentation, publisher model metadata,
Google Maven metadata/POM and tagged runtime source. No artifact bytes were downloaded
or independently hashed, no Android model harness compiled, and no phone measurement
was made. Compatibility status must retain those limits.

### Confirmed modalities versus available deployment artifacts

The second-generation model card describes a shared **768-dimensional** embedding
space for text/code, audio, images and video; modular configurations are roughly
270M text, 440M text/vision, 570M text/audio and 740M full. MRL dimensions include
512/256/128; truncate and renormalize consistently. This is an embedding model, not
transcription or a prose-generating assistant. “Over 100 languages” does not certify
Bangla/Banglish retrieval quality. [EmbeddingGemma 2 model card](https://ai.google.dev/gemma/docs/embeddinggemma/model_card_2?hl=en)

The official Python tutorial demonstrates raw audio embedding and comparison with
text descriptions without speech recognition, plus image/video processing. That
establishes family capability, not Android codec/streaming support. It is a proposed
correctness reference only; do not copy tutorial URL-fetching helpers into the app.
[Official multimodal tutorial](https://ai.google.dev/gemma/docs/embeddinggemma/multimodal-embeddinggemma-with-sentence-transformers)

| Publisher repository | Generic CPU/GPU file / pinned revision | Published bytes | Role |
|---|---|---:|---|
| `litert-community/embeddinggemma-2-text-270m-litert-lm` | `embeddinggemma-2-text-270m.litertlm`; `9be6e8b90982095dc05c2bd162e4b954ee4dbac7` | 164,626,432 | Text comparison/optimization experiment; **cannot** satisfy required audio |
| `litert-community/embeddinggemma-2-text-vision-440m-litert-lm` | `embeddinggemma-2-text-vision-440m.litertlm`; `e301f74d5551b0c2641bd5cb4652a76239d5c5f8` | 387,710,976 | Staged vision experiment; not an audio replacement |
| `litert-community/embeddinggemma-2-740m-litert-lm` | `embeddinggemma-2-740m.litertlm`; `24d962e906c7d332c6428e71c9676855024569e2` | **484,622,336** | First required text+audio candidate, vision inactive and modular allocation measured |

The multimodal file's published LFS SHA-256 is
`e7a8a2204b91e0f96e92960e84a09a89212e1633dcb7575a9bf3378b4df77f4c`.
Verify actual imported bytes before use. Other hashes and base-checkpoint revision
are in supporting research. The base `google/embeddinggemma-2` safetensors checkpoint
is not a directly interchangeable `.litertlm` bundle. No separate generic 570M
text/audio bundle was established in the reviewed official guide. [Publisher artifact metadata](https://huggingface.co/api/models/litert-community/embeddinggemma-2-740m-litert-lm?blobs=true)

The full bundle advertises on-demand loading, mixed QAT audio quantization, streaming
and an audio soft-token signature of 12; that number is **not** a demonstrated
seconds limit. Its S26 Ultra benchmark reports a 10-second audio workload at about
305 ms CPU with 465 MB CPU memory on a second load, excluding accelerator allocation.
These are publisher results for another phone, not A52 results or Cya! measurements.
No A52-specific compiled NPU artifact was identified among the listed newer
Qualcomm targets. Start with the generic CPU bundle; GPU is a measured alternative.
[Full artifact card](https://huggingface.co/litert-community/embeddinggemma-2-740m-litert-lm)

### Recommended first runtime and known compatibility blockers

Use **direct Kotlin LiteRT-LM `com.google.ai.edge.litertlm:litertlm-android:0.18.0`**
and its tagged `EmbeddingEngine` as the first isolated compatibility POC. Version
0.18.0 announces the embedding APIs and is published to Google Maven. This follows
the app's existing native integration style, without assuming an older Flutter
plugin exposes direct audio embeddings. No dependency is added during this audit.
[Release notes](https://github.com/google-ai-edge/LiteRT-LM/releases/tag/v0.18.0),
[tagged Kotlin implementation](https://raw.githubusercontent.com/google-ai-edge/LiteRT-LM/v0.18.0/kotlin/java/com/google/ai/edge/litertlm/EmbeddingEngine.kt)

MediaPipe UniversalEmbedder documents text/audio input, but its
`tasks-retrieval:1.1.1` POM resolves `litertlm-android:0.17.0-alpha1`, while the new
embedding release is 0.18.0. This is a version-pair risk, **not a proven failure**.
Do not use `latest.release` or force an override without compile/runtime tests.
Evaluate the wrapper after verifying its resolved dependency graph. [Android guide](https://developers.google.com/edge/mediapipe/solutions/retrieval/universal_embedder/android),
[exact POM](https://dl.google.com/dl/android/maven2/com/google/mediapipe/tasks-retrieval/1.1.1/tasks-retrieval-1.1.1.pom)

| Quantified/identified blocker | What the POC must settle |
|---|---|
| Generic multimodal artifact is **484.6 MB decimal / about 462.2 MiB**; no verified separate 570M mobile bundle | Actual active encoder allocations, install/rollback disk cost and supported quantized configuration; a text-only success does not close audio |
| Maven versions **1.1.1 → 0.17.0-alpha1** versus direct embedding API **0.18.0** | Pin AAR/transitives; compile a release harness; inspect min API, ABIs, native libraries, 16 KB page-size compatibility and actual target-driver support |
| Two documented text prompt conventions differ | Model card gives query `task: search result \| query:` and document `title: none \| text:`; runtime guide gives query `task: search query \| text:` and document `task: search result \| text:`. Test artifact/runtime formatting against reference and held-out ranking; prevent double prefixes |
| Android WAV byte input example versus MediaPipe segmented `AudioData`; exported streaming signature narrower than full context prose | Confirm codec, downmix/resample, duration/overlap, streaming and pooling semantics using known local fixtures; arbitrary AAC/M4A support is not established |
| Model card warns against float16 while generic runtime menus list it | Use a validated precision/backend for the pinned artifact; reject NaN/Inf/quality regressions, do not reinterpret a generic option as model safety |
| **Zero** Galaxy A52 model runs / quality samples / thermal runs in this audit | Do not invent failing or passing device numbers. Named-device benchmark and explicit budgets remain an evidence gate |

Prompt/audio API evidence: [LiteRT-LM embedding guide](https://developers.google.com/edge/litert-lm/embedding_models).

### License and installation

Base and reviewed LiteRT artifact metadata declare **Apache-2.0**; the generic
UniversalEmbedder page refers to a “Gemma license,” and the model card mentions a
use-policy obligation. Resolve the exact artifact's applicable terms/notices before
redistributing. The inspected file listings did not provide a standalone license/
notice file to verify. Preserve publisher metadata and required notices, inventory
runtime/transitive licenses separately, and do not assume original EmbeddingGemma
terms apply unchanged. No redistribution/legal approval is claimed by this audit.
[Model metadata](https://huggingface.co/api/models/google/embeddinggemma-2),
[official Apache text](https://ai.google.dev/gemma/apache_2),
[generic task overview](https://developers.google.com/edge/mediapipe/solutions/retrieval/universal_embedder)

Prefer an explicit local Storage Access Framework import of the pinned model into
app-private managed storage; no silent download or remote inference URL. Validate
size/hash/fingerprint/capabilities, complete installation atomically, expose status,
version, pause/resume, remove/reindex and rollback. Keep installation separate from
personal content. Bundling is an alternative only after measuring distribution and
installation size. A staging-plus-existing rollback copy needs roughly **969 MB**
for two full bundles before recordings/indexes; external source/other versions can
increase that. Model files are public weights, while vectors/audio/jobs may contain
personal information and need the private-store/encryption policy.

### Production integration after the POC

Expose a small semantic-memory interface: request indexing, query related/source
results, observe status, pause/cancel/rebuild. Keep exact runtime input/output and
codec details inside a native adapter. Add a distinct asynchronous bridge/worker
instead of blocking the existing reminders/key/capture channel. Initialize only for
explicit semantic search or scheduled post-save work, never app/capture startup.

One bounded worker owns the model; cap threads/batches and prioritize foreground
capture. Measure whether an app-private separate inference process is needed so model
OOM/restarts cannot kill native capture in the main process. That decision should
follow measured allocation/lifecycle cost, not an unmeasured process rewrite. Keep
ASR out of the same peak-memory window. No existing durable background-job module
exists to reuse unchanged; introduce the minimum reviewed scheduler, not an online
service or continuous model loop.

Store vector provenance with exact source revision/hash, segment, artifact SHA,
runtime/backend where material, task/prompt/preprocessing versions, dimension and
normalization. Do not mix text-only/full/quantized vectors under one index merely
because they have the same dimensions. Validate cross-artifact parity or rebuild.
Use cosine via normalized vectors/inner product with known test pairs. Start with
an exact-search oracle to measure approximate-index recall and real cost. Persist
derived vectors privately, rebuildably, without native capture indexing triggers or
new mandatory SQLite extensions. Select a more complex index only from scale results.

## 9. Separate offline transcription feasibility

Audio capture, direct audio embedding, ASR and optional TTS are independent features.
**Transcription is P1; it cannot gate required P0 direct-audio semantic retrieval.**
No existing Cya! path provides speech transcription. Do not use platform dictation or
`SpeechRecognizer` as evidence of strict offline support. A readable transcript is
a derivative, with original audio retained, language/model/version/status and user
corrections recorded separately. Translation or Latin-script transliteration must
not be silently substituted for transcription.

| Candidate | Evidence and experiment |
|---|---|
| `whisper.cpp` with multilingual Whisper tiny/base/small | Maintainer project supports Android/native CPU/quantization; Whisper tokenizer includes Bengali `bn` and English `en`. Use multilingual weights, **not `.en` variants**. Language labels do not prove code-switch accuracy. Whisper code/weights and whisper.cpp have MIT licensing; retain exact model/runtime provenance. [Whisper](https://github.com/openai/whisper), [language map](https://github.com/openai/whisper/blob/main/whisper/tokenizer.py), [whisper.cpp](https://github.com/ggml-org/whisper.cpp) |
| `sherpa-onnx` with a validated multilingual Whisper export | Local Android/Flutter integrations, CPU/INT8 possibilities, runtime Apache-2.0; exported model license/provenance and output parity require separate verification. Its bindings may simplify integration but do not establish Bangla/Banglish quality. [Maintainer project](https://github.com/k2-fsa/sherpa-onnx), [Whisper integration](https://k2-fsa.github.io/sherpa/onnx/pretrained_models/whisper/index.html) |

The whisper.cpp project lists approximate tiny/base/small disk footprints of
75/142/466 MiB and memory figures 273/388/852 MB. These are **general project values**,
not Cya!/A52 measurements, final APK impact or concurrent EmbeddingGemma budgets.
Measure one model at a time; start tiny/base then small if quality warrants it;
compare supported quantized versions with multilingual quality held constant.

Build a consented/synthetic, manually transcribed local corpus with at least 30 clips
per language/noise cell: Bangla, English, code-switched speech × quiet/noisy = **180
clips minimum**, multiple speakers, 5–120 seconds plus interruption/long samples.
Banglish means both Latin-script typed Bangla and spoken Bangla-English switching;
define expected transcript script rather than assume these are the same task.
Measure raw and normalized WER, Bangla CER, switch-boundary accuracy, preserved
names/numbers/negations, dropped-language spans and hallucinations on silence/noise.
Report per-stratum results, RTF, cold/warm latency, RAM, energy and sustained thermal
cost. Proposed review gates: RTF <=1 for background short notes; English WER <=20%,
Bangla WER <=30%/CER <=15%, code-switch WER <=35%, and no fabricated speech on silence
fixtures. These are starting decision thresholds, **not observed or approved claims**.

If quality or resources fail, quantify each failure, try supported local smaller/
quantized/runtime alternatives and retain manual text with original audio. Never send
recordings to a remote API. ASR failure does not justify dropping P0 direct audio
retrieval. TTS later requires a confirmed local installed voice and explicit activation;
no inference model is necessary to speak a user-selected fixed reminder.

## 10. Mandatory POC and concrete semantic-memory benchmark plan

This is a plan for experiments **after approval**, not a speculative implementation
created during this audit. It must precede broad migrations/refactors. Its purpose is
to select a viable implementation of the required capability, not vote on whether
semantic/multimodal memory belongs in Cya!.

### A. Compatibility and correctness experiment

1. Inventory the physical Galaxy A52 4G (8 GB/128 GB): exact model/SoC, actual RAM
   headroom, OS/API/security patch, ABI/driver, storage, battery condition and thermal
   baseline. Record a lower-resource Android profile too. Emulation can check API
   behavior, but cannot stand in for phone battery, GPU, microphone or thermals.
2. Pin the full generic bundle/revision/hash above, LiteRT-LM 0.18.0, resolved Maven
   graph, Python reference environment, build flags and corpus seed. Inspect AAR ABI/
   minimum API/native library packaging and any sqlite/JNI conflicts. Record exact
   bytes on disk rather than call a model “small.”
3. In an isolated release harness, load CPU, embed text and **original audio directly**,
   compare selected GPU variant if supported, explicitly disable vision and measure
   allocations. Confirm vectors have expected length, finite values, correct norm and
   reproducible rankings. Verify query/document/similarity task formatting is applied
   exactly once under the chosen policy. Compare conflicting official conventions.
4. Establish local Python FP32/BF16 reference where supported, then compare the Android
   quantized candidate. Compare rankings and output drift, not only identical shape.
   Test supported text signatures and clip durations/streamed segments, sample-rate/
   channel conversion and pooling; preserve source and segment timestamps.
5. Execute text→text, text→audio **with no transcript anywhere in the candidate index**,
   and memory→related-memory paths. A transcript-derived vector cannot pass the
   direct-audio acceptance test. All requests/results remain local.

### B. Retrieval corpus, leakage controls and metrics

| Element | Concrete design |
|---|---|
| Text corpus | At least **600** records: 200 each English, Bangla and Banglish/mixed-script; short/long thoughts, academic/work/life topics, names/dates/negations and revisions |
| Audio corpus | At least **180** original clips: 60 per speech stratum, balanced quiet/noisy, >=4 speakers, 5/15/30/120-second bands; separate >5-minute/streaming-limit stress fixtures |
| Queries | At least **300** human-judged queries, 100 per query-language stratum; literal/paraphrase/no-word-overlap, cross-language, negative/no-relevant-item cases; >=20 judged query/source pairs in each applicable language-pair cell |
| Relatedness | At least **90** seed memories, 30 per language, with graded related/hard-negative labels; test text/audio candidate neighbors, accepted/dismissed suggestion state and no automatic merge |
| Direct-audio isolation | Opaque recording ids; no transcript, descriptive filename/title/tag or associated copied text in the audio candidate index. Human reference transcripts stay outside model inputs/indexes. Rank raw-audio vectors only; show originals/timestamps |
| Hard negatives | Near-same words with different date/person/negation; same topic but opposite decision; similar-sounding unrelated speech; silence/music/noise; Bangla vowel/minimal pairs and Banglish spelling variants |
| Evaluation split | Separate tuning and held-out topics/speakers; freeze preprocessing/prompts/segment policy before test; no tuning on the final questions |
| Metrics | Recall@1/5/10, MRR and nDCG@5, judged precision@5 for relatedness; macro averages **and each language/noise/duration/language-pair stratum**; false positives on no-match/hard-negative queries |
| Comparators | Current FTS5 baseline, text-only model as diagnostic reference, full 768d exact-search oracle, validated reduced dimensions and any ANN candidate. Transcript retrieval may be a separate labeled comparison, never credited to direct audio |

Proposed starting review targets: text Recall@5 >=0.80, direct audio Recall@5 >=0.70,
relatedness precision@5 >=0.70, and no core language stratum below 0.60 Recall@5.
Agree thresholds/corpus relevance criteria before accepting results. Similarity scores
are not calibrated probabilities; use per-task validation, show suggestions and source
material, and avoid a fabricated answer when no useful match exists.

### C. Phone resource and responsiveness protocol

Run release builds at **1k, 10k and 100k indexed segments**, not just records (long
audio multiplies segments). Compare 768/512/256/128d with the same held-out evaluation
and renormalization. Dimension reduction lowers vector/search cost, not model-weight
RAM. At float32, 10k vectors alone are **30.72 MB at 768d**, **20.48 MB at 512d**,
**10.24 MB at 256d**; 100k costs ten times that, excluding index/metadata/encryption.

For capacity illustration only, 570M active parameters imply about 2.28 GB FP32 or
1.14 GB BF16 weights; 740M implies 2.96/1.48 GB. Uniform INT4 arithmetic would be
285/370 MB but does **not** describe a verified export. Actual mixed-quantized bundle
and measured mapped/allocated memory govern selection. Include Flutter, runtime,
activation/workspace, preprocessing, DB/index cache and GPU memory in the total.

Record app-only baseline, model cold/warm and first/second load separately. Measure
load, query embedding, audio embedding, decode/preprocess, vector search and final
source rendering separately and end-to-end. At least **30 cold** and **100 warm**
samples per important configuration; report median/p90/p95/max and confidence bounds.
Use the same phone/OS/build, database, audio duration, dimensions/backend/threads,
ambient temperature, charge range and connectivity. Do not drop cold failures.

| Measure | Proposed acceptance/review gate — not an existing measurement |
|---|---|
| Capture | Preserve Master PRD median tap→saved **<2 s** (aim <1 s). Also propose p95 <2 s and <=10% regression under indexing; measure full open→durable confirmation, not only `capture_ms` before schedule/widget/dismiss |
| Startup/navigation | Preserve Master cold interactive <2 s and stable 60 FPS goal; no model initialization in launch/capture traces. Historical emulator timeouts do not meet this phone criterion |
| Search | At 10k segments, warm end-to-end semantic query p95 <=1 s; cold load/query separately visible with cancel/progress; sources stay browsable and keyword search available |
| Audio indexing | 30-second audio RTF <=1 initially; background throughput and long/overlap/streaming quality reported; save completion is independent |
| Memory | Propose incremental model PSS <=1 GB initially; record peak app+worker PSS/RSS/native/GPU, free system RAM, allocation failures/LMK and reclamation after close. Installed 8 GB is not process budget |
| Thermal/energy | Paired model-idle versus index runs for **20–30 minutes**, >=3 repetitions, randomized order and fixed brightness; record thermal status/temperature, throttle onset, throughput decay, CPU/GPU utilization and energy per audio-minute/1k text records where counters support it |
| Sustained acceptance | No severe thermal status, OOM/process kills, ongoing idle inference, sustained foreground jank or missed capture/reminder while indexing. Report battery/energy deltas with method/uncertainty; no invented battery-life promise |
| Reliability | Process death, pause/resume/cancel, low storage, bad/missing/wrong-version model, recording interruption, source edit/delete during jobs, index corruption/rebuild and simultaneous native/Flutter operations |
| Offline/privacy | Fresh install + local model import, airplane mode, blocked network observation; no remote URLs/content upload; retained capture/navigation/keyword failure fallback and successful offline semantics |

Measure SQLCipher/native↔Dart coexistence and actual reminder firing while the worker
is busy. Add real on-device assertions; the current 183 tests mock native channels and
cannot substitute. Record model/runtime/OS/fixture hashes and raw local metrics for
reproducibility. Keep personally identifying corpus content out of published logs.

### D. Optimization and explicit decision protocol

If the first candidate exceeds a budget, report **measured** load/latency/RAM/quality/
energy and failing fixtures. Try documented modular/lazy loading, bounded text/audio
signatures, chunk overlap/pooling, batch/thread caps, CPU/GPU selection, validated
mixed quantization, worker lifecycle/reclamation and charging/user-approved background
backlog policies. Test whether a supported separate text+audio export can be produced;
do not invent one or replace the model silently. Evaluate every optimization against
the multilingual/direct-audio quality set. Lower dimensions do not solve encoder RAM.

If no compatible configuration meets agreed budgets, present measured alternatives
and ask for an explicit product decision on configuration, supported devices, timing
or model substitution. **EmbeddingGemma 2 and semantic memory remain required.**
Fallback-only release, an ASR workaround masquerading as raw-audio embeddings, or
calling the model optional does not satisfy the proposal.

### E. Staged image/video support

After required text+audio retrieval works, preserve original media as protected
attachments and add validated vision input. Benchmark the exported 70/140 image-token
signatures, deterministic resize/crop, text→image and cross-modal relatedness. For
video, test 0.2/1 fps sampling and bounded overlapping clips with timestamped keyframes
and audio. Determine whether the exact Android API provides composed video embeddings
or Cya! must manage frame/audio segments; Python video support is not proof of Android
video-container support. Evaluate temporal-event retrieval and visible-only versus
audio-only facts separately. Return playable original time ranges and label
modality/source evidence. Loading vision must not regress P0 capture/text/audio or
require loading unused encoders. Graph canvas is independent of this model rollout.

## 11. Recommended phases and acceptance gates

The concrete proposed plan is
[`../plans/product-direction-staged-plan.md`](../plans/product-direction-staged-plan.md).
Phase names below are new extension work, not renumbering historical iterations.

| Phase | Scope | Testable exit criteria |
|---|---|---|
| A — contract reconciliation + mandatory model POC | Approve vision conflicts, exact artifact/runtime/local-install and device/corpus budgets; run section 10 experiments in an isolated harness after approval | Pinned artifacts/transitives; actual A52 direct text+audio and relatedness results without transcripts; per-language/resource/thermal evidence, or quantified blocker/options for explicit decision. No broad schema work based on model-family prose alone |
| B — protect existing data/capture | Resolve verified/static reliability risks, specify backup/privacy and coordinated v3 design; add actual native regression seams | Existing 183 tests retained; failure-closed key handling; atomic/recoverable version/migration and source-save semantics; legacy/native/Flutter opener-order fixtures; native UI invalidation; protected custom reminders and no network on capture |
| C — local memory/audio/focus foundation | Neutral text/original audio, local playback, multilingual lexical browse/edit/archive/delete, optional intention links and focus-return UX | Save/restart/readback without model; interrupted/denied/low-space recording recovery; no automatic promise/alarm/XP/retirement for memory; accurate agreed lexical corpus; focus save-before-reminder and change/dismiss; existing promise surfaces still work |
| D — production semantic memory, required P0 | Proven native runtime adapter, protected vector/index/job state, incremental/rebuild/delete handling, semantic results and related suggestions with accept/dismiss | Offline text→text and no-transcript text→audio pass agreed held-out multilingual gates; source-version-consistent results; model failure/cancel/pause safe; release A52 resource/capture gates pass; no vectors resurrected after deletion |
| E — connected history + safe portable data, P0 | Explicit relations/branches, current versus historic decisions, versioned attachment-aware backup/import and protected export | Branch leaves source unchanged; both superseded/current source accessible; accepted/dismissed provenance; export/import on clean install preserves counts/content/events/files/checksums; corrupt/traversal/oversized/future-version import causes zero live-data change; merge/replace explicit and recoverable |
| F — staged modalities, ASR, graph and polish | P1 image/video and evaluated local ASR; bounded graph/topic view; opt-in offline TTS at agreed P1/P2; accessibility/low-resource work | Separate vision/video/time-range retrieval evidence; ASR language/resource gates; accessible list/tree fallback, large corpus frame tests and no P0 regression; no cloud substitution |

Phases C/D/E are internal milestones. The product-direction release is **not complete
before required semantic text+audio memory and the remaining P0 gates pass**. Some
independent design/fixture work can overlap after approval, but benchmarks must inform
runtime/index/attachment contracts before an irreversible migration design is fixed.
No estimates here imply physical-device access or a promised completion date.

## 12. Unresolved decisions, safe recommendations and review boundary

| Decision | Safe recommendation / evidence still needed |
|---|---|
| Memory versus generalized intention | Prefer distinct non-action memory linked to retained intention, unified read/search projection; approve cardinality/promotion/source-edit rules before schema |
| Definition of original / edit history | Preserve exact source separately from edited revision; transcripts/embeddings/normalization are derivatives. Decide whether current capture trimming stays acceptable |
| Promise aging and archived recall | Retain existing commitment policy until approved; no memory aging by default; add explicit archive browsing and decide how archived memories participate in semantics |
| Focus return | User-selected priority only; confirm scope/session restoration/duration, non-escalating banner versus notification and cancel behavior; no work inference or blocking |
| Exact runtime/artifact | First experiment: pinned 0.18.0 Kotlin + full generic bundle, CPU, vision inactive. Resolve prompt/precision/wrapper/codec/ABI questions and measure real allocations before selecting production configuration |
| Target floor | Verify actual A52/API/SoC and a lower-resource profile; never claim “almost all devices.” Model budgets and multilingual relevance gates are proposed until agreed |
| Index design | Begin exact-search correctness oracle; measure scale/dimensions and choose persisted private index/ANN only if justified. No capture-side vector extension dependency |
| Recording/privacy | Explicit foreground recording first; app-private authenticated attachments; decide background capture limits, interruption, notification visibility and key/erase lifecycle |
| Export/import security | Prefer encrypted, versioned portable archive with independent password/key and integrity; local export may permit explicitly disclosed plaintext, but existing JSON is not secure backup. Never export device Keystore keys as portability shortcut |
| Import identity/merge | Preserve source/event identities through a defined mapping; existing integer ids are device-local. Validate typed references, attachments, versions, quotas and relative paths before staging; rekey restored data for destination; rebuild derived indexes |
| Backup policy | Explicitly prohibit unintended cloud backup of private DB/audio/vectors/keys and define local transfer separately. Test real OS/OEM behavior; no claim based solely on absence of INTERNET |
| Licenses/model distribution | Resolve conflicting generic wording against exact artifact notices and policies; preserve runtime/transitive attribution; no model weight download/redistribution occurred here |
| ASR/Banglish output | Define script/transliteration expectations and judge code-switched audio locally; separate ASR budget from required direct-audio index |
| iOS parity and releases | Android first; scope Swift/native key/capture/reminder implementation separately. Release still signs with debug key; shipping keystore and store-policy review remain outstanding |
| UI/readability | Keep Cya! identity and restrained navigation; test Bangla font fallback, long/mixed-script text, large accessibility scaling, screen reader, reduced motion and recording status on physical screens |

**Review deliverables:** this audit; the proposed staged plan; primary-source model
research; ignored command/probe evidence. No application code, schema, dependency or
existing product-document edits are part of this audit. Existing dirty relocation
changes were preserved. No model execution/device-performance result is claimed.

**Next action:** review these findings and approve/revise the staged plan. Broad
refactors, migrations, model/runtime integration and experimental harness
implementation remain stopped pending that approval.
# 2026-10-16 routine extension delta audit

The user-approved v2 extension adds P0 routine management/recovery and optional
daily/weekly reviews. The original audit and its baseline remain historical
evidence. Current focus_sessions/focus_events (schema6) track chosen priorities;
they are not recurring routines, step lists, occurrences or a day plan. The
intention/promise engine, reminder scheduling and weekly digest still exist and
must remain the sole promise engine. Do not present timers as routine completion.

| v2 requirement | Current coverage at extension receipt | Required addition |
|---|---|---|
| FR-10 adaptive day planning | Promise rescheduling + chosen focus; partial | Explicit selected routine occurrences/recovery |
| FR-11 routine management/recovery | Missing | Definition/version history, optional recurrence/window/steps, pause/reorder, Today selection, occurrence outcomes/reschedule/shorten |
| FR-12 daily/weekly review | Existing promise digest; partial | Routine outcomes + brief optional user note; explainable factual suggestions; manual changes only |
| FR-08/09 focus/capture return | Session history + save-first dismissible prompt | Keep separate from routines; do not infer work from elapsed time |
| FR-22 diagnostics | Model status/retry + developer measurement; partial | User-visible local storage/count/error view |

Data recommendation: additive shared tables for routine current state, immutable
routine revisions/events, explicitly selected dated occurrences/events and brief
dated review notes/revisions. Occurrences snapshot the exact routine version and
selected steps/window so later edits cannot rewrite past plans. Generate only
eligible suggestions for Today; persist occurrences solely when selected by the
user. A missed/day-expired plan stays recorded and never becomes an inferred
completion or punitive failure. Deferred occurrences retain original day/context
and explicit target day; paused definitions preserve all occurrences/history.
No routine alarm/model is added to native critical capture; time windows are
preferences, not a new exact-alarm guarantee. Existing promise reminders remain.

Local review computes descriptive counts from recorded events, labels selection
versus completion, distinguishes upcoming promises and unresolved selected
occurrences, and shows an evidence-based adjustment suggestion only when there
are enough explicit outcomes. No automatic schedule change or AI productivity
score. Use existing Riverpod/Drift, versioned export/import and both-writer
migration tests. All earlier source/privacy/offline constraints still apply.

