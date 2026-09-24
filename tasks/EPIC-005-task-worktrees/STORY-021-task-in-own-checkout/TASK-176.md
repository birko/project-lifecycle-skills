---
id: TASK-176
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] `close.md` detects it is running in a linked worktree from evidence (`git rev-parse --git-common-dir` differs from `--git-dir`) **before anything is written** (step 4b, D18), and takes the D7 path. *(Reworded 2026-09-24, before work began: "step 8" was too late, since steps 5–7 commit on the task branch and a failed close must leave it untouched.)*
- [x] Dirty main copy, or main copy off the default branch → failed close with the reason; task status unchanged; worktree and branch untouched.
- [x] The tail runs in D8 order; a failing step stops the tail and the report names what remains to clean up.
- [x] A dirty worktree at removal → reported with its path, not removed, branch not deleted.
- [x] The 5c *defer* path leaves the worktree in place and names it, so `/tasks unblock` + re-close resumes there.
- [x] Steps 9–12 run against the main copy — by absolute path when the session could not leave — and what they regenerate there is committed (D22). *(Widened 2026-09-24, before work began, from TASK-176's plan: uncommitted regenerations dirty the main copy the next pick and close check.)*
- [x] A session that cannot leave the worktree after a landed merge ends `done`, printing the exact outstanding commands (D20).
- [x] Only the worktree `pick` made is removed (D21); a close run from the wrong worktree, or from the main copy while a worktree holds the branch, changes nothing and says so (the latter hands to TASK-181).

## Out of scope

- Changing the merge strategy or the PR flow.

## Human test plan

On a `pr-per-task` consumer, after TASK-174/175 created a worktree for a throwaway task.

- [x] Commit a trivial change in the worktree, `/tasks close`. Expected: merge commit on the default branch in the main copy, worktree folder gone, `git worktree list` shows only the main copy, `task/TASK-NNN` deleted, session in the main copy.
- [x] Repeat with an uncommitted edit in the main copy. Expected: failed close, task still `in-progress`, worktree intact.
- [x] Repeat with an untracked file left in the worktree. Expected: merge done, removal reported and skipped, branch kept, path printed.

## Implementation plan

Decisions: D18–D22 (approved 2026-09-24). Lands with TASK-174/175 (D17 landing).

1. `close.md` **step 4b "Where this close runs"**: evidence-only and recomputed every run. It has four cases:
   - (a) the main copy, with no worktree holding the branch → today's flow;
   - (b) the task's own worktree → the worktree path;
   - (c) another task's worktree → the wrong-tree line, then stop;
   - (d) the main copy while a worktree holds the branch → the held-elsewhere line, then stop (TASK-181 later makes it re-enter).

   In (b), check the main copy here: it must be clean and on the default branch. Otherwise it is a failed close and nothing is written.
2. Under (b), steps 6–7 edit and commit in the worktree, on the task branch. The dashboard is not regenerated there (D19).
3. **Step 8, a "from a worktree" branch:**
   - Re-check the main copy.
   - **Local path:** `git -C <main> merge --no-ff --no-commit task/TASK-NNN`, write the `pr:` backfill into the pending merge, then `commit --no-edit`. On conflict → `merge --abort` → failed close.
   - **PR path:** push and create the PR from the worktree. Run `gh pr merge` without `--delete-branch`, then `git -C <main> pull --ff-only`.
   - **Tail**, stopping at the first failure and printing the outstanding commands:
     - leave: `ExitWorktree keep`, or `cd`, then prove it with a separate `--show-toplevel`;
     - remove: `git -C <main> worktree remove`, only for D21's path, never forced;
     - delete: `branch -d`, never `-D`.
4. **5c defer / step 5 review park:** commit in the worktree, push, keep the worktree, print the kept line, and skip the tail.
5. **Steps 9–12** run against the main copy. Under `workspace: worktree`, commit what steps 10–11 wrote with `git commit --only` (D22).
6. **Step 2 `--unattended` table:** one row recording that 4b and the worktree tail ask nothing.
7. **Edge cases:** leave failed, removal refused, and a failed `pull --ff-only`.
8. **`SKILL.md` pointer:** one clause pointing at `close` 4b/8.
9. **Drill:** a `-p` runner launched *inside* the worktree, since it cannot leave. The orchestrator simulates the pick and reads every verdict from git, then runs the printed outstanding commands verbatim to prove they are exact. Plus dirty-main, wrong-tree and held-elsewhere fixtures. The full tail with removal needs the interactive session.

**Drill (2026-09-24).** Four `claude -p` runners, each **launched inside** the task's worktree (a `-p` runner cannot move, so this is the only way to reach the worktree close). Command as on TASK-174 plus `--allowedTools "Bash(git:*)" "Bash(cd:*)" EnterWorktree ExitWorktree`. Brief: `/tasks close TASK-001 --unattended`, with the 5b passes treated as run and passed and no remote. **Not cold on names**; this drills behaviour. The fixtures were scripted to the D17 shape: a pick commit on `main`, then `git worktree add` at `<root>/<repo>-TASK-001`, then the work committed on the task branch. **Every verdict below was read from git, not from the runner.**

| Fixture | Git afterwards | Line printed |
|---|---|---|
| a · clean main, runner inside the worktree | `task/TASK-001` commit (status `done`) → `--no-ff` merge on `main` whose task file carries `pr: 89a5e94` (the backfill rode in the merge) → `chore: dashboard and rollups after TASK-001` holding only `tasks/README.md`; main clean | could-not-leave, with the outstanding commands. **Those commands, run verbatim afterwards, removed the worktree and deleted the branch cleanly**: worktree list = main only, branch list = `main` |
| b · unrelated edit in main | nothing new on either branch; worktree clean; `main:` task file still `in-progress` | failed-close (not clean, 1 path) |
| c · runner in TASK-002's worktree | nothing changed | wrong-tree |
| d · runner in the main copy, worktree holds the branch | nothing changed | held-elsewhere |

Not reachable by a `-p` runner, so left for the interactive session: the full tail with removal (human-test step 1), and a dirty worktree at removal (step 3).

**Close gate and re-drill:** recorded once, on TASK-174 (joint landing).

**Interactive steps run** in TASK-179's trial (steps 7 and 8), **after D7/D8 changed** because the trial found the reach-in merge refused under worktree isolation (step 6).

**Closed `done` 2026-09-24:** every human-test step has now been run (TASK-179's trial). Landed with TASK-175/176 in `b9e9161`, with the trial's D7/D8/D18 fixes on top.
