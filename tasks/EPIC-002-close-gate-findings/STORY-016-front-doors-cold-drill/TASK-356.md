---
id: TASK-356
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-102-1, DRILL-102-2, DRILL-102-3, DRILL-102-4, DRILL-102-5, DRILL-102-6, DRILL-102-7]
pr: null
github-issue: null
jira-key: null
---

# `adopt-project`'s survey and report leave seven readings that several cold runners each settled differently

## Context

Filed 2026-11-13 from a cross-drill comparison. Six cold drills of `adopt-project` ran that day, each a fresh copy of
the `d065` fixture under `%LOCALAPPDATA%/Temp/`, with briefs and reports kept there:
- `d065b/scoped` and `d065b/full`, for TASK-065;
- `d353`, for TASK-353;
- `d354`, for TASK-354;
- `d102` and `d102b`, for TASK-102.

Each drill recorded its one-runner readings on its own task as "not filed". Compared across drills, these seven
were raised by **two or more runners independently**, the agreement bar FEATURE-002 D10 sets. They are a group
because all of them are about what the survey decides or where the report puts it, in
`skills/adopt-project/SKILL.md`, `INFER.md` and `skills/new-project/LAYER.md`.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-102-1 | `INFER.md` says to "record that they are empty pending a real decision" for Conventions subsections it could not infer, but not **where**. Writing it into the guide would amend it unasked, so every runner put it in the report only | d065b/full, d354, d102, d102b |
| DRILL-102-2 | `docs/architecture.md`'s row says "Leave it; report if absent". Nothing says whether that absence is `missing` or `missing, not offered` | d354, d102, d102b |
| DRILL-102-3 | the licence question and the guide-choice question have no stated wording, unlike the tasks questions. "Each in the words step 2 would use" has no words to point at | d065b/scoped, d353, d102b |
| DRILL-102-4 | the Dockerfile row: "a CLI shipped as a hosted container job is a Yes" against "run mode is settled by what the entry point does". Is a run-once script with no deploy evidence a derived No or `unknown`? | d065b/scoped, d353, d354 |
| DRILL-102-5 | step 1 detects facts that are not rows (stack, remote, ancestor repo, uncommitted state, kind). Only the `run:` line and the table have a stated place | d065b/scoped, d353 |
| DRILL-102-6 | a scoped run prints "one line per step that did not run". Whether 3b and 3c count as steps is unstated | d065b/scoped, d353 |
| DRILL-102-7 | the `.gitignore` row says to offer the lines. A scoped run writes nothing, and whether it still names the offer is unstated | d065b/scoped, d353 |

## Acceptance criteria

- [ ] DRILL-102-1 … 7 each have one stated answer, in the file that owns the rule (`LAYER.md` for a row's state,
      `adopt-project` for the run and its report, `INFER.md` for the inference round)
- [ ] Nothing that LAYER.md owns is restated in `adopt-project`; it is pointed at
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where questions and offers are put: TASK-102 (done)
- Pinning a test runner with no manifest: TASK-072
- The fill-side readings (regeneration, template fields, `docs/features/`, empty renders, the negation): TASK-357

## Human test plan

- [ ] Re-run the `d065b` scoped brief and the full brief, each on a fresh copy of `d065/adopted` (and `d065/fresh` for
      the scoped one) and of `skills/`, with a cold runner each. Expected: none of DRILL-102-1 … 7 in either
      "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-356` — leave empty until then._
