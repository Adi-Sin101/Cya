# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Cya!** — an *intention manager* (surfaced to users as "promises"). Capture the moment
someone decides "I'll do this later," store it with source context, and resurface it at the
right time with one-tap actions. Flutter (Dart, Impeller), Android-first → iOS fast-follow.

The single source of truth for **everything** — product, architecture, standards, roadmap —
is [docs/Cya_Master_PRD_and_Development_Bible.md](docs/Cya_Master_PRD_and_Development_Bible.md).
It is the **bible**. Read it before non-trivial work. If a requirement here conflicts with what
you're about to do, **stop and flag it** rather than silently diverging.

> Current state (2026-08-31): **Phase 0 is complete.** Riverpod + go_router + the designed Home,
> Promises, Promise Detail and Profile screens are reactive over a **Drift** store
> (`intentions` + append-only `intention_events` + `preferences` + an FTS5 search index), and the
> **native-thin Share Sheet capture path** writes to that same SQLite file from Kotlin with no
> Flutter engine (762 ms cold, 117 ms warm on an API 34 emulator). Reminder scheduling
> (`AlarmManager`), notifications with one-tap Done/Snooze, escalation tiers and boot rescheduling
> are in — see `plans/BUILD_LOG.md` for what is verified and what is not.
>
> Not yet built: Memory Garden and Achievements screens (placeholders), Rive reward animations,
> the weekly digest, enrichment (on-device date extraction, auto-categorization), Quick Settings
> Tile, home-screen widget, and iOS. `freezed` is deliberately **not** used — see ADR-003.
> Two contracts to respect before touching data or native code:
> [docs/native_db_contract.md](docs/native_db_contract.md) (the schema both runtimes write) and the
> ADR log in PRD §13.3.

## Development workflow (non-negotiable process)

Development runs as a persistent, written cycle:
**Requirement Analysis → Planning → Execution → Testing → Feedback → repeat.**

- **Plans live in [plans/](plans/)** as dated Markdown files, one per unit of work. A plan
  always derives from the PRD and states its acceptance criteria (from PRD §10 / Appendix B).
  Do not start executing a phase until its plan exists and the previous phase's acceptance
  criteria pass.
- **[plans/BUILD_LOG.md](plans/BUILD_LOG.md)** is the running record of execution + testing
  feedback: what was done, what worked, what broke and why, and the lesson. Append to it every
  session so future work learns from past mistakes and rewards the right actions.
- **The PRD's own living log (§13)** is also kept current: module status table (§13.1), decision
  log / ADRs (§13.3), mistakes & lessons (§13.4), test log (§13.5). Update it when you finish a
  unit of work.
- **Definition of done** (PRD Appendix B): meets its §10 acceptance criteria; respects Core
  Principles (§3) and NFRs (§9); tests added/passing; zero analyzer warnings; PRD §13.1/§13.3/§13.4
  updated.

Prefer the **smallest change** that satisfies the acceptance criteria. Clean, efficient,
resource-conscious ("green") code over cleverness. We are system-design/software engineers —
correct design patterns and architecture must show in the code quality.

## Commands

```bash
flutter pub get                 # install deps after editing pubspec.yaml
flutter run                     # run on connected device/emulator (Android first)
flutter analyze                 # static analysis — zero warnings may be merged
dart format .                   # format
flutter test                    # all tests
flutter test test/foo_test.dart # a single test file
flutter test --name "pattern"   # tests whose name matches
flutter build apk               # Android release artifact
```

Lints currently use `flutter_lints` via [analysis_options.yaml](analysis_options.yaml); the PRD
targets stricter `very_good_analysis`, CI-enforced. Keep the analyzer clean regardless.

## Architecture (target, per PRD §5)

Two runtimes share **one SQLite file** — this boundary is the whole design:

- **Native layer (Kotlin/Swift):** all capture surfaces (Share Sheet, Quick Settings Tile,
  widget, alarms). Writes capture rows **directly** to the shared SQLite DB and schedules the
  default reminder via native `AlarmManager`. **The Flutter engine is only booted if the user
  chooses to refine a capture.** This is the "native-thin capture path."
- **Flutter layer (Dart):** the entire main app UI, gamification, refine screens — reading the DB
  reactively via Drift `watch` queries.

Flutter-side layering (dependencies point **inward**; `domain/` imports nothing from Flutter):

```
presentation/  Widgets + Riverpod providers (no business logic)
domain/        Use-cases, entities, repository interfaces (pure Dart)
data/          Drift DB, DAOs, repository impls, ML/notification/scheduler services
native/        Platform channels + native modules (capture, tile, widget, alarms)
core/          DI, Result/error types, constants, extensions
```

Stack in place: Riverpod (state/DI), Drift/SQLite (reactive source of truth), go_router (nav,
including the deep-linkable `cya://promise/<id>` route), bundled Plus Jakarta Sans. Notifications
and exact alarms are **native Kotlin**, not `flutter_local_notifications` — the same scheduler has
to work when the engine has never started (ADR in PRD §13.3). Still to come: Rive (reward
animations) and on-device ML Kit enrichment. Immutable models are hand-written, not freezed
(ADR-003).

## Invariants that must never regress

These come straight from the PRD's Core Principles (§3) and seeded ADRs (§13.3). Breaking one is
a product-level bug, not a style nit:

1. **Capture path is native-thin and does the absolute minimum:** one DB insert + schedule
   default reminder + dismiss. **Never** put a network call, model inference, or Flutter engine
   boot on the capture path. Target: tap → saved in **< 2s** (aim < 1s). This is the product's
   reason to exist.
2. **The local SQLite store is the single source of truth.** Every capture surface writes the
   same DB directly; the UI is reactive over it. No server is in the critical path (no backend
   in V1).
3. **Event-log-backed data model.** `Intention` is the current-state row; `IntentionEvent` is an
   append-only log. **All gamification and metrics are projections over the event log** —
   recomputable, tamper-resistant. No mutation may happen without its event, in the same
   transaction — that rule holds in `IntentionDao` *and* in the Kotlin `CyaStore`. Native capture
   writes must match the Drift schema; the contract is written down in
   [docs/native_db_contract.md](docs/native_db_contract.md) and a test asserts it.
   **A shared database may only use SQL features both SQLite builds have** — Android's system
   SQLite has no FTS5, so the search index is Dart-owned (ADR-005, lesson L-001).
4. **Close the loop.** Resurfacing, escalation (quiet → banner → digest), snooze limit, and
   one-tap resolution (reachable from the notification) are **V1**, not later.
5. **Performance AND beauty are co-equal, zero tradeoff** (§9.1): native capture path, Rive for
   rich animation, Impeller, isolates/`compute` for enrichment, narrow reactive rebuilds +
   `RepaintBoundary` around animated subtrees. Both are acceptance criteria, not aspirations.
6. **Privacy-first / local-first:** on-device by default, explicit consent before any cloud AI,
   no scraping of private apps. The mascot appears only in reward/empathy moments — never on the
   capture path.

## Vocabulary (use consistently in code and UI)

Code models `Intention`; UI says **"promise"**. *Resurface* = show at scheduled time.
*Resolution* = mark as done. **Memory Garden** = gamified growth tied to resolved promises.
