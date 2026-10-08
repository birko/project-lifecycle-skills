---
id: TASK-284
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-273]
picked-by: fix-next
pr: null
github-issue: null
jira-key: null
---

# `fix-next` step 0 cannot see a `close` interrupted between its status write and its commit

## Context

Found by the correctness pass at TASK-227's close gate (2026-10-08).

- **CR-273.** `/tasks close` step 6 writes the task's new `status:` (`done`, `verify`, or `in-progress` plus a
  `blocked:` field), and step 7 commits it. A session reset between the two leaves the task file reading the new
  status, **uncommitted**. `skills/fix-next/SKILL.md` step 0 finds in-flight runs only by `status: in-progress`
  (and, under `workspace: worktree`, by branch copies reading `in-progress`). So a file reading an uncommitted
  `done` is invisible to it. The next `/fix-next` picks a second task on top of a dirty tree, and the first task's
  work is never committed. That breaks *one task in-progress at a time*, and the reset contract
  (§ *Verify the reset really is safe*).
- If step 0 did find it, `close` step 4 under `--unattended` refuses an already-`done` task, so a re-close would
  stop too. Whether that refusal should tell an uncommitted `done` from a committed one is part of this task.
- TASK-227 made step 8 judge completion from `status:` plus git. This is the one interruption point where
  `status:` alone says the close happened when git says it did not.

## Acceptance criteria

- [x] `/fix-next` step 0 detects a skill-owned task whose `status:` change is uncommitted (the task file is
      modified against `HEAD`, and its log ends at step 8), and resumes it instead of picking new work
- [x] The resume completes the close (commit, plus the merge where one applies) without `close` step 4 refusing
      it as already `done`, or the task says which verb owns that path
- [x] Holds in `single-branch`, PR-per-task and `workspace: worktree` projects
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- How `close` orders its own steps 6 and 7. The ordering is deliberate (`close.md` step 6, *Ordering rationale*)

## Human test plan

- [x] Drill: on a `single-branch` fixture, stage the state by hand (task file at `status: done` with step 8's line
      last, uncommitted), then run `/fix-next`. It resumes that task and ends with a clean tree; it does not pick
      another

## Implementation plan

_Populated by `/tasks plan TASK-284` — leave empty until then._

## Outcome

**What changed.** `/tasks close` writes a task's new status before the commit that carries it. A session reset between
the two left the task file reading `done` (or `verify`) with nothing committed. `/fix-next` step 0 searched only for
`in-progress`, so it missed the task and started a second one on top of the uncommitted work, and `close` refused an
already-`done` task under `--unattended`. Two edits now cover this:
- **`/fix-next` step 0** has a third search. A task file is an interrupted close when its working copy reads `done` or
  `verify`, carries `picked-by: fix-next`, and `HEAD`'s copy reads something else. Step 0 resumes it at step 8.
  Step 8's completion paragraph says an uncommitted status does not count.
- **`close` step 4**: a `done` or `verify` that no commit carries is not a closed record. `close` reads `HEAD`'s status
  and runs again from step 4b, review passes included, under `--unattended` too. The `--unattended` table gains a row.

**How each project shape is covered.** On `single-branch` and in-place PR-per-task projects, the new step 0 search finds
the task. Under `workspace: worktree`, step 0 already found it, because the task-branch copy still reads `in-progress`.
What failed there was the re-close, and the `close` step 4 change fixes that, since in the worktree `HEAD` is the task branch.

**Step 6, as numbers.** Revert-and-split by drill, one hand-staged fixture state run twice: the fix applied, `status: done`,
step 8's line last, nothing committed, and a second defect waiting.
- *With the fix stashed* (`%TEMP%\d284a`): the run **did not fail.** It resumed TASK-001 and ended clean (`1e67853`). It got
  there by improvising from step 0's "git wins", and logged `step 0 — resumed … the file read done but git held no close commit`.
- *With the fix* (`%TEMP%\d284b`): it ended clean (`77731c5`), citing the new rule, and ran the close gate again as
  `close` step 4 now says.
- **Split: 0/1 failed. The drill does not discriminate, and no fix-dependent outcome is proven.** Both outcomes are
  contract pins, as is the lint. What the fix changes is that the resume is now an instruction instead of a capable
  runner's inference, and that `close` no longer contradicts it with the already-`done` refusal. A weaker runner
  would not have improvised. This drill used one runner and cannot show that.
- *Runner* for both: `echo <brief> | claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" … --add-dir
  ~/.claude/skills C:/Source/project-lifecycle-skills`, cwd the fixture. Not cold: this repo's skills are installed at
  user level and the repo was readable. The drill tests behaviour, and the brief withheld the staged state.

