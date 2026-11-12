---
id: TASK-348
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-332-1, DRILL-332-2, DRILL-332-3, DRILL-332-4, DRILL-332-5, DRILL-332-6]
pr: null
github-issue: null
jira-key: null
---

# `/tasks block`'s confirmation and the dashboard it chains leave six readings open

## Context

Spawned 2026-11-12 from TASK-332's Human test plan drill. One cold run of TASK-212's brief (`/tasks block TASK-002`,
no flags) was made on a fresh fixture, `%LOCALAPPDATA%/Temp/d332` (report kept there as `report.md`). **Raised by one
runner only**, so each is a candidate to confirm, not a measured defect (FEATURE-002 D10's bar is two). It is a group:
the readings are small and share one drill.

In `skills/tasks/verbs/block.md`:
- **DRILL-332-1:** step 3b's fallback says "say so in step 7: `blocked: reason unknown added (no reason given, nobody chose one) …`", while step 7 prints `blocked: <reason> added — status stays <state>`. Replace or add is unstated. The runner replaced.
- **DRILL-332-2:** step 7's "any `depends-on` added" does not say whether to print that none was.
- **DRILL-332-3:** `block` says nothing about committing. `cancel` and `block` do not commit (as `/fix-next` § *A run that ends without a fix* states), but `block` itself never says so.

In `skills/tasks/verbs/triage.md`, reached through the chained dashboard:
- **DRILL-332-4:** the `blocked` row's overlap note ("1 also counted in their own state") has no slot in the template's `{{TK_BLOCKED}}` cell. The runner put it inside the cell.
- **DRILL-332-5:** whether a blocked `todo` task counts in the "`todo` by priority" line. Taken tasks are excluded explicitly; blocked ones are not mentioned.
- **DRILL-332-6:** step 2 gives `—` for pairs that don't apply, but no value for an applicable pair with no items (`0` or blank).

## Acceptance criteria

- [ ] Each of DRILL-332-1 … 6 is either confirmed by a second cold runner and then answered in the verb that owns it, or recorded here as not reproduced
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where `blocked:` and its note go, and the reason's order — TASK-332

## Human test plan

- [ ] Re-run TASK-212's brief on a fresh fixture of its shape (recipe on TASK-212, fixture source `%LOCALAPPDATA%/Temp/d212/repo`) with a cold runner. Expected: none of the confirmed findings in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-348` — leave empty until then._
