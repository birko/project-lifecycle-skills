---
id: TASK-175
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
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

# `/tasks pick` proves the move into the worktree, and falls back when it cannot

## Context

FEATURE-001 D3 and D4. A branch checked out in a worktree **cannot** be checked out in the main copy,
so a worktree the session never enters is a trap: work keeps landing in the main copy, on the default
branch, under a policy that promised isolation.

- **D3** — when the running tool cannot change its working directory for the rest of the session,
  create nothing: cut `task/TASK-NNN` in place as today and report the degradation.
- **D4** — after moving, prove it from evidence: `git rev-parse --show-toplevel` must equal the
  worktree path. Never ask the agent whether it can move; DRILL-109 measured cold runners asserting
  things nobody established. On mismatch: `git worktree remove` the new worktree, delete the unused
  branch, fall back to D3, report.

How a skill tells "this runtime can move" from "this one cannot" without asking itself is the design
question for the plan. The D4 proof is the backstop either way: an attempt that did not stick is
caught and undone.

## Acceptance criteria

- [x] `pick.md` enters the worktree and runs the `--show-toplevel` check before anything else is flipped *(superseded in part by D17, approved mid-work: the status flip is now committed on the default branch **before** the worktree exists, so the check runs before anything is written **in the worktree**)*; the comparison normalizes path forms (drive letters, `/c/` vs `C:\`, trailing separators).
- [x] Mismatch → worktree removed, branch deleted, in-place branch cut; the report names the fallback and the two paths compared.
- [x] A move that does not stick leaves nothing behind — no worktree, no branch — and the in-place fallback says so (D3). *(Reworded 2026-09-24, before work began: the original "a runtime known not to persist a directory change never creates the worktree" assumed something can know that in advance, which D14 rules out; the outcome it protected is unchanged.)*
- [x] The report distinguishes *in a worktree at <path>* from *fell back to in-place: <reason>* — never one line for both.

## Out of scope

- A per-runtime capability table — rejected by D14; every runtime takes the same attempt-then-prove path.

## Human test plan

On a `pr-per-task` consumer, `workspace: worktree`, root declared.

- [ ] Claude Code: `/tasks pick`. Expected: the session reports the worktree path, and `git rev-parse --show-toplevel` / `git branch --show-current` run from the session show the worktree and `task/TASK-NNN`; the main copy stays on the default branch.
- [ ] pi runtime: same. Expected: either the same outcome, or an explicit fallback report with no worktree left behind (`git worktree list` shows only the main copy).
- [x] Force a mismatch (temporarily point the proof at a wrong path). Expected: worktree and branch removed, in-place branch cut, report names both paths.

## Implementation plan

Lands in **one change with TASK-174**. Decision: D14 (attempt, then prove, for every runtime; no capability table), approved 2026-09-24. It rests on a probe run that day: from the main Claude Code session, `EnterWorktree` with `path` entered an outside-repo worktree, and `git rev-parse --show-toplevel` confirmed it from both Bash and PowerShell.

1. `pick.md` step 6b, after `git worktree add`: **enter, prove, then continue** to steps 7–9. Order matters: the status flip and the dashboard regeneration must land in the worktree, on the task branch. Written in the main copy, they would dirty it and fail D7's clean check at close.
   - **Enter** with the runtime's own worktree-entry tool when it has one (Claude Code: `EnterWorktree` with `path`). Otherwise use a directory change.
   - **Prove** with `git rev-parse --show-toplevel` as a **separate, later command**, never chained after the move, since a same-line check always passes.
2. Compare against `git -C <path> rev-parse --show-toplevel`, so git produces both forms. Then normalise both: drive-letter case, `/c/` ↔ `C:/`, `\` → `/`, trailing separator.
3. Mismatch → `git worktree remove <path>` and `git branch -d task/TASK-NNN` (no commits yet, so never force). Cut the branch in place as step 7 does, and print the fell-back line naming both paths. If a removal fails → report what is left behind and stop.
4. Report: one fixed line for the worktree case and one for the fallback, printed before step 9's hand-off.
5. Known outcome, stated so the first test doesn't read as a failure: a subagent (pinned working directory) always falls back, correctly.

**Drill (2026-09-24):** recorded once, on TASK-174 — the two tasks were drilled together on the same fixtures. This task's forced-mismatch step passed there.

**Close gate:** recorded once, on TASK-174 (joint landing).
