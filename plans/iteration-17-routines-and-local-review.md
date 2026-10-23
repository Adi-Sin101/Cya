# Iteration17 — real routines, Today recovery and optional review

16 October2026. Implements newly approved v2 FR10–12 and acceptance17–19.
Read supplied full v2 PRD/prompt (preserved in docs/revamp); delta audit and
ADR024 resolve the earlier narrower Phase1 scope and historical audit starter.
Depends on stabilizing the in-progress schema7 connections change. Retain all
memory/EmbeddingGemma2 and current promise/reminder behavior; no new task engine.

## Approach

Add coordinated schema8 routine definitions with immutable versions/events,
explicitly selected dated occurrences and occurrence events, and optional local
review notes with preserved revisions. Definitions support title, optional
weekdays/window/steps/fallback, pause/resume, reorder, archive/delete. A blank
recurrence is flexible, never mandatory. Today shows eligible available routines
separately from the small set the user actually selects; no automatic occurrence
creation or overload. Snapshot exact version/settings at selection.

Record planned/completed/skipped/deferred by explicit action. Allow shortened
steps and revised window/day with an event, retaining original selected day,
version/context and all prior outcomes. Missed earlier selections remain open
history, never inferred failure. Pause stops suggestions, not history. Deletion
is explicit and confirmed soft removal with restore-paused; all history remains.
Promises and memories remain. Export/import include all versions/events/occurrences/reviews
with fresh identities, validation and no current-plan overwrite.

Today/focus uses existing Home and a concise routine/day-plan destination; keep
the current chosen focus independent and capture-save-first behavior unchanged.
Daily/weekly review is optional: factual local task/routine outcomes, upcoming
commitments, a short user note, and explainable manual adjustment suggestions.
No timer-based completion, surveillance, model productivity score, guilt language,
new alarm engine or autonomous plan changes. Time windows are preferred times,
not a promise of notifications; existing commitment reminders keep working.

## Acceptance

- Create/edit/reorder/pause/resume; optional weekdays/time windows/steps/fallback.
- Select eligible or manually chosen routines for Today, idempotently, without
  auto-adding every recurrence. Day rollover recomputes eligibility but retains
  history. Weekday calculation uses the local selected day, including boundary cases.
- Complete/skip/defer, shorten/move/reprioritize/pause after disruption; event and
  state transaction consistency, original snapshots unchanged after definition edit.
- Optional daily/weekly review summarizes recorded facts only; notes preserve
  revisions and suggestions require explicit navigation/action to adjust plans.
- Native/Drift create/migrate parity, v7 preservation, rollback/future rejection,
  export/import round trip, delete cleanup and no new network permission.
- Widget coverage for Today/recovery/review and existing regressions; analyzer,
  release build, A52 offline smoke and truthful performance/limits logged.

## Execution feedback —16 October2026

Schema8 implements six coordinated routine/review tables; immutable definitions,
explicit selections/outcomes/recovery, reversible removal and factual optional
review notes reuse the Memory store/index. Portable format7 introduces remapped
routine histories and distinct imported-review origin slots; format8 later adds
focus-clock event vocabulary without more DDL. Current review/priority are retained.
12 routine repository tests plus3 initial widgets pass; full260/260 in34s,
analyzer0 in35s, native8/8 in1m42s. Production release223.9s, ARM64
52,326,861bytes/x64 58,696,355bytes, no INTERNET/ACCESS_NETWORK_STATE. A52 upgraded
in place to6011 with no clear/uninstall. Actual UI creates a routine without
auto-selecting Today; explicit selection/completion and daily factual review work
with settled no-network state. All radios restored. Automated review-note save
assertion was inconclusive; do not count it as phone save proof.

The creator then rejected the verbose visual presentation and explicitly approved
a complete cohesive visual replacement with its own tab and proper focus mode.
Continue iteration19; preserve this tested domain/store behavior.
