---
id: TASK-221
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-3, SH-12]
pr: null
github-issue: null
jira-key: null
---

# `cancel` and container close disagree about cancelled work

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). Both findings are about what cancelled work
means for its container and for a revival.

- **SH-12 — a story of only cancelled tasks closes `done`.** `close --story` (and `--epic`) checks every child is
  `done` or `cancelled` and then always flips the container to `done`. `skills/tasks/verbs/cancel.md` says a story
  whose children are all cancelled is itself `cancelled`. Two verbs, two answers for the same tree.
- **SH-3 — reviving cancelled work is a hand edit.** `cancel.md`'s revival edge case says to `/tasks pick` "after
  manually flipping it back", while `tasks/SKILL.md` § Lifecycle says every status has a verb and none requires
  hand-editing frontmatter.

## Acceptance criteria

- [ ] A container whose children are all `cancelled` gets one answer from both `close` and `cancel`, stated in both
- [ ] Reviving a cancelled task goes through a verb (an existing one, or a stated new path) — no hand edit of
      `status:`; `SKILL.md`'s "every status has a verb" stays true
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- What a mixed done/cancelled container is — already `done` in both

## Human test plan

- [ ] On an invented tree, close a story whose only task is cancelled: the result matches what `cancel` says

## Implementation plan

_Populated by `/tasks plan TASK-221` — leave empty until then._
