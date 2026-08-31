# Iteration 2 — Drift data foundation (event-log-backed store)

- Implements PRD: §3.3 (local store = single source of truth), §3.2 (dumb capture / async
  enrichment), §7 (data model), §5.3 (layering), §6.2 (reminder presets), §6.6 (gamification as
  event-log projections), §9.4/§9.5 (standards + tests), §10 Phase 0 (Drift DB + schema, Riverpod DI)
- Depends on: `iteration-1-foundation-splash-theme.md` (theme, shell, Home UI)

## Requirement analysis

Phase 0 is only half done: the scaffold, theme, shell and a designed (mock-fed) Home exist. The
missing half of Phase 0 is the **store** — and the store must land *before* the native-thin capture
spike, because §7.2 requires the native writer to insert rows that match the Drift schema. So this
iteration builds the schema, the DAOs, the pure domain layer over them, and swaps Home off the mock.

What the store must support on day one:

1. `Intentions` — current-state rows exactly as §7.1 lists them.
2. `IntentionEvents` — append-only log; **every** state change writes an event in the same
   transaction as the row mutation. Gamification and all §11 metrics are *projections* over it.
3. FTS5 over `rawContent`/`snippet` for V1 search (§6.4) — created now so the migration contract is
   stable before native code opens the same file.
4. Reactive `watch` queries so the UI is reactive over the DB (§3.3), with **narrow** streams (§9.1)
   — Home watches today's intentions, not the whole table.
5. A DB file at a **native-reachable, stable path** (not an opaque Flutter-only location), because
   the Kotlin capture path will open the same file (§5.2, §5.4).

## Approach / design

### Schema (v1)
`Intentions` and `IntentionEvents` per §7.2, plus:
- `intentions_fts` — FTS5 virtual table (`rawContent`, `snippet`), kept in sync by SQL triggers so
  **native inserts stay indexed without any Dart code running** (critical: the native capture path
  must not need Flutter to keep search correct).
- Indices on `status`, `reminderAt` (the two columns every hot query filters on).

`status` and event `type` are stored as `TEXT` and mapped through Dart enums with a **String value**
each, so the native writer can insert `'open'` / `'captured'` literals without sharing Dart code.

`schemaVersion = 1`. A `docs/` note records the native contract: table + column names, the status
and event-type vocabularies, and the DB filename. Native and Drift must never drift apart (pun
acknowledged); a future migration bumps both.

### DB location
`getApplicationSupportDirectory()/cya.db` — on Android this is
`/data/data/<pkg>/files/…`-adjacent app-private storage that Kotlin can reach with
`context.filesDir`. Encapsulated in `data/db/cya_database_paths.dart` (Dart) so there is exactly one
definition to mirror natively.

### Layering (§5.3, dependencies point inward)
```
domain/   entities: Intention, IntentionEvent, enums IntentionStatus, IntentionEventType
          repositories/: IntentionRepository (interface, pure Dart)
          usecases/: CaptureIntention, ResolveIntention, SnoozeIntention, ReopenIntention…
          projections/: xp/level, week stats, garden growth — pure functions over events
data/     db/: CyaDatabase (Drift), tables, converters
          dao/: IntentionDao (all SQL lives here)
          repositories/: DriftIntentionRepository implements the domain interface
presentation/ providers watch repository streams; widgets stay dumb
```
`domain/` keeps zero Flutter imports; projections are pure functions so they unit-test with no DB.

### Reminder presets → concrete times (§6.2)
`ReminderPreset.resolve(DateTime now)` — pure, testable, and **shared with native** by
specification: Tonight = today 20:00 (or +2h if already past 20:00), Tomorrow = tomorrow 09:00,
Weekend = next Saturday 10:00. Native uses the same rule for the zero-tap default so a capture
scheduled natively and one scheduled in Dart land on the same instant.

### Gamification projections (§6.6, §3.3)
Pure functions over the event stream: XP (capture = 10, resolution = 25 — weighted higher per §6.6),
level curve, weekly captured/completed/success-rate, garden growths = resolutions this week. Stored
nowhere; always recomputed → tamper-resistant and recomputable, as §6.6 demands.

### Home swap
`HomeController` stops reading `MockHomeRepository` and instead composes narrow watches. First run
seeds the demo promises from §8.2 **once**, guarded by an event-log check, so the designed Home
still looks alive on a fresh install without faking state.

## Steps
1. Add deps: `drift`, `sqlite3_flutter_libs`, `path_provider`; dev: `drift_dev`, `build_runner`.
2. `data/db/tables.dart`, `cya_database.dart` (+ FTS5 triggers in `onCreate`), run codegen.
3. `domain/entities` + `domain/repositories/intention_repository.dart`.
4. `data/dao/intention_dao.dart` — every mutation writes its event in one transaction.
5. `data/repositories/drift_intention_repository.dart`.
6. `domain/usecases/*` + `domain/projections/*` (pure).
7. Riverpod providers: database, repository, narrow stream providers for Home.
8. Rewire Home; delete the mock repository.
9. Tests: preset resolution, XP/level/week/garden projections, snooze-limit rule; DAO round-trip
   (capture → watch today → resolve → event log) where a sqlite3 library is available on the host.
10. Update PRD §13.1/§13.3/§13.5 and `plans/BUILD_LOG.md`.

## Acceptance criteria (PRD §10 Phase 0 / Appendix B)
- [ ] Drift DB with `Intentions` + `IntentionEvents` + FTS5 exists at a native-reachable path, at a
      pinned schema version, with the native write contract documented.
- [ ] Every state mutation appends an event **in the same transaction** — no path mutates a row
      without logging it.
- [ ] Home renders from reactive DB watches; toggling completion writes `resolved` and the Today
      ring, week stats and garden preview all update from the store.
- [ ] Gamification/metrics are recomputed projections over the event log (no stored counters).
- [ ] `flutter analyze` = 0 issues; `flutter test` green; `flutter build apk --debug` OK.
- [ ] PRD §13.1/§13.3/§13.5 + BUILD_LOG updated.

## Risks & mitigations
| Risk | Mitigation |
|---|---|
| Native writer and Drift schema diverge → corrupt/invisible captures | Single documented contract file; FTS kept by SQL triggers, not Dart; schema version pinned and asserted. |
| Wide `watch` queries repaint Home every write | Narrow, filtered watches per section + `select`/scoped providers (§9.1). |
| Projections recomputed on every frame | Compute in providers over a stream, not in `build`; keep them O(events-this-week). |
| Codegen (build_runner) friction on the bleeding-edge toolchain | Pin versions, commit generated files, keep drift usage plain (no fancy generators). |
| sqlite3 native lib unavailable to `flutter test` on Windows | Keep all business rules pure-Dart so they test without a DB; DB round-trip tests degrade to device/emulator integration. |
