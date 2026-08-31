# Cya! — Master PRD & Development Bible

> **Tagline:** *Capture now. Remember later.* — "I'll remember for you."
> **Type:** Intention manager (not a task app, not a reminder app, not a chatbot).
> **Status:** Pre-development. This document is the single source of truth for the entire build.
> **Platform sequencing:** Android first → iOS fast-follow.
> **Framework:** Flutter (Dart, Impeller).

---

## 0. How to use this document (read first, every session)

This file is the **bible**. It is both a specification and a **living log**. Two kinds of content live here:

1. **Fixed spec** (Sections 1–12): the product, architecture, standards, and plan. Change these only via a logged decision (Section 13.3).
2. **Living log** (Section 13): implementation status, decisions, mistakes, lessons, open questions. **Update this after every work session.**

**Rules for the AI building this app:**

- Before starting any task, re-read Section 3 (Core Principles) and Section 9 (Non-Functional Requirements). They are non-negotiable.
- Never put work on the capture path that isn't strictly necessary to save an intention (see 3.2 and 5.4). This is the most common way to break the product.
- After completing a unit of work: update the module status table (13.1), append any decision to the decision log (13.3), and record anything that broke and why in the mistakes/lessons log (13.4).
- If a requirement here conflicts with something you're about to do, **stop and flag it** rather than silently diverging.
- Prefer the smallest change that satisfies the acceptance criteria. Clean, efficient, resource-conscious ("green") code over cleverness.
- Two priorities are co-equal and neither may be traded off: **(A) native-level performance** and **(B) a beautiful, colorful, animated UI/UX**. Section 9.1 explains how both are achievable at once.

---

## 1. Product overview

### 1.1 Executive summary
Cya! captures the exact moment a user decides *"I'll do this later,"* stores it with its source context, and resurfaces it at the right time with one-tap actions. The goal is to become the default **"Later" layer** across a user's digital life.

### 1.2 Positioning
Cya! is an **Intention Manager**. The primary object is an **intention** (surfaced to users as a **"promise"**), not a task. Success is measured by *resurfacing and resolution behavior*, not list length.

### 1.3 Promise to the user
Capture an intention in **under two seconds**, from anywhere, with the source context preserved — and never lose it.

### 1.4 Vocabulary (use consistently in code and UI)
| Internal term | User-facing term | Notes |
|---|---|---|
| Intention | **Promise** | The core object. Code models `Intention`; UI says "promise". |
| Resurface | Reminder / "brings it back" | The act of showing an intention at its scheduled time. |
| Resolution | "Mark as done" | Terminal positive state. |
| Memory Garden | Memory Garden | Gamified growth visualization tied to resolved promises. |
| Capture surface | — | Any entry point that creates an intention (share sheet, tile, widget, listener). |

---

## 2. Problem & market

### 2.1 Problem statement
Users constantly postpone actions — reply to a message, read a paper, buy a product, review a PDF, call someone, apply for a job. These intentions are scattered across dozens of apps and are usually forgotten, because switching context is expensive and existing productivity apps interrupt flow.

### 2.2 Target user
Gen Z living across many apps daily (Messenger, WhatsApp, Discord, Slack, Gmail, LinkedIn, Instagram, TikTok, GitHub, YouTube, Chrome). They think *"I'll reply later," "I'll watch this tonight," "I'll read this after class"* — and these thoughts rarely become tasks; they vanish.

### 2.3 Market gap
No mainstream product owns the **"Not now"** moment across apps. Todoist/TickTick/Google Tasks/Apple Reminders require manual task creation and are task-first. Pocket/Instapaper only handle articles. Notion is too heavy. Google Keep isn't intention-centric. Cya! differentiates by **minimizing capture friction** and treating **postponed intentions with source context** as the primary object.

---

## 3. Core product principles (non-negotiable)

These are the constitution. Every feature and code decision must respect them.

### 3.1 Under two seconds to capture
Median time from share/tap to saved intention **< 2s** (target **< 1s**). This is the headline metric and the product's reason to exist.

### 3.2 Capture is dumb and synchronous; enrichment is asynchronous
The capture path does the **absolute minimum**: write the raw intention to the local store + schedule a default reminder + dismiss. Everything intelligent (AI categorization, deadline refinement, embeddings) runs later in background work and updates the record reactively. **Never** put a network call or model inference on the capture path.

### 3.3 The local store is the single source of truth
No server is in the critical path. Every capture surface writes to the same local SQLite database directly. The UI is reactive over that database.

### 3.4 Close the loop
Capture without resurfacing is just another inbox. Resurfacing, escalation, snooze limits, and one-tap resolution are **V1 features, not later** — this is the biggest retention risk.

### 3.5 Privacy-first, local-first
No scraping of private apps. Only user-initiated capture or explicit notification permission. Prefer on-device AI. Explicit consent before any cloud AI. Encrypted sync when it arrives. Full export and deletion controls.

### 3.6 Performance and beauty are co-equal, with zero tradeoff
Native-level performance **and** a lush, animated, colorful, mascot-driven experience. Section 9.1 defines how to get both.

---

## 4. Tech stack & rationale

### 4.1 Decision: Flutter
Chosen for pixel-consistent rendering across devices, smooth animation-dense UI by default (the Memory Garden, XP progression, mascot, achievement reveals), strong on-device ML plugin support, and a cohesive single-language toolchain. The differentiating capture surfaces are native in any framework, so the framework choice governs the main UI — where Flutter's fluidity is the deciding advantage given UI polish is a top priority.

### 4.2 Stack
| Concern | Choice | Notes |
|---|---|---|
| Framework / language | Flutter (stable), Dart | Impeller renderer. New features gated behind stable channel. |
| State / DI | Riverpod | With clean layering; providers over reactive DB streams. |
| Immutable models | freezed + json_serializable | Value equality, copyWith, unions for state. |
| Local DB (source of truth) | **Drift** (SQLite) | Reactive `watch` queries; real SQLite file the native layer can also open. |
| Navigation | go_router | Declarative, deep-link friendly. |
| Notifications | flutter_local_notifications | Channels + importance tiers for escalation. |
| Exact scheduling | Native `AlarmManager` bridge (Android) | For exact, Doze-resilient reminders. |
| Share receiving | receive_sharing_intent | Capture write stays native-thin (5.4). |
| On-device date/time extraction | google_mlkit_entity_extraction | "before tonight" → timestamp, on-device. |
| Home-screen widget | home_widget + native Glance/WidgetKit | Flutter pushes data; OS draws widget. |
| Quick Settings Tile / Notification Listener | Native `MethodChannel` modules | `TileService` / `NotificationListenerService`. Listener deferred. |
| Animation (mascot, garden) | **Rive** (primary) + Flutter animations + CustomPainter | State-driven, low-cost vector animation. |
| Fonts | google_fonts → Plus Jakarta Sans | Or bundle for offline/perf. |
| Local search | Drift FTS5 (V1) → vector index later | On-device. |
| Lints | very_good_analysis (or flutter_lints, strict) | Enforced in CI. |
| Crash/analytics | Privacy-respecting product analytics | Capture speed measured locally. |

