---
id: TASK-333
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-327-1, DRILL-327-2]
pr: null
github-issue: null
jira-key: null
---

# `/fix-next`'s empty-pool branch miscounts its cases and leaves the final report undefined

## Context

Found by TASK-327's cold drill (2026-11-04, recorded on TASK-327), in `skills/fix-next/SKILL.md` step 1:

- **DRILL-327-1:** "Two causes, two different offers:" heads four bullets. The drained case's fixed line says "every filed finding is closed or awaiting verification" even when nothing awaits verification.
- **DRILL-327-2:** "Empty pool → say so and stop" leaves open whether step 9's report runs. Step 9 says "Either way, name the next pick", and § *Verify the reset really is safe* is part of it.

## Acceptance criteria

- [ ] The lead-in matches the number of empty-pool cases, or names none
- [ ] The drained line names awaiting-verification tasks only when there are some
- [ ] Step 1 says whether step 9's report runs after an empty-pool stop, and what it contains
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [ ] Re-run the originating drill's brief (recorded on that task's Progress log) on a freshly built fixture with a cold runner. Expected: its "left undecided" section no longer lists these findings

## Implementation plan

_Populated by `/tasks plan TASK-333` — leave empty until then._
