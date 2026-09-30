---
id: TASK-198
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

# Migrate: `roadmap`'s cross-tree pass reads `verify` and the blocked flag

## Context

A migrate batch of FEATURE-003 (owner group: `skills/roadmap/`). The cross-tree pass joins tasks to
features and runs the divergence rules; any rule keyed on a task status must read both forms.

## Acceptance criteria

- [ ] Every status the cross-tree pass and the divergence rules read accepts both forms, by pointer to `tasks/SKILL.md` § *Lifecycle*
- [ ] A flagged task is never reported as a divergence merely for carrying the flag
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature coarse marker — unchanged

## Human test plan

- [ ] `/roadmap --check` on the TASK-197 fixture reports the same divergences as on an all-old-form copy of it.
