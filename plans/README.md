# Plans

Persistent, written plans for building Cya!, one Markdown file per unit of work. Every plan
derives from [../docs/Cya_Master_PRD_and_Development_Bible.md](../docs/Cya_Master_PRD_and_Development_Bible.md)
(the bible) and follows the cycle: **Requirement Analysis → Planning → Execution → Testing → Feedback**.

## Conventions
- One file per phase/feature, e.g. `phase-0-foundation.md`, named for the work it covers.
- Each plan states: the PRD sections it implements, the approach, and the **acceptance criteria**
  (from PRD §10 and Appendix B) that must pass before the next phase begins.
- Execution and testing feedback goes in [BUILD_LOG.md](BUILD_LOG.md); durable lessons and
  decisions also go into the PRD living log (§13).
- Do not start a phase until the previous phase's acceptance criteria pass and PRD §13.1 is updated.

## Suggested plan template
```
# <Plan title>
- Implements PRD: §<sections>
- Depends on: <prior plans>

## Requirement analysis
## Approach / design
## Steps
## Acceptance criteria   (must pass — from PRD §10 / Appendix B)
## Risks & mitigations
```
