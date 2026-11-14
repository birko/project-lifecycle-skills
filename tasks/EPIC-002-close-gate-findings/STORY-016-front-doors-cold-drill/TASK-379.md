---
id: TASK-379
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-378-1, DRILL-378-2, DRILL-378-3, DRILL-378-4, DRILL-378-5]
pr: null
github-issue: null
jira-key: null
---

# Five adoption readings that two or more cold runners left undecided

## Context

Filed 2026-11-14 by comparing the undecided sections of three cold runs of one brief: the d065b full `/adopt-project`
run on a fresh copy of `d065/adopted`, as `%LOCALAPPDATA%/Temp/d365`, `d269` and `d378` (each `report.md`, § 7). Each
reading below was raised by at least two of them, so each meets FEATURE-002 D10's two-runner bar. They were noted as
one-runner leftovers on TASK-365 and TASK-269 before the comparison showed the overlap.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-378-1 | **The fill item's granularity.** "one itemised offer naming each missing section": one letter per guide section, or one letter for all of them | d365, d269, d378 |
| DRILL-378-2 | **When the verdict line counts.** "Every run ends its report with one verdict line" does not say whether its counts are the survey's states or the states after the fill (7 missing against 2 on the same repo) | d269, d378 |
| DRILL-378-3 | **"A `tests/` package for pytest".** Whether it means creating `tests/__init__.py`; one runner did, one did not, and the harness table says "the test dir and the runner config only" | d365, d378 |
| DRILL-378-4 | **The drift note's reason wording.** `/feature status`'s drift note `<target> DV<x> <short reason>` fixes no reason text, so each runner wrote its own ("no spec map", "never generated") | d269, d378 |
| DRILL-378-5 | **Which rows "a verb creates".** TASK-365's form `missing — <verb> creates it in step 3` covers "every row whose cell names its creating verb", but `docs/features/`'s cell creates the folder by hand and only the index by `/feature status`, and the test harness's cell says "delegate", not "create" | d269, d378 |

## Acceptance criteria

- [ ] DRILL-378-1 … 5 each have one stated answer, in the file that owns the rule (`adopt-project`, `LAYER.md`,
      `populate-tests`, `feature` `status`, `roadmap`)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Single-runner readings from the same drills (`amended` defined by consent while `/tasks init` changes a file
  unasked; the re-run wording on a row that never existed): file them when a second runner raises them
- Everything TASK-365, TASK-269 and TASK-378 settled

## Human test plan

- [ ] Re-run the d065b brief (`%LOCALAPPDATA%/Temp/d378/brief.txt`) on a fresh copy of `d065/adopted` and of `skills/`
      at the fix, with a cold runner. Expected: none of DRILL-378-1 … 5 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-379` — leave empty until then._
