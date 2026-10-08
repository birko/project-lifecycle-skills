---
id: TASK-227
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-24]
picked-by: fix-next
pr: null
github-issue: null
jira-key: null
---

# `fix-next` step 8 writes a log line after `close` has committed, so the run never ends clean

## Context

Found by the defect-draining spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-24.** `skills/fix-next/SKILL.md` step 8 hands the task to `/tasks close --unattended`, which commits the
  work and the task file, and then asks for the log line `- step 8 — closed <status>; <sha>`. The sha exists only
  after `close` has committed, so the line can only be written afterwards, which leaves the task file modified.
  § *Verify the reset really is safe* then requires `git status --short` to be clean in every repo touched, so the
  skill's own contract fails on every run that follows step 8 as written. Under `workspace: worktree` it is worse:
  `close` step 8 removes the task's worktree after merging, so the copy of the file the line should go into may no
  longer be where the run is.

Every other step's log line is written before the commit that carries it. Step 8's is the one that cannot be.

## Acceptance criteria

- [x] Step 8 says where its closing record goes so that, after it, `git status --short` is clean — for example
      written before `close` runs with the sha left to the commit history, or carried in a commit `close` makes
- [x] The answer holds in `single-branch`, PR-per-task and `workspace: worktree` projects, and step 8 says which
      copy of the task file it writes in each
- [x] Step 0's resume can still tell that step 8 completed
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `close`'s own commit composition (`skills/tasks/verbs/close.md`). If the chosen fix needs a change there, spawn it

## Human test plan

- [x] Drill: run `/fix-next` to completion on an invented `single-branch` fixture with one filed defect, then run
      `git status --short`. It is empty, and the task file alone says the task closed

## Implementation plan

_Populated by `/tasks plan TASK-227` — leave empty until then._

## Outcome

**What changed.** `/fix-next` step 8 used to ask for `- step 8 — closed <status>; <sha>` after `/tasks close`, and that line can
only be written once `close` has committed, so the task file was always left modified. The line is now written **before**
`close`, beside the `## Outcome`, and reads `- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log`.
`close`'s own commit carries both. The status and the sha are read where they are actually recorded, in the task's `status:` and in the
commit whose subject leads with the task id. A table in step 8 names which copy of the task file gets the line: the working tree
(`single-branch`), the checked-out task branch (PR-per-task in place), or the worktree (`workspace: worktree`).

**Resume.** Step 0 judges step 8 complete from git, never from the line, which is the same whether `close` finished or was
interrupted. A `close` that committed has moved the task out of `in-progress` (to `done`, to `verify`, or to blocked on a deferred
merge), so step 0 does not resume it. An unblocked `in-progress` task with step 8's line last has no close commit, so step 8 runs
again. That is stated in step 8 rather than step 0, because the rule belongs to the verb that owns it.

**Step 6, the proof.** For a change to skill prose the guard is a drill, not a suite.
- *With the fix:* 1/1. A `claude -p` session on an invented `single-branch` fixture (`%TEMP%\d227`, one `review-intake` defect)
  ran `/fix-next` end to end. `git status --short` was then empty, the task file read `status: done`, and its last log line was the new
  form verbatim (close commit `f6549e3` in the fixture).
- *Without the fix:* not re-run cold. The evidence is the three most recent real runs under the old wording, TASK-253, 256 and 272. All
  three could not follow it and wrote `closed done; … sha in git log` before `close`, which was the workaround this change now makes the
  rule. 3/3 deviated from the old text, and that is the failure the fix removes.
- *Contract pins:* `skills-lint.sh` OK. It checks links and frontmatter, not this behaviour.

**Runner.** `echo <brief> | claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" … --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills`,
cwd `%TEMP%\d227`. **Not cold:** this repo's skills are installed at user level, and the repo was granted read access. Acceptable
because the drill tests *behaviour* (does the run end clean), not wording. The brief said only *"Run /fix-next … unattended"*, and
withheld the clean-tree check and step 8.

