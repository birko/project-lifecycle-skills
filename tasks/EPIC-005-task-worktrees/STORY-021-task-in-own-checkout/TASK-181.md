---
id: TASK-181
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: ai
created: 2026-09-24
depends-on: [TASK-175, TASK-176]
blocks: [TASK-179]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Resuming a task re-enters the worktree that holds its branch

## Context

FEATURE-001 D16, found while planning TASK-174/175. A new session always starts in the main copy, but
under `workspace: worktree` the task's branch `task/TASK-NNN` is checked out in its worktree, and git
refuses to check it out a second time in the main copy. So any path that resumes an in-progress task
from a new session has nowhere correct to work:
- [[fix-next]] step 0, which exists to resume an interrupted drain and is built to "stop where
  resetting the session loses nothing".
- A `/tasks pick` of an already-`in-progress` task.
- A `/tasks close` run from a new session (TASK-176's merge is driven from the worktree).

The evidence is on disk and is recomputed rather than remembered: `git worktree list --porcelain`
names the worktree holding `refs/heads/task/TASK-NNN`. Reading the *task's* worktree this way is not
the inference the config forbids. `workspace:` is still read from the config; this only locates a
branch the verbs themselves created.

## Acceptance criteria

- [ ] Every verb path that resumes an in-progress task under `workspace: worktree` (fix-next step 0, `pick` of an in-progress task, `close` from a new session) locates the worktree holding `task/TASK-NNN` from `git worktree list --porcelain`, enters it, and proves the move exactly as TASK-175 does.
- [ ] No worktree holds the branch → report it and continue in place, as today. A worktree whose folder is missing (`prunable`) → report it by path, never prune it automatically.
- [ ] Resuming never creates a second worktree for a task that already has one.
- [ ] Enter-then-prove becomes a cross-skill protocol once this task reuses it from `fix-next`, `pick` and `close`: it keeps **one** owning file (today `skills/tasks/verbs/pick.md` step 6b), the other sites point at it, and AGENTS.md § Conventions gains a one-line entry (register-on-introduce; raised by TASK-174/175's conventions review).
- [ ] `skills/fix-next/SKILL.md` step 0 and the `pick`/`close` sites each carry the rule, or a pointer to the one place that owns it.

## Out of scope

- Creating the worktree in the first place — TASK-174/175.

## Human test plan

On a `pr-per-task` consumer, `workspace: worktree`, root declared.

- [ ] Pick a task (worktree created), end the session, start a new one in the main copy, `/tasks pick` the same task. Expected: the session enters the existing worktree and proves it; no second worktree; the main copy stays on the default branch.
- [ ] Same, but delete the worktree folder by hand first. Expected: reported as prunable by path, not pruned, and the run continues in place.

## Implementation plan

_Populated by `/tasks plan TASK-181` — leave empty until then._
