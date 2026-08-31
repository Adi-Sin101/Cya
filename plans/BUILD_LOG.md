# Build Log — Cya!

> Running record of **execution + testing feedback**. Append every work session. Purpose: learn
> from past mistakes, avoid repeating them, and reinforce the actions that worked. This complements
> the PRD's living log (§13) — the PRD holds module status/ADRs/lessons; this holds the session-by-
> session narrative of what actually happened at the keyboard.

Format for each entry:

```
## <YYYY-MM-DD> — <short title>
- Plan: plans/<file>.md   (which plan this work executes)
- Goal:
- Done:
- Verified / working:      (how it was tested, with evidence)
- Broke / deferred:        (what failed, root cause)
- Lesson / rule:           (what to remember; mirror into PRD §13.4 if durable)
- Next:
```

---

## 2026-07-03 — Project bootstrap & workflow setup
- Plan: (none yet — pre-development)
- Goal: Establish the development mindset and persistent workflow before coding starts.
- Done: Read the PRD bible; authored CLAUDE.md; created plans/ + this build log; recorded the
  non-negotiable invariants and the plan→execute→test→feedback cycle.
- Verified / working: n/a (no code yet — repo is the default Flutter counter scaffold).
- Broke / deferred: Phase 0 (foundation + two-second capture spike) not started.
- Lesson / rule: PRD is the single source of truth; every plan derives from it; nothing regresses
  the native-thin capture path.
- Next: Write plans/phase-0-foundation.md and begin the Phase 0 scaffold + capture spike (PRD §10).

## 2026-07-08 — Iteration 1: design system, native video splash → Home
- Plan: plans/iteration-1-foundation-splash-theme.md
- Goal: Ship the app's foundation — theme + Plus Jakarta Sans, a fully-native Android animated
  splash playing Cya_splash.mp4 before the Flutter engine boots, leading into the full designed
  (static) Home.
- Done:
  - **Theme:** `core/theme` — `AppColors` tokens (PRD §8.1 light+dark), `CyaColors` ThemeExtension
    (success/warning/surface2/gradient), Plus Jakarta Sans type scale, M3 light+dark `AppTheme`.
  - **Fonts:** bundled Plus Jakarta Sans 400/500/600/700 TTFs (SIL OFL) into lib/assets/fonts/.
  - **App shell:** Riverpod `ProviderScope`, go_router `StatefulShellRoute` (Home + 3 placeholder
    tabs), notched bottom nav + docked gradient capture FAB (capture = stub bottom sheet).
  - **Home:** greeting + level badge, gradient Today card with a CustomPainter completion ring,
    Today's Promises list (app icon, preset chip, completion toggle), Memory Garden preview, This
    Week stats with a sparkline. Reactive over a `HomeController` (Notifier) + mock repository.
  - **Native splash:** `SplashActivity` (TextureView + MediaPlayer, center-crop, muted) as LAUNCHER;
    `CyaApplication` pre-warms a cached FlutterEngine; `MainActivity.provideFlutterEngine` attaches
    it; res/raw video, SplashTheme, values-v31 branded system splash, branded warm-up window;
    idempotent `proceed()` covering completion / error / 6 s timeout / tap-to-skip / reduced-motion.
- Verified / working (emulator, API 34):
  - Cold start → SplashActivity plays the video (resumed during playback) → seamless handoff to
    MainActivity/Home, no white/black flash (branded warm-up bg == Home bg).
  - Designed Home renders in light + dark; tapping a promise updates the Today ring live (1/4→2/4).
  - Reduced-motion (`animator_duration_scale 0`) skips the video (fast handoff).
  - `flutter analyze` 0 issues · `flutter test` 2/2 · `flutter build apk --debug` OK on AGP 9.0.1 /
    Gradle 9.1 / Kotlin 2.3.20.
- Broke / deferred:
  - First-ever launch once showed a stale 0/4; a clean relaunch showed the correct 1/4. Cause looked
    like a first-run process artifact; deterministic on force-stop + relaunch. Watch for it.
  - Splash still (`splash_still.jpg`) used as the SplashActivity window background may stretch vs the
    center-cropped video for the first frame; momentary and acceptable. Revisit if a flash appears.
- Lesson / rule:
  - Chose TextureView + framework MediaPlayer over Media3/ExoPlayer to avoid an AndroidX dep graph on
    a bleeding-edge (AGP 9) toolchain — fewer moving parts, and it built first try.
  - Pre-warming the engine in `Application.onCreate` makes the native→Flutter handoff effectively
    flash-free; pair it with a warm-up window background equal to the Flutter screen's background.
  - On Git Bash + adb, set `MSYS_NO_PATHCONV=1` so on-device paths like `/sdcard/...` aren't mangled.
- Next: rename applicationId off `com.example.cya`; confirm dark Surface2 #243137; then Phase 0
  native-thin capture spike (Share Sheet → shared SQLite write → AlarmManager) per PRD §10.

## 2026-07-08 - Splash size, launcher logo, and Profile theme toggle
- Plan: plans/iteration-1-foundation-splash-theme.md
- Goal: Fix the oversized native splash video, restore the real Cya launcher icon, and expose
  light/dark switching from Profile.
