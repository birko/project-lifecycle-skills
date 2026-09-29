---
id: TASK-115
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-114, TASK-195]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/feature new` writes the frontier it could not reach, instead of losing it

## Context

Today `/feature new` grills until the session ends and whatever was not reached goes with the
conversation. The story's fix: **grill the frontier it can reach, then write the rest down as open
questions with edges.**

`/tasks spawn` is the named precedent — work discovered mid-flight becomes a durable record rather than
an intention. Same move, applied to questions rather than tasks.

The table and its states are TASK-114's; this task only makes `new` *write* them.

### Merged in 2026-09-26: TASK-116 — `/feature pick` gains one branch: open questions outstanding, resume at the frontier

_Merged because new writes the open-question frontier and pick reads it back; writer and reader of one state. The original file stays, cancelled, at `tasks/EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-116.md`._

The story is emphatic about the shape of this change: **"No new verb, no new skill, no new tree."**
`/feature pick` is already the front door to an existing feature and already routes on state; it gains
**one** branch — open questions outstanding, resolve the next frontier one.

That constraint is the task. The temptation is a `/feature resume`; the story rejects it, because a
second front door is how two doors drift apart.

## Acceptance criteria

- [ ] `/feature new` ends by writing every unreached question as a row, with its `blocked-by` edges — not
      a flat list of leftovers
- [ ] Edges are recorded when the question is *raised*, not reconstructed at the end from memory
- [ ] A run that reached everything says so explicitly rather than writing an empty table — silence
      cannot be told from "the grill never got there"
- [ ] The verb states what it wrote, in its closing output, so a user can see the frontier they are
      leaving behind
- [ ] Nothing restates TASK-114's states or frontier query — point at the owner
- [ ] `bash .github/workflows/skills-lint.sh` passes

*From TASK-116:*

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

- Resuming from what this writes — **TASK-116**.
- The round mechanics of the grill itself — **TASK-117**.
- Reconciling older files — **TASK-119**.

*From TASK-116:*

- Writing the questions in the first place — **TASK-115**.
- The grill's round mechanics — **TASK-117**.
- Any change to `/feature pick`'s existing decompose-offer branch.

## Human test plan

- [ ] Run `/feature new` on a real idea and stop it deliberately part-way. Reopen the folder and read
      only `idea.md`. Expected: a reader who was not present can tell what remains open and what each
      remaining question waits on.

*From TASK-116:*

- [ ] Take the part-way feature TASK-115's test leaves behind, in a fresh session with no memory of it,
      and run `/feature pick`. Expected: it resumes at a question you did not have to find yourself.