---

## 5. System architecture

### 5.1 High-level flow
Multiple capture surfaces → **one local store (source of truth)** → two independent async pipelines: (a) background **enrichment** (writes results back into the store) and (b) the **reminder scheduler** → **resurfacing** with escalation → one-tap resolution or return-to-source-app.

### 5.2 The native / Flutter boundary
- **Native layer (Kotlin/Swift):** all capture surfaces + direct SQLite writes for capture. This is the performance-critical zone.
- **Flutter layer (Dart):** the entire main app UI, gamification, refine screens, reading the DB reactively.
- The two layers **share one SQLite file**. Capture surfaces do not depend on the Flutter engine.

### 5.3 App layering (Flutter side)
```
presentation/   Widgets + Riverpod providers (no business logic)
  screens/, widgets/, theme/
domain/         Use-cases, entities, repository interfaces (pure Dart, no Flutter)
  entities/, usecases/, repositories/
data/           Drift DB, DAOs, repository impls, ML/notification/scheduler services
  db/, dao/, services/, repositories_impl/
native/         Platform channels + native modules (capture, tile, widget, alarms)
core/           DI, error handling (Result types), constants, extensions
```
Rule: dependencies point **inward** (presentation → domain ← data). `domain/` imports nothing from Flutter.

### 5.4 The native-thin capture path (critical)
On a share/tile capture:
1. A thin **native** activity/service receives the intent.
2. It writes the raw intention row **directly to the shared SQLite file** (native SQLite/Room open of the same DB Drift uses).
3. It schedules the **default reminder** ("Tonight") via native `AlarmManager`.
4. It dismisses. **The Flutter engine is only launched if the user chooses to refine** the capture.

This keeps the two-second promise independent of engine startup. Enrichment happens later, off the capture path.

### 5.5 Enrichment pipeline
Runs after capture (background/isolate): ML Kit entity extraction for deadlines → refine `reminder_at`; rule-based categorization (source app + URL domain + keyword map) → `category`; later: embeddings for semantic search. Writes results back to the store; the reactive UI updates itself.

### 5.6 Reminder / resurfacing engine
- Exact alarms via native `AlarmManager` (`setExactAndAllowWhileIdle`); use `USE_EXACT_ALARM` where the app qualifies (reminders are the core function).
- Handle **Doze** and OEM battery-optimization: detect and guide the user to exempt Cya! where reminders are being dropped.
- **Escalation state machine:** re-snoozed intention rises in prominence: quiet notification → banner → daily digest.
- **Snooze limit:** after N re-snoozes, prompt to resolve / delete / archive (enforced in the domain layer).
- **Weekly digest:** lightweight Sunday-evening review of open intentions (a review moment, not a guilt list).

### 5.7 Backend
**None in V1.** Local-first, single device. When multi-device encrypted sync arrives (Later): end-to-end encryption means the server stores only **opaque ciphertext blobs** and shuttles them between a user's devices — a dumb store (a BaaS is fine). Keys derive from user credentials and live on-device. No server-side AI until Pro demand is proven.

---

## 6. Features & functionality

### 6.1 Capture methods (surfaces)
| Surface | Platform | Notes / gotchas |
|---|---|---|
| Share Sheet | Android + iOS | Primary workhorse. Register share target; use Direct Share / Sharing Shortcuts so Cya! surfaces with an icon. Receiving UI is translucent and dismisses instantly. |
| Quick Settings Tile | Android | `TileService`. Cannot read foreground app content — opens a fast paste/dictate capture screen. |
| Home-screen widget | Android + iOS | Glance/WidgetKit. 1–2 tap targets: capture + view today. |
| Notification Listener | Android (deferred) | `NotificationListenerService`. Play Store **sensitive permission** — data-safety declaration + manual review. **Opt-in, fast-follow**, only saves notifications the user taps to save. Never silently ingest the stream. |
| App Intents / Siri Shortcuts | iOS (fast-follow) | Voice + shortcut capture. |

**Zero-tap default:** every surface must be able to complete a capture with no extra taps, using a default preset ("Tonight"). The preset picker is optional refinement.

### 6.2 Reminder presets
`Tonight`, `Tomorrow`, `Weekend`, `Custom (pick date/time)`. AI may suggest a time; the user can always override.

### 6.3 Capture stored fields
Source app, raw content, snippet, deep link (return-to-app), timestamp, user-selected reminder, (async) category, (async) extracted deadline, status, snooze count.

### 6.4 Categories & search
Manual categories in V1 + basic on-device search (Drift FTS5). Auto-categorization arrives via enrichment. Semantic search is Later (on-device embeddings + vector index).

### 6.5 AI / enrichment scope
- **V1:** on-device deadline extraction (ML Kit), rule-based categorization, timing suggestion. Nothing on the capture path.
- **Fast-follow:** on-device auto-categorization refinement.
- **Later:** semantic search; drafting replies; document summaries; monitoring saved links (price/deadline/repo changes); completion assistance. Cloud AI only with explicit consent (AI Pro tier).

### 6.6 Gamification (from the design)
- **XP + Levels:** e.g., "Level 12 · Future Builder · 2,450 / 3,000 XP". XP awarded for capture and (weighted higher) resolution.
- **Memory Garden:** plants grow as promises are resolved ("4 new growths this week"). Rive-driven, reacts to streaks.
- **Achievements:** e.g., *First Step* (first intention captured), *Never Lost* (recovered 100), *Reader* (read 50 saved articles), *Communicator* (replied to 100 conversations), *Future You* (kept 500 promises), *Legend* (keep 1000 promises).
- **Weekly stats:** Captured / Completed / Success Rate, with an encouraging trend line.
- All gamification state is a **projection over the event log** (Section 7) — recomputable, tamper-resistant.

### 6.7 Monetization (no monetization in V1)
| Tier | Includes |
|---|---|
| Free | Capture, reminders, categories, basic sync, gamification. |
| Pro | AI organization, semantic search, smart scheduling, multi-device sync. |
| AI Pro | Drafting, summaries, monitoring services, advanced automation. |

---

## 7. Data model

### 7.1 Entities
**Intention** (current-state row):
`id`, `source_app`, `raw_content`, `snippet`, `deep_link`, `captured_at`, `reminder_at`, `category`, `status` (`open` | `snoozed` | `resolved` | `archived`), `snooze_count`, `extracted_deadline?`, `updated_at`.

