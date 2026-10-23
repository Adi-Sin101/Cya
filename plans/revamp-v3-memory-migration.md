# Proposed revamp memory migration — approval required

15 October 2026. **Approved for staged implementation** by the user's instruction
“start implementing the phases, go on”. Implements ADR-018 and the
approved product direction, informed by `docs/Cya_Product_Direction_Audit.md`.
This document requests approval of the design boundary, not a claim of tested DDL.
Exact DDL and native/Drift parity tests must be reviewed before release.

## Decision requested

Approve an additive shared-store v2 → v3 migration for neutral memories,
immutable revisions, managed attachments, explicit relationships, user-selected
focus and resumable derived-data work. Preserve existing promises, identifiers,
events, reminders and preferences unchanged. Do not automatically convert every
promise into a second memory or change the plaintext-to-cipher conversion routine
in this migration. The latter needs its own recovery-focused change and fixtures.

The new tables share the existing encrypted SQLite file. The schema version and
DDL must change in Kotlin and Drift together, including native-first creation.
Android's native writer must never issue FTS5 SQL or load a model.

## Proposed records and invariants

| Record | Proposed contents and rules |
|---|---|
| `memories` | Stable UUID, kind (text/audio), current revision pointer, capture/update/archive timestamps and source context. A neutral memory has no default reminder, XP, completion or aging. |
| `memory_revisions` | Immutable UUID, memory FK, preceding revision, original/current text, timestamps and reason. First captured text is never overwritten. Edits create a new revision and update the current pointer in one transaction. Audio metadata edits do not alter original bytes. |
| `memory_attachments` | Stable UUID, memory FK, app-private relative path, media type, byte length, checksum, duration and pending/ready/error state. Never DB audio blobs or arbitrary absolute/imported paths. |
| `memory_links` | Typed source/target references to memories or existing intentions, relationship (related/branch/supersedes/task), provenance (user/model), pending/accepted/dismissed and source revision/section anchor. Validate endpoint existence; reject cycles only where relationship semantics require it. No automatic merge or source mutation. |
| `focus_sessions` | User-selected intention or stated priority snapshot, start/end and dismissed-prompt state. A save commits before a dismissible focus-return prompt; no app blocking or disruptive alarm. |
| `memory_events` | Append-only changes with revision/attachment/link identifiers and minimal metadata; mutation and event commit together. Existing `intention_events` semantics remain unchanged. |
| `memory_jobs` | Job kind, source/revision hash, state, attempt count, next retry and lease expiry. Durable enqueue in save transaction, bounded worker after save; process-death recovery and cancellation on deletion. |
| `memory_vectors` | Source/revision/segment identifiers, model artifact digest, encoder configuration, dimension, normalization and preprocessing version; bounded numeric vector storage. No mixing incompatible versions. Start with measured flat scan, introduce approximate index only if benchmark justifies it. |
| `memory_transcripts` | Optional derived, editable ASR result with engine/language/confidence metadata where available, independent from immutable audio and raw-audio embedding jobs. |

SQLite FKs must cover concrete tables. For heterogeneous links use separate
nullable intention/memory columns with exactly-one endpoint CHECKs, rather than
unvalidated polymorphic IDs. UUID encoding, enum values, timestamp seconds and
checks become part of `docs/native_db_contract.md`; integer intention IDs retain
their existing encoding. Avoid requiring new intents to satisfy memory-only rules.

## Save, attachment and deletion protocol

Text save: transaction inserts memory, initial revision, captured event and
indexing job; acknowledge only after commit. Model loading is never on this path.
Audio save: record to a private staging file, finish/flush, validate readable media,
then atomically rename within the same volume to a UUID-based managed path.
Commit its ready attachment, memory, event and job together before acknowledging.
File and SQLite operations cannot form one transaction: use explicit pending
states and startup reconciliation. Reconcile orphan files only after a grace
period and an ownership check. Recording interruption must expose recovery or
discard, never a false successful save. Storage limits and disk-full errors need
visible feedback without deleting source data.

Archive retains originals/history and hides normal results through explicit
filters; it does not erase vectors. Hard delete requires user confirmation and
an explicit preview of linked/history effects. Delete/cancel derived rows and
jobs transactionally, then remove owned files using a persisted cleanup job.
Retain no personal-content tombstone after hard deletion. Links to deleted
sources must resolve to an explicit missing reference or be removed under the
approved policy; never silently relink to a different record. Backups already
exported remain under the user's control. Final retention wording needs review
before enabling hard delete.

