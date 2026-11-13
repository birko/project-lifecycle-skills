---
id: TASK-368
parent: STORY-011
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
findings: [DRILL-367-1]
pr: null
github-issue: null
jira-key: null
---

# `triage`'s tree never says what order a story's tasks are listed in

## Context

Filed 2026-11-13 at TASK-367's close. Two cold runners rendering `tasks/README.md` through `/tasks block` → `triage`
(`%LOCALAPPDATA%/Temp/d358` and `d367`, reports kept there) each noted that `triage` step 4 gives no order for the
tasks under a story. Both applied `SKILL.md` § *Collection pass*'s "Task order: one total order, used by every list
of tasks" (TASK-139) on their own. The rule covers the tree, but `triage` never points at it, so a reader has to
find it. Two runners meets FEATURE-002 D10's bar.

## Acceptance criteria

- [ ] `triage` step 4 states the order of epics, stories and tasks in the tree, by pointing at § *Collection pass*'s
      task order for tasks rather than restating it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The task order itself: TASK-139 (done)

## Human test plan

- [ ] Re-run TASK-212's brief on a fresh copy of `d212/repo` with `skills/` at the fix, using a cold runner. Expected:
      tree order is not in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-368` — leave empty until then._
