---
id: TASK-178
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] § *The cold drill* names the location for a drill checkout, with the undeclared case covered.
- [x] It names the cleanup step and its owner; a dirty drill worktree is reported, not force-removed.
- [x] The clone caveat still reads correctly and covers worktrees too.
- [x] AGENTS.md § Testing, which points at that section, still points correctly (no copy added).

## Out of scope

- Automating drill setup.

## Human test plan

- [x] A cold reader given only the revised section and a target repo with `worktree-root:` declared is asked where a dirtying drill's checkout goes and how it ends. Expected: under the declared root, removed at the end without `--force`. The brief withholds the expected answer (populate-tests § *The cold drill*).

## Implementation plan

A one-section edit, planned in the task's own Context (a single file, and the acceptance criteria name every part):
1. In `populate-tests` § *The cold drill*, after *Leave the target as you found it*, add *Where that checkout goes, and who removes it*:
   - declared root → `<worktree-root>/<repo-name>-drill-<label>`;
   - undeclared → the runner's scratch directory, never inside the target;
   - the drill removes it at its end, after nothing stands in it;
   - a dirty checkout is reported, never `--force`d.
2. Widen the clone caveat to worktrees.
3. Leave AGENTS.md's pointer untouched.

**Drill (2026-09-24) — cold, two readers.** Runner: `cd /c/Source/WebChecker && claude -p --disable-slash-commands < brief` (the cold-runner recipe: a repo with no agent guide, and the installed skill roster suppressed). **Coldness confirmed**: asked first, both reported *no skills listed at all* and nothing named `populate-tests`, `tasks` or `pick`. The brief held only the revised section (29 lines) and a target described with `worktree-root: ../wt` and a colleague's uncommitted work in the main copy. The expected answers were withheld.

**Both readers agreed on every point:**
- **Where:** `C:/Source/wt/Acme-drill-<label>`, via `git -C C:/Source/Acme worktree add "<path>" <commit>`, with the `-drill-` infix kept apart from task worktrees.
- **At the end:** make sure no runner or shell stands in it, then `git worktree remove`. If dirty, report it by path, leave it, and never `--force`. Record the path and whether it was removed.
- **Tell the reader:** it is a worktree from commit X, without the main copy's uncommitted or untracked files, so absences are inferences, not findings.

**One gap raised and fixed:** reader 2 resolved the relative root against the repo root *by elimination*, because the section did not say. It now states it.

**Close gate:** a one-section prose edit whose instrument is the drill above. Conventions reviewed inline: `AGENTS.md` § Testing still points at the section with no copy added, and the lint is OK. Comments: none in the diff. Security: not applicable.
