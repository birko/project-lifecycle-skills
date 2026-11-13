---
id: TASK-362
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-357-1, DRILL-357-2, DRILL-357-3, DRILL-357-4, DRILL-357-5]
pr: null
github-issue: null
jira-key: null
---

# Five more adoption readings that a second cold runner has now raised

## Context

Filed 2026-11-13 at TASK-357's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d357`, `report.md`, § 7)
against the session's other adoption drills under `%LOCALAPPDATA%/Temp/`. Each reading below was recorded as a
one-runner reading on an earlier task, and d357 raised it again, which meets FEATURE-002 D10's bar. They are a
group because each is a small gap in what a full adoption writes or reports.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-357-1 | INFER's UI / UX subsection: whether a program whose only output is `print` lines counts as "output formatted for a reader". Every runner fell back to "evidence that settles neither way → count it as applicable", and two flagged it as undecided | d356/f, d357 |
| DRILL-357-2 | `/specs init`'s "Offer the first harvest" comes up inside the delegation. Whether it is an offer "found after the round" (reported, not asked) is unstated, because adopt's exception names only `populate-tests`' `.gitignore` lines | d360, d357 |
| DRILL-357-3 | `.gitattributes` and `.editorconfig`: the row says "Create if absent" and gives no shape, owner or template, so each runner wrote its own content | d102b, d357 |
| DRILL-357-4 | the `tasks/` row's state in a **full** run's table, printed before `/tasks init` answers. `present, owner not asked` is scoped-only, so runners printed `present` with an ad-hoc note | d065b/full, d357 |
| DRILL-357-5 | `/specs init`'s unmapped files: "which of the three is a judgement" and "where that reconciliation needs the user, put this question" never say when the user is needed. Runners sent the docs, `tasks/` and `*.md` to `ignore` without asking. Asking, with no answer, would leave them unmapped and change what `verify` reports (added at TASK-361's close) | d356/f, d361 |

## Acceptance criteria

- [ ] DRILL-357-1 … 5 each have one stated answer, in the file that owns the rule (`INFER.md`, `adopt-project`,
      `LAYER.md`)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The specs scan set and adoption's own files: TASK-361
- Everything TASK-356 and TASK-357 settled

## Human test plan

- [ ] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      none of DRILL-357-1 … 5 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-362` — leave empty until then._
