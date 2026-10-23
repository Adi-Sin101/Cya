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

## 2026-09-01 — Iteration 9 (part 1): the loop fixes a real week demands
- Plan: plans/iteration-9-onboarding-local-identity-and-loop-fixes.md
- Goal: a grilling session settled what Cya! actually is — Gen Z multi-app user (§2.2), a
  **trusted utility rather than a daily habit**, with Samsung + Poco as the reliability floor. Three
  defects found by *reading the shipped code* contradicted that positioning. Fix those first; the
  onboarding screens wait on Stitch.
- Done:
  - **ADR-012 — grouped reminders.** Every zero-tap capture defaults to `tonight` (20:00), and
    notifications were posted one per promise. A good capture day therefore produced N separate
    interruptions at one instant: the better the capture path worked, the worse the resurface
    moment got. Reminders now share a notification group with `GROUP_ALERT_CHILDREN` and a summary
    that appears from two children up and is recomputed when a child leaves. Per-promise Done and
    Snooze survive, because one-tap resolution from the shade is a §3.4 invariant.
  - **ADR-013 — "Let it go".** The fourth-snooze notification asked the user to "finish it, or let
    it go" and offered only **Done**. Added `ACTION_LET_GO` + `CyaStore.archive` (status and event
    `archived`, written in one transaction like every other mutation) shown in place of Snooze past
    the limit, and `STATUS_ARCHIVED`/`EVENT_ARCHIVED` mirrored into `CyaDatabaseContract`.
  - **ADR-011 — kept-rate replaces the streak.** The Garden's second stat was a day streak, which
    resets on a calm week — a daily-habit mechanic under a trusted-utility product.
    `GardenScene.keptRate` (kept over captured, null until something is captured) now sits there.
    `streak()` stays computed and tested but is no longer surfaced.
- Verified / working: `flutter analyze` 0 · `flutter test` **125/125** (121 + 4 new kept-rate
  tests) · `:app:compileDebugKotlin` exit 0. The vocabulary test already asserted `archived` on
  both sides, so the new Kotlin constants are covered by the existing cross-runtime contract test.
- Broke / deferred:
  - **[L-006]** `rescheduleAll()` runs on every app resume and re-armed *every* pending promise —
    including those past the snooze limit, for which `ReminderReceiver` deliberately shows nothing.
    Each firing wrote a `resurfaced` event. Every over-snoozed promise was therefore an endless
    silent alarm loop polluting the event log that XP, the garden and every metric are projected
    from. Found by reading Kotlin, not by a test: **there are still zero Kotlin tests**, and every
    Dart test that crosses the boundary mocks the channel.
  - Not yet done: onboarding, local identity (ADR-010), export/delete (§9.3), 30-day aging
    (ADR-014), the reply-draft handoff (ADR-015), the instrumentation script.
  - The Poco reboot question (D-4, MIUI Autostart) is still unanswered and still gates everything.
- Lesson / rule: three real defects this session came from reading the shipped code against a
  *stated product position*, not from running it. "Grouped or not?" is invisible to a unit test and
  obvious the moment you ask what a good day looks like. Decide what the product is, then re-read
  the code as if you were the user having a good week.

## 2026-09-01 — Iteration 9 (part 2): onboarding and local identity

- Goal: work items 1 and 2 of `plans/iteration-9-onboarding-local-identity-and-loop-fixes.md` —
  the four onboarding steps, and identity that is a profile plus a PIN rather than an account
  (ADR-010). Screens designed in Stitch against the existing Cya! design system asset, then
  implemented against §8.1.
- Done:
  - **Onboarding, four steps, in that order.** What Cya! is → the share gesture → notification
    permission → the OEM reliability checklist. Ordering *is* the design: both asks arrive after
    the reason for them is on screen (§3.5). There is no global skip — the two teaching steps have
    nothing to decline, and the two asking steps carry their own quiet way past, which is a
    different thing from a link that lets someone leave without ever meeting the share sheet.
  - **The share-gesture demo.** A looping, composited phone-inside-the-phone: a chat, a share sheet
    rising, the Cya! target lighting up under a tap ripple, and a "Saved · 0.1s" toast. Built from
    widgets rather than a video or a Rive file — it has to re-colour for dark mode, and the whole
    thing is four transforms. Under reduced motion it holds the frame where everything it teaches
    is on screen at once, rather than playing faster.
  - **The reliability step.** `DeviceReliability.kt` names the OEM (Xiaomi/Poco/Redmi → HyperOS or
    MIUI, Samsung → One UI, …), reports battery-exemption / exact-alarm / notification state, and
    opens the right settings screen from a per-OEM component list. Autostart is unreadable on every
    OEM, so it is recorded as something the user confirms, not something we detect — and the screen
    says outright that Android will not let Cya! change any of it. No red, no warning triangles: a
    reminder app that opens by telling you your phone is broken has picked a fight it does not need.
  - **Local identity (ADR-010).** Profile = display name + one of six glyphs. Lock = a 4-digit PIN
    as PBKDF2-HMAC-SHA256 (100k iterations, per-device salt, constant-time compare), an escalating
    cooldown after five failures (30s doubling to a 5-minute cap), and an optional fingerprint.
  - **Biometrics without a plugin (ADR-016).** `local_auth` would have required re-parenting the
    host activity and its themes to AppCompat — including `LaunchTheme`, the window background the
    two-second capture path paints against. The framework `BiometricPrompt` over the existing
    channel needs neither. API 28+; below that the PIN is simply the only way in.
  - **The lock is an overlay, not a route.** Drawn inside `MaterialApp.builder`, above the
    navigator. A `cya://promise/<id>` deep link therefore resolves *behind* the gate and is revealed
    by the PIN, instead of being lost to a lock screen that dumps the user on Home (§3.4).
    Re-locks after a minute in the background, not instantly — sharing into Cya! bounces through
    another app, and an instant re-lock would put a four-digit toll on §3.1.
  - **Fixed on the way past:** `ensureNotificationPermission` replied `false` the moment the system
    dialog opened, so a first grant always looked like a refusal. It now holds the
    `MethodChannel.Result` and answers from `onRequestPermissionsResult`.
  - Reachable afterwards: Profile → Privacy has the lock, the fingerprint switch, and removal —
    which asks for the PIN first, since a phone left unlocked on a table must not be able to disarm
    the thing protecting it.
