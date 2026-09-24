---
id: STORY-020
parent: EPIC-004
# status — one of: planned, in-progress, done, cancelled
status: in-progress
created: 2026-09-24
---

# What FEATURE-002's review gate found unfinished

## User story

As the stakeholder signing FEATURE-002 off, I want every decision it approved actually built and the new
command findable where the skill set lists its skills, so that "done" means what it says.

## Behaviour

Gate A of `/feature review FEATURE-002` (2026-09-24) confirmed every approved and changed decision built
except two, partly built, and found the new skill registered nowhere a reader looks for skills. Each gap
is a task here, per the review verb: a gap goes back to a task, never into a silent fix at the gate.

- D8's comments axis is missing from the text that counts `close`'s axes → TASK-167
- `review-comments` is absent from the naming list, the README and the architecture doc → TASK-168
- D10's pass bar is not stated beside the table that depends on it → TASK-169
- D15's guide row has no relocation target in `review-comments` → TASK-170
