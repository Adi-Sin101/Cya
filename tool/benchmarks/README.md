# Raw speech retrieval probe

Developer-only source for an **isolated** Android test application
`dev.cya.embeddingprobe`; never replace Cya!'s production entry point or read its
database. This helper is not a user feature or a replacement semantic engine.

- Exact pinned model and SDK/configuration: see
  `docs/revamp/EmbeddingGemma2_Android_Compatibility.md`.
- `python tool/benchmarks/fetch_public_speech.py` prepares10 English and10 Bangla
  validation clips from Google FLEURS, pinned to
  70bb2e84b976b7e960aa89f1c648e09c59f894dd. Google/contributors,
  [dataset card and CC-BY4.0 attribution](https://huggingface.co/datasets/google/fleurs).
  Streaming extraction reads only bounded members and uses no archive paths for
  output. Converts float32/PCM16 mono16k WAV to PCM16 and caps at20s, recording
  source/converted hashes and sentence IDs under ignored `.buildlog/speech-corpus`.
- Copy samples.json/WAV files into an isolated probe's `assets/speech` directory.
  Build queries.json as20 entries `{source:index,group:language+'_native',
  query:raw_transcription}` followed by `speech_queries.json` (independent
  paraphrases/Banglish and unrelated controls). Source index refers to samples.json.
- Compile `RawSpeechBenchmark.kt` into that probe and call
  `RawSpeechBenchmark.run(initializedEngine,assets)` on its background thread.
  Minify with the same LiteRT-LM JNI keep rule; no INTERNET permission. Explicitly
  install the exact verified model locally, then run in settled airplane mode.
- Read logcat tag CyaSpeechBench. RESULT reports per-group audio/text rank metrics,
  warm query/audio distributions, total duration and observed PSS maximum. Sample
  process RAM/thermal status independently throughout; observed PSS is not a proof
  of absolute peak or portable battery usage.

Audio vectors receive only WAV bytes. Transcripts are query/reference labels,
never audio captions/index input. Audio-to-reference-text alignment is reported
separately from user-labeled related-memory quality. Relevance groups same sentence
IDs across languages. Three unrelated controls report scores, not a certified
rejection threshold. These20 read Wikipedia sentences and authored Banglish text
queries do **not** cover spontaneous Banglish speech, noisy personal recordings,
long-corpus ranking or held-out relatedness. Use the larger mandatory evaluation
in the model feasibility report before claiming release-quality acceptance.
