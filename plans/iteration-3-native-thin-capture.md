# Iteration 3 — The native-thin capture path (Phase 0's two-second spike)

- Implements PRD: §3.1 (< 2s capture), §3.2 (dumb synchronous capture), §5.2/§5.4 (native/Flutter
  boundary, native-thin capture), §6.1 (Share Sheet, zero-tap default), §7.2 (native writes match the
  Drift schema), §9.2 (performance budgets), §10 Phase 0 acceptance
- Depends on: `iteration-2-drift-data-foundation.md` (schema v1 + `docs/native_db_contract.md`)

## Requirement analysis

This is the product's reason to exist and the invariant most easily broken. The acceptance criterion
from §10 is precise: *a shared item becomes a saved, scheduled intention in < 2s on a cold process,
with no Flutter engine boot, and the capture time is logged.*

That rules out, on this path: the Flutter engine, `receive_sharing_intent` (which requires the
engine), any plugin, any network call, any inference, and any UI beyond a dismissal cue.

What it requires:
1. An exported, **translucent**, no-Flutter Kotlin `Activity` registered as a `text/plain` share
   target that finishes immediately.
2. A direct SQLite write into `cya.db` — the same file Drift opens — using the schema and encodings
   in `docs/native_db_contract.md`, with the row and its `captured` event in **one transaction**.
3. The zero-tap default reminder (`Tonight`), computed with the same rule as
   `ReminderPreset.tonight`.
4. Capture-time instrumentation, so the < 2s budget is a measured fact rather than a hope.

The reminder *firing* (AlarmManager → notification → one-tap resolution) is the next iteration; this
one stores `reminder_at` correctly and stops there, so the spike stays honest about what it proves.

## Approach / design

### Who creates the schema?
Either runtime may be the first to open the file (a share can arrive before the app is ever opened).
So the native side carries the **same DDL** as Drift's `onCreate` and sets `PRAGMA user_version = 1`.
Drift then sees a version-1 database and skips `onCreate`; native sees an existing file and skips its
own creation. The DDL lives in one Kotlin file, `CyaDatabaseContract.kt`, mirroring
`docs/native_db_contract.md` line for line — including the FTS5 table and its triggers, so search
stays correct no matter who created the file.

### The capture path, exactly
```
ACTION_SEND (text/plain)
  → CaptureActivity.onCreate
      t0 = SystemClock.elapsedRealtime()
      read EXTRA_TEXT / EXTRA_SUBJECT, resolve source app from referrer
      open cya.db  (create schema if absent)
      BEGIN; INSERT intentions; INSERT intention_events('captured'); COMMIT
      (reminder_at = tonight rule)
      log capture_ms into the event metadata + Logcat
  → Toast "Saved. I'll remember for you."  →  finish()
```
No layout is inflated (`Theme.Translucent.NoTitleBar`), no engine, no plugin, no coroutine framework —
`onCreate` does the work synchronously on a warm SQLite handle and returns.

### Source-app attribution
`referrer` (or `EXTRA_REFERRER` / calling package) → package name → app label via `PackageManager`.
Fall back to `"Shared"` when the sender is unknown. This is the `source_app` column the UI shows and
the future deep link keys off.

### Instrumentation (PRD §9.2, §11)
`capture_ms` (activity start → commit) is written into the `captured` event's JSON metadata and
emitted to Logcat as a single tagged line, so a scripted `adb` run can assert the budget. Because it
lives in the event log, the app can also report its own real capture-speed distribution later.

### What deliberately does *not* happen here
Refinement UI, category, deadline extraction, notification, alarm. Each is a later, asynchronous step
by design (§3.2). The "refine" affordance (which *does* boot Flutter) comes with the notification
work in iteration 4.

## Steps
1. `CyaDatabaseContract.kt` — DDL + column/status/event constants mirroring the Dart enums.
2. `CaptureWriter.kt` — open/create, one transaction, returns the new row id + elapsed ms.
3. `ReminderDefaults.kt` — the Tonight/Tomorrow/Weekend rules, ported from `ReminderPreset`.
4. `CaptureActivity.kt` + manifest entry (exported, translucent, `ACTION_SEND` `text/plain`).
5. Verify the Dart side reads native-written rows unchanged (open the same file, assert in-app).
6. Measure: `adb shell am start -W` with a share intent on a cold process, repeated, record medians.
7. Tests: a Kotlin-side unit test is overkill for a spike; instead assert the **contract** from Dart
   (schema v1 opens a native-created file without migrating) and measure on-device.
8. Update PRD §13.1/§13.3/§13.5 + BUILD_LOG.

## Acceptance criteria (PRD §10 Phase 0)
- [ ] Sharing text from another app saves an intention **without booting the Flutter engine**.
- [ ] Median tap → saved **< 2s** on a cold process (target < 1s), measured and recorded.
- [ ] The row is visible in the app with the right source app, content and `reminder_at` (Tonight),
      and it is searchable — proving the trigger-maintained FTS index works for native writes.
- [ ] The `captured` event exists with `capture_ms` metadata.
- [ ] A share into a **fresh install** (no app launch yet) creates the schema, and the Flutter app
      then opens that same file without running a migration.
- [ ] `flutter analyze` 0 · `flutter test` green · debug APK builds.

## Risks & mitigations
| Risk | Mitigation |
|---|---|
| Native DDL drifts from Drift's | One contract doc + one Kotlin constants file; a Dart test opens a native-shaped DB and asserts no migration runs. |
| WAL sidecar files confuse one runtime | Same journal mode on both; never copy the `.db` without its `-wal`/`-shm`. |
| Someone "improves" the path with a plugin or engine boot | The invariant is written in CLAUDE.md, the PRD and this plan; the acceptance test measures cold-process time, which an engine boot would blow. |
| Toast feels like nothing happened | Keep the toast, and let the (next iteration) notification confirm the reminder is scheduled. |
