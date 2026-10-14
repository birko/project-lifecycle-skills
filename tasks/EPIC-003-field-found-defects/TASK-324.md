---
id: TASK-324
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
findings: [CR-317-1]
pr: null
github-issue: null
jira-key: null
---

# A re-close that parks a `done` task at `verify` never rolls its parents up

## Context

Found by TASK-317's close review (2026-10-14). [[tasks]] SKILL.md § *Roll status up to parents* lists "reopened by `close`" among the triggers of the reopening direction. The only `close` path that actually takes a task out of `done` is `skills/tasks/verbs/close.md` step 4's interactive "reopen and re-close", when the re-close then parks the task at `verify` in step 5 because a test step did not pass. Neither step says to roll the parents up. So a `done` story stays `done` over a `verify` child, and with an upstream nobody runs the unlanded `record/<ID>` check either.

TASK-317 tried a fix and reverted it. Running the rollup in step 4 writes before step 4b has settled where the close runs. It sits above the `--unattended` refusal. And it is usually undone in the same run, because a re-close that ends `done` makes step 12's "now has an open child" line false. The rollup belongs at the moment the task actually leaves `done`, which is the step-5 park, and it has to respect step 10's table of what may be written where (nothing on the default branch with an upstream).

## Acceptance criteria

- [ ] A re-close that parks a previously `done` task at `verify` runs the reopening direction of SKILL.md § *Roll status up to parents* at the park, where step 10's table allows the write
- [ ] With an upstream it runs the unlanded-record check, and step 12 reports each reopened container and each `record/<ID>` line
- [ ] A re-close that ends `done` reopens nothing and reports no record line
- [ ] `--unattended` behaviour is unchanged (step 4 still refuses a closed record)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `move`, `new`, `spawn`, `decide` (TASK-317) and the chaining verbs (TASK-325)

## Human test plan

- [ ] On a fixture with a `done` story over one `done` task, re-close the task interactively and report a test step as failed. Expected: the task reads `verify`, the story reopens with its dated line, and the confirmation names it.

## Implementation plan

_Populated by `/tasks plan TASK-324` — leave empty until then._
