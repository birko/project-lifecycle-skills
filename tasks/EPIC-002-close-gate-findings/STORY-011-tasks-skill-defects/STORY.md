---
id: STORY-011
parent: EPIC-002
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-20
---

# The `tasks` skill's own defects — templates, pick, close, triage, intake

## User story

As someone whose whole workflow runs through `/tasks`, I want its verbs and templates to express what
the tree actually needs to hold, so that the tracking layer stops being the thing that loses work.

## Behaviour

- **Templates cannot express what the tree needs.** `STORY.md` has no way to record dependency edges
  between its tasks, and the dashboard template has no slot for the todo-by-priority breakdown that
  the bare-`/tasks` snapshot already computes.
- **`pick` walks past verification debt.** The house rule is that debt surfaces before new scope;
  `pick` selects new work without mentioning tasks sitting at `review`, so the rule holds only for
  whoever remembers to run the bare snapshot first.
- **`close` has two unattended-path defects.** Its step 5d offer assumes a user is present to take it,
  which is false when [[fix-next]] drives the close; and its single-branch SHA backfill instructs an
  amend that cannot be performed as written.
- **`intake` cannot adopt a loose backlog** — the gap this very epic had to work around by hand.
- Common thread: each is a place where the skill assumed a shape (a user present, a branch model, a
  parent epic) rather than reading or providing for the one in front of it. That is the same defect
  class EPIC-001 records as recurring, arriving inside the tracker itself.