**IntentionEvent** (append-only log):
`id`, `intention_id`, `type` (`captured` | `snoozed` | `resurfaced` | `resolved` | `archived` | `edited`), `occurred_at`, `metadata` (JSON).

The event log is the backbone: gamification, all V1 metrics, and future sync reconciliation derive from it.

### 7.2 Drift schema sketch (illustrative — refine in code)
```dart
class Intentions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceApp => text()();
  TextColumn get rawContent => text()();
  TextColumn get snippet => text().nullable()();
  TextColumn get deepLink => text().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  DateTimeColumn get reminderAt => dateTime().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get extractedDeadline => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
}

class IntentionEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get intentionId => integer().references(Intentions, #id)();
  TextColumn get type => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get metadata => text().nullable()(); // JSON
}
// Plus an FTS5 virtual table over snippet/rawContent for V1 search.
```
**Native capture writes must match this schema** when inserting directly (keep a shared migration/version contract between Drift and the native writer).

---

## 8. UI/UX specification

### 8.1 Design system
**Palette — Light**
| Token | Hex |
|---|---|
| Primary (Sage) | `#2E705B` |
| Secondary (Soft Sage) | `#74B69D` |
| Accent (Mint) | `#A7D7C5` |
| Success (Green) | `#16A34A` |
| Warning (Amber) | `#F59E0B` |
| Error (Coral) | `#EF4444` |
| Background | `#F7FAF8` |
| Surface | `#FFFFFF` |
| Surface 2 | `#F1F5F3` |
| Text Primary | `#1F2937` |
| Text Secondary | `#64748B` |
| Gradient | `#2E705B → #74B69D → #A7D7C5` |

**Palette — Dark**
| Token | Hex |
|---|---|
| Primary / Secondary / Accent | `#2E705B` / `#74B69D` / `#A7D7C5` (unchanged) |
| Success / Warning / Error | `#16A34A` / `#F59E0B` / `#EF4444` |
| Background (Deep) | `#0F172A` |
| Surface (Elevated) | `#1E293B` |
| Surface 2 (Card) | `#243137` *(confirm exact value from palette file)* |
| Text Primary | `#F8FAFC` |
| Text Secondary | `#94A3B8` |

**Typography:** Plus Jakarta Sans — Bold / SemiBold / Medium / Regular. Feel: clean, friendly, modern.
**Shape:** rounded cards (~12–16px radius), soft surfaces, generous spacing.
**Brand character:** the beaver mascot ("I'll remember for you") appears in reward/empathy moments — never on the capture path.

### 8.2 Screens (from approved mockups)
**Home**
- Greeting ("Good Evening, Arif 👋", "Future you is proud of today.") + level badge (Level 12 · Future Builder · 2,450 / 3,000 XP).
- **Today** card: count of promises + completed ring (e.g., 8 promises, 6 completed).
- **Today's Promises** list: each row = app icon, title, source app + time, preset chip (Tonight/Tomorrow/Weekend), completion toggle. Examples: *Reply to Sarah · Messenger*, *Read AI Paper · Chrome*, *Review PR #128 · GitHub*, *Buy HDMI Cable · Amazon*.
- **Memory Garden** preview ("4 new growths this week") with plant illustrations.
- **This Week** stats: Captured / Completed / Success Rate + encouraging trend line.
- Bottom nav: **Home · Promises · (+) · Garden · Profile** (center + = capture).

**Capture Intention**
- Prompt: "What do you want to save for later?" ("Paste, write, or let Cya! understand what this is about.").
- Content field showing pasted/shared text + source app + timestamp.
- "When should I remind you?" → presets: **Tonight · Tomorrow · Weekend · Pick Date**.
- **AI Suggestion** line (e.g., "Tonight · 8:00 PM").
- Primary button: **Save to Cya! ✨**.

**Promise Detail / Resurface (e.g., "Reply to Sarah")**
- Header: title, source app + original time, reminder chip (Tonight · 8:00 PM).
- The captured context (e.g., the message quote).
- Actions: **Mark as Done** (primary), **Open in [source app]**, **Snooze**.
- **"Why this matters"** context card with the mascot.

**Achievements**
- Grid of badges with locked/unlocked states (First Step, Never Lost, Reader, Communicator, Future You, Legend…), "View all achievements".

**Garden** (full screen): the Memory Garden as the emotional core of retention.

### 8.3 Motion & animation principles
- Reward moments (resolution, level-up, new growth, achievement unlock) are **Rive** animations — expressive, colorful, state-driven, reacting to real data (streaks, counts).
- Micro-interactions (toggles, chips, transitions) via Flutter implicit/explicit animations; keep them snappy (short durations, natural easing).
- The mascot is a personality anchor in empathy/reward surfaces; keep it out of latency-critical flows.
- **Respect reduced-motion settings.** Provide a calmer variant.

### 8.4 Accessibility
Sufficient contrast in both themes, scalable text, semantic labels, large enough tap targets, one-tap resolution reachable from the notification itself.

---

## 9. Non-functional requirements

### 9.1 Performance AND beauty — how to have both (no tradeoff)
The two are only in tension if animation work blocks the critical path. They don't have to:
- **Keep the capture path native** (5.4): the heaviest latency risk never touches Flutter or animations.
- **Rive for rich animation**: vector, GPU-friendly, far cheaper than rebuilding widget trees per frame — beauty at low cost.
- **Impeller renderer**: precompiled shaders, no first-run jank.
- **Isolates / `compute` for enrichment**: AI/embedding/parsing work runs off the UI isolate; the UI never stalls.
- **Reactive, narrow rebuilds**: `select`/scoped providers, `const` constructors, `ListView.builder` for lists, `RepaintBoundary` around animated subtrees so animation never repaints static UI.
- **Measure continuously**: DevTools frame profiling; treat any sustained dropped frame as a bug.
Result: lush animated surfaces *and* a UI that never blocks. Both are acceptance criteria, not aspirations.

### 9.2 Performance budgets (hard targets)
| Metric | Target |
|---|---|
| Capture time (tap → saved) | median < 2s; aim < 1s (native path) |
| Frame rate | 60fps min; 120fps on capable displays; no sustained dropped frames |
| Main-app cold start → interactive | < 2s |
| Reminder fire reliability | > 99% (excluding OS-killed states we warn about) |
| Capture path | zero network, zero model inference, single DB insert + alarm schedule |

### 9.3 Privacy (see 3.5)
On-device by default; explicit consent for any cloud AI; encrypted sync; export + delete controls; no scraping of private apps.

