---
id: TASK-329
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-328-1]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick TASK-NNN` by bare id skips the taken filter, so an in-place pick can take a task another clone holds

## Context

Found by TASK-328's cold drill (2026-10-14). Both runners raised it. `skills/tasks/verbs/pick.md` step 1 says: *"Bare ID arg (`/tasks pick TASK-014`) → skip the picker, jump to step 5."* That skips step 3, where the taken filter lives (a `todo` task whose `task/TASK-NNN` branch exists locally or on a remote, [[tasks]] SKILL.md § *Collection pass*). Under `workspace: worktree` with an upstream, 6b's taken-elsewhere check still catches it, and since TASK-328 every fallback runs that check too. Two cases have no check at all:
- an ordinary in-place pick (`workspace: in-place`, a PR-per-task default);
- any pick with no upstream, where a local `task/TASK-NNN` from another session marks the task as taken.

Scenario: a person names a task someone else has pushed a branch for. The pick flips it to `in-progress` and cuts a second branch over the other person's work.

## Acceptance criteria

- [x] A bare-id pick refuses a task the Collection pass counts as taken, whatever `workspace:` says, with a stated report line
- [x] A bare-id pick of a task taken by this clone's own branch still resumes where the resume rules say it does
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- 6b's own taken-elsewhere check (TASK-328)

## Human test plan

- [x] On an in-place PR-per-task fixture with `task/TASK-001` already on the remote, run `/tasks pick TASK-001`. Expected: the run refuses and names the branch; nothing is flipped or cut.
  - Passed 2026-10-14 as a cold drill (`skills/populate-tests/SKILL.md` § *The cold drill*). Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)"`, brief on stdin. The cwd was a scratchpad clone, `f329-fixed/repo` (`workspace: in-place`, `pr-per-task`, a local bare remote holding `task/TASK-001`), holding copies of `SKILL.md` and `pick.md`. Coldness: the runner reported no skills. Result: `pick: TASK-001 is taken — task/TASK-001 exists on origin, and this session is not on it. Nothing was changed. …`; TASK-001 still reads `todo` and the tree is clean. The review's rework changed only the local-branch rows, not the refusal this drill hit.

## Implementation plan

Written by `/fix-next` after step 3 (it runs no `/tasks plan`): give the bare-id path step 3's taken check as a table, with the carve-outs step 3 and 6b already make; fetch first with an upstream; respec `work-tracking`; drill the task's own test plan.

## Outcome

- **The fix.** `/tasks pick TASK-NNN` skipped the picker, and with it step 3's taken filter, so naming a task was a way to start one that another clone had pushed a branch for. Now a bare id runs that check first, fetching first when there is an upstream:
  - no branch, or a branch that is the current checkout → the pick goes ahead;
  - a local branch under `workspace: worktree` → step 6b, which owns resuming it and its leftover lines;
  - anything else → refused, with a fixed **taken** line naming where the branch is, and nothing written.

  File: `skills/tasks/verbs/pick.md` step 2, plus the `work-tracking` spec.
- **Step-6 split (cold drill, original vs fixed files, in-place fixture with the branch already on the remote):** 2 of 2 outcomes flip. Fix-dependent: the refusal, and the status left at `todo`. The original runner flipped `TASK-001` to `in-progress` over the other clone's branch, and noted "pick.md's bare-id path never asks for this". Contract pins: the remote branch untouched, no push.
- **Judgement calls.**
  - The check is a table at the bare-id branch rather than a pointer to step 3. Step 3 filters a list, and this path has no list, so the carve-outs have to be stated where they apply.
  - Under `workspace: worktree`, every local branch goes on to 6b. The review showed the first version refused a case 6b resumes: a local branch with no worktree holding it. 6b already owns all local cases, so it keeps them.
  - Accepted, not fixed: in an in-place project with no upstream, this session's own branch is refused if the checkout was switched away. The line says to switch to it and pick again, which then succeeds; that two-step path is the safe direction. A detached HEAD is refused the same way.
- **Specs.** `work-tracking` respecced by `/fix-next` step 7: the "Picking a task" requirement gains the bare-id check, and a scenario. *Intended anyway — TASK-329's criteria, answered by /fix-next.*
- **Review gate.** Standards: pass, no findings. Fidelity: criterion 2 was wrong in the first version (the resume row pre-empted); fixed. Correctness: high, the same pre-emption of 6b's no-worktree resume and leftover line, fixed. Medium: a parked `verify` branch was described as another clone's; now under 6b in worktree projects. Low: the in-place switched-away case (above), a detached HEAD (safe), and the wording of the in-place worktree row (gone with the rework). Security and review-comments: not applicable.
- **Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-327 because keys 1 and 3: an in-place bare-id pick of a taken task flips it and cuts a second branch over another person's work with no signal, while TASK-327 is a misleading empty-pool message; also P2 over P3
- step 3 — verified: held. `pick.md` step 2: "Bare ID arg (`/tasks pick TASK-014`) → skip the picker, jump to step 5"; the taken filter lives in step 3 alone, and step 7's branch cut checks nothing. Under `workspace: worktree` 6b's taken-elsewhere check (remote branch, no local one) still applies; nothing else does
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/pick.md step 2: a bare id runs step 3's taken check on that task first (a table: absent, current checkout and a worktree resume go on, anything else prints the **taken** line and stops), fetching first with an upstream; test = lint OK + cold drill (step 6)
- step 6 — reverted fix (cold `claude -p` runners, original vs fixed `SKILL.md`/`pick.md`; in-place `pr-per-task` fixture whose remote already holds `task/TASK-001` from another clone): 2/2 flip. Fixed: the run printed `pick: TASK-001 is taken — task/TASK-001 exists on origin …` and changed nothing (`status: todo`, clean tree). Original: TASK-001 flipped to `in-progress` in the working copy over the other clone's branch, and the runner noted that "pick.md's bare-id path never asks for this". fix-dependent = the refusal, the unchanged status; contract pins = the remote branch untouched, no push. The fixed runner raised one gap, a fetch before the check (fixed)
- step 7 — respecced work-tracking; requirement changed: "Picking a task" (a task named by id passes the taken check); scenario added: a task named by id that another clone holds
- step 7 (amended after review) — under `workspace: worktree` every local branch goes on to 6b; spec sentence matched
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
