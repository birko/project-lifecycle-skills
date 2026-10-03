---
id: TASK-217
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-142]
pr: null
github-issue: null
jira-key: null
---

# `/tasks migrate` never exports a task awaiting verification

## Context

Found by the correctness pass at TASK-213's close (2026-10-03). `skills/tasks/verbs/migrate.md` step 1 selects
"All TASKS with status ∈ {`todo`, `in-progress`, `blocked`}". That set predates FEATURE-003: `blocked` is no longer
a status (a blocked task keeps its own state and carries a `blocked:` field), and `verify` — or the old `review` —
is not in it at all. So a project moving to hybrid mode silently leaves every task awaiting verification out of
its tracker, and a task blocked in the new form is exported only if its own state happens to be in the set.
FEATURE-003 D4 says readers accept both forms; this reader drops one of them entirely.

## Acceptance criteria

- [ ] `migrate` selects open tasks by state per [[tasks]] § *Reading a task's status* — `todo`, `in-progress`,
      `verify` (and the old `review`), plus an old-form `status: blocked` — independent of whether the task
      carries a `blocked:` field
- [ ] A blocked task in any of those states is exported with its marker, as `export` step 5 already does
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `export`'s own behaviour — already reads both forms

## Human test plan

- [ ] A cold run of `/tasks migrate` against an invented tree, with the tracker calls replaced by a printed plan:
      the plan lists a `verify` task, an old-form `review` task and a blocked `in-progress` task, and no
      `done` or `cancelled` one

## Implementation plan

_Populated by `/tasks plan TASK-217` — leave empty until then._
