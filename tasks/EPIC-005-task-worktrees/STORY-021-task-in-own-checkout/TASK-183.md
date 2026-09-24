---
id: TASK-183
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
priority: P2
assignee: ai
created: 2026-09-24
depends-on: [TASK-176]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Worktree mode for projects whose default branch tracks a remote

## Context

FEATURE-001 D23. Worktree mode ships for local merges only. The design records "this task is in progress" (the D17 pick commit) and "the dashboard after this close" (the D22 refresh) as commits on the **local** default branch. When that branch tracks a remote and work merges through PRs, nobody pushes those commits. The local branch diverges from the remote as soon as a PR merges there, every later `pull --ff-only` fails, and a protected branch can never take them. Today `pick` step 6b and `close` step 4b refuse the case and say so.

The open question is where "in progress" lives when the default branch cannot carry it. Candidates, none decided:
- the pushed task branch's existence on the remote;
- a PR in draft;
- a lightweight marker branch;
- accepting task-branch-only status and teaching the collection pass to read other branches.

It needs a grill and a decision round before any code.

## Acceptance criteria

- [x] A recorded decision on where in-progress state lives for a PR-based project, with the rejected options.
- [x] `pick` step 6b and `close` steps 4b/8 support a default branch that tracks a remote under that decision, and D23's refusal is removed or narrowed.
- [x] Drilled against a fixture with a bare remote, including two tasks merged remotely in either order.

## Out of scope

- Local-merge worktree mode — TASK-174/175/176.

## Human test plan

- [ ] On a consumer with a GitHub remote and a protected default branch: pick two tasks, merge both PRs on GitHub in either order, and close both. Expected: no divergence, no failed pull, and both worktrees removed.

## Implementation plan

Decisions: D25 (in progress = the pushed task branch), D26 (no generated-file commits on the default branch), D27 (plain git), and D23 changed. Remote mode = `workspace: worktree` + the default branch tracks a remote.

1. **`pick` step 6b.** The remote check selects remote mode rather than refusing.
   - Run `git fetch` first (offline → report and continue on local knowledge). The leftover check also looks for `refs/remotes/*/task/TASK-NNN`.
   - **No pick commit on the default branch.** In remote mode the clean check allows no uncommitted task file, since there is nowhere to put it: an uncommitted new task means "commit it first" (report, stop).
   - Order: create the worktree → enter → prove → flip the status **in the worktree** → commit `TASK-NNN: pick` on the task branch → `git push -u <remote> task/TASK-NNN`. A failed push is reported: the task is in progress locally but unseen elsewhere.
   - A fallback in place follows today's in-place behaviour.
2. **Collection (the `tasks` SKILL.md Collection pass, the owner).** A `todo` task whose `task/TASK-NNN` exists locally or under `refs/remotes/` is **taken**: shown in progress, never offered by `pick`, outside `fix-next`'s pool. It is recomputed from `git branch --list` / `git branch -r --list`, never stored. `pick` step 3 and `fix-next` point at it.
3. **`close`.** Step 4b's remote check selects remote mode.
   - Steps 6–7 commit `done` on the task branch in the worktree, then push. Step 8 uses the existing PR path (open or merge; `gh pr merge` without `--delete-branch`).
   - Leave and prove, check the main copy (clean, on the default branch), then `git pull --ff-only`. The local default branch has no local commits, so this cannot diverge.
   - Remove the worktree, `branch -d`, then delete the remote task branch when the host did not.
   - **Step 10/10b/11 write nothing on the default branch**; print what changed and name the owning verbs (D26).
4. **Wording.** `SKILL.md` § Where the work happens, the config template comment, and `init`'s workspace question drop "local merges only".
5. **Drill.** A fixture with a bare remote. The `-p` runners exercise pick's fallback path, the push, and the "taken" collection. An interactive run in a nested clone with a bare origin exercises the full pick → push → close → PR-less remote merge (`git push` of the merge, simulating the host) → `pull --ff-only` → remove.

