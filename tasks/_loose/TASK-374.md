---
id: TASK-374
parent: null
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: human
created: 2026-11-14
depends-on: [TASK-124]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Retire FEATURE-003's state-model playground once TASK-124's test no longer needs it

## Context

Raised 2026-11-14 by two cold runners of `/feature status` (`%LOCALAPPDATA%/Temp/d067r/report-run1.md` point 10, and
`%LOCALAPPDATA%/Temp/d371/report.md` point 10). FEATURE-003's `idea.md` § Prototype reads "Built … It answered D1, D2
and D3; delete it once those are stamped." D1–D3 were stamped 2026-09-30 and the feature was signed off 2026-10-03,
yet the line still says Built, so every `/feature status` keeps linking a prototype the record says is due to go.

**Why not now:** the playground is also TASK-124's test instrument, and TASK-124 is at `verify`, waiting on an
outside tester. Deleting it first would leave that test with nothing to run.

**Assigned to a person** because unpublishing a hosted page is the owner's call, and the page is outside the repo.

**Loose on purpose:** repo-record upkeep, not a review finding.

## Acceptance criteria

- [ ] TASK-124 is closed (or no longer uses the playground), and the owner has deleted or unpublished the page
- [ ] FEATURE-003's `idea.md` § Prototype records the retirement with its date, and `decisions.md` History gains a
      dated line saying so
- [ ] `/feature status` is re-run, and FEATURE-003's prototype cell no longer links the page

## Out of scope

- How `/feature status` words a `done` feature's Prototype line in general: TASK-373 (DRILL-371-7)

## Human test plan

- [ ] Open the old playground link. Expected: it no longer resolves, or resolves to a page the owner has unpublished
