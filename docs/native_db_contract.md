# Native ↔ Drift database contract (schema v8)

Current portable export format is8. Database schema8 remains unchanged by the
visual Rhythm/focus-clock unit described at the end of this contract.

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
| `source_package` | TEXT | yes | — | **v2.** The Android package `source_app` labels, e.g. `com.whatsapp`. Lets the UI draw that app's real launcher icon. NULL for an in-app capture or an unattributable share |
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
creator runs the shared DDL and stamps the current `PRAGMA user_version = 7`; the other side then opens that
version-5 database and skips its own creation. Existing v1/v2/v3/v4 stores upgrade additively. `CyaDatabaseContract.CREATE_STATEMENTS` (Kotlin) and
Drift's `onCreate` must therefore stay equivalent, and `test/data/native_contract_test.dart` keeps a
copy of the native DDL and asserts Drift accepts it unchanged — including that it contains no `fts`.

## Android key failure and reader visibility

Android must obtain a valid native SQLCipher raw key before Dart creates a
connection. Missing bridge, native errors, null and malformed keys fail closed;
none selects a plaintext connection. Unsupported non-Android hosts explicitly
permit the existing missing-plugin/null fallback. This does not validate legacy
plaintext conversion or certify encryption on unsupported targets.

Native SQLite commits do not notify Drift's connection-local query streams.
On Flutter resume, `CyaDatabase.refreshAfterNativeWrites()` marks all three shared
tables updated and the app invalidates cached search queries. FTS reconciliation
remains Dart-owned. No polling, inference, Flutter startup or new work is added
to native capture.

## v3 neutral typed memories

Approved by the user's 15 October 2026 instruction to implement the proposed
migration. Attachment/link/vector tables follow as their behavior is implemented;
v3 implements only the tested typed-memory vertical slice. No promise is copied
or converted; no existing intention/event fields change.

| Table | Fields (all NOT NULL unless marked nullable) |
|---|---|
| `memories` | `id` TEXT PK (UUIDv4), `kind` TEXT default `text`, `source` TEXT default `Cya!`, `captured_at`/`updated_at` INTEGER seconds, `archived_at` INTEGER seconds nullable |
| `memory_revisions` | `id` TEXT PK (UUIDv4), `memory_id` TEXT FK memories ON DELETE CASCADE, `revision` INTEGER (1-based, UNIQUE with memory_id), `body` TEXT original bytes, `created_at` INTEGER seconds |
| `memory_events` | `id` INTEGER PK AUTOINCREMENT, `memory_id` TEXT FK memories ON DELETE CASCADE, `type` TEXT, `occurred_at` INTEGER seconds, `revision_id` TEXT nullable FK memory_revisions ON DELETE CASCADE |
| `memory_jobs` | `revision_id` TEXT PK/FK memory_revisions ON DELETE CASCADE, `state` TEXT default `pending`, `attempts` INTEGER default0, `retry_at` INTEGER seconds nullable, `last_error` TEXT nullable |

Event vocabulary: `captured`, `edited`, `archived`, `restored`. Current content
is the revision with the greatest per-memory revision number, not a mutable
copy or timestamp tie-break. DAO edits preserve every earlier body; concurrent
editors must supply the expected revision. Capture/edit commits source state,
revision, event and pending semantic job in the same transaction. Archive does
not discard history/jobs; hard delete explicitly removes all source-owned rows.
No model or transcript is required to save/browse. Jobs are durable pending work,
not proof that the required semantic engine has been integrated.

The new keyword fallback is a parameterized literal substring over current
revision bodies; ASCII case-fold for English/Banglish, exact Bangla Unicode marks.
It uses ordinary SQLite, adds no native FTS/triggers and makes no stemming or
linguistic-normalization claim. The existing promise FTS is unchanged.

Both runtimes apply DDL and the v3 stamp in a transaction, propagate failures,
verify new columns and reject future versions. Native reads version only after
acquiring its transaction lock. Failed upgrades must not advance user_version.
Column/FK parity tests read the actual Kotlin memory DDL. Export format2 includes
all memory revisions/events; pending derived jobs are rebuildable and omitted.

## Schema history

| Version | Change |
|---|---|
| 1 | Initial: `intentions`, `intention_events`, `preferences`, indices |
| 2 | `intentions.source_package` — the package a share came from, so the promise list can show that app's real launcher icon (PRD §8.2) |
| 3 | Additive neutral memories, immutable revisions/events and durable semantic jobs; existing promise data untouched |
| 4 | Versioned segment vectors, reviewed revision-to-revision links, resumable job progress and memory-event metadata |
| 5 | Managed original audio attachment metadata and durable file-cleanup queue |

