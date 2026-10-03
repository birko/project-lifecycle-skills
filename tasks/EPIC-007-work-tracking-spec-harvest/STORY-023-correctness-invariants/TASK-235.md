---
id: TASK-235
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
findings: [SH-42]
pr: null
github-issue: null
jira-key: null
---

# `/feature review` closes open tasks after a gate that stops on open tasks

## Context

Found by the feature-lifecycle spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-42.** `skills/feature/verbs/review.md` step 5, "All three gates pass": "suggest closing any still-open tasks via
  `/tasks close`". Gate A (step 2) already stops when any linked task is not `done`, and the edge case *Some tasks
  still open / unmerged* repeats that. So either the suggestion is unreachable, or Gate A lets some tasks through
  that are not `done`. The likely candidates are tasks at `verify`, which step 5's third bullet parks there on
  purpose. The verb does not say which.

## Acceptance criteria

- [ ] Gate A states whether a `verify` task (either form, per [[tasks]] § *Reading a task's status*) passes
      completeness
- [ ] Step 5 suggests closing tasks only if Gate A can let one through, and names which ones
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Gate B's handling of unchecked test plans

## Human test plan

N/A — reconciling two statements in one verb, checked by reading Gate A, step 5 and the edge case together.

## Implementation plan

_Populated by `/tasks plan TASK-235` — leave empty until then._
