---
id: TASK-321
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
findings: [FIELD-017]
pr: null
github-issue: null
jira-key: null
---

# `/feature pick`'s decompose offer has no answer-less path

## Context

Found by TASK-319's post-fix drill (2026-10-14). `skills/feature/verbs/pick.md` gate D puts "N approved decision(s) have no tasks. Decompose now? [Y/n]" and its step 4 defines only `Y` and `n`. With nobody to answer, the runner stopped and said the instructions give no path for silence, while gate Q in the same file says "Silence is not a no." AGENTS.md § Output/prose rules requires every ask-step to state its answer-less path.

## Acceptance criteria

- [ ] Gate D's offer (and step 4) states what the run does when nobody answers, and what it reports
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Gate D's condition

## Human test plan

- [ ] A cold runner reaches gate D with nobody to answer. Expected: it takes the stated answer-less path and reports it, without saying the instructions left it undefined.

## Implementation plan

_Populated by `/tasks plan TASK-321` — leave empty until then._
