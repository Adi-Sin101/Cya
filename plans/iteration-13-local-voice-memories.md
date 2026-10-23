# Iteration 13 — local original voice memories

15 October 2026. Planned under the approved phased implementation.
Depends on tested typed memories and the exact EmbeddingGemma2 text/raw-audio
proof and app integration. No Android SpeechRecognizer/remote ASR is used.

Implement native foreground PCM16 mono16kHz WAV recording/playback, app-private
managed files, safe interruption recovery and permission/storage feedback.
Recording originals are independent of optional transcripts. A coordinated
additive schema adds attachment metadata and durable file cleanup. Capture
acknowledges only after file finalization and source/revision/event/job commit.
Embedding jobs consume bounded raw-WAV segments, never titles/transcripts in
place of audio. User can listen and browse with the model disabled.

Storage decision must be explicit before coding: existing validated SQLCipher
protection covers SQLite, not audio attachments or shared archives. Initial WAV
attachments are app-private files, with clear UI disclosure that they are not
encrypted at rest. Do not claim otherwise. This adds no transmission path or
external-storage permission. A later attachment-encryption change must preserve
originals and receive recovery/security validation; no speculative cipher format.

Tests: WAV headers/segment integrity; staging/process-death recovery; blank/denied
microphone and low-storage errors; source/event/job atomicity; audio jobs call
the actual audio encoder independent of labels; delete removes vectors/owned
files through retryable cleanup; export includes original attachments and integrity
metadata without silently omitting audio. Export/import must be versioned and
validate paths/checksums/records, with no silent overwrite. Full analyzer/tests,
Android release build, airplane-mode workflow and named device measurement.

## Outcomes (2026-10-16)

Original audio capture/recovery/playback, schema5 attachments/durable cleanup,
raw-audio async segments and format4 complete ZIP export delivered. Full225 Flutter
and five native tests pass, debug builds and actual airplane audio-memory
index/text-query/checksum/delete smoke pass. Details/limits in BUILD_LOG.
Spoken multilingual quality, phone/microphone acceptance and final release
remain open. Validated portable import continues in Iteration14; Phase1 incomplete.
