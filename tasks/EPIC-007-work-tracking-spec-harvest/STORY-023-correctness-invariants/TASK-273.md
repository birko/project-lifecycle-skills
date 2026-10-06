---
id: TASK-273
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-90, SH-95, SH-100]
pr: null
github-issue: null
jira-key: null
---

# Ask-steps in `tdd`, `populate-tests`, `domain` and `roll-changelog` state no question or no answer-less path

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

AGENTS.md § *Output / prose rules* requires every ask-step to carry the question actually put **and** what the run does when no answer comes.
- **SH-90 (partly confirmed):** `skills/tdd/SKILL.md:83-90` has its question text (`:90`) but no answer-less path. `skills/populate-tests/SKILL.md:15` ("offer to seed the convention first") has neither.
- **SH-95:** `skills/domain/SKILL.md:36` ("offer to start one") and `:85` ("Offer one") have no question text and no answer-less path. `:50` has its question but no answer-less path.
- **SH-100:** `skills/roll-changelog/SKILL.md:20`, `:44`, `:52`, `:57`, `:61` and `:65` ask with no question text and no answer-less path. `:44` ("ask the user what shipped") is the riskiest: with no answer, the run has no source of work at all.

The same defect class as TASK-229, TASK-230, TASK-247 and TASK-259, in four more skills; one PR can fix all four.

## Acceptance criteria

- [ ] Every ask-step in the four skills quotes the question it puts
- [ ] Every ask-step states what the run does when no answer comes, as a reported unresolved state, never a value that reads as decided
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ask-steps in other skills (their own tasks)

## Human test plan

- [ ] Run `/roll-changelog` in a scratch repo with nobody answering, and confirm it ends in the stated unresolved state rather than stalling or inventing an answer

## Implementation plan

_Populated by `/tasks plan TASK-273` — leave empty until then._
