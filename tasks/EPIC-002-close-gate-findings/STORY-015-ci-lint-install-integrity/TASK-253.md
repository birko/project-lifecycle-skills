---
id: TASK-253
parent: STORY-015
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-04
depends-on: [TASK-252]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/tasks close` trusts a local test run where the project's CI runs elsewhere

## Context

Spawned from TASK-252. CI on Linux was red for two weeks while every `/tasks close` here passed the lint under Git
Bash. TASK-252 fixed the cause (a CR byte that let CRLF into `skills-lint.sh`) and added lint check 8, so **that
cause** cannot recur unseen. **The class can:** any difference between the machine running `close` and the CI
runner (GNU vs BSD tools, a missing binary, a path or locale difference) still passes locally and fails only in CI,
where nobody looks.

This is a change to `close`'s gate behaviour for every consumer, not to this repo's lint, which is why it is not
part of TASK-252. The likely shape: where the project has CI and a CLI to read it (`gh run list`), `close` reports
the default branch's last CI result beside the local tests, and a red CI is surfaced, not silently outranked by a
green local run.

## Acceptance criteria

- [x] `close` says whether the project's CI result for the default branch was read, and what it was. Where it cannot be read (no CI, no CLI, offline), it says so — never silence
- [x] A red CI on the default branch is reported at the gate as its own line, distinct from the local test result
- [x] Whether a red CI holds the merge or only warns is decided and recorded, and the flag rules (`--unattended`) cover it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- This repo's own lint (TASK-252)
- Waiting for a CI run triggered by the close's own push. Reading the last completed run is enough to catch a gate that has been red for days

## Human test plan

- [x] On a fixture repo whose last CI run on the default branch failed, run `/tasks close` on a task whose local tests pass. Expected: the red CI is named at the gate

## Implementation plan

Decided before the edit, after the owner's answer below, and written here at close (`/fix-next` runs no `/tasks plan`, TASK-135).
1. A new step 5a in `close.md`, ahead of the review axes: read the latest completed run of each CI workflow on the default branch with the host's CLI (`gh run list` on GitHub), and print one `ci:` line in one of three shapes: green, RED with the workflow and URL, or `not read — <reason>`.
2. **Decision (criterion 3), asked on 2026-10-07 and answered by the owner: a red CI warns and never holds.** The run is about code already on the default branch, usually not this task's. Holding would stall every close on an unrelated red, and an unattended drain would stop at each one. The owner chose "Warn, don't block" over "Block the close" and "Ask each time". It is recorded inline in step 5a with the rejected options.
3. Add a 5a row to the `--unattended` table (nothing is asked), carry the `ci:` line into 5c's merge question and step 12's confirmation, and keep it out of 5b's verdict ordering.
4. Respec the area that maps `close.md`, then run a cold drill of `close` on old and new text against a fixture whose CI reads red (a stub `gh` on PATH).

## Outcome

- **The fix:** `/tasks close` now reads the default branch's last completed CI run per workflow (new step 5a) and always prints one `ci:` line: green with the number of workflows read, RED naming each workflow, its conclusion, commit and run URL, or `not read` with the reason. A red result warns and never holds the close, by the owner's decision. Before, `close` judged only what ran on the closing machine, which is how this repo's CI sat red on Linux for two weeks while every close passed.
- **Step-6 split:** on the plan's premise (local tests pass, CI red), old text 0/1 named the red run and closed silently; new text 1/1, on the final wording too (`ci: main RED — ci failure at 9f3c2a1…: …/runs/4242`, at the gate and in the confirmation, task still `done`). Fix-dependent: that drill. Contract pins, not evidence: the lint. Two earlier pairs were void and are recorded below.
- **Judgement calls:** the hold-or-warn question went to the owner, who chose **warn** over "block the close" and "ask each time". The run belongs to code already on the default branch, so holding would stall every close on an unrelated failure. Placed as its own step ahead of the review axes, not inside them, because it judges the branch, not this diff. The command reads the last *completed* run only, as Out of scope allows.
- **Flagged, not fixed:** nothing outstanding.
- **Close gate (step 5b), each axis on its own:**
  - **Correctness:** two blocking, fixed. A close parking at `verify` never reached 5a while step 12 still printed its line (5a now runs before parking too). GitHub conclusions other than success/failure were unmapped (green is now `success`/`neutral`/`skipped`, any other conclusion is RED and named). Five minor, fixed: `--limit 20` could drop a rarely-run workflow (now 100, and the line counts the workflows read); one sha for several workflows (each red entry carries its own); STORY/EPIC closes read no CI (step 12 says task closes only); `/fix-next`'s report now quotes a red `ci:` line; the `--unattended` row's wording.
  - **Standards:** warn, no blocker. Fixed: shipped prose cited this repo's TASK-253, which a consumer cannot resolve (dropped; the rationale is inline). Its provenance warning (a spec stamped HEAD while the source was uncommitted) is met by committing both together.
  - **Fidelity:** pass. Fixed: an awkward parenthetical, and the drill evidence quoted an earlier wording of the line (re-run on the final text, above). Accepted: `close` has no separate local-test line, so "distinct from the local test result" is met by keeping the `ci:` line apart from every verdict.
  - **Security / comments:** not applicable (no input handling; no code comments).
  - **Out of scope (5d):** 2 boundaries (TASK-252's lint; waiting for the close's own run), 0 spawned.

## Progress log

- step 2 — picked by the owner's direct request ("task 253"), so the ranking was not run; it was the named next pick after TASK-256 (a silent wrong gate result, key 1 below TASK-256's write into a consumer repo). Criterion 3 holds a decision (hold vs warn), so the guardrail applies: build the non-controversial part, and put the decision to the owner with a recommendation.
- step 3 — verified: held. `skills/tasks/verbs/close.md` reads no CI anywhere (no `gh run`, no CI step); its gate is the review axes on this machine plus the task's own evidence. The owner was asked the hold-or-warn question (criterion 3) and chose warn.
- step 4 — layer: local (`close.md` owns the gate).
- step 5 — fix in `skills/tasks/verbs/close.md`: new step 5a (read the default branch's CI and print one `ci:` line; red warns, never holds, with the rejected options inline), a 5a row in step 2's `--unattended` table, the `ci:` line in 5c's merge question and step 12's confirmation. Lint OK. The command was run for real on this repo: `ci: main green at d2ff262`.
- step 6 — reintroduce-and-confirm, as cold drills on old and new `skills/tasks` copies (`%TEMP%\d253\old|new`). Fixture (`%TEMP%\d253\repo-old|new`): a single-branch shell repo with `.github/workflows/ci.yml`, a GitHub remote, a `test.sh` that passes locally, and an in-progress TASK-001 with a one-line diff. A stub `gh` first on PATH answers `run list` with one failed `ci` run (`runs/4242`). Command, in each fixture's cwd: brief on stdin to `claude -p --disable-slash-commands --permission-mode acceptEdits --add-dir %TEMP%\d253\<old|new> --allowedTools "Bash(git:*)" "Bash(gh:*)" "Bash(sh:*)" "Bash(bash:*)"`, with PATH prefixed by the stub's folder. Brief: `/tasks close TASK-001 --unattended`, no further input, quote what the gate and confirmation printed. Coldness: all six runners listed **no** skills. Three pairs, two void:
  - pair 1 (no remote): new printed `ci: not read — no git remote configured`, a correct answer the step had not listed; "no remote" added to the reasons. Old printed no CI line.
  - pair 2 (remote, but `test.sh` failing locally): void for the old side. It reported "CI red on every push" by inferring it from the failing local test, not by reading CI. That contradicts the plan's premise (local tests pass).
  - **pair 3 (the plan's premise): old 0/1 named the red CI**: no CI line, closed `done` silently. **New 1/1**: `ci: main RED at 9f3c2a1 — ci: https://github.com/acme/stockcount/actions/runs/4242` at the gate and again in the confirmation, and the close still reached `done` (warn, not hold).
  Fix-dependent: the pair-3 red-CI drill. Contract pins, not evidence: the lint; pair 1's `not read` line is new behaviour with no old-text counterpart to fail.
- step 7 — respecced work-tracking (no other `skills/tasks` change since its stamp 20c038b); requirements changed: added *The default branch's CI is reported at the gate, and never holds it* (scenarios *CI red on the default branch*, *No way to read CI*); *Merge decided before the status is written* now names the `ci:` line in the question; *Unattended close contract* now lists printing the CI line without asking.
- step 6 (addendum) — after the review fixes changed the line's shape, pair 3's new side was re-run on the final text: `ci: main RED — ci failure at 9f3c2a17…: https://github.com/acme/stockcount/actions/runs/4242`, at the gate and in the confirmation; TASK-001 reached `done`.
- step 7 (addendum) — the review fixes also changed `skills/fix-next/SKILL.md` (report item 3), so defect-draining was respecced (stamp eebeb6e; TASK-193's `57fedb5` had already re-harvested it): *the final report* now includes a red `ci:` line. work-tracking's new requirement was updated for the park path, the conclusion mapping and task-only confirmation.
- step 8 — closed done; committed as `TASK-253: …` on main (single-branch), sha in `git log`.
