# Cya! comprehensive emulator QA — 23 October 2026

## Scope and release decision

This is a bounded functional QA pass of the existing application, not a claim
that every possible use is perfect. Twenty-seven distinct emulator cases passed
on the normal production entry point. Two reproducible application defects were
fixed with regression tests. Remaining checks below must not be read as passes.

No personal-phone data was cleared or modified. No schema, dependency, network
permission or capture-path architecture was changed by these QA fixes. The
pre-existing offline revamp implementation was preserved and committed separately.

## Reproduction environment

| Item | Observed configuration |
| --- | --- |
| Host | Windows 11 IoT Enterprise LTSC, 10.0.26100, 16 GB RAM |
| Checkout | `C:\Code\Logarithm\cya`, origin `Adi-Sin101/Cya`, main |
| Flutter / Dart | 3.44.4 / 3.12.2, `C:\Flutter\flutter` |
| Android SDK | `D:\Android`; emulator 36.1.9.0 |
| JDK | Eclipse Adoptium 17.0.17.10-hotspot |
| Native tooling | Gradle 9.1, AGP 9, Kotlin 2.3.20; existing compatibility flags retained |
| Synthetic device | `CyaQA_20261023`, `emulator-5560`, Android 14/API 34 Google APIs x86_64 |
| AVD display | 720 x 1600, density 320, two CPU cores |
| Graphics | Host GPU, Vulkan disabled; software-rendering attempts crashed QEMU |
| Network | Airplane mode; Wi-Fi/mobile data disabled; active default network: none |
| Microphone | Host microphone disabled; synthetic recording tests do not certify physical microphone fidelity |

The dedicated AVD contained synthetic English, Bangla and Banglish notes, routine
data and a synthetic PIN. The driver refuses a different AVD name/serial.
`tool/qa/README.md` documents the public Android accessibility driver, separate
instrumentation package and actual share/widget fixture. They are development
tools and are not bundled into Cya!.

The tested initial split release was x86_64 version **8015**, base build 4015,
58,894,967 bytes, SHA256
`66c1b46f0081dc5f1bf96022058439fed6f434f7e87d8d9948e36837617d3552`.
Its normal entry point is `lib/main.dart`, package `dev.cya.app`, minSDK 24,
targetSDK 36. This APK predates the two QA fixes. Fresh artifact verification is
recorded in the final validation section rather than attributed to this binary.

## Automated validation

| Command / check | Result |
| --- | --- |
| Baseline `flutter analyze` | PASS, no issues, 117.9 seconds |
| Baseline `flutter test` | PASS, 289 tests, 166 seconds |
| Full suite after completed-promise fix | PASS, 291 tests, 83 seconds |
| `flutter test test/presentation/promise_tile_status_test.dart` | PASS, two red-to-green regressions |
| `flutter test test/presentation/focus_room_test.dart` | PASS, five tests including new recovery regression, eight seconds |
| Final `flutter --no-version-check analyze --no-pub` | PASS, no issues, 321.2 seconds on the loaded host |
| Final `flutter --no-version-check test --no-pub --concurrency=1` | PASS, all 292 tests, 11 minutes 3 seconds on the loaded host, after both fixes |
| `gradlew.bat --offline --max-workers=1 "-Dorg.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=768m -XX:ReservedCodeCacheSize=256m" testDebugUnitTest` | PASS, 7 minutes 53 seconds; eight tests, zero failures/errors |
| Native XML suites | WavePcmFileTest: 3; ArchiveReaderTest: 3; ArchiveWriterTest: 2 |
| `python -m py_compile tool/qa/build_fixture.py tool/qa/emulator_qa.py tool/qa/run_emulator_cases.py` | PASS |

Logs are retained locally in ignored `.buildlog/qa22-*.log`; native XML is under
`build/app/test-results/testDebugUnitTest`. A repeated full-suite attempt was
interrupted deliberately during host memory pressure and is not counted as a
test failure or a pass. The later final full suite passed as recorded above;
its long host runtime is not an application latency measurement.

## Actual emulator coverage

The append-only `.buildlog/qa22/cases.jsonl` retains failed harness attempts as
well as later successful assertions. Screenshots and accessibility trees use the
case IDs below. A pass means the stated visible behavior was observed, not that
all combinations or error conditions of that feature were exhaustively covered.

Selected synthetic screenshots: [saved original voice playback](evidence/voice-original-playback.png)
and [explicit routine completion](evidence/routine-explicit-completion.png).
The [latest recorded outcomes and attempt counts](evidence/case-results.json)
preserve 27 passes and three failed/incomplete case IDs; two IDs refer to the
same unfinished PIN workflow. Not-run cases have no fabricated log entry.

