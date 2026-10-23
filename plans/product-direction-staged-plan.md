# Cya! product-direction extension — proposed staged plan

**Date:** 15 October 2026 (Asia/Dhaka). **Status:** proposed; awaiting review.
**Depends on:** the audited intention/promise foundation, schema v2 and current native
contract. This document does not replace the historical iteration plans.

## Requirement analysis

Derives from the existing Master PRD sections 3, 5, 7, 9 and its ADRs, and the proposed
extension at `docs/revamp/Cya_Product_Direction_PRD.md` plus its core-model clarification.
See [`../docs/Cya_Product_Direction_Audit.md`](../docs/Cya_Product_Direction_Audit.md)
for the full feature matrix, code evidence, risks, conflicts and benchmark procedure.

Preserve Cya!'s working promise loop while adding neutral text/original-audio memory,
focus-return, explicit connections/history and portable local backup. **EmbeddingGemma
2 semantic text+audio memory is required P0**, including text-query-to-audio retrieval
without a transcript and related-memory discovery. Image/video is a staged modality
extension, not a replacement for the audio requirement. ASR is separate P1 work.

Current observed baseline: Flutter 3.44.4 / Dart 3.12.2, Windows x64, Java 17,
Android SDK 36; `flutter analyze` clean, `flutter test --reporter expanded` **183/183**,
`flutter build apk --debug` succeeds. Only Android 14 x86_64 emulator is connected;
Galaxy A52/physical-phone model performance remains unmeasured. Supplemental ignored
audit probes confirm Bangla lexical discrimination and external-writer invalidation
gaps, plus null key-fetch error fallback. Existing tests/app/dependencies were unchanged.

## Approach and approval boundary

This is planning, not implementation authorization. Before any phase changes code,
agree its decisions and write a focused iteration plan with fixtures, rollback and
acceptance tests. Do not edit either product vision merely to eliminate a conflict.
Log approved decisions and future outcomes using repository conventions at that time;
the audit phase preserves existing product documents/build log.

Prefer a distinct neutral memory entity linked to existing intentions, one encrypted
local metadata store, managed protected attachment files and a unified read/search
projection. Reuse the intention scheduler and event-backed progress; do not create a
parallel task engine. The schema shape and source/promotion cardinality remain choices
for approval, not a migration specified by this plan.

## Phase A — resolve contracts and run the mandatory model POC

### Scope

- Resolve P0 semantic priority versus Master “Later/Pro,” automatic category/deadline
  writes versus reviewable suggestions, Tonight/retirement versus lasting memories,
  and offline/backup/export policy conflicts. Keep both documents intact until decisions.
- Obtain/identify the physical Samsung Galaxy A52 4G 8 GB/128 GB and a lower-resource
  profile; freeze device/build/corpus/budget reporting.
- After approval, build an isolated release benchmark harness, not a replacement app
  or production migration. First candidate: direct Kotlin LiteRT-LM **0.18.0** and
  `embeddinggemma-2-740m.litertlm`, publisher revision
  `24d962e906c7d332c6428e71c9676855024569e2`, SHA-256
  `e7a8a2204b91e0f96e92960e84a09a89212e1633dcb7575a9bf3378b4df77f4c`.
- CPU first, vision inactive; verify actual modular allocation. Do not substitute the
  text-only bundle for the required audio path. Resolve MediaPipe's documented
  1.1.1/0.17.0-alpha1 transitive version risk before considering that wrapper.
- Verify actual license/notices, local import and byte hash, AAR API/ABI/native
  packaging, prompt/precision conflicts, audio decode/streaming/window/pooling and
  reference parity. No remote samples or content upload.

### Acceptance

- Pinned artifact/runtime/dependency graph compiles and runs on the named phone,
  produces finite normalized vectors of the agreed dimension, and returns original
  text/audio sources with provenance.
- Demonstrate text→text search, **text→original audio with no transcript or descriptive
  metadata in the candidate index**, and related-memory discovery. ASR is not involved.
- Execute the audit's frozen corpus: >=600 text records, >=180 original audio clips,
  >=300 judged queries, >=90 relatedness seeds; English/Bangla/Banglish, code-switch,
  cross-language/no-match/hard-negative and quiet/noisy strata.
- Record quality at each relevant language/noise/duration stratum and latency/RAM/
  disk/battery/thermal measurements at 1k/10k/100k segments, cold/warm conditions.
