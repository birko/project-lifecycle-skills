---
id: TASK-326
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-324-1]
pr: null
github-issue: null
jira-key: null
---

# `close`'s "reopen and re-close" never says what reopening resets, so a re-close over a ticked plan goes straight back to `done`

## Context

Found by TASK-324's cold drill (2026-10-14). Both runners raised it independently. `skills/tasks/verbs/close.md` step 4 says only *"Already `done` → warn, ask "reopen and re-close?" or abort."* Nothing says what reopening writes, or whether it resets the Human test plan. Step 5 asks *"Did you run "<step>"?"* only for steps that *"are not run"*, and a `[x]` step reads as passed. So by the letter, a re-close of a `done` task whose steps are all ticked goes straight back to `done`, and the user's fresh result (often the reason for reopening) is never asked for. Both runners worked around it by treating the user's report as a re-run. SKILL.md's *"Reopening resets the plan"* rule covers a feature change landing on a closed feature, not this case.

This is also the only path into TASK-324's park rollup, so as written that rollup is reachable only when a step already reads unrun.

## Acceptance criteria

- [ ] `close.md` step 4 says what "reopen and re-close" changes before step 5 runs: which test-plan steps it resets to not run, if any, and why
- [ ] A re-close in which the user reports a fresh failure reaches step 5's failed case by the text, not by inference
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The park rollup itself (TASK-324)

## Human test plan

- [ ] Re-close a `done` task whose plan is ticked and say the step now fails. Expected: the run asks about the step, records the failure, and parks at `verify`, with no inference needed.

## Implementation plan

_Populated by `/tasks plan TASK-326` — leave empty until then._
