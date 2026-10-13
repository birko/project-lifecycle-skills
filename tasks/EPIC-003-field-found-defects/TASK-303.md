---
id: TASK-303
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-296-1]
pr: null
github-issue: null
jira-key: null
---

# `/feature review` parks a `done` task at `verify` under a STORY that already reads `done`

## Context

Found by TASK-296's upstream-fixture drill (2026-10-13). `/feature review`'s Gate B parked TASK-001 `done → verify`, because its N/A test plan had no test behind it. TASK-001's STORY-001 had been closed `done` one step earlier. Nothing rolls the change up, so the tree then holds a `done` story with an open child. That is the contradiction `/tasks audit` and the container-close children-done check exist to prevent. `skills/feature/verbs/review.md` step 5 does the park; `skills/tasks/verbs/close.md` § *Closing a STORY / EPIC* owns the container rule.

## Acceptance criteria

- [ ] Parking a task at `verify` from `/feature review` states what happens to a parent STORY or EPIC that reads `done`: reopened, or reported for a person, never left contradicting silently
- [ ] The rule is stated where the park happens and points at the container rule rather than restating it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The upstream record question (TASK-296)

## Human test plan

- [ ] On a fixture where a feature's only task is `done` under a `done` story with an N/A plan that has no test behind it, run `/feature review`. Expected: the story is not left `done` over a `verify` child without a line saying so.

## Implementation plan

_Populated by `/tasks plan TASK-303` — leave empty until then._