**Judgement calls.**
- *Rejected: having `close` make a follow-up commit that records the sha.* It terminates, but `close.md` step 7 already rejects exactly
  that for `pr:`: it doubles commits, and the follow-up would lead with the task id, so `/specs regen` would attribute it. It would also
  need a change in `close`, which this task puts out of scope.
- *Rejected: keeping a status in the line* (`closed done`). The line is written before the status is settled. A `close` that parks at
  `verify` or defers the merge would then leave a line claiming `done`, and that is a worse lie than naming neither.

**Flagged, not fixed.** **TASK-284** (CR-273, filed from this close's correctness pass): `/fix-next` step 0 cannot see a
`close` interrupted between its step 6 status write and its step 7 commit. The file then reads an uncommitted `done`, which
step 0's `in-progress` search misses. That gap predates this change, and fixing it touches step 0 and possibly `close` step 4.

**Close gate (`/tasks close --unattended`), each pass on its own.**
- `ci: main green — 1 workflows read`.
- **standards** ([[verify-conventions]], done inline against AGENTS.md § Conventions): pass. The prose is imperative, and a table
  is used where the agent has to choose. One restated list was caught and rewritten as a single invariant: the
  closing states listed in step 0's paragraph became *"some status other than an unblocked `in-progress`"*. No new
  cross-cutting pattern, so no § Conventions entry is owed.
- **fidelity** ([[verify-intent]], inline): pass. All four acceptance criteria are built. The out-of-scope boundary held:
  `close.md` was not touched.
- **correctness** ([[code-review]], inline): three findings, all fixed here. (1) The example grep `^TASK-NNN:` missed
  subjects with a prefix, and it matched `pick`'s `TASK-NNN: pick` commit under worktrees. It is now "the newest commit
  whose subject's first task id is this task's", the rule [[specs]] `regen` already uses. (2) The new spec scenario used
  "no commit leads with the id" as its test, which is false for the same reason; it now says close never committed.
  (3) The interrupted-between-6-and-7 gap became TASK-284.
- **security-review**: not applicable. Two markdown files describe a progress-log line, with no auth, input, secret
  or dependency surface.
- **review-comments**: not applicable. The diff contains no code comments.
- 5c skipped: `integration: single-branch`. 5d: one `## Out of scope` bullet. It is a boundary (`close`'s commit
  composition), and none of this needed to change `close`, so nothing was spawned from the sweep.

## Progress log

- step 2 — picked; named by the owner (Outline roadmap's suggested next pick, 2026-10-07) rather than ranked — it is the defect every `/fix-next` run so far has had to work around, so fixing it first makes every later run's step 9 check honest
- step 3 — verified: held. `skills/fix-next/SKILL.md` step 8's `- step 8 — closed <status>; <sha>` needs the sha of the commit `close` step 7 makes, so it can only be written after that commit, which leaves the task file dirty against § *Verify the reset really is safe*. Evidence that every run hit it: TASK-253, 256 and 272 all wrote `closed done; committed as … sha in git log` *before* `close`, contrary to the letter of step 8. Under `workspace: worktree` `close` step 8.4 removes the worktree holding the file, so the late write has no target at all.
- step 4 — layer: local (`skills/fix-next/SKILL.md` step 8 and step 0; `close` needs no change, so nothing spawned)
- step 5 — fix in `skills/fix-next/SKILL.md` step 8 (line written before `close`, per-project copy table, completion read from `status:` + the subject-led commit, never from the line); no automated test applies to prose — the guard is the drill below; `skills-lint.sh` OK (20 skills)
- step 7 — respecced defect-draining; requirements changed: *Every step appends a progress line* (step 8's form), *Close through the merge gate unattended* (line before close, which copy, how resume judges completion; two scenarios added). Unmapped: 0 (one source file, unchanged list). `shaped-by` unchanged — TASK-227 has `feature: null`
- step 6 — with fix: drill 1/1 clean (fixture `git status --short` empty, `status: done`, step 8 line verbatim); without fix: not re-run cold, 3/3 recent real runs (TASK-253, 256, 272) could not follow the old text; contract pins = `skills-lint.sh`
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
