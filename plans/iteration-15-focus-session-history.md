# Iteration 15 — user-selected focus session history

Approved Phase1 requires a chosen current priority and save-first respectful
return prompts. Replace the preference-only shortcut with durable local sessions
and an append-only start/end event record, preserving prior priorities. Keep the
existing preference as a compatible projection for fast UI reads; switching ends
the old session and starts the next in one transaction. No autonomous priority,
timed alarms, app blocking or surveillance. Add history browsing and optional
explicit duration later only with a user decision; sessions currently end on
explicit switch/end rather than silently expiring.

Add schema6 focus_sessions/focus_events in both runtimes; native capture only
creates the tables during migration, never reads them or initializes models.
Export/import all focus history in format5; import ends imported active sessions
at import time with an explicit event, leaving the current local session intact.
Acceptance: switch/end/event atomicity, old priorities preserved, no focus prompt
before failed/durable capture, exact Dart/Kotlin migration parity and existing
promise/audio/semantic tests pass. No phase-completion claim while required
device and multilingual retrieval acceptance remains unresolved.

## Outcomes (2026-10-16)

Schema6 session/event history, legacy priority observation, UI history and format5
portable import/export implemented. Full236 Flutter tests and current subset18
pass, including native/Dart-first v4/v5 fixtures and failure rollback. BUILD_LOG
records exact results. Production release/device checks continue; phone now
available. No battery/thermal/quality completion claim until measured.
