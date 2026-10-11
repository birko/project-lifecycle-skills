---
id: TASK-295
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-11
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-294-1]
pr: null
github-issue: null
jira-key: null
---

# `/feature review` is read two ways on a `done` task whose `N/A` test plan turns out to be false

## Context

Found while drilling TASK-294's fix (2026-10-11). Two runs of `/feature review FEATURE-002` on the same
single-branch fixture (`%TEMP%\d294`) met the same task: TASK-002 is `done`, and its Human test plan reads
`N/A — fully covered by automated tests`, but the repo has no test at all. Both runners saw that the `N/A`
claim was false and failed Gate B. They then disagreed on the task:

- one moved TASK-002 `done → verify`, citing `skills/feature/verbs/review.md` step 5 ("Park any client tasks
  awaiting sign-off at `status: verify`");
- the other left it `done`, reasoning that a task must not be parked on a test step that was never written
  ([[tasks]] § *Lifecycle*: an absent or unfilled plan is resolved before choosing the status).

`review.md` does not say what Gate B does with a plan whose `N/A` is false, or whether step 5's parking rule
covers a task already `done`. The result is that the same review gives different task statuses on different
runs. This is not TASK-235, which is about Gate A's handling of tasks that are already `verify`.

## Acceptance criteria

- [ ] `review.md` Gate B says what a false `N/A` plan is (a failed step, a not-run step, or something else) and
      what is recorded for it
- [ ] Step 5 says whether parking at `verify` applies to a task that is already `done`, and the rule agrees with
      [[tasks]] § *Lifecycle* on reopening a `done` task
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Whether review commits what it writes — TASK-294

## Human test plan

- [ ] On a fixture with a `done` task whose `N/A` plan names a test that does not exist, run `/feature review`
      twice in fresh sessions. Expected: both runs leave the task in the same status and report the plan the
      same way.

## Implementation plan

_Populated by `/tasks plan TASK-295` — leave empty until then._
