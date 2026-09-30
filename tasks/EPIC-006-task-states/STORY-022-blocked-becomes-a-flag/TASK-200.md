---
id: TASK-200
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: `specs regen`'s state gate reads `verify`

## Context

A migrate batch of FEATURE-003 (owner group: `skills/specs/`). `regen`'s inferred-evidence gate reads task
statuses, including the leading status comment the task template emits. Both must accept the new form.

## Acceptance criteria

- [ ] `specs/verbs/regen.md`'s state gate accepts `verify` wherever it accepted `review`, and reads a flagged task by its state
- [ ] The quoted template status comment matches what the template emits after TASK-204, and still matches older files
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing which states count as evidence

## Human test plan

- [ ] N/A — the gate is a reading rule with no user-visible surface. The TASK-205 migration run on a consumer repo re-runs a regen and compares it with the pre-migration map.