- Done:
  - Changed `SplashActivity` from full-screen video to a centered 280dp rounded video card on the
    sage brand background.
  - Regenerated Android, iOS, macOS, and web app icons from `lib/assets/images/cya-logo.png`; Android
    label now reads `Cya!`.
  - Added a Riverpod-backed Profile settings screen with the Cya logo avatar and a dark-mode switch.
  - Removed the cached Flutter-engine startup path after emulator verification showed a blank green
    handoff screen; MainActivity now uses the standard FlutterActivity engine path.
- Verified / working:
  - `flutter analyze` clean.
  - `flutter test` 3/3, including Profile theme switch coverage.
  - `flutter build apk --debug` OK; installed on emulator `emulator-5554`.
  - Screenshots captured under `build/verification/`: compact rounded splash, Home after handoff,
    Profile light mode, and Profile dark mode.
- Broke / deferred: Theme preference is in-memory for now; persistence can be added with local
  settings storage in a later pass.
- Lesson / rule: Favor a reliable visible handoff over engine pre-warm cleverness unless the
  cached-engine path is proven on the target emulator/device.
- Next: Add persistent user settings when the app's local storage layer is introduced.

## 2026-07-08 - Circle splash crop and larger icon viewport
- Plan: plans/iteration-1-foundation-splash-theme.md
- Goal: Make the splash video fully circular and make the Cya logo fill icon viewports more strongly.
- Done:
  - Changed the splash video card to an oval-clipped square and zoomed the video content inside the
    circular crop.
  - Regenerated platform icon PNGs from `cya-logo.png` with a 1.32x centered crop so the mascot/logo
    fills the launcher icon canvas.
- Verified / working:
  - `flutter analyze` clean.
  - `flutter test` 3/3.
  - `flutter build apk --debug` OK; installed on emulator and captured circle splash plus Home
    handoff screenshots under `build/verification/`.

## 2026-07-08 - Fix flutter run ANR and adaptive launcher icon
- Plan: plans/iteration-1-foundation-splash-theme.md
- Goal: Stop `flutter run` from losing the emulator connection and make the app-list icon fill the
  launcher viewport.
- Done:
  - Moved the launcher intent back to `MainActivity`; `SplashActivity` is no longer the launched
    activity, avoiding the unstable native-video-activity to Flutter-activity transition.
  - Added `CyaBootstrap`, a Flutter-owned startup splash using the existing splash video asset with
    a fast timeout fallback into the app.
  - Added Android adaptive icon resources with a large Cya mascot foreground and `roundIcon`.
  - Branded Android launch backgrounds to sage to avoid the white pre-first-frame screen.
  - Disabled Kotlin incremental compilation to work around the Windows cross-drive
    `video_player_android` cache error (`C:` pub cache vs `D:` repo).
- Verified / working:
  - `flutter analyze` clean.
  - `flutter test` 3/3.
  - `flutter run -d emulator-5554 --debug --no-resident` builds, installs, and reaches Home.
  - Logcat scan after launch showed no Cya ANR, fatal exception, or lost-connection markers.
  - Captured Home and enlarged adaptive icon screenshots under `build/verification/`.
- Broke / deferred: In debug on the emulator, video initialization can be slow; the bootstrap falls
  back quickly rather than blocking startup.

## 2026-07-08 - Replace splash decoder with animated asset
- Plan: plans/iteration-1-foundation-splash-theme.md
- Goal: Fix the non-playing splash video, avoid debug startup crashes, and reduce over-cropping.
- Done:
  - Replaced the Flutter `video_player` splash path with a padded animated WebP image rendered in a
    centered circular clip.
  - Moved the splash timeout to start after Flutter paints its first splash frame, so slow debug
    cold starts do not skip the animation.
  - Removed the temporary `video_player` dependency and Kotlin incremental workaround.
  - Regenerated Android launcher foreground/legacy icons from `cya-logo.png` with a looser crop.
  - Added a dedicated native `splash_icon.png` and branded launch backgrounds for pre-Flutter
    startup.
- Verified / working:
  - `flutter analyze` clean.
  - `flutter test` 3/3.
  - `flutter run -d emulator-5554 --debug --no-resident` builds, installs, and keeps the emulator
    connection.
  - Cold-start logcat scan showed no Cya ANR, fatal exception, tombstone, lost-connection marker,
    ExoPlayer, or MediaCodec startup path.
  - Captured a post-first-frame splash showing the padded circular animation, followed by Home.

## 2026-07-08 - GIF splash and unmodified logo regeneration
- Plan: plans/iteration-1-foundation-splash-theme.md
- Goal: Fix the non-animating splash and restore clean mascot eyes/logo rendering.
- Done:
  - Replaced the animated WebP splash with `cya-splash-animated.gif`, generated from the existing
    MP4 frames for reliable Flutter image animation.
  - Started the splash countdown only after the GIF's first frame is painted, so slow debug cold
    starts do not consume the animation time behind Android's native splash screen.
  - Regenerated Android launcher and splash icon assets from `cya-logo.png` using only crop/resize,
    with no pixel color or alpha manipulation.
- Verified / working:
  - `flutter analyze` clean.
  - `flutter test` 3/3.
  - `flutter run -d emulator-5554 --debug --no-resident` builds, installs, and stays connected.
  - Cold-start logcat scan showed no Cya ANR, fatal exception, tombstone, lost-connection marker,
    ExoPlayer, or MediaCodec startup path.
  - Captured multiple on-device splash frames showing the GIF advancing before Home.

