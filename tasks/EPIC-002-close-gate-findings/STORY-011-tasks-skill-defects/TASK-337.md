---
id: TASK-337
parent: STORY-011
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
findings: [DRILL-182-1, DRILL-182-2, DRILL-182-3]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` on a bare id leaves debt surfacing and plan age unclear, and 9b's offer says "1 steps"

## Context

Found by TASK-182's two-runner drill (2026-11-04, recorded on TASK-182). Both runners raised all three, in `skills/tasks/verbs/pick.md`:

- **DRILL-182-1:** step 2 says a bare id jumps "to step 5 — after step 3's taken check". Read literally, that skips step 2b's verification-debt surfacing, yet 9b's contract table lists 2b among the asks that came before.
- **DRILL-182-2:** step 6 says to note a plan's age and flag one that predates changes to the code it references. A plan carries no date, and nothing says where its date comes from, or what to do when the paths it names do not exist.
- **DRILL-182-3:** 9b's offer template renders "Ends at verify: 1 manual test steps".

## Acceptance criteria

- [ ] Step 2 says whether 2b runs on a bare-id pick
- [ ] Step 6 names the source of a plan's date and the reading when its referenced paths are absent
- [ ] 9b's offer reads correctly for one step
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [ ] Re-run TASK-182's drill brief (on its Progress log) with one cold runner. Expected: none of the three appears in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-337` — leave empty until then._
