---
id: TASK-205
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-203, TASK-204]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Run the migration on this repo and every consumer repo

## Context

The last step of FEATURE-003. Measured on 2026-09-30: 40 `blocked` tasks across Presenter, Symbio,
WorkoutTracker, Birko.Framework and DraCode, and 31 `review` tasks across seven repos, this one included.
Each repo is migrated with TASK-203's tool and the change lands through that repo's own integration policy.

## Acceptance criteria

- [ ] Every repo in the measurement is migrated, or its skip is recorded with the reason
- [ ] Per repo: counts before and after, and every task whose prior state had to be asked
- [ ] This repo's own tree carries no old-form status
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Repos that do not use these skills

## Human test plan

- [ ] The owner opens `/tasks` in two migrated consumer repos and confirms the blocked tasks show their real state and reason.
