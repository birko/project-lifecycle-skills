---
id: TASK-184
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
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

- [ ] Id allocation under `workspace: worktree` sees ids minted on every local task branch as well as the default branch (for example via `git grep` across `refs/heads`), or a recorded decision says why another mechanism is better.
- [ ] Two parallel worktrees each spawning a task get different ids, drilled.

## Out of scope

- Remote branches not fetched locally — TASK-183's territory.

## Human test plan

- [ ] Pick two tasks into worktrees, spawn a follow-up from inside each, and close both. Expected: two distinct ids and no add/add conflict.

## Implementation plan

_Populated by `/tasks plan TASK-184` — leave empty until then._