**Drill (2026-09-24), interactive, real remote.** The fixture: a bare repo as the host (`origin183.git`); the drill clone nested at `scratch/trial183/proj`, whose `main` tracks `origin/main`, so remote mode applies and `EnterWorktree` accepts its worktrees; and a second clone standing in for another machine and for the host. The main Claude Code session ran it, not a cold runner.

*Round 1, one task end to end, by the verbs:*
- **`pick TASK-001`.** Every remote-mode check passed (main copy, upstream `origin/main`, `fetch`, clean, nothing on the remote). The worktree was created with **nothing committed on `main`**. `EnterWorktree` and the proof passed in both shells. `TASK-001: pick` was committed on the task branch and pushed with `-u`, and local `main` stayed equal to `origin/main`.
- **The other clone.** A `claude -p` runner in clone2 listed `pick` candidates. It **left TASK-001 off** (its reason: `origin/task/TASK-001` exists, so another clone has it, though `main`'s file reads `todo`) and offered only TASK-002.
- **`close`.** The work and `done` were committed and pushed on the branch. The host merge was simulated from clone2 (`merge --no-ff`, push `main`), because a bare repo hosts no PRs. Then the tail ran: leave, main clean, `git pull --ff-only` (fast-forward), 0 local commits ahead, the remote branch deleted, the worktree removed, the branch deleted. `main` ended as a clean mirror.

*Round 2, two tasks merged in reverse pick order, git steps run directly (entry already proved in round 1):*
- **TASK-003** was created uncommitted, as `/tasks new` leaves it, with `tasks/README.md` touched. The pick **carried** it into the worktree cut from `origin/main`, then restored `main` (task file moved out, README restored). It was committed and pushed on its branch.
- **TASK-002** was picked alongside it, from a clean `main`.
- **Merges.** The host merged **TASK-002 first, then TASK-003**. Each close pulled fast-forward, deleted the remote branch, removed the worktree and deleted the branch. There were no conflicts; all three tasks read `done` on `main`, including TASK-003, which reached `main` only through its PR. `origin/main..main` = 0 throughout.

**Review round 1** failed correctness with 7 blockers: resume and `fix-next` blind to remote mode; planned or new tasks stopping at "commit it first"; the root answer left dirty on `main`; a stale local base; close still checking "no remote"; a defer after `done` resuming to a local merge. Plus 5 warnings. **Timing, stated exactly:** round 1's pick and the other-clone check ran *before* those fixes; round 1's close and all of round 2 ran *after*. The fixes left the path a committed task takes through `pick` unchanged, apart from `fetch --prune` and cutting the worktree from the upstream tip. Round 2 exercised the carry fix directly.

*Round 3, after review rounds 2 and 3, git steps run directly:*
- **TASK-004** was carried as a new, uncommitted task, then closed on a **remote with no PR mechanism (D29)**: leave, then merge in the main copy and push `main`. `origin/main..main` = 0.
- **The re-close of a landed merge:** the tail was left unfinished on purpose, then the task was closed again. Step 4's remote-mode check found the task branch reading `done` and the upstream reading `done`, with the branch an ancestor of the upstream, so it ran **only the tail**: no push, no PR, no second merge. The clean mirror was restored.

**Review rounds.**
- **Round 2** confirmed the 7 original fixes hold and found 5 more issues, all fixed:
  - a stale local base under the carry;
  - the fallback's branch delete failing;
  - no resume without a worktree;
  - a loop after a landed merge;
  - a defer rule contradicting merge-failed.
- **Round 3** confirmed B, C and D hold. Fix A's fast-forward had been placed before the on-default-branch check, and is now moved to the end of the checks.
- **Round 3 also raised two design questions**, answered by the stakeholder: **D28** (queue a not-yet-mergeable PR with the host's auto-merge rather than looping on restarted checks) and **D29** (a plain remote merges in the main copy and pushes `main`, never a PR host lacking a client).

A fourth review pass was not run; the round-3 fixes were verified by the round-3 drill above.

**Parked at `review`, not `done`:** the human-test step needs a real GitHub remote with a protected default branch and required checks. That is where D28's auto-merge queue and the host's own merge run, and no drill here can stand in for the host. Every other path was drilled against a bare remote.
