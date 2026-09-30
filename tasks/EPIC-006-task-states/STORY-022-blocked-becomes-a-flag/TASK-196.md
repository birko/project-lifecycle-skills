---
id: TASK-196
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: []
blocks: [TASK-197, TASK-198, TASK-199, TASK-200, TASK-201, TASK-202, TASK-203, TASK-204]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Expand: the `tasks` skill reads both the old and the new status forms

## Context

The expand phase of FEATURE-003's wide refactor (`skills/tasks/slicing.md` § *Wide refactors*). Nothing
writes the new form yet, and every reader outside `tasks` still reads the old one, so this change must
leave every gate green and every existing file read exactly as before.

The new vocabulary (FEATURE-003 D1, D4): statuses `todo`, `in-progress`, `verify`, `done`, `cancelled`,
and a `blocked:` frontmatter field holding the reason, absent when the task is not blocked. The old
values stay readable **permanently**, because copies in repos nobody migrates are out of reach:
`review` reads as `verify`, and `status: blocked` reads as "prior state unknown, blocked". A reader
treats it as `todo` plus the flag until the migration (TASK-203) settles the prior state.

## Acceptance criteria

- [ ] `skills/tasks/SKILL.md` § *Lifecycle* defines the new vocabulary and the permanent legacy reading once; every other file points there
- [ ] The Collection pass buckets both forms: `verify` and legacy `review` together, and a flagged task counted in its state and in a blocked count
- [ ] `triage`'s dashboard and its template show the blocked count as a flag count across states, and render a flagged task with its reason
- [ ] `pick`'s list, its 2b verification-debt line and `show` read both forms; `audit` accepts the `blocked:` field and flags a `blocked:` field on a `done`/`cancelled` task
- [ ] Nothing in this change writes the new form
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Every reader outside the `tasks` skill: TASK-197 to TASK-203
- Writing the new form: TASK-204

## Human test plan

- [ ] Cold drill on a fixture tree holding old-form and new-form tasks side by side: bare `/tasks` and `/tasks triage` count each state once, show the flagged task with its reason, and report a legacy `blocked` task as "to do, blocked".