### 9.4 Coding standards ("clean, efficient, green")
- Strict lints (very_good_analysis), CI-enforced; no analyzer warnings merged.
- Immutable models (freezed); pure `domain/` layer; repository pattern; Riverpod for DI.
- Explicit error handling via `Result`/sealed types — no silent catches.
- Small, single-responsibility widgets; extract rather than nest deeply.
- Resource-conscious: dispose controllers/streams; avoid needless rebuilds and allocations; lazy-load; optimize assets.
- Every module ships with tests (9.5) and a status update in 13.1.
- Meaningful names using the vocabulary in 1.4.

### 9.5 Testing strategy
- **Unit:** domain use-cases, categorization rules, escalation/snooze-limit logic, event-log projections (gamification + metrics).
- **Widget:** key screens and states (empty, loading, populated).
- **Integration:** capture → store → schedule → resurface → resolve loop; native capture write matches Drift schema.
- **Golden tests:** core screens in light + dark to lock the design system.
- **Performance checks:** capture-time instrumentation; frame profiling on the garden/home.

---

## 10. Execution plan / roadmap

Approach: **plan by plan, sequence by sequence.** Do not start a phase until the previous phase's acceptance criteria pass and 13.1 is updated.

### Phase 0 — Foundation & the two-second spike
- Project scaffold (layering per 5.3), theming (8.1), lints/CI, Drift DB + schema (7.2), Riverpod DI.
- **Native-thin capture spike:** Android Share Sheet → native SQLite write → native `AlarmManager` default reminder → local notification → one-tap return-to-app. Instrument capture time.
- **Acceptance:** a shared item becomes a saved, scheduled intention in < 2s on a cold process, with no Flutter engine boot required; capture time is logged.

### Phase 1 — V1 core loop (Android)
- Flutter app shell reading the DB reactively: Home, Today's Promises, Promise Detail.
- Reminder resurfacing with **escalation** (quiet → banner → digest), **snooze limit**, **one-tap resolution** (reachable from the notification).
- Manual categories + basic FTS search. Quick Settings Tile + home-screen widget.
- Weekly digest. Free tier only.
- Gamification MVP (XP, levels, Memory Garden, first achievements) as event-log projections, with Rive reward animations.
- **Acceptance:** full capture→resurface→resolve loop works; escalation + snooze limit enforced; performance budgets (9.2) met; golden tests pass in both themes.

### Phase 2 — Fast-follow
- iOS: Share Extension, widgets, App Intents/Siri Shortcuts.
- Notification Listener (Android, **opt-in**) after Play Store review.
- Enrichment: on-device date extraction + auto-categorization.
- Pro tier launch.

### Phase 3 — Later
- Semantic search (on-device embeddings + vector index), drafting assistance, monitoring of saved links, multi-device **E2EE** sync, AI Pro tier.

---

## 11. Success metrics (V1)
- **Capture speed:** median tap→saved < 2s.
- **D7 / D30 retention** for users with ≥1 capture in week one.
- **Resolution rate:** share of captured intentions marked done / acted on within their target window.
- **Re-snooze rate:** share snoozed > twice (proxy for becoming a second backlog).
- **Weekly active capturers vs. resolvers** (separate savers from finishers).
All derived from the event log (7.1).

---

## 12. Risks & mitigations
| Risk | Mitigation |
|---|---|
| OEM battery optimization silently drops reminders | Detect dropped alarms; guide battery-optimization exemption; monitor fire reliability. A forgotten reminder is fatal for a memory product. |
| Notification Listener review friction | Keep it opt-in, narrowly scoped, fast-follow; save only user-tapped notifications. |
| Capture becomes a second backlog | Escalation + snooze limit + weekly digest + fast one-tap resolution. |
| Engine startup eats the 2s budget | Native-thin capture path (5.4). |
| Animation-heavy UI jank | Rive + Impeller + isolates + RepaintBoundary + frame profiling (9.1). |
| Habit formation | Make resolution as frictionless as capture; the garden + streaks reward closing the loop. |

---

## 13. LIVING DEVELOPMENT LOG (update every session)

> This is the AI's written testament. Keep it current: what's implemented, what works, what doesn't, what broke, and the lesson. Later phases get easier because this stays accurate.

### 13.1 Module / feature status
Legend: ⬜ not started · 🟨 in progress · ✅ done · ⚠️ done-with-known-issues · 🟥 blocked

| Module | Status | Last updated | Working? | Notes / known issues |
|---|---|---|---|---|
| Project scaffold & layering | ✅ | 2026-07-08 | Yes | core/domain/data/presentation layering in place (Iteration 1). |
| Theming (light/dark, Plus Jakarta Sans) | ✅ | 2026-07-08 | Yes | M3 light+dark from §8.1; PJS bundled. Dark Surface2 #243137 pending confirm. |
| Drift DB + schema + migrations | ✅ | 2026-08-31 | Yes | v1: intentions + intention_events + preferences + FTS5 (trigger-maintained) + hot-path indices. Contract in docs/native_db_contract.md. |
| Native-thin capture (Share Sheet) | ✅ | 2026-08-31 | Yes | Kotlin CaptureActivity → direct SQLite write, no Flutter engine. Cold fresh-install 762 ms total / 172 ms write; warm 117 ms median. |
| Native animated splash (video) | ✅ | 2026-07-08 | Yes | Iteration 1: SplashActivity plays mp4 pre-engine; flash-free handoff. Not a PRD-mandated module — supports §5.2/§9.1. |
| Native alarm scheduler | ✅ | 2026-08-31 | Yes | `setExactAndAllowWhileIdle`, degrades to inexact when the permission is absent; re-armed on boot and on every app resume. |
| Local notifications + escalation | ✅ | 2026-08-31 | Yes | Native channels quiet/banner; Done + Snooze actions write to the store with no Flutter engine; past the snooze limit Cya! stops interrupting (digest tier). |
| Snooze limit logic | ✅ | 2026-08-31 | Yes | SnoozePolicy (max 3) enforced in SnoozeIntention; detail screen prompts to resolve/archive. |
| Home screen | ✅ | 2026-08-31 | Yes | Reactive over Drift; section-scoped consumers; designed empty state. |
| Promise detail / resurface | ✅ | 2026-08-31 | Yes | Done / Open-in-app (stub until deep links) / Snooze + "Why this matters". Deep-linkable route. |
| Quick Settings Tile | ✅ | 2026-08-31 | Yes | TileService opens a native dialog capture (clipboard pre-filled), engine-free. Tile capture measured at 35 ms. |
| Home-screen widget | ⬜ | | | |
| Categories + FTS search | ✅ | 2026-08-31 | Yes | FTS5 search verified against natively written rows (ADR-005); seven manual categories with a picker on Promise Detail, filter chips on Promises, and an icon on every tile. |
| Gamification (XP/levels/garden) | ✅ | 2026-08-31 | Yes | XP, levels, week stats and the full Memory Garden (weekly beds, plant species, streak) are pure projections. Rive reward moments still deferred — see 13.6. |
| Achievements | ✅ | 2026-08-31 | Yes | Six badges from 8.2, evaluated as predicates over counts; locked ones show real progress. Opened from Profile. |
| Weekly digest | ✅ | 2026-08-31 | Yes | Sunday 18:00 native alarm (self-rescheduling), low-importance notification leading with what was kept, `cya://digest` into a review screen with one-tap resolution. |
| Enrichment (date extraction) | ⬜ | | | Fast-follow. |
| Metrics instrumentation | 🟨 | 2026-08-31 | Partly | `capture_ms` in every `captured` event; every fire writes `resurfaced` with its tier, so reminder reliability is measurable. Missed-reminder detection ships; no in-app metrics screen yet. |

