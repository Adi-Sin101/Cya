# Iteration16 — explicit connections and immutable branches

Implements approved Phase2 after the Phase1 functional gate: tested text/audio
capture, browsing/history, model-disabled fallback, required real-model offline
retrieval, local export/import and durable chosen focus sessions. Phone quality,
ASR and sustained performance evaluation continue as Phase3/4 gates; they are not
waived or interpreted as optional semantic memory. Record exact gate evidence
before implementation; no claim all product-direction acceptance is complete.

Functional gate recorded 2026-10-16: full236 Flutter tests, current migration/
audio/import/UI subset18, analyzer0, release ARM64/x64 build (433.5s,49.3/55.4MB),
no INTERNET/ACCESS_NETWORK_STATE in release. A52 SM-A525F/API34 successfully
restored a locally selected ZIP with promise/audio/revision/focus histories,
installed exact model through production SAF bridge, indexed its raw WAV,
and returned Voice thought/Audio match near0s for a text query with no transcript.
Production app PSS observed673766KiB after indexing. Isolated R8 runtime on A52:
init2855ms, firsttext429ms, warmquery337ms,1s audio637ms, finite normalized256d;
post-audio PSS550071KiB. Short functional fixtures, not representative semantic
quality or sustained battery/thermal acceptance. Import root-navigator overlap
found on phone and corrected in source; final build will include it. Continue
Phase2 implementation while required Phase3 quality/hardware evaluation proceeds.

Reuse memory_links for explicit related/supports/contradicts/supersedes/branch
connections between exact revisions, with provenance=user versus model reviews.
Branch creates a separate text memory/revision/event/job and source link in one
transaction; source bytes/revisions stay unchanged. An optional selected quote
and offsets are recorded as context, never substituted for the original source.
Both directions remain navigable after either note is edited.

Add schema7 collections (topic/project, optional project parent) and assignments
from exact memory revisions to a collection or existing intention. Preserve the
one promise engine and scheduler. Native writer migrates identical SQLite DDL;
no inference/FTS/capture-path changes. FK cascades follow explicit endpoint deletion.
Validate tree parent/cycles and assignment target XOR. Organization is optional
at capture; no required tags/folders.

Provide a navigable bounded list/tree and explicit link/branch controls; similarity
suggestions remain separate, reviewable and never auto-merge. Do not ship a fake
graph. Any later graph is a bounded neighborhood over the same durable links.
Version export/import together, remap references, preserve historical provenance.

Acceptance: branch/links/events atomic, source hash/history unchanged, exact old
revision still navigable after edit, user/model origin visible, existing promise
reference has no duplicate task/reminder, collections cycle/invalid target rejected,
coordinated native/Drift parity and migration tests, portable full round trip and
offline navigation. Analyzer, full tests, release build and named device smoke.

## Execution feedback —16 October2026

Implemented transactional user links/immutable branches, bidirectional historic
revision navigation, topic/project hierarchy and existing-promise assignments.
Schema7/native contract and format6 portability landed before coordinated schema8
routines. Source content never changed by branching; no duplicate reminder engine.
9 connection tests pass, including rollback/provenance/cycles/import remapping and
native/Dart-first upgrade. The subsequent full schema8 suite260/260, analyzer0,
native8/8 and release ARM64/x64 pass (see BUILD_LOG). Physical branch navigation
is not yet claimed; final device validation continues in iterations18–19.
