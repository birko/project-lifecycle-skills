---
id: TASK-186
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
priority: P1
assignee: ai
created: 2026-09-24
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-F001-1, CR-F001-5]
pr: null
github-issue: null
jira-key: null
---

# Remote mode hides a session's own in-progress task from `fix-next` step 0 and from the `pick` list

## Context

Found by `/feature review FEATURE-001` Gate A (2026-09-24). The finding was raised by the cross-task seam pass over the feature's cumulative diff `f4b982e..HEAD`. Per the review verb, it is filed here rather than fixed at the gate.

Two seams between TASK-181 (resume) and TASK-183 (remote mode). In remote mode, the default branch's copy of an in-progress task reads `todo`.
- **CR-F001-1, high.** `skills/fix-next/SKILL.md` step 0 enters its resume block only after a `grep ^status: in-progress` hit on the default branch. The task-branch lookup TASK-181 added (`git branch --list "task/*"`, then `git show`) sits *inside* that block, so in remote mode it never runs. The pool rule (a task with a branch is "taken") also hides the run's own task, so a reset drain picks a **second** task and abandons the first. The lookup also has no status filter: a branch copy parked at `review`/`blocked`, or one whose merge failed with `done`, would be "resumed" as an active run.
- **CR-F001-5, medium.** `skills/tasks/verbs/pick.md` step 3 lists every `todo` task with a branch as `taken (hidden)`, including this clone's own in-progress task. The 6b resume row is reachable only by the bare-id path, and nothing says so, so a session resuming via `/tasks pick` is offered fresh work.

## Acceptance criteria

- [x] `fix-next` step 0 finds its own run in remote mode: the task-branch lookup runs **independently** of the default-branch grep, and resumes only a branch copy that reads `in-progress` and carries `picked-by: fix-next`.
- [x] `pick`'s hidden list marks a local branch that a worktree holds as the session's own, naming the resume path (`/tasks pick TASK-NNN`), and never as taken by someone else.
- [x] Drilled in remote mode: a reset `fix-next` resumes its task and picks nothing new, and a bare `/tasks pick` points at the resume.

## Out of scope

- The linked-worktree probe — TASK-187.

## Human test plan

- [ ] In a remote-mode fixture, interrupt a `fix-next` run after its pick, reset, and run `/fix-next` again. Expected: it resumes the same task, and no second task becomes in-progress.

## Implementation plan

Written at the FEATURE-001 review gate; the fix follows the acceptance criteria one to one.

**Close gate (2026-09-24).** Fixed at the FEATURE-001 review. A targeted Gate A confirmation pass found every finding holding, and flagged three small issues in this task's own fix, all fixed in place: the in-progress line is now gated on the branch copy reading `in-progress`; it is worded "on this machine" with a caution; and `fix-next` reads the branch copy. `skills-lint` is OK. **Parked at `review`:** the human-test step (a remote-mode `fix-next` reset that resumes its own task) has not been run. The reviews confirmed the text only.
