---
id: STORY-010
parent: EPIC-002
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-20
# theme: review-intake stories only — this story's slug on intake's subject ladder.
# fix-next reads it as tie-break key 6; omit it on an ordinary story.
theme: correctness-invariants
---

# `verify-conventions` — what the lint skips and what it fails to say

## User story

As someone running the adherence half of the merge gate, I want the lint to judge the right files and
to tell me which rules it actually read, so that a clean pass is evidence of adherence rather than
evidence that nothing was checked.

## Behaviour

- The skill has no rule about **generated and vendored files**, so it lints artifacts whose content is
  owned by a generator and whose violations cannot be fixed at the source it points at. Two file
  classes need distinct handling — a generated file's rules belong to the verb that writes it, and a
  vendored file's belong to nobody in this repo.
- The output has **no slot for the sections it read**. This is the reporting half of the defect
  TASK-006 fixed: that task stopped the skill claiming a repo had no conventions when it had many, but
  a reader still cannot tell a thorough pass from a shallow one, because the report never names its
  inputs. A pass that read one heading and a pass that read six render identically.
- Both defects share a root: the skill's confidence is not observable from its output. Fixing them
  together keeps the report format changing once.
