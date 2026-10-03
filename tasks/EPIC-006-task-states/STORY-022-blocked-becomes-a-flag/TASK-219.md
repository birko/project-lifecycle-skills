---
id: TASK-219
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [VI-004, VI-005, VI-006]
pr: null
github-issue: null
jira-key: null
---

# A task blocked on another task drops out of `fix-next`, and a few labels still say `review`

## Context

Found by the re-run of `/feature review FEATURE-003` (2026-10-03), Gate A's feature-level fidelity pass. The owner
chose to file these as a follow-up rather than hold the review: the decisions are built, and these are an
interaction with an older rule plus display leftovers.

| Id | Where | Problem |
|---|---|---|
| VI-004 | `skills/fix-next/SKILL.md` § pool, "Exclude: unmet `depends-on`" | D6 says a blocked task stays on offer in `fix-next`, marked. `/tasks block --on TASK-X` adds TASK-X to `depends-on`, and this older exclusion then drops the task from the pool altogether — so a task blocked *on another task* disappears, while one blocked for any other reason stays. Step 9 lists only blocked tasks *in* the pool |
| VI-005 | `skills/tasks/verbs/block.md` step 7 | Confirms `status: … → blocked`, a status change D1 rules out; `unblock`'s own confirmation correctly says the status stays |
| VI-006 | `tasks/SKILL.md` (snapshot's "omit the `review:` line", "In review" heading, "no task is in `review`"), `triage.md` "In review" heading, `pick.md` 2b ("a worktree park's `review`"), `spawn.md` ("Leave the task `todo` (or `blocked` on the decision)") | Display labels and one ambiguous sentence still naming the old task status; nothing writes a stored value |

## Acceptance criteria

- [ ] A task blocked with `--on` stays in `fix-next`'s pool, marked and never started, like any other blocked task;
      a task whose unmet `depends-on` came from anywhere else is handled as the decision owner intends — state which
- [ ] `block`'s confirmation says the status stays, matching `unblock`'s
- [ ] The listed labels say `verify` (or "awaiting verification") for the task status; `spawn.md`'s sentence says
      `todo` with a `blocked:` field
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature's own `review` marker, phase and gate

## Human test plan

- [ ] A cold `/fix-next` ranking on an invented pool with one task blocked `--on` another and one blocked for a
      stated reason: both are listed as skipped-blocked, neither is started

## Implementation plan

_Populated by `/tasks plan TASK-219` — leave empty until then._
