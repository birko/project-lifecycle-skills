---
id: TASK-231
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
findings: [SH-14]
pr: null
github-issue: null
jira-key: null
---

# `roadmap` states DV10's trigger twice, and the two statements contradict

## Context

Found by the project-roadmap spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-14.** `skills/roadmap/SKILL.md` step 2b says that when the spec map is absent or still the empty seed, DV10
  fires "if the project has real code (a `src/` tree or a build manifest with tracked source files)". The section
  *DV10: what counts as code* opens with "**Do not ask for a `src/` tree or a build manifest**" and puts that test
  third on a four-rung ladder, after the map's `ignore:` list and what the repo's gate runs over, ending in silence.
  The DV10 table row itself points at the ladder section. A reader of step 2b alone gets the test the ladder was
  written to replace, and this repo is the measured case where that test never fires (source is `skills/**/*.md`).

## Acceptance criteria

- [ ] Step 2b defers to *DV10: what counts as code* rather than restating a trigger, so DV10's condition is stated in
      one place
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The other DV rules in this pass — TASK-232 (DV5), TASK-207 (DV1/DV4)

## Human test plan

N/A — a pointer replacing a restated condition, checked by reading step 2b, the DV10 row and the ladder together.

## Implementation plan

_Populated by `/tasks plan TASK-231` — leave empty until then._