## 2026-07-08 - Tight sprite splash and startup optimization
- Plan: plans/iteration-1-foundation-splash-theme.md
- Goal: Make the circular splash crop more aggressive and reduce startup animation jank.
- Done:
  - Replaced GIF playback with a single compact sprite sheet, `cya-splash-sprite.webp`.
  - Cropped frames from the MP4 using detected content bounds with only a small margin, so the art
    fills the circular viewport more tightly.
  - Reduced the startup animation payload to 36 frames at 192px per frame, 265 KB on disk.
  - Added a dedicated sprite painter driven by `AnimationController`, avoiding video decoder and GIF
    disposal/timing issues.
  - Added a short fade switch from splash to app.
- Verified / working:
  - `flutter analyze` clean.
  - `flutter test` 3/3.
  - `flutter run -d emulator-5554 --debug --no-resident` builds and installs.
  - `flutter build apk --release` builds `app-release.apk`.
  - Release cold start measured with `adb shell am start -W` at about 3.7 seconds on the emulator.
  - Logcat showed no Cya ANR, fatal exception, tombstone, lost-connection marker, ExoPlayer, or
    MediaCodec startup path.

## 2026-07-08 - Loosen splash crop so the slogan is visible
- Plan: plans/iteration-1-foundation-splash-theme.md
- Goal: The circular splash crop was cutting off the "I'll remember for you." slogan below the
  beaver/"Cya!" log. Make the crop looser so the whole sprite frame shows.
- Done: In `cya_bootstrap.dart` `_SplashView`, replaced the circular clip (`BoxShape.circle` +
  `ClipOval`) with a 40px rounded rectangle (`BorderRadius.circular(40)` + `ClipRRect`). The sprite
  frames are square with the mascot centered and the slogan at the bottom, so a circle clipped the
  wide bottom line; a rounded rect keeps the full frame with only softened corners.
- Verified / working:
  - `flutter analyze` clean.
  - `flutter build apk --debug` OK; installed on emulator-5554.
  - Captured an on-device splash frame showing the rounded card with the beaver, "Cya!" log, and the
    full "I'll remember for you." slogan no longer clipped.
- Lesson / rule: A circular crop is wrong for content wider at the bottom (a centered wordmark +
  slogan). Match the mask shape to the artwork's aspect — a rounded rectangle preserves bottom text.

## 2026-07-08 - Splash back to a circle, with the full lockup fit inside
- Plan: plans/iteration-1-foundation-splash-theme.md
- Goal: Keep the circular splash shape (per request) but stop it clipping the slogan.
- Done: In `cya_bootstrap.dart` `_SplashView`, restored `BoxShape.circle` + `ClipOval`, filled the
  circle with the sprite's off-white background (`#FDFBF9`), and inset the sprite by 46px so the
  whole square frame fits inside the circle's inscribed square (side = D/√2 ≈ 212 for D=300). The
  matching fill hides the square's edges, so it reads as a clean off-white circle containing the
  full mascot + "Cya!" + slogan lockup.
- Verified / working: `flutter analyze` clean; `flutter build apk --debug` OK; installed on
  emulator-5554; on-device capture shows a circular splash with the beaver, "Cya!", and the full
  "I'll remember for you." slogan, none clipped.
- Lesson / rule: To fit square art in a circle without clipping, inset it to the inscribed square
  (≈0.707·diameter) and fill the circle with the art's own background color so the seams vanish.

## 2026-08-31 — Iteration 2: Drift data foundation (the store becomes the source of truth)
- Plan: plans/iteration-2-drift-data-foundation.md
- Goal: Finish the half of Phase 0 that was still missing — the local store — *before* the native
  capture spike, because the Kotlin writer has to match the Drift schema (PRD §7.2).
- Done:
  - **Schema v1** (`data/db`): `intentions`, `intention_events`, `preferences`, every column name
    pinned with `.named(...)` because the native writer will insert into these tables directly.
    FTS5 index over `raw_content`/`snippet` maintained by **SQL triggers**, so a native capture stays
    searchable without the Flutter engine ever starting. Hot-path indices on `status`, `reminder_at`,
    and the event log's `occurred_at`/`intention_id`.
  - **`IntentionDao`** with the invariant that no mutation happens without its event, in the same
    transaction: capture / resolve / reopen / snooze / archive / resurface / reschedule / edit /
    delete. Plus the scheduler's queries (`dueAt`, `nextScheduled`) and a grouped event-count
    aggregate so XP never streams the whole log.
  - **Pure domain layer**: `Intention` / `IntentionEvent` entities, `IntentionRepository` interface,
    use-cases (`CaptureIntention`, `ResolveIntention`, `SnoozeIntention`, `ManageIntention`),
    `SnoozePolicy` (limit 3 + quiet→banner→digest escalation tiers), and the XP / week-stats / garden
    projections. `domain/` imports nothing from Flutter and nothing from Drift.
  - **`Result` / `AppError`** sealed types so commands report failures instead of throwing into the
    widget tree; `Clock` typedef so every time-dependent rule is testable at any instant.
  - **Riverpod DI** (`core/di/providers.dart`): database → DAO → repository → use-cases, with the
    database overridable in tests.
  - **UI rewired off the mock**: Home is now section-scoped consumers over narrow watches (ticking a
    promise does not repaint the greeting); real capture sheet with presets + custom date; Promises
    tab with FTS search and open/done/all filters; Promise Detail with Done / Open-in-app / Snooze,
    the snooze-limit prompt, and the "Why this matters" mascot card; designed empty states.
  - Theme preference now **persists** (the `preferences` table), closing the deferred item from the
    2026-07-08 session.
  - `docs/native_db_contract.md` — the two-runtime contract: file location, value encodings
    (DateTime = INTEGER unix **seconds**), table/column names, status + event wire strings, the
    zero-tap preset rules native must reproduce, and the migration procedure.
  - Deleted `data/mock/` and the `Promise` presentation model. The mock is gone, not bypassed.
