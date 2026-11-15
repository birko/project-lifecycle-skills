---
id: TASK-382
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-15
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-024-1, DRILL-024-2, DRILL-024-3]
pr: null
github-issue: null
jira-key: null
---

# Three re-adoption readings that both TASK-024 runners left undecided

## Context

Filed 2026-11-15 from TASK-024's two cold re-adoption runs of the d065b brief: `%LOCALAPPDATA%/Temp/d024` (over d378's
adopted output) and `%LOCALAPPDATA%/Temp/d024b` (over d024's committed output), each `report.md`. Both runs raised
each reading below, so each meets FEATURE-002 D10's two-runner bar. TASK-024's Outcome lists them as not yet filed.

| Id | Reading | Where |
|---|---|---|
| DRILL-024-1 | **A re-run that finds nothing "writes nothing at all"**, while `/tasks init` and `/feature status` rewrite their files' timestamps on every run. Whether a timestamp-only rewrite counts as a write, and whether the re-run should call those verbs at all when their rows are current | `skills/adopt-project/SKILL.md` (the re-run rule), `LAYER.md`'s rows for `tasks/README.md` and the features index |
| DRILL-024-2 | **The CI row's test-step rule** names a missing harness or one wired this run, not a harness present with no tests in it. Whether the CI step runs the runner, skips it, or reports it | `skills/new-project/LAYER.md`, the CI row |
| DRILL-024-3 | **Whether the test-harness row's terminating sentence counts as its verb answering**, for the verdict *complete*. The row ends "A repo with a working runner is already adopted — say so and move on", so `populate-tests` `adopt` is never asked, and AGENTS.md's owner-verb convention reads as if it should be | `LAYER.md`'s test-harness row, `adopt-project` step 3 |

## Acceptance criteria

- [ ] DRILL-024-1 … 3 each have one stated answer, in the file that owns the rule
- [ ] DRILL-024-3's answer says whether an adoption reaches `populate-tests` `adopt` once a runner exists, and the
      `AGENTS.md` owner-verb entry agrees with it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Everything TASK-024 decided (the four `/specs init` outcomes, the harness check by reading, the changelog left alone,
  the features index *regenerated*)
- TASK-379's five readings, from the same brief

## Human test plan

- [ ] Re-run the d065b brief on a fresh copy of an adopted fixture (not WorkoutTracker) with `skills/` at the fix and a
      cold runner, twice in succession. Expected: none of DRILL-024-1 … 3 in either run's "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-382` — leave empty until then._
