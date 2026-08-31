# Iteration 4 — Closing the loop: alarms, notifications, escalation, one-tap resolution

- Implements PRD: §3.4 (close the loop), §5.6 (reminder/resurfacing engine, escalation, snooze
  limit, digest), §6.1 (return-to-source), §8.4 (one-tap resolution reachable from the notification),
  §9.2 (reminder fire reliability > 99%), §12 (OEM battery-optimization risk), §10 Phase 1
- Depends on: `iteration-2-drift-data-foundation.md`, `iteration-3-native-thin-capture.md`

## Requirement analysis

Capture without resurfacing is just another inbox (§3.4). This iteration is what makes Cya! a memory
product rather than a note app, and the PRD is unusually specific about it:

- Exact alarms via native `AlarmManager` (`setExactAndAllowWhileIdle`), Doze-resilient.
- An **escalation state machine**: quiet → banner → digest as a promise is re-snoozed.
- The **snooze limit** enforced in the domain layer (already built: `SnoozePolicy`).
- **One-tap resolution from the notification itself** — not "open the app, find it, tick it".
- Reliability is a hard number (>99%), and OEM battery optimization is the named risk.

The domain policy already exists and is tested; what is missing is everything that makes a reminder
actually arrive, and the two-way street between the notification and the store.

## Approach / design

### Where the scheduler lives
Native, next to the capture writer. The alarm must survive the app never being opened, and the
capture path already schedules the default reminder without Flutter. A Kotlin `ReminderScheduler`
owns: schedule(intentionId, atMillis), cancel(intentionId), and `rescheduleAll()` after boot.

Alarms carry only the intention id; the receiver reads current state from the shared database, so an
alarm can never fire with stale content.

### Firing
`ReminderReceiver` (BroadcastReceiver):
1. read the intention; if it is no longer pending, drop silently (resolved on another surface);
2. pick the channel from the escalation tier — the same rule as `SnoozePolicy.tierFor`:
   `snooze_count == 0` → quiet channel (low importance, no sound);
   `< 3` → banner channel (high importance, heads-up);
   `>= 3` → **no interruption**: it belongs to the digest;
3. post a notification with actions **Done** and **Snooze**, tapping the body deep-links into the
   promise detail screen;
4. write a `resurfaced` event with the tier in its metadata — reliability and escalation both become
   measurable from the log.

### One-tap resolution (the point)
`NotificationActionReceiver` writes `resolved` (or `snoozed` + a new alarm) **directly to SQLite**,
the same native-thin way capture does, then cancels the notification. Resolving from a notification
must not require the Flutter engine either — the reactive UI picks the change up the next time it
runs, because the store is the single source of truth (§3.3).

### Escalation, honestly
Tiers are already domain policy; this iteration only maps them to notification channels and respects
"digest" by *not* interrupting. The weekly digest itself (Sunday review) is scoped to its own
iteration — the escalation ladder's third rung must exist before the digest can be its home.

### Permissions and the reliability problem (§12)
- `POST_NOTIFICATIONS` (API 33+), requested in-app at a moment that explains why, not on first frame.
- `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`: reminders are the app's core function, so it qualifies —
  but the app must still detect `canScheduleExactAlarms() == false` and guide the user.
- `RECEIVE_BOOT_COMPLETED` + a boot receiver that reschedules from the database.
- A **reliability check on resume**: any pending promise whose `reminder_at` is in the past with no
  `resurfaced` event is a dropped alarm — surface a one-time, non-nagging prompt to exempt Cya! from
  battery optimization. This turns the §12 risk into something observed rather than assumed.

### Deep link
`cya://promise/<id>` → `RoutePaths.promiseDetail`, already a top-level go_router route outside the
shell. The notification's content intent starts `MainActivity` with that data URI.

## Steps
1. Kotlin: `ReminderScheduler`, `ReminderReceiver`, `NotificationActionReceiver`, `BootReceiver`,
   notification channels (quiet/banner), manifest entries and permissions.
2. `CaptureActivity` schedules the default alarm after its insert (still one insert + one schedule).
3. Dart: a `ReminderPort` platform channel for the app's own scheduling (capture sheet, reschedule,
   snooze from the detail screen) so both runtimes go through the same scheduler.
4. Dart: deep-link handling into promise detail; permission/exact-alarm guidance surface.
5. Dart: dropped-alarm detection on resume + the battery-optimization prompt.
6. Tests: escalation-tier mapping (pure, already partly covered), a dropped-alarm detector test, and
   an on-device run of fire → Done-from-notification → row resolved.
7. Update PRD §13.1/§13.3/§13.5 + BUILD_LOG.

## Acceptance criteria (PRD §10 Phase 1, §9.2)
- [ ] A captured promise fires its reminder at the scheduled minute, including from a cold process.
- [ ] **Done** from the notification resolves the promise in the store without opening the app; the
      Home ring and garden reflect it on next open.
- [ ] **Snooze** from the notification pushes the reminder and reschedules the alarm; the fourth
      snooze is refused by the same domain policy the UI uses.
- [ ] Escalation is visible: first fire is quiet, a re-snoozed promise arrives as a heads-up banner,
      and a promise past the snooze limit does not interrupt at all.
- [ ] Alarms survive a reboot.
- [ ] Every fire writes a `resurfaced` event, so fire reliability is measurable from the log.
- [ ] `flutter analyze` 0 · tests green · debug APK builds.

## Risks & mitigations
| Risk | Mitigation |
|---|---|
| OEM battery optimization silently drops alarms | Detect missed reminders from the event log and guide the exemption; measure reliability rather than assume it. |
| Exact-alarm permission revoked on Android 14+ | Detect `canScheduleExactAlarms()`, fall back to an inexact window, and tell the user plainly what changed. |
| Notification actions racing the app's own writes | Both write the same rows in the same transactional shape; the store is the arbiter, and the UI is reactive over it. |
| Escalation becoming nagging | The third tier is *quieter*, not louder: past the snooze limit Cya! stops interrupting and moves the promise to the digest. |
