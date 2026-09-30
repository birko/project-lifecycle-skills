---
id: TASK-196
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] `skills/tasks/SKILL.md` § *Lifecycle* defines the new vocabulary and the permanent legacy reading once; every other file points there
- [x] The Collection pass buckets both forms: `verify` and legacy `review` together, and a flagged task counted in its state and in a blocked count
- [x] `triage`'s dashboard and its template show the blocked count as a flag count across states, and render a flagged task with its reason
- [x] `pick`'s list, its 2b verification-debt line and `show` read both forms; `audit` accepts the `blocked:` field and flags a `blocked:` field on a `done`/`cancelled` task
- [x] Nothing in this change writes the new form
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Every reader outside the `tasks` skill: TASK-197 to TASK-203
- Writing the new form: TASK-204

## Human test plan

- [x] Cold drill on a fixture tree holding old-form and new-form tasks side by side: bare `/tasks` and `/tasks triage` count each state once, show the flagged task with its reason, and report a legacy `blocked` task as "to do, blocked".
  - **Run 2026-09-30, passed.** Fixture: `%TEMP%/d196`, a git repo with one story of six tasks: `todo`; `in-progress` + `blocked:`; `verify`; old `review`; old `status: blocked`; `todo` + `blocked:`. Runner: `claude -p --allowedTools "Bash(git:*)" "Bash(grep:*)" "Bash(ls:*)" Read Grep Glob Skill --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills < brief.txt`, run from the fixture. It had the installed skills, which a behaviour drill needs, and the brief was read-only and did not state the expected counts. Result: `todo 2 · in-progress 1 · review 2 · blocked 3 · done 0`. Next up held only the plain `todo` task. In review listed the `verify` and the old `review` task. The tree showed `⚠ blocked: <reason>` beside each flagged task's own state and a bare `⚠ blocked` on the old form, and the runner cited the new rule for every task. Three gaps it raised were fixed in place: the § *Lifecycle* table and the Collection pass disagreed on the old `status: blocked` (it now counts as blocked only, never guessed into a state); the `blocked` row overlaps other rows, and wherever counts are shown this is now said; a blocked in-progress task now carries its marker in the In progress lists.

## Implementation plan

Planned inline at pick (2026-09-30). One owner, the `tasks` skill's read side only: define the two forms once in § *Lifecycle*, then make the Collection pass, `triage` (counts, markers, In progress), `pick` (filters, 2b, the branch-copy line, the blocked edge case), `show` and `audit` point at it. `close` step 4 needed nothing, since it has no case for `review`. No writer changes.

## Progress log

- 2026-09-30 — Picked; STORY-022 and EPIC-006 rolled up to `in-progress`.
- 2026-09-30 — `SKILL.md` § *Lifecycle*: the table *Reading a task's status* covers two forms, both read permanently. The Collection pass buckets both, `triage` shows the blocked marker and reason, `pick` reads `verify` in 2b and the branch-copy line, `show` shows the reason, and `audit` gains a `contradiction` row. Lint OK.
- 2026-09-30 — Drill passed; three gaps fixed in place (record above).
- 2026-09-30 — Close review. **Standards:** pass. The vocabulary is defined once, and every other file points at it. The skill text cites no task id, since a TASK-204 pointer would name a different task in a consumer repo. **Intent:** pass, all 6 criteria met; nothing writes the new form. **Correctness:** pass. The old form is still read exactly as before: `review` stays in its bucket, and old `blocked` stays out of Next up. `close` step 4 accepts `verify` because it has no `review` case to miss. **Security:** not applicable. **Comments:** not applicable.
- 2026-09-30 — Out of scope, recorded rather than filed: the runner also noted small pre-existing layout gaps in the snapshot (list format, tree order, a `done: 0` line) that predate FEATURE-003, and the known commit-trailer conflict between the skill and a session attribution instruction. Neither is work for this story.