- Verified / working:
  - `flutter analyze` — 0 issues. `dart format .` clean.
  - `flutter test` — **53/53**: preset resolution (incl. DST/month-end and "tonight must stay
    tonight"), XP/level curve, week stats + garden projections, use-cases including the refused
    fourth snooze, DAO round-trips against **real SQLite** (FTS matching, trigger sync on delete,
    today-window semantics, due/next-scheduled), and widget tests driving the app over an in-memory
    database.
  - Confirmed on-disk encoding by querying `typeof(captured_at)` → `integer`, value = epoch
    **seconds** (not millis) — which is what the contract doc now states for the Kotlin writer.
- Broke / deferred:
  - **Widget tests hung for 10 minutes** on the first run. Cause: drift schedules a zero-duration
    `Timer` when a query stream is cancelled, and Riverpod cancels those streams while the tree is
    torn down at teardown — after the tester can still pump. Fix: unmount the app *inside* the test
    body (`pumpWidget(SizedBox())` + `pump(Duration.zero)`) so the timers run.
  - The first toggle test tapped "the last GestureDetector", which was fragile. Fixed properly by
    giving the completion toggle a stable `ValueKey('promise-toggle-<id>')` — better for
    accessibility tooling too.
  - `flutter test` output piped through `tail` shows nothing until the process exits — a hung run
    looks identical to a silent one. Use `--reporter expanded` without a pipe when diagnosing.
  - Still open: no notifications/alarms; "Open in <app>" is honest-but-stubbed until deep links
    arrive with the native path; Garden and Achievements are placeholders; the day boundary is read
    once when the provider builds, so an app left open across midnight will not roll over.
- Lesson / rule:
  - Build the **store before the native capture path**, not after: the schema is a contract between
    two runtimes, and it is far cheaper to pin column names and value encodings while there is only
    one writer.
  - Keep the FTS index in **SQL triggers**, never in Dart. Anything the native path must not depend
    on the Flutter engine for belongs in the database itself.
  - `sqlite3` 3.x builds via Dart build hooks, so real SQLite (with FTS5) is available in
    `flutter test` on Windows — DAO tests can be genuine integration tests instead of mocks. Prefer
    a real in-memory database to a hand-written fake.
- Next: Phase 0's remaining piece — the native-thin capture spike (Share Sheet → Kotlin SQLite insert
  → `AlarmManager` default reminder → notification → one-tap return), instrumented for the < 2s
  budget.

## 2026-08-31 — Iteration 3: the native-thin capture path (Phase 0's two-second spike)
- Plan: plans/iteration-3-native-thin-capture.md
- Goal: Share Sheet → Kotlin → direct SQLite write, no Flutter engine, inside the < 2s budget
  (PRD §3.1, §5.4, §10 Phase 0 acceptance).
- Done:
  - **`CaptureActivity`** — exported, translucent, `Theme.Translucent.NoTitleBar`, `noHistory`,
    `excludeFromRecents`. Inflates no layout, starts no engine, loads no plugin. Reads
    `ACTION_SEND` / `ACTION_PROCESS_TEXT`, attributes the source app from the caller's package
    label, extracts the first URL as the return-to-source `deep_link`, toasts, finishes.
  - **`CaptureWriter`** — `SQLiteDatabase.openOrCreateDatabase` on the shared file, one transaction
    inserting the row *and* its `captured` event, `capture_ms` measured from
    `SystemClock.elapsedRealtime()` at `onCreate` and stored in the event metadata (so §11 capture
    speed is a fact in the log, not a guess) plus one tagged Logcat line for scripted assertions.
  - **`CyaDatabaseContract`** — the native half of the schema contract: the shared DDL, the
    `user_version` stamp, and Kotlin twins of the status/event wire strings. A share can land before
    the app has ever been opened, so whichever runtime gets there first creates the file.
  - **`ReminderDefaults`** — the Tonight / Tomorrow / Weekend rules ported from `ReminderPreset`, on
    `Calendar` so the capture path needs no desugaring.
  - **`test/data/native_contract_test.dart`** — keeps a copy of the native DDL, builds a database
    with it, and asserts Drift opens it without migrating, reads the rows with the right encodings,
    finds them via search, and can resolve them. Also asserts the native DDL contains no `fts`.
