---
id: STORY-021
parent: EPIC-005
# status — one of: planned, in-progress, done, cancelled
status: in-progress
created: 2026-09-24
---

# Run a task in its own checkout

## User story

As a developer (or agent) working a task, I want `/tasks pick` to give the task its own folder
outside the repository, so that another task can run at the same time and the main copy stays on the
default branch and buildable.

## Behaviour

- `workspace: worktree` declared → `pick` creates a worktree under the declared `worktree-root:`,
  on `task/TASK-NNN`, and the session moves into it.
- `worktree-root:` not declared → `pick` asks, suggesting `../wt`; with no answer it writes nothing,
  cuts the branch in place as today, and reports `worktree-root undeclared`.
- The move is proved from `git rev-parse --show-toplevel`, never from the agent's own claim; a tool
  that cannot move, or a proof that fails, removes the worktree and falls back to the in-place branch,
  saying so.
- `close` merges by driving the main copy (`git -C <main-tree> merge --no-ff`), then leaves the
  worktree, removes it, and deletes the branch — in that order. A dirty main copy fails the close;
  a dirty worktree is reported, never force-removed.
- Nothing declared → byte-for-byte today's behaviour.

**Edge case that defines it.** A branch checked out in a worktree cannot be checked out in the main
copy. So a worktree the session never enters is not a harmless extra folder: the session keeps
editing the main copy on the default branch, under a policy that promised isolation. Every fallback
in this story exists to make that state impossible.
