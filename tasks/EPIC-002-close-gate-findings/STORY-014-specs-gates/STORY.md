---
id: STORY-014
parent: EPIC-002
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-20
# theme: review-intake stories only — this story's slug on intake's subject ladder.
# fix-next reads it as tie-break key 6; omit it on an ordinary story.
theme: correctness-invariants
---

# `specs` — two gates that pass without checking

## User story

As someone relying on the spec layer to be a real behavioural map, I want its own gates to fail when
they should, so that a passing check means the thing it names was verified.

## Behaviour

- **`/specs init`'s coverage check can pass vacuously** — it can report coverage satisfied in a state
  where nothing was actually covered, so the bootstrap step that is supposed to guarantee the area map
  is complete guarantees nothing.
- **`/specs regen`'s state gate can read the commented enum instead of the status.** The task templates
  carry their status vocabulary as a commented enum line directly above the real `status:` field; a
  parser taking the first match reads the comment, and the gate then evaluates a task state that is not
  the task's state.
- Common thread: both are checks whose failure mode is a **false pass**, which is the worst kind in a
  gate — nothing downstream ever learns the check did not run. Neither is visible from the output, so
  each needs a test that fails without the fix.
