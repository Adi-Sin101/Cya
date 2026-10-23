# Iteration 11 — offline memory foundation

15 October 2026. Typed-memory unit verified; overall Phase1 remains incomplete.
Implements approved extension FR capture, history,
retrieval and ADR-018. User instruction “start implementing the phases, go on”
approves proceeding with the proposed additive migration; do not ask again.

Deliver a tested vertical slice first: schema v3 neutral typed memories,
immutable revisions/events, durable semantic jobs, browsing/edit/archive/delete,
Unicode keyword fallback and user-chosen focus. Preserve promises and native
capture. Recording/attachments and relationships follow in small coordinated
migrations; do not pre-create untested speculative tables. Required semantic
integration follows the runtime compatibility proof, never on capture/save.

Acceptance: native-first and Dart-first v1/v2→v3 preserve all existing records;
native upgrades are atomic and reject future versions. No FTS in native DDL.
Text capture creates initial revision/event/job transactionally; edits preserve
originals. Archive/restore, explicit hard delete and retries retain invariants.
Bangla combining marks remain distinct in keyword search. Memory capture never
creates a promise, alarm, XP or aging job. UI exposes errors and unsaved content.
Capture finishes before any focus-return message. Existing tests, new regression
tests, analyzer and Android build pass. Audit every erase/export path for new data.

Do not install migrations over a physical phone's only data copy. Use fixtures and
emulator first; validate recovery before personal-data upgrade. No content upload,
network dependency/permission or model downloads in the application.

## Outcomes

- Delivered typed capture, literal Unicode keyword fallback, browse/history/edit,
  archive/restore and confirmed hard delete. Immutable source versions and
  semantic pending jobs commit with events. Focus priority and post-save
  dismissible return prompt work; full focus-session history remains later work.
- Shared schema3 creation/v1-v2upgrade in Kotlin/Drift; migrations propagate
  errors, roll back DDL/version together, verify columns and reject future versions.
  Existing promise IDs/content/reminders/events/preferences preserved in fixtures.
- Existing export now format2 including all memory revisions/events, still
  redacting PIN material; erase includes memories/cascading history/jobs.
- `flutter analyze --no-pub`: zero issues, exit0,17.8s.
- `flutter test --no-pub --reporter expanded`:203/203, exit0,71s.
  Added privacy integration separately:1/1, exit0,4s (204 total tests).
- `flutter build apk --debug --no-pub`:exit0,338.7s under concurrent build load.
  Emulator initially rejected version1 over installed4001; rebuilt with
  `--build-number=4002`, exit0,93.5s. No uninstall/data clear.
- Installed on API34 emulator. Native-first v3 open/capture succeeded
  `capture_ok id=5 capture_ms=1431` (cold/migration), subsequent capture
  `id=6 capture_ms=60`. MainActivity's debug launch timed out under load; no
  AndroidRuntime/Flutter error observed. UI unit tests are separate evidence.
- Existing release package was not debuggable, so attempted pre-upgrade private
  tar snapshot failed; no successful recovery backup is claimed. This was the
  development emulator, not a personal phone. Recovery-tested physical rollout
  remains outstanding. No release app run/airplane-mode claim for this unit.
- Required model SDK/pinned-artifact proof ran separately and succeeded for text
  and transcript-free raw audio; see compatibility report. Semantic app integration,
  audio capture/playback, import, links and complete multilingual/device acceptance
  are not delivered by this typed-memory unit; work continues under Iteration12.
