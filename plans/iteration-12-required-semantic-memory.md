# Iteration 12 — required local EmbeddingGemma 2 integration

15 October 2026. In progress; approved phased implementation continues.
Depends on Iteration11's tested v3 typed-memory foundation and actual local
artifact/runtime proof in the Android compatibility report.

Pinned484,622,336-byte generic model and LiteRT-LM0.18.0 successfully execute
text and raw-WAV embeddings on API34 x86_64, CPU2threads, float32,256 dimensions,
vision omitted. Initial diagnostic PSS after audio440,928KiB; cold init16.9s.
Never initialize on app/native capture startup. Keep runtime local installation
explicit and digest checked; no downloads or network permission in the app.

Steps: resolve R8's Kotlin2.4 metadata warning with a minimal supported build-tool
configuration in the isolated probe; run its minified APK. Add a lazy native
embedding bridge and local-file installation only after compatibility proof.
Implement versioned vector persistence, bounded durable jobs/retry/rebuild,
semantic text retrieval and reviewable related suggestions. Extend to managed
raw-audio source records with independent playback, recording/recovery and
direct text-query→audio evaluation; ASR remains separate and optional per audio
record, never a prerequisite. All required semantic behavior must eventually pass.

Acceptance: source/event/job commit precedes any inference; installed/model-disabled
paths are honest; finite normalized vectors with matching version/dimension only;
deletion removes derived rows; upgrades reindex; pending/failed jobs survive death.
Run real pinned artifacts, no fake vectors presented as model success. Preserve
existing promise/native regressions. Offline release manifest and airplane mode,
device measurements and multilingual retrieval corpus remain explicit test gates.

Current official Android compatibility table requires R8≥9.1.29 for Kotlin2.4:
https://developer.android.com/build/kotlin-support . The isolated AGP9.0.1 release
build succeeded but emitted metadata warnings; test minimal R8 override before
changing the app toolchain. Do not suppress warnings as proof of compatibility.

## Integration results (2026-10-15)

Text engine delivered: pinned SDK/model, lazy local installation/inference, durable versioned segments/retries/rebuild, semantic search and reviewable historical connections. R8 JNI stripping crash fixed with package keep and R8 9.1.56. Full213 tests, focused19, analyzer0 and production release splits pass. Actual airplane app smoke passes text indexing/search, raw-audio API and disabled-model fallback. Seed Banglish Hit@1 only6/10; representative quality remains required. See BUILD_LOG and compatibility report for exact timings/pins. Audio source integration continues in Iteration13; this is not complete semantic/device acceptance.
