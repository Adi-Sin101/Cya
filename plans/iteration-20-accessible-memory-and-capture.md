# Iteration 20 — visible memory, voice journal and complete capture navigation

16 October 2026. Implements approved direction §§7–8 and the creator's explicit
request that delivered voice/memory features be reachable in the actual app.
Depends on implemented iterations 10–19; validation gates remain honestly open.

## Requirement analysis

Memory capture is hidden behind a small Home link. The corner + only opens the
old promise composer. Voice is an unlabeled toolbar icon on a secondary screen.
Storage functionality alone does not meet the usable-product requirement.

## Explicit design decision

Five preserved tabs: Home, Memories, Rhythm, Promises, Profile. Garden remains
available through the existing Home week landscape and a labeled Home/Profile
entry, with back navigation. This supersedes the original five-tab composition,
not Garden's functionality. Corner + opens a labeled capture chooser: voice,
thought, promise. Native share/tile/widget capture stays unchanged.

## Implementation

- Visible Home voice/text/library entry and labeled memory actions.
- Memory journal with coherent sage surfaces, type icons, original-audio playback,
  dates, history, explicit connections/branches, archive, semantic/keyword search,
  model management and topics/projects. Preserve every existing operation.
- Voice recording room with elapsed-time visual (not invented sound levels),
  explicit start, stop/save/review, original playback, discard confirmation and
  interrupted-recording recovery. No microphone starts on navigation.
- Responsive scrollable layout, reduced motion, light/dark, accessible labels.
- Trace reachable routes for focus, routines/recovery/reviews, promises/Garden,
  model install/index rebuild and data/privacy tools. Repair disconnected paths.

## Acceptance

User-visible tests start from real CyaApp navigation and reach voice, typed memory,
promise capture, original playback, archive/history/branch/topics and settings.
Mocked native recording proves save→event→index job, denial recovery and no mic on
open; actual phone microphone testing requires intentional user audio. Model is
never required to save. Light/dark narrow/enlarged/reduced-motion checks and visual
previews; full tests, analyzer, normal minified release, in-place A52 update.
No schema migration/new network dependency/permission. Record exact results.

## Remaining phase acceptance

Required text/audio semantic engine stays integrated. Larger judged multilingual
and spontaneous Banglish quality, sustained unplugged energy/thermal, recording
interruptions and low-storage/reboot device checks must be measured; no UI change
can certify them. ASR and image/video remain staged per approved P1 scope until
their local artifact/runtime/quality feasibility gates pass. Do not present mock
ASR, fake graph relationships or untested model paths as complete.


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

## Exact files touched in this unit

- `lib/core/router/app_router.dart`
- `lib/core/theme/app_theme.dart`
- `lib/presentation/providers/memory_providers.dart`
- `lib/presentation/shell/home_shell.dart`
- `lib/presentation/shell/widgets/cya_bottom_nav.dart`
- `lib/presentation/widgets/motion/entrance.dart`
- `lib/presentation/widgets/local_feature_header.dart`
- `lib/presentation/screens/home/home_screen.dart`
- `lib/presentation/screens/capture/capture_hub.dart`
- `lib/presentation/screens/capture/capture_sheet.dart`
- `lib/presentation/screens/memories/journal_capture_card.dart`
- `lib/presentation/screens/memories/memories_screen.dart`
- `lib/presentation/screens/memories/memory_journal_tile.dart`
- `lib/presentation/screens/memories/memory_composer.dart`
- `lib/presentation/screens/memories/voice_capture_sheet.dart`
- `lib/presentation/screens/memories/voice_recording_visual.dart`
- `lib/presentation/screens/memories/memory_connection_map.dart`
- `lib/presentation/screens/memories/connection_picker.dart`
- `lib/presentation/screens/memories/collections_screen.dart`
- `lib/presentation/screens/memories/local_model_screen.dart`
- `lib/presentation/screens/routines/focus_room_screen.dart`
- `lib/presentation/screens/profile/profile_screen.dart`
- `lib/presentation/screens/profile/import_backup_screen.dart`
- `lib/presentation/screens/profile/storage_diagnostics_screen.dart`
- `test/widget_test.dart`
- `test/presentation/memories_test.dart`
- `test/presentation/voice_journal_navigation_test.dart`
- `test/presentation/memory_exploration_navigation_test.dart`
- `tool/journal_visual_preview_test.dart`
- `README.md`
- `docs/Cya_Master_PRD_and_Development_Bible.md`
- `docs/revamp/Navigation_and_Release_Checklist.md`
- `docs/revamp/Revamp_Implementation_Status.md`
- `plans/iteration-20-accessible-memory-and-capture.md`
- `plans/BUILD_LOG.md`


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
