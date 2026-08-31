# Native ↔ Drift database contract (schema v1)

> Companion to [Cya_Master_PRD_and_Development_Bible.md](Cya_Master_PRD_and_Development_Bible.md)
> §5.2, §5.4 and §7. **Both runtimes write this file.** If the Kotlin writer and the Drift schema
> disagree, captures are silently lost or corrupt — the one failure this product cannot survive.
> Change nothing here without bumping `CyaDatabase.schemaVersion` **and** the native writer together.

## The file

| | |
|---|---|
| File name | `cya.db` |
| Dart location | `getApplicationSupportDirectory()/cya.db` |
| Android native location | the same path — reachable from Kotlin as `context.filesDir` sibling; resolve it once in a shared helper, never hardcode it twice |
| Journal mode | SQLite default via Drift (WAL where the platform allows). Native must open the same file with the same journal mode and honour `-wal` / `-shm` siblings |
| Foreign keys | `PRAGMA foreign_keys = ON` on **every** connection, including the native one |

## Value encodings

| Dart type | SQLite storage | Note |
|---|---|---|
| `DateTime` | `INTEGER`, **Unix epoch seconds, UTC** (Drift's default) | Kotlin: `instant.epochSecond`, *not* `System.currentTimeMillis()` |
| `bool` | not used in v1 | — |
| enums (`status`, event `type`) | `TEXT`, the exact wire strings below | Never store ordinals |

## Tables

### `intentions` — current state (PRD §7.1)

| Column | Type | Null | Default | Notes |
|---|---|---|---|---|
| `id` | INTEGER | no | autoincrement | primary key |
| `source_app` | TEXT | no | — | e.g. `Messenger`, `Chrome`, `Cya!` |
| `raw_content` | TEXT | no | — | exactly what was captured; never rewritten by enrichment |
| `snippet` | TEXT | yes | — | short display form of the source context |
| `deep_link` | TEXT | yes | — | return-to-source URI |
| `captured_at` | INTEGER | no | — | epoch seconds |
| `reminder_at` | INTEGER | yes | — | epoch seconds; the alarm time |
| `category` | TEXT | yes | — | filled in later by enrichment |
| `status` | TEXT | no | `'open'` | see vocabulary |
| `snooze_count` | INTEGER | no | `0` | drives escalation + the snooze limit |
| `extracted_deadline` | INTEGER | yes | — | on-device enrichment only |
| `updated_at` | INTEGER | no | — | epoch seconds |

### `intention_events` — append-only log (PRD §7.1)

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | INTEGER | no | autoincrement |
| `intention_id` | INTEGER | no | FK → `intentions.id` |
| `type` | TEXT | no | see vocabulary |
| `occurred_at` | INTEGER | no | epoch seconds |
| `metadata` | TEXT | yes | JSON object, or NULL |

**Rule:** a row in `intentions` is never inserted or mutated without a matching row in
`intention_events`, *in the same transaction*. This holds for the native writer too — a capture is
`BEGIN; INSERT intentions; INSERT intention_events(type='captured'); COMMIT;`.

### `preferences`
`key` TEXT primary key, `value` TEXT. Device-scoped settings only.

### `intentions_fts` — FTS5 search index (PRD §6.4)

**The native writer must not touch this table, and must not create it.**

Android's system SQLite ships **without the fts5 module** (verified on API 34 / Android 14), so any
trigger referencing an FTS5 table would make every native insert fail. The index therefore lives
entirely on the Dart side, which bundles its own SQLite build:

```sql
CREATE VIRTUAL TABLE IF NOT EXISTS intentions_fts USING fts5(
  raw_content, snippet, content='intentions', content_rowid='id');
```

Drift creates it on open if missing and catches it up from a watermark stored in
`preferences['fts_indexed_through_id']` — the highest `intentions.id` already indexed. Native rows
written while the app was closed are picked up the next time the app opens or searches. Search is
only ever used inside the app, so this is unobservable to the user.

> Do **not** reconcile by comparing `COUNT(*)` of the two tables: an external-content FTS5 table
> reads its values from the content table, so the counts always match even when nothing is indexed.

### Indices
`idx_intentions_status`, `idx_intentions_reminder_at`, `idx_intention_events_occurred_at`,
`idx_intention_events_intention`.

## Vocabularies (exact strings)

- `intentions.status`: `open` · `snoozed` · `resolved` · `archived`
- `intention_events.type`: `captured` · `snoozed` · `resurfaced` · `resolved` · `archived` · `edited`

Defined once in Dart as `IntentionStatus.wire` / `IntentionEventType.wire`
(`lib/domain/enums/`). Mirror them as Kotlin constants — do not retype literals at call sites.

## The zero-tap default reminder

Every capture surface must be able to save with no extra taps (PRD §6.1). The default is
`ReminderPreset.tonight`, and native must compute it identically to
`lib/domain/enums/reminder_preset.dart`:

| Preset | Rule (local time) |
|---|---|
| Tonight *(default)* | today 20:00; if it is already ≥ 20:00, `now + 2h` |
| Tomorrow | tomorrow 09:00 |
| Weekend | the next Saturday 10:00 (today if Saturday before 10:00) |

## Migrations

`CyaDatabase.schemaVersion` is the single version number for both runtimes. A migration must:

1. bump `schemaVersion` and add the Drift `onUpgrade` step;
2. update the Kotlin writer in the same change;
3. update this document;
4. add a migration test.

## Who creates the file

Either runtime, whichever runs first — a share can arrive before the app has ever been opened. The
creator runs the shared DDL and stamps `PRAGMA user_version = 1`; the other side then opens a
version-1 database and skips its own creation. `CyaDatabaseContract.CREATE_STATEMENTS` (Kotlin) and
Drift's `onCreate` must therefore stay equivalent, and `test/data/native_contract_test.dart` keeps a
copy of the native DDL and asserts Drift accepts it unchanged — including that it contains no `fts`.
