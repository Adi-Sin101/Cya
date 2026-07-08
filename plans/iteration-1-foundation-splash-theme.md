# Iteration 1 — Foundation: Design System, Native Video Splash → Home

- **Implements PRD:** §8.1 (design system), §8.2 (Home), §8.3 (motion), §5.2/5.3 (native boundary,
  layering), §9.1 (performance + beauty), Phase 0 foundation (§10).
- **Depends on:** none (first feature iteration; repo was a fresh scaffold).
- **Status:** ✅ Done · 2026-07-08 — all acceptance criteria verified on emulator (API 34). See
  `plans/BUILD_LOG.md` and PRD §13.5.

## Context / requirement analysis

Cya! was a default Flutter counter app. This iteration ships the foundation of the real app: the
design system (colors + Plus Jakarta Sans), a **fully-native Android animated splash** that plays
`Cya_splash.mp4` *before the Flutter engine boots*, and the **full designed Home screen** the splash
hands off to. Establishes the visual identity and app shell for all later phases.

Two confirmed product decisions:
1. Splash = **fully-native Android** — a Kotlin `SplashActivity` plays the mp4 before Flutter boots.
2. Home = **full designed static screen** (mock data now; wired to Drift in a later phase).

## Approach / design

### A. Native Android video splash (flash-free)
- Player: `TextureView` + framework `MediaPlayer` (center-crop `Matrix`). No Media3/ExoPlayer —
  avoids an AndroidX dep graph against AGP 9.0.1 / Gradle 9.1 / Kotlin 2.3.20 for one short H.264 clip.
- Flash-free chain: Android-12 OS splash branded (`values-v31`) → `SplashActivity` window = the still
  frame (`cya-splash.jpeg`, matches video frame 1) → `TextureView` alpha-revealed on first rendered
  frame → pre-warmed cached `FlutterEngine` (built in `CyaApplication` during playback) makes
  `MainActivity`'s first frame instant → `MainActivity` warm-up window painted the Home background.
- Video lives in `res/raw` only (native), **not** double-bundled in pubspec.
- Robustness through one idempotent `proceed()` (AtomicBoolean): error fallback, ~6s safety timeout,
  tap-to-skip, reduced-motion (`ANIMATOR_DURATION_SCALE == 0`) skip, lifecycle release, no-anim handoff.
- Audio muted by default.

**Native files:** create `CyaApplication.kt`, `SplashActivity.kt`, `res/raw/cya_splash.mp4`,
`res/drawable/splash_still.jpg`, `res/values/colors.xml`, `res/values-night/colors.xml`,
`res/values-v31/styles.xml`. Modify `MainActivity.kt` (cached engine), `AndroidManifest.xml`
(launcher → SplashActivity, `.CyaApplication`, MainActivity not-exported), `styles.xml` +
`values-night/styles.xml` (SplashTheme; LaunchTheme/NormalTheme bg → `@color/app_background`),
`launch_background.xml` (+ `drawable-v21`).

### B. Flutter foundation
Layering per §5.3. `core/theme` (color tokens, M3 light+dark ThemeData, `CyaColors` ThemeExtension,
Plus Jakarta Sans typography); `core/router` (go_router `StatefulShellRoute.indexedStack`, 4 branches
+ docked FAB `CaptureSheet` stub); `presentation/` app + shell + designed Home with sub-widgets
(greeting/level badge, Today card w/ CustomPainter completion ring, promise tile + preset chip +
toggle, garden preview, week stats) + placeholder Promises/Garden/Profile; `domain/models` plain
immutable classes (no freezed yet); `data/mock` single source of Home mock data. `RepaintBoundary`
around painted subtrees; small const widgets. `MaterialApp.router`, `ThemeMode.system`.

### C. pubspec
Add `flutter_riverpod` + `go_router` only. Declare `cya-logo.png`, `cya-splash.jpeg` assets (mp4 is
native-only). Bundle Plus Jakarta Sans TTFs (400/500/600/700) into `lib/assets/fonts/` — fetch-then-
declare; offline fallback = omit block + M3 default type with `// TODO(font)`.

## Acceptance criteria (must pass)
- `flutter analyze` → 0 issues; `dart format` clean.
- Cold start: branded OS splash → video fullscreen, center-cropped, **no white/black flash** →
  seamless cut to designed Home.
- Tap-to-skip works; reduced-motion skips video; bad-video error still lands on Home.
- Dark mode renders M3 dark theme + `values-night` warm-up background.
- Home scrolls jank-free (`--profile`); CompletionRing repaint isolated by RepaintBoundary.
- `flutter build apk --debug` succeeds under the current toolchain.

## Risks / open items
- Bleeding-edge toolchain (AGP 9 / Gradle 9.1 / Kotlin 2.3.20 / Dart 3.12) — verify a clean build early.
- Dark Surface2 `#243137` still "confirm" (PRD §13.6). Splash audio muted (default). `com.example.cya`
  rename deferred. Center-crop assumes key video content in a center safe zone.

## Feedback
See `plans/BUILD_LOG.md` for execution/testing outcomes and lessons.
