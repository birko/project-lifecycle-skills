---
id: TASK-201
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

# Migrate: both front doors ship the new status vocabulary

## Context

A migrate batch of FEATURE-003 (owner group: `skills/new-project/` + `skills/adopt-project/`, one owner under
the layer-parity rule). The seeded rulebook and the templates the scaffolder renders name the task
statuses. Rendered copies in consumer repos are out of reach, which is why the legacy reading is permanent.

## Acceptance criteria

- [ ] Every seeded or rendered text naming a task status uses the new vocabulary, with no copy of the status list: it points at the `tasks` skill
- [ ] `skills/new-project/LAYER.md` is changed if it names task statuses, and the adopter reconciles the same wording
- [ ] The comment-rule markers are untouched, so lint check 5 stays green
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Rewriting consumer repos' already-rendered guides — out of reach by design

## Human test plan

- [ ] Scaffold a throwaway project with `/new-project` and read its guide: the statuses named are the new ones, and nothing lists them twice.
