---
id: TASK-222
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
findings: [SH-6]
pr: null
github-issue: null
jira-key: null
---

# `new` and Jira import offer only P0–P2

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). `skills/tasks/verbs/new.md` step 5 asks for
"P0 / P1 / P2", and `import.md`'s Jira mapping maps the priority field to P0/P1/P2. Elsewhere the skill says the
opposite on purpose: the Collection pass buckets "one bucket per priority actually present" and warns that a
fixed set "silently drops any other value in use" (measured on this repo, which has P3 tasks), and `export`
handles `priority/<any value>`. So a P3 can be read and exported but never created or imported.

## Acceptance criteria

- [ ] `new` accepts any `P<n>` priority, offering the common ones without limiting to them
- [ ] Jira import maps priorities without collapsing anything below P2 into P2, and says what it does with a
      priority it cannot map
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Renumbering existing priorities

## Human test plan

N/A — a prompt's option list and a mapping table, checked by reading against the Collection pass and `export`.

## Implementation plan

_Populated by `/tasks plan TASK-222` — leave empty until then._
