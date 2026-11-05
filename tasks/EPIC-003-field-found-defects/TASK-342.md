---
id: TASK-342
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/feature pick` words gate B's question twice

## Context

Found while planning TASK-336 (2026-11-04, a split signal in its plan, left unspawned), in `skills/feature/verbs/pick.md`. Gate B's question appears in the step-3 gate table as "N decision(s) still awaiting a verdict. Decide them now? [Y/n]" and again in the gate A–C questions table as "FEATURE-NNN has N decision(s) still awaiting a verdict: <ids>. Decide them now? [Y/n]". TASK-336 fixed the same doubling for gate D by making the gate-table cell point at the one wording. AGENTS.md's ask-step rule wants the question actually put, once.

## Acceptance criteria

- [ ] Gate B's question is worded once; the gate-table cell points at it, as gate D's now does
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

N/A — one ask-step's wording; the reviewer check against the AGENTS.md ask-step rule at close covers it

## Implementation plan

_Populated by `/tasks plan TASK-342` — leave empty until then._
