---
id: TASK-028
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# The inference skip rule counts five subsections when one of them is conditional

## Context

Found by `/code-review` on TASK-026's diff (2026-08-19), in a file that diff did not touch.

`skills/adopt-project/INFER.md:91` decides whether to run the convention-inference round by counting
coverage over the five subsections of § *What to read, per subsection*: **all covered → skip**,
**some covered → run a round scoped to the rest** ("four of five covered is a one-subsection round").
But that same section makes **UI / UX** conditional — *only when a human-facing surface exists*,
otherwise *drop the subsection rather than filling it emptily*.

On a headless library the two rules collide. An agent following the arithmetic literally either never
reaches "all covered" — UI / UX cannot be covered, because it does not apply — and runs a pointless
round forever, or runs a one-subsection round proposing UI rules to a repo with no UI, which is
precisely the empty fill the conditional exists to prevent. TASK-017 gave this round its skip
condition; this is that condition meeting a repo shape it does not describe.

## Acceptance criteria

- [ ] The rule counts **applicable** subsections, not five — an inapplicable subsection is neither covered nor outstanding
- [ ] A headless library whose rulebook answers its four applicable subsections **skips** the round, and says which subsection it dropped and why
- [ ] A repo with a human-facing surface is unchanged: UI / UX still counts, and still runs when uncovered
- [ ] The applicability test is stated where the count is made, so the two rules cannot be read separately again
- [ ] Any arithmetic example in the file ("four of five") is restated in terms that survive a dropped subsection
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Whether the five subsections are the right five. This task only fixes the count.
- The layer's other conditional artifacts (CI's `missing, not offered`), which carry their own adjudication already.

## Human test plan

- [ ] Run `/adopt-project` step 2 against a headless library whose guide answers framework, structure, naming and testing — confirm it skips and names the dropped subsection
- [ ] Run it against a repo with a UI whose guide has no UI rules — confirm UI / UX is still proposed
- [ ] Run it against a repo with a UI and a complete rulebook — confirm the skip still fires

## Implementation plan

_Populated by `/tasks plan TASK-028` — leave empty until then._
