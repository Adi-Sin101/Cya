# Iteration 5 — The Memory Garden, achievements, and the weekly digest

- Implements PRD: §6.6 (gamification), §8.2 (Garden + Achievements screens), §8.3 (motion, Rive,
  reduced motion), §5.6 (weekly digest), §9.1 (beauty and performance, co-equal), §10 Phase 1
- Depends on: `iteration-2-drift-data-foundation.md` (projections),
  `iteration-4-reminders-escalation.md` (the digest is the third escalation rung)

## Requirement analysis

Two of the bottom-nav tabs are still placeholders, and the PRD is explicit that the Memory Garden is
"the emotional core of retention" — the reward half of a product whose other half is a nag. The
mechanics already exist: XP, levels, week stats and growth counts are projections over the event log
(ADR-002). What is missing is everything the user actually *sees*.

Also missing is the digest — which iteration 4 deliberately left as a hole: escalation's third rung
sends a promise "to the digest", and right now that means nowhere.

This iteration is where §9.1 gets tested for real: the app must become lush without dropping frames.

## Approach / design

### Memory Garden (full screen)
A plant per resolved promise, grown from the event log — so the garden is a *view* of the same
truth as the stats, never a second bookkeeping system.

- **Layout:** a scrollable scene of plant clusters, one cluster per week, newest at the bottom
  ("this week" always in view). Each resolved promise contributes a plant whose species is derived
  deterministically from the intention id (stable across rebuilds — a plant never changes identity)
  and whose growth stage comes from how long ago it was resolved.
- **Rendering:** `CustomPainter` over a `RepaintBoundary` for the static scene; Rive only for the
  moments that deserve it (a new growth appearing, a level-up). Painting hundreds of plants as
  widgets would be the obvious way to drop frames.
- **Streak:** consecutive days with at least one resolution — another pure projection.
- **Empty state:** a patch of soil and one honest line. A garden that starts empty is the point.

### Achievements
Badges with locked/unlocked states (PRD §8.2 names them: *First Step*, *Never Lost*, *Reader*,
*Communicator*, *Future You*, *Legend*). Each is a **predicate over event counts**, evaluated by a
pure `AchievementProjection` — no stored flags, no "unlocked_at" column to get out of step.

Unlock detection for the *celebration* is a diff: compare the set of unlocked achievements before
and after a resolution. Which achievements are unlocked is always recomputable; only "have we
congratulated the user for this one yet" is stored (a small `preferences` entry), because a
celebration is a UI event, not a fact about the promises.

### Reward moments (PRD §8.3)
Resolution, level-up, new growth, achievement unlock. Each gets a Rive animation with the mascot,
plus haptics. **Respect reduced motion**: `MediaQuery.disableAnimations` selects a calm variant —
a still frame and a line of copy, never nothing.

### Weekly digest (PRD §5.6)
A Sunday-evening notification summarising open promises — "a review moment, not a guilt list". Same
native scheduler, a repeating weekly alarm, its own notification channel. Tapping it opens a digest
screen: what is still open, what was resolved this week, and one-tap resolution on every row.
Promises past the snooze limit live here — this is where escalation's third rung finally lands.

## Steps
1. `domain/projections/garden_projection.dart` — plants, clusters, streak (pure, tested).
2. `domain/projections/achievement_projection.dart` — the badge predicates (pure, tested).
3. Garden screen: painter-based scene, streak header, empty state.
4. Achievements screen + the Profile entry point that currently says "Coming soon".
5. Reward moments: Rive assets, a `RewardOverlay`, reduced-motion variants.
6. Weekly digest: native repeating alarm + channel + digest screen.
7. Frame profiling on the Garden and Home (PRD §9.1: sustained dropped frames are bugs).
8. Update PRD §13.1/§13.3/§13.5 + BUILD_LOG.

## Acceptance criteria (PRD §10 Phase 1)
- [ ] The Garden renders from the event log alone and grows when a promise is resolved.
- [ ] Achievements show locked/unlocked states, all derived — deleting a derived value and
      recomputing gives the same answer.
- [ ] A resolution produces a reward moment; reduced motion gets a calm variant, not a missing one.
- [ ] The weekly digest fires, lists open promises, and resolves them in one tap.
- [ ] 60fps on the Garden with a realistic number of plants; no sustained dropped frames.
- [ ] `flutter analyze` 0 · tests green · golden tests for Garden and Achievements in both themes.

## Risks & mitigations
| Risk | Mitigation |
|---|---|
| The garden becomes a widget tree that repaints per frame | One `CustomPainter` scene inside a `RepaintBoundary`; Rive only for discrete reward moments. |
| Gamification drifts into a second source of truth | Everything is a projection; the only stored UI state is "already celebrated". |
| Reward animations delay the action they celebrate | The write lands first; the animation plays over an already-updated UI. |
| The digest reads as a guilt list | Lead with what was resolved; one-tap actions on everything; never a red badge count. |
