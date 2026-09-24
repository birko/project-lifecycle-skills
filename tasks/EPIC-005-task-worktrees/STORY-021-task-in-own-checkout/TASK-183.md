---
id: TASK-183
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

- [ ] A recorded decision on where in-progress state lives for a PR-based project, with the rejected options.
- [ ] `pick` step 6b and `close` steps 4b/8 support a default branch that tracks a remote under that decision, and D23's refusal is removed or narrowed.
- [ ] Drilled against a fixture with a bare remote, including two tasks merged remotely in either order.

## Out of scope

- Local-merge worktree mode — TASK-174/175/176.

## Human test plan

- [ ] On a consumer with a GitHub remote and a protected default branch: pick two tasks, merge both PRs on GitHub in either order, and close both. Expected: no divergence, no failed pull, and both worktrees removed.

## Implementation plan

_Populated by `/tasks plan TASK-183` — leave empty until then._
