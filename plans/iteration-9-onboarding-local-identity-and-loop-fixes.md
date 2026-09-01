# Iteration 9 — Onboarding, local identity, and the loop fixes a real week demands

**Date:** 2026-09-01
**Branch:** `main`
**Derives from:** PRD §2.2 (target user), §1.2 (success definition), §3.4 (close the
loop), §3.5 (privacy-first), §5.6 (resurfacing/escalation), §5.7 (no backend in V1),
§6.6 (gamification), §8.1/§8.2 (design system + screens), §9.3 (privacy controls),
§12 (risks), §13.6 (open questions).

> This plan is the written output of a grilling session on 2026-09-01. Everything
> below marked settled was decided by the product owner in that session. It is
> recorded here because the decisions cost a long conversation and must survive a
> session restart.

## Positioning settled in this session

| Question | Settled answer | Consequence |
|---|---|---|
| Who is "everyone"? | **PRD §2.2 stands** — Gen Z living across many apps. "Everyone" is the ambition, not the V1 target. | Presets, categories and copy stay tuned to postponed *content and conversations*, not household errands. |
| What does "daily usable" claim? | **Trusted utility, not daily habit.** The user rarely opens the app; the job is that nothing is ever lost. | Retention mechanics that punish a quiet week are wrong by definition. See ADR-011. |
| Reliability floor | **Samsung + Poco (MIUI/HyperOS).** | Reminder arrival on those two devices is the real Phase 1 acceptance criterion — ahead of golden tests and frame profiling. |
| Build or freeze? | **Build now**, test in parallel. A release APK is already available. | Iteration 9 proceeds while device testing runs alongside. |

## Decisions taken here (ADR candidates — fold into PRD §13.3 on completion)

- **ADR-010 — Identity is local-only; there is no account.** Onboarding presents
  registration and login *as an experience* — create a profile (display name,
  avatar), then set a PIN or biometric unlock. It is backed entirely by the device:
  no server, no email, no network dependency, no first `http` package. Data stays in
  the existing Drift/SQLite store, encrypted at rest (SQLCipher, key held in the
  Android Keystore). This satisfies "proper onboarding, registration and login" and
  "all local, safe and private" simultaneously, and leaves §5.7 and §3.5 intact.
  Phase 3 E2EE sync layers on top without redesign: the passphrase derives keys, the
  server only ever holds ciphertext.
  *Rejected:* Supabase/Firebase accounts + hosted Postgres — contradicts the stated
  privacy requirement, breaks §5.7, and makes an outage or an expired token a barrier
  between the user and their own promises.
