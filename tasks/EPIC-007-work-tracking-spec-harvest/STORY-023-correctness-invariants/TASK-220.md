---
id: TASK-220
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
findings: [SH-4, SH-5]
pr: null
github-issue: null
jira-key: null
---

# Two verbs leave a `blocked:` field behind that `audit` then reports

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). Both findings leave the same leftover: a
`blocked:` field nobody removes.

- **SH-4 — `cancel` keeps the field.** `skills/tasks/verbs/cancel.md` never mentions `blocked:`, so cancelling
  a blocked task writes `status: cancelled` beside its `blocked:` line — the contradiction
  `tasks/SKILL.md` § *Reading a task's status* says `audit` reports.
- **SH-5 — `audit --fix`'s "Unblock" does not unblock.** Its fix removes the satisfied id from `depends-on` and
  never clears the `blocked:` field, while `block.md`'s edge case says audit flags these as unblock candidates
  and the loop continues with `/tasks unblock`. One word, two meanings.

## Acceptance criteria

- [ ] Cancelling a blocked task removes its `blocked:` field (the reason survives in the body note), and says so
      in the confirmation
- [ ] `audit --fix`'s action either runs `unblock` — removing the field — or is renamed so it no longer claims to
      unblock; `block.md`'s edge case agrees with whichever it is
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `close`'s own blocked refusal — already built (TASK-214)

## Human test plan

- [ ] On an invented tree, cancel a blocked task and run `audit`: no `contradiction` row for it

## Implementation plan

_Populated by `/tasks plan TASK-220` — leave empty until then._
