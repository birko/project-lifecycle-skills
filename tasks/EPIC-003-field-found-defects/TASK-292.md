---
id: TASK-292
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-161-1]
pr: null
github-issue: null
jira-key: null
---

# An in-place `close` regenerates `tasks/README.md` after its own commit and leaves it uncommitted

## Context

Seen while running TASK-161's human test plan (2026-10-08). A real `/tasks close TASK-001 --unattended`
on a throwaway `single-branch` fixture (no worktree, no remote) parked the task at `verify`, committed the
work and the task file in `d819001`, and then left `?? tasks/README.md` behind. The runner's report quoted
the reason: the close only commits the dashboard for worktree closes.

That matches `skills/tasks/verbs/close.md`: step 10 regenerates the dashboard after step 7's commit (or after
step 5's `verify` park), and step 10b, which commits what 10–11 wrote, applies to "worktree closes with no
upstream only", with "In-place projects keep today's behaviour". Nothing says what that behaviour is. The
next `close`'s clean-tree checks, and [[fix-next]]'s *Verify the reset really is safe*, then meet a dirty
tree that no step owns.

Not yet established: whether the `done` path differs. This repo's own closes do carry `tasks/README.md` in
the task commit (for example `e9cc2c7`), so either the agent folds it in off-script or a step says so and the
fixture runner missed it. Find out first.

## Acceptance criteria

- [ ] `close.md` states, for an in-place project, which commit (if any) carries the regenerated dashboard and feature rollups, on both the `done` path and the `verify` park
- [ ] An in-place close on a `single-branch` fixture ends with `git status --short` clean, on both paths
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Worktree closes and closes with an upstream — step 10b and step 10 already define them

## Human test plan

- [ ] On a `single-branch` fixture, close one task to `done` and park another at `verify`. Expected: `git status --short` is empty after each.

## Implementation plan

_Populated by `/tasks plan TASK-292` — leave empty until then._
