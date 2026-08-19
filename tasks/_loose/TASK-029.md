---
id: TASK-029
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P3
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

# The lint's own coverage grew 16 to 25 cases with nothing recording what the nine pin

## Context

Noticed while closing TASK-026 (2026-08-19). `AGENTS.md` § Testing said
`.github/workflows/skills-lint-test.sh` carries **16 cases**; it now runs **25**. TASK-026 corrected
the number because it was already editing the file, and deliberately did no more.

The stale number matters more here than a typo would, because of what the guide says next: the lint
is *the repo's only gate*, so "a silent regression in it disables checking entirely with no signal",
and *a change to `skills-lint.sh` is not done until a case here fails without it*. The case count is
what a reviewer uses to check that rule was honoured. A count that lags turns the check into a
formality — and nobody can now say from the records whether the nine new cases arrived with the lint
changes that needed them.

## Acceptance criteria

- [ ] Each of the 25 cases maps to the lint behaviour it pins, and the nine added since the count was written are identified
- [ ] Any lint behaviour with **no** case is either given one or recorded as deliberately unpinned, with the reason
- [ ] Whether the guide should carry a raw count at all is decided explicitly — a number that must be hand-synced drifts again next week, so prefer a pointer or have the count come from the script
- [ ] `skills-lint-test.sh` still passes and still runs before the lint in CI

## Out of scope

- Rewriting the lint itself. This is about its test coverage and how the guide describes it.
- Adding new lint rules; a gap found here becomes its own task.

## Human test plan

- [ ] Break one lint rule at a time and confirm a named case fails for each — the mapping is only real if it is exercised
- [ ] Confirm a fresh reader can get the true case count from the guide without running the script

## Implementation plan

_Populated by `/tasks plan TASK-029` — leave empty until then._
