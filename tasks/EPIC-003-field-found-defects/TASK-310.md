---
id: TASK-310
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
findings: [CR-309-1, CR-309-2]
pr: null
github-issue: null
jira-key: null
---

# `/tasks new`'s `affects:` question has no answer-less path, and nothing reads the "inferred, not chosen" mark

## Context

Grouped: two follow-ups the correctness pass raised at TASK-309's close (2026-10-13), both about how
`skills/tasks/verbs/new.md` handles a field nobody answered.

- **CR-309-1.** Step 8's `{{AFFECTS}}` says "ask the user which sub-projects it affects" with no question
  text and no answer-less path, the one ask left in `new.md` outside AGENTS.md § Output/prose rules. An
  empty `affects: []` written unasked reads as "affects nothing". TASK-309 drafted a fix and reverted it as
  outside its criteria.
- **CR-309-2.** TASK-309 added the mark `> Filed with nobody to answer — inferred, not chosen: <fields>.`
  under a new file's heading. Nothing reads it: `triage`, `pick`, `close` and `audit` never surface it, so a
  task with an inferred parent or priority can be ranked, picked and closed with the mark still there, and
  "whoever confirms deletes the line" has no verb to prompt it.

## Acceptance criteria

- [ ] Step 8's `affects:` question is stated verbatim, with an answer-less path that does not read as decided
- [ ] At least one reader surfaces a file carrying the mark (for example `pick` prints it, or `triage`/`audit` lists it)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The questions TASK-309 covered

## Human test plan

- [ ] A cold runner creates an epic in an aggregator repo with nobody to answer, then picks a task that
      carries the mark. Expected: `affects` is marked, not silently `[]`, and the pick shows the mark.

## Implementation plan

_Populated by `/tasks plan TASK-310` — leave empty until then._