- Starting gates for agreement: Recall@5 text >=0.80/audio >=0.70; related precision@5
  >=0.70; no core language below 0.60 Recall@5; warm query p95 <=1 s at 10k segments;
  30 s audio RTF <=1; incremental model PSS <=1 GB; no severe thermal status/OOM.
  These are **proposed**, not measured or approved results. Preserve Master capture
  median <2 s and cold interactive <2 s; propose p95 capture <2 s/<=10% regression
  while indexing, and measure foreground frame/reminder behavior.
- At least 30 cold/100 warm samples for key configurations and >=3 paired 20–30-minute
  sustained energy/thermal runs; measurements include backend/threads/model/index size,
  physical OS/SoC/ABI, memory headroom and uncertainty.
- If a candidate fails, supply actual measured blockers and quality-preserving
  modular/quantized/runtime/backend/scheduling alternatives. If none pass, request an
  explicit product decision; do not silently demote EmbeddingGemma 2 or substitute ASR.

## Phase B — protect current data and capture before extension migration

Depends on approved contracts and Phase A evidence sufficient to choose runtime/index
boundaries. Design fixtures can proceed independently after review.

### Scope

- Fail closed for Android key/cipher errors, recoverable legacy encryption conversion,
  atomic schema/version migration, supported-version checks, key persistence failures.
- Define cloud-backup/D2D exclusions and portable restore/key lifecycle separately.
- Add real native test seams and explicit native→Drift invalidation; protect user-picked
  reminder provenance and distinguish schedule/delivery attempts from verified outcomes.
- Agree memory/attachment/revision/link/job/vector contracts and deletion/rollback policy.

### Acceptance

- Existing **183 tests** retained and passing; add focused regressions for observed
  risks rather than tests that only copy the implementation.
- v1/v2 plaintext/encrypted fixtures survive native-first and Flutter-first upgrade;
  simultaneous opener, failed ALTER, full disk, failed rename and process death cannot
  stamp a broken version or replace source with an empty DB. Unknown future schema fails safely.
- Missing/corrupt/wrong keys never create plaintext on production Android or silently
  reset data. Test/desktop fallback is explicitly scoped and disclosed.
- Native share/Done/Snooze while Flutter remains alive refreshes corresponding UI without
  restart. Custom reminders are not silently moved by an enrichment pass.
- Native creation/mutation agrees with Drift encodings/FKs; state/event pairing is checked
  on the real runtime. No FTS/vector/model work or Flutter boot added to native capture.
- No unintended private DB/recording/vector/key cloud backup; actual restore behavior
  tested. Retained reminders, notification actions, widget/tile and lock behavior pass.

## Phase C — local text/audio memory and explicit focus-return

### Scope

- Neutral text memory, original audio recording/playback and optional promise links;
  minimal capture without mandatory title/tag/project/transcript/model.
- Safe private attachment staging/readiness/recovery and authenticated encryption;
  recording interruptions, storage quotas/errors and user-mediated microphone permission.
- Multilingual lexical browse/edit/archive/delete, source/revision distinction and
  explicit archive access; preserve existing promise surfaces/metrics.
- User-selected focus session with start/end/change, configurable capture-window
  duration and save-first return-to-priority confirmation. No screen/app surveillance.

### Acceptance

- Airplane-mode save→process death→restart returns exact retained text/original audio;
  playback and source browsing work with model absent/corrupt/paused.
- Bangla vowel/minimal-pair, combining-mark/conjunct, English and Banglish/mixed-script
  lexical fixtures pass agreed retrieval rules; retain originals, normalize derivatives only.
- Permission denied/revoked, low storage, call/background interruption, missing attachment
  and process death at each file/DB staging step recover without losing confirmed data.
- A memory does not become a pending promise/alarm/XP/auto-retirement merely by existing.
  Source promotion/linking does not unnecessarily copy the old intention library.
- Focus confirmation appears only after durable capture and uses the user's chosen
  priority. Dismiss/change/end are available; a timer is not represented as observed work.
- Current promise navigation, native captures, reminder actions and reduced motion remain
  covered; physical capture/recording overhead stays inside agreed device budget.

## Phase D — production required semantic memory and related suggestions

### Scope

- Native asynchronous runtime adapter selected by Phase A; lazy model lifecycle,
  explicit local installation/status/pause/resume, bounded foreground-aware worker.