| Case | Result | Observed behavior |
| --- | --- | --- |
| 01 | PASS | First-run onboarding continues with notification permission declined |
| 02–04 | PASS | Typed English, Bangla and Banglish memories saved and visible |
| 05 | PASS | Unsaved text asks for confirmation before discard |
| 06 | PASS | Microphone denial handled without losing access to other capture |
| 07 | PASS | Record, review, play, save, reopen and play original audio |
| 08 | PASS | Force-stop during recording offers recovery after relaunch |
| 09–10 | PASS | Garden accessible from Home and Profile, with return navigation |
| 11 | PASS | Missing local model has visible installation/status controls |
| 12 | PASS | Keyword search retrieves English, Bangla and Banglish text |
| 13 | PASS | Editing preserves original revision/history |
| 14 | PASS | Exploration branch retains source link and leaves source unchanged |
| 15 | PASS | Memory archive, restore, delete and cancellation |
| 16 | PASS | Create and open a topic |
| 17 | PASS | Focus pause, restart, resume, capture-first priority notice and end |
| 18 | PASS | Create and select a routine |
| 19 | PASS | Skip, replan, lighter steps, explicit completion and outcome history |
| 20 | PASS | Save a daily review note |
| 21 | INCOMPLETE | Promise presets/Done/reopen/snooze exercised; grouped archive assertion needs rerun after correcting the driver's three-snooze prerequisite |
| 22 | PASS | Cold native ACTION_SEND and PROCESS_TEXT persist into the shared store; logged capture 84 ms / 22 ms for these individual samples |
| 23 | PASS | Actual RemoteViews bound in a separate test AppWidgetHost; real PendingIntent opens native capture and persists a promise |
| 24 | PASS | Real date/time picker creates a custom promise and an AlarmManager entry |
| 25 | PASS | Scheduled notification actually arrives; notification Done action resolves the promise |
| 26–27 | PASS | Background 15-minute focus survives; after a long idle the timer is zero and routine still awaits explicit completion |
| 28 | PASS | Real system Quick Settings Tile opens native capture and saves |
| 29 / 29b | INCOMPLETE | Profile name and appearance changed; PIN persisted and cold launch showed unlock. Wrong-PIN/correct-PIN/remove sequence blocked by unstable emulator accessibility/graphics |
| 30 | NOT RUN | Production share export with attachment/hash verification |
| 31–32 | NOT RUN | Actual SAF corrupt-archive rejection and append-only import |
| 33 | NOT RUN | User-selected local model install via production UI |

Cases 26–27 were inspected after more than twelve hours of idle, not at the exact
15-minute boundary. They do not prove timely focus-end notification delivery.
The widget case uses real Android RemoteViews and PendingIntents, but not an OEM
launcher. Recording with the host microphone disabled verifies state/file/playback
plumbing, not speech intelligibility. Cold native timing samples are observations,
not a latency distribution or a phone-performance guarantee.

## Confirmed defects and changes

### Completed promises retained pending urgency

Resolving an overdue promise still displayed the red Overdue indicator in its
list tile and reminder row in detail. Both now suppress pending urgency for a
resolved promise while preserving its stored reminder for reopening.

Files: `lib/presentation/screens/home/widgets/promise_tile.dart`,
`lib/presentation/screens/promise_detail/promise_detail_screen.dart`,
`test/presentation/promise_tile_status_test.dart`. The two regressions failed
before the change and passed afterward. Fresh-release GUI confirmation remains
separate from these host regression results.

### Reopened routine focus lost routine context

A saved timer had its occurrence ID, but reopening focus without a constructor
occurrence omitted routine steps and its completion action. A read-only lookup
now restores the persisted occurrence and exact saved revision. Explicit
completion still uses repository transaction/version checks; timer expiry does
not silently complete the routine.

Files: `lib/data/repositories/routine_repository.dart`,
`lib/presentation/screens/routines/focus_room_screen.dart`,
`test/presentation/focus_room_test.dart`. The new recovery regression failed
before the fix; the five-test focus suite passed afterward. No migration.

## Offline, security and data boundaries

The tested release manifest contains neither INTERNET nor ACCESS_NETWORK_STATE.
Core navigation/capture/search/routines and real reminder delivery were exercised
with no active default network. This is evidence for these paths, not a packet
capture audit of all Android components. No new networking dependency was added.

Native capture still saves before asynchronous model work and uses the shared
SQLCipher/native–Drift schema version 8. It does not start a Flutter engine or
run inference on the critical path. This QA introduced no schema migration.
Existing migration/contract tests are part of the Flutter suite; no destructive
legacy plaintext conversion was attempted. See `docs/native_db_contract.md`.

Original managed WAV attachments and portable ZIP exports are **not encrypted**.
Database encryption must not be described as encrypting those files or an entire
device. Authentication correctness is not certified by the incomplete PIN GUI
sequence. Backup reader/writer unit tests passed; that does not substitute for the
pending production export/import round trip.

