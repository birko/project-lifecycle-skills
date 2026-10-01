---
id: TASK-197
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: the `feature` skill reads `verify` and the blocked flag

## Context

A migrate batch of FEATURE-003 (owner group: `skills/feature/`). Its readers bucket a feature's tasks by
status for the phase, the rollup and the review gate. They must read `verify` (and legacy `review`) as
awaiting verification, and a flagged task as still in its state.

## Acceptance criteria

- [x] `feature/SKILL.md`'s Collection note, `status.md`'s phase derivation and `review.md`'s gates read both forms, pointing at `tasks/SKILL.md` § *Lifecycle* rather than restating it
- [x] Prose that names the old `review` task status uses the new name; the feature's own `status: review` (the coarse marker in `idea.md`) is **not** renamed, because it is a different field
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature's own coarse marker (`idea | review | done | dropped | superseded`) — a different vocabulary, unchanged

## Human test plan

- [x] Run `/feature status` on a fixture feature whose tasks mix `review`, `verify` and a flagged `in-progress` task: the phase and counts match what the old form produced.
  - **Run 2026-10-01, passed.** Fixture: `%TEMP%/d197`, two features. FEATURE-001 has tasks `done`, `verify` and old `review`; FEATURE-002 has `done` and `in-progress` + `blocked:`. Runner: `claude -p --allowedTools "Bash(git:*)" "Bash(grep:*)" "Bash(ls:*)" Read Grep Glob Skill --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills < brief.txt`, run from the fixture. It had the installed skills; the brief was read-only and did not state the expected phases. Result: FEATURE-001 → `review (awaiting sign-off)`, with `verify` and `review` both in the review bucket; FEATURE-002 → `building`, the flagged task counted in-progress and also blocked. That is what the old form gives when both review tasks read `review`. The runner's other notes predate FEATURE-003 (the phase/`status.md` circularity, `building` vs `review` precedence, a stale `idea` marker that no rule catches, the digest's done/total hiding verify tasks). Its note 6 was a fault in the fixture (done tasks with unticked test-plan boxes).

## Implementation plan

Planned inline at pick (2026-10-01). Three readers of the **task** status: `feature/SKILL.md`'s Collection note, `status.md`'s `review` phase rule, and `pick.md`'s surfacing line. Each now points at [[tasks]] § *Lifecycle*. The feature's own coarse `review` marker is deliberately untouched, and the router now says so. Two **writers** were found in `feature` (`decide.md` and `pick.md`, both reopening a task `done → review`) and recorded on TASK-204, which owns writers.

## Progress log

- 2026-10-01 — Picked; planned inline. Edits made; lint OK.
- 2026-10-01 — Drill passed (record above).
- 2026-10-01 — Close review. **Standards:** pass. It points at the `tasks` vocabulary and restates nothing, and the two-vocabulary distinction is stated where a reader would conflate them. **Intent:** pass, all 3 criteria met. **Correctness:** pass. The phase rule's old-form reading is unchanged. **Security:** not applicable. **Comments:** not applicable.
