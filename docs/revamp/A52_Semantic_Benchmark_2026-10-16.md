# Cya! required local semantic memory: A52 speech probe

16 October2026. This is real on-device inference over public human speech,
**not** a replacement for the larger held-out product acceptance protocol.
No private source was read or uploaded. Runtime remains a required capability.

## Exact setup

Samsung Galaxy A52 4G SM-A525F, Android14/API34,8GB (MemTotal7,668,936KiB).
Isolated minified `dev.cya.embeddingprobe`, LiteRT-LM0.18.0, exact
484,622,336-byte embeddinggemma-2-740m.litertlm with SHA256
e7a8a2204b91e0f96e92960e84a09a89212e1633dcb7575a9bf3378b4df77f4c.
CPU2threads for text/audio, float32 activations, vision disabled,256d normalized.
R8 JNI keep rule retained. No GPU/NPU performance is claimed.

20 public Google FLEURS validation clips:10en_us and10bn_in,204.86seconds total,
4.14–18.96s each. Pinned dataset revision
70bb2e84b976b7e960aa89f1c648e09c59f894dd. Google/contributors,
[dataset card, CC-BY4.0](https://huggingface.co/datasets/google/fleurs).
Float32 audio converted deterministically to mono16k PCM16 WAV. The preparation
script caps at20s, but none of these clips exceeded that cap. Original/converted
SHA256 and sentence IDs retained in local samples.json. Sources came from archive
order, not a randomized or speaker-balanced personal-memory corpus.

Each audio encoder call received **WAV bytes only**. Reference transcripts served
as20 native-language queries and separate reference text documents, never as an
audio caption, input, ASR product or metadata embedding. Additional queries:
20 independently authored Banglish paraphrases,10 Bangla→English and10
English→Bangla paraphrases. Same sentence IDs count as relevant across languages.
All queries rank against all20 audio candidates.3 unrelated controls have no
positive label. Finite256d and unit norm checked for every vector.

## Results

| Query group | Queries | Text→audio Hit@1 / Recall@5 / MRR | Text→text Hit@1 / Recall@5 / MRR |
|---|---:|---|---|
| English native reference | 10 | 1.00 /1.00 /1.00 | 1.00 /1.00 /1.00 |
| Bangla native reference | 10 | 1.00 /1.00 /1.00 | 1.00 /1.00 /1.00 |
| Banglish text paraphrases | 20 | 1.00 /1.00 /1.00 | 1.00 /1.00 /1.00 |
| Bangla→English paraphrases | 10 | 1.00 /1.00 /1.00 | 1.00 /1.00 /1.00 |
| English→Bangla paraphrases | 10 | 1.00 /1.00 /1.00 | 1.00 /1.00 /1.00 |

Audio→matching reference-text alignment:20/20 first. This verifies shared-space
alignment, **not** graded related-memory suggestion precision or relationship truth.
The three unrelated controls still produce nearest neighbors (e.g. one cosine
0.5691). No no-match threshold is certified; similarity remains a suggestion.

- Engine initialization1424ms in a new process; OS model-file caches were warm
  from prior tests. This is not a cold-filesystem benchmark. Earlier initial
  A52 probe2855ms; do not select one as universal startup performance.
- Raw-audio calls p502653ms, p955649ms for variable4.14–18.96s inputs.
  Warm text-query embedding p50342ms, p95377ms. Percentile rule is the sorted
  floor-index `(n-1)*p`; includes no app DB/index ranking/UI overhead.
- Corpus encode/query/alignment elapsed97,561ms; monitor100.44s including polling.
  Model full-load/source hashing costs in production differ from this probe.
- In-process observed PSS maximum540,903KiB. Independent27 ADB samples, roughly
  every3–4s, maximum541,311KiB (528.6MiB). This is a **sampled maximum**, not proof
  that sub-sample peaks were absent. Production app previously observed673,766KiB
  after indexing because Flutter/DB/UI also consume memory.
- Android thermal status remained0 in sampled readings. Battery sensor32.5–33.2°C,
  before32.8°C/after33.1°C. USB powered/charging,16% displayed throughout. These
 100seconds do not certify sustained thermals or unplugged battery drain.
- Airplane mode with WiFi/data disabled, settled `Active default network: none`
  before inference. Original airplane0/WiFi1/mobile1/Bluetooth1 restored and verified.

## Scope and next gates

This removes the previous synthetic-tone-only speech evidence limitation for the
exact artifact/runtime path. It does not establish broad Banglish-speech quality:
the Banglish inputs here are authored **text queries** over English/Bangla speech.
Read Wikipedia sentences and a20-candidate set are easier than colloquial noisy
personal memories, spelling variation, negation, names or a1000-source index.
The earlier30-document seed remains Banglish Hit@1=6/10; do not discard that
counterexample because this smaller-topic-separation fixture performs well.

Keep required acceptance: held-out300 queries/1000 sources, spontaneous
Banglish speech, independent graded relatedness,10k/50k index responsiveness,
long clips/interruption and sustained unplugged energy/thermal work. No measured
budget failure presently requires model substitution. Supported encoder loading,
lazy initialization, quantization/runtime alternatives remain explicit optimization
decisions if later measurements fail. Offline ASR is a separate P1 experiment;
this benchmark performs no transcription. Image/video retain the shared-space plan.

Reproducible probe logic, public fixture preparation and authored queries:
`tool/benchmarks/`. Exact run logs and27 samples are local ignored artifacts:
`.buildlog/a52-public-speech.log`, `a52-public-speech-report.json`.