- Verified / working (emulator API 34, `pm clear` before the cold run):
  - **Cold process, database did not exist: `am start -W` total 762 ms**, of which `capture_ms=172`
    was the write *including creating the schema*. Budget is < 2000 ms, target < 1000 ms (§9.2).
  - **Warm process, 5 runs: 117 ms median** (`159, 117, 125, 105, 107`), writes 10–18 ms.
  - On-device `sqlite3` dump: `user_version=1`; `captured_at`/`reminder_at` in epoch **seconds**;
    `reminder_at` = tonight 20:00; `deep_link` extracted from the shared URL; one `captured` event
    per row carrying `{"surface":"share_sheet","capture_ms":…}`.
  - The Flutter app then opened that **native-created** file with no migration, listed all six
    promises with the right source and "Tonight" chip, projected **60 XP** (6 captures × 10) from
    events Dart never wrote, and FTS search for "paper" found a natively written promise.
  - `flutter analyze` 0 · `flutter test` 58/58 · debug APK builds.
- Broke / deferred:
  - **The first on-device run failed outright: `no such module: fts5`.** Android's system SQLite is
    built without FTS5, and iteration 2 had the search index maintained by triggers on `intentions`
    — so *every* native insert failed. Redesigned as ADR-005: the native path knows nothing about
    search; Drift owns the index and reconciles it from a watermark.
  - While fixing that, a second trap: reconciling by comparing `COUNT(*)` of `intentions` and
    `intentions_fts` never detects staleness, because an external-content FTS5 table reads its
    values *from* the content table, so the counts always agree. Replaced with an explicit
    "indexed through id" watermark in `preferences`.
  - `source_app` reads "Shell" when the share comes from adb — correct behaviour, and a real app
    supplies its own label.
  - Reminder *firing* is not in this iteration by design: the spike proves capture, and `reminder_at`
    is stored correctly for iteration 4 to schedule.
  - Android's `SQLiteDatabase` silently adds an `android_metadata` table to the file. Harmless —
    Drift ignores tables it does not know about.
- Lesson / rule:
  - **A shared database may only use SQL features that *both* SQLite builds have.** Dart bundles its
    own SQLite (FTS5 on); Android's system SQLite does not. Anything richer belongs to the side that
    bundles its own engine, as a derived artifact it maintains itself.
  - **Green tests on one runtime prove nothing about the other.** All 53 Dart tests passed while the
    native path was broken on every device. A two-runtime feature is not done until it has run on a
    device.
  - Windows/PowerShell: `adb exec-out … > file` corrupts binaries (BOM + text encoding). Use
    `adb shell "… > /sdcard/x"` then `adb pull`. Same for `screencap`.
  - `adb shell am start … --es …` needs *device-side* quoting: without inner quotes the device shell
    splits the extra and `am` swallows the fragments as flags.
- Next: iteration 4 — AlarmManager scheduling, notification channels mapped to the escalation tiers,
  one-tap resolution from the notification (native write, no engine), boot rescheduling, and the
  `cya://promise/<id>` deep link into promise detail.

## 2026-08-31 — Iteration 4: closing the loop (alarms, notifications, escalation, one-tap resolution)
- Plan: plans/iteration-4-reminders-escalation.md
- Goal: Make a captured promise actually come back, and let the user close it **from the
  notification** without opening the app (PRD §3.4, §5.6, §8.4, §9.2, §12).
- Done:
  - **`ReminderScheduler` (Kotlin)** — `setExactAndAllowWhileIdle`, degrading to
    `setAndAllowWhileIdle` (with a log line) when exact alarms are not permitted, because a late
    reminder beats none. Alarms carry only the intention id; everything shown is read from the store
    at fire time, so a reminder can never surface stale content. `rescheduleAll()` re-arms from the
    database and fires anything already overdue rather than dropping it.
  - **`ReminderReceiver`** — skips promises that are no longer pending, maps `snooze_count` to the
    escalation tier (the same rule as `SnoozePolicy.tierFor`), posts on the quiet or banner channel,
    and writes a `resurfaced` event *even when the tier is digest and nothing is shown* — that event
    is how reminder reliability becomes measurable (§9.2).
  - **`NotificationActionReceiver`** — Done and Snooze write straight to SQLite, the same
    native-thin way capture does. A refused fourth snooze re-shows the promise *quietly* with
    "You've pushed this back 3 times", instead of silently ignoring the tap.
  - **`BootReceiver`** — alarms do not survive a reboot; they are re-armed from the store.
  - **`CyaStore`** — the native store grew from capture-only to the full engine-free vocabulary:
    capture, findById, resolve, snooze (limit enforced), markResurfaced, pendingReminders.
  - **Dart side:** `ReminderPort` (MethodChannel) + `PlatformReminderScheduler` behind a pure-domain
    `ReminderScheduler` interface, so use-cases arm and cancel alarms without `domain/` importing
    Flutter. Capture schedules, resolve cancels, snooze re-arms, archive/delete cancel, reopen
    restores a still-future reminder.
  - **Reliability, measured not assumed (§12):** `missedReminders()` finds pending promises whose
    reminder passed with no `resurfaced` event; a Home banner appears only on that evidence and
    offers the actual fix (exact-alarm settings, or re-arm everything). Alarms are also re-armed on
    every app resume.
  - **Deep link** `cya://promise/<id>` from the notification body into Promise Detail.
  - Notification permission is requested right after a capture, where its reason is on screen.
