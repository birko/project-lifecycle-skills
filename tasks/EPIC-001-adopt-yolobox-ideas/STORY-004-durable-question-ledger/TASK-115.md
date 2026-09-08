---
id: TASK-115
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

# `/feature new` writes the frontier it could not reach, instead of losing it

## Context

Today `/feature new` grills until the session ends and whatever was not reached goes with the
conversation. The story's fix: **grill the frontier it can reach, then write the rest down as open
questions with edges.**

`/tasks spawn` is the named precedent — work discovered mid-flight becomes a durable record rather than
an intention. Same move, applied to questions rather than tasks.

The table and its states are TASK-114's; this task only makes `new` *write* them.

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

## Out of scope

- Resuming from what this writes — **TASK-116**.
- The round mechanics of the grill itself — **TASK-117**.
- Reconciling older files — **TASK-119**.

## Human test plan

- [ ] Run `/feature new` on a real idea and stop it deliberately part-way. Reopen the folder and read
      only `idea.md`. Expected: a reader who was not present can tell what remains open and what each
      remaining question waits on.
