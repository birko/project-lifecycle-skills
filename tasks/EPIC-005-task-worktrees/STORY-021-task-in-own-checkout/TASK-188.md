---
id: TASK-188
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
priority: P2
assignee: ai
created: 2026-09-24
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-F001-4, CR-F001-6]
pr: null
github-issue: null
jira-key: null
---

# A worktree-parked `review` task is invisible to verification-debt surfacing; a remote-mode in-place fallback leaves its remote branch

## Context

Found by `/feature review FEATURE-001` Gate A (2026-09-24). The finding was raised by the cross-task seam pass over the feature's cumulative diff `f4b982e..HEAD`. Per the review verb, it is filed here rather than fixed at the gate.

- **CR-F001-4, medium.** A close parked at `review` in a worktree writes that status on the task branch only (`close.md` step 5 and the step-8 kept path). `pick` 2b and the Collection pass's `inReviewTasks[]` read only the default branch, so the task shows as `in-progress` (local mode) or `todo`→taken (remote mode). The "close review before new scope" nudge never sees it.
- **CR-F001-6, low.** A remote-mode in-place fallback pushes `task/TASK-NNN` (pick "Create"). Its later close is an in-place close, which only runs `git branch -d` locally; the remote-branch delete lives only in the worktree remote paragraph. The stale branch hides nothing once the task is `done`, but branches build up on the remote.

## Acceptance criteria

- [x] Verification debt counts a task whose own branch copy reads `review`, read with `git show`, like the resume row.
- [x] An in-place close of a task whose branch was pushed in remote mode deletes the remote branch, or says it did not.

## Out of scope

- Nothing else.

## Human test plan

- [ ] Park a worktree close at `review`, then run `/tasks pick` from the main copy. Expected: the verification-debt line names it.

## Implementation plan

Written at the FEATURE-001 review gate; the fix follows the acceptance criteria one to one.

**Close gate (2026-09-24).** The confirmation pass found both fixes holding. **Parked at `review`:** the human-test step (park a worktree close at `review`, then check that `pick`'s debt line names it) has not been run.
