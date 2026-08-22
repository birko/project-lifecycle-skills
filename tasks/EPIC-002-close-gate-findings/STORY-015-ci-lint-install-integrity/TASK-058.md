---
id: TASK-058
parent: STORY-015
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-053-7]
pr: null
github-issue: null
jira-key: null
---

# STORY-015's theme ranks the repo's only gate last

## Context

**Found by `/code-review` at TASK-053's close gate.** This story — the one this task sits under — carries
`theme: docs-i18n-coverage`. Its four tasks are TASK-029, TASK-037, TASK-043 and TASK-045, and every one
of them is a **correctness defect in `skills-lint.sh`**, the repo's only automated gate. TASK-045 is
*"a flag one skill passes is never checked to exist in the receiving verb"*; TASK-043 is the wikilink
contract's enforcement boundary. None of that is documentation or i18n coverage.

**Why the wrong label has teeth.** `docs-i18n-coverage` is rung 7 — the bottom of `intake`'s subject
ladder — and [[fix-next]] reads `theme:` as tie-break **key 6**. So the field ranks this repo's
gate defects *below every other EPIC-002 story*, all of which carry `correctness-invariants`. TASK-044
added `theme:` specifically so the ranking would stop being inferred from titles and become reproducible;
here it is reproducibly wrong, which is the failure mode a declared field trades for — an inference that
guesses right sometimes is replaced by a declaration that is confidently wrong until someone corrects it.

**This is a re-classification, not a typo fix, which is why it gets an id rather than a quiet edit.**
Changing a ranking key changes what `/fix-next` picks next, so it deserves to be visible and reviewable
rather than folded into an unrelated close. Read `intake`'s ladder before writing the new value —
`correctness-invariants` is the obvious candidate and almost certainly right, but the ladder is the
authority and it may have a rung that fits gate-infrastructure defects better.

**Check the sibling stories while here.** If one label drifted from its contents, the others are worth a
glance — but only a glance: re-theming a story whose label is defensible is churn, and disagreement about
a borderline rung is not a defect.

## Acceptance criteria

- [ ] STORY-015's `theme:` names a rung that matches what its four tasks actually are, chosen against `intake`'s ladder rather than by analogy to the other stories
- [ ] The reason is recorded on this task — which rung, and why the tasks fit it — so the next reader does not re-derive it
- [ ] Every other EPIC-002 story's `theme:` is checked against its tasks; each is either left alone or corrected, and the sweep's outcome is stated either way
- [ ] `/fix-next`'s ranking is re-read (not re-implemented) to confirm the new value orders these tasks the way the change intends

## Out of scope

- Changing `intake`'s ladder, or `fix-next`'s key order. If the ladder has no rung that fits gate-infrastructure defects, that is a finding to spawn, not to fix here.
- The four tasks themselves — TASK-029, TASK-043, TASK-045 stay `todo` and are unaffected by their story's label.
- TASK-044, which added the field and is `done`. This is a data correction to one story, not a defect in that work.

## Human test plan

N/A — fully covered by reading `intake`'s ladder against the four task titles, plus re-reading
`fix-next`'s key 6. There is no runtime: the "test" is that a human agrees the rung matches the contents,
which is the acceptance criteria restated, and running `/fix-next` to watch the order change would
confirm the field is read — never that the value is right.

## Implementation plan

_Populated by `/tasks plan TASK-058` — leave empty until then._