- Persistent derived segment/vector index and job lifecycle with exact artifact/source/
  revision/prompt/preprocessing/dimension metadata, version swap/rebuild and deletion.
- Semantic query and direct audio results, original-source/time-span navigation,
  related-memory suggestions and explicit accept/dismiss provenance.

### Acceptance

- All Phase A quality/resource gates pass in the app's release build on A52, including
  no-transcript audio retrieval and per-language/code-switch results; no cached online demo.
- Initialization/inference never occurs on capture or app startup. Query/worker cancellation,
  missing model, low memory and corrupt index leave navigation/save/keyword paths usable.
- Model version/prompt/dimension changes trigger a compatible new index/rebuild, not mixed
  vectors. Delete/edit during inference rejects stale commits; no deleted source returns.
- Exact-search oracle measures any ANN recall loss. Source/vector/link cleanup and interrupted
  reindex/restart are tested; private vector storage does not bypass encryption policy.
- Suggested relationships are labeled, traceable and reviewable; no automatic merge, rewrite
  or invented personal facts. Relatedness quality is separately measured from search.

## Phase E — explicit connections/history and safe portable data

### Scope

- Typed user/accepted/suggested/dismissed links; branch/source segment anchors; projects/topics
  optional; current view versus superseded historic source records.
- Versioned archive with DB logical snapshot, attachment inventory/checksums and independently
  defined encryption; local import with new/merge/replace choices, staging and recovery.

### Acceptance

- Branching never changes parent; both current and prior belief/decision are accessible;
  no algorithm silently resolves a contradiction. Link navigation has a simple back path.
- Export→clean-install import preserves source bytes, revisions, promise/event integrity,
  links and attachment counts/hashes; destination rekeys private storage and re-arms reminders
  deliberately. Derived indexes can rebuild and never import stale device credentials/jobs.
- Truncated/corrupt/future-version archives, traversal/absolute paths, symlink entries,
  duplicate/conflicting ids, missing referenced attachments and decompression/size bombs
  fail before changing the live store. Wrong password/integrity failure is recoverable.
- Merge/replace never silently overwrites; current data has a recoverable snapshot before
  replacement. Deletion covers managed sources/derivatives/jobs/links/export caches per
  disclosed policy; no unsupported secure-flash-erasure claim.

## Phase F — staged vision/video, ASR and exploration UI

### Scope and acceptance

- Image/video indexing: validate actual exported runtime ingestion, 70/140 image-token
  settings, deterministic media processing and 0.2/1 fps bounded keyframe/audio segments;
  measure text→image/video moment and cross-modal relatedness, original timestamps and
  visible-only/audio-only relevance separately. Re-run P0 capture/text/audio resource gates.
- Offline ASR: evaluate multilingual Whisper tiny/base/small through pinned whisper.cpp
  and/or sherpa-onnx adapters. Independent corpus scoring: WER, Bangla CER, code-switch
  spans, names/numbers and silence hallucinations; RTF/RAM/energy measured on A52. No `.en`
  substitute for Bangla, no cloud workaround; editable transcript remains a derivative.
- Bounded topic/list/tree/graph views with accessible list fallback and large-corpus frame
  tests. Keep explicit edge records as truth, not canvas layout.
- Optional TTS priority needs resolution (proposal says both P1 and P2). Require a verified
  offline voice and explicit activation; no unsolicited spoken alarms.
- Confirm Bangla font fallback/readability, large text, dark mode, semantics and reduced motion
  on physical screens. Scope iOS native parity separately; no claim from scaffold presence.

## Release rule, risks and feedback

Phases C, D and E are internal milestones; the extension release is **not complete**
until required local text+audio semantic memory and all other agreed P0 criteria pass.
Staging is implementation order, not permission to ship keyword-only memory as finished.

Primary risks: shared-runtime migration/encryption failure, missing phone evidence,
runtime/artifact/prompt compatibility, code-switch retrieval quality, concurrent native
writes, attachment privacy/recovery, sustained memory/thermal pressure and unsafe restore.
Mitigation is explicit fixtures, frozen benchmarks, bounded processing and reviewed
contracts, not a rewrite or unsupported performance assurance.

After approval, split each phase into small iteration plans, update authorized logs/ADRs
with actual results, and stop for a product decision when measured blockers cannot be
resolved within the agreed model/device budget. **No phase has been implemented by this plan.**
