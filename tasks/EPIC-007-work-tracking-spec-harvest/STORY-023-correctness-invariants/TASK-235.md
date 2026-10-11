---
id: TASK-235
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-42]
pr: null
github-issue: null
jira-key: null
---

# `/feature review` closes open tasks after a gate that stops on open tasks

## Context

Found by the feature-lifecycle spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-42.** `skills/feature/verbs/review.md` step 5, "All three gates pass": "suggest closing any still-open tasks via
  `/tasks close`". Gate A (step 2) already stops when any linked task is not `done`, and the edge case *Some tasks
  still open / unmerged* repeats that. So either the suggestion is unreachable, or Gate A lets some tasks through
  that are not `done`. The likely candidates are tasks at `verify`, which step 5's third bullet parks there on
  purpose. The verb does not say which.

## Acceptance criteria

- [x] Gate A states whether a `verify` task (either form, per [[tasks]] § *Reading a task's status*) passes
      completeness
- [x] Step 5 suggests closing tasks only if Gate A can let one through, and names which ones
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Gate B's handling of unchecked test plans

## Human test plan

- [x] On a single-branch fixture where an earlier review parked a task at `verify`, run `/feature review` with the
      task's test step reported passed and the stakeholder signing off. Expected: the run reaches a verdict on
      that task without leaving the review's own contract, and two runs agree.
  - **Passed 2026-10-11:** two fresh `claude -p` runs on `%TEMP%\d235` (FEATURE-001 at `review`, TASK-002 at
    `verify` with its spreadsheet step unticked). Both passed Gate A with TASK-002 at `verify`, ticked its step at
    Gate B, set the feature `done` and named `/tasks close TASK-002`. Run a committed `chore: review FEATURE-001`;
    in run b the harness held the commit and the run named all five files. The brief named no expected outcome.
    The runner holds the installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-235` — leave empty until then._

## Outcome

**The fix.** Gate A stopped on any task that was not `done`, so the suggestion after an all-pass review to close
still-open tasks could never apply. It was worse than unreachable: `/feature pick` sends a feature whose tasks are
`done` or `verify` to `/feature review`, and review's step 5 parks tasks at `verify` for the next review to pick
up, but that next review then stopped on them as open. Gate A now says a task is merged when it is `done`, or at
`verify` with its work on the default branch. Such a task waits only for its test plan, which is Gate B's
question. Open means `todo`, `in-progress`, blocked, or a `verify` park still on an unmerged task branch (a
PR-per-task park). After an all-pass review, step 5 names each task still at `verify` and suggests
`/tasks close` for it, and suggests nothing when there is none.

**Step 6 split.** Pre-fix text, 2 runs on the same fixture and brief: **both treated TASK-002 as open** and
ran `/tasks close TASK-002` themselves before Gate A (one said "the feature can't pass until every linked task is
`done`"), committing a task close inside a feature review. Fixed text, 2 runs: **both passed Gate A with
TASK-002 at `verify`** and left the close to `/tasks close`, named by id. **Fix-dependent:** Gate A's verdict on
a `verify` task, and whether the review closes tasks itself. **Contract pins, not evidence:** the feature ending
`done`, the History lines, and the rollup regenerated. Those were the same in all four runs.

**Judgement calls.**
- *Let a `verify` task through Gate A instead of having review close it.* Under the old text both runners closed
  the task themselves, which ran another verb's gate inside the review. Gate B already owns the plan, and the
  `verify → done` flip stays with `/tasks close`, which is the owning verb.
- *Merged is read off the branches, not the status.* `close` parks at `verify` on the default branch in place,
  and on an unmerged task branch on a PR-per-task project. The status alone cannot tell the two apart, and an
  unmerged park really is not complete.

**Flagged, not fixed.** Nothing new. One fixed run could not commit because the drill harness held `git commit`
for approval. That is the harness, and the run named every uncommitted file as step 6 requires.

## Progress log

- step 2 — picked; ranked above TASK-234 because TASK-295 made parking `done → verify` the normal outcome of an unsigned review, so every re-review after sign-off now meets Gate A with `verify` tasks, the case this verb leaves undefined (key 2: reached on every two-pass review; key 3: a review that lists a parked task as "open" and stops reads as unfinished work, not as debt to verify). Keys 1 and 6 inert: both are wrong-result defects under `correctness-invariants`
- step 3 — verified: held, and wider than filed. Gate A stops on any task not `done`, so step 5's close suggestion is unreachable as written; and `feature/verbs/pick.md` phase E routes a feature whose tasks are `done` or `verify` to `/feature review`, which then stops on those `verify` tasks: the two verbs route into each other. Whether a `verify` task is merged depends on where `close` parked it (default branch in place; an unmerged task branch on a PR-per-task park, close.md step 10's table)
- step 4 — layer: local (`skills/feature/verbs/review.md`)
- step 5 — fix in `skills/feature/verbs/review.md` (close-gate correctness pass widened "unmerged" from a PR-per-task park to any task-branch park, in place or worktree): Gate A defines merged (`done`, or `verify` with its work on the default branch) and open (`todo`, `in-progress`, blocked, or a `verify` park on an unmerged task branch); step 5's all-pass branch names each task still at `verify` for `/tasks close`; the edge case agrees. Lint green; drill 2/2 on `%TEMP%\d235`
- step 6 — reverted: 2/2 pre-fix runs read TASK-002 at `verify` as open and closed it themselves before Gate A; 2/2 fixed runs passed Gate A with it at `verify` and named `/tasks close TASK-002`. Fix-dependent = Gate A's verdict on a `verify` task, and the review not closing tasks; contract pins = feature `done`, History lines, rollup regenerated
- step 7 — respecced feature-lifecycle ("Review is a three-gate completeness check": merged and open defined, plus scenario "A task parked at verify by an earlier review is not open"; "Review sets the coarse status honestly": all-pass names each `verify` task for `/tasks close`); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
