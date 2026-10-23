# Iteration 10 — revamp foundation preflight

Date: 15 October 2026. Status: complete for this bounded preflight unit.
Implements the user's phased revamp direction, Master PRD sections 3/5/9,
ADR-018, and audit risks for key failure and native-write visibility.

## Requirement analysis and decisions

The user's implementation instruction authorizes proceeding from the completed
audit into bounded foundation work. The supplied extension remains under
`docs/revamp/`; establish its canonical approved copy at
`docs/Cya_Product_Direction_PRD.md`, preserving the original proposal.
EmbeddingGemma 2 direct text/audio retrieval is required P0. Do not interpret
the absent phone or runtime uncertainty as permission to drop it.

This unit protects the current application before adding memories. Risky schema,
encryption-file conversion and restore changes require a concrete reviewed plan
and the user's explicit approval. Schema stays at v2 in this unit.

## Steps

1. Record the governing scope decision before implementation.
2. Add regressions for Android key-fetch failure/null/malformed key handling;
   prevent selecting a plaintext connection on Android.
3. Add regressions for native-like writes while Flutter stays alive, then refresh
   Drift-backed views and cached search results on resume without polling/capture work.
4. Verify the exact proposed local model Android AAR/API/ABI/permission surface;
   record whether the available emulator can run it. Do not add unverified runtime
   dependencies to the app or claim a phone benchmark.
5. Prepare a concrete memory migration/attachment/index plan for approval.
6. Run focused/full tests, analyzer and Android build. Update logs and status
   with exact delivered behavior, limits and next approval boundary.

## Acceptance criteria

- Existing Android key bridge errors, nulls and invalid raw-key literals fail
  before opening an unencrypted database; only explicitly unsupported non-Android
  hosts may use the existing missing-plugin fallback.
- A native-like committed capture/notification transition updates Home and search
  after resume, without restarting Flutter, model inference or native-path changes.
- Current promise loop regressions remain green; no table/version/dependency changes.
- Exact model compatibility facts distinguish published APIs from executed support.
- Migration proposal specifies data preservation, original audio/history, async jobs,
  native/Drift parity, rollback and failure tests; no migration executes before approval.

## Feedback

Completed Android key fail-closed handling and resume refresh of shared-table
streams plus cached search. Added four key-bridge tests and two end-to-end widget
regressions over a real memory database. Initial tests reproduced both defects.
The search test needed complete lifecycle transitions and enough animation frames
to drain its entrance timer; the corrected full suite passes.

`flutter analyze --no-pub`: exit 0, zero issues (8.8s).
`flutter test --no-pub --reporter expanded`: exit 0, 189/189 (21s).
`flutter build apk --debug --no-pub`: exit 0 (Gradle 20.0s).
Logs: `.buildlog/revamp-preflight-{analyze,test,build}.log`.
Schema remains v2; no package, native writer, audio or model changes.

Exact SDK inspection is recorded in
`docs/revamp/EmbeddingGemma2_Android_Compatibility.md`: SDK compile metadata
needs an isolated build proof; WAV API and emulator ABI exist, configured audio
loads eagerly. No weights/inference or A52 benchmark occurred. No new network
permission/dependency; runtime airplane-mode verification was not rerun here.

Proposed migration: `plans/revamp-v3-memory-migration.md`, pending explicit user
approval before schema changes. This unit is not completion of Phase 1:
recording, memory schema/UI, required model inference and portable data remain outstanding.
