# Iteration 23: onboarding animation overlap

Date: 24 October 2026. Implements Master PRD sections 8.3, 8.4, 9.1 and
Appendix B; follows iteration 9 onboarding and iteration 22 QA findings.

## Requirement and approach

Reproduce the reported illustration/animation overlap using the real onboarding
pages, app typography and animation frames at compact phone sizes. Keep the
existing visual language, teaching sequence, permission timing and navigation.
Fix sizing and painting boundaries rather than hiding layout failures.

## Acceptance

- Share animation and notification preview remain readable inside their allocated
  illustration area, including intermediate animation frames.
- Headline, body, supporting cards and actions do not collide with illustration
  contents at narrow/short sizes, enlarged text or reduced motion.
- All steps and actions remain reachable through scrolling when necessary.
- Add regressions that fail before the fix; inspect before/after renders.
- Run onboarding tests, full Flutter tests, analyzer and release build where
  possible. Record exact results and device verification limits in BUILD_LOG.
- Commit and push as Adi-Sin101 without coauthor, as explicitly requested.

No data/schema, dependencies, native capture or product-direction changes.

## Execution and feedback

The initial no-overflow/layout-rectangle checks passed despite the visible bug.
The decisive regression measures transformed paint bounds after ancestor clipping
and opacity: the share sheet painted below its phone (for example, text bottom394
versus illustration bottom356 at320x640), and the saved badge escaped above it.
All four size/motion matrix tests failed before the fix. A second red run exposed
the duplicated notification title/actions in the decorative rear card.

The share demo now clips its moving contents to the rounded phone and places the
badge inside it. The rear notification is a silhouette with reserved space rather
than another full notification; the foreground remains readable and unrotated.
No shared scaffold change was needed: sizing/scrolling passed the real-font matrix.

Regression coverage samples six animation times across48 page configurations:
Welcome/Share/Notifications,360x800/320x640, light/dark, text1.0/1.35 and normal/
reduced motion. It also checks that the primary action remains scroll-reachable.
The existing twelve flow tests still cover the full sequence and local identity.

Targeted16/16 pass (9s); analyzer0 (51.7s); full296/296 pass (55s). Normal release
build4017 passes172.7s (ARM646017/x648017); hashes in BUILD_LOG.
Renders are Flutter host captures with actual app fonts, not fresh
emulator/phone screenshots. No fresh device acceptance is claimed.

### Visual evidence

- [Before: share sheet paints below its phone](../docs/qa/evidence/onboarding/share-before.png)
- [After: same entrance frame remains inside the phone](../docs/qa/evidence/onboarding/share-after-entry.png)
- [After: saved frame and surrounding copy](../docs/qa/evidence/onboarding/share-after-saved.png)
- [After: notification group without repeated text/actions](../docs/qa/evidence/onboarding/notification-after.png)
