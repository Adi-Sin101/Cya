# Iteration18 — release, phone and required semantic acceptance

16 October2026. Continues the approved extension and routine delta after the
implemented schema8 foundation. Semantic memory remains required. This is a
validation unit, not permission to ship keyword-only memory as complete.

## Requirement analysis and approach

Run all Flutter/analyzer/native checks and build the normal minified Android
release. Upgrade A52 in place without uninstall/clear or reading private content.
Exercise explicit routine creation/Today selection/outcomes/recovery/reviews,
immutable branches and model-disabled capture/keyword. Confirm release permissions
and actual settled airplane-mode operation, then restore original device radios.
Test process restart preserving saved data. Physical microphone tests require an
intentional recording by the user; automated tests use public/synthetic audio.

Extend the isolated minified model probe with20 public Google FLEURS validation
recordings (10en_us,10bn_in),60 positive text queries and3 unrelated queries.
Use raw PCM16 WAV only for audio embedding, official text search prefixes,256d
normalized vectors, CPU2threads/float32, no vision. Compare exact native-language
queries, independently authored cross-language paraphrases and20 Banglish queries
against all20 audio/text candidates. Same sentence IDs are multi-positive across
languages. Report per-stratum Hit@1/Recall@5/MRR, latency distribution and observed
PSS; audio-to-reference-text is an alignment check, not labeled relatedness quality.
No ASR/transcript enters the audio index. Public transcripts are evaluation
queries/reference text only. No private source is sent off-device.

Dataset pin google/fleurs70bb2e84b976b7e960aa89f1c648e09c59f894dd,
CC-BY4.0. Preserve original hashes, float32→PCM16 conversion and any20s clipping.
Fetch only development-host public data; no application downloader/permission.
Reproducible probe logic and independent queries live in tool/benchmarks.

## Acceptance and limits

- Flutter/analyzer/native checks and release build pass with exact results logged.
- A52 schema6→8 upgrade retains current records/settings and original model install.
- Routine/review/branch flows work offline and survive process restart. No mic
  activation or destructive low-storage experiment on personal phone.
- Actual no-network state confirmed after settling; restore original radios.
- Report measured speech retrieval weaknesses, sampled RAM and warm/cold status.
  USB charging prevents a defensible unplugged energy claim. Do not call a small
  Wikipedia-speech fixture representative personal-memory/Banglish-speech quality.
- Full held-out300-query/1000-source protocol in model feasibility research remains
  the release-quality gate. No silent model substitution/removal. Optimize supported
  modalities, quantization/lazy loading/bounded jobs if measured budgets fail.
- Offline ASR is P1 feasibility/benchmark work per approved v2 scope; no Android
  speech API is assumed offline. Vision/video are staged shared-space extensions.
- Record unrun low-storage, mic interruption, reboot/rescheduling and sustained
  unplugged battery/thermal tests honestly; never certify them from host tests.
