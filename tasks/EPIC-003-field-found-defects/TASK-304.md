---
id: TASK-304
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-296-2]
pr: null
github-issue: null
jira-key: null
---

# `pick` regenerates `tasks/README.md` on the default branch when the default branch has an upstream

## Context

Found by TASK-296's upstream-fixture drill (2026-10-13). An in-place `pick` (no `workspace:`) on a repo whose `main` tracks a remote ran step 8 and wrote `tasks/README.md`. The file was untracked, never committed, and stale once the task merged. `skills/tasks/verbs/close.md` step 10 rules that with an upstream nothing generated is written on the default branch, because the copy must mirror the remote. `pick` step 8 (`skills/tasks/verbs/pick.md`) has no such condition, and its step 6b already skips the regen in a worktree for the same reason.

## Acceptance criteria

- [x] `pick` step 8 follows the same upstream rule as `close` step 10: with an upstream it writes no dashboard, and it prints the task's new status and the owning verb to run instead
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The worktree path, which already skips the regen

## Human test plan

N/A — one condition on one step, checked by reading `pick` step 8 against `close` step 10.

## Outcome

**The fix.** `skills/tasks/verbs/pick.md` step 8 no longer regenerates the dashboard unconditionally. It reads
where step 7's status flip landed, by `close` step 10's rule: on the default branch with no upstream, it chains
triage as before; on a task branch cut in place, it writes nothing; with an upstream, it writes nothing on the
default branch and prints `TASK-NNN is now in-progress — dashboard not refreshed; run /tasks triage through a
PR`. A worktree pick never reaches the step (6b handles both cases). Spec `work-tracking` respecced (the pick
requirement + one scenario).

**Step-6 split: 0/0.** No automated test reads verb prose; the lint run (OK, 20 skills) is a contract pin, not
evidence. The task's own Human test plan is `N/A — checked by reading pick step 8 against close step 10`, which
this run did: every row of the new table matches a row of close's, with the same reason.

**Judgement calls.**
- *Pulled in the in-place task-branch case.* Same root cause (step 8 had no where-did-it-land rule), same step,
  and `close` already forbids exactly that write. Leaving it out would have fixed one row of a table and kept
  the other wrong.
- *Stated the rule as a small table with a pointer to `close` step 10, not "see close".* A verb file must be
  readable standalone, and the rows are an invariant both verbs share, not a list that grows.

**Flagged, not fixed.** Nothing.

## Implementation plan

_Populated by `/tasks plan TASK-304` — leave empty until then._

## Progress log

- step 2 — picked; ranked above TASK-298 because key 4 (self-containment): one condition on one step, while TASK-298 carries an open design question about where a task-branch record belongs. Keys 1–3 do not separate them: both leave files uncommitted, and TASK-298's run names them while this one leaves an untracked dashboard nobody mentions, so key 3 (silence) also leans to TASK-304. Key 6 inert: parented straight to EPIC-003
- step 3 — verified: held, and one sibling case pulled in. `pick` step 8 read only "chain to triage logic", with no condition. Same root cause (step 8 lacks `close` step 10's where-did-the-status-land rule): an in-place pick that cut `task/TASK-NNN` writes the dashboard on the task branch checkout, which `close` then commits there — the per-task dashboard conflict `close`'s table forbids ("on a task branch left unmerged → write nothing"). Same function, same fix, so folded in
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/pick.md step 8; no automated test applies — prose verb; lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed; fix-dependent = none; contract pins = skills-lint.sh run; the N/A plan's read-through check done (step 8 rows against close step 10)
- step 7 — respecced work-tracking; requirements changed: "Picking a task" (dashboard condition + upstream scenario)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
