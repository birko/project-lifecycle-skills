---
id: TASK-176
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: ai
created: 2026-09-24
depends-on: [TASK-174]
blocks: [TASK-179]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/tasks close` merges from the worktree and removes it in a fixed order

## Context

FEATURE-001 D7 and D8. In a worktree the default branch is checked out in the main copy and cannot be
checked out again, so `close` step 8 (`skills/tasks/verbs/close.md`, *Merge gate*) cannot "check out
the default branch" the way it does today.

- **D7** — merge by driving the main copy from where the session stands:
  `git -C <main-tree> merge --no-ff task/TASK-NNN`. Main copy dirty or not on the default branch ⇒
  **failed close**, which step 8 already defines: stop, report, the task keeps its pre-close status.
  The PR path (push, open, merge remotely) still applies where the project uses one; this changes only
  where a local merge is driven from.
- **D8** — fixed tail: merge → leave the worktree (session moves to the main copy) →
  `git worktree remove <path>` → `git branch -d task/TASK-NNN`. Forced by git: you cannot remove the
  folder you are standing in, and a branch held by a worktree cannot be deleted. A dirty worktree at
  removal is **reported, never force-removed** — `--force` there destroys uncommitted work at the one
  step meant to be safe.

Step 8's later promise (chore refreshes land on the default branch) must still hold: after the tail,
the session is in the main copy on the default branch.

## Acceptance criteria

- [ ] `close.md` step 8 detects it is running in a linked worktree from evidence (`git rev-parse --git-common-dir` differs from `--git-dir`) and takes the D7 path.
- [ ] Dirty main copy, or main copy off the default branch → failed close with the reason; task status unchanged; worktree and branch untouched.
- [ ] The tail runs in D8 order; a failing step stops the tail and the report names what remains to clean up.
- [ ] A dirty worktree at removal → reported with its path, not removed, branch not deleted.
- [ ] The 5c *defer* path leaves the worktree in place and names it, so `/tasks unblock` + re-close resumes there.
- [ ] Steps 9–12 run from the main copy.

## Out of scope

- Changing the merge strategy or the PR flow.

## Human test plan

On a `pr-per-task` consumer, after TASK-174/175 created a worktree for a throwaway task.

- [ ] Commit a trivial change in the worktree, `/tasks close`. Expected: merge commit on the default branch in the main copy, worktree folder gone, `git worktree list` shows only the main copy, `task/TASK-NNN` deleted, session in the main copy.
- [ ] Repeat with an uncommitted edit in the main copy. Expected: failed close, task still `in-progress`, worktree intact.
- [ ] Repeat with an untracked file left in the worktree. Expected: merge done, removal reported and skipped, branch kept, path printed.

## Implementation plan

_Populated by `/tasks plan TASK-176` — leave empty until then._
