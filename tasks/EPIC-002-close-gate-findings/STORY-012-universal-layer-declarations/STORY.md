---
id: STORY-012
parent: EPIC-002
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-20
---

# The universal layer — declarations that nobody owns, owner verbs that cannot reconcile

## User story

As a repo adopting or re-adopting the lifecycle layer, I want each declared value to have exactly one
owner and each owner verb to be able to say whether my artifact is current, so that a second run
reports the truth instead of a shrug.

## Behaviour

- **The owner-verb reconcile rule was taught to one verb only.** `/tasks init` learned it; the other
  verbs named in `LAYER.md`'s Owner column still answer a present artifact with an undifferentiated
  "nothing to do", so *already current* is indistinguishable from *declined to look*. TASK-024 carries
  the per-verb breakdown — read it there rather than copying the list here, since `LAYER.md` gains rows.
  The rule text is in scope alongside the verbs: it says every `LAYER.md` row with an Owner, which that
  file's *Delegation follows the row* section explicitly rejects.
- **Nothing owns the `integration:` question.** Three rules each hand it to another, so a repo can
  reach a close gate with the field absent and no verb responsible for having asked.
- **The survey misreads repo state.** `present, uncommitted` is blind to work that was staged but never
  committed, and the inference skip rule counts five subsections when one of them is conditional — so
  the skip fires on a count that cannot be reached.
- Common thread: the layer's rules are correct and under-applied. Every one of these is a rule that
  exists, was written down, and reached exactly the verb that exposed it.
