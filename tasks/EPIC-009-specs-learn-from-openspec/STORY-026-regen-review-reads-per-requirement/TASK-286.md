---
id: TASK-286
parent: STORY-026
feature: FEATURE-004
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: [TASK-285]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen` names every scenario a regeneration dropped

## Context

FEATURE-004 D3. Nothing in `regen` compares scenarios before and after, so a regeneration that loses a `#### Scenario:` passes review unless a reader happens to spot it. OpenSpec (v1.8.0, v1.9.0, v1.13.2) fails a MODIFIED requirement that would drop a scenario, and names the scenario.

## Acceptance criteria

- [ ] Regen compares the old and new scenarios of each requirement that survives, and names every one that disappeared
- [ ] Before the spec is written, each lost scenario is either explained as behaviour that is really gone (a finding, classified as in step 4) or restored
- [ ] A renamed requirement (TASK-285) is compared against the scenarios under its old name
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The scenarios of a requirement removed as a whole: the removal itself is the finding

## Human test plan

- [ ] Drill: install the changed skill and run `/specs regen <area>` on a real area of this repo, or on a fixture spec staged to exercise the change. Record how the runner was obtained (AGENTS.md § Testing); a scenario deliberately left out of the harvest is named in the review

## Implementation plan

_Populated by `/tasks plan TASK-286` — leave empty until then._
