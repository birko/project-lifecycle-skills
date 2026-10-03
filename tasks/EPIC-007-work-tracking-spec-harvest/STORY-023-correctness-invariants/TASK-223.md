---
id: TASK-223
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
findings: [SH-11]
pr: null
github-issue: null
jira-key: null
---

# A taken task is "shown as in progress", but no index says where it is counted

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). `tasks/SKILL.md` § Collection pass says a
`todo` task whose `task/TASK-NNN` branch exists elsewhere is **taken**: "count it and show it as in progress, and
never offer it as next work". But `inProgressTasks[]` is defined as `status: in-progress` only, and the counts
bucket by the file's `status:`. So the snapshot's `in-progress` count and "In progress" list either omit a taken
task, contradicting the sentence, or include it with nothing saying how — two runs can render it differently.

## Acceptance criteria

- [ ] The Collection pass states which index and which count a taken task lands in, and the snapshot and
      `triage` render it the same way (for example, listed under "In progress" with its owning branch)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- How a task becomes taken — `pick`'s own rules

## Human test plan

- [ ] On an invented tree with a `todo` task whose branch exists, the bare `/tasks` snapshot shows it once, as
      the Collection pass says, and not under "Next up"

## Implementation plan

_Populated by `/tasks plan TASK-223` — leave empty until then._