## v4 semantic derivations and reviewed links

`memory_jobs` adds `next_segment` INTEGER NOT NULL DEFAULT0 and `model_version`
TEXT nullable. States: `pending`, `running`, `failed`, `complete`. One1000-codepoint
text segment per worker turn; no inference before durable source/event/job save.
Running work has a retry timestamp; process restart recovers interrupted jobs.
Failure uses bounded exponential retries. A model/preprocessing version change
resets progress and replaces derived vectors, retaining original revisions.

`memory_vectors`: `revision_id` TEXT FK memory_revisions ON DELETE CASCADE,
`segment` INTEGER, composite PK(revision_id,segment); `model_version` TEXT,
`dimensions` INTEGER, `vector` BLOB, all NOT NULL. Current encoding is256
little-endian float32 values,1024bytes, finite and L2-normalized. This is bounded
derived numeric data, not an audio/model blob. Version encodes the exact model
SHA, LiteRT-LM0.18.0, CPU float32 text+audio configuration, dimension and search
preprocessing version. Different versions/dimensions never mix in scoring.

`memory_links`: `id` TEXT PK(UUIDv4), `from_revision`/`to_revision` TEXT FKs
memory_revisions ON DELETE CASCADE, `kind`/`provenance`/`state` TEXT,
`created_at` INTEGER seconds, all NOT NULL; UNIQUE(from_revision,to_revision,kind).
Current related suggestions store explicit user review as accepted/dismissed,
provenance `model`. No link is written merely because a score is high; no merge
or source rewrite occurs. Revision endpoints preserve historic context. Broader
user-created branch/task/topic relationships remain subsequent work.

`memory_events` adds nullable `metadata` TEXT JSON. Link review commits with an
event `link_accepted`/`link_dismissed`, source revision, link ID and target revision.
Hard deleting either endpoint cascades source-owned derived vectors/jobs and
incident links. Archive retains vectors/history and has an explicit search filter.

Native v3→v4 adds the three columns and two tables; native v1/v2 creation upgrades
create current memory tables directly. Dart follows the same paths. Both verify
new columns and commit DDL/version together; no FTS or model work in native capture.
Export format3 adds reviewed links to format2 memory data. Derived vectors/jobs
are intentionally rebuildable and excluded. No import completion is claimed yet.

## v5 managed original recordings

| Table | Fields (all NOT NULL) |
|---|---|
| `memory_attachments` | `id` TEXT PK(recording UUID), `memory_id` TEXT FK memories ON DELETE CASCADE and UNIQUE, `file_name` TEXT UNIQUE, `sha256` TEXT, `byte_length` INTEGER, `duration_millis` INTEGER, `captured_at` INTEGER epoch seconds |
| `attachment_cleanup` | `file_name` TEXT PK, `created_at` INTEGER epoch seconds; deliberately no FK to a deleted source |

Native and Dart resolve the same app-private `filesDir/memory_audio` directory.
File name is exactly `<recording-UUID>.wav`; no absolute/imported free-form path.
Recording format: standard44-byte RIFF/WAVE header, PCM16 little endian, mono,
16,000Hz,32,000bytes/second, maximum300seconds. Originals stay as managed files;
SQLite contains metadata only. SQLCipher does **not** encrypt these files.
UI disclosure precedes microphone access. Android microphone permission is
requested only on explicit Start; no speech service or ASR is involved.

Record to `<UUID>.part` with original capture-time sidecar `<UUID>.json`.
Bounded writes sync periodically and on stop. Final header/data sync precedes
rename to WAV. Stop/save verifies size, format, duration and SHA256, then commits
memory + initial revision/event/attachment/pending embedding job transactionally.
An audio memory's initial caption is empty; no fake transcript is stored.
Duplicate recovery of the same unchanged recording is idempotent, with no extra
memory/event. Conflicting metadata cannot replace an existing recording reference.

Leaving the foreground requests recorder stop and releases playback; no background
microphone service. Interrupted files remain recoverable, not falsely marked saved.
Recovery writes a separate valid WAV from complete PCM samples, retaining the
interrupted original until explicit discard/deletion. File locks prevent recovery
racing an active writer. A52/phone recording/latency acceptance still needs testing.

