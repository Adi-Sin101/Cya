<div align="center">

# Cya!

**Capture now. Remember later.** - *"I'll remember for you."*

[![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20->%20iOS-3DDC84)](#roadmap)
[![Status](https://img.shields.io/badge/status-development--release-F59E0B)](#status)

</div>

---

## What is Cya!?

Cya! is an **intention manager** (surfaced to users as a **"promise"**).
It captures the exact moment you decide, *"I'll do this later,"* stores it with source context, and resurfaces it at the right time with one-tap actions.

This is not a to-do list clone, and it is not a chatbot. Cya! owns the "not now" moment and closes the loop later.

## Using memories and voice

The five main tabs are **Home, Memories, Rhythm, Promises and Profile**.
Home and Memories have labeled **Record voice** and **Write a thought** buttons.
The bottom-right + opens voice, text or promise capture. Recording starts only
when you tap Start recording. Memories shows original playback, history,
connections, branches, archive, keyword/semantic search and topics/projects.
Garden remains available from Home and Profile. Model controls are in Memories
and Profile; installation is an explicit local-file choice.

See [current navigation and release gates](docs/revamp/Navigation_and_Release_Checklist.md).

## Highlights

- **Sub-two-second capture**: share or tap, and the promise is saved and scheduled.
- **Native-thin capture path**: no Flutter engine boot, no network call, no waiting in the critical path.
- **Capture surfaces everywhere**: Share Sheet, Quick Settings Tile, and home-screen widget.
- **Close the loop**: reminders with escalation, snooze limits, and one-tap resolution from notifications.
- **Local-first and private**: SQLite is the single source of truth; no server in the V1 critical path.
- **Lush animated UX**: colorful, mascot-driven UI with Memory Garden, XP, levels, and achievements.

## Tech stack

| Concern | Choice |
|---|---|
| Framework / language | Flutter (Impeller), Dart |
| State / DI | Riverpod |
| Local DB (source of truth) | Drift (SQLite), reactive `watch` queries |
| Immutable models | Hand-written immutable Dart models |
| Navigation | go_router |
| Notifications and scheduling | Native Kotlin `AlarmManager` and notifications |
| Animation | Flutter animations + CustomPainter |
| Typography | Plus Jakarta Sans |

## Architecture at a glance

Two runtimes share **one SQLite file**:

- **Native Android layer (Kotlin)** handles performance-critical capture surfaces. It writes raw promises directly to the shared DB and schedules the default reminder.
- **Flutter layer (Dart)** powers the main app UI, gamification, and refine flows, reading the DB reactively.

See the full architecture and constraints in the [Master PRD and Development Bible](docs/Cya_Master_PRD_and_Development_Bible.md).

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).
The verified development toolchain is **Flutter 3.44.4 / Dart 3.12.2**.
Keep `pubspec.lock` when restoring the project to preserve package versions.

```bash
flutter pub get
flutter run
```

After moving the checkout, run `flutter clean` followed by `flutter pub get`
to regenerate files containing absolute paths. Ensure Flutter is on PATH and
`android/local.properties` points to the installed Flutter and Android SDKs;
that file is local to each machine and is not committed. On the restored Windows
setup, Flutter is at `C:\Flutter\flutter` and Android remains at `D:\Android`.
Restart terminals and your editor after changing PATH.

Common tasks:

```bash
flutter analyze
dart format .
flutter test
flutter test test/widget_test.dart
flutter build apk
```

## Roadmap

| Phase | Focus |
|---|---|
| Existing foundation | Android promise capture, reminders, search, Garden and local identity |
| Offline memory foundation | Original text/audio, required local semantic retrieval, immutable history and portable data |
| Connections and Rhythm | Explicit relationships/branches/projects, flexible routines/recovery/review and chosen focus |
| Validation | Named-device offline, multilingual quality, interruption/storage/reboot and performance acceptance |
| Staged P1 | Verified local transcription and image/video extension; no cloud inference or automatic downloads |

## Status

**Implemented Android application; offline memory revamp under release validation.**
The existing promise/reminder/native capture system is retained. The approved
extension adds local text/original-audio memories, required EmbeddingGemma 2
semantic retrieval, immutable history/branches, topic/project links, focus sessions,
real routines/recovery, optional reviews and validated portable backups.
The table above records the original roadmap; cloud sync, accounts, notification
listeners and remote AI are excluded from the approved extension scope.

Current shared native/Drift schema is8 and portable export format8. Model weights
are explicitly installed from a local file and verified by size/SHA256; they are
not downloaded by the app or bundled into the APK. Keyword search/capture work
with semantic processing paused. Original audio and exported archives are readable
files; do not extend SQLite encryption claims to them. Representative speech/
Banglish quality and sustained phone performance remain release gates.

**Rhythm** is the routine/day-plan tab: visual daily path, selected routines,
manual recovery and graphical daily/weekly review. Its focus room offers a saved,
pausable timer and thought capture. Time passing never marks a routine complete.

Single source of truth:

- [Master PRD and Development Bible](docs/Cya_Master_PRD_and_Development_Bible.md)
- [Plans](plans/)
- [Build log](plans/BUILD_LOG.md)
- [Approved product direction](docs/Cya_Product_Direction_PRD.md)
- [Audit and requirement mapping](docs/Cya_Product_Direction_Audit.md)
- [CLAUDE.md](CLAUDE.md)

## Contributing

Development follows a written loop:

**Requirement Analysis -> Planning -> Execution -> Testing -> Feedback**

Each unit of work should:

- have a plan in `plans/`
- append outcomes and lessons to `plans/BUILD_LOG.md`
- meet acceptance criteria from the PRD
- ship with tests
- keep analyzer output clean
