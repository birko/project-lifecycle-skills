---
id: TASK-288
parent: STORY-026
feature: FEATURE-004
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen --all` writes each area as soon as its review is accepted

## Context

FEATURE-004 D5. `regen` step 3 harvests every area, then runs the reviews one after another, and nothing says when each area is written, so an interrupted `--all` run is all-or-nothing in practice. OpenSpec v1.14.1 writes each capability's spec as soon as it is drafted, so an interrupted run keeps them.

## Acceptance criteria

- [ ] Under `--all`, each area is written (step 5) as soon as its own review is accepted, before the next review starts
- [ ] A re-run after an interruption can tell which areas are already current, and says so
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Running the reviews in parallel: they stay one at a time, because each is a conversation with a person

## Human test plan

- [ ] Drill: start `/specs regen --all` on a fixture with three areas, stop after the second review, and re-run. The first two areas are kept and reported as current

## Implementation plan

_Populated by `/tasks plan TASK-288` — leave empty until then._
