---
id: TASK-315
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-WT-3]
pr: null
github-issue: null
jira-key: null
---

# move.md never states the reopen it performs

## Context

Raised by the spec harvest of work-tracking (2026-10-13). `skills/tasks/SKILL.md` names `move` as a reopen trigger that does not ask (an open task moved in reopens a `done` or `cancelled` parent). `skills/tasks/verbs/move.md` step 6 only points at SKILL.md § *Roll status up to parents*, so a reader of the verb file alone cannot see that moving a task can reopen its new parent, or that it does so without asking. AGENTS.md: a verb file must be readable standalone.

## Acceptance criteria

- [ ] move.md states, in its own words, that an open task moved under a `done` or `cancelled` container reopens it without asking, and why (the person named the target)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing what move does

## Human test plan

N/A — wording only; behaviour unchanged.

## Implementation plan

_Populated by `/tasks plan TASK-315` — leave empty until then._