### 13.2 Current session log
```
Session 2026-07-08 — Iteration 1 (foundation: theme, font, native video splash → Home)
- Goal: Ship the app foundation — design system + Plus Jakarta Sans, a fully-native Android
  splash playing Cya_splash.mp4 before the Flutter engine boots, leading into the designed Home.
- Done: core/theme (tokens, CyaColors extension, PJS type scale, M3 light+dark); Riverpod +
  go_router shell (Home + placeholder tabs, notched nav, capture FAB stub); designed Home
  (level badge, gradient Today card + CustomPainter ring, promise tiles, garden preview, week
  stats + sparkline) reactive over a mock repo; native SplashActivity (TextureView+MediaPlayer,
  center-crop, muted) + pre-warmed cached FlutterEngine + branded flash-free handoff.
- Working / verified (emulator API 34): splash video → seamless Home handoff (no flash); Home in
  light + dark; live toggle updates the Today ring; reduced-motion skips the video; analyze 0,
  tests 2/2, debug APK builds on AGP 9.0.1 / Gradle 9.1 / Kotlin 2.3.20.
- Not working / deferred: applicationId still com.example.cya (rename before release); dark
  Surface2 #243137 to confirm; Home data is mock (Drift lands later).
- Next: Phase 0 native-thin capture spike (Share Sheet -> shared SQLite -> AlarmManager) per 10.

Session 2026-08-31 - Iteration 2 (Drift data foundation: the store becomes the source of truth)
- Goal: Finish the second half of Phase 0 - the local store - before the native capture spike, since
  the native writer must match the Drift schema (7.2).
- Done: Drift v1 schema (intentions, intention_events, preferences) with explicitly pinned column
  names + FTS5 index maintained by SQL triggers; IntentionDao where every mutation writes its event
  in the same transaction; pure domain layer (entities, repository interface, use-cases,
  SnoozePolicy, XP/week/garden projections); Riverpod DI graph; Home/Promises/Detail rewired off the
  mock onto narrow reactive watches; real in-app capture sheet; persisted theme preference;
  docs/native_db_contract.md.
- Working / verified: analyze 0 issues; 53 tests green (preset rules, projections, use-cases
  including the snooze limit, DAO round-trips against real SQLite, widget tests over an in-memory
  store).
- Not working / deferred: no notifications or alarms yet; "Open in <app>" is a stub until deep links
  arrive with the native path; Garden + Achievements screens are still placeholders; the day boundary
  is captured at provider build (no midnight rollover while the app is open).
- Next: Phase 0 native-thin capture spike (Share Sheet -> shared SQLite -> AlarmManager).

Session 2026-08-31 - Iteration 3 (native-thin capture: Phase 0's two-second spike)
- Goal: Share Sheet -> Kotlin -> direct SQLite write, with no Flutter engine, inside the < 2s budget.
- Done: CaptureActivity (translucent, no layout, no engine) + CaptureWriter (one transaction: row +
  captured event) + CyaDatabaseContract (native half of the schema contract, creates the file and
  stamps user_version when a share lands before the app has ever run) + ReminderDefaults (the
  zero-tap Tonight rule, ported from ReminderPreset). capture_ms is written into the event metadata
  and to Logcat.
- Working / verified on emulator (API 34), fresh install via `pm clear`:
  - Cold process, database did not exist: `am start -W` total 762 ms, of which 172 ms was the write
    (including creating the schema). Warm: 117 ms median over 5 runs, 10-18 ms per write.
  - On-device SQLite dump: user_version=1, epoch SECONDS, reminder_at = tonight 20:00, deep_link
    extracted from the shared URL, one captured event each with capture_ms.
  - The Flutter app then opened that native-created file with no migration, showed all six promises,
    projected 60 XP (6 captures x 10) from natively written events, and FTS search found a natively
    written promise by content.
- Broke / deferred: first run failed with `no such module: fts5` - Android's system SQLite has no
  FTS5, so the trigger-maintained index made every native insert fail. Redesigned (ADR-005): the
  index is Dart-owned and reconciled from a watermark. Reminder firing (alarms + notifications) is
  iteration 4; source_app shows the caller's label ("Shell" over adb).
- Next: iteration 4 - AlarmManager, notification channels by escalation tier, one-tap resolution
  from the notification, boot rescheduling, deep link into promise detail.

Session 2026-08-31 - Iteration 4 (closing the loop: alarms, notifications, escalation)
- Goal: Make a captured promise actually come back, and let the user close it from the notification
  without opening the app (3.4, 5.6, 8.4).
- Done: native ReminderScheduler (exact alarms, inexact fallback, boot + resume rescheduling),
  ReminderReceiver (reads current state, picks the tier, logs `resurfaced`), notification channels
  quiet/banner with Done + Snooze actions, NotificationActionReceiver writing straight to SQLite,
  BootReceiver, `cya://promise/<id>` deep link, a Dart ReminderPort so in-app capture/snooze/
  reschedule use the SAME native scheduler, missed-reminder detection + the Home banner that offers
  the fix, and notification permission requested at the moment its reason is on screen.
- Working / verified on emulator (API 34): capture schedules an exact RTC_WAKEUP alarm (confirmed in
  `dumpsys alarm`, exactAllowReason=policy_permission); a REAL alarm fired at 20:00:00 after
  advancing the device clock, posting the quiet-channel notification; Done from the notification
  resolved the row, logged `resolved{"surface":"notification"}`, dismissed the notification and
  cancelled the alarm - with no Flutter engine; snooze re-armed the alarm and the next fire escalated
  to the banner channel; the fourth snooze was refused and the digest tier posted no interruption;
  BootReceiver re-armed pending alarms; the deep link opened Promise Detail from a cold start.
  74 Dart tests green (7 new for missed reminders, 7 for scheduling side effects).