- Verified / working (emulator API 34):
  - Capture registers a real exact alarm — `dumpsys alarm`: `RTC_WAKEUP … window=0
    exactAllowReason=policy_permission origWhen=2026-08-31 20:00:00.000`.
  - **A real alarm fired**: with the device clock advanced to 19:59:30, at `20:00:00.483` the quiet
    notification appeared with Done + Snooze; the snoozed-three-times promise fired at
    `20:00:00.137` as `tier=digest` and posted nothing.
  - **Done from the notification** → row `resolved`, `resolved{"surface":"notification"}` in the log,
    notification dismissed, alarm cancelled — Flutter never started.
  - **Escalation** → first fire `cya_reminders_quiet`; after one snooze the next fire used
    `cya_reminders_banner`; the fourth snooze was refused (`granted=false`).
  - **Boot** → `BOOT_COMPLETED` → `rescheduled count=1`.
  - **Deep link** → cold start into Promise Detail (screenshot in `build/verification/`).
  - `flutter analyze` 0 · `flutter test` **74/74** · debug APK builds.
- Broke / deferred:
  - **Captures were silently rolled back.** After moving the native writer into `CyaStore`, every
    Share Sheet capture logged `capture_ok id=1` while the database stayed empty. Cause: `capture`
    returned from *inside* the inline `transaction { }` lambda — a non-local return that unwinds past
    `setTransactionSuccessful()` into the `finally`, rolling the transaction back. Fixed by returning
    the lambda's last expression (and `return@transaction` for early exits), with the trap documented
    on the helper. Recorded as PRD §13.4 [L-002].
  - **Deep links 404'd**: Flutter's automatic deep linking handed go_router the raw `cya://promise/2`
    as a *location*. Disabled it (`flutter_deeplinking_enabled=false`); MainActivity passes the link
    over the reminder channel and the app routes it itself.
  - **The notification icon was a hollow blob**: status-bar small icons are alpha masks, so the
    launcher icon cannot be used. Generated `ic_stat_cya` — a white bookmark silhouette — in all five
    density buckets.
  - A widget test began hanging on `pumpAndSettle` once the capture path talked to a platform
    channel: the save spinner never stopped. Fixed by mocking the `cya/reminders` channel in the
    test, which also documents the channel's shape.
  - Still open: the weekly digest (escalation's third rung currently just stays quiet); Garden and
    Achievements screens; Rive reward moments; iOS has no scheduler.
- Lesson / rule:
  - **A write is not verified by the writer's own return value.** `insertOrThrow` returned an id for
    a row that was rolled back moments later. Read the data back — `sqlite3` on the device — before
    believing a native write.
  - **An inline block that runs code *after* your body is a trap for `return`.** In Kotlin, prefer
    the last expression; if you need an early exit, label it.
  - **Refactoring native code needs its own device run.** All 60 Dart tests were green while every
    native capture was being discarded.
  - Escalation's top rung should be *quieter*, not louder. Past the snooze limit Cya! stops
    interrupting and asks to close the loop instead — nagging is how a memory product becomes the
    backlog it was meant to prevent.
- Next: iteration 5 — the Memory Garden, achievements, reward animations, and the weekly digest.

## 2026-08-31 — Iteration 5 (part 1): the Memory Garden and Achievements
- Plan: plans/iteration-5-garden-achievements-digest.md
- Goal: Turn the two placeholder tabs into the reward half of the product (PRD §6.6, §8.2) — the
  part that makes closing the loop worth doing.
- Done:
  - **`GardenProjection`** — kept promises become plants, grouped into weekly beds; a plant's
    species is derived from its intention id (the same promise always grows into the same plant),
    its growth from how long ago it was kept, and the streak counts consecutive days with a
    resolution, forgiving a today that has not happened yet.
  - **`AchievementProjection`** — the six badges named in §8.2 as predicates over counts, with
    `newlyUnlocked(before, after)` for celebrating a change. Nothing stored, so a badge can never
    disagree with the event log.
  - **Garden screen** — a `CustomPainter` scene per bed inside a `RepaintBoundary` (a mature garden
    is hundreds of plants; a widget each would be the obvious way to drop frames), five hand-drawn
    plant species with deterministic posture, a soil bed, an animate-in that respects reduced
    motion, and a designed empty state.
  - **Achievements screen** — grid with locked/unlocked states, where locked badges show real
    progress. Profile links to both instead of saying "Coming soon".
  - Two narrow queries feed it: `watchResolutions()` (only resolved events) and one aggregate for
    the *Reader* and *Communicator* counts.
- Verified / working (emulator API 34): six captures with four kept across three weeks rendered as
  "This week / Last week / Week of Aug 17" with a 3-day streak and 4 all-time; Achievements showed
  1 of 6 unlocked with correct progress (4/100, 1/50 — the 1 being the single kept promise that
  carried a link, which exercises the flavour query end to end). `flutter analyze` 0 ·
  `flutter test` 93/93.
- Broke / deferred:
  - The first painted garden read as sticks on a bar: plants hugged the left edge, the soil was
    nearly invisible, and one species drew as a hard triangle that looked like an arrow. Redrawn —
    plants centre and spread across the bed, stems bend, and the species are a sprout, a flower with
    a centre, a bush, a canopy tree and a grass tuft. Worth the second pass: the PRD treats beauty
    as an acceptance criterion, not a nicety.
  - **Rive reward moments are not built** — there are no `.riv` assets, and inventing a mascot rig
    is a design job, not a coding one. Logged as an open question rather than faked.
  - The weekly digest is still open; escalation's third rung stays quiet in the meantime.
- Lesson / rule: a projection-shaped feature is cheap to add *and* cheap to trust — the garden, the
  stats and the badges cannot drift apart, because they are three readings of one event log.
  Screenshot the result before believing it: the projections were right on the first try and the
  drawing was wrong, and only one of those is visible in a test.
- Next: the weekly digest, then enrichment (on-device date extraction, auto-categorization).

## 2026-08-31 — Iteration 5 (part 2): the weekly digest
- Plan: plans/iteration-5-garden-achievements-digest.md
- Goal: Give escalation's third rung somewhere to point (PRD §5.6). A promise past the snooze limit
  stops interrupting — it has to end up *somewhere*, or "stops interrupting" just means "forgotten".
- Done:
  - **`DigestScheduler`** — next Sunday 18:00, inexact (a weekly review does not need to interrupt
    to the minute, and inexact is far kinder to the battery), and scheduled one week at a time: the
    receiver arms the next when it fires, so the schedule survives reboots and clock changes without
    drifting. Armed from the same `rescheduleAll()` that arms reminders — one place guarantees both.
  - **`DigestReceiver`** — leads with what was *kept*, then what is waiting; says nothing at all on a
    week with no activity. Deliberately a low-importance channel.
  - **Digest screen** (`cya://digest`) — "Time to decide" for promises past the snooze limit, "Still
    waiting", and "Kept", with one-tap resolution on every row: the review is a place to close the
    loop, not just to read about it.
- Verified / working: broadcasting the digest logged `digest_shown kept=1 open=2` and armed the next
  for the following Sunday 18:00; the deep link opened the review from a cold start with the right
  sections (screenshot in `build/verification/digest.png`). `flutter analyze` 0 · `flutter test`
  97/97.
- Broke / deferred: the first digest test crashed on `context.cyaColors`, which force-unwrapped the
  theme extension — a widget rendered outside the app's theme should look plain, not explode. It now
  falls back to the palette matching the theme brightness.
- Lesson / rule: an accessor that force-unwraps ambient state makes every widget untestable in
  isolation. Give it a sane fallback and the same widget works in the app, in a test, and in a
  preview.
- Next: enrichment — on-device date extraction and rule-based auto-categorization, both strictly off
  the capture path (PRD §3.2).

## 2026-08-31 — Iteration 6: Quick Settings Tile and manual categories
- Plan: plans/iteration-5-garden-achievements-digest.md (follow-on; the remaining Phase 1 items)
- Goal: Close the two Phase 1 items that are not the home-screen widget — a second capture surface
  (PRD §6.1) and manual categories (§6.4).
- Done:
  - **`CyaTileService` + `QuickCaptureActivity`** — a tile cannot read the screen, so this is the one
    capture surface that needs a text field. It is still engine-free: a dialog built programmatically
    in Kotlin (no XML inflation, no Flutter), **pre-filled from the clipboard** so the common case —
    "I just copied this" — is a single tap, and saving runs the same one-insert-plus-one-alarm path
    as every other surface.
  - **`PromiseCategory`** — seven fixed categories. A short list on purpose: the product's job is to
    make "later" cheap, and free-form tagging turns every capture into a filing decision. The wire
    values are stored, because auto-categorization will later write the same ones.
  - Category picker on Promise Detail (tapping the current one clears it), filter chips on the
    Promises tab, and a category icon on every promise tile.
  - Chips gained a hairline outline — unselected ones were rendering as plain text.
- Verified / working: on device the tile capture logged `tile_capture_ok id=7 capture_ms=35`, stored
  the row with source "Quick Tile" and scheduled its alarm; the category picker and filters render
  and persist (screenshots in `build/verification/`). `flutter analyze` 0 · `flutter test` 101/101.
- Broke / deferred: the first tile dialog was a narrow floating window that truncated its own
  question mid-sentence ("What do you want to save for"). Fixed with
  `windowMinWidthMajor/Minor` — a dialog that wraps its prompt reads as broken, and this one is the
  first thing a tile user sees. The home-screen widget is the last Phase 1 item.
- Lesson / rule: build native UI at the size it will actually appear. A dialog theme's default width
  is not the width of a phone, and the difference is only visible in a screenshot.
- Next: the home-screen widget (PRD §6.1), then enrichment (§5.5).

## 2026-08-31 — Iteration 7: the home-screen widget
- Plan: plans/iteration-5-garden-achievements-digest.md (follow-on; last Phase 1 surface)
- Goal: The remaining capture surface from PRD §6.1 — two tap targets: capture, and view today.
- Done:
  - **`CyaWidgetProvider`** — a RemoteViews card on the brand gradient: today's remaining promises,
    how many are kept, the body opening the app and the `+` opening the same native quick capture
    the tile uses. It reads the shared store directly; **no Flutter engine renders a count**, which
    would be a battery cost the user never asked for.
  - **`CyaStore.todayCounts()`** — one aggregate over the same window as the app's Today card (due
    by end of day, including overdue, plus what was resolved today).
  - Every native write path — share capture, tile capture, notification Done/Snooze — calls
    `CyaWidgetProvider.refresh()`, so the widget is never staler than the write that changed it.