**Judgement calls.**
- *Rejected: resuming `close` at its commit step.* It is cheaper, but the working copy cannot prove the gate passed
  before the status was written, and a hand-edited `done` looks identical. So `close` runs its gate again.
- *Rejected: "read `HEAD`'s status whenever the working copy differs".* That was the first draft, and it was wrong: in-place
  `pick`, `block` and `cancel` never commit, so an uncommitted `in-progress`, `blocked:` or `cancelled` is normal and must
  be read as written. The rule is limited to the two statuses `close` itself writes.
- The first draft of step 0 also keyed on "`HEAD` reads `in-progress`". An in-place pick commits nothing, so on a
  `single-branch` repo `HEAD` reads `todo`, and that draft would have missed the main case. Corrected before the drill.

**Flagged, not fixed.** A *deferred merge* interrupted before its commit (working copy `in-progress` plus a `blocked:`
field) is still read as a block. `/fix-next` never defers, because `--unattended` always merges, so only an interactive
close reaches that state, and a person is there to see it. That is recorded here as a decided boundary, not as work.

**Close gate (`/tasks close --unattended`), each pass on its own.**
- `ci: main green — 1 workflows read`.
- **standards** (inline, AGENTS.md § Conventions): pass. The prose is imperative; the new `--unattended` table row keeps
  the flag's contract complete (§ *A flag that declares an absent capability*); "the statuses `close` writes in place" is
  stated as an invariant, not a list that can grow. Nothing new to register.
- **fidelity** (inline): pass. All four acceptance criteria are built; the out-of-scope boundary held (step 6/7 order unchanged).
- **correctness** (inline): one finding, fixed. The new step 4 bullet said "run from step 5", which skipped step 4b
  (where the close runs), so a worktree close would have committed in the wrong tree. It now says step 4b.
- **security-review**: not applicable. Markdown only, no auth, input, secret or dependency surface.
- **review-comments**: not applicable. No code comments in the diff.
- 5c skipped: `single-branch`. 5d: one `## Out of scope` bullet, a boundary (`close`'s step order). Nothing spawned.

## Progress log

- step 2 — picked; named by the owner, following TASK-227's closing report and the Outline roadmap (2026-10-08), not ranked — it completes TASK-227's reset contract, the one interruption point where a skill-owned run can still be lost
- step 3 — verified: held, slightly wider. `close.md` step 6 writes `status:` and step 7 commits it; `fix-next` step 0 searches only for `status: in-progress`, and `close` step 4 refuses an already-`done` task under `--unattended`. The same gap opens at step 5's `verify` park, which writes `verify` before its park commit. Under `workspace: worktree` step 0 already finds the run, because the branch copy still reads `in-progress`, but the re-close then hits step 4's refusal. Acceptance criteria already say "status change", so no rewrite is needed
- step 4 — layer: local (`skills/fix-next/SKILL.md` step 0; `skills/tasks/verbs/close.md` step 4, which owns how a re-close reads the status, per acceptance criterion 2)
- step 5 — fix in `skills/fix-next/SKILL.md` step 0 (a third search: a skill-owned task file whose working copy reads `done`/`verify` while `HEAD`'s does not → resume at step 8) and `skills/tasks/verbs/close.md` step 4 (a `done`/`verify` no commit carries is not a closed record: read `HEAD`'s status and rerun from step 5, gate included; only those two statuses, because in-place `pick`/`block`/`cancel` legitimately leave theirs uncommitted). First draft keyed on "`HEAD` reads `in-progress`" and was wrong: an in-place pick commits nothing, so `HEAD` reads `todo` there. Lint OK (20 skills). The guard is the drill in step 6
- step 6 — revert-and-split by drill, one fixture state staged twice (`%TEMP%\d284a` old text, `%TEMP%\d284b` fix): **0/1 failed, so the drill does not discriminate.** With the fix stashed, the runner still resumed TASK-001 and ended clean (`1e67853`), improvising from step 0's "git wins" and logging `step 0 — resumed … the file read done but git held no close commit`. With the fix it did the same (`77731c5`), citing the new rule, and reran the close gate per `close` step 4. Neither picked TASK-002. Fix-dependent = none proven; contract pins = both drill outcomes and lint
- step 7 — respecced work-tracking (*A blocked task cannot be closed*: uncommitted `done`/`verify` clause, plus scenario *Close interrupted before its commit*) and defect-draining (*Resume an interrupted run*: third search, plus scenario *A close stopped before its commit*). Unmapped: 0
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
