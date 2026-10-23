# EmbeddingGemma 2 Android compatibility verification

16 October execution follow-up: the historical inspection statement below is
superseded for actual runtime evidence by the later experiments in this document
and [A52 public speech benchmark](A52_Semantic_Benchmark_2026-10-16.md). Exact
pinned runtime/artifact now performs20-source/60-positive-query local speech
retrieval on the physical phone; see that report for measurements and limits.

Verified 15 October 2026, Asia/Dhaka. This follow-up inspects the published Android SDK before integration. It preserves the earlier `docs/Cya_Model_Feasibility_Research.md`. No application/dependency/schema edits, model weights, inference run, or device benchmark were made. Public SDK artifacts and source were downloaded into ignored `.buildlog/model-compatibility/` only.

## Published artifact inspected

Coordinate: `com.google.ai.edge.litertlm:litertlm-android:0.18.0`. The downloaded [official AAR](https://dl.google.com/dl/android/maven2/com/google/ai/edge/litertlm/litertlm-android/0.18.0/litertlm-android-0.18.0.aar) is **20,905,807 bytes**, SHA-256 `706cbb8a87739b2818111bf3a19a78b8f7781586d10f80adf3415581fab7595f`. [POM](https://dl.google.com/dl/android/maven2/com/google/ai/edge/litertlm/litertlm-android/0.18.0/litertlm-android-0.18.0.pom) SHA-256 `3c631cd8e04fe4289818d41675c0f6b1f26a7a37db63606699a51e2c95695a54`. No `-sources.jar` was available at the corresponding URL (HTTP 404); public v0.18.0 tagged source supplied the source inspection instead.

Actual ZIP contents:

| Entry | Uncompressed bytes | ZIP compressed bytes |
|---|---:|---:|
| `AndroidManifest.xml` | 243 | 164 |
| `classes.jar` | 191,250 | 177,166 |
| `R.txt` | 10,701 | 2,211 |
| `jni/arm64-v8a/liblitertlm_jni.so` | 22,155,680 | 9,706,385 |
| `jni/x86_64/liblitertlm_jni.so` | 26,353,160 | 10,703,419 |
| `LICENSE` | 16,086 | 5,010 |
| `THIRD_PARTY_NOTICE.txt` | 2,198,164 | 310,354 |

There is also an empty `res/` entry. No `aar-metadata.properties` entry was present. Sizes above are SDK ZIP facts, **not final APK size or inference RAM**. Both native libraries combined are 48,508,840 bytes before packaging. ABI splitting changes the installed package contribution; actual final release APK size must be measured after integration.

The text Android manifest declares package `com.google.ai.edge.litertlm`, **minimum SDK 24**, and an empty application. It declares **no permissions, services, activities or providers**. This is verified for this AAR, not the final application manifest.

## ABI, ELF and local emulator

NDK `28.2.13676358` `llvm-readelf` inspection found both ARM64 and x86_64 ELF files. Each imports system libraries `libandroid`, `libz`, `libGLESv2`, `libEGL`, `libGLESv3`, `liblog`, `libdl`, `libm`, and `libc`. All displayed LOAD segment alignments were `0x4000` (16 KiB). This supports ELF alignment readiness; it does not establish final APK ZIP alignment or full Android 16 KiB execution compatibility.

The connected device was `emulator-5554`, `sdk_gphone64_x86_64`, Android API **34**, `ro.product.cpu.abilist=x86_64,arm64-v8a`. The SDK provides **native x86_64**, so its CPU POC does not need ARM translation. Native load, corrupt/missing-model errors, model capability inspection and CPU inference with a user-installed model are valid emulator experiments. GPU acceleration and Galaxy A52 performance cannot be certified from this emulator. No physical Galaxy A52 was connected during this check.

No `socket`, `connect`, `getaddrinfo`, `sendto`, `sendmsg`, `recv`, `curl` or `ssl` undefined dynamic symbols matched in these two libraries. This narrows the observed network surface; dynamic symbol inspection cannot prove absence of all network behavior, statically linked code, indirect syscalls, future dependencies or app-originated uploads.

## Dependency and toolchain facts

The exact POM declares three compile dependencies:

| Direct dependency | Version | Additional non-test dependencies observed in its POM |
|---|---|---|
| `com.google.code.gson:gson` | 2.14.0 | `com.google.errorprone:error_prone_annotations:2.48.0` |
| `org.jetbrains.kotlin:kotlin-reflect` | 2.4.0 | `kotlin-stdlib:2.4.0` |
| `org.jetbrains.kotlinx:kotlinx-coroutines-android` | 1.11.0 | `kotlinx-coroutines-core-jvm:1.11.0`, `kotlin-stdlib:2.2.20` |

Core coroutines additionally declares `org.jetbrains:annotations:23.0.0` and stdlib 2.2.20. Gson's JUnit/Truth/Guava test dependencies are test scope and should not enter the application through this POM. None of the observed production dependency coordinates is an HTTP client, remote model installer or telemetry SDK. These POMs are not a resolved app graph: Gradle conflict resolution, parent/BOM constraints, plugin dependencies and any additional app dependencies still need checking. [Gson POM](https://repo.maven.apache.org/maven2/com/google/code/gson/gson/2.14.0/gson-2.14.0.pom), [reflect POM](https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-reflect/2.4.0/kotlin-reflect-2.4.0.pom), [Android coroutines POM](https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/kotlinx-coroutines-android/1.11.0/kotlinx-coroutines-android-1.11.0.pom), [core coroutines POM](https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/kotlinx-coroutines-core-jvm/1.11.0/kotlinx-coroutines-core-jvm-1.11.0.pom).

`javap -v` on the actual `EmbeddingEngine.class` reports **class major version 65 (Java 21)** and Kotlin metadata **`mv=[2,4,0]`**. The existing repository sets Kotlin plugin **2.3.20**, Java/Kotlin JVM target **17**, and uses Flutter's minimum SDK setting. The discovered `java.exe`/`javap.exe` belongs to Eclipse Adoptium JDK **17.0.17.10**. These differences require a compile/D8/metadata compatibility check; this document does **not** claim that the current build already fails or that a blanket toolchain upgrade is necessary. Do not disable metadata checks or override the SDK's minimum API to hide an actual incompatibility. Verify the Gradle JVM separately from the shell JVM.

The previously inspected MediaPipe `tasks-retrieval:1.1.1` POM resolves LiteRT-LM **0.17.0-alpha1**, while the [0.18.0 release](https://github.com/google-ai-edge/LiteRT-LM/releases/tag/v0.18.0) explicitly adds EmbeddingGemma 2 APIs. Direct pinned LiteRT-LM remains the initial compatibility candidate; adding a wrapper without a resolved-version test risks silently using a different engine. [MediaPipe POM](https://dl.google.com/dl/android/maven2/com/google/mediapipe/tasks-retrieval/1.1.1/tasks-retrieval-1.1.1.pom).

## Actual Kotlin API and modality lifecycle

`javap` confirms the shipped classes contain `EmbeddingEngine`, `EmbeddingEngineConfig`, `EmbeddingOptions`, `EmbeddingResponse`, `InputData.Text`, `InputData.Audio`, `InputData.Image` and model-capability classes. The engine has `initialize`, sync/async single and batch computation, `isInitialized`, and `close`. Audio is **`InputData.Audio(ByteArray)`**; [tagged `Session.kt`](https://github.com/google-ai-edge/LiteRT-LM/blob/v0.18.0/kotlin/java/com/google/ai/edge/litertlm/Session.kt) explicitly documents **WAV**. There is no public raw-float streaming constructor or explicit video input class in this API. No evidence here supports passing AAC/M4A bytes directly. Preserve originals and create bounded WAV derivatives for input; image/video staging will need decoded frame/audio handling.

The exact config accepts model path **or** Android file descriptor (exclusive), main backend, nullable vision/audio backends, cache directory, maximum text input length, vision token budget and activation precision. Options accept normalization, special-token insertion, output dimension and per-call vision budget. `EmbeddingResponse` exposes **only `FloatArray embedding`**. [Tagged configuration](https://github.com/google-ai-edge/LiteRT-LM/blob/v0.18.0/kotlin/java/com/google/ai/edge/litertlm/EmbeddingConfig.kt), [engine](https://github.com/google-ai-edge/LiteRT-LM/blob/v0.18.0/kotlin/java/com/google/ai/edge/litertlm/EmbeddingEngine.kt).

**Supported omission differs from lazy loading:** native settings create modality executor settings only when corresponding backends are supplied. `visionBackend=null` omits a vision executor, and `audioBackend=null` omits an audio executor. Native code does support lazy modality compilation, but its flag defaults **false** and the inspected Kotlin config/JNI does **not** expose/set that flag. Therefore do not promise first-audio-use lazy loading inside an initialized Kotlin engine. For this API, lazily construct a text+audio engine after durable capture, with vision null, and close/release it under explicit lifecycle control. Alternatively benchmark separate text-only/text+audio engines with non-overlapping lifetimes. Even omission does not prove every model byte is unmapped or no preprocessing objects exist; measure actual memory. [Native settings](https://github.com/google-ai-edge/LiteRT-LM/blob/v0.18.0/runtime/engine/embedding_engine_settings.cc), [settings default](https://github.com/google-ai-edge/LiteRT-LM/blob/v0.18.0/runtime/engine/embedding_engine_settings.h), [JNI](https://github.com/google-ai-edge/LiteRT-LM/blob/v0.18.0/kotlin/java/com/google/ai/edge/litertlm/jni/litertlm.cc).

The native implementation decodes audio using metadata-driven preprocessing, checks mono output configuration, computes audio features and flushes/resets state at audio end. It truncates vector dimensions **before** L2 normalization. Native embedding responses include input length, truncated length and chunk count, but the Kotlin JNI returns only the vector, dropping those diagnostics. Consequently finite normalized vectors alone cannot prove that all long-recording content was represented. Segment/time-span accounting, bounded test cases and known-content tail retrieval are necessary. The settings' internal `max_sequence_length=30` is an executor argument, **not evidence of a public 30-second audio limit**. [Core implementation](https://github.com/google-ai-edge/LiteRT-LM/blob/v0.18.0/runtime/core/embedding_engine_impl.cc), [audio preprocessing](https://github.com/google-ai-edge/LiteRT-LM/blob/v0.18.0/support/preprocessor/audio_preprocessor_miniaudio.cc).

Do not rely on defaults: explicitly request float32 CPU activation and normalize with 768 or 256 output dimensions, then assert finite unit vectors in the harness. The runtime exposes float16 as an enum, which does not override the model card's precision warning. Task-prefix discrepancies documented in the earlier research remain unresolved and require ranking/reference comparison.

## Model availability rechecked without weights

The official repository remains at revision `24d962e906c7d332c6428e71c9676855024569e2`. Its generic `embeddinggemma-2-740m.litertlm` metadata lists **484,622,336 bytes**, SHA-256 `e7a8a2204b91e0f96e92960e84a09a89212e1633dcb7575a9bf3378b4df77f4c`. [Publisher API](https://huggingface.co/api/models/litert-community/embeddinggemma-2-740m-litert-lm?blobs=true), [file listing](https://huggingface.co/litert-community/embeddinggemma-2-740m-litert-lm/tree/24d962e906c7d332c6428e71c9676855024569e2).

This proves listed availability, not a locally tested model/runtime pair. No model bytes were downloaded. The SDK AAR contains Apache license and third-party notices; that is a runtime licensing fact and does not resolve the earlier model-card/generic-guide licensing discrepancy for weights.

## What can be proved next

1. Add the SDK only to an isolated benchmark/diagnostic integration after reviewing build scope. Record resolved dependency versions, merged permissions, minSDK and final ABI packaging. Run compile and release D8 first; report any actual Kotlin/JDK issue before choosing the smallest toolchain fix.
2. On API34 x86_64, exercise native load and deliberate missing/corrupt-local-model errors without model weights. Verify errors recover and capture/navigation do not initialize or await the engine. This establishes plumbing only.
3. With separately approved/local-installed pinned model, inspect `ModelInfo.from(localPath)` capabilities/runtime minimum/backends and execute synthetic text plus synthetic/consented WAV audio. Verify direct text-to-audio similarity with transcripts completely absent; then perform the multilingual corpus tests in the prior research.
4. Capture normalization/dimension checks, cold/warm timings, repeated lifecycle behavior, original audio/time-span preservation, and missing-tail/truncation experiments. CPU emulator timings are diagnostics, not A52 acceptance numbers.
5. Repeat release tests on physical Galaxy A52 8 GB for correctness, CPU/GPU compatibility, peak memory, process death, battery/thermal and capture concurrency. A52 is not available in this inspection. No feature-completion or device-performance claim can precede those results.
6. Confirm offline behavior using the final merged app without INTERNET permission where feasible, airplane mode and observed network traces. A clean SDK manifest and the absence of network symbols/dependencies are supporting evidence, not a substitute for runtime verification.

EmbeddingGemma 2 text+audio semantic memory remains required. These findings constrain the implementation strategy and truthful test claims; they do not downgrade the capability.

## Executed compatibility and inference proof — 15 October follow-up

The implementation instruction authorizes continuing the POC. An isolated
diagnostic APK under ignored `.buildlog/embedding-probe/` uses AGP9.0.1,
Kotlin2.3.20, JVM target17 and direct LiteRT-LM0.18.0 including its resolved
transitives. The existing application's dependencies were not changed for this
experiment. `android/gradlew.bat -p .buildlog/embedding-probe :app:assembleDebug
:app:assembleRelease --console=plain` exited0, BUILD SUCCESSFUL in5m29s.
The release configuration enabled R8 minification. R8 emitted two Kotlin
metadata parsing warnings; that is a remaining release concern, not a compiler
failure. Both APK builds succeeded, and the debug SDK's JNI loaded on API34
x86_64. A deliberate missing model raised `LiteRtLmJniException` with NOT_FOUND,
not a missing-class/ABI/linkage error. No toolchain upgrade was necessary for
this compile and D8 proof. Release runtime behavior is not yet tested.

Downloaded the **public model to the development workspace**, not through the
application. Exact484,622,336 bytes and SHA-256
`e7a8a2204b91e0f96e92960e84a09a89212e1633dcb7575a9bf3378b4df77f4c`
match the pinned publisher metadata. Installed that file into the diagnostic
package's private storage with ADB; no application download path was added.
The current [official model card](https://ai.google.dev/gemma/docs/embeddinggemma/model_card_2?hl=en)
explicitly designates Apache2.0; generic-guide license wording still should not
override the exact artifact's terms/notices when packaging a distributable.

**Actual executed CPU text+raw-audio path:** `EmbeddingEngineConfig` with
CPU(threadCount=2), visionBackend=null, audioBackend=CPU(threadCount=2), float32
activations. Explicit normalization and256 output dimensions. A Bangla/Banglish
text input, English text query, and locally synthesized1second16kHz mono PCM16
WAV produced finite256-dimensional vectors. Audio norm1.00000005. The raw WAV
went directly to `InputData.Audio`; no ASR or transcript existed. The query/audio
cosine was0.7388; a single pair without distractors is **not retrieval-quality
evidence**. This proves that the exact artifact/runtime pair executes the
required modality path; integration and corpus evaluation remain necessary.

One emulator run (concurrent host builds; no phone acceptance claim):

| Diagnostic | Measured |
|---|---:|
| Engine initialization |16,899ms|
| First text embedding |2,325ms|
| Next text query |790ms|
| One-second raw-audio embedding |3,296ms|
| App PSS before initialization |33,079KiB|
| PSS after initialization |250,607KiB|
| PSS after audio |440,928KiB|

PSS values are snapshots, not sampled peak RAM or encoder-only allocation.
These are single-run diagnostics, not p50/p95, battery/thermal measurements,
Galaxy A52 predictions or multilingual quality. The cold load reinforces the
requirement to keep inference off startup/capture. Logs are available through
`CyaEmbeddingProbe` logcat; model/build artifacts remain ignored locally.

### Minified release defect, correction and application offline smoke

Release initialization alone was insufficient: first embedding aborted natively
with `ClassNotFoundException: com.google.ai.edge.litertlm.InputData$Text`.
The JNI implementation resolves wrapper types by names that R8 had changed.
Keeping `com.google.ai.edge.litertlm.**` classes/members fixes that tested path;
application shrinking remains enabled. The SDK wrapper JAR is191,250bytes
before packaging, so a package-scoped keep is preferable to speculative lists
of reflection/JNI entry points. Final APK impact still requires measurement.

The [official Android compatibility table](https://developer.android.com/build/kotlin-support)
requires R8≥9.1.29 for Kotlin2.4. That exact minimum was not found in Google
Maven; the published9.1.56 patch resolved successfully. With that build-tool-only
override and JNI rules, the minified probe build passed in1m45s without the prior
metadata warnings, and actual text **and raw audio** inference succeeded.
Release single-run measurements: init9010ms, firsttext10159ms, nextquery2065ms,
1secondaudio13350ms; final PSS410,831KiB. Variable emulator/host load makes these
unsuitable for release-vs-debug speed comparisons. Finite256d vectors and the
same audio norm/cosine confirm the corrected release path executes.

Integrated Cya!'s native bridge and actual Dart job/index/query service, then
built the developer-only `tool/local_semantic_smoke.dart` entry point. Its sources
are synthetic and the database is an isolated in-memory fixture; personal rows
were not read or modified by the diagnostic. The model was explicitly copied to
the app with ADB after its hash was verified; this does **not** validate the SAF
installation UI. Existing encrypted file upgrade/native capture were tested
separately.

Actual airplane-mode test: emulator setting1, Wi-Fi disabled, active default
network **none**. App smoke reported passed:2 text memories indexed in21,273ms
(includes cold load and worker scheduling), query606ms ranked its expected
synthetic book note first; raw audio returned256d without transcript, audio/query
cosine0.74666; model-disabled capture and keyword fallback succeeded. One positive
text ranking and one tone are functional coverage, not multilingual/retrieval
quality acceptance. Prior radio settings0/1/1 (airplane/Wi-Fi/mobile data) restored
afterward. Exact synthetic report retained in `.buildlog/semantic-airplane-smoke.log`.
