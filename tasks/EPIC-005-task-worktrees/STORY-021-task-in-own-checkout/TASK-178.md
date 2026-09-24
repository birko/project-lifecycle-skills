---
id: TASK-178
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: ai
created: 2026-09-24
depends-on: [TASK-173]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Give drill checkouts a declared home and a cleanup rule

## Context

FEATURE-001 D10. `skills/populate-tests/SKILL.md` § *The cold drill* says a drill that must dirty the
tree *"runs on a clone or worktree"* and stops there — no location, no owner for deleting it. The same
`worktree-root:` declaration can serve drills too.

Replace the bare phrase with: where a drill's disposable checkout goes (under `worktree-root:` when
declared), what happens when nothing is declared (a path outside the target, never inside it), and who
removes it and when (the drill, at its end, via `git worktree remove` — reported, never forced, if
dirty). Keep the section's existing caveat that a clone drops uncommitted and untracked state; a
worktree has the same working-tree gap and needs the same warning.

## Acceptance criteria

- [ ] § *The cold drill* names the location for a drill checkout, with the undeclared case covered.
- [ ] It names the cleanup step and its owner; a dirty drill worktree is reported, not force-removed.
- [ ] The clone caveat still reads correctly and covers worktrees too.
- [ ] AGENTS.md § Testing, which points at that section, still points correctly (no copy added).

## Out of scope

- Automating drill setup.

## Human test plan

- [ ] A cold reader given only the revised section and a target repo with `worktree-root:` declared is asked where a dirtying drill's checkout goes and how it ends. Expected: under the declared root, removed at the end without `--force`. The brief withholds the expected answer (populate-tests § *The cold drill*).

## Implementation plan

_Populated by `/tasks plan TASK-178` — leave empty until then._
