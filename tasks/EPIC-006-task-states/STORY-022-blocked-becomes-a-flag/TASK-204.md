---
id: TASK-204
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-197, TASK-198, TASK-199, TASK-200, TASK-201, TASK-202, TASK-203, TASK-196]
blocks: [TASK-205]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Contract: every writer switches to the new form

## Context

The contract phase of FEATURE-003: it depends on every batch. Before this, nothing writes the new form.
After it, nothing writes the old one, while every reader keeps the permanent legacy reading (the
alias is not removed, because copies in consumer repos are out of reach).

The behaviour decisions land here, because they live in the writers: D2 (unblock keeps the state),
D3 (a deferred merge is `in-progress` + `blocked: merge deferred`), D6 and D7 (`pick` offers a flagged
task with a warning and asks *"Unblock and start?"* when it is chosen).

**Writers outside `tasks` found by the migrate batches** (so this task reaches them too):
`feature/verbs/decide.md` (a change landing on a closed feature reopens its task `done → review`) and
`feature/verbs/pick.md` (the same revert, named in an edge case). Both must write `verify`. Found by
TASK-197.

## Acceptance criteria

- [x] `block` writes the `blocked:` field and leaves `status:` alone; `unblock` removes the field and leaves `status:` alone (D2)
- [x] `close` writes `verify` instead of `review`, and a deferred merge is `in-progress` + `blocked: merge deferred` (D3); "done means merged" still holds
- [x] `pick` lists a flagged task with its reason (D6), and choosing it puts *"TASK-NNN is blocked: <reason>. Unblock and start?"*, with the answer-less path stated (D7)
- [x] The TASK template's status comment lists the new vocabulary and the `blocked:` field
- [x] `git grep` for code that writes `status: blocked` or `status: review` in `skills/` finds none. The legacy readers remain
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Rewriting existing files: TASK-203 and TASK-205

## Human test plan

- [x] Cold drill through a real task: pick → block → unblock → close with a manual step pending. The file never reads `blocked` or `review`, and the task returns to the state it had after unblocking.
  - **Run 2026-10-01, passed.** Fixture: `%TEMP%/d204`, a git repo with `integration: single-branch` and two tasks rendered from the new template: TASK-001 `todo`; TASK-002 `todo` + `blocked:`. Runner: `claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(grep:*)" "Bash(ls:*)" Read Grep Glob Edit Write Skill --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills < brief.txt`. Its steps were pick → block → unblock → `close --unattended` → pick TASK-002, with nobody to answer, and the brief did not state the expected states. **Independent check from the fixture's git history**, TASK-001 per commit:
    - pick: `in-progress`;
    - block: `in-progress` + `blocked: waiting on the copy review` (D1);
    - unblock: `in-progress`, back where it was (D2);
    - close: `verify`.

    `git log -p` shows no old-form value ever written. Step 5 put D7's question verbatim and, with no answer, reported `not started: TASK-002 is blocked: …` and changed nothing. Two gaps the runner raised were fixed in place: the park commit template still said `review`, and `block`'s in-progress question had no answer-less path.
  - **Not drilled, and stated rather than implied:** the deferred-merge path (`in-progress` + `blocked: merge deferred`) needs a `pr-per-task` fixture, and D6's list rendering, because the runner picked TASK-002 by id rather than from the list. Both are text-only. TASK-205's runs on real consumer trees are the next chance to see D6.

## Implementation plan

Planned inline at pick (2026-10-01). Measured every writer of `review`/`blocked` first.

**Changed:**
- `block`/`unblock`: the field, never the status. The old form's unblock reads history as `init` 3b does.
- `close`: the park writes `verify`; a deferred merge is `in-progress` + `blocked: merge deferred`.
- `pick`: D6 lists blocked tasks; D7 asks its question and states the answer-less path.
- `spawn`, `slicing`, `triage` (marker and row), the TASK and README templates.
- The normative vocabulary line and the Lifecycle prose in `tasks/SKILL.md`.
- `fix-next`'s debt line, and `feature`'s `decide.md`/`pick.md` reopen lines (found by TASK-197).
- `export`'s title guard learns the new `# blocked:` template comment, so TASK-192's fix is not undone.
- `docs/glossary.md`'s task-state sense of *review*.

**Left alone:** every use of `review` meaning the feature gate or the feature's own marker.

## Progress log

- 2026-10-01 — Picked; measured; edits made; lint OK.
- 2026-10-01 — Drill passed (record above); two gaps fixed in place.
- 2026-10-01 — Close review:
  - **Standards:** pass. The vocabulary is defined once and the writers point at it. D7's ask-step carries its question and its answer-less path, and so does `block`'s new one. The template ships the `blocked:` line commented, because absence is the "not blocked" state (AGENTS.md § *A template ships nothing a render cannot make true*).
  - **Intent:** pass, all 6 criteria met. `git grep` for an old-form writer finds only readers, the migration and the history-reading unblock.
  - **Correctness:** pass. The history trace shows every transition as decided.
  - **Security:** not applicable.
  - **Comments:** not applicable.
- 2026-10-01 — Out of scope, recorded rather than filed. The runner noted older gaps in the in-place path: no commit is defined for an in-place pick/block/unblock; a bare-id pick skips 2b's debt nudge; an in-place park leaves the regenerated dashboard uncommitted; the `pr:` prompt has no wording. None of them changes this story's behaviour.
