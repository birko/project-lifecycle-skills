---
id: TASK-303
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-296-1]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/feature review` parks a `done` task at `verify` under a STORY that already reads `done`

## Context

Found by TASK-296's upstream-fixture drill (2026-10-13). `/feature review`'s Gate B parked TASK-001 `done → verify`, because its N/A test plan had no test behind it. TASK-001's STORY-001 had been closed `done` one step earlier. Nothing rolls the change up, so the tree then holds a `done` story with an open child. That is the contradiction `/tasks audit` and the container-close children-done check exist to prevent. `skills/feature/verbs/review.md` step 5 does the park; `skills/tasks/verbs/close.md` § *Closing a STORY / EPIC* owns the container rule.

## Acceptance criteria

- [x] Parking a task at `verify` from `/feature review` states what happens to a parent STORY or EPIC that reads `done`: reopened, or reported for a person, never left contradicting silently
- [x] The rule is stated where the park happens and points at the container rule rather than restating it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The upstream record question (TASK-296)
- Deferred to TASK-306 — with an upstream, a park can miss a story whose `done` waits on an unlanded `record/` branch
- Deferred to TASK-305 — `/feature review` does not regenerate `tasks/README.md` after parking a task

## Human test plan

- [ ] On a fixture where a feature's only task is `done` under a `done` story with an N/A plan that has no test behind it, run `/feature review`. Expected: the story is not left `done` over a `verify` child without a line saying so.

## Implementation plan

Not drafted: `/fix-next` picked this task and offers no plan step (TASK-135 owns that gap). The work followed the Progress log below, step by step.

## Outcome

**The fix.** A task moved back from `done` to `verify` now reopens a parent story or epic that already reads `done`, so the tree no longer shows a closed story over an unfinished task. The rule's closing direction ("children all done → close the container") was already in [[tasks]] § *Roll status up to parents*. This adds the reopening direction there, once. `/feature review`'s park (step 5) and `/feature decide`'s surface-dependent revert both point at it. Review names each reopened container, and its files ride in the review's commit.

**Step-6 split.** The same fixture was run before and after: a story closed, then the feature reviewed with no sign-off available. Before (TASK-296's first drill): STORY-001 `done` over TASK-001 `verify`, one contradiction. After: STORY-001 `in-progress`, reported as reopened and committed in `chore: review FEATURE-001`, no contradiction. Fix-dependent: STORY-001's final status, review's report line, and the story file in the review commit. Contract pins, not evidence: TASK-001 parked at `verify` in both runs, EPIC-001 unchanged at `in-progress` (already open), and the commit subjects.

**Judgement calls.**
- *Reopen, not report and leave.* The task allowed either. A container's status is derived from its children, and its own close gate would refuse it with a `verify` child, so leaving it `done` keeps a claim nothing can back. Reopening is reversible: the next `close --story` re-closes it once the child is `done`.
- *`decide.md` pulled in, beyond the written criteria* (every criterion names `/feature review`, and the step-3 log records the pull-in). Its surface-dependent revert makes the same `done → verify` move with the same gap. Same root cause, same rollup rule, so it is fixed here rather than spawned.

**Close-gate fixes.** From the correctness pass: the rule names an epic's directly parented tasks, says a `--force`-closed container is no exception (new information, not an override), leaves a dated `> Reopened` line in the container so the reopen is never silent, and reports the child's actual status rather than a hard-coded `verify`. The intent pass noted the rule restated the container gate, so it now points at `close`'s children-done check. Conventions noted that the two pointers restated the trigger more narrowly, so they now point only. Specs re-aligned (`done` or `cancelled`; the `decide` revert requirement gained its clause).

**Flagged, not fixed.** TASK-306 (CR-303-1): with an upstream, a story's `done` waits on its unlanded `record/` branch, so a park in between reopens nothing, and the contradiction returns when the branch lands. TASK-305 (DRILL-303-1): `/feature review` parks a task and reopens its story, then commits without regenerating `tasks/README.md`, so the dashboard contradicts the files in the same commit. The drill showed it.

## Progress log

- step 2 — picked; ranked above TASK-304 because this leaves the task tree contradicting itself silently (a `done` story over a `verify` child, key 3), where TASK-304 leaves a stray file that `git status` shows; key 6 inert (EPIC-003 tasks carry no story theme)
- step 3 — verified: held, and wider — `review.md` step 5 parks `done → verify` with no parent re-evaluation, and `decide.md` (surface-dependent revert, line 78) makes the same move with the same gap. The owner, [[tasks]] SKILL.md § *Roll status up to parents*, states only the closing direction (children finishing close a container), never the reopening one. Same root cause, same function of the tree, so pulled in
- step 4 — layer: local
- step 5 — fix in `skills/tasks/SKILL.md` (§ *Roll status up to parents*: the reopening direction), `skills/feature/verbs/review.md` (step 5 points at it; 5b counts reopened containers among its files) and `skills/feature/verbs/decide.md` (status rule points at it); lint OK (20 skills)
- step 6 — before/after on TASK-296's fixture: before STORY-001 `done` over TASK-001 `verify` (1 contradiction), after STORY-001 reopened to `in-progress`, reported, and committed in the review commit (0); fix-dependent = STORY-001's status, the report line, the story in the commit; contract pins = TASK-001 parked in both, EPIC-001 unchanged, subjects; spawned TASK-305 from the drill
- step 7 — respecced feature-lifecycle (*Feature and task status vocabularies stay separate*: the park reopens a done parent; new scenario) and work-tracking (*Parents rolled up after child changes*: new reopening scenario)
- step 6 (addendum, close gate) — rule tightened from the three passes (epic's direct tasks, `--force`, a dated reopen line, the child's real status, pointer to close's gate, pointers trimmed); not re-drilled, since the drilled path (story `done` → task `verify` → story reopened) is unchanged and the additions are wording around it; spawned TASK-306
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