EmbeddingGemma 2 semantic memory remains a required capability. The exact local
740M LiteRT-LM artifact was available and copied into the synthetic AVD:
484,622,336 bytes, SHA256
`e7a8a2204b91e0f96e92960e84a09a89212e1633dcb7575a9bf3378b4df77f4c`.
Availability is not a successful installation, inference or retrieval test.
Prior A52 experiments in `docs/revamp/A52_Semantic_Benchmark_2026-10-16.md`
remain historical evidence; this QA has not revalidated production-UI text/raw
audio retrieval, related suggestions, pause/rebuild or deletion of indexed
sources. Do not claim semantic-memory acceptance from keyword-search passes.

## Host and harness failures

Windows recorded QEMU access violations (`0xc0000005`) while trying software
renderers; the application was not running for several of these crashes. Host
GPU allowed the main pass. After a long idle, framebuffer/accessibility snapshots
were inconsistent; restarting was necessary. Later host free RAM fell to about
200 MB while an unrelated Android build ran. The creator explicitly requested
leaving that build running. Our emulator was stopped to free RAM, and checks are
serialized. These observations are not evidence of a Cya! PIN defect or app crash.

Initial test-driver failures included keyboard overlays, lazy-list scrolling,
native uppercase labels, accessibility attachment and instrumentation targeting
the fixture process. The driver was corrected to dismiss the IME, inspect actual
text and descriptions, scroll, retry attachment and use a separate target process.
Failures are preserved in raw evidence rather than silently erased.

## Remaining release gates

1. Final full suite and normal release rebuild passed; verify the fixes on a
   reliably running installed binary. The final emulator update attempt blocked.
2. Finish the incomplete promise lifecycle/PIN cases, real export/import round
   trip and corrupt import rejection when the AVD is stable.
3. Complete exact-artifact offline text-to-text, text-query-to-original-audio
   without transcript, related-memory discovery, index pause/rebuild/delete and
   multilingual quality acceptance. Do not substitute another model silently.
4. Reboot/reschedule, revoked permissions, large font, low storage and destructive
   reset scenarios need a further explicit synthetic-device pass.
5. Physical Galaxy A52 microphone, biometrics, OEM background restrictions,
   unplugged battery/thermal behavior and representative multilingual retrieval
   quality need named-device measurements. No phone was connected for this pass.

Focus-end/routine-window notifications are not implemented; promise reminders
were verified. Offline ASR and image/video indexing remain staged work, not
features certified by this report. None of these open requirements is reclassified
as optional by the QA result.

## Final validation and delivery

Closure continued on 24 October2026. Final source:292/292 Flutter tests pass;
analyzer0; native8/8 pass. No application source changed after those checks.

The normal-entry-point release build passed,753.7 seconds on the loaded host:

```powershell
flutter --no-version-check build apk --release --no-pub --split-per-abi --target-platform android-arm64,android-x64 --build-number 4016 -t lib/main.dart
```

The process-local `GRADLE_OPTS` set one worker and a2GB daemon heap with768MB
metaspace/256MB code cache; the daemon log confirms that heap. Repository tooling
versions and project heap defaults were preserved. Existing release signing still
uses the development key; this is not a production-signing claim.

| Fresh artifact | Version code | Bytes | SHA256 |
| --- | --- | --- | --- |
| `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` | 6016 | 52,459,937 | `09e6a62d04b09714024344d1bdb99097edcaae7168d92571947bc8ae2960768f` |
| `build/app/outputs/flutter-apk/app-x86_64-release.apk` | 8016 | 58,894,967 | `ec7ed330ca779bde33cc4425daf684553f1ea361e28c36a6b476770714c4720c` |

`aapt dump badging` confirms package `dev.cya.app`, minSDK24, targetSDK36.
`aapt dump permissions` on the fresh release confirms no INTERNET or
ACCESS_NETWORK_STATE. Existing alarm/boot/notification/biometric/audio and
application-local receiver permissions remain.

The isolated AVD was cold-started again after the competing build ended. Android
eventually reported `sys.boot_completed=1`, but System UI suffered an ANR and
package installation/accessibility operations stalled. Last observed installed
version was8015; no successful8016 install result was obtained. The initial
install retry before boot reported missing package service, an environment/startup
error. Bluetooth also recorded a native abort during boot. Host free RAM was
approximately0.4GB during this attempt. Our AVD was stopped after collecting the
failure evidence; no other applications or builds were stopped during closure.

Consequently, cases21/29 and30–33, fixed-release GUI confirmation, reboot alarm
verification and the remaining edge cases stay incomplete/not run. A built APK
and host tests do not close these gates. The matrix above retains those limits.
Do not represent this as every feature passing or all product phases complete.

Delivery uses seven meaningful commits on main under Adi-Sin101, with no coauthor;
the final response records verified push status. APKs/model files/local exports,
credentials and raw private data are excluded from Git.