- Broke / deferred: [L-002] a Kotlin `return` inside the inline `transaction { }` helper silently
  rolled back every native capture while logging success - caught only on device. Flutter's automatic
  deep linking fed the raw `cya://` URI to go_router as a location ("no routes for location"); the
  app now routes its own links (`flutter_deeplinking_enabled=false`). The first notification used the
  launcher icon and rendered as a hollow blob - status-bar icons are alpha masks, so a white
  silhouette (`ic_stat_cya`) was generated. The weekly digest itself is iteration 5.
- Next: iteration 5 - Memory Garden, achievements, reward animations, and the weekly digest that
  escalation's third rung already points at.

Session 2026-08-31 - Iteration 5 (the reward half: Memory Garden + achievements)
- Goal: Turn the two placeholder tabs into the reward half of the product (6.6, 8.2) - the thing
  that makes closing the loop worth doing.
- Done: GardenProjection (plants, weekly beds, growth over a week, streak) and
  AchievementProjection (six badges as predicates over counts), both pure and tested; a
  CustomPainter garden scene inside a RepaintBoundary with five plant species, deterministic
  posture per promise, and a reduced-motion variant; the Garden screen (streak/this-week/all-time
  header, weekly beds, designed empty state); the Achievements grid with progress on locked badges;
  Profile now links to both instead of saying "Coming soon".
- Working / verified on emulator (API 34): six captures with four resolved across three weeks
  rendered as This week / Last week / Week of Aug 17 beds with distinct plants, 3-day streak,
  4 all-time; Achievements showed 1 of 6 unlocked with real progress (4/100, 1/50 - the 1 being the
  one kept promise that carried a link, which exercises the flavour query). 93 tests green.
- Not working / deferred: Rive reward animations (no .riv assets exist yet - the garden animates
  with Flutter instead, and reward moments are not built); the weekly digest.
- Next: the weekly digest (escalation's third rung), then enrichment (on-device date extraction and
  auto-categorization).

Session 2026-08-31 - Iteration 5 (part 2): the weekly digest
- Goal: Give escalation's third rung somewhere to point (5.6). A promise past the snooze limit stops
  interrupting - it has to end up somewhere, or "stops interrupting" just means "is forgotten".
- Done: native DigestScheduler (next Sunday 18:00, inexact, self-rescheduling so it survives reboots
  and time changes without drifting) armed from the same rescheduleAll() that arms reminders;
  DigestReceiver posting a low-importance notification that leads with what was KEPT and stays quiet
  on an empty week; a `cya://digest` deep link into a review screen with "Time to decide" (promises
  past the snooze limit), "Still waiting" and "Kept", each row resolvable in one tap.
- Working / verified on emulator: broadcasting the digest logged `digest_shown kept=1 open=2` and
  armed the next one for the following Sunday 18:00; the deep link opened the review from a cold
  start with the right sections. 97 tests green (4 new for the digest screen).
- Not working / deferred: Rive reward moments still need assets; enrichment is next.
- Next: enrichment - on-device date extraction (ML Kit) and rule-based auto-categorization, both off
  the capture path (3.2).

Session 2026-08-31 - Iteration 6 (Quick Settings Tile + manual categories)
- Goal: Close the two remaining Phase 1 items that are not the home-screen widget: a second capture
  surface (6.1) and manual categories (6.4).
- Done: CyaTileService + QuickCaptureActivity - a native dialog built in Kotlin (no XML, no Flutter
  engine) pre-filled from the clipboard, saving through the same one-insert-one-alarm path as every
  other surface. PromiseCategory (seven fixed categories with stored wire values that enrichment
  will later write into), a picker on Promise Detail, filter chips on the Promises tab, and a
  category icon on every promise tile. Chips also gained a hairline outline - unselected ones read
  as plain text before.
- Working / verified: tile capture on device logged `tile_capture_ok id=7 capture_ms=35` with the
  alarm scheduled and the row stored with source "Quick Tile"; the category picker and filters
  render and persist. 101 tests green.
- Not working / deferred: the home-screen widget is the last Phase 1 item; Rive reward moments still
  need assets.
- Next: the home-screen widget, then enrichment.
```

### 13.3 Decision log (ADR-lite)
Record any architectural or product decision that diverges from or refines this spec.
```
[ADR-001] Title
Date:
Context:
Decision:
Consequences:
```
Seed entries (already decided):
- **[ADR-000] Framework = Flutter.** Rationale in Section 4.1.
- **[ADR-000b] Capture path is native-thin.** Section 5.4. Never regress this.
- **[ADR-000c] Event-log-backed data model.** Section 7. Gamification + metrics derive from it.
- **[ADR-000d] No backend in V1; E2EE dumb-blob store later.** Section 5.7.

```
[ADR-001] Native, pre-Flutter animated video splash
Date: 2026-07-08
Context: The brand intro (Cya_splash.mp4) should feel native and play immediately on cold start,
  before the Flutter engine is ready, without a white/black flash on the native→Flutter handoff.
Decision: A Kotlin SplashActivity is the LAUNCHER and plays the mp4 (res/raw) on a TextureView via
  the framework MediaPlayer (center-cropped, muted) — chosen over Media3/ExoPlayer to avoid adding
  an AndroidX dependency graph on the bleeding-edge AGP 9 toolchain. A custom Application pre-warms
  a cached FlutterEngine during playback; MainActivity.provideFlutterEngine attaches it. Flash-free
  chain: values-v31 branded system splash → SplashActivity window = still first frame → TextureView
  alpha-revealed on first rendered frame → MainActivity warm-up window == Flutter Home background.
  One idempotent proceed() handles completion / error / 6 s timeout / tap-to-skip / reduced-motion.
Consequences: Splash is Android-only (iOS needs its own approach in fast-follow); the video lives
  only in res/raw (not double-bundled in pubspec). This is UI-layer native code for the splash and
  does NOT touch or regress the native-thin capture path (ADR-000b). One persistent pre-warmed
  engine (no auto-teardown; cached engines don't receive initial-route/intents — revisit for
  deep-links/capture).
```


```
[ADR-002] Event-log projections, XP weights and the level curve
Date: 2026-08-31
Context: 6.6 requires gamification to be a projection over the event log, and 13.6 left the XP
  weights and level curve open. Storing counters would make progress corruptible and unrepairable.
