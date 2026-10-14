---
id: TASK-320
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-016]
pr: null
github-issue: null
jira-key: null
---

# Two cold runners disagreed on whether `/feature status` creates the features index when it is absent

## Context

Found by the TASK-306 and TASK-307 drills (2026-10-14), run on the same fixture shape on the same day. Both reached `/feature status FEATURE-001` with no `docs/features/README.md`. The TASK-306 runner did not create it; the TASK-307 runner did. Both quoted the same sentence as the gap: *"Single-feature runs update only that feature's `status.md` and **its row** in the index, not the whole file."* Nothing says what a single-feature run does when there is no index to hold the row. Two runs of one verb produced different trees.

## Acceptance criteria

- [ ] `skills/feature/verbs/status.md` states what a single-feature run does when the index does not exist
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The index's shape

## Human test plan

- [ ] Two cold runners each run `/feature status FEATURE-001` on a fixture with no `docs/features/README.md`. Expected: both leave the same tree.

## Implementation plan

_Populated by `/tasks plan TASK-320` — leave empty until then._
