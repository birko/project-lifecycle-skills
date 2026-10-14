---
id: TASK-298
parent: STORY-023
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
findings: [FIELD-009]
pr: null
github-issue: null
jira-key: null
---

# A `/fix-next` run that cancels or blocks its task on a task branch has nowhere to commit the record

## Context

Found while doing TASK-228 (2026-10-11). `skills/fix-next/SKILL.md` steps 3 and 4 end a run without a fix: a
rejected finding is cancelled through `/tasks cancel`, and a defect whose fix belongs upstream is blocked through
`/tasks block`. Neither verb commits what it writes (`skills/tasks/verbs/cancel.md`, `block.md`). TASK-228 makes
the run commit that record on the default branch when the task file is there (an in-place pick with no task
branch). When step 2 cut a task branch (`pr-per-task`, or `workspace: worktree`), the record lands on that
branch, which no fix will ever merge:

- a cancel committed there leaves the default branch's copy reading `todo`, so the next run ranks the rejected
  finding again, unless the branch's existence keeps it out of the pool as **taken**, which then hides it for good;
- a block committed there is the state step 0 reads through `git show task/TASK-NNN:<file>`, which may be the
  intended shape, but nothing says so.

TASK-228 leaves those files uncommitted and has the run name them and stop, even under `--loop`.

## Acceptance criteria

- [x] `fix-next` states, for a run that cancels or blocks its task after step 2 cut a task branch, where the
      record is committed and how the default branch learns the task is no longer `todo`
- [x] The answer agrees with [[tasks]] `cancel` and `block` and with the taken signal in § *Collection pass*
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The in-place case — TASK-228

## Human test plan

- [x] On a `pr-per-task` fixture whose top pool task is a false positive, run `/fix-next` twice in fresh sessions.
      Expected: both end with the task `cancelled` on the default branch, a clean tree, and a later run that does
      not rank it again
  - Passed 2026-10-14 as a cold drill (`skills/populate-tests/SKILL.md` § *The cold drill*), run as two independent cold runners rather than two runs over one fixture: `d298-fixed` on the first version of the fix, then `d298-final` on the final text. Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)"`, brief on stdin. The cwd was a `pr-per-task` fixture with no remote, holding copies of the `fix-next` and `tasks` SKILL.md files and `close.md` (plus `cancel.md` in the first run). The run was staged after step 3's rejection on `task/TASK-001`. Coldness: the runners reported no skills. Result in both: the cancel was committed on the branch and merged into `main`, the branch was deleted, `main` reads `cancelled`, and the tree is clean. Both runners answered that a later run would not find the task, since it is not `todo` and no branch is left to mark it taken. A third runner, `d298-keep`, drilled the pending-decision path: the record and the work were committed on the branch, the run returned to `main`, and the tree is clean.

## Implementation plan

Written by `/fix-next` after step 3, before the edits (it runs no `/tasks plan`):

1. § *A run that ends without a fix*: a table by outcome. A cancel or an upstream block commits on the branch and lands it through `close` step 8; a pending decision commits and keeps the branch.
2. Step 0: resume an unfinished landing.
3. Lint, a cold revert-and-split drill on a `pr-per-task` fixture, respec `defect-draining`.

## Outcome

- **The fix.** When `/fix-next` had cut a task branch and then rejected the finding, or blocked it on an upstream fix, it wrote the record and committed nothing. The default branch kept reading `todo`, and the surviving branch hid the task as *taken* forever. Now the record is committed on the branch and the branch is **landed** through `close` step 8's own paths. That merges the outcome onto the default branch and deletes the branch, then `close` steps 10/10b refresh the dashboard. A pending decision is different: its branch also holds half a fix, so the run commits and **keeps** the branch, pushes it when there is an upstream, and returns to the default branch. Step 0 then reports that branch on every run, and resumes a landing that was committed but never finished. Files: `skills/fix-next/SKILL.md` (step 0, § *A run that ends without a fix*), `skills/tasks/verbs/close.md` (step 8 names this caller), and the `defect-draining` spec.
- **Step-6 split (cold drill, original vs fixed files, `pr-per-task` fixture with no remote, staged after the rejection):** 3 of 3 outcomes flip. Fix-dependent: the record on `main`, the branch gone, and a clean tree. The original runner committed nothing, left `main` reading `in-progress` with `task/TASK-001` still marking the task taken, and failed the skill's own reset check, which it quoted. Contract pins: the cancel edit itself, the rollup to `cancelled`, and the one-defect stop. Re-drilled on the final text (same result), plus the kept-branch path (record and work on the branch, back on `main`, clean).
- **Judgement calls.**
  - The fix lands through `close` step 8 rather than writing new merge mechanics. That gives one owner of every path (in place, worktree, upstream PR) and its failure lines, and `close.md` now names the caller so a change there sees it. Rejected: a `record/TASK-NNN` branch. That would be a fourth record-branch user for a record that already has a branch of its own.
  - A pending decision keeps its branch. The fidelity pass noted that the default branch then never learns the task is not `todo`. That is deliberate: landing would merge half a fix, and step 0's per-run `not resumed` line is how the open question stays visible. The stricter option, landing it anyway, was rejected for that reason.
  - The branch commit carries the task file and any rolled-up container, never the dashboard, which is discarded and then regenerated on the default branch after the merge (review finding 3).
