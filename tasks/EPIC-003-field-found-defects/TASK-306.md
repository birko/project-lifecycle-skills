---
id: TASK-306
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-303-1]
pr: null
github-issue: null
jira-key: null
---

# With an upstream, a park can miss a story whose `done` waits on an unlanded `record/` branch

## Context

Found by the correctness pass at TASK-303's close (2026-10-13). With an upstream, a container close commits `done` on `record/STORY-NNN` and restores the main copy (TASK-296, `skills/tasks/verbs/close.md` § *Closing a STORY / EPIC* step 5). Until that branch lands, the main copy's `STORY.md` still reads `in-progress`. A `/feature review` that parks one of its tasks at `verify` meanwhile reopens nothing, because nothing reads `done` yet ([[tasks]] § *Roll status up to parents*, the reopening direction). When the record branch lands, the story reads `done` over a `verify` child, the contradiction TASK-303 removed.

## Acceptance criteria

- [ ] The reopening rule, or the record-branch rule, states what happens when a task's container has an unlanded `record/<ID>` branch: the park reports it by name, so a person reopens or re-records before landing
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-upstream path, where the close is committed on the default branch and the reopen sees it

## Human test plan

- [ ] On an upstream fixture, close a STORY (leaving `record/STORY-NNN` unlanded), then run `/feature review` so it parks one of that story's tasks. Expected: the report names the unlanded record branch.

## Implementation plan

_Populated by `/tasks plan TASK-306` — leave empty until then._
