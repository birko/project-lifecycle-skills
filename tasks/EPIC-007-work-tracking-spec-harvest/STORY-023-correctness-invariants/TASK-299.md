---
id: TASK-299
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-010]
pr: null
github-issue: null
jira-key: null
---

# `/tasks export --to jira` never says how a task's priority reaches the ticket

## Context

Found while doing TASK-222 (2026-10-12). `skills/tasks/verbs/export.md` step 5 builds the payload's labels,
`priority/<the task's priority value>` among them, and says what each label means on GitHub. For Jira, step 4
says only "Same for Jira", and the Jira bullets under step 5 cover issue types and the Flagged marker. Nothing
says whether a task's `priority:` becomes a Jira label, sets the Jira priority field, or is dropped.

TASK-222 gave `import --jira` a mapping from the Jira priority field: a `P<n>` name as given, Jira's default
scheme Highest–Lowest to P0–P4, and anything else to P1 with a record that nobody chose it. A task exported
and then imported back has no defined route through that table, so its priority can change on the round trip
with nothing showing it.

## Acceptance criteria

- [ ] `export --to jira` states where a task's `priority:` goes on the ticket, and what it does when the
      project's Jira priority scheme has no matching value
- [ ] The rule is the inverse of `import --jira`'s mapping, or `import.md` says why the two differ
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The GitHub side, which already sends `priority/<value>` for any value

## Human test plan

N/A — a mapping rule in a verb file, checked by reading it against `import.md`'s Jira mapping table.

## Implementation plan

_Populated by `/tasks plan TASK-299` — leave empty until then._
