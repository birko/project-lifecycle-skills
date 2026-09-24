---
id: TASK-174
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: ai
created: 2026-09-24
depends-on: [TASK-173]
blocks: [TASK-175, TASK-176]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` creates the task worktree, asking for the root when undeclared

## Context

FEATURE-001 D5 and D6. When `.config.yml` declares `workspace: worktree`, `pick` step 7
(`skills/tasks/verbs/pick.md`, *Cut the task branch*) creates a worktree on a new `task/TASK-NNN`
branch under `worktree-root:` instead of cutting the branch in the main copy. The root is **outside**
the repository by decision (D5); an in-repo path is refused rather than accepted.

When `worktree-root:` is absent, `pick` asks. Per the ask-step rule (AGENTS.md § Output/prose rules)
the question is written verbatim into the verb, with its answer-less path. Starting wording, to be
refined in the plan but kept to this shape:

> **Where should task worktrees live?** They go outside this repository, one folder per task.
> Suggested: `../wt` (relative to the repository root). Give a path, or leave it blank to work in
> place this time.

- **Answer given** → write `worktree-root:` into `.config.yml` (the answer is the declaration), then create the worktree.
- **Blank, or nobody to ask** → write nothing, cut `task/TASK-NNN` in place as today, and report `worktree-root undeclared`. The suggestion never becomes the declaration.

The folder layout under the root (for example `<root>/<repo>/TASK-NNN`) is observable behaviour —
choose it in the plan and record it with `/feature decide`. Note the `check_root` comment in
`.github/workflows/skills-lint.sh`: a `<repo>/wt/<repo>` layout already broke shortest-prefix path
stripping once.

## Acceptance criteria

- [x] `pick.md` step 7 branches on `workspace:`; absent or `in-place` is unchanged byte for byte. *(Read as behaviour, per the plan written before work began: in-place output and outcome are unchanged — step 6b prints nothing and hands to step 7 — while the prose around step 7 gained worktree sentences and step 6's resume point moved to 6b.)*
- [x] `worktree` → `git worktree add <path> -b task/TASK-NNN` from the default branch, at the recorded layout.
- [x] A declared or answered root that resolves **inside** the repository is refused with the reason, and the run falls back to in-place.
- [x] The undeclared-root question is quoted verbatim in `pick.md` with both paths; the answer-less path writes nothing and reports `worktree-root undeclared`.
- [x] Any no-user flag that reaches `pick` lists this ask-step in its definition (AGENTS.md § *A flag that declares an absent capability*).
- [x] Layout decision recorded on FEATURE-001.
- [x] `integration: single-branch` + `workspace: worktree` → works in place and prints the fixed report line FEATURE-001 D11 records, on every run that reaches the branch step (added 2026-09-24 from TASK-173's plan: `pick`'s single-branch branch returns before `workspace:` is read, so without this nothing carries D11 out). The line lives in `pick.md`; `skills/tasks/SKILL.md` § *Where the work happens is declared too* deliberately states only that `worktree` has no effect there, and gains a one-clause pointer to `pick` once this lands.
- [x] A `workspace:` value that is neither `in-place` nor `worktree` (a typo such as `worktrees`) is reported by name and treated as in-place for the run — never silently (added 2026-09-24 from TASK-173's correctness review: only the absent case was defined).

## Out of scope

- Moving into the worktree and proving it — TASK-175. This task must not ship a path that creates a worktree without entering it: land the two together, or keep this path unreachable until TASK-175 is in.
- Merge and removal — TASK-176.

## Human test plan

Runs on a `pr-per-task` consumer project — **not this repo**, which declares `single-branch`.

- [x] `workspace: worktree`, no `worktree-root:`; answer the question with a path outside the repo. Expected: the path is written to `.config.yml`, the worktree exists there on `task/TASK-NNN`, the main copy is still on the default branch.
- [x] Same, but leave the answer blank. Expected: no `worktree-root:` written, branch cut in place, report says `worktree-root undeclared`.
- [x] Answer with a path inside the repo. Expected: refused with a reason, in-place fallback.

## Implementation plan

Lands in **one change with TASK-175**, because a TASK-174 commit alone would create worktrees that nothing enters (the D3 trap). Decisions: D13 (layout), D15 (where the answer goes), D11 (report line), all approved 2026-09-24.

1. `skills/tasks/verbs/pick.md`: add **step 6b "Decide where the work happens"** between the plan check and the status flip. It runs only on a git repo whose main copy is on the default branch with HEAD born; otherwise it goes straight to step 7. Step 7's in-place text is unchanged.
   - Read `integration:`, `workspace:` and `worktree-root:` from `.config.yml`. Never read `git worktree list` to decide.
   - `workspace:` absent or `in-place` → step 7, nothing printed.
   - Any other value except `worktree` → print the invalid-value line, treat as in-place.
   - `single-branch` + `worktree` → print the D11 line on every run, cache nothing.
   - `worktree` with the root absent → ask the verbatim question. An answer is written and committed per D15. Blank or nobody to ask → write nothing, fall back, report `worktree-root undeclared`.
   - Resolve the root against the repo root, normalise it, and refuse it if it is inside the repo.
   - Path = `<root>/<repo-name>-TASK-NNN` (D13).
   - `git worktree add <path> -b task/TASK-NNN <default-branch>`; on failure print the fell-back line with git's message. A branch or worktree left from an earlier pick → report and stop, never remove it.
   - Hand off to the enter-and-prove step (TASK-175). The declaration answers step 7's "offer to cut a branch", so that offer is not repeated.
2. Step 7: one line — skip the cut when 6b already made it.
3. No-user paths: no flag reaches `pick` today. Record that the answer-less path *is* the unattended outcome; do not add an `--unattended`. `skills/fix-next/SKILL.md` step 2's branch-cut bullet gains: undeclared root → pick's answer-less path, never ask, never write.
4. `skills/tasks/SKILL.md` § *Where the work happens is declared too*: add a one-clause pointer to `pick` step 6b for the D11 line.
5. Lint; cold drill on a `pr-per-task` fixture (human test plan).

**Drill (2026-09-24), shared with TASK-174/175.** Runner: `claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" EnterWorktree ExitWorktree --add-dir <skills> <repo> <fixtures>`, brief on stdin. Each cwd was a scratch `pr-per-task` git fixture with a planned TASK-001. **Not cold on names** (installed skills). This is acceptable because it drills behaviour, and the brief withheld the expected outcomes.

