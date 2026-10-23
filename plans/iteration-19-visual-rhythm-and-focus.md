# Iteration19 — visual Rhythm tab and focus room

16 October2026. Explicit user direction: routine/day/review UI is too textual;
give it a main tab, cohesive visual/animated life overview and proper focus mode.
Design context confirmed from .impeccable.md plus the approved memory/routine
extension. Apply frontend-design and animate skills; keep sage/mint, Plus Jakarta
Sans, warm companion tone, reduced motion and native-thin capture constraints.

## Design and implementation

- Five preserved-state tabs: Home, Promises, Rhythm, Garden, Profile. Keep a
  distinct48px capture action in the navigation bar. An end-floating trial covered
  a promise completion control in regression tests; the bar reserves its space.
  All existing destinations remain, with independent navigator state.
- Rhythm: a selectable seven-day strip, graphical path through actual selected
  routines, compact next-focus invitation and visual routine timeline cards.
  Completed/skipped/deferred are explicit states, not scored productivity. No fake
  time-use chart, inferred work, streak or guilt. Optional routines live in a compact
  picker; advanced recovery/history stays progressively disclosed.
- Dedicated focus room: chosen priority, visual timer, duration choice,
  pause/resume/end and save-first thought capture. Reuse existing focus sessions,
  memory composer and preference store; persist timer projection so process death
  does not reset it. Clock passage never completes routines/promises. No alarm,
  notification surveillance, inference or network dependency.
- Routine library/editor and daily/weekly review use the same visual vocabulary,
  concise copy and charts from recorded actions. Preserve all existing editing,
  manual recovery, optional review notes, history and import behavior.
- One-shot entrance/state transitions and bounded focus-only motion. Respect
  reduced motion, background lifecycle and tab TickerMode. Do not load models for UI.

## Acceptance

Navigation/state retention and original capture tests; timer clock/pause/restart/
stale-session/transaction tests; source/event/job save before focus reminder;
explicit outcomes/recovery/history still work. Light/dark, narrow width, enlarged
text and reduced-motion widget checks; analyzer, full tests, release build and A52
visual inspection. No schema migration or app network permission required.
Record exact checks and screenshots without personal content where possible.

## Validation feedback —16 October2026

Implemented planned visual/tab/focus behavior, plus independent priority entry
without requiring a routine/promise. Timer domain6 tests cover persistence,
pause/resume, stale rooms, rollback, replacement and portable history. Focus UI
covers save-before-reminder and enlarged reduced-motion layout. Routine widgets
cover light/dark narrow layouts, real weekly bars and explicit selection/outcomes.
Main navigation retains original capture/promise/Garden/Profile behavior.

Final full274/274 in82s with concurrency2, analyzer0 in24.3s; focused focus/nav16/16.
Production release ARM64/x64 build414.9s, normal entrypoint, no Internet permission.
Installed6012 in place on A52 with data/model retained. Existing lock reactivated
after APK update; physical screen/timer verification follows the user's unlock.
No extra schema migration or dependency. Format8 excludes active clock projection.
Source groups and artifact digests in the implementation report.

Creator correction during final validation: + must be **centered and hovering**,
not a reserved end-nav action. Restore64px centerFloat above all five tabs. Keep
bottom scroll clearance and verify rows can be scrolled above it; position tests
assert center alignment and separation from nav icons. User instruction resolves
this design choice (ADR-027). Correct day-path marker contrast/vector check.
A526012 focus pause/leave/reopen/resume/end verified, QA session explicitly ended.
Final corrected placement release follows; do not describe earlier6012 as carrying
the final + position.


## 2026-10-16 ? latest creator correction: compact corner +

Latest instruction supersedes the centered hovering decision (ADR-028). Capture
is now a 48px rounded square at bottom-right, solid theme primary/onPrimary,
16px edge inset, softer shadow and smaller28px icon. All five tabs retained.
Press feedback respects reduced motion. Original capture flow unchanged.
Short-viewport test initially reproduced a floating overlap with the promise
checkbox; regression now verifies that scrolling reaches the original control
and completion persists, alongside Profile-row reachability. This is a normal
floating overlay, not a promise-state change. Light/dark synthetic renders inspected.
Final checks/package recorded in the implementation status report. No schema,
model, permissions, dependency or native capture changes.


Final corner package: `flutter build apk --release --no-pub --split-per-abi
--target-platform android-arm64,android-x64 --build-number 4013 -t lib/main.dart`
passed in116.0s. Normal entrypoint; ARM64 version6013,52,393,145bytes;
x64 version8013,58,762,639bytes. Release manifest has no INTERNET or
ACCESS_NETWORK_STATE permission. Current artifact SHA256:

- ARM64: `91e6ebf9e9f22037e6335b0d5c393458df231676e6631864154c86b946188f91`
- x64: `2669850361eb0ac104be567d06db865a70a4dffa6aa2dd32b98f302c095c91a4`

Full274 tests passed71s; analyzer0 issues18.1s; synthetic light/dark preview2/2
passed5s; diff-check0. Earlier centered4013 build was never installed and is now
replaced by the corner artifacts. No app clear/uninstall. Final position checked
in rendered synthetic layouts; no new physical unlock/GUI proof is claimed.

A52 in-place install succeeded (`adb install -r --no-streaming`); package manager
confirms version6013. Existing app data retained; no clear/uninstall performed.
