---
id: TASK-175
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

- [ ] `pick.md` enters the worktree and runs the `--show-toplevel` check before anything else is flipped; the comparison normalizes path forms (drive letters, `/c/` vs `C:\`, trailing separators).
- [ ] Mismatch → worktree removed, branch deleted, in-place branch cut; the report names the fallback and the two paths compared.
- [ ] A runtime known not to persist a directory change never creates the worktree (D3), and says so.
- [ ] The report distinguishes *in a worktree at <path>* from *fell back to in-place: <reason>* — never one line for both.

## Out of scope

- Detecting runtimes beyond Claude Code and pi; anything else takes the D4 path and is caught by the proof.

## Human test plan

On a `pr-per-task` consumer, `workspace: worktree`, root declared.

- [ ] Claude Code: `/tasks pick`. Expected: the session reports the worktree path, and `git rev-parse --show-toplevel` / `git branch --show-current` run from the session show the worktree and `task/TASK-NNN`; the main copy stays on the default branch.
- [ ] pi runtime: same. Expected: either the same outcome, or an explicit fallback report with no worktree left behind (`git worktree list` shows only the main copy).
- [ ] Force a mismatch (temporarily point the proof at a wrong path). Expected: worktree and branch removed, in-place branch cut, report names both paths.

## Implementation plan

_Populated by `/tasks plan TASK-175` — leave empty until then._
