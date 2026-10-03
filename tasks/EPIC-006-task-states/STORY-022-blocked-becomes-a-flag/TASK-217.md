---
id: TASK-217
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-142]
pr: null
github-issue: null
jira-key: null
---

# `/tasks migrate` never exports a task awaiting verification

## Context

Found by the correctness pass at TASK-213's close (2026-10-03). `skills/tasks/verbs/migrate.md` step 1 selects
"All TASKS with status ∈ {`todo`, `in-progress`, `blocked`}". That set predates FEATURE-003: `blocked` is no longer
a status (a blocked task keeps its own state and carries a `blocked:` field), and `verify` — or the old `review` —
is not in it at all. So a project moving to hybrid mode silently leaves every task awaiting verification out of
its tracker, and a task blocked in the new form is exported only if its own state happens to be in the set.
FEATURE-003 D4 says readers accept both forms; this reader drops one of them entirely.

## Acceptance criteria

- [x] `migrate` selects open tasks by state per [[tasks]] § *Reading a task's status* — `todo`, `in-progress`,
      `verify` (and the old `review`), plus an old-form `status: blocked` — independent of whether the task
      carries a `blocked:` field
- [x] A blocked task in any of those states is exported with its marker, as `export` step 5 already does
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `export`'s own behaviour — already reads both forms
- Deferred to TASK-218 — `migrate`'s dry-run scope, its confirmation question, its milestone linking and its hand-off to `export`'s mode check, found by this drill

## Human test plan

- [x] A cold run of `/tasks migrate` against an invented tree, with the tracker calls replaced by a printed plan:
      the plan lists a `verify` task, an old-form `review` task and a blocked `in-progress` task, and no
      `done` or `cancelled` one

## Implementation plan

_Drafted at pick, 2026-10-03; one line, grill skipped._

1. `migrate.md` step 3: select open tasks by state per [[tasks]] § *Reading a task's status* (`todo`, `in-progress`, `verify`/`review`, old-form `status: blocked`), independent of the `blocked:` field; blocked ones keep `export`'s marker.
2. Lint; drill with `--dry-run` (the verb's own no-push mode) on an invented tree holding one task of each state, two cold runners, `gh` not allowed.

## Progress log

- 2026-10-03 — Picked (in place; single-branch). `migrate.md` step 3 now selects every task not `done` or `cancelled`, reading both status forms per `tasks/SKILL.md` § *Reading a task's status*, independent of the `blocked:` field; blocked ones keep `export`'s marker. Lint OK.
- 2026-10-03 — Drill: invented tree `%TEMP%\d217base` (one task per state: todo, in-progress + `blocked:`, verify, old `review`, old `status: blocked`, done, cancelled), oracle first; two cold runners of `migrate --to github --repo example-org/shop --dry-run`, `gh` not allowed. **Both match the oracle and agree**: TASK-001…005 listed, 002 and 005 with the blocked marker, 006 and 007 left out, no file changed (cold: no skills listed). After the drill I replaced my explicit state list with "every task that is not `done` or `cancelled`" plus the pointer — the standards rule against restating a list that can grow; the selected set is unchanged. Spawned: TASK-218 — four older `migrate` gaps both runners or one raised (DRILL-217-1…4). Review (inline, one line): **standards** — pointer, not a restated list; **intent** — 3/3 criteria met; **correctness** — the selected set equals the open set by construction; **security / comments** — not applicable. Closed `done`.
