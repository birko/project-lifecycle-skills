---
id: EPIC-005
# status — one of: planned, in-progress, done, cancelled
status: planned
created: 2026-09-24
owner: František Bereň
affects: skills/tasks, skills/new-project, skills/adopt-project, skills/populate-tests, AGENTS.md
---

# Task worktrees

## Area of concern

Where a task's work physically happens. Today [[tasks]] gives a task a **branch** and nothing else:
`pick` cuts `task/TASK-NNN` in the one working copy, `close` merges it. That leaves one task in
flight at a time, no clean copy of the default branch while work is under way, and drills improvising
"a clone or worktree" with no declared location and no owner for the cleanup.

This epic lets a project declare that each task runs in its own git worktree, outside the
repository, and makes `pick` / `close` create, enter, prove, merge and remove it. Decisions and
rationale: `docs/features/FEATURE-001-task-worktrees/`.

**Out of scope at the epic level:** worktrees inside the repository (FEATURE-001 D5a, removed);
tooling for reviewing someone else's branch; orchestrating several tasks in parallel; any change to
`integration:`.

## Success criteria

- A project that declares `workspace: worktree` gets a worktree per task from `/tasks pick`, and
  `/tasks close` merges it and removes it, leaving the main copy on the default branch throughout.
- A project that declares nothing behaves exactly as it does today.
- No run ever mints `worktree-root:` from its own suggestion, and no run leaves the work landing on
  the default branch because it created a worktree it could not enter.
- Both front doors carry the new declarations in the same change.

## Requirement → feature matrix

| Req | Brief quote (abridged, from docs/BRIEF.md) | Feature | Story |
|-----|--------------------------------------------|---------|-------|
| R1 | _"in our skills we have rule to create branch and merge after its finnished how about git worktree support?"_ | FEATURE-001 | STORY-021 |
| R2 | _"i am afrarid that repo/wt could polute the repository accidentaly so a specified path if no path is declared ask for one fisrt or suggest one"_ | FEATURE-001 | STORY-021 |
