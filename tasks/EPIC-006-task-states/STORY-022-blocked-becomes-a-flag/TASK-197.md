---
id: TASK-197
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
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

- [ ] `feature/SKILL.md`'s Collection note, `status.md`'s phase derivation and `review.md`'s gates read both forms, pointing at `tasks/SKILL.md` § *Lifecycle* rather than restating it
- [ ] Prose that names the old `review` task status uses the new name; the feature's own `status: review` (the coarse marker in `idea.md`) is **not** renamed, because it is a different field
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature's own coarse marker (`idea | review | done | dropped | superseded`) — a different vocabulary, unchanged

## Human test plan

- [ ] Run `/feature status` on a fixture feature whose tasks mix `review`, `verify` and a flagged `in-progress` task: the phase and counts match what the old form produced.
