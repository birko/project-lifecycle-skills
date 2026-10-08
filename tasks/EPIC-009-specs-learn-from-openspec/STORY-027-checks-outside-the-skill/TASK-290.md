---
id: TASK-290
parent: STORY-027
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

# `skills-lint.sh` fails a structurally broken spec file

## Context

FEATURE-004 D4. Nothing checks `docs/specs/*.md`. OpenSpec's validator (v1.9.0 to v1.13.1) reports a placeholder Purpose, a scenario with no body, and requirement names that differ only in case. The owner chose the CI lint, so a broken spec fails the build here.

## Acceptance criteria

- [ ] A new lint check fails a spec whose `## Purpose` is empty or a placeholder
- [ ] It fails a `#### Scenario:` with no Given/When/Then lines
- [ ] It fails two `### Requirement:` names in one spec that differ only in case
- [ ] Each of these has a case in `skills-lint-test.sh` that fails without the change, and AGENTS.md § Testing and its test count are updated
- [ ] Every current spec passes, or each failure is fixed by `/specs regen` within this task
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Checking consumers' specs: the owner chose this repo's CI, not `/specs verify`

## Human test plan

N/A — covered by the new lint cases, which must fail without the change (AGENTS.md § Testing).

## Implementation plan

_Populated by `/tasks plan TASK-290` — leave empty until then._
