---
id: TASK-287
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

# `/specs regen` flags a requirement it writes or rewrites past ~500 characters

## Context

FEATURE-004 D1. Measured 2026-10-08: 131 of the 383 requirements in `docs/specs/` run past 500 characters, the longest at 1,576. OpenSpec v1.14.1 warns past 500 and fails under `--strict`. The owner chose to flag only what a regen writes or rewrites, and never to split untouched requirements, so the spec diff stays reviewable.

## Acceptance criteria

- [ ] Regen flags each requirement it adds or changes whose statement exceeds the threshold, and suggests a split
- [ ] An untouched requirement is never flagged, so the flag never pushes against the stable-wording rule
- [ ] The threshold and the reason for it are stated once, in the verb that owns them
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Splitting existing long requirements in bulk (out of scope for FEATURE-004)

## Human test plan

- [ ] Drill: install the changed skill and run `/specs regen <area>` on a real area of this repo, or on a fixture spec staged to exercise the change. Record how the runner was obtained (AGENTS.md § Testing); a long new requirement is flagged, and a long untouched one is not

## Implementation plan

_Populated by `/tasks plan TASK-287` — leave empty until then._
