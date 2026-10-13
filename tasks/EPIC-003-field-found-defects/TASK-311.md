---
id: TASK-311
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-310-1, CR-310-2]
pr: null
github-issue: null
jira-key: null
---

# The "inferred, not chosen" mark reaches no reader through `/fix-next`, nor on an epic or story

## Context

Grouped: two gaps the correctness pass raised at TASK-310's close (2026-10-13). TASK-310 made `/tasks pick`
step 9 print the mark `new.md` § *Unanswered questions* writes. Two paths still never show it:

- **CR-310-1.** `/fix-next` marks its task in-progress itself (`skills/fix-next/SKILL.md` step 2) and never
  reaches `pick` step 9. A defect filed unattended, with an inferred parent and priority, is exactly what it
  drains, and it fixes and closes such a task without the guess ever being shown. It cannot ask, so it
  should report: the step 2 log line and the step 9 report name the inferred fields.
- **CR-310-2.** `pick` handles tasks only. A mark on an epic or story (`level`, `title`, `affects`) is shown
  once, at `new` step 13, and never again; `show.md` even hides an empty `affects:` list.

## Acceptance criteria

- [ ] `/fix-next` records a picked task's inferred fields in its Progress log and its final report
- [ ] A marked epic or story is surfaced by a reader (`show`, or `audit`)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The mark's wording ("inferred" for a fallback like `affects: []`; accepted at TASK-310)

## Human test plan

- [ ] A cold runner runs `/fix-next` on a fixture whose only defect carries the mark, then `show`s a
      marked epic. Expected: both reports name the inferred fields.

## Implementation plan

_Populated by `/tasks plan TASK-311` — leave empty until then._
