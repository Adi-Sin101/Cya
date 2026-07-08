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
