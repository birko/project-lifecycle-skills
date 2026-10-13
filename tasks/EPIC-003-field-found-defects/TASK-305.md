---
id: TASK-305
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-303-1]
pr: null
github-issue: null
jira-key: null
---

# `/feature review` parks tasks at `verify` and never regenerates `tasks/README.md`

## Context

Found by TASK-303's drill (2026-10-13). On a fixture with no upstream, `/feature review` parked TASK-001 `done → verify` and reopened STORY-001. It then committed `chore: review FEATURE-001` with `tasks/README.md` still showing TASK-001 `done` and STORY-001 `done (1/1)`. `skills/feature/verbs/review.md` step 5 chains `/feature status` for the feature rollup but nothing for the tasks dashboard, which `/tasks triage` owns. So every review that parks a task leaves the dashboard contradicting the task files it just committed.

## Acceptance criteria

- [ ] When `/feature review` parks a task or reopens a container, it regenerates `tasks/README.md` through `/tasks triage`, and step 5b commits it with the rest. With an upstream it follows `close` step 10's rule (no generated file on the default branch), so the dashboard goes on the record branch or is named
- [ ] `decide.md`'s surface-dependent revert does the same
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The reopening rule itself (TASK-303)

## Human test plan

- [ ] On a fixture with no upstream, run `/feature review` on a feature whose only task has an unbacked `N/A` plan. Expected: the review commit carries a `tasks/README.md` showing the task at `verify`.

## Implementation plan

_Populated by `/tasks plan TASK-305` — leave empty until then._
