---
id: TASK-314
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
findings: [SH-WT-2]
pr: null
github-issue: null
jira-key: null
---

# SKILL.md re-checks the epic only above a reopened story, while new.md checks it either way

## Context

Raised by the spec harvest of work-tracking (2026-10-13). `skills/tasks/SKILL.md` § *Roll status up to parents* re-evaluates the epic "above a reopened STORY". `skills/tasks/verbs/new.md` step 10 (TASK-308) checks it "whether or not the story was reopened", because a `planned` story can sit under a `done` epic. The verb is the superset; the router's rule is narrower, so a verb that follows only the router misses that case.

## Acceptance criteria

- [ ] SKILL.md § *Roll status up to parents* states the epic check the way new.md step 10 does, or new.md points at a router rule that covers it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other roll-up wording

## Human test plan

N/A — a one-sentence alignment between two files; the lint covers the link, and TASK-308's drill already exercises the path.

## Implementation plan

_Populated by `/tasks plan TASK-314` — leave empty until then._