| Fixture | Declared | Outcome |
|---|---|---|
| a | `worktree`, no root, no answer | question quoted verbatim; nothing written; `fell back … worktree-root undeclared`; branch cut in place |
| b | `worktree`, no root, answered `../wt` | `worktree-root: ../wt` written and committed alone on `main` (`TASK-001: declare worktree-root`) **before** `git worktree add`; worktree created at `../wt/b-answered-TASK-001` (D13 layout); entry failed (below); proof mismatch caught; worktree and branch removed without force; in-place fallback line naming both paths |
| c | `worktree`, root `../wt` | same as b without the question: created, not entered, proof caught it, cleaned, fell back |
| d | root `wt` (inside) | refusal line, no worktree |
| e | `single-branch` + `worktree` | no-effect line, nothing changed |
| f | `workspace: worktrees` | invalid-value line, in place |

**Why b and c fell back:** a `-p` runner cannot approve `EnterWorktree`'s confirmation, even when the tool is allowlisted, and its `cd` does not persist. That makes b and c a natural run of the forced-mismatch case, which passed. **The success path, where the session is actually inside the worktree, cannot be reached by a `-p` runner.** The mechanism was proved in the main interactive session the same day: `EnterWorktree` with `path` entered an outside-repo worktree, and `--show-toplevel` from a separate command in both shells returned it. It still needs one interactive `/tasks pick` on a consumer (the unticked human-test steps).

**Found and fixed during the drill:** the fell-back line claimed the branch was already "cut in the main copy" before step 7 had run (it now says "continuing in the main copy at step 7"). A declaration commit that failed had no defined outcome (it now stops before any worktree, branch or status change). **Found and filed:** step 7's two older ask-steps have no answer-less path → TASK-182 (DRILL-174-1).

**Re-drill after the review fixes and D17 (2026-09-24).** Same runner command, fresh fixture set, ten runners in parallel. Every outcome was as step 6b now specifies:

