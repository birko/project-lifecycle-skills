---
id: TASK-184
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

# Tasks created in parallel worktrees can mint the same id

## Context

Found by the second correctness review of TASK-174/175/176 (2026-09-24). `new` and `spawn` allocate the next `TASK-NNN` by taking the highest id among the files **in the current tree** and adding one. With two tasks in parallel worktrees, each tree has its own view. A follow-up spawned in each is given the same id, and the result is either an add/add conflict at the second merge or two different files carrying one id. The dashboard conflict the same review found was fixed in that change, because no verb regenerates `tasks/README.md` inside a worktree. The id collision is the stakeholder's call to handle separately.

## Acceptance criteria

- [x] Id allocation under `workspace: worktree` sees ids minted on every local task branch as well as the default branch (for example via `git grep` across `refs/heads`), or a recorded decision says why another mechanism is better.
- [x] Two parallel worktrees each spawning a task get different ids, drilled.

## Out of scope

- Remote branches not fetched locally — TASK-183's territory (the shipped rule now names them as unseen).
- `FEATURE-NNN`, which has the same collision through its own counter — TASK-185.

## Human test plan

- [x] Pick two tasks into worktrees, spawn a follow-up from inside each, and close both. Expected: two distinct ids and no add/add conflict.

## Implementation plan

1. **Probe first (done):** in an isolated worktree session, confirm which scan forms run. Plain `git branch --list`, a `git grep` over named branches, and a by-path read of another tree's `tasks/` (including an uncommitted file) all ran. `--format=%(refname)` and command substitution were refused.
2. **`SKILL.md` § ID generation owns the rule:** take the max over this tree, every local branch and every other worktree, in those plain forms. Recompute on every mint, and name an unreadable copy. `FIELD-NNN` uses the same scope.
3. **Pointers:** `new` step 6 and the two `FIELD-NNN` minting sites (in `new` and `intake`) point at the rule, not restating it.
4. **Drill:** two parallel worktrees, each spawning a task, must get distinct ids.

**Drill (2026-09-24).** A scratch repo with TASK-001..003, `workspace: worktree`, and two task worktrees open. Two `claude -p` runners ran **one after the other**, each launched inside one worktree, each told to create a loose follow-up via `new.md` (`--allowedTools "Bash(git:*)" "Bash(grep:*)" "Bash(ls:*)"`). **Not cold on names**; this drills behaviour.
- **Runner A** in `proj-TASK-001` → **TASK-004**, left uncommitted.
- **Runner B** in `proj-TASK-002` → **TASK-005**. Its report listed each copy with its max: this worktree TASK-003, the main copy TASK-003 (read by path), and `proj-TASK-001` **TASK-004 (uncommitted, read by path)**. It said a branches-only scan would have picked TASK-004. Unprompted, it also flagged the duplicate title.
- Under the old rule, both would have been TASK-004. Final tally across trees: TASK-004 ×1, TASK-005 ×1.

**Close gate: three review passes.**
- **Correctness:** two high findings, both fixed. The `git branch --list` output markers (`* `, `+ `, detached) were not parsed, and there was no no-git fallback (step 1 alone is now the whole scan).
- **Medium, fixed:** one `git grep` over all refs; remote-only branches named as unseen; the scan-to-write gap.
- **Medium, filed:** `FEATURE-NNN` → TASK-185.
- **Intent:** met once this drill ran.
- **Conventions:** the runtime-specific "Measured" paragraph was trimmed to the rule, and "name an unreadable copy" now has a home in `new`'s confirmation.

The drill ran on the pre-fix text. The fixes change how branches are listed, not the by-path read that caught B's collision.
