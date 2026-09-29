---
id: TASK-186
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] In a remote-mode fixture, interrupt a `fix-next` run after its pick, reset, and run `/fix-next` again. Expected: it resumes the same task, and no second task becomes in-progress.
  - **Run 2026-09-29, passed.** A cold `/fix-next` runner on `master` (both tasks reading `todo` there) found TASK-011 through `git branch --list "task/*"` + `git show`, accepted it on `in-progress` + `picked-by: fix-next`, and resumed it at step 3 without ranking a pool. It rejected TASK-012's `review` branch copy as "not an active run". A cold bare `/tasks pick` runner printed `in progress on this machine: TASK-011 at …/wt/TASK-011 — resume with /tasks pick TASK-011 (check no other session is working in it)` and did not list TASK-011 as taken or offer it as fresh work.

**How the runners were obtained (both tasks).** Fixture: a bundle of Affiliate's `master` cloned into a local bare repo `%TEMP%/d186/remote.git` and a clone `%TEMP%/d186/affiliate` whose `master` tracks it (remote mode; nothing reached GitHub). The config was changed to `mode: local`, `workspace: worktree` and `worktree-root: ../wt`. The post-pick and parked-close states were **staged by hand**, following `pick.md` step 6b's remote-mode pick, because a `claude -p` runner cannot enter a worktree. TASK-011: worktree, `TASK-011: pick` on the task branch with `status: in-progress`, `picked-by: fix-next` and a step-2 log line, pushed. TASK-012: a pick, then a close parked at `review` in its kept worktree, pushed. `master` read `todo` for both. Fixture deviation: the worktree folders were named `wt/TASK-NNN`, not step 6b's `<repo>-TASK-NNN`. Nothing tested depends on the name, since resume locates the worktree by branch. Runner: `cd %TEMP%/d186/affiliate && claude -p --allowedTools "Bash(git:*)" "Bash(grep:*)" "Bash(ls:*)" Read Grep Glob Skill --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills < brief`, one read-only brief per verb, neither stating the expected answer. Coldness: the runners held the installed skills (the subject, needed for a behaviour drill) and could read this repo through `--add-dir`. Neither report mentions TASK-186, TASK-188 or the expected outcome.

## Implementation plan

Written at the FEATURE-001 review gate; the fix follows the acceptance criteria one to one.

**Close gate (2026-09-24).** Fixed at the FEATURE-001 review. A targeted Gate A confirmation pass found every finding holding, and flagged three small issues in this task's own fix, all fixed in place: the in-progress line is now gated on the branch copy reading `in-progress`; it is worded "on this machine" with a caution; and `fix-next` reads the branch copy. `skills-lint` is OK. **Parked at `review`:** the human-test step (a remote-mode `fix-next` reset that resumes its own task) has not been run. The reviews confirmed the text only.

## Progress log

- 2026-09-29 — Human test step run on a remote-mode fixture of Affiliate (record above); passed. Closed `review → done`. Drill findings outside this task's criteria filed as TASK-193 (DRILL-186-1) and TASK-194 (DRILL-186-2, DRILL-186-3).