Each audio revision queues raw-audio inference, independent of caption/transcript.
Worker reads bounded20second WAV derivatives into RAM and calls the audio API;
source bytes are unchanged. `next_segment` counts20second audio segments for audio
and1000-codepoint text chunks for text. Version tag pins these preprocessing rules.
Search aggregates segment scores and retains the winning segment for playback
offsets. No transcript/title/filename is substituted for raw-audio embeddings.

Hard delete queues file names in the same transaction that deletes source rows;
then removes only owned WAV/staging/sidecar files. Interrupted cleanup stays
durable and retries on memory-screen entry. Global erase stops/unloads processing,
removes all managed originals/pending files and owned export/model caches, then
clears preferences. Public model weights are separate from personal data.
No secure physical-erasure claim is made.

Export format4 includes attachment metadata and streams exact original WAVs into
a plaintext ZIP with `manifest.json`, `manifest.sha256` and `attachments/<UUID>.wav`.
Every file must exist, match size and SHA; failure never publishes a partial archive.
No-audio exports remain readable JSON. User explicitly chooses where to share/save;
the archive is not encrypted. Import remains a subsequent validated unit.

## Schema6: focus session history (2026-10-16)

Both native and Drift add focus_sessions and focus_events, within the same
migration transaction/version stamp. v5 rows and model progress are unchanged.

- focus_sessions: id TEXT PK, priority TEXT, started_at INTEGER seconds,
  ended_at INTEGER seconds NULL. Current sessions have no end timestamp.
- focus_events: id INTEGER autoincrement PK, session_id TEXT FK focus_sessions
  ON DELETE CASCADE, type TEXT, occurred_at INTEGER seconds. Types started,
  ended and import_ended. Append-only except explicit full user erasure.
- Changing priority atomically ends active sessions, appends end/start events,
  inserts the new session and updates focus_priority preference projection.
  Ending does the same without creating a replacement. No alarm or app tracking.
- Native capture creates/migrates these tables but never runs focus/inference.
  No FTS operations were added. Full erase deletes sessions and cascaded events.
- Export format5 includes sessions/events; reads formats1–5. Imported active
  copies receive an explicit import_ended event and end time, preserving their
  original start/history and leaving current local focus unchanged. DB timestamps
  are seconds; exported Drift JSON timestamps are milliseconds (not ISO strings).
  Promise export dates retain the existing ISO format; importer handles both
  documented representations by record type.

## Schema7: explicit connections and optional organization

Both runtimes add memory_collections, collection_events and memory_assignments
in the existing migration transaction; all v6 originals/history stay in place.

- memory_collections: id TEXT PK, title TEXT, kind TEXT CHECK topic/project,
  parent_id TEXT NULL self FK ON DELETE SET NULL, created_at INTEGER seconds.
  Repository rejects missing/non-project parents and cycles/depth>32. Deleting
  organization never deletes memories/promises; children become top level.
- collection_events: id INTEGER autoincrement PK, collection_id TEXT FK CASCADE,
  type TEXT created/updated, occurred_at INTEGER seconds, metadata TEXT JSON.
  Title/parent changes and their historic snapshots commit transactionally.
- memory_assignments: id TEXT PK, revision_id TEXT FK memory_revisions CASCADE,
  intention_id INTEGER NULL FK intentions CASCADE, collection_id TEXT NULL FK
  memory_collections CASCADE, kind/context TEXT, created_at INTEGER seconds.
  CHECK permits exactly one destination with corresponding kind intention or
  collection. Unique revision+intention and revision+collection prevent duplicates.
  Context preserves the label/content observed at linking; endpoint updates do
  not silently replace that snapshot. Explicit assign/unassign append memory events.
- Existing memory_links stores user related/supports/contradicts/supersedes/branch
  edges as well as reviewed model related edges. Exact revision endpoints and
  origin persist. Navigation reads both directions; source content is untouched.
  Branch captures a new memory/revision/event/job and branch link/event in one
  transaction; optional source selection offsets/quote live in event metadata.
- Format6 exports/imports organization/events/assignments as well as earlier data;
  supported1–6. Import validates tree/references/target XOR and remaps identities,
  parent-first, never overwriting existing rows. Vectors are rebuilt, not imported.
- Full erase includes organization/events. Native capture only creates/migrates
  plain tables; no FTS/inference/network work is introduced.

## Schema8: routines, explicit day selections and optional reviews

Both writers create the following six plain tables in the existing migration
transaction, then stamp8. Existing v2–7 data is retained. Exact executable DDL is
`CyaDatabaseContract.ROUTINE_STATEMENTS`; Drift definitions are
`lib/data/db/routine_tables.dart`. Contract tests compare columns, defaults,
constraints, FKs and native-first/Dart-first upgrades. No model/Flutter boot/FTS
operation is added to native capture.

