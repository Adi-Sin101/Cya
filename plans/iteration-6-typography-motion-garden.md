# Iteration 6 — Typography, motion, and a garden worth opening

**Date:** 2026-08-31
**Branch:** `feat/phase-0-store-and-native-capture`
**Derives from:** PRD §8.1 (design system), §8.3 (motion), §8.4 (accessibility),
§9.1 (performance AND beauty), §3.6, §6.5 (enrichment), §13.6 (open questions).

## Requirement analysis

Phase 0 and Phase 1 are functionally complete, but the app *reads* like a
spreadsheet with a good data model behind it. Five things are asked for:

1. **Typography much bigger and better.** The current scale tops out at 34/24/16
   and leans on 12–14px supporting text. On a phone held at arm's length that is
   a squint. The scale needs a real jump and a real hierarchy.
2. **Motion + haptics.** Today only two things animate (the toggle, the garden's
   one-shot grow-in) and exactly one haptic exists (capture save). PRD §8.3 asks
   for micro-interactions everywhere and reward moments.
3. **The garden must be beautiful.** It is "the emotional core of retention"
   (§8.2) and is currently five flat plant shapes on a brown bar.
4. **Less clutter, lower cognitive load.** Home stacks 6 competing blocks; the
   Promises screen shows 3 filters + 7 category chips + a search bar before a
   single promise.
5. **Finish what's left**, and prove the app actually works.

## Decisions taken here

- **ADR-007 — reward animations are Flutter, not Rive.** §8.3 specifies Rive,
  but no `.riv` asset exists and authoring a mascot rig is a design job, not an
  engineering one (§13.6 open question). Particle/petal bursts painted by a
  single `CustomPainter` behind a `RepaintBoundary` cost less than a Rive
  runtime + asset, need no new dependency, and are data-driven all the same.
  Revisit if/when mascot art is produced.
- **Text scaling is clamped to 0.85–1.35.** §8.4 asks for scalable text; an
  unbounded scaler on a 44px display style destroys every layout. Clamping keeps
  the promise honest without shipping broken screens.
- **Enrichment is rule-based on-device Dart, not ML Kit.** §6.5 allows either;
  a deterministic date/category parser in an isolate is testable, has zero model
  download, and keeps the capture path untouched (§3.2). ML Kit stays open for
  Phase 2+ if the rules prove insufficient.

## Scope

### A. Design-system foundation (`lib/core/theme/`)
- New type scale: display 44/36, headline 30/26/22, title 20/18/16, body
  18/16/14, label 15/13/12. Optical letter-spacing on the large end.
- `AppMotion` — duration + curve tokens, one place to tune feel.
- `AppSpacing` — spacing and radius scale, kills the magic numbers.
- `CyaHaptics` — the only place `HapticFeedback` is called, honours reduced
  motion.
- Component themes sized to the new scale (buttons ≥ 52dp, chips ≥ 44dp).

### B. Motion primitives (`lib/presentation/widgets/motion/`)
`EntranceStagger`, `PressableScale`, `AnimatedCounter`, `RewardBurst`.

### C. Garden rewrite
Layered painted scene: time-of-day sky, parallax hills, textured soil, 8 plant
species with gradients and ground shadows, continuous wind sway, fireflies at
night, one-shot grow-in for new growth. One controller, one painter, one
`RepaintBoundary` per bed; static when reduced motion is on.

### D. Declutter
- Home: 6 blocks → 4, level folded into the header.
- Promises: filters collapse into one row; category filter moves behind a chip.
- Detail: single action bar, quieter supporting cards.

### E. Finish the remaining work
1. On-device enrichment (date extraction + auto-categorization) in an isolate,
   strictly off the capture path.
2. Reward moments: resolution burst, level-up, achievement unlock.
3. Midnight rollover (day boundary currently read once at provider build).
4. Real "Open in <source app>" handoff over the existing method channel.
5. Display-name setting (the greeting has no way to learn your name today).
6. `applicationId` off the `com.example` placeholder.
7. Golden tests for core screens, light + dark.

## Acceptance criteria

- `flutter analyze` — 0 issues; `flutter test` — all green, new tests added for
  enrichment, midnight rollover, and the garden scene.
- Every interactive control gives haptic + visual feedback within 120ms.
- Reduced motion (`MediaQuery.disableAnimationsOf`) yields a still, complete UI
  on every animated surface — verified by test.
- Garden holds 60fps with 200+ plants on the emulator.
- Capture path untouched: no enrichment, network, or inference on it (asserted
  by the existing native contract test plus a new use-case test).
- App installs and runs on the emulator; every screen visually verified by
  screenshot.
- PRD §13.1 / §13.3 / §13.4 / §13.5 and `plans/BUILD_LOG.md` updated.
