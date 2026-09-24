---
id: TASK-185
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: ai
created: 2026-09-24
depends-on: [TASK-184]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `FEATURE-NNN` minted in parallel worktrees can collide too

## Context

Found by TASK-184's review (2026-09-24). TASK-184 widened task and `FIELD-NNN` id allocation to take the max
over every copy of the tree: this tree, every local branch, and every other worktree. [[feature]] mints
`FEATURE-NNN` the old way, still with a glob over `docs/features/FEATURE-*/` in this tree only
(`skills/feature/SKILL.md` § ID generation, `skills/feature/verbs/new.md` step 1). So two features started
on parallel task branches or in parallel worktrees get the same number. It is rarer than the task case,
because features are usually born on the default branch, but the mechanism is identical.

## Acceptance criteria

- [x] `FEATURE-NNN` allocation takes its max over the same copies as [[tasks]] § ID generation, by pointing at that rule rather than restating it (the id pattern differs: a folder name, not an `id:` line).
- [x] Two features started in parallel worktrees get distinct numbers, drilled.

## Out of scope

- Task and `FIELD-NNN` ids — TASK-184.

## Human test plan

- [x] Two parallel worktrees each run `/feature new`. Expected: distinct `FEATURE-NNN`, and the second run's report names the first's uncommitted folder as a place it looked.

## Implementation plan

1. `feature/SKILL.md` § ID generation: take the max over the copies [[tasks]] § ID generation names, pointing at it for the forms. The branch scan reads the `id: FEATURE-NNN` line.
2. `feature/verbs/new.md` step 2: point at it, and name any unreadable copy in the confirmation.
3. Drill: two parallel worktrees each mint a feature id.

**Drill (2026-09-24).** The same shape as TASK-184's: a scratch repo with FEATURE-001 and two task worktrees. Two `claude -p` runners, one after the other, each ran `/feature new` steps 1–2 for "Export to CSV" inside its worktree. **Not cold on names**; this drills behaviour.
- **A** → FEATURE-002, uncommitted.
- **B** → **FEATURE-003**, having read A's uncommitted folder by path. Its report listed each copy with its highest id, and it flagged the likely duplicate on its own. The old glob-this-tree rule would have given both FEATURE-002.

**Close gate:** a two-line pointer change onto TASK-184's reviewed rule. Conventions checked inline: it points at [[tasks]] § ID generation and restates nothing, and the lint is OK. The drill is the fidelity check.