## Required semantic engine and separate ASR

EmbeddingGemma 2 text/raw-audio retrieval and related discovery are required for
product-direction completion. Install a pinned verified artifact only through
bundling or explicit local user installation. Validate digest, file type and
runtime compatibility; no automatic download or remote fallback. A disabled or
missing model leaves save/browse/keyword/reminders usable with pending jobs.

Do not add the runtime to the app until an isolated compile/initialization proof
confirms the exact artifact/API. See the compatibility research and audit for
the Java/Kotlin metadata mismatch, audio WAV input, nullable encoder backends,
eager configured audio initialization and absent long-input metrics. Queue raw
audio embedding independently of optional ASR. Bound decode/resample and chunk
work; chunk metadata must permit playback at the retrieved location. Normalize
and version vectors consistently; compare official/runtime query templates in
the pinned-artifact quality experiment before choosing one. Never double-prefix.

Reuse the audit's required no-transcript audio evaluation and Bangla/English/
Banglish corpus. Measure text→text, text→audio and related discovery separately;
report per-language Recall@k/MRR and reviewed suggestion precision. Image/video
use the same versioned embedding space later, with explicit decoder/frame
sampling, storage, privacy and runtime tests. ASR quality (WER/CER and code-switch
retention) is a separate experiment, never evidence for raw-audio retrieval.

## Migration and acceptance sequence

1. Inventory existing encrypted/native-first/Flutter-first v1/v2 fixtures. Record
   hashes and row/event counts before migration; create recovery fixtures without
   exposing personal content or keys. No destructive upgrade on a user's only copy.
2. Implement equivalent v3 create/upgrade transactions in native and Drift. Reject
   newer unsupported versions. Replace swallowed native ALTER failures with
   verified transactional upgrade; never stamp a failed upgrade as complete.
3. Test all four writer/opener combinations, v1→v3/v2→v3, interrupted upgrade,
   failed SQL, disk full and repeated reopen. Assert exact promise fields, IDs,
   reminder timestamps, event order/counts and preferences are preserved; native
   FTS ban and state/event atomicity remain true.
4. Ship typed-memory persistence/browse/keyword with Unicode combining-mark
   regression cases. FTS is Dart-owned and rebuildable; test Bangla vowel marks,
   English and Banglish with positive and negative matches. Preserve promise UI.
5. Ship recording/playback and crash-safe attachment recovery, then required
   pinned-model indexing/query/suggestions. Test retry, process death, deletion,
   rebuild, version changes and stale-revision cancellation, with no inference
   before save acknowledgement. No transcript/filename metadata in raw-audio
   retrieval evaluation.
6. Test focus prompts, immutable history, user links and branch source preservation.
   Add versioned export/import in a separate bounded change: validate manifest,
   checksums, schema, sizes, traversal, duplicates and missing attachments before
   any writes. Import must preview conflicts and use explicit decisions; no silent
   overwrite. Export warns that a shared plaintext archive is user-controlled.
7. Run full analyzer/tests/release build plus airplane-mode, reboot/reminder,
   low-storage and model-disabled tests. Measure capture and model cold/warm
   latency, peak RAM, battery and thermal behavior on named devices, especially
   Galaxy A52 4G 8GB. Emulator evidence does not satisfy hardware budgets.

## Recovery, rollout and remaining decisions

No automatic schema downgrade. Before installation over real data, validate a
coordinated version-compatible recovery copy and restore procedure. Keep the
old APK and its compatible snapshot separate from the migrated store; never
open v3 with an old writer that accepts unknown versions. Restore must verify
key availability and attachment consistency. Reindex derived data instead of
restoring incompatible vectors. Test every recovery procedure before use.

Approve separately any changed OS backup policy, legacy cipher-file conversion,
hard-delete retention rule or new network permission/dependency. No new network
permission is proposed. Runtime dependency selection is contingent on compatibility
proof and local permission review. Final A52 budgets and any artifact/runtime
optimization decision require measurements; failure cannot remove semantic memory.

**Execution:** implement/test in bounded coordinated versions. v3 begins with
typed memories, revisions, events and jobs; attachment/link/vector tables follow
as their behavior is implemented. Approval does not imply tested DDL or safe
personal-device rollout. No actual user-data conversion has occurred yet.