| Fixture | Outcome |
|---|---|
| a · root undeclared, no answer | question quoted verbatim; nothing written, no commit; `fell back — worktree-root undeclared` |
| b · answered `../wt` | answer checked, then written; a single `TASK-001: pick` commit on `main` holding `.config.yml` (live `worktree-root: ../wt`), the task file (`in-progress`) and `tasks/README.md`; worktree created; entry failed (a `-p` limit); proof mismatch caught, worktree and branch removed, branch cut in place **without asking** |
| c · root declared | same as b, without the question |
| d · root inside the repo | refusal line; nothing written |
| e · `single-branch` | no-effect line |
| f · `workspace: worktrees` | invalid-value line |
| g · unrelated edit in the main copy | `fell back — the main copy is not clean on main`; no pick commit |
| h · `task/TASK-001` already exists | leftover line; nothing changed |
| i · task file untracked | the pick commit **added** the file, so the worktree would contain it; `main` shows `in-progress` |
| j · pick run from inside another task's worktree | wrong-tree line naming both trees; nothing changed |

Every code-review finding this addressed is closed by a fixture above: planning skipping 6b (the resume point moved to 6b), a missing or uncommitted task file (i), status invisible from main (b/c/i: `in-progress` is on `main`), the answered root committed before being refused (the check now runs first), a commit sweeping in other files (`--only`, and g), running from inside a worktree (j), a leftover branch (h), and case-insensitive comparison. Still open by design: the in-worktree success path needs an interactive session (see above), and **this task closes together with TASK-175 and TASK-176** (D17 landing), because today's `close` cannot yet merge from a worktree.

**Close gate (2026-09-24), shared by TASK-174/175/176, which land together (D17). One verdict per pass.**

*Round 1*, on 174/175 alone:
- **Standards:** pass. Fixed: a duplicated drill record, the `fix-next` restatement, and a stale dashboard.
- **Fidelity:** two gaps, fixed. An answered in-repo root was committed before being refused. The fallback relied on step 7's *offer*.
- **Correctness:** three high findings, which led to D17 (the pick commit) and the joint landing. Five more were fixed.

*Round 2*, on 174/175/176:
- **Standards:** one 🛑, the hand-edited dashboard, regenerated at this close. Three ⚠ fixed: `fix-next` states the blank-answer branch outright, the `--unattended` row is spelled out, and the reason the pick subject leads with the id is given.
- **Fidelity:** two gaps in TASK-176, fixed. A failure after step 7 was reported as "nothing written". Step 11's rollup was not directed to the main copy.
- **Correctness:** three high findings:
  - The PR path diverged local and remote main, which led to **D23** (local merges only) and **TASK-183**.
  - Chained verbs regenerated the dashboard inside a worktree. Fixed in `triage.md`; the id collision it exposed is **TASK-184**.
  - `fix-next`'s pick markers missed the pick commit. Fixed.
  - Five medium and three low findings were fixed: the SHA-backfill carve-out, a merge-failed line plus resume, the `new`→`pick` clean check, held-elsewhere counting linked worktrees only, no stacked fallback cut, the park path, the `unblock` location, and holding the answer until every check passes.

**Comments:** not applicable, since the diff adds no code comments. **Security:** not applicable beyond the path handling already covered: paths are quoted and roots inside the repo are refused.

*Fixes verified by re-drill, not by a third review pass*:
- **p1:** a default branch that tracks a remote gives the unsupported line.
- **p2:** the `new`→`pick` state gives a single pick commit holding the task file and the dashboard.
- **c1:** a merge conflict gives the merge-failed line, and a **second close resumed at the merge** without asking to reopen or refusing under `--unattended`.
- **c2:** a clean close leaves no staged edit in the worktree (the backfill carve-out holds). It then exposed the **two-shell** case: the Bash and PowerShell tools each keep a working directory, so leaving in one left the other holding the folder, and removal was only partial. Both rules are now in `close` step 8.

**Parked at `review`, not `done`.** One human-test step each needs an interactive Claude Code session on a consumer, because a `-p` runner can neither approve `EnterWorktree` nor move: `pick` ending up *inside* the worktree, the pi runtime, and `close`'s full tail with removal. TASK-179's end-to-end drill is where they are run.

**Interactive step run** in TASK-179's trial (step 1): the question was answered by the stakeholder, the root was committed in the pick commit, and the worktree was created.

**Closed `done` 2026-09-24:** every human-test step has now been run (TASK-179's trial). Landed with TASK-175/176 in `b9e9161`, with the trial's D7/D8/D18 fixes on top.
