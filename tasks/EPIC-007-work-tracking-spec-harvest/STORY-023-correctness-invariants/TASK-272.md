---
id: TASK-272
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-87]
pr: null
github-issue: null
jira-key: null
---

# `/populate-tests survey` promises no edits, but chains `adopt`, which writes files

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-87:** `skills/populate-tests/SKILL.md:41-42` says **survey** makes "No edits". Lines 39-40 have survey and populate call `adopt` first when no harness is found, and `adopt` scaffolds a test directory, a runner config and a pinned dev dependency (`:34`). A bare `/populate-tests` defaults to survey (`:31`), so the read-only default can write files into a repo with no harness.

## Acceptance criteria

- [x] `survey` either makes no edits in every case (it reports "no harness — run `/populate-tests adopt`" instead of chaining adopt), or its description says it may scaffold a harness first; the two lines no longer contradict
- [x] A bare `/populate-tests` on a repo with no harness does what the chosen wording says
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Whether `adopt` reconciles an existing harness (TASK-024)

## Human test plan

- [x] Run `/populate-tests` with no verb in a scratch repo that has no test harness, and confirm the files it writes, if any, match what `survey` promises

## Implementation plan

Decided at step 4, before the edit, and written here at close: `/fix-next` runs no `/tasks plan` (TASK-135 is that gap).
1. Take the stricter of the two exits the first criterion allows: survey makes no edits in every case, and only `populate` chains `adopt`. Survey is the bare default, the one a user runs to look.
2. With no harness found, survey reports every surface untested and ends by naming `/populate-tests adopt`.
3. Regenerate `test-authoring`'s survey requirement and its no-harness scenario, and prove it with a cold drill on the old and the new text.

## Outcome

- **The fix:** a bare `/populate-tests` (which runs `survey`) promised to only look, but on a repo with no test setup it first ran `adopt`, which writes a test directory, a runner config and a dependency. Survey now never edits: with no harness found (neither a test dir nor a runner config, the test REFERENCE.md § Adopt uses) it reports every surface untested and ends `no harness — run /populate-tests adopt to wire one`. Only `populate` still chains `adopt`.
- **Step-6 split:** a cold drill on the pre-fix text wrote 3 paths (1/1 failed); the same drill on the fixed text wrote none (0/1). Fix-dependent: that no-harness survey drill. Contract pin, not evidence: the lint.
- **Judgement call:** the first criterion allowed either wording. The stricter one (survey never writes) was taken over "survey may scaffold a harness first", because survey is the bare default, the command a user runs to look; disclosing the write would still write files nobody asked for.
- **Flagged, not fixed:** `verify` and `ledger` still say nothing about a repo with no harness (correctness review, pre-existing) → TASK-283.
- **Close gate (step 5b), each axis on its own:**
  - **Standards:** pass. One suggestion: progress-log steps 6 and 7 were out of order. Reordered.
  - **Fidelity:** pass, no findings.
  - **Correctness:** no blocking defect. Fixed from it: "no harness" now names its test, so a repo with tests but no runner config is surveyed normally; the spec's "only `populate`" now reads "of the five modes", so it no longer contradicts a scaffolder calling `adopt`. Spawned: TASK-283. Accepted: the spec's `generated-at` is the pre-commit HEAD, the documented normal case (`regen.md`).
  - **Security / comments:** not applicable (no input handling, no code comments).
  - **Out of scope (5d):** 1 boundary (TASK-024), owned; 0 spawned from it.

## Progress log

- step 2 — picked; ranked above TASK-256 because both write into a consumer repo uninvited or wrong (key 1 tie), and this one is reached from the bare default `/populate-tests` while TASK-256 needs an adopt on a guide missing two sections (key 2, reachability). Key 6 inert: both declare `correctness-invariants`.
- step 3 — verified: held as written. `SKILL.md:39-40` has `survey`/`populate` call `adopt` when no harness is found, `:41-42` says survey makes "No edits", `:31` makes survey the bare default. `REFERENCE.md` says nothing about survey. `docs/specs/test-authoring.md:199` records the contradiction as shipped.
- step 4 — layer: local (the rule and its contradiction are both in `skills/populate-tests/SKILL.md`).
- step 5 — fix in `skills/populate-tests/SKILL.md` (adopt and survey bullets): only `populate` chains `adopt`; survey makes no edits in every case and with no harness ends `no harness — run /populate-tests adopt to wire one`. Prose repo: the regression check is the drill below (step 6), the lint the floor; lint OK.
- step 6 — reintroduce-and-confirm, as two cold drills (run in parallel with step 7). 2 fixtures, the same tiny Node repo with no harness (`%TEMP%\d272\repo-old`, `repo-new`); one runner reads the pre-fix `SKILL.md`, the other the fixed one. Command, in each fixture's cwd: brief on stdin to `claude -p --disable-slash-commands --permission-mode acceptEdits --add-dir %TEMP%\d272\<old|new>` (the skill copy and `REFERENCE.md`). Brief: list your skills, then act on a bare `/populate-tests` exactly as the skill file says, with no further user input, and list every file changed. Coldness: both runners listed **no** skills. Split: **old 1/1 wrote files** (`package.json` modified, `.gitignore` and `tests/README.md` created, per `git status`); **new 0/1** (clean `git status`, report ends `no harness — run /populate-tests adopt to wire one`). Fix-dependent: the no-harness survey drill. Contract pins: the lint (passes before and after; it checks no prose meaning).
- step 7 — respecced test-authoring (no other source change since its stamp 20c038b); requirements changed: *Five modes with survey as the default* (survey makes no edits in any case; only populate chains adopt) and its scenario *Survey in a repo with no harness*. Diff is 4 lines, all intended.
- step 8 — closed done; committed as `TASK-272: …` on main (single-branch), sha in `git log`.