- Verified / working: the provider is registered (`dumpsys appwidget` lists it), an update broadcast
  runs with no exception in logcat, and `todayCounts()`'s query matches a hand-written SQL
  cross-check (7 due today, 4 kept). Home itself shows 7 promises, 4/7 done and 170 XP — exactly
  7 captures × 10 + 4 resolutions × 25, so the projection is right end to end.
  `flutter analyze` 0 · `flutter test` 101/101.
- Broke / deferred: **the widget has not been seen on an actual home screen.** Placing a widget
  needs the launcher's picker, which could not be driven over adb. Recorded as ⚠️ in PRD §13.1
  rather than ticked — it needs one manual look before Phase 1 is complete.
- Lesson / rule: report what was actually observed. "Provider registered and update path runs" is
  not "the widget works", and writing it down as the former keeps the next session honest.
- Next: enrichment (PRD §5.5) — on-device date extraction (ML Kit) and rule-based
  auto-categorization, both strictly off the capture path.

## 2026-08-31 — Iteration 8: typography, motion, the garden, and the rest of Phase 2
- Plan: plans/iteration-6-typography-motion-garden.md
- Goal: the app was functionally complete and read like a spreadsheet with a good data model behind
  it. Make it feel like the product the PRD describes, then finish what was left.
- Done:
  - **Design system.** Type scale roughly +40% across the board (display 44/36, headline 30/26/22,
    body 18/16/14) with optical tracking on the large end. `AppMotion` (durations + curves),
    `AppSpacing`/`AppRadius`/`AppTouch`, and `CyaHaptics` — a five-entry haptic *vocabulary*, so a
    buzz means something. Component themes sized to the scale rather than to Material's defaults.
  - **Contrast (ADR-009).** The §8.1 status colours fail as text: amber on white is 2.2:1. Split
    them into fills (unchanged §8.1 values) and inks. Dark mode promotes Soft Sage to `primary`,
    because Sage on the dark background is 2.9:1. The Today card's gradient was rebalanced — white
    on mint was 1.6:1 and the ring was invisible; sage now holds the first 45% and the ring is deep
    ink.
  - **Edge-to-edge.** The app paints under the status and navigation bars, with the bar icons
    following the resolved theme. No more black seam at the top.
  - **Garden rewrite.** One `GardenScenePainter`: a sky that darkens with the actual hour, sun or
    moon and stars, two parallax hill bands, textured soil, ground shadows, 8 species, wind sway,
    fireflies at night. The screen now has one focal point — this week as a full landscape — with
    older weeks as quiet soil strips beneath.
  - **Declutter.** Home 6 blocks → 4 (level inlined under the greeting; the garden teaser and the
    week stats merged into one `WeekCard`, because they answer the same question). Promises: three
    filter chips over seven category chips → one segmented row plus a filter button. Detail: the
    7-chip category grid → one row and a sheet, and the three loop-closing actions moved *above*
    the supporting cards.
  - **Reward moments (ADR-007).** Flutter particle bursts instead of Rive.
  - **Real source-app icons.** Schema **v2** adds `intentions.source_package`; the capture path
    records the sharing app's package, and an `appIcon` channel hands back its launcher icon.
    Unknown sources fall back to the mascot rather than a grey bookmark.
  - **Enrichment (ADR-008).** Rule-based date extraction + auto-categorization, run after startup,
    never on the capture path, never over the top of a user's choice.
  - **Midnight rollover, real "Open in <app>", a display-name setting, `applicationId` →
    `dev.cya.app`.**
