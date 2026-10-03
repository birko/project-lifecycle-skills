---
id: TASK-227
parent: STORY-023
feature: null
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
findings: [SH-24]
pr: null
github-issue: null
jira-key: null
---

# `fix-next` step 8 writes a log line after `close` has committed, so the run never ends clean

## Context

Found by the defect-draining spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-24.** `skills/fix-next/SKILL.md` step 8 hands the task to `/tasks close --unattended`, which commits the
  work and the task file, and then asks for the log line `- step 8 — closed <status>; <sha>`. The sha exists only
  after `close` has committed, so the line can only be written afterwards, which leaves the task file modified.
  § *Verify the reset really is safe* then requires `git status --short` to be clean in every repo touched, so the
  skill's own contract fails on every run that follows step 8 as written. Under `workspace: worktree` it is worse:
  `close` step 8 removes the task's worktree after merging, so the copy of the file the line should go into may no
  longer be where the run is.

Every other step's log line is written before the commit that carries it. Step 8's is the one that cannot be.

## Acceptance criteria

- [ ] Step 8 says where its closing record goes so that, after it, `git status --short` is clean — for example
      written before `close` runs with the sha left to the commit history, or carried in a commit `close` makes
- [ ] The answer holds in `single-branch`, PR-per-task and `workspace: worktree` projects, and step 8 says which
      copy of the task file it writes in each
- [ ] Step 0's resume can still tell that step 8 completed
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `close`'s own commit composition (`skills/tasks/verbs/close.md`). If the chosen fix needs a change there, spawn it

## Human test plan

- [ ] Drill: run `/fix-next` to completion on an invented `single-branch` fixture with one filed defect, then run
      `git status --short`. It is empty, and the task file alone says the task closed

## Implementation plan

_Populated by `/tasks plan TASK-227` — leave empty until then._
