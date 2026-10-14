---
id: TASK-318
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-014]
pr: null
github-issue: null
jira-key: null
---

# `/tasks plan` asks whether to grill the plan and never says what happens when nobody answers

## Context

Found by TASK-313's cold drill (2026-10-14). `skills/tasks/verbs/plan.md` step 7 says only: *Print: "Draft plan written. Grill it via `grill-me`? [y/N]"*. It states no answer-less path, which AGENTS.md § Output/prose rules requires of every ask-step. The runner, with nobody present, took the capitalised `N` as a default and said it had inferred it. `new` chains `plan` on every task it files, so every unattended `/tasks new task` reaches this question.

## Acceptance criteria

- [ ] `plan.md` step 7 states its answer-less path, and what the run reports when nobody answers
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The grill itself ([[grill-me]])

## Human test plan

- [ ] A cold runner files a task with nobody to answer. Expected: it quotes the grill question, takes the stated answer-less path, and reports it without calling it inferred.

## Implementation plan

_Populated by `/tasks plan TASK-318` — leave empty until then._