- Verified / working: `flutter analyze` 0 · `flutter test` **165/165** (was 125) ·
  `flutter build apk --debug` exit 0, which is what proves the new Kotlin compiles. New tests:
  PBKDF2 against published RFC 8018 vectors (a *wrong* KDF round-trips perfectly well — it just
  isn't the one whose cost anyone has measured), lock policy, the whole onboarding flow, and the
  gate. `pubspec.yaml` gained exactly one package, `crypto` — pure Dart, offline — so "no network
  dependency is added" holds, and there is still no `INTERNET` permission.
- Broke / deferred:
  - **[L-007]** Every widget test that typed a PIN hung to the harness timeout with no error:
    `Isolate.run` never resolves inside `testWidgets`' fake-async zone. Cost me two wrong diagnoses
    (`pumpAndSettle`, then a never-settling animation) before the seam.
  - **[L-008]** The familiar `IntrinsicHeight` + `Spacer` scroll pattern cannot contain a
    `LayoutBuilder`; neither can `SliverFillRemaining(hasScrollBody: false)`. The error names the
    scaffold, several widgets from the cause.
  - **[L-009]** A 79px overflow on Home under `flutter test` at 400dp turned out to be the test
    font drawing ~1em per glyph, not a real defect. Kept the defensive `Flexible` + ellipsis on the
    OEM chip anyway, because a long device name at a 1.35 text scale can reproduce it for real.
  - **Not done, still outstanding:** SQLCipher at rest keyed from the Android Keystore — the third
    part of work item 2. The PIN proves who is holding the phone; encrypting the file is a separate
    job touching the shared schema and `CyaStore`, and belongs with the native contract rather than
    bolted onto a UI iteration. Also untouched this session: export/delete-all (§9.3, item 3),
    30-day aging (ADR-014), the reply-draft handoff (ADR-015), the instrumentation script.
  - **Two Stitch renders never came back.** The share-gesture and PIN-setup screens timed out on
    every attempt (three and one respectively) — both are the compositional ones, a device-in-device
    and a 12-key pad. The other five landed. Both were fully specified in the prompts and are
    implemented in Flutter regardless; only the static mock is missing.
  - **The Poco reboot question (D-4) is still unanswered and still gates everything.** This
    iteration built the fix; nothing here has met a physical Xiaomi. The per-OEM settings intents
    are undocumented and get renamed between skin versions, which is why every one of them resolves
    before it launches and falls back to a written path — but that fallback is also untested.
- Lesson / rule: the two hardest hours went to a hang and a layout assertion that both named the
  wrong widget. When a failure points at a scaffold or a `pumpAndSettle`, ask what *crosses a
  boundary* underneath it — an isolate, an intrinsic pass, a substituted font. The framework
  reports where it noticed, not where it went wrong.

## 2026-09-01 — Iteration 9 (part 3): encryption, privacy controls, and the rest of the plan

- Goal: finish everything iteration 9 left open — SQLCipher at rest (the remainder of work item 2),
  export/delete-all (item 3), 30-day retirement (item 4 / ADR-014), the reply-draft handoff
  (item 6 / ADR-015) and the instrumentation script (item 7) — then verify the whole app on a
  device rather than in the test suite.
- Done:
  - **Encryption at rest (ADR-017).** SQLCipher 4 on both runtimes, keyed with 32 random bytes
    sealed by an Android Keystore AES-GCM key and passed as SQLCipher's raw-key literal
    `x'<64 hex>'`. Raw rather than a passphrase because SQLCipher would otherwise run 256,000
    PBKDF2 rounds *per open*, and the Share Sheet path opens this database cold with no Flutter
    engine — measured result: capture stayed at **9–15 ms warm**. A pre-encryption file converts
    itself in place on first touch, built beside the original and swapped only once complete.
  - **Export and delete-all (§9.3).** Export writes the whole store as indented JSON into a cache
    directory and hands it to the share sheet through a `FileProvider`; the PIN's salt, hash and
    cooldown are withheld by a denylist checked in one place. Delete-all is guarded by a typed
    `DELETE`, cancels alarms *before* the rows go — an alarm is keyed by intention id and there is
    no way to find it again afterwards — and returns the app to onboarding.
  - **ADR-014 retirement.** Pending promises untouched for 30 days archive themselves with
    `{"reason":"aged_out"}`, announced once in the digest with one-tap restore that reschedules to
    now. Keyed on `updatedAt`, so anything snoozed or edited recently is safe.
  - **ADR-015 reply-with-draft.** A collapsed composer on Promise Detail hands the finished text to
    the source app. Cya! never sends, and the card says so.
  - **`tool/metrics.dart`.** Reads a data *export*, not the database — so it needs no device key,
    works off-device, and cannot drift from the format the user is entitled to.
- Verified / working: `flutter analyze` 0 · `flutter test` **183/183** (was 165) ·
  `flutter build apk --debug` exit 0. And, on an Android 14 emulator, an actual walk-through:
  all four onboarding steps, the permission dialog awaited correctly, the reliability checklist
  re-ticking Notifications after the grant, profile, PIN set/confirm, relock on restart, wrong PIN
  rejected, right PIN accepted, reply draft, export → share sheet → metrics script, and
  delete-everything returning to onboarding. The encryption was proved the only way that counts:
  the file header is noise rather than `SQLite format 3`, a native capture created and wrote the
  encrypted database with no Flutter engine running, and the Flutter UI then read all five rows
  back.
- Broke / deferred:
  - **[L-010]** `net.zetetic:sqlcipher-android` and `package:sqlite3`'s `source: sqlcipher` hook
    both ship a file called `libsqlcipher.so`. Android packaging keeps one; the winner had no JNI,
    so every Kotlin open died with `UnsatisfiedLinkError` while Dart worked perfectly. Fixed by
    moving Dart to `sqlite3mc` in SQLCipher-compat mode — a different filename, so both ship.
  - **[L-011]** Stock SQLite accepts every cipher pragma and ignores it, so a mislinked build would
    write plaintext that every layer above believes is encrypted. Both runtimes now assert the
    cipher is real on every open and refuse to write otherwise.
  - **[L-012]** 183 green tests did not catch either the native crash or an onboarding CTA pushed
    below the fold on a 1080×2400 screen. Ten minutes on an emulator caught both.
  - Fixed on device: the mascot's white asset background showing as a square on a mint circle; the
    share-gesture hero growing until it pushed "Got it" off screen (heroes are now capped at 340dp);
    a headline claiming "three switches" on a device that shows three rows, not four.
  - **Still outstanding:** no release keystore, no golden tests, iOS has no native side, and the
    home-screen widget has still never been seen on a launcher.
  - **The Poco/Samsung reboot question (D-4) remains unanswered.** Everything above ran on an
    emulator, which is stock Android — it detected itself as "Google", correctly hid the Autostart
    row, and therefore exercised none of the OEM-specific intents this iteration was built for.
    That is the one acceptance criterion that still needs real hardware.
- Lesson / rule: the two defects that mattered most this session were both invisible to the suite —
  one lived in the packaging of native libraries, the other in the size of a real screen. Green
  tests are evidence that the Dart logic is right, not that the app works. For anything with two
  runtimes in it, "done" means the engine-free path was watched running on a device.

## 2026-10-15 - Restore development after moving the checkout to C:

- Requirement / plan: restore the previous development environment without changing
  app behavior or dependency versions; see `plans/drive-c-relocation.md`.
- Root cause: the Flutter SDK at `D:\Flutter\flutter` was missing. User PATH,
  VS Code's explicit SDK setting, IntelliJ's SDK library metadata, and project build
  metadata retained its absolute path; build metadata also retained the old checkout.
- Repairs:
  - Restored Flutter 3.44.4 / Dart 3.12.2 at `C:\Flutter\flutter` from the official
    Windows archive, verifying SHA-256
    `8f2d6224fc6872d2f7f180de86cde989fcea3776efe0edf48a9aac2cd9be2b1b`.
  - Updated persistent user PATH, VS Code settings, ignored IntelliJ SDK metadata,
    and `android/local.properties`. Retained the valid Android SDK at `D:\Android`.
  - Ran `flutter clean`, archived the relocated project-local Gradle cache under
    ignored `.buildlog/gradle-before-drive-c`, and regenerated dependency metadata.
  - User enabled Windows Developer Mode for Flutter plugin symlinks and reviewed
    Android SDK licenses. `flutter doctor -v` now passes Android toolchain checks.
  - Added relocation guidance to README and ignored the project-local Kotlin cache.
- Verified:
  - `flutter pub get --enforce-lockfile`: exit 0; `pubspec.lock` unchanged.
  - `flutter analyze --no-pub`: zero issues.
  - `flutter test --no-pub --reporter expanded`: 183/183 pass.
  - `flutter build apk --debug --no-pub`: exit 0.
  - Debug APK installed on the Android 14 emulator. Onboarding rendered; a native
    share capture logged `capture_ok id=1`. The heavily loaded emulator initially
    timed out waiting for the debug first frame; a subsequent screenshot confirmed
    onboarding. These runs are functional checks, not capture-speed acceptance tests.
  - Every package_config file URI exists. Active configuration uses the C: checkout
    and SDK; hook stdout retains the invoking session's inherited PATH as log text.
- `flutter build apk --release --split-per-abi --no-pub`: exit 0. ARMv7 22.8 MB,
  ARM64 26.8 MB, x86_64 28.9 MB; ARM64 matches the previous recorded release size.
- A second native share capture succeeded with `capture_ms=106`.
- Installed the x86_64 release APK over debug without clearing app data. After a
  force-stop, native capture logged `capture_ok id=3 capture_ms=239`, confirming
  that the release native writer still opens the existing encrypted store after R8.
  Release UI hierarchy confirmed the onboarding headline, Next button and step 1
  of 4, with no AndroidRuntime/Flutter error logged. Launch timing was affected by
  emulator load; this does not verify the PRD cold-start performance budget.
- Limits / feedback: Visual Studio C++ tooling for Windows desktop is absent; this
  does not block the Android app. iOS/macOS builds cannot be verified on Windows.
  Automatic approval review rejected removal of the downloaded SDK ZIP as blocked
  by policy, so `C:\Flutter\flutter_windows_3.44.4-stable.zip` remains (about 1.8 GB).
  Restart existing terminals and VS Code to reload the persistent PATH.
- No application source or native capture behavior was changed. Existing unrelated
  untracked documents under `docs/revamp/` were left untouched.

## 2026-10-15 - Revamp foundation preflight (Iteration 10)

- User's phased implementation instruction authorizes bounded foundation work
  following the completed product-direction audit. Recorded ADR-018 to resolve
  the old Later/Pro model scope in favor of required offline text/audio semantic
  memory, preserve promises/native capture, and retain explicit migration approval.
- Plan: `plans/iteration-10-revamp-foundation-preflight.md`. Established canonical
  `docs/Cya_Product_Direction_PRD.md` from the supplied revamp proposal; preserved
  the proposal. No claim that new memory features are already implemented.
- Delivered: Android key-fetch errors/null/malformed keys now fail before a
  plaintext connection can be selected. Non-Android unsupported hosts retain
  explicit missing-plugin/null fallback. Existing native key literal is compatible.
- Delivered: app resume refreshes shared-table Drift streams and cached searches
  so native captures become visible without restarting Flutter. No polling,
  inference or native capture work added. Current reminder/relock behavior retained.
- Application/test files: `lib/native/database_key_port.dart`,
  `lib/data/db/cya_database.dart`, `lib/presentation/app/cya_app.dart`,
  `test/native/database_key_port_test.dart`, `test/widget_test.dart`.
- Documentation: canonical PRD, Master PRD logs/ADR/status, native contract
  (key/visibility behavior and stale v1 creation wording corrected), this log,
  iteration plan, proposed `plans/revamp-v3-memory-migration.md`, and
  `docs/revamp/EmbeddingGemma2_Android_Compatibility.md`.
- Verification: original key-error/Home regressions failed before fixes.
  Expanded tests include missing/null/malformed keys and native-like SQL captures
  in Home and cached search. Corrected test lifecycle sequencing and drained
  delayed entrance animation before disposal. Final results:
  - `flutter analyze --no-pub`: exit 0, zero issues, 8.8 seconds.
  - `flutter test --no-pub --reporter expanded`: exit 0, 189/189, 21 seconds.
  - `flutter build apk --debug --no-pub`: exit 0, Gradle 20.0 seconds.
  - `git diff --check`: exit 0. Ignored logs under `.buildlog/revamp-preflight-*`.
- Environment: Windows, Flutter 3.44.4/Dart 3.12.2 at C:\Flutter\flutter,
  Android SDK D:\Android, Temurin JDK 17.0.17.10, existing emulator API34 x86_64.
  No physical A52 connected; no phone performance measurement or new release run.
- Model compatibility research inspected actual LiteRT-LM 0.18.0 AAR/API and
  published POM graph. Runtime AAR 20,905,807 bytes, minSDK24, ARM64/x86_64,
  no manifest permissions; WAV audio input. Java21 classfiles/Kotlin2.4 metadata
  versus existing Java17/Kotlin2.3.20 are untested integration risks, not observed
  compiler failure. Configured audio initializes eagerly; omission of vision is
  supported. No weights downloaded, no inference/quality/thermal/RAM benchmark.
- Offline/network: no application dependency/permission or network code added.
  SDK graph inspection found no HTTP client; this is not runtime network proof.
  Airplane-mode and release merged-manifest checks were not rerun in this unit.
- Data impact: schema v2, all existing tables and native writer unchanged; no
  conversion/migration/import/deletion executed. Proposed additive v3 design is
  concrete for review and awaits the user's required explicit migration approval.
- Phase 1 remains incomplete: typed/audio memories, history/focus, required
  semantic indexing/search/related suggestions and versioned import/export remain.
  Next: approve migration design; build isolated exact-runtime compatibility POC
  and verify local artifact/license, then implement bounded foundation units.
  EmbeddingGemma 2 remains required and must pass actual offline/device evaluation.

## 2026-10-15 - Iteration11 typed memories and exact model proof

- User explicitly directed implementation (“start implementing the phases, go
  on”); proposed migration approved for staged execution. ADR-019 records the
  concrete schema/preservation decisions. No further approval requested for
  already-authorized foundation work.
- Delivered Home→Memories, typed save without tags/reminders, literal keyword
  search preserving Bangla vowel marks, immutable edit history, archive/restore,
  confirmed hard delete, chosen priority and dismissible post-save return prompt.
  No promise duplication, alarms, XP or retirement for neutral thoughts.
- v3 adds memories/revisions/events/jobs in both runtimes. Mutation/event/job
  atomicity, stale-edit protection, failure rollback, future-version refusal and
  actual Kotlin DDL column/FK parity have tests. Native upgrades now acquire a
  transaction before reading version and never swallow ALTER failures.
- Export format2 carries all thought revisions/events and keeps PIN redaction;
  existing erase includes new source-owned rows. Import/attachments are not
  implemented yet. Metrics script accepts v1/v2 unchanged promise/event shapes.
- Exact source files: new `lib/data/db/memory_tables.dart`,
  `lib/data/repositories/drift_memory_repository.dart`,
  `lib/domain/entities/memory.dart`, `lib/domain/repositories/memory_repository.dart`,
  `lib/presentation/providers/memory_providers.dart`,
  `lib/presentation/screens/memories/memories_screen.dart`; modified DB and generated
  DB/DAO bindings, intention DAO erase, core DI/router/paths, Home/Profile,
  privacy provider, DataExport, tool/metrics, native CyaDatabaseContract/CyaStore.
  Tests: native_contract updated, new memory_repository, memories and memory_privacy.
  Governing documents/iteration plans/contract/log updated in the same unit.
- Tests: focused22/22; full `flutter test --no-pub --reporter expanded`203/203
  (71s), then new privacy integration1/1 (4s). Analyzer zero issues (17.8s).
  `flutter build apk --debug --no-pub`exit0 (338.7s under concurrent host load).
  `--build-number=4002` rebuilt successfully (93.5s) after emulator rejected
  version1 over installed4001. No app data cleared/uninstalled.
- API34 emulator native-first migration/capture: id5/capture_ms1431 cold;
  subsequent id6/capture_ms60. Debug MainActivity launch reported timeout under
  load; no AndroidRuntime/Flutter error observed. A pre-upgrade run-as tar attempt
  failed because installed release was not debuggable; no recovery-backup claim.
  No physical personal-data rollout, new release app run or airplane-mode test.
- Exact-model POC: isolated ignored Gradle diagnostic package, LiteRT-LM0.18.0,
  AGP9.0.1/Kotlin2.3.20/JVM17, debug and R8 release builds succeeded in5m29s.
  R8 metadata warnings remain and are being addressed in Iteration12. Missing
  model correctly returned native NOT_FOUND; JNI ABI/API works on emulator.
- Downloaded public pinned model to developer workspace only,484,622,336bytes;
  SHA256e7a8a2204b91e0f96e92960e84a09a89212e1633dcb7575a9bf3378b4df77f4c
  verified. ADB-installed into diagnostic storage. No model download code in app.
  CPU2threads, vision omitted, float32: actual text and synthesized raw-WAV audio
  return finite normalized256d vectors, no ASR/transcript. Single-run init16,899ms,
  firsttext2325ms, nextquery790ms,1secondaudio3296ms; PSS snapshots33,079→250,607→
  440,928KiB. These are emulator diagnostics, not sampled peak, phone performance
  or multilingual/retrieval-quality evidence. Full report in revamp compatibility doc.
- No application package/network permission/dependency added in Iteration11.
  Public tooling/artifact downloads occurred on development host. Overall Phase1
  remains incomplete: voice, semantic app integration/related suggestions, full
  focus sessions, portable import, and hardware/quality acceptance still required.
  Continuing under `plans/iteration-12-required-semantic-memory.md`.

## 2026-10-15 — Iteration12 required semantic text integration

- Delivered lazy local EmbeddingGemma2 bridge, explicit digest-checked local model installation, durable versioned segment jobs/retry/rebuild, semantic search and related suggestion accept/dismiss with exact historical revision links. No inference on native capture or app startup.
- Exact SDK LiteRT-LM0.18.0; generic484,622,336-byte model pin/hash in compatibility report. CPU2threads, float32,256d, vision omitted. Runtime licenses bundled. No app network permission or downloader.
- Fixed real minified JNI crash (InputData stripped) with package-scoped keep rules; R8 9.1.56 handles Kotlin2.4 metadata without changing Kotlin/AGP/JVM.
- Schema4 additive vectors/links/job progress/event metadata, coordinated Kotlin/Drift, native-first and Dart-first migration fixtures. Existing promise tables preserved. Current voice work advances to schema5 separately.
- Files: android/app/build.gradle.kts, android/build.gradle.kts, app/proguard-rules.pro, assets/licenses, MainActivity, memory/EmbeddingBridge.kt; lib/domain/services/embedding_runtime.dart, native/embedding_port.dart, data/services/semantic_index.dart, data/db/memory_tables.dart and generated bindings, repositories/drift_memory_repository.dart, core/utils/local_id.dart, memory providers/screens, router/paths and privacy export. New semantic_index and embedding_port tests; diagnostic tool entrypoints. Full change list remains git diff (earlier relocation changes preserved).
- Tests: full213/213 (49s), later focused migration/port/WAV19/19. Analyzer0 (18.9s). Debug build199.6s. Production release splits236.1s: ARM64 49.1MB, x64 55.2MB, weights excluded. aapt release permissions contain no INTERNET/ACCESS_NETWORK_STATE.
- Actual app bridge airplane-mode smoke: two text sources indexed21,273ms including cold initialization; text query606ms expected source first; raw tone audio256d, text/audio cosine0.74666; disabled-model capture/keyword passed. Synthetic functional evidence only.
- Actual release multilingual seed:30 synthetic docs,30 queries per prefix. Official-card Hit@1 English10/10, Bangla10/10, Banglish6/10; Recall@5 .9667/.9333/.6333; warm query p50 459/442/445ms. Runtime-guide alternate prefixes same Hit@1, Banglish Recall@5 .6. Retain official prefixes; representative Banglish/speech corpus acceptance remains open.
- API34 x86_64 emulator only; release native-first capture id8/capture_ms761 cold. No A52 connection, battery/thermal or phone performance proof. Restored original emulator radios after experiments. No personal phone data migrated.
- Continuing voice in Iteration13. Required semantics are implemented for text, not declared complete: real speech retrieval, managed original audio, representative quality, device/scalability acceptance remain. No optionalization or model substitution.

## 2026-10-16 — Iteration13 original voice memories

- Delivered native foreground AudioRecord PCM16/16k mono (five-minute bound), explicit microphone permission, playback, background stop, interrupted .part recovery retaining original bytes. No SpeechRecognizer/ASR or model work on native promise capture.
- Managed immutable WAV files, SHA256/size/duration metadata, schema5 attachments and durable deletion-cleanup queue in both Kotlin/Drift. Finalization/integrity precedes source/revision/event/job commit; recording retries are idempotent. Optional captions are separate immutable revisions;20-second raw-audio segments are indexed without transcripts.
- Capture/review/recovery UI and model-disabled playback; app-private audio files are NOT encrypted, disclosed before recording/export. SQLCipher covers SQLite only. Backup/extraction exclusions follow no-cloud requirement (ADR022); OEM behavior not certified.
- Format4 complete readable ZIP streams originals and manifest/hash; missing/corrupt files fail instead of silent omission. Full erase stops recorder/model, queues cleanup and removes owned files/export caches. Public model weights retained.
- Files: native memory/VoiceBridge.kt, WavePcmFile.kt, privacy/ArchiveWriter.kt, DocumentShare/MainActivity, manifest/backup XML; Dart domain/audio, local_audio_files, attachment_cleanup, voice_port, audio_mapping, memory_tables/generated bindings, repository/index/providers, voice_capture_sheet, memories/Profile/privacy/DataExport/share bridge; contract/plans/ADR.
- Full Flutter tests225/225 (30s). Native :app:testDebugUnitTest five tests,0 failures/errors,2m49s. Debug8007 build29.9s; diagnostic8008 build20.2s.
- Actual airplane-mode app smoke: dumpsys active default network none; two text sources plus original synthetic tone WAV indexed17,072ms including cold initialization, text query426ms expected source first, direct text-query returns indexed raw-audio memory without transcript, original checksum unchanged and attachment deletion verified. Disabled-model capture/keyword pass. Log .buildlog/audio-semantic-airplane-smoke.log. Synthetic tone is NOT spoken multilingual quality evidence.
- Emulator only; A52 absent. Physical mic/phone, representative speech quality, battery/thermal, low-storage UX and final release checks remain. Analyzer had two braces lints in developer smoke (no app compile errors); cleanup continues. Latest diagnostic must be replaced by normal app. Shell AIRPLANE_MODE broadcast denied by OS; settings/wifi/data toggles worked and no-network confirmed; restored toggles afterward.
- Portable validated import continues in Iteration14. Overall Phase1 remains incomplete.

## 2026-10-16 — Iteration14 portable import validation

- Added local SAF selection, privately staged bounded ZIP/JSON reader, manifest SHA256 verification, strict attachment names, duplicate/path/unknown-entry rejection, actual decompressed size limits (10MiB manifest,9,600,044-byte audio,1GiB total) and streamed digest validation. No runtime network API or overwrite.
- Dart validates supported version, counts, IDs, source/revision/event/link/audio references, capture history, enums and attachments. Preview counts, explicit append copies, fresh identities/remapped refs, fresh semantic jobs and manifest repeat guard. Current PIN/settings/priority unchanged. DB/source/history/jobs commit atomically, failed commit removes only newly allocated audio files. Original export/user data untouched.
- Files: privacy/ArchiveReader.kt and ImportBridge.kt, MainActivity channel, native/import_port.dart, data/services/backup_import.dart, Profile import screen/entry, ArchiveReaderTest, backup_import_test and audio round-trip test.
- Host focused import/audio8/8 (3s), including integrity-preserving audio copies, failed import cleanup, original untouched, bad counts/references/version/duplicate revision rejection and transactional rollback. Native tests8/8,0 failures/errors, :app:testDebugUnitTest BUILD SUCCESSFUL2m53s. Analyzer0 issues58.2s before focus-session changes.
- Picker interaction/real device archive restore remains to validate; no claim from merely opening a chooser. Import file-selection cancellation/recovery does not alter existing rows. Staging uses private cache; crash leftovers are not uploaded. Full erase clears cache.
- Continuing full focus-session history as Iteration15/schema6/format5. Phase1 remains open pending representative semantic quality/device and final regression/recovery acceptance.

## 2026-10-16 — Iteration15 focus history and foundation validation

- Schema6 coordinated additive focus_sessions/focus_events in native and Drift. Session switch/end and append-only start/end events update atomically with current-priority preference projection. Legacy preference preserved as legacy_observed (migration observation time, unknown original start never invented). User can browse focus history; saving thoughts still commits before a dismissible return prompt.
- Format5 carries focus sessions/events with promises/audio/memories/links; importer accepts1–5, remaps histories and explicitly ends imported active session copies with import_ended. Current focus/settings/PIN preserved. Full erase includes sessions/events. No tracking/alarms/blocking introduced.
- Files: memory_tables and generated DB, cya_database/native contract, focus_repository, memory providers/screen, privacy/DataExport/backup_import/import UI, intention DAO erase, metrics format support, new focus_repository tests and updated contract/privacy tests.
- Full Flutter236/236 (71s), focused foundation32/32 (12s), then current legacy-focus/portable-audio/import/UI subset18/18 (8s). Analyzer0 issues38.4s before final legacy SQL. v4/v5 first-open fixtures preserve source bodies, model version/progress and legacy chosen priority, with foreign_key_check clean. Failure-injected focus event rolls back session/preference changes.
- ARM64/x64 release build in progress. A52 connected and authorized: SM-A525F/API34/arm64, MemTotal7668936KiB, MemAvailable3355912KiB at initial sample; USB powered,48% battery,30.9C battery sensor. Package check found no existing Cya! install; no user DB overwritten. Isolated minified probe installed and exact public model explicitly copied to Download (484622336bytes,18.890s transfer). Runtime/device results pending; do not infer success from transfer.
- Required semantic quality/phone/thermal and product UI/recovery gates remain open. Explicit connections/branches planned in Iteration16 after foundation functional gate; no semantic capability removed.

## 2026-10-16 — A52 production foundation functional gate

- Production release ARM64/x64 builds in433.5s (49.3/55.4MB). Manifest no INTERNET/ACCESS_NETWORK_STATE; existing alarms/notifications/boot/biometric plus explicit microphone only. Normal lib/main.dart installed on A52, not a diagnostic entrypoint. No app data cleared/uninstalled.
- Exact model imported through isolated probe SAF with digest verified. A52 SM-A525F Android14/API34 arm64, CPU2threads/float32/no vision: init2855ms, first text429ms, warm query337ms,1second synthetic WAV637ms; finite256d, norm1.00000040, text/audio cosine0.73458576, post-audio PSS550071KiB. Initial20,091KiB and post-init353,961KiB. Separate ADB sampling began after engine close (~169MiB), so it did NOT capture inference peak. Do not report it as peak-RAM proof.
- Battery snapshots USB charging49%,30.9C before installs,32.4C after short probe/setup. Charging/install confounded, no energy/thermal acceptance claim. Logs .buildlog/a52-initial-probe.log and a52-initial-memory.json.
- A52 production SAF import previewed/validated then restored synthetic ZIP (promise, original WAV, revision/event history, focus history). Success UI confirmed; no overwrite. Exact model installed through actual app local-file UI; status Semantic memory is ready. Production PSS673766KiB/RSS730516KiB after indexing. Text query 'a high pitched whistling tone' returned Voice thought with Audio match near0s, no transcript/caption. Proves integration, not spoken quality.
- Found import route nested under shell caused capture FAB overlap. Corrected Profile navigation to rootNavigator; next build carries fix. No global erasure on phone. Home/profile settings existed by UI check; absent pm path at initial check was not proof of absent historical/restorable data. Preserve current phone rows/settings and do not claim a personal-data backup/restore verification.
- Removed15 incidental formatter-only changes after exact comparison: formatting HEAD reproduced their entire current content, initial protected hashes checked. Kept all behavior changes. Emulator InterlinkQA shut down gracefully to relieve16GB host RAM pressure; persistent data retained, will restart for recording QA (host input explicitly off). Phone recording not automatically activated.
- Phase1 functional gate now passes for staged Phase2 implementation (plan16 records evidence). Representative multilingual/speech retrieval, sustained A52 measurements, process/recording/storage/reboot and final release acceptance remain required Phase3/4 work. Semantic memory remains mandatory; no budget/model downgrade.

## 2026-10-16 — user adds required routine/productivity scope

- Read both supplied attachments fully: updated50,234-byte v2 PRD and10,186-byte execution prompt. Preserved unchanged texts as docs/revamp/Cya_Product_Direction_PRD_v2_Routines_2026-10-16.md and Cya_Execution_Prompt_v2_Routines_2026-10-16.md. Canonical PRD receives an approved additive delta; original master/proposal visions not silently replaced.
- New required Phase1: real routines (weekdays/window/steps, pause/reorder/Today selection and explicit occurrence outcomes/recovery), optional factual daily/weekly review. Current focus sessions are NOT routines. Delta audit maps v2 FR10–12/22 and missing coverage. ADR024 resolves the proposal's stale audit-only starter against already-approved audit and user's continue/execute instructions; no repeated approval request.
- Finish in-progress schema7 connections to a tested contract, then implement routines in a separate additive schema8 unit per iteration17 plan. Do not undo previous authorized memory/semantic work. All no-network/native-thin/source/history invariants remain.
- A52 offline production check: first sample was taken before network settled (active network114), so inconclusive. Repeated with airplane enabled, WiFi/data disabled and wait for disconnect: Active default network:none, raw-audio text-query result visible; original airplane0/WiFi1/mobile1/Bluetooth1 restored and verified. Report .buildlog/a52-production-offline-settled.json. No physical microphone activation.

## 2026-10-16 — Iterations16–17 connections, routines and retained review copies

- Delivered explicit related/supports/contradicts/supersedes links, immutable branches with source selections, bidirectional version navigation, topic/project hierarchy and existing-promise assignments. Schema7 native/Drift parity, no second reminder/task engine. Nine connection tests cover atomicity, provenance, unchanged source, cycles, refs and remapped portable history.
- Schema8 adds routines, immutable routine_revisions/events, explicit routine_occurrences with optimistic change_version, before/after occurrence events and local_reviews associated with the existing Memory history/index. Weekday masks, preferred same-day windows, optional steps/fallback, reorder, pause/resume, reversible removal and manual complete/skip/defer/replan. No automatic Today workload/failure, inferred work or new alarm.
- Optional daily/weekly review uses actual recorded actions; note versions/jobs reuse Memory. Evidence-based suggestions require manual action. Import copies preserve current review with distinct import:UUID origin slots; a regression restores into a destination that already has a local review. No silent overwrite or dropped imported prose.
- Format7 includes routine/review history, validation/remapping of complete occurrence snapshot chains, and sorted original event IDs. Full erase removes owned tables. Local storage/status screen reports actual counts/sizes and discloses readable original audio/archives. Import preview reports routine/review counts and dated copies. Format8 later adds timer event vocabulary.
- Files: lib/domain/entities/routine.dart; data/db/routine_tables.dart and generated DB; repositories/routine_repository.dart, memory_connections.dart; services/routine_backup.dart, backup_import.dart; routine/memory providers; screens/routines/*, memories/{collections_screen,connection_picker,memories_screen}.dart; Profile import/storage screens; privacy/export/erase paths; native CyaDatabaseContract.kt; contract/docs/plans and repository/widget tests.
- Exact baseline: full Flutter260/260 in34s; analyzer0 in35.0s; Gradle :app:testDebugUnitTest8/8, zero errors/failures,1m42s. Native archive/PCM tests plus host coordinated migration fixtures. Release223.9s: ARM64 52,326,861bytes (49.9MB), x64 58,696,355bytes (56.0MB), version6011/8011. Release no INTERNET/ACCESS_NETWORK_STATE. Logs schema8-* under .buildlog.
- A52 upgraded in place schema6→8, normal entrypoint, no clear/uninstall. After the user unlocked existing app security, actual UI created QA evening reset without selecting Today automatically, then selected/completed it. Settled airplane-mode Active default network:none; explicit completion and factual daily review verified. All radios restored. Automated review-note save visibility assertion was inconclusive; do not report it as successful phone save proof.
- User then rejected the verbose UI and explicitly requested its own tab, cohesive visual/animated life planning and proper focus mode. Iteration19 replaces presentation while retaining these domain/event rules.

## 2026-10-16 — Iteration18 real A52 raw-speech retrieval evidence

- Isolated minified probe, pinned real EmbeddingGemma2/LiteRT-LM0.18.0, CPU2threads/float32/256d/no vision.20 public Google FLEURS clips (10English,10Bangla),204.86s total;60 positive queries (native references,20 Banglish text paraphrases and20 cross-language paraphrases) plus3 unrelated controls. Audio embeddings consume WAV only, without transcripts/captions. Text labels are evaluation/reference input separately.
- All60 positives ranked expected audio first among20 candidates; text-to-text same, audio→reference-text20/20. Not graded relatedness truth or spontaneous Banglish-speech acceptance. The earlier Banglish seed6/10 remains a counterexample; no broad perfect-quality claim.
- Engine init1424ms with OS caches warm; audio p502653ms/p955649ms for4.14–18.96s clips; warm query p50342ms/p95377ms; corpus97,561ms.27 independent RAM samples max541,311KiB (528.6MiB), in-process observed540,903KiB. Sampled maxima, not absolute peaks.
- Thermal status0 across readings, battery sensor32.5–33.2°C. USB charging16% throughout;100s cannot certify sustained heat or unplugged energy. No INTERNET; settled Active default network:none. Original0/1/1/1 radios restored and verified. A first launcher PID-read raced startup; added bounded wait and repeated successfully, no false failure claim.
- Source/pin/license/method/results/limits: docs/revamp/A52_Semantic_Benchmark_2026-10-16.md. Reproducible host fixture/probe/query files under tool/benchmarks. Personal data was not read/transmitted; no phone microphone activated.
- Remaining gates: held-out300-query/1000-source quality, spontaneous/noisy Banglish audio, independent relatedness,10k/50k responsiveness, sustained unplugged energy/thermal, physical recording/interruption/low-storage/reboot checks. Offline ASR is separate P1 feasibility; image/video staged in the same shared-space plan. Required semantic memory remains integrated, never optionalized.

## 2026-10-16 — Iteration19 visual Rhythm and durable focus room

- Explicit creator-approved presentation overhaul: five preserved-state Home/Promises/Rhythm/Garden/Profile branches; graphical day path from actual selections, seven-day picker, compact routine timeline cards, focus invitation, separate routine library/full-screen editor, recovery/history menus, optional graphical review with weekly bars and outcome legend. Reuses sage/mint, Plus Jakarta Sans and existing entrance/motion/haptic conventions; reduced motion renders still states.
- Focus room supports an independently chosen priority or selected routine,15/25/45-minute clock, persisted deadline, pause/resume/end and original steps. Existing focus_sessions/events plus preference projection, no DB migration/task engine/alarm. Expiry does not complete or end work. Stale rooms cannot end a changed priority. All state/event writes transactional, failure injection tested. Capture extracts/reuses the existing composer and save-before-return reminder; text stays exact and original audio capture remains unchanged.
- Format8 adds timer_started/paused/resumed/stopped; exports history but excludes running device-clock projection. Imports end copied focus histories, retain current priority and never activate imported clocks. Native schema remains8. Native capture/inference boundaries and network permissions unchanged.
- An end-floating capture trial covered a promise checkbox; the original regression caught it. Capture now occupies reserved48px navigation space. Five tabs remain accessible; no overlay over completion controls. Narrow light/dark enlarged1.35 text, reduced motion and focus save-first UI tests pass.
- Current exact final checks: flutter test --no-pub --concurrency=2 --reporter expanded274/274 in82s; flutter analyze --no-pub0 issues24.3s; latest focused focus/navigation16/16 in12s. Earlier full run272pass/1fail exposed the overlay and was corrected, not hidden by modifying the promise test.
- New core files: domain/entities/focus_timer.dart; data/repositories/focus_timer_repository.dart; screens/routines/{focus_room_screen,rhythm_visuals,rhythm_week_chart}.dart and redesigned day_plan_screen/routine_editor/routines_screen/review_screen; memories/memory_composer.dart extracted from existing screen; routine providers, router/paths and shell/nav; focus timer/domain/UI/navigation tests; format/export/import/metrics updates. Full final file inventory/limits in the implementation status report.
- Normal production ARM64/x64 build4012 in progress. Device visual/timer checks follow installation; no claim yet that the new visual release has passed physical-screen inspection or sustained60fps profiling.

- Build completed:414.9s, ARM64 52,327,609bytes/version6012; x64 58,762,639bytes/version8012. Both normal lib/main.dart. Release permissions unchanged, no INTERNET/ACCESS_NETWORK_STATE. A52 in-place install6012 succeeded; app security reactivated after update, so final UI checks wait for the user's unlock. No Cya! clear/uninstall. Separate dev.cya.embeddingprobe removed after evidence capture, freeing its public test model copy; Cya!'s installed model remains untouched.
- git diff --check exit0. Detailed behavior/files/migration/privacy/test/remaining acceptance report: docs/revamp/Revamp_Implementation_Status.md. Model results in A52_Semantic_Benchmark_2026-10-16.md. Independent low-storage/mic interruption/reboot, sustained performance and larger held-out quality still unpassed; no all-phases-complete claim.

## 2026-10-16 — creator correction: + centered and hovering

- Explicit latest direction rejects reserved end-nav +. Restored existing64px capture control to centerFloat above all five tabs. Kept original promise capture/toggle behavior and bottom list clearance. Position test checks horizontal center and vertical separation from tabs. Profile achievements test now scrolls its lower row to a hit-testable position above the creator-requested floating control; no hidden nav item or unreachable last row. ADR-027 records the decision overriding earlier placement.
- Corrected completed path-marker contrast to theme onPrimary with a vector check; shared font for numbered markers. No task/native capture/model/schema/dependency changes. Native schema8 and export8 unchanged.
- A52 actual6012 visual/focus checks after user unlock: five tabs/day/week visible, QA selected/completed occurrence present;15-minute independent chosen priority started; paused at14:21, room left/reopened with same value, resumed and explicitly ended/returned. QA focus ended, current priority initially empty and restored empty. No model/mic activation or data clear. Flags in .buildlog/a52-visual-focus-smoke.json.6012 does not carry the final centered +; corrected package follows.
- Developer-only tool/rhythm_visual_preview_test.dart renders light/dark with synthetic in-memory routines and loaded PlusJakartaSans/MaterialIcons. First render lacked icon fonts, corrected tooling; final previews inspected with real icons and vector marker. These are not phone screenshots or FPS measurements. Focused main navigation+render14/14 in8s. Final full/analyzer/release follow below.


## 2026-10-16 ? latest creator correction: compact corner +

Latest instruction supersedes the centered hovering decision (ADR-028). Capture
is now a 48px rounded square at bottom-right, solid theme primary/onPrimary,
16px edge inset, softer shadow and smaller28px icon. All five tabs retained.
Press feedback respects reduced motion. Original capture flow unchanged.
Short-viewport test initially reproduced a floating overlap with the promise
checkbox; regression now verifies that scrolling reaches the original control
and completion persists, alongside Profile-row reachability. This is a normal
floating overlay, not a promise-state change. Light/dark synthetic renders inspected.
Final checks/package recorded in the implementation status report. No schema,
model, permissions, dependency or native capture changes.


Final corner package: `flutter build apk --release --no-pub --split-per-abi
--target-platform android-arm64,android-x64 --build-number 4013 -t lib/main.dart`
passed in116.0s. Normal entrypoint; ARM64 version6013,52,393,145bytes;
x64 version8013,58,762,639bytes. Release manifest has no INTERNET or
ACCESS_NETWORK_STATE permission. Current artifact SHA256:

- ARM64: `91e6ebf9e9f22037e6335b0d5c393458df231676e6631864154c86b946188f91`
- x64: `2669850361eb0ac104be567d06db865a70a4dffa6aa2dd32b98f302c095c91a4`

Full274 tests passed71s; analyzer0 issues18.1s; synthetic light/dark preview2/2
passed5s; diff-check0. Earlier centered4013 build was never installed and is now
replaced by the corner artifacts. No app clear/uninstall. Final position checked
in rendered synthetic layouts; no new physical unlock/GUI proof is claimed.

A52 in-place install succeeded (`adb install -r --no-streaming`); package manager
confirms version6013. Existing app data retained; no clear/uninstall performed.


## 2026-10-16 - Iteration20: visible memory and voice journaling

- User reports a genuine product gap: implemented voice capture is hidden behind
  a small Home link and unlabeled toolbar action; global + only captures promises.
  ADR-029 makes Memories a preserved main tab. Five tabs: Home, Memories, Rhythm,
  Promises, Profile. Garden remains via Home/Profile and week landscape with back.
- Home/Memories expose labeled Record voice and Write a thought. Corner + opens
  voice/text/promise chooser. Focus also exposes voice capture. No mic starts on
  navigation. Native share/tile/widget unchanged. Thought editor is full screen,
  preserves exact text/earlier versions and confirms unsaved draft discard.
- Recorder shows actual elapsed time/max5min, explicit stop/save/review, original
  playback, kept-original recovery and discard confirmation. Permission failure
  offers existing Android app-settings handoff and a usable typed fallback.
  Voice journal cards show actual stored duration/dates, play/stop and version,
  connections/branch/actions. Keyword/Semantic and All/Voice/Written filters.
- Accepted immediate-link map is bounded to6 nodes, with full navigable list and
  explicit provenance retained; suggestions stay separate/reviewable. Topics,
  model/install/status, import/count preview and storage views match the palette.
  Theme defines all surface-container roles; final visual review removes the
  heavy default search elevation. No fake sound levels, tracked work or analytics.
- Home/Focus/global capture previously queued without starting the worker until
  Memories opened. Post-commit notice now resumes lazy index; worker lifecycle
  observer pauses/unloads on background and resumes on return independently of
  current tab. Capture remains source/event/job first. No model on opening
  capture UI; test embedding verifies source/event already committed.
- Fix delayed Entrance timer cleanup on dispose. Initial UI tests exposed lazy
  offscreen row expectations and horizontal search-scroll selection; tests now
  actually scroll vertical content and reach controls, without hiding failures.
- Tests: full285/285 in47s; final voice/memory/exploration+render16/16 in9s after
  last visual correction; analyzer0 in7.6s; native JUnit8/8,0 errors/failures42s.
  Full suite uses --no-pub --concurrency=2 --reporter expanded; all Flutter commands
  use --no-version-check to avoid a stalled SDK version probe. A concurrent preview
  attempt hit Windows sqlite3mc.dll test-file locking and was rerun after suite
  completion. No dependencies changed. Initial failed checks are not final passes.
- Visual proof: tool/journal_visual_preview_test.dart renders synthetic Home,
  memory library/cards and recorder light/dark with bundled fonts/icons. Not
  phone screenshots or physical mic/performance evidence. Screenshot artifacts
  .buildlog/journal-{home,library,entries,recorder}-{light,dark}.png.
- No schema or portable format change (8/8), no new dependency/permission/network
  call or native inference/capture change. Existing personal-phone data untouched.
  ADB currently has no devices; final installation requires reconnection.
- Remaining gates and exact feature paths: docs/revamp/Navigation_and_Release_Checklist.md.
  Required semantic memory remains integrated. Larger judged multilingual/Banglish,
  relatedness, sustained energy/thermal/large-index and physical mic/interruption/
  storage/reboot validation remain unpassed. Staged offline ASR/image-video not
  presented as implemented. Existing promise reminders remain; this unit adds no
  routine-window/focus-end alarms. Do not claim all phases accepted.


### Iteration20 final release artifacts

Normal `lib/main.dart` entrypoint, build4014: `flutter --no-version-check build apk
--release --no-pub --split-per-abi --target-platform android-arm64,android-x64
--build-number 4014 -t lib/main.dart` passed in65.6s after final search styling.
Earlier first packaging passed134.7s and is superseded by this exact rebuild.
ARM64 version6014 and x64 version8014. Manifest inspection confirms no INTERNET
or ACCESS_NETWORK_STATE; existing microphone/notification permissions retained.

| Artifact | Bytes | SHA256 |
|---|---:|---|
| build/app/outputs/flutter-apk/app-arm64-v8a-release.apk | 52459809 | bdc5218407fa8f4b96bb98b61772d45caa28023c4d66baef45028600c8885daf |
| build/app/outputs/flutter-apk/app-x86_64-release.apk | 58894839 | c0072308e258a2d2af732f6c1d26cb2d05df741a6dd8aca048073a8e3acd5b73 |

ADB lists no connected device at final check. **This release is built but not
installed on the A52**; the previously installed release is6013. No phone data
was cleared, replaced or uninstalled. Physical checks of this exact UI and
intentional microphone recording still require the reconnected authorized phone.
No updated real-device latency/RAM/thermal result is claimed for this build.


## 2026-10-17 - A52 release6014 installed after reconnection

- Authorized Galaxy A52 R58RA47Q09L/SM-A525F reconnected. Verified ARM64 APK against
  SHA256 bdc5218407fa8f4b96bb98b61772d45caa28023c4d66baef45028600c8885daf.
- `adb -s R58RA47Q09L install -r --no-streaming ...` succeeded; package manager
  confirms versionCode6014/minSDK24/targetSDK36. Existing data retained; no
  uninstall/clear, no migration, no app source changes or rebuild this unit.
- MainActivity launches and is resumed. Android device keyguard is not showing,
  but Samsung's biometric package displays Cya!'s existing unlock prompt. Initial
  UI smoke cannot inspect the app beneath that prompt. User asked to unlock;
  no PIN/biometric bypass or credential collection. No microphone was activated.
- UI entry/recorder checks await unlock, not reported as failed functionality or
  passed checks. Evidence .buildlog/a52-release6014-navigation.json. Prior host
  tests/build/permission verification remain applicable to this exact APK.


## 2026-10-17 - Iteration21 Garden doorway and visual Profile

- Explicit creator request: keep Garden visually present on Home and accessible
  from Profile, with more Profile visualization. Shared GardenDoorway replaces
  the Home text shortcut near the top and the Profile plain row. Reuses the
  actual GardenSceneView, event-derived plants/counts, current-time sky and full
  Garden route/back. Miniature painting capped16, one-shot growth, no wind loop.
  Existing Home week landscape/statistics remains available.
- ProfileIdentityVisual adds an animated XP/avatar ring and current level, using
  original projections. ProfileMilestones shows earned/total and three actual
  badge progress circles; opens full achievements. Existing settings, review,
  memory/model, lock and data controls retained below. Dark-mode switch uses
  the theme's inactive colors. No schema/data/dependency/native/network changes.
- New tests prove both Home/Profile Garden entrances and back paths, reactive
  event-backed plants/milestones, 320px enlarged light/dark reduced-motion layouts
  and settings reachability. Old short-screen expectations were updated to scroll
  to now-lower promise counts; initial failures were lazy layout expectations,
  not suppressed tests. Full289/289 in54s; analyzer0 in7.8s; focused navigation+
  new Profile tests+render18/18 in10s before final minor switch styling. Native
  source unchanged; prior8 native tests not rerun for this presentation-only unit.
- Synthetic previews expanded with real fixture resolution events, Home garden,
  Profile header and milestone views. No private phone screenshots or fake saved
  growth in production. tool/journal_visual_preview_test.dart.
- A52 release6014 physical navigation smoke now passed after user unlock: Home
  voice/text actions, Memories tab/header, visible recorder, explicit Start/off
  copy, close without starting mic, return Home. Prior pending unlock resolved.
  New release4015/ARM646015 packaging/install results follow separately.
- Files: lib/presentation/widgets/garden_doorway.dart;
  screens/profile/profile_visuals.dart and profile_screen.dart;
  screens/home/home_screen.dart; test/widget_test.dart;
  test/presentation/garden_profile_test.dart; tool/journal_visual_preview_test.dart;
  Master ADR-030/living log, iteration21 plan, BUILD_LOG, navigation checklist and
  implementation status. No changes to native capture, semantic runtime or DB.


Iteration21 final package: normal lib/main.dart release build4015 passed116.1s;
ARM64 version6015/x64 version8015. Final synthetic preview2/2 passed6s after
switch styling; full289/28954s and analyzer0/7.8s apply to final source. Manifest
has no INTERNET/ACCESS_NETWORK_STATE permission; existing permissions unchanged.

- `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`: 52459937bytes, SHA256 `380de6be315015648afdf68f0096af292a29b81f4357ecddd5f91df8fc663875`.

- `build\app\outputs\flutter-apk\app-x86_64-release.apk`: 58894967bytes, SHA256 `66c1b46f0081dc5f1bf96022058439fed6f434f7e87d8d9948e36837617d3552`.

No data migration, model/runtime or new native code. Exact installed/device status follows.


17 October2026 installation closure: A52 in-place `adb install -r --no-streaming`
succeeded, package manager confirms6015. No Cya! clear/uninstall. Initial device
UI probe encountered a transient ADB CalledProcessError; reconnection transport
refreshed and MainActivity launch confirmed. Retried probe is blocked by the
existing app/device lock surface. No credential bypass, mic activation or data
mutation. Final Garden/Profile physical GUI is unverified pending normal unlock;
host navigation/back/data/reduced-motion/render coverage is green. Prior6014
voice/navigation physical smoke remains valid for those unchanged entry flows.
Evidence .buildlog/a52-release6015-garden-profile.json. Exact final files changed
in this unit: garden_doorway.dart; profile_visuals.dart; home_screen.dart;
profile_screen.dart; widget_test.dart; garden_profile_test.dart; expanded
journal_visual_preview_test.dart; iteration21 plan; BUILD_LOG; Master PRD ADR-030,
module/session/lesson/test logs; navigation checklist; implementation status.


## 2026-10-23 ? Iteration22: comprehensive emulator QA and regression fixes

- Synthetic API34 CyaQA_20261023/emulator-5560 only; no physical phone targeted,
  personal data cleared, schema/dependency change or new network permission.
- 27 distinct normal-release UI cases passed: original voice capture/playback and
  interrupted recording recovery; multilingual text/keyword search; immutable
  history/branch; routines/focus/review; Garden navigation; actual native share,
  PROCESS_TEXT, RemoteViews PendingIntent, system tile and scheduled notification
  delivery/Done. Full matrix, incomplete cases and synthetic evidence are in
  docs/qa/Emulator_QA_2026-10-23.md; raw evidence remains ignored under .buildlog.
- Fixed completed promise false overdue presentation (list and detail, two
  red-to-green regressions) and lost saved routine occurrence when reopening
  focus (one red-to-green regression, focused5/5). Original reminder/history and
  explicit routine completion semantics preserved; no DB migration.
- Final flutter --no-version-check analyze --no-pub: no issues,321.2s. Final
  flutter --no-version-check test --no-pub --concurrency=1:292/292,11m03s.
  Native offline testDebugUnitTest with one worker/2GB heap:8/8,zero failures or
  errors,7m53s. Python QA scripts compile. Long durations reflect severe shared
  host RAM pressure; they are not app performance measurements.
- Software-rendering QEMU access violations and later accessibility/graphics
  instability retained as environment failures, not mislabeled app/PIN defects.
  Creator chose to leave a competing build running; it was not stopped.
- At least6?7 meaningful commits and push explicitly authorized. GitHub account,
  local author and committer verified as Adi-Sin101; no coauthor trailer. Six
  completed units separate direction/contracts, implementation, native fixtures,
  urgency fix, guarded UI workflows and QA report/evidence. Final delivery and
  fresh release results follow; do not infer a push or install from this entry.
- Remaining gates include actual PIN GUI/backup round trip, pinned-model
  production UI retrieval/index lifecycle, physical microphone/biometric/OEM
  delivery and named-device thermal/battery/held-out multilingual quality.
  Semantic memory is required. Focus/routine end alerts and offline ASR are not
  certified as delivered by this pass. See the report for precise limitations.


### Iteration22 closure ? 24 October2026

- Normal lib/main.dart release4016 passed753.7s. ARM646016:52459937 bytes,
  SHA25609e6a62d04b09714024344d1bdb99097edcaae7168d92571947bc8ae2960768f.
  X648016:58894967 bytes,
  SHA256ec7ed330ca779bde33cc4425daf684553f1ea361e28c36a6b476770714c4720c.
  aapt confirms minSDK24/targetSDK36 and no INTERNET/ACCESS_NETWORK_STATE on both.
- Final fresh AVD eventually booted, but Android System UI ANR and package-manager/
  accessibility stalls prevented verified update installation and further UI
  acceptance. Last observed installed8015, no8016 success result. Stopped only
  dedicated CyaQA_20261023; host resource failures remain distinct from app bugs.
- 27 passing earlier emulator cases and final292 Flutter/native8/analyzer0 are
  bounded results. PIN, real export/import, production model/retrieval, reboot
  and additional edge cases remain open, listed in the QA report. No all-phases
  or every-feature-perfect claim. Required semantic acceptance remains required.
- Final delivery groups the authorized work into seven meaningful conventional
  commits, author/committer Adi-Sin101, no coauthor. No APKs, model binaries,
  exports, credentials or personal-phone data in Git. Verify ordinary push and
  remote SHA before reporting completion to the creator.
