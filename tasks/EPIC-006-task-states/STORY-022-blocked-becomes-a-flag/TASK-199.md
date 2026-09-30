---
id: TASK-199
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: `fix-next` reads the new form and skips a blocked task it ranks first

## Context

A migrate batch of FEATURE-003 (owner group: `skills/fix-next/`). Step 0 resumes only `in-progress`
branch copies, step 1 excludes `status: blocked` from the pool, and step 8 closes through `close`.
FEATURE-003 D6 keeps a blocked task in the offered work, and D9 decides what an unattended drain does
with one: **skip it, report it, and take the next unblocked task**, never unblocking it itself.

## Acceptance criteria

- [ ] Step 0 treats a flagged `in-progress` branch copy as an active run only when it is unflagged. A flagged run is reported and not resumed
- [ ] Step 1 ranks a flagged task in the pool, then skips it with a report line naming the task and the reason (D9); legacy `status: blocked` is skipped the same way
- [ ] `verify` and legacy `review` are both non-active in step 0
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Unblocking anything — a human decision

## Human test plan

- [ ] Cold drill: a pool whose top-ranked defect carries `blocked: waiting on TASK-X`. `/fix-next` names the skip and the reason, then picks the runner-up.
