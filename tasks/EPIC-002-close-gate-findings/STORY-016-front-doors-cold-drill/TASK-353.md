---
id: TASK-353
parent: STORY-016
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
findings: [DRILL-065-1, DRILL-065-2, DRILL-065-3]
pr: null
github-issue: null
jira-key: null
---

# `adopt-project`'s report has no stated place for a derived "not applicable", and two more readings are open

## Context

Spawned 2026-11-12 from TASK-065's Human test plan drill: one cold scoped survey of two invented repos
(`%LOCALAPPDATA%/Temp/d065`, report kept there as `report.md`). Raised by one runner. These predate TASK-065, which
did not touch them. A group: three readings in the survey and report.

- **DRILL-065-1 — the two files disagree on reporting a derived No.** `skills/new-project/LAYER.md` says `adopt-project`
  "has no `not applicable` entry in its per-state report list at all … a derived No is currently still silent".
  `adopt-project/SKILL.md` step 4 says "a state added there that no outcome bucket absorbs gets a bucket here named
  after it". The runner followed step 4 and printed a `not applicable` bucket. One of the two sentences is wrong.
- **DRILL-065-2 — an undeclared `workspace:` under `single-branch`.** LAYER.md says an absent `workspace:` is asked with
  `tasks init`'s question. `init` skips that question under `integration: single-branch`. Neither says what the survey
  row reports, an outstanding declaration or a settled one.
- **DRILL-065-3 — the closing next step on a repo with no `tasks/`.** Step 4 ends with `/tasks new` as a next step,
  printed on a repo where `tasks/` is `missing` and there is nothing for it to write into.

## Acceptance criteria

- [ ] LAYER.md and `adopt-project` step 4 agree on whether, and where, a derived `not applicable` is reported
- [ ] The survey states what an absent `workspace:` reports under `integration: single-branch`
- [ ] Step 4's next step fits a repo with no `tasks/`, or says why it does not need to
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Scoped runs and the run line — TASK-065

## Human test plan

- [ ] Re-run TASK-065's brief (`%LOCALAPPDATA%/Temp/d065/brief.txt`, fixture recipe on TASK-065) with a cold runner. Expected: none of DRILL-065-1 … 3 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-353` — leave empty until then._