- **Specs.** `defect-draining` respecced by `/fix-next` step 7 as a targeted edit, `generated-at` restamped, `shaped-by` carried (`feature: null`). Changes are *intended anyway — TASK-298's criteria, answered by /fix-next*, plus the review fixes.
- **Review gate.** Standards: pass. Its warnings were applied: the restated list of step 8's sub-steps is now a pointer, and `close.md` step 8 names the caller. The spec stamp is noted above. Fidelity: criteria 1–2 met, the kept-branch choice confirmed above, and the step-0 resume kept as support for criterion 1. Correctness: 6 findings, all fixed:
  1. The landing resume now runs on any project that cuts task branches, and the branch scan is no longer worktree-only, with an in-place resume onto the branch.
  2. A kept branch returns to the default branch.
  3. Dashboard handling is as above.
  4. The default branch's copy is described correctly per path.
  5. A blocked task is described as outside the pool and reported by step 0, both here and in the `--loop` line.
  6. Every `pr:` write is skipped on the upstream path, and a kept branch is pushed.

  Security and review-comments: not applicable.
- **Flagged, not fixed.** The drill found that step 1's empty-pool messages have no case for a fully drained backlog, filed as TASK-327. Also not drilled: the worktree and upstream landing paths. They are `close` step 8's own, and drilled there.

## Progress log

- step 2 — picked; ranked above TASK-254 because key 3 (silence): with a task branch, a rejected finding's cancel never reaches the default branch, and the branch then hides the task as taken for good; TASK-254 is a phrasing gap whose drill runner derived the right answer. Both found in use or by drill (key 5)
- step 3 — verified: held. `skills/fix-next/SKILL.md` § *A run that ends without a fix* says "where this record belongs is not defined yet (TASK-298): commit nothing, name every file in the report, and stop even under `--loop`". `cancel.md` and `block.md` commit nothing. SKILL.md § *Collection pass* counts a task whose branch exists as taken, out of every pool
- step 4 — layer: local
- step 5 — fix in skills/fix-next/SKILL.md § *A run that ends without a fix* (a table by outcome: cancel and upstream block commit on the branch and land it through `close` step 8's paths; a pending decision commits and keeps it) and step 0 (an unfinished landing resumes); test = lint OK + cold drill (step 6)
- step 6 — reverted fix (cold runners, original vs fixed `fix-next` and `tasks` SKILL.md, plus `close.md` and `cancel.md`; `pr-per-task` fixture with no remote, run stopped after step 3's rejection on `task/TASK-001` with the cancel written): 3/3 flip. Fixed: the record was committed on the branch and merged `--no-ff` into `main`, the branch was deleted, `main` reads `cancelled`, and the tree is clean. Original: nothing committed ("commit nothing, name every file in the report"), `main` reads `in-progress`, `task/TASK-001` survives as the taken signal, and the tree is dirty, failing the skill's own reset check (the runner quoted it). fix-dependent = the record on `main`, the branch gone, the clean tree; contract pins = the cancel edit itself, the story/epic rollup to `cancelled`, the one-defect stop. Gaps raised by the fixed runner: no subject for the branch commit (fixed: same as in place), and step 1's empty-pool messages miss a fully drained backlog (spawned TASK-327)
- step 7 — respecced defect-draining; requirement changed: "A run that ends without a fix still ends clean" (task-branch records land or are kept, dashboard regenerated after landing, unfinished landing resumed); scenario added: a false positive on a task branch
- step 7 (amended after review) — step 0 branch scan widened to every task-branch project, in-place resume, dashboard kept off the branch, kept branch pushed and left; re-drilled final text and the kept path
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
