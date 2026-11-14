---
id: TASK-368
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
picked-by: fix-next
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

- [x] `triage` step 4 states the order of epics, stories and tasks in the tree, by pointing at § *Collection pass*'s
      task order for tasks rather than restating it
- [x] Step 4 gives tasks parented directly to an epic one stated place, and one story-line form for every story state
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The task order itself: TASK-139 (done)

## Human test plan

- [x] Re-run TASK-212's brief on a fresh copy of `d212/repo` with `skills/` at the fix, using a cold runner. Expected:
      tree order is not in its "left undecided" section

**Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d368`: five `/tasks triage` runs (`claude -p
--disable-slash-commands`, each runner listing no skills) on a clone of this repo, each over the previous one's
output.
- **Runs 1 and 2** (the first fix): trees identical but for TASK-145, a cancelled task with a feature tag, the tag
  inside the strike in one and outside in the other. Both counted cancelled tasks in a total, so a finished story
  would read `done (5/8 done)`. Both fixed: the tag goes after the strike, and cancelled tasks count in neither number.
- **Run 3** found a defect in this task's own step-6 rewording: "stay in the tree, in step 4's story-line form" read
  as the line alone, and it dropped every done story's tasks. It also varied the Completed wrapper, which all three
  runs had named undecided. Both fixed: done stories keep their tasks, and the wrapper is stated.
- **Runs 4 and 5:** run 4 restored the tasks and wrote `<summary>Completed (4 epics)</summary>`; **run 5 differed
  from run 4 only in the timestamp.**

## Implementation plan

Inline: one block in `triage.md` step 4 fixing order, the epic-level line and the story-line form; step 6 pointed at it.

## Outcome

**The fix (`skills/tasks/verbs/triage.md`).** Step 4 now fixes what two runs used to choose differently:
- **order:** epics and stories by id, and tasks by the Collection pass's task order (pointed at);
- **tasks parented to an epic:** one `(epic level) — <d>/<t> done` line after its stories;
- **one story-line form:** `— <state> (<d>/<t> done)`, with `todo` shown as `planned`, and cancelled tasks counted
  in neither number, so a finished story reads `n/n`;
- **a cancelled task:** no checkbox, and anything after its title goes after the closing `~~`;
- **step 6:** done stories keep their tasks; the Completed section is one `<details>` block, `Completed (<n> epics)`.

**Step-6 split.** Text: the step-4 block is absent at HEAD and present at the fix. Behavioural: d368, whose last two
runs differ only in the timestamp, against d375's pair (before the fix), which split on all three of this task's
points.

**Judgement calls.**
- **`(epic level)` over a flat list.** It was the form this repo's dashboards used before d375, and it keeps every
  child of an epic a story-shaped line.
- **Cancelled tasks out of the story counts.** `/feature status` still counts them in its feature totals
  (TASK-373, DRILL-371-1), so TASK-373 should take the same rule or say why not; noted there.
- **Two fixes widened this task**, both found by its own drill and both about the tree it owns: the cancelled-task line
  and the Completed wrapper. Three other recurring readings sit outside the tree and are filed as TASK-376.

**Close gate (inline, one skill file plus one spec):**
- **Standards:** the task order is pointed at, not restated.
- **Intent:** all three criteria met.
- **Correctness:** found and fixed by d368 run 3.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

**Flagged.** TASK-376, filed: the verification heading, the Loose section's contents, and the summary line with only
accepted drift.

## Progress log

- step 2 — picked; ranked above TASK-268 and 269 (P2) on keys 1, 3 and 4: those are cross-skill refactors with no wrong output, while this one makes the committed dashboard non-reproducible (d375's two runs differed on all three of its points, silently) and is fixable in `triage.md` alone
- step 3 — verified: `triage.md` step 4 names no order, no slot for a task parented to an epic, and two story-line forms (`(2/3 done)` and `(0/2)`); d375's two runs split on all three
- step 3b — planned inline: one block in step 4 fixing order (epics and stories by id, tasks by the Collection pass's task order, pointed at), the `(epic level)` line, and one story-line form; step 6's `(done)` suffix points at it
- step 4 — layer: local (triage.md)
- step 5 — fix in skills/tasks/verbs/triage.md (step 4, step 6)
- step 6 — behavioural: d368 runs 1-5; run 3 found the step-6 rewording defect, fixed; runs 4 and 5 identical but for the timestamp. Text: the step-4 block 0 → 1
- step 7 — respecced work-tracking (the dashboard requirement states the tree's order, epic-level line, story-line form, cancelled rule and Completed wrapper, with a two-runs scenario), restamped
- step 8 — closed inline; commit in git log
