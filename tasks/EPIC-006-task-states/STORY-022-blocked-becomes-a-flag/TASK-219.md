---
id: TASK-219
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
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

- [x] A task blocked with `--on` stays in `fix-next`'s pool, marked and never started, like any other blocked task;
      a task whose unmet `depends-on` came from anywhere else is handled as the decision owner intends — state which
- [x] `block`'s confirmation says the status stays, matching `unblock`'s
- [x] The listed labels say `verify` (or "awaiting verification") for the task status; `spawn.md`'s sentence says
      `todo` with a `blocked:` field
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature's own `review` marker, phase and gate

## Human test plan

- [x] A cold `/fix-next` ranking on an invented pool with one task blocked `--on` another and one blocked for a
      stated reason: both are listed as skipped-blocked, neither is started

## Implementation plan

_Populated by `/tasks plan TASK-219` — leave empty until then._

## Progress log

- 2026-10-03 — Picked (in place; single-branch). `fix-next`'s exclusion of unmet `depends-on` now carves out a blocked task, which stays in the pool, marked and never started — even when its block is one of those dependencies (`/tasks block --on` writes it there). A task whose unmet dependency is not a block is still excluded: that is the decision this criterion asked to state, and the carve-out states it. `block`'s confirmation says the status stays; the snapshot's and dashboard's "In review" becomes "Awaiting verification" (`tasks/SKILL.md`, `triage.md`), and its `review:` line the `verify:` it already prints; `pick` 2b says a worktree park's `verify`; `spawn` says `todo` with a `blocked:` field. Lint OK; no "In review" label left in `skills/`.
- 2026-10-03 — Drill: invented review-intake pool `%TEMP%\d219base` (TASK-001 blocked `--on` TASK-003, TASK-002 blocked for a reason, TASK-003 plain, TASK-004 with an unmet dependency, not blocked), oracle first; two cold runners of `fix-next` up to its pick. **Both match the oracle and agree** (cold: no skills listed): pool 001, 002, 003; 004 excluded by its unmet dependency; 003 chosen; `skipped: TASK-002 — blocked: …` printed; 001 below the pick, listed for the closing report; nothing changed. Review (inline, one rule plus labels): **standards** — the carve-out states its reason inline; labels only; **intent** — 4/4 criteria; **correctness** — the carve-out cannot start a blocked task, since step 2 skips every blocked one; **security / comments** — not applicable. Note for the next dashboard regeneration: this repo's `tasks/README.md` still says "In review" until `/tasks triage` runs. Closed `done`.
