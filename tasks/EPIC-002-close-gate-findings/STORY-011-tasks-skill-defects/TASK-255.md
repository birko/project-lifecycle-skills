---
id: TASK-255
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
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

- [ ] Each of the five has one stated answer in `pick.md`, and none is restated elsewhere
- [ ] A re-run of TASK-194's drill brief on its fixture shape lists none of the five as a two-way reading
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The two points TASK-194 settled: the taken-list exclusions and the `gh` gating

## Human test plan

- [ ] Re-run TASK-194's brief (recorded on that task) on a freshly built fixture of the same shape, with a cold runner. Expected: its "read two ways" section lists none of DRILL-194-1 … 5

## Implementation plan

_Populated by `/tasks plan TASK-255` — leave empty until then._
