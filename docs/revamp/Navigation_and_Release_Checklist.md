# Cya! navigation and release checklist

16 October 2026. Iteration 20 / Master ADR-029. This is the current navigation
contract, superseding the earlier five-tab composition. Existing product visions
and historical decisions remain recorded in the Master PRD.

## Reachable product paths

| Capability | Actual UI path | Implementation and verification |
|---|---|---|
| Voice journal | Home → Record voice; Memories → Record voice; corner + → Record voice; Focus → Record a voice thought | Explicit start only; original native recorder, stop/save/review/play, recovery and discard confirmation. Mocked native-channel UI tests prove save/event/attachment/job and playback; hardware interruption acceptance remains open. |
| Typed memory | Home / Memories / corner + → Write a thought; Focus → Save a thought | Full-screen editor; original text preserved, unsaved-draft confirmation, transactional save, post-save focus reminder. |
| Saved originals | Memories → All memories / Voice / Written → journal card | Actual dates, stored audio duration, original playback and stop control; no invented amplitude or work metrics. |
| History and editing | Memory card → tap or Memory actions → History / Edit | Immutable versions retained. Audio edits caption text, not original WAV. |
| Branch | Memory card → Branch; preserved version → Branch from selection | Separate source-linked memory; source unchanged, tested from real CyaApp navigation. |
| Connections | Memory card → Connections → accepted-link map / complete list | Map shows at most six accepted immediate links, with accessible node labels. Full list retains relation kind and user/model provenance. Suggestions remain separate, reviewable and never auto-merged. |
| Organization | Memories → Topics and projects → Create / existing collection | Optional project/topic hierarchy; source-version links. Main-tab navigation test creates a topic. |
| Keyword and semantic retrieval | Memories → search → Keyword / Semantic | Keyword stays usable without model. Semantic searches original text/audio embeddings; no ASR required. Voice/Written filters apply to results. |
| Model/index management | Memories → chip icon (Local semantic model); Profile → Local semantic memory | Explicit local-file install, status, resume/pause/unload/rebuild. No downloader. |
| Promise capture | corner + → Capture a promise; original native share/tile/widget | Existing reminder/save path retained; no model or Flutter engine added to native capture. |
| Promise follow-through | Promises; Home → today's promise | Existing detail, Done/Snooze/archive/source/category/search behavior retained. |
| Routine/focus/recovery/review | Rhythm → day/routine/focus; day menus → library/recovery/history/review | Existing graphical Rhythm and durable focus clock retained; timer passage never marks work complete. |
| Garden | Home → Garden / week landscape; Profile → Memory Garden | Existing animated scene retained on a full-screen route with back navigation. |
| Profile and data | Profile → app lock / appearance / progress / export / import / local storage | Current controls retained; model entry added. Import preview uses actual record counts, storage uses actual counts and readable byte units. |

## What changed underneath

No schema, dependencies, network permission, native capture or model artifact
change. Shared schema 8 and portable format 8 remain unchanged. Saving through
Home/global capture/Focus now wakes the lazy semantic worker after source commit;
it no longer depends on first visiting Memories. Lifecycle pause/resume follows
the worker wherever it was created. No microphone or inference starts merely
because a capture chooser/recorder is opened. The user still controls semantic
enablement and model-file installation.

Delayed entrance animation timers are cancelled on disposal. This fixes a real
short-screen scroll/unmount cleanup issue exposed by the new navigation tests.
Material surface-container colors now explicitly use Cya!'s existing sage/slate
palette across new screens rather than falling back to framework default colors.

## Evidence and completion boundary

The Flutter workflow tests use in-memory data, a mocked native voice channel and
test embedding vectors to verify ordering/navigation/error recovery. They do not
prove physical microphone quality, real-model latency or recognition accuracy.
The actual-model A52 evidence remains in
[the semantic benchmark](A52_Semantic_Benchmark_2026-10-16.md).

The approved P0 text/audio memory and connection behavior is implemented and
receives additional navigation coverage here. It is not honest to mark all
release phases accepted while these gates remain:

- A52 recording, permission revocation, interruption, process death, low storage
  and reboot/rescheduling checks; current phone connection needed for this update.
- Larger held-out multilingual/code-switched retrieval and independently judged
  relatedness quality, with declared corpus/hard negatives and per-language scores.
- Sustained unplugged battery/thermal and larger-index responsiveness measurements.
- Offline transcription and image/video are the approved staged P1 feasibility /
  implementation work, not hidden implemented features. No transcript-generating
  UI or unsupported vision/video path is presented as working.
- Legacy plaintext-to-cipher conversion still requires its separate recovery-safe
  migration decision; this UI unit does not change data encryption or claim that
  original WAVs/exports are encrypted.

Focus-end and routine-window notifications are still absent. Existing promise
notifications work through the native scheduler. This unit does not silently
change preferred routine windows into automatic alarms or add spoken prompts.

Exact commands, artifacts, file inventory and installation state are recorded in
[implementation status](Revamp_Implementation_Status.md) and
[BUILD_LOG](../../plans/BUILD_LOG.md). Synthetic rendered previews are produced by
`tool/journal_visual_preview_test.dart`; they are not private-phone screenshots.


17 October update (ADR-030): Home and Profile now have an illustrated Garden
entrance, backed by actual events and capped at16 painted plants. Profile has
an XP/avatar ring and badge progress panel; all settings retained. Full289 tests
pass. A526014 memory/recorder navigation smoke passed after unlock without mic
activation. See implementation status for6015 build/install and device limits.
