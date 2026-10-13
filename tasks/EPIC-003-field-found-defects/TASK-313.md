---
id: TASK-313
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
findings: [SH-WT-1]
pr: null
github-issue: null
jira-key: null
---

# A new task under an open story whose epic is cancelled leaves open work under the cancelled epic, unreported

## Context

Raised by the spec harvest of work-tracking (`/specs regen`, 2026-10-13). `skills/tasks/verbs/new.md` step 10 checks the epic above a parent story and says a `cancelled` one "asks first, as step 4 does". Step 4's question and its answer-less path ("file under the nearest ancestor that is not cancelled") are written for a cancelled **parent**. Here the parent story is open, so the item lands in it, and with no answer the cancelled epic is left over open work with nothing defining the outcome or reporting it.

## Acceptance criteria

- [ ] Step 10 states the question for a cancelled epic above an open parent story, verbatim
- [ ] It states the answer-less outcome, and that outcome is reported, never silent
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- A cancelled direct parent (TASK-308 covers it)

## Human test plan

- [ ] A cold runner files a task in an open story under a cancelled epic with nobody to answer. Expected: it quotes the question and reports what it left, and the epic is not silently left `cancelled` over open work without a report.

## Implementation plan

_Populated by `/tasks plan TASK-313` — leave empty until then._
