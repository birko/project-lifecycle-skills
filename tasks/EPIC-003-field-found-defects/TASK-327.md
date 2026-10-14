---
id: TASK-327
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
findings: [DRILL-298-1]
pr: null
github-issue: null
jira-key: null
---

# `/fix-next`'s empty-pool messages have no case for a backlog that has been fully drained

## Context

Found by TASK-298's cold drill (2026-10-14). Both runners reached an empty pool after the only task was cancelled. `skills/fix-next/SKILL.md` step 1 names two causes of an empty pool and an offer for each: *"No review has been filed"* and *"A review backlog exists but predates the stamp"*, plus a third, every pool task blocked. A review that was filed, stamped and fully worked off fits none of them. The runner said so: *"A review was filed and is now fully drained, so neither of step 1's 'empty pool' messages fits exactly."* So the run either invents a message, or picks one that tells the user to run a review or adopt an epic that is already stamped.

## Acceptance criteria

- [ ] Step 1 names the drained case (`kind: review-intake` epics exist, and no task in the pool is `todo` or blocked) with its own line, and offers nothing that would create scope
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The other three empty-pool causes, which are correct as written

## Human test plan

- [ ] On a fixture whose only review-intake epic has every task `done` or `cancelled`, run `/fix-next`. Expected: the run reports the backlog as drained and offers no review, adoption or intake.

## Implementation plan

_Populated by `/tasks plan TASK-327` — leave empty until then._
