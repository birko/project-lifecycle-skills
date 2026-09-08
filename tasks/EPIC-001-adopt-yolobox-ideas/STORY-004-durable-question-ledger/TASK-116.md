---
id: TASK-116
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-114]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/feature pick` gains one branch: open questions outstanding, resume at the frontier

## Context

The story is emphatic about the shape of this change: **"No new verb, no new skill, no new tree."**
`/feature pick` is already the front door to an existing feature and already routes on state; it gains
**one** branch — open questions outstanding, resolve the next frontier one.

That constraint is the task. The temptation is a `/feature resume`; the story rejects it, because a
second front door is how two doors drift apart.

## Acceptance criteria

- [ ] `/feature pick` detects outstanding open questions and offers to resume at the frontier, as one
      branch among its existing routing — no new verb, no new file
- [ ] The branch's position in the routing is stated: what it outranks and what outranks it, so two
      readers resolve the same feature to the same offer
- [ ] Resuming marks the question `claimed-by` per TASK-114, and releases the claim when the session
      ends or the question resolves
- [ ] A feature with a table but an empty frontier — every open question blocked — reports **that**,
      distinctly from having no open questions at all
- [ ] Nothing restates the frontier query
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Writing the questions in the first place — **TASK-115**.
- The grill's round mechanics — **TASK-117**.
- Any change to `/feature pick`'s existing decompose-offer branch.

## Human test plan

- [ ] Take the part-way feature TASK-115's test leaves behind, in a fresh session with no memory of it,
      and run `/feature pick`. Expected: it resumes at a question you did not have to find yourself.
