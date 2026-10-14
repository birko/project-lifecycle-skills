---
id: TASK-328
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-254-1]
pr: null
github-issue: null
jira-key: null
---

# `pick`'s proof-mismatch fallback never pushes the task branch with an upstream, so other clones see the task as free

## Context

Found by TASK-254's close review (2026-10-14). `skills/tasks/verbs/pick.md` step 6b has two ways to fall back to an in-place pick:

- **`git worktree add` fails.** Since TASK-254 this path says it pushes `task/TASK-NNN` when the default branch has an upstream, and that the status flip stays uncommitted until `close`.
- **The enter-then-prove check mismatches.** This happens whenever the session cannot enter the worktree, and a `claude -p` runner always takes it. This path says only "continue at step 7". Nothing says it pushes with an upstream.

With an upstream, nothing is committed on the local default branch, so the pushed branch is the only taken signal (FEATURE-001 D25). Scenario: a session picks with an upstream, the proof mismatches, it falls back in place, and it never pushes. Every other clone's Collection pass sees no `task/TASK-NNN` on the remote and offers the task as free, so two people work it at once. `docs/specs/work-tracking.md`'s worktree-with-upstream requirement carries the same narrowing ("when the worktree cannot be created").

## Acceptance criteria

- [ ] Every 6b fallback that ends in an in-place pick with an upstream pushes `task/TASK-NNN`, or prints the **not-pushed** line, and says where the flip lives
- [ ] The spec requirement covers both fallbacks
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The worktree-add fallback, which TASK-254 already describes

## Human test plan

- [ ] On an upstream fixture with `workspace: worktree`, run `/tasks pick` from a `claude -p` runner, which cannot enter a worktree. Expected: the run falls back in place and `git ls-remote --heads origin task/TASK-NNN` shows the branch.

## Implementation plan

_Populated by `/tasks plan TASK-328` — leave empty until then._
