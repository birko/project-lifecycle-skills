---
id: TASK-255
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-194-1, DRILL-194-2, DRILL-194-3, DRILL-194-4, DRILL-194-5]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `pick`'s list output leaves five rendering details for each reader to settle

## Context

Found by TASK-194's two cold drills (2026-10-04). In each, a runner rendered bare `/tasks pick` on a fixture with an
upstream, a task in progress in a worktree here, one parked at `verify`, one taken by another clone and one free.
**Both runners raised each of these five, independently.** Each chose a reasonable reading, so none produced a wrong
result on that fixture, but two runners having to settle the same five questions means the text leaves them open.
All five are in `skills/tasks/verbs/pick.md`.

- **DRILL-194-1 — the debt line for one task.** Step 2b's table row is "1–2 | one line — `⚠ 2 in review awaiting
  sign-off: TASK-046, TASK-048`". It only shows the count of two, so each runner improvised `⚠ 1 in review …`.
- **DRILL-194-2 — `remote/<name>`** in `taken (hidden): TASK-NNN (<local | remote/<name>>)`. Is `<name>` the remote's
  name (`origin`) or the remote ref?
- **DRILL-194-3 — where the in-progress line goes.** The taken line is printed "under the list", while the
  "in progress on this machine" line is only "printed apart".
- **DRILL-194-4 — the "multiple in-progress by same assignee" warning** (Edge cases). It does not say whether a
  generic `assignee: ai` counts, whether a task in progress only on its branch counts, or whether a task taken by
  another clone, which the Collection pass "shows as in progress", counts.
- **DRILL-194-5 — one report line or two.** Step 6b's report lines are "one per outcome, never a shared line for two".
  A successful worktree pick with an upstream meets both the *in a worktree* and the *upstream* outcomes, and the text
  does not say whether both print.

## Acceptance criteria

- [x] Each of the five has one stated answer in `pick.md`, and none is restated elsewhere
- [x] A re-run of TASK-194's drill brief on its fixture shape lists none of the five as a two-way reading
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The two points TASK-194 settled: the taken-list exclusions and the `gh` gating

## Human test plan

- [x] Re-run TASK-194's brief (recorded on that task) on a freshly built fixture of the same shape, with a cold runner. Expected: its "read two ways" section lists none of DRILL-194-1 … 5
  - **Passed 2026-11-05:** a fixture of TASK-194's shape, built in `%LOCALAPPDATA%/Temp/d255`: `main` tracking a bare `remote.git` (absolute URL, so pushes from a worktree resolve); `workspace: worktree`, `worktree-root: ../wt`; TASK-011 in progress in its worktree and pushed; TASK-012 at `verify` in its worktree and pushed; TASK-014's branch on the remote only; TASK-013 free, with `github-issue: 42`; skill `tasks` copied after this fix. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep < brief.txt`. TASK-194's brief, re-stated: read-only, no fetch, render bare `/tasks pick` quoting the sentence placing each task, describe step 9's hand-off for TASK-013, and list every two-way reading. It rendered `⚠ verification debt: 1 at verify awaiting sign-off: TASK-012`, then the in-progress line for TASK-011, the list (TASK-013), and `taken (hidden): TASK-014 (remote/origin)` under it, each quoted from the new text. The warning counted TASK-011 and not the taken TASK-014. None of DRILL-194-1…5 is in its two-way list. Its literal "1 tasks" from the new warning text was fixed before close. Coldness: it listed no skills

## Outcome

**What was fixed.** Five readings two cold runners each had to settle in `/tasks pick`'s list output now have one stated answer each, all in pick.md:
- the debt line is a template with a count and ids, shown for one task and for two;
- `remote/<name>` is the remote's name (`origin`), with `local` winning when both exist;
- the in-progress-here line goes before the list, and the taken line on one line under it;
- the multiple-in-progress warning counts tasks in progress here by assignee (`agent`, `unassigned` and `ai` as one), never a taken task;
- a 6b run meeting two outcomes prints both lines, in the order reached.

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill, which passed.

**Judgement calls.**
- **The in-progress line goes before the list,** because started work is offered before new work, as debt is. No drill record had settled it.
- **The warning's scope defers to the Collection pass and step 9's assignee grouping,** rather than listing either.

**Review (close step 5b, inline).** Adherence: nothing is restated outside pick.md (checked by grep). Fidelity: all three criteria are met. Correctness: the new warning's plural was fixed from what the drill printed.

**Flagged, not fixed** (the runner's other readings, older text): filed as TASK-346.

## Implementation plan

### The five answers, all in pick.md
1. **The debt line is a template:** `⚠ verification debt: <n> at verify awaiting sign-off: <ids>`, with one-task and two-task examples.
2. **`remote/<name>`:** `<name>` is the remote's name as `git remote` prints it (`remote/origin`), not the ref, and a branch both local and remote prints `local`. This is the reading TASK-194's runner chose, and it matches step 2's local-first check.
3. **Placement:** the "in progress on this machine" line goes before the candidate list, after the debt line, since started work is offered before new work as debt is. The taken line goes under the list, on one line.
4. **The multiple-in-progress warning** counts tasks in progress here: those whose own file reads `in-progress`, plus the in-progress-on-this-machine line, by assignee. `agent`, `unassigned` and `ai` are one assignee, and a taken task never counts. A resume does not count its own task.
5. **A run meeting two 6b outcomes prints both lines,** in the order reached: a worktree pick with an upstream prints *in a worktree*, then *upstream*.

### Spec
- `work-tracking`, Picking a task (debt count and ids, line positions, the warning) and Worktree workspace (two outcomes, two lines).

## Progress log

- step 2 — picked; ranked above the unverified older pool because key 5: two cold runners raised all five readings independently (TASK-194), and key 4: one file; keys 1 and 3 tie with the P2 harvest tasks (two runs over one tree render differently); key 7 (P3) is below the keys that decided it
- step 3 — verified: held. pick.md 2b still shows only a count of two (TASK-341 reworded it to `⚠ verification debt: 2 at verify …`, and two runners today again improvised the one-task form); `taken (hidden)`'s `remote/<name>`, the in-progress line's position, the multiple-in-progress warning's scope and 6b's one-line-per-outcome rule for a worktree pick with an upstream are unchanged
- step 3b — planned: /tasks plan --no-grill (five readings in one file); no split signal
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/pick.md (2b debt-line template; `remote/<name>` defined; the in-progress line before the list, the taken line under it; the multiple-in-progress warning's scope; 6b prints both lines for two outcomes); none restated elsewhere (grep of skills/ and docs/specs); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill
- step 7 — respecced work-tracking; requirements changed: Picking a task, Worktree workspace; intended — TASK-255's criteria
- step 5 (amended after the drill) — the warning reads `<n> task(s)`, `1 task` for one
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
