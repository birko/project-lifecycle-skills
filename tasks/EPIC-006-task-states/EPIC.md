---
id: EPIC-006
# status — one of: planned, in-progress, done, cancelled
status: done
created: 2026-09-30
owner: František Bereň
affects: []
---

# Task states follow common practice

## Area of concern

The task status vocabulary that every skill in this set reads and writes. FEATURE-003 changes it:
five states plus a `blocked` flag, and `review` renamed `verify`. That is a change many places read,
so it is sequenced as a wide refactor per `skills/tasks/slicing.md`: expand, migrate by owner, contract,
then rewrite the existing task files.

Out of scope here: the states of stories and epics, and the rest of the feature lifecycle.

## Success criteria

- Every skill reads both the old and the new form for as long as an unmigrated file can exist, and writes only the new one.
- Every consumer repo's task files are migrated, with no task left without an owner of its prior state.
- A task never loses where its work was because it was blocked.

## Requirement → feature matrix

| Req | Brief quote (abridged, from docs/BRIEF.md) | Feature | Story |
|-----|--------------------------------------------|---------|-------|
| R1  | _"dal by sa tento workfow nejak zredujovat podla standardov…"_ (2026-09-30) | FEATURE-003 (done, signed off 2026-10-03) | STORY-022 (done) |

## State as of 2026-10-03

Done. All three success criteria hold: every skill reads both forms and writes only the new one; all eight consumer repos were migrated (Presenter last, through TASK-211), each prior state from history or a recorded answer; a blocked task keeps its state. FEATURE-003 was signed off the same day.
