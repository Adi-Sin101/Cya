# Iteration21 — visible Garden and visual Profile

17 October2026. Implements the creator's explicit Home Garden/Profile request,
Master design §§8–9 and the retained Garden requirement in ADR-029.

## Plan and acceptance

- Replace the Home text-only Garden entry with a prominent painted preview near
  the top. Keep the existing week summary and full Garden route/back navigation.
- Reuse that preview on Profile, with an XP/avatar progress ring and visual
  achievement milestones. Data comes from existing event-backed projections.
- Retain all settings, privacy/data tools, memory navigation and five main tabs.
- No invented growth, streaks, fake activity, model work, schema or dependency.
  Preview scenery is bounded and has no looping wind; motion respects preferences.
- Test both entrances/back paths, live growth, Profile settings/achievements,
 320px/enlarged light/dark/reduced motion. Render synthetic previews, analyze,
 full tests and normal release APK, then update the authorized A52 in place.
- Record exact installation and screen proof; never bypass biometric security.

## Prior device check

User unlocked release6014. A52 smoke passed Home voice/text entry, main Memories
tab, journal header, visible voice action, recorder explicit Start/off copy,
close without mic activation and return Home. No new audio or personal content
created/read. The new Garden/Profile presentation is validated separately below.


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