Decision: Nothing derived is stored. XP = 10 per capture, 25 per resolution (resolution weighs more
  because the product's failure mode is becoming a second backlog, 12). Advancing from level N costs
  250 x N XP, which puts level 12 in the 3,000 XP band shown in the approved mockup. Titles are
  garden-themed (Seedling, Sprout, Gardener, Memory Keeper, Future Builder, Promise Master, Legend).
  Week stats and garden growth are recomputed from this week's events.
Consequences: Progress is recomputable and tamper-resistant, and a logic change can be replayed.
  Cost: projections re-run on every event change - kept cheap by projecting XP from a grouped COUNT
  aggregate and stats from this week's rows only.
```

```
[ADR-003] Hand-written immutable domain entities instead of freezed
Date: 2026-08-31
Context: 4.2 lists freezed + json_serializable for immutable models. Drift's generator already emits
  immutable row classes with copyWith/equality, and the domain entities are few and small.
Decision: Diverge for now. domain/ uses hand-written immutable classes with const constructors,
  explicit copyWith and value equality; Drift's generated classes cover the data layer. freezed gets
  added when unions (sealed state machines) or JSON serialization actually earn it - encrypted sync
  (5.7) is the likely trigger.
Consequences: One codegen pipeline (build_runner + drift_dev) instead of two, and less generated code
  to compile. Risk: hand-written equality/copyWith can fall out of step with the fields - mitigated
  by keeping entities small and covered by the DAO round-trip tests. This is a LOGGED divergence
  from 4.2, not a silent one.
```

```
[ADR-004] One SQLite file at getApplicationSupportDirectory()/cya.db, with a written native contract
Date: 2026-08-31
Context: 5.2/5.4 require the Kotlin capture path to open the same database Drift uses, and 3.3
  requires a single local source of truth.
Decision: One file, cya.db, in application support (app-private storage reachable from Kotlin).
  Column names are pinned with .named(...) rather than left to the generator; status and event types
  are stored as documented wire strings; DateTime columns use Drift's default INTEGER unix SECONDS.
  The FTS index is maintained by SQL triggers so a native insert stays searchable with no Dart
  running. Device settings (theme, display name) live in a preferences table in the same file rather
  than a second preferences mechanism. All of it is written down in docs/native_db_contract.md,
  which any schema change must update.
Consequences: The native writer can be a plain SQLite insert with no Flutter dependency. Cost: two
  runtimes now share a migration contract - every schema change is a two-sided change plus a doc
  update.
```


```
[ADR-005] The FTS5 search index is Dart-owned, not database-owned
Date: 2026-08-31
Context: Iteration 2 kept the search index in sync with SQL triggers so that natively written
  captures would stay searchable without the Flutter engine. The first on-device run of the native
  capture path failed outright: `no such module: fts5`. Android's system SQLite - the one a plain
  Kotlin SQLiteDatabase uses - is built without FTS5 (verified on API 34 / Android 14), while the
  Dart side bundles its own SQLite with FTS5 enabled. Any trigger referencing an fts5 table makes
  every native INSERT fail, which would silently break the product's core promise.
Decision: The native path knows nothing about search. It creates and writes only intentions,
  intention_events and preferences. Drift creates the fts5 table on open and catches it up using a
  watermark (`preferences['fts_indexed_through_id']` = highest indexed intention id), rebuilding
  after edits and deletions. Search reconciles before querying, so rows captured natively while the
  app was open or closed are always found.
  Rejected: bundling a second SQLite build into the Android side (adds a native library and a second
  SQLite version writing the same file, for a feature only used inside the app); FTS4 (available in
  Android's SQLite but a downgrade the PRD did not ask for).
Consequences: The capture path stays dependency-free and as thin as it can be, which is the point
  (3.1/5.4). Search results for a native capture are up to date from the next app open or search -
  unobservable, since search only exists inside the app. Trap recorded: do NOT reconcile by comparing
  COUNT(*) of the two tables - an external-content fts5 table reads its values from the content
  table, so the counts always agree even when nothing is indexed.
```


```
[ADR-006] Reminders are scheduled and shown by native code, not flutter_local_notifications
Date: 2026-08-31
Context: 4.2 lists flutter_local_notifications for notifications. But 5.4 requires a capture from the
  Share Sheet to schedule its default reminder without starting the Flutter engine, and 3.4 requires
  one-tap resolution FROM the notification. A Flutter plugin cannot do either while the engine is
  not running.
Decision: One scheduler, in Kotlin. `ReminderScheduler` (AlarmManager), `ReminderReceiver`
  (notification + `resurfaced` event), `NotificationActionReceiver` (Done/Snooze written straight to
  SQLite), `BootReceiver` (re-arm after reboot). The app reaches the SAME scheduler through a
  `MethodChannel` (`ReminderPort` -> `PlatformReminderScheduler`), so a promise captured in the app
  and one captured from a share behave identically. `domain/` depends only on the
  `ReminderScheduler` interface and stays pure Dart.
Consequences: No Flutter dependency anywhere on the resurfacing path, which is what makes the loop
  work when the app has never been opened. Cost: the escalation ladder and the snooze limit now
  exist in two places (SnoozePolicy in Dart, CyaStore/ReminderNotifications in Kotlin) and must be
  kept in step - both are covered by tests, and iOS will need its own implementation.
  Rejected: also disabled Flutter's automatic deep linking, because it hands the raw `cya://` URI to
  go_router as a location; MainActivity passes it over the channel instead.
```

### 13.4 Mistakes & lessons learned
```
[L-001] The shared database is only as portable as the weakest SQLite that opens it
What broke / went wrong: The first on-device native capture failed with `no such module: fts5`, so
  nothing was saved. Every Dart test had passed, because Dart bundles its own SQLite.
Why: The schema was designed against Drift's SQLite build (FTS5 enabled) and assumed the Kotlin side
  would behave the same. Android's system SQLite has no FTS5, and the FTS triggers ran inside the
  native INSERT.
Fix: ADR-005 - the search index is Dart-owned; the native DDL contains no FTS at all, and a test
  asserts that (`the native path never needs the fts5 module`).
Lesson / rule to remember going forward: When two runtimes share a database file, the schema may
  only use features BOTH SQLite builds have. Anything richer belongs to whichever side bundles its
  own engine, as a derived artifact it maintains itself. Green tests on one runtime prove nothing
  about the other - the two-runtime path needs a device run before it can be called done.
```

```
[L-002] A non-local `return` inside an inline `transaction { }` silently rolled back every capture
What broke / went wrong: After refactoring the native writer into `CyaStore`, Share Sheet captures
  logged `capture_ok id=1` and returned a row id - but the database was empty. The reminder receiver
  then reported "no longer pending" for a promise that had never been stored.
Why: `transaction { }` is a Kotlin *inline* helper that calls `setTransactionSuccessful()` after the
  lambda and `endTransaction()` in a `finally`. `capture` returned its result from *inside* the
  lambda, which is a non-local return: it unwound straight past `setTransactionSuccessful()` into the
  `finally`, so SQLite rolled the transaction back. `insertOrThrow` had already handed back the
  row id, so every signal said success.
Fix: return the value as the lambda's last expression, never with `return`; early exits use a
  labelled `return@transaction`. The helper now carries a doc comment saying exactly this.
Lesson / rule to remember going forward: an inline block that must run code *after* your body is a
  trap for `return`. More generally: a write is not verified by the writer's own return value -
  verify it by reading the data back (`sqlite3` on the device), which is what finally caught this.
  Refactoring native code needs its own device run; the Dart tests could never have seen this.
```

### 13.5 Test & verification log
| Date | What was tested | Result | Notes |
|---|---|---|---|
| 2026-07-08 | `flutter analyze` | ✅ 0 issues | Iteration 1. |
| 2026-07-08 | `flutter test` (Home smoke + reactive toggle) | ✅ 2/2 | |
| 2026-07-08 | `flutter build apk --debug` | ✅ built | AGP 9.0.1 / Gradle 9.1 / Kotlin 2.3.20. |
| 2026-07-08 | Native splash → Home handoff (emulator API 34) | ✅ | Video plays pre-engine; no flash into Home. |
| 2026-07-08 | Reactive toggle updates Today ring | ✅ | 1/4 → 2/4 on tap. |
| 2026-07-08 | Dark mode render | ✅ | M3 dark + values-night warm-up. |
| 2026-07-08 | Reduced-motion (animator scale 0) skips video | ✅ | Fast handoff, no video. |
| 2026-08-31 | `flutter analyze` | ✅ 0 issues | Iteration 2. |
| 2026-08-31 | `flutter test` (53 tests) | ✅ 53/53 | Preset rules, XP/week/garden projections, use-cases + snooze limit, DAO round-trips on real SQLite, widget tests over an in-memory store. |
| 2026-08-31 | FTS5 availability + trigger sync | ✅ | Captured rows are searchable immediately; deleting one removes it from the index. |
| 2026-08-31 | Event-log invariant (mutation implies event, same txn) | ✅ | Asserted per transition in test/data/intention_dao_test.dart. |
| 2026-08-31 | Native Share Sheet capture, cold process, fresh install (API 34) | ✅ 762 ms | `am start -W` total; `capture_ms=172` for the write incl. schema creation. Budget is < 2000 ms (§9.2). |
| 2026-08-31 | Native capture, warm process x5 | ✅ 117 ms median | Writes 10-18 ms. |
| 2026-08-31 | Native-created database opened by Drift | ✅ | user_version=1, no migration, all six rows read; XP projected 60 from native events. |
| 2026-08-31 | FTS search over a natively written row | ✅ | "paper" matched a promise Dart never wrote (index reconciled from the watermark). |
| 2026-08-31 | On-device value encodings | ✅ | captured_at/reminder_at are epoch SECONDS; reminder = tonight 20:00; deep_link extracted from the shared URL. |
| 2026-08-31 | Exact alarm registered by the capture path | ✅ | `dumpsys alarm`: RTC_WAKEUP, window=0, exactAllowReason=policy_permission, origWhen 20:00:00. |
| 2026-08-31 | Real alarm fires (clock advanced to 19:59:30) | ✅ 20:00:00.483 | Quiet-channel notification with Done + Snooze. |
| 2026-08-31 | One-tap Done from the notification | ✅ | Row resolved, `resolved{"surface":"notification"}` logged, notification dismissed, alarm cancelled — no Flutter engine. |
| 2026-08-31 | Escalation quiet → banner → digest | ✅ | Second fire used cya_reminders_banner; at snooze_count 3 the fire logged tier=digest and posted nothing. |
| 2026-08-31 | Snooze limit enforced natively | ✅ | 4th snooze `granted=false`; the promise is re-shown quietly asking to close the loop. |
| 2026-08-31 | Boot rescheduling | ✅ | BOOT_COMPLETED → `rescheduled count=1`. |
| 2026-08-31 | `cya://promise/<id>` deep link, cold start | ✅ | Opens Promise Detail (after disabling Flutter's own deep-link handling). |
| 2026-08-31 | `flutter test` (74 tests) | ✅ 74/74 | +7 missed-reminder detection, +7 scheduling side effects. |
| 2026-08-31 | Garden + achievement projections | ✅ | 16 unit tests: weekly beds, stable species per promise, growth over a week, streak rules (same-day, missed day, grace for today), badge predicates and progress. |
| 2026-08-31 | Garden and Achievements on device | ✅ | 4 kept promises across 3 weeks rendered as beds with a 3-day streak; 1 of 6 badges unlocked with correct progress. |
| 2026-08-31 | `flutter test` (93 tests) | ✅ 93/93 | +16 projections, +3 widget tests (garden populated, garden empty, achievements). |
| 2026-08-31 | Weekly digest fires and re-arms | ✅ | `digest_shown kept=1 open=2`, next scheduled for the following Sunday 18:00. |
| 2026-08-31 | `cya://digest` deep link | ✅ | Cold start into the review screen with Kept / Still waiting sections. |
| 2026-08-31 | `flutter test` (97 tests) | ✅ 97/97 | +4 digest screen (leads with kept, stalled section, resolve from the review, empty week). |
| 2026-08-31 | Quick Settings Tile capture | ✅ 35 ms | Native dialog → row stored with source "Quick Tile" + exact alarm scheduled; no Flutter engine. |
| 2026-08-31 | `flutter test` (101 tests) | ✅ 101/101 | +4 category round-trip, storage and clearing. |

### 13.6 Open questions
- Which capture mechanism becomes the primary driver of retention in practice (Share Sheet vs Tile)?
- Confirm exact dark-mode Surface 2 hex from the palette file.
- Should the day boundary roll over live while the app is open (midnight timer), or is a resume-time refresh enough?
- ~~Exact XP weights for capture vs resolution; level curve.~~ Decided in ADR-002.
- Digest timing/frequency defaults.
- Rive reward animations (8.3) need designed .riv assets before they can be built; the garden
  currently animates with Flutter's own animation system. Who produces the mascot rig?

---

## Appendix A — Capture feasibility reference
| Capability | Android | iOS | Note |
|---|---|---|---|
| Share content | Yes | Yes | Official APIs |
| Notification capture | Yes | No | Android Notification Listener (sensitive) |
| Overlay bubble | Yes | No | Platform restriction |
| Read private chats | No | No | Blocked by OS privacy — intentionally not attempted |
| Widgets | Yes | Yes | Supported |
| App Intents | N/A | Yes | Apple ecosystem |

## Appendix B — Definition of done (per feature)
1. Meets its acceptance criteria in Section 10. 2. Respects all Core Principles (3) and NFRs (9). 3. Tests added/passing (9.5). 4. No analyzer warnings. 5. Status updated in 13.1; any decision in 13.3; any breakage + lesson in 13.4.
