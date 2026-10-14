---
id: TASK-322
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-018]
pr: null
github-issue: null
jira-key: null
---

# A signed-off feature with an unbuilt `changed` decision reads phase `review`, as if built

## Context

Found by TASK-319's post-fix drill (2026-10-14). Since TASK-319, a `changed` decision whose change is not built yet sets `idea.md` `done → review`, leaves the old task `done`, and empties the row's task column so the change gets decomposed. `skills/feature/verbs/status.md` § *Compute the phase* rule 1 then mirrors the stored `review`, and rule 2 would say `review` anyway, since every linked task is `done`. But `review` means built and awaiting sign-off, and the change is not built. Consequences: the rollup tells stakeholders the work awaits sign-off, and `/feature pick` meets gate D (decompose) and gate E (review, "lead with this") at once. The runner resolved that by gate order and said the text reads both ways.

## Acceptance criteria

- [ ] A feature with an `approved`/`changed` row whose task column is empty never derives phase `review`, whatever its stored status or its other tasks
- [ ] `decide.md`'s unbuilt case sets the stored status to whatever makes the phase say the work is not built, and says why
- [ ] `/feature pick` cannot meet gates D and E at once for such a feature
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The built case, which is correctly `review`

## Human test plan

- [ ] On a no-upstream fixture, record a `changed` decision on a `done` feature whose change is not built, then run `/feature status FEATURE-001` and `/feature pick FEATURE-001`. Expected: the phase is not `review`, and pick offers decompose with no competing review offer.

## Implementation plan

_Populated by `/tasks plan TASK-322` — leave empty until then._
