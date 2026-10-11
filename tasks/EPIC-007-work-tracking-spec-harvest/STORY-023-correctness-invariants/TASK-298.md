---
id: TASK-298
parent: STORY-023
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
findings: [FIELD-009]
pr: null
github-issue: null
jira-key: null
---

# A `/fix-next` run that cancels or blocks its task on a task branch has nowhere to commit the record

## Context

Found while doing TASK-228 (2026-10-11). `skills/fix-next/SKILL.md` steps 3 and 4 end a run without a fix: a
rejected finding is cancelled through `/tasks cancel`, and a defect whose fix belongs upstream is blocked through
`/tasks block`. Neither verb commits what it writes (`skills/tasks/verbs/cancel.md`, `block.md`). TASK-228 makes
the run commit that record on the default branch when the task file is there (an in-place pick with no task
branch). When step 2 cut a task branch (`pr-per-task`, or `workspace: worktree`), the record lands on that
branch, which no fix will ever merge:

- a cancel committed there leaves the default branch's copy reading `todo`, so the next run ranks the rejected
  finding again, unless the branch's existence keeps it out of the pool as **taken**, which then hides it for good;
- a block committed there is the state step 0 reads through `git show task/TASK-NNN:<file>`, which may be the
  intended shape, but nothing says so.

TASK-228 leaves those files uncommitted and has the run name them and stop, even under `--loop`.

## Acceptance criteria

- [ ] `fix-next` states, for a run that cancels or blocks its task after step 2 cut a task branch, where the
      record is committed and how the default branch learns the task is no longer `todo`
- [ ] The answer agrees with [[tasks]] `cancel` and `block` and with the taken signal in § *Collection pass*
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The in-place case — TASK-228

## Human test plan

- [ ] On a `pr-per-task` fixture whose top pool task is a false positive, run `/fix-next` twice in fresh sessions.
      Expected: both end with the task `cancelled` on the default branch, a clean tree, and a later run that does
      not rank it again

## Implementation plan

_Populated by `/tasks plan TASK-298` — leave empty until then._
