---
id: TASK-317
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-013]
pr: null
github-issue: null
jira-key: null
---

# `move` and `new` never report an unlanded `record/<ID>` branch, though TASK-306 says every trigger does

## Context

Found by TASK-306's close review (2026-10-14). TASK-306 put the unlanded-record check into [[tasks]] SKILL.md § *Roll status up to parents*, and its Outcome says every trigger of the reopening rule now reports it: a `decide` revert, `close` reopening, `move`, `new`, and a review park. Only `skills/feature/verbs/review.md`'s park confirmation was told to relay the line.

- `skills/tasks/verbs/move.md` step 8 lists exactly what the report carries, and the `record/<ID> is unlanded …` line is not in it.
- `skills/tasks/verbs/new.md` step 10 reopens only when the parent reads `done` (or `cancelled` and chosen). Inside the unlanded-record window the parent reads `in-progress`, so step 10 never reaches the SKILL.md rule and never runs the check.

A verb file must be readable standalone, so a run that follows one of these verbs drops the line or skips the check.

## Acceptance criteria

- [ ] `move.md` step 8 and `new.md` step 13 report each `record/<ID> is unlanded …` line (and `not checked`) the reopening rule produces
- [ ] `new.md` runs the check whenever the default branch has an upstream, whatever the parent reads
- [ ] `decide.md`'s revert and `close`'s reopen relay the line too, or the task records that they already do
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The check itself, and the review park (TASK-306)

## Human test plan

- [ ] On an upstream fixture with `record/STORY-001` pushed and unlanded, `/tasks move` an open task into STORY-001 and `/tasks new task` under it. Expected: each report names the unlanded branch.

## Implementation plan

_Populated by `/tasks plan TASK-317` — leave empty until then._
