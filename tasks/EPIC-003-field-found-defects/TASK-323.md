---
id: TASK-323
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
findings: [CR-322-3]
pr: null
github-issue: null
jira-key: null
---

# A feature parked at `review` drops out of "verification debt first" while a new row waits to be decomposed

## Context

Found by TASK-322's close review (2026-10-14). Since TASK-322, `skills/feature/verbs/status.md` § *Compute the phase* rule 2 makes any feature with an undecomposed `approved`/`changed` row read `building`, whatever is stored. That is right for an unbuilt change. But `/feature review` step 5 can park a feature at stored `review` with tasks at `verify`, and Gate C's "stakeholder requests changes" path then adds a row through `decide`. Until that row is decomposed and built, the feature reads `building`: the listing orders it after `review`-phase features (`skills/feature/SKILL.md` § verification debt first), and `pick`'s gate E stays silent. `pick` step 5 still surfaces the `verify` tasks at hand-off, but only after decompose.

Undecided: should outstanding `verify` sign-off on such a feature still lead the listing (and if so, by which rule), or is `building` the honest headline because the stakeholder asked for more work?

## Acceptance criteria

- [ ] The rule for a feature that has both `verify` tasks awaiting sign-off and an undecomposed row is written down in `status.md` (or `SKILL.md`'s ordering rule), with the reason
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The unbuilt-change case itself (TASK-322)

## Human test plan

- [ ] On a fixture feature stored at `review` with one task at `verify` and one new `approved` row with no tasks, run `/feature` (bare listing) and `/feature pick`. Check the ordering and offers match the rule written.

## Implementation plan

_Populated by `/tasks plan TASK-323` — leave empty until then._
