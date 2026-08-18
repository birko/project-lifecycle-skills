---
id: STORY-006
parent: EPIC-001
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-18
---

# Slicing doctrine and the state-model prototype branch

## User story

As someone decomposing a decision into tasks, I want the skill to tell me how to slice — including
what to do when a change is too wide to slice at all — so that I stop producing tasks that cannot
land green on their own.

## Behaviour

- **`decompose` and `plan` currently have no slicing doctrine** beyond "atomic and independently completable". They gain: each slice cuts a **narrow but complete path through every layer** (vertical, not a horizontal slice of one layer); a completed slice is **demoable or verifiable on its own**; each is sized to fit **one fresh context window**; prefactoring goes first — make the change easy, then make the easy change.
- **Wide refactors are the explicit exception.** A mechanical change whose blast radius fans across the codebase (rename a shared symbol, retype a column) breaks thousands of call sites at once, and no vertical slice can land green. Sequence it **expand → migrate → contract**: add the new form beside the old so nothing breaks; migrate call sites in batches sized by blast radius, each batch its own task blocked by the expand, CI green batch to batch because the old form still exists; delete the old form last, in a task blocked by every batch. When even the batches cannot stay green alone, they share an integration branch that all block a final integrate-and-verify task — green is promised only there.
- **`/feature prototype` gains a fourth form.** Its three existing forms (HTML mockup, markdown wireframe, code spike) all answer *what should this look like*. The missing one answers **"does this state model feel right?"** — a single shareable HTML file with free-play controls **plus tabbed guided walkthroughs** that push the state machine through the cases that are hard to reason about on paper, drivable by a non-developer.
- Throwaway discipline is stated plainly: a prototype answers its question and is then deleted. Do not architect it, do not polish it, do not wire it into the repo.
- Where a prototype produced a snippet that encodes a decision more precisely than prose can (a state machine, a reducer, a schema, a type shape), that snippet may be inlined into the decision — trimmed to the decision-rich part, noted as prototype-derived. Otherwise decisions stay free of file paths and code, which go stale fast.

**Independent of everything past STORY-001** — pull it forward for a short session.