- Verified / working: `flutter analyze` 0 · `flutter test` **121/121**. On an API 34 emulator:
  share-sheet capture 37–120 ms under the new package; schema v2 migrated a live v1 database with
  no data loss; Chrome and Settings launcher icons render in the list; a natively captured
  "Call the plumber tomorrow at 9am" was untouched at capture time and then categorised `reply`
  and rescheduled to 09:00 on app open; the whole loop verified on a **release** build.
  Release APK 63.4 MB → **20.8 MB**.
- Broke / deferred:
  - **[L-004]** The ambient animations hung twenty widget tests — `pumpAndSettle` cannot return
    while a controller repeats. Deleted the FAB's decorative loop and confined the wind to the
    Garden hero. The test hang was the design telling the truth about a battery cost.
  - **[L-005]** Enrichment moved `reminder_at` without re-arming AlarmManager. Caught by reading
    the device DB, not by a test — the resume-time `rescheduleAll()` was hiding it.
  - The home-screen widget **still** has not been seen on a launcher.
  - Golden tests are still not written; the reduced-motion and rollover tests landed instead.
  - Release still signs with the debug key.
- Lesson / rule: two of the three real bugs this session were found by reading the device's SQLite
  back, and none of them by a green test suite. Keep doing that after any change that crosses the
  Dart/Kotlin boundary. And treat a test that suddenly hangs as a design signal before treating it
  as a test problem.
- Next: place the widget on a launcher and settle §13.1's last ⚠️; a release keystore; golden tests
  for the core screens in both themes; then iOS, which has no native side at all.
