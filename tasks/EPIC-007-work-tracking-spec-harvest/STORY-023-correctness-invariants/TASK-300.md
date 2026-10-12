---
id: TASK-300
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
findings: [FIELD-011]
pr: null
github-issue: null
jira-key: null
---

# A task exported to Jira shows the project's default priority in Jira's own priority field

## Context

Found while doing TASK-299 (2026-10-12). `skills/tasks/verbs/export.md` step 5 sends a task's priority to Jira
only as the label `priority/<value>` and leaves the ticket's priority field as the project sets it. TASK-299 made
`import --jira` read that label first, so the round trip now keeps the value. But anyone reading the ticket in
Jira sees the field: a P0 task exported to a project whose default is Medium shows as Medium there. A cold runner
in TASK-299's drill pointed this out.

Setting the field means mapping `P<n>` onto the project's priority scheme. `import.md`'s table maps Jira's
default scheme (Highest–Lowest to P0–P4) and a scheme already named `P<n>`. Export would need the inverse, plus a
rule for a scheme it cannot read or that has no matching value. That rule is the open part.

## Acceptance criteria

- [ ] `export --to jira` sets the ticket's priority field when the project's scheme has a value for the task's
      priority, by the inverse of `import.md`'s table, and states what it does when there is none
- [ ] The `priority/<value>` label is still sent, and import's label-first rule is unchanged
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The round trip itself, which TASK-299 fixed

## Human test plan

N/A — a mapping rule in a verb file, checked by reading it against `import.md`'s Jira table.

## Implementation plan

_Populated by `/tasks plan TASK-300` — leave empty until then._
