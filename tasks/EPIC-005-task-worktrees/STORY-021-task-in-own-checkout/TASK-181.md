---
id: TASK-181
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] Every verb path that resumes an in-progress task under `workspace: worktree` (fix-next step 0, `pick` of an in-progress task, `close` from a new session) locates the worktree holding `task/TASK-NNN` from `git worktree list --porcelain`, enters it, and proves the move exactly as TASK-175 does.
- [x] No worktree holds the branch → report it and continue in place, as today. A worktree whose folder is missing (`prunable`) → report it by path, **name `git worktree prune` as the person's step, and stop** — never prune it automatically. *(Corrected 2026-09-24, before work began: git refuses to check the branch out anywhere while a prunable registration holds it — measured, `'task/PROBE' is already used by worktree at …` — so "continue in place" is impossible without the prune this criterion forbids.)*
- [x] Resuming never creates a second worktree for a task that already has one.
- [x] Enter-then-prove becomes a cross-skill protocol once this task reuses it from `fix-next`, `pick` and `close`: it keeps **one** owning file (today `skills/tasks/verbs/pick.md` step 6b), the other sites point at it, and AGENTS.md § Conventions gains a one-line entry (register-on-introduce; raised by TASK-174/175's conventions review).
- [x] `skills/fix-next/SKILL.md` step 0 and the `pick`/`close` sites each carry the rule, or a pointer to the one place that owns it.

## Out of scope

- Creating the worktree in the first place — TASK-174/175.

## Human test plan

On a `pr-per-task` consumer, `workspace: worktree`, root declared.

- [x] Pick a task (worktree created), end the session, start a new one in the main copy, `/tasks pick` the same task. Expected: the session enters the existing worktree and proves it; no second worktree; the main copy stays on the default branch.
- [x] Same, but delete the worktree folder by hand first. Expected: reported as prunable by path, not pruned; the run stops and names `git worktree prune` as the person's step.

## Implementation plan

**Written after the fact — a lifecycle slip, recorded rather than hidden.** No plan was drafted before
implementation. The review caught it. What was built:
1. `pick` step 6b gains a **resume** row, scoped to `workspace: worktree` + in-progress + branch exists, after the
   no-effect row. The wrong-tree check runs first. There are three cases: re-enter and prove; a prunable entry
   stops without pruning; with no worktree, continue in place, then step 9. 6b is declared the one owner of
   enter-then-prove.
2. `close` step 4b: a close from the main copy while a worktree holds the branch resumes through pick's resume.
3. `fix-next` step 0 resumes through it before reading the Progress log.
4. `AGENTS.md` gains the owner entry (register-on-introduce).

**Drill (2026-09-24), interactive, in TASK-179's trial clone.** The main Claude Code session ran it, not a cold runner (see TASK-179). Each "new session" was simulated by `ExitWorktree` back to the main copy, which is exactly where a new session starts.

| Case | Outcome (read from git) |
|---|---|
| TASK-015 picked into a worktree, part of the work committed, then back to the main copy and **`pick` again** | resume row: the worktree was found from `git worktree list --porcelain` (not the first entry, `branch refs/heads/task/TASK-015`), entered by `EnterWorktree path=`, proved in Bash and PowerShell; the first commit was present; **still 2 worktrees**, no second one made |
| rest of the work, back to the main copy, **`close` from there** | step 4: `git show` of both copies read `in-progress`, so it is not an unmerged close. Step 4b's new row resumed into the worktree through pick's resume and proved it. The branch and remote checks ran **from inside the isolated session** (the narrowed skip, confirmed live). Then `done` was committed on the branch → leave (proved in both shells) → main copy clean → merge with `pr: 3ed2552` → worktree removed → branch deleted → main clean |
| TASK-016 picked into a worktree, then its **folder deleted by hand**, then `pick` again | resume → the entry is `prunable` → prunable line, **stop, not pruned**, nothing changed |
| the person runs `git worktree prune`, then `pick` again | **found a gap in the first draft**: the resume row fired only when a worktree held the branch, so its no-worktree case was unreachable, and the run would have hit the leftover stop. Fixed: the row fires on *in-progress + branch exists*. Re-run: no-worktree line, main copy clean, switched to `task/TASK-016` in place |

The protocol owner is pick step 6b. `close` 4b and `fix-next` step 0 point at it, and AGENTS.md § Code structure gained the one-line entry.

**Closed `done` 2026-09-24.** Close gate: three review passes (correctness failed with two majors, intent partial, conventions warned), all fixed. The resume row is scoped to `workspace: worktree` and runs after the wrong-tree check, so in-place projects are unchanged. Every-shell proof moved into the owner, the AGENTS.md entry was cut to invariant plus pointer, and the doubled close line and the `fix-next` stop list were fixed. The live drill above covers all three resume cases. The unwritten plan is recorded as a slip.
