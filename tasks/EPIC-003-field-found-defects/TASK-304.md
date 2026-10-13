---
id: TASK-304
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-296-2]
pr: null
github-issue: null
jira-key: null
---

# `pick` regenerates `tasks/README.md` on the default branch when the default branch has an upstream

## Context

Found by TASK-296's upstream-fixture drill (2026-10-13). An in-place `pick` (no `workspace:`) on a repo whose `main` tracks a remote ran step 8 and wrote `tasks/README.md`. The file was untracked, never committed, and stale once the task merged. `skills/tasks/verbs/close.md` step 10 rules that with an upstream nothing generated is written on the default branch, because the copy must mirror the remote. `pick` step 8 (`skills/tasks/verbs/pick.md`) has no such condition, and its step 6b already skips the regen in a worktree for the same reason.

## Acceptance criteria

- [ ] `pick` step 8 follows the same upstream rule as `close` step 10: with an upstream it writes no dashboard, and it prints the task's new status and the owning verb to run instead
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The worktree path, which already skips the regen

## Human test plan

N/A — one condition on one step, checked by reading `pick` step 8 against `close` step 10.

## Implementation plan

_Populated by `/tasks plan TASK-304` — leave empty until then._
