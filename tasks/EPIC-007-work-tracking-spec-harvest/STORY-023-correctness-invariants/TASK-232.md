---
id: TASK-232
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-15]
pr: null
github-issue: null
jira-key: null
---

# DV5 flags every story that has no feature behind it, including the ones that should not have one

## Context

Found by the project-roadmap spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-15.** `skills/roadmap/SKILL.md` § 4, DV5's second arm: "a story/epic with tasks but no feature folder". Many
  stories legitimately have no feature: review-intake stories (this epic's own two), defect stories, chores, tree
  hygiene — everything the [[tasks]] skill tracks that carries no stakeholder decision. As written, each is reported
  under *Tracked in one tree only*, which the full render calls "the real planning holes". On a tree like this one the
  arm reports mostly correct structure, and a check that does that gets ignored (the same failure TASK-032 describes
  for divergences that cannot be accepted).

## Acceptance criteria

- [ ] DV5's second arm states which stories and epics it applies to, and excludes at least `kind: review-intake`
      epics and their stories, read from a declared field rather than inferred from a title
- [ ] The criterion says what a story with no feature must carry, if anything, to be recognised as feature-less on
      purpose, or why nothing is needed
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Recording a divergence as accepted — TASK-032
- DV1/DV4 — TASK-207

## Human test plan

- [ ] Run `/roadmap --check` on this repo before and after: the DV5 hits that remain are each a requirement tracked in
      one tree only, by reading them

## Implementation plan

_Populated by `/tasks plan TASK-232` — leave empty until then._
