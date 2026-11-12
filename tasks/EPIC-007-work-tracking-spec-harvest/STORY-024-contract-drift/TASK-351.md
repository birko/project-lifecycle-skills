---
id: TASK-351
parent: STORY-024
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
findings: [DRILL-240-4, DRILL-240-5, DRILL-240-6, DRILL-240-7]
pr: null
github-issue: null
jira-key: null
---

# `/feature status` in single-feature mode leaves four rendering details to the reader

## Context

Spawned 2026-11-12 from TASK-240's Human test plan drill (`%LOCALAPPDATA%/Temp/d240`, `report.md`). **Raised by one
runner only**, so each is a candidate to confirm, not a measured defect. A group: small readings from one run of
`skills/feature/verbs/status.md` in single-feature mode.

- **DRILL-240-4:** a single-feature run updates one index row and leaves the `_Generated <timestamp>_` header, which
  then dates a row it did not produce.
- **DRILL-240-5:** the collection pass finds divergences (DV5 here), but a single-feature run renders no drift note and
  `status.md` has no slot for one, so the finding is surfaced nowhere.
- **DRILL-240-6:** `{{TASK_LIST}}` and `{{TESTABLE_SUMMARY}}` have no wording for a feature with no tasks, and
  `{{TIMESTAMP}}` no format.
- **DRILL-240-7:** `{{NEXT_STEP}}` has examples only; `deciding` with a proposed row left has no stated wording.

## Acceptance criteria

- [ ] Each of DRILL-240-4 … 7 is either confirmed by a second cold runner and then answered in `status.md`, or recorded here as not reproduced
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Who writes the index row — TASK-240

## Human test plan

- [ ] Re-run TASK-240's brief on a fresh copy of its fixture with a cold runner. Expected: none of the confirmed findings in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-351` — leave empty until then._
