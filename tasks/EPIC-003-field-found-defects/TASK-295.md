---
id: TASK-295
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-11
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-294-1]
pr: null
github-issue: null
jira-key: null
---

# `/feature review` is read two ways on a `done` task whose `N/A` test plan turns out to be false

## Context

Found while drilling TASK-294's fix (2026-10-11). Two runs of `/feature review FEATURE-002` on the same
single-branch fixture (`%TEMP%\d294`) met the same task: TASK-002 is `done`, and its Human test plan reads
`N/A — fully covered by automated tests`, but the repo has no test at all. Both runners saw that the `N/A`
claim was false and failed Gate B. They then disagreed on the task:

- one moved TASK-002 `done → verify`, citing `skills/feature/verbs/review.md` step 5 ("Park any client tasks
  awaiting sign-off at `status: verify`");
- the other left it `done`, reasoning that a task must not be parked on a test step that was never written
  ([[tasks]] § *Lifecycle*: an absent or unfilled plan is resolved before choosing the status).

`review.md` does not say what Gate B does with a plan whose `N/A` is false, or whether step 5's parking rule
covers a task already `done`. The result is that the same review gives different task statuses on different
runs. This is not TASK-235, which is about Gate A's handling of tasks that are already `verify`.

## Acceptance criteria

- [x] `review.md` Gate B says what a false `N/A` plan is (a failed step, a not-run step, or something else) and
      what is recorded for it
- [x] Step 5 says whether parking at `verify` applies to a task that is already `done`, and the rule agrees with
      [[tasks]] § *Lifecycle* on reopening a `done` task
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Whether review commits what it writes — TASK-294

## Human test plan

- [x] On a fixture with a `done` task whose `N/A` plan names a test that does not exist, run `/feature review`
      twice in fresh sessions. Expected: both runs leave the task in the same status and report the plan the
      same way.
  - **Passed 2026-10-11:** two fresh `claude -p` sessions on `%TEMP%\d295` ran `/feature review FEATURE-002`
    with the product owner signing off. Both reported `TASK-002 — N/A claimed, coverage not found`, both moved
    TASK-002 `done → verify`, and both committed `chore: review FEATURE-002` with a clean tree. The brief named
    no expected status. The runner holds the installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-295` — leave empty until then._

## Outcome

**The fix.** `/feature review` accepted any test plan marked `N/A — fully covered by automated tests` without
looking for the tests, and it did not say whether a task that was already `done` could be sent back to `verify`.
So two reviews of the same feature could end differently. Gate B now checks an `N/A` claim. Missing coverage
makes it false, and a false `N/A` counts as an unsatisfied plan, reported on its own line as
`N/A claimed, coverage not found`. Step 5 now states that parking covers every linked task whose plan Gate B
did not pass, which moves a `done` task to `verify`.

**Step 6 split.** Before the fix, two runs on this task shape split one to one (TASK-294's drills: one parked
the task, one left it `done`). After the fix, 2/2 runs on `%TEMP%\d295` agreed: the same report line, TASK-002
at `verify`, the same two remedies. **Fix-dependent:** the agreement between runs. **Contract pins:** Gate A
passing and the `chore: review` commit, the same before and after.

**Judgement calls.**
- *Park at `verify`, and do not leave the task `done` while routing new work.* Step 5 already parks tasks
  awaiting sign-off, and Gate A guarantees every one of them is `done`, so the "leave it `done`" reading made
  step 5's parking unreachable. `decide.md`'s surface-dependent revert already moves `done → verify`, so this
  adds no new kind of status change. The other reading had its own reason: "no step was written to park it
  on". The report line answers that by naming both remedies, writing the test or writing real steps.
- *Checking an `N/A` is a search for the coverage it names, not a re-run of the suite.* Running tests is
  out of reach on many stacks. Finding no test at all, or not finding the named one, is enough to call the
  claim false. A weak test that does exist is a correctness question for `/tasks close`, not this gate's.

**Flagged, not fixed.** One run set the feature to `review` without regenerating `status.md`. Step 5 runs
`/feature status` only on the all-pass branch, which leaves the stakeholder rollup stale → TASK-297.

## Progress log

- step 2 — picked; ranked above TASK-235 because it gives a silent wrong result (one review reopens a task, another leaves it done; keys 1, 3) and was observed in two real runs (key 5), where TASK-235 is an unreachable suggestion that reads as dead text rather than a wrong state. Key 6 inert: TASK-295 has no story, and the pool separated on keys 1–5
- step 3 — verified: held. Gate B accepts any plan "explicitly `N/A`" and never checks the claim; step 5 parks "client tasks awaiting sign-off" at `verify` without saying whether a `done` task counts. The text settles the reading: Gate A has already required every linked task to be `done` before step 5, so the tasks step 5 parks can only be `done` ones, and `decide.md`'s surface-dependent revert already moves `done → verify` directly. So a false `N/A` is an unsatisfied plan, the same as a step not run
- step 4 — layer: local (`skills/feature/verbs/review.md`)
- step 5 — fix in `skills/feature/verbs/review.md`: Gate B checks an `N/A` claim and reads a false one as an unsatisfied plan, reported as `TASK-NNN — N/A claimed, coverage not found: <what was looked for>`; step 5's parking covers every linked task whose plan Gate B did not pass (`done → verify`). Tests: lint green; drill on `%TEMP%\d295` (a `done` task whose `N/A` names a test that does not exist), two fresh sessions — both reported the line, both parked TASK-002 at `verify`, both named the same two remedies, both ended clean
- step 6 — reverted evidence: the two TASK-294 drill runs on this same shape (2026-10-11, review.md without this change) split 1/1 — one parked the task at `verify`, one left it `done`. Fixed: 2/2 agree on `verify` and on the report. Fix-dependent = the agreement between runs; contract pins, not evidence = Gate A passing and the review commit, identical before and after
- step 7 — respecced feature-lifecycle ("Review is a three-gate completeness check": an `N/A` must have its coverage present; the task-status requirement: parking moves `done → verify` for every task whose plan did not pass; a new scenario under "Review sets the coarse status honestly"); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
