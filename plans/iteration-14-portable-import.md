# Iteration 14 — validated local backup import

Implements approved Phase1 portable export/import. Depends on version4 export
and managed originals from Iteration13. No source schema change required.

Select JSON or ZIP explicitly through Android's local document picker. Stage
privately with entry/count/size limits; reject unknown versions, traversal,
duplicate entries, missing/extra attachments, invalid records/references and
checksum mismatch before changing the store. Preview counts and preservation
policy. Import appends copies with fresh IDs, retains original history/timestamps,
remaps references, queues embeddings after commit and reschedules promises.
Never overwrite current rows, device settings, PIN, model settings or original
files. Prevent accidental repeat import using a manifest fingerprint committed
with rows. Deletion of originals remains an explicit user action.

Acceptance: round-trip text/audio and promise events, corrupt input rejection
without partial DB changes, transaction rollback, attachment integrity, interrupted
staging cleanup/retry, no overwrite, repeat import protection and offline operation.
No inferred success from opening the picker/share chooser. File-system changes
precede the single source/event/job transaction; a failed commit cleans only the
newly allocated import files. Crash leftovers are recoverable local recordings.
