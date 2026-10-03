---
id: TASK-214
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
findings: [VI-003]
pr: null
github-issue: null
jira-key: null
---

# `/tasks close` finishes a blocked task, against FEATURE-003 D7

## Context

Found by `/feature review FEATURE-003` (2026-10-03), Gate A's feature-level fidelity pass. D7 says a blocked
task cannot be started **or finished** while it carries the flag. The start half is built: `pick` asks
"Unblock and start?", and `fix-next` refuses to resume a blocked run. The finish half is not.
`skills/tasks/verbs/close.md` step 4 checks for `done` and `cancelled` only, so `/tasks close` on a task
carrying `blocked:` goes on to write `status: done` with the field still present — the contradiction `audit`
reports (`skills/tasks/SKILL.md` § *Reading a task's status*). No task's criteria covered this half;
TASK-204's D7 criterion named only `pick`.

`close`'s own deferred-merge path *writes* `blocked: merge deferred: …` and re-closes after `/tasks unblock`.
That re-close starts from an unblocked task, so a refusal does not break it.

## Acceptance criteria

- [ ] `close` step 4 refuses a task blocked in either form, with its exact question (unblock and close, or
      stop) and an answer-less path — `--unattended` included — that refuses and reports, never closes
- [ ] The `--unattended` contract table gains the row for it
- [ ] The deferred-merge re-close path still works, shown by walking it in the progress log
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The wording sweep — TASK-213

## Human test plan

- [ ] A cold run of `/tasks close` on an invented blocked task with nobody to answer: it refuses, says why,
      and writes nothing

## Implementation plan

_Populated by `/tasks plan TASK-214` — leave empty until then._
