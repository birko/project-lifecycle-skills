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
findings: [DRILL-367-1, DRILL-375-1, DRILL-375-2]
pr: null
github-issue: null
jira-key: null
---

# `triage`'s tree never says what order a story's tasks are listed in, where storyless tasks go, or how a story line reads

## Context

Filed 2026-11-13 at TASK-367's close. Two cold runners rendering `tasks/README.md` through `/tasks block` → `triage`
(`%LOCALAPPDATA%/Temp/d358` and `d367`, reports kept there) each noted that `triage` step 4 gives no order for the
tasks under a story. Both applied `SKILL.md` § *Collection pass*'s "Task order: one total order, used by every list
of tasks" (TASK-139) on their own. The rule covers the tree, but `triage` never points at it, so a reader has to
find it. Two runners meets FEATURE-002 D10's bar.

**Added 2026-11-14 from the dashboard refresh (`%LOCALAPPDATA%/Temp/d375`, `report-run1.md` and `report-run2.md`).**
The two runs agreed on every count and diverged on layout, each naming these as undecided:
- **DRILL-375-1 — tasks with no story.** Step 4's "group tasks under their parent story under their parent epic" has
  no slot for a task parented to an epic. Run 1 kept an `(epic level) — n/m done` group; run 2 listed them flat at
  story indentation after the stories (run 1 point 2, run 2 point 12).
- **DRILL-375-2 — the story line.** The example `— in-progress (2/3 done)`, the planned example `(0/2)` and the
  `(done)` suffix leave a planned story with done tasks open. Run 1 wrote `planned (17/21 done)`, run 2
  `planned (17/21)` (run 1 point 4, run 2 point 11).

## Acceptance criteria

- [ ] `triage` step 4 states the order of epics, stories and tasks in the tree, by pointing at § *Collection pass*'s
      task order for tasks rather than restating it
- [ ] Step 4 gives tasks parented directly to an epic one stated place, and one story-line form for every story state
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The task order itself: TASK-139 (done)

## Human test plan

- [ ] Re-run TASK-212's brief on a fresh copy of `d212/repo` with `skills/` at the fix, using a cold runner. Expected:
      tree order is not in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-368` — leave empty until then._