| Table | Columns and invariants |
|---|---|
| routines | id TEXT PK; current_revision INTEGER default1; position INTEGER default0; paused INTEGER boolean default0; created_at/updated_at INTEGER seconds; deleted_at nullable INTEGER. Remove is reversible soft removal with pause, retaining all versions/events/occurrences. |
| routine_revisions | id TEXT PK; routine_id TEXT FK CASCADE; revision INTEGER; title TEXT; weekdays nullable INTEGER (1–127, Monday bit0); preferred_start/end nullable INTEGER minutes; steps TEXT JSON default[]; fallback nullable TEXT; created_at INTEGER seconds. UNIQUE(routine_id,revision). Immutable versions. |
| routine_events | id INTEGER autoincrement PK; routine_id FK CASCADE; revision_id nullable FK revisions CASCADE; type TEXT; occurred_at INTEGER seconds; metadata nullable JSON TEXT. Created/edited/paused/resumed/reordered/removed/restored events commit with mutations. |
| routine_occurrences | id TEXT PK; change_version INTEGER default1; routine_id/revision_id FKs CASCADE; selected_day/target_day TEXT local YYYY-MM-DD; state TEXT planned/completed/skipped/deferred; position INTEGER default0; steps JSON TEXT; preferred_start/end nullable INTEGER; selected_at/updated_at INTEGER seconds. UNIQUE(routine_id,selected_day). Selection snapshots an exact immutable definition version. |
| routine_occurrence_events | id INTEGER autoincrement PK; occurrence_id FK CASCADE; type TEXT; occurred_at INTEGER seconds; metadata JSON TEXT with full before/after snapshots (initial before=null). Every change increments change_version and appends its event in one transaction. |
| local_reviews | id TEXT PK; origin TEXT default local; day_key TEXT; period daily/weekly; memory_id TEXT UNIQUE FK memories CASCADE; created_at INTEGER seconds. UNIQUE(period,day_key,origin). Local review uses origin=local; imported copies use distinct import:UUID slots, preserving current local review. Weekly key is local Monday. Prose reuses Memory revisions/events/index jobs. |

Window CHECKs permit null flexible timing or 0–1439 minutes with end>=start;
end requires start. These are **preferred same-day windows, not scheduled alarms**.
Repository validates titles/steps/weekday masks and optimistic revision/version.
Recurrence only suggests availability. Occurrences require explicit selection;
day rollover never inserts work, marks failure or infers completion. Shortening,
moving, reordering and pausing retain selected_day, definition version and history.
There is no second promise/reminder engine. Review facts use recorded events;
suggestions explain evidence and require manual action, never change plans.

Portable format7 includes all six lists and accepts prior formats1–6. Validate
references, contiguous definition versions, exact occurrence snapshot chains and
final states before writes. Import remaps all IDs, including snapshot IDs, and
preserves event order; current focus/settings/review remain unchanged. Imported
dated selections are visible as copies on their original dates. Imported review
notes remain browsable/searchable in Memories; they never replace the local
daily/weekly editor. Drift JSON snapshot timestamps are milliseconds; database
timestamps remain seconds. Full explicit erasure removes owned routine tables;
deleting a review memory cascades its association and derived memory data.

## Focus clock and portable format8 (no additional DDL)

`focus_timer_v1` is a device-local preference projection of an existing active
focus_sessions row: sessionId,priority,durationSeconds,remainingSeconds,nullable
deadline milliseconds,optional occurrenceId. It is not another routine/task or
alarm engine. Existing focus_events additionally permits timer_started,
timer_paused,timer_resumed,timer_stopped. Event and projection commit atomically;
starting/replacing/ending reuses FocusRepository. Loading checks that the original
session is still active; stale controls cannot pause/end a changed priority.
Countdown expiry is a UI clock state, never an inferred completion or end event.
Foreground rendering ticks once/second; background rendering stops. A persisted
wall-clock deadline restores remaining time after process death (manual system
clock changes can alter remaining time; no measured-work-duration claim).

Format8 introduces these event types and accepts1–7. Export retains focus history
and excludes the active device-clock projection; restore appends ended copies
without activating old timers or changing the local priority. No native capture
path, schema version, FTS restriction, network permission or encryption policy
changes in this unit. SQLCipher still protects DB records only, not WAV/archives.