- **ADR-011 — The streak is replaced by a kept-rate.** `GardenProjection.streak`
  counts consecutive days with a resolution, so a user who captures on Monday,
  resolves everything Tuesday and has a calm Wednesday is shown a zero. A streak is a
  daily-habit mechanic and this product is a trusted utility. A kept-rate ("23 of 25
  promises kept") never resets, and is the metric §11 already names.
- **ADR-012 — Due reminders are grouped, not stacked.** Every zero-tap capture
  defaults to `ReminderPreset.tonight` (20:00), so a productive capture day produces
  N separate notifications at one instant — the capture path working well makes the
  resurface moment worse. Android notification groups (`setGroup` + a summary)
  collapse them into one while preserving per-promise Done/Snooze actions, which §3.4
  makes a V1 invariant. The default stays `tonight`; for the §2.2 user, tonight is
  genuinely when they deal with postponed content.
- **ADR-013 — Past the snooze limit, "Let it go" exists.** The fourth-snooze
  notification currently reads *"Finish it, or let it go"* and offers only **Done**.
  Add a **Let it go** action that archives from the shade, and stop `rescheduleAll()`
  re-arming digest-tier promises.
- **ADR-014 — Promises pending and untouched for 30 days auto-archive.** Announced in
  the weekly digest ("12 promises quietly retired — tap to bring any back"), fully
  reversible. Nothing currently expires, so the pending list grows monotonically and
  the digest reads the backlog back at the user — §12's failure mode arriving by
  design rather than by accident.
- **ADR-015 — Scheduled replies are a prefilled draft, never an automated send.**
  Android exposes **no public API** to send a message in a third-party app. The
  alternatives are `SEND_SMS` (Play restricts it to default SMS handlers, and it would
  undermine the core-function claim that justifies `USE_EXACT_ALARM`),
  `NotificationListenerService` + `RemoteInput` (can only reply while an unread
  notification is still live, and is the private-app scraping §3.5 forbids), and
  `AccessibilityService` automation (Play policy violation, breaks on every target-app
  update). The deliverable version — at the reminder, one tap opens the conversation
  with the draft ready — is a small delta on the existing `openLink` handoff and is
  the better product: under a trusted-utility framing, sending on the user's behalf is
  a trust liability, because "never lost" fails safely and "sent for you" does not.

## Defects found by reading the shipped code (2026-09-01)

| # | Defect | Where | Why the test suite cannot see it |
|---|---|---|---|
| D-1 | The 20:00 pileup — one notification per due promise, no group | `ReminderNotifications.show` | A design property, not a logic error. |
| D-2 | Over-snooze re-arm loop: digest-tier promises show nothing but are re-armed by `rescheduleAll()` on every app resume, writing a junk `resurfaced` event each time | `ReminderReceiver` + `ReminderScheduler.rescheduleAll` | Kotlin. Zero Kotlin tests exist. |
| D-3 | Nothing ever ages out | domain | No policy to test. |
| D-4 | **MIUI/HyperOS Autostart is off by default for sideloaded apps → `BOOT_COMPLETED` never delivered → a reboot silently drops every pending alarm** until the app is next opened | `BootReceiver` | Requires a physical Poco. **Verify first.** |
| D-5 | Every Dart test that crosses the native boundary uses `setMockMethodCallHandler`; the §9.5 integration loop is tested on the Dart side of a fake | `test/` | Structural. |
| D-6 | No golden tests — Iteration 8 rewrote every screen's type and colour with no regression protection | — | Structural. |
| D-7 | No export or delete-all controls, which §9.3 requires | `profile_screen.dart` | Not implemented. |

## Work items

1. **Onboarding flow** (screens from Stitch, implemented against §8.1):
   1. What Cya! is — one line, the beaver.
   2. **The share gesture** — an animated demo of sharing *into* Cya! from another
      app. Non-negotiable: the product depends on the user discovering this, and
      nothing currently teaches it.
   3. Notification permission, asked with a reason.
   4. **Reliability setup** — walk the user to Autostart + battery exemption. On a
      Poco this screen is worth more than the other three combined.
2. **Local identity (ADR-010):** profile creation, PIN/biometric lock gate, SQLCipher
   at rest keyed from the Android Keystore.
3. **Privacy controls (§9.3):** export all data, delete all data.
4. **Loop fixes:** D-1 (ADR-012), D-2 (ADR-013), D-3 (ADR-014).
5. **Kept-rate replaces the streak** (ADR-011).
6. **Reply-with-draft handoff** (ADR-015).
7. **Instrumentation script** in `tool/` — captures/day, resurface→resolve latency,
   snooze distribution, promises retired at the limit, missed alarms.

## Acceptance criteria

- A promise captured on a Samsung **and** a Poco survives a device reboot and still
  fires. (Gates everything else — a reminder product that drops reminders is worthless.)
- Six promises due at 20:00 produce **one** notification group, each still resolvable
  in one tap from the shade.
- A promise past the snooze limit can be let go from the notification, and stops
  re-arming a silent alarm.
- Onboarding teaches the share sheet: a new user who has never seen the app can
  capture from another app without being told how.
- Nothing leaves the device. No network dependency is added to `pubspec.yaml`.
- The database is encrypted at rest and unreadable without the device key.
- Export and delete-all both work.
- `flutter analyze` 0 · `flutter test` green · PRD §13.1/§13.3/§13.4 updated.

## Verified state at the start of this iteration

`flutter analyze` → 0 issues. `flutter test` → 121/121. Release build → exit 0,
`app-arm64-v8a-release.apk` 21 MB (correct ABI for both the Samsung and the Poco).
Test distribution: 76 domain · 30 data · 15 presentation · **0 Kotlin**.
