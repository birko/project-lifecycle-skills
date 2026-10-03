---
id: STORY-022
parent: EPIC-006
# status — one of: planned, in-progress, done, cancelled
status: done
created: 2026-09-30
---

# "Blocked" becomes a flag, and "review" becomes "verify"

## User story

As someone tracking work with these skills, I want a blocked task to keep the state its work is in,
so that unblocking it does not throw away the fact that work was already done on it, and so that the
states mean what they mean in every other tracker.

## Behaviour

- Five states: `todo`, `in-progress`, `verify`, `done`, `cancelled`. `blocked` is a flag with a reason, which any open task may carry (FEATURE-003 D1).
- Unblocking removes the flag and leaves the state (D2). A finished task whose merge must wait is `in-progress` with a `merge deferred` flag (D3).
- `review` is written `verify` (D4). `blocked` and `review` in an old file are still read correctly, permanently, since some copies are out of reach.
- A blocked task stays on offer with a warning (D6), cannot be started or finished while flagged, and choosing one asks "Unblock and start?" (D7). `fix-next` skips it and reports it (D9).
- Synced trackers show the flag as the GitHub label `blocked` or Jira's "Flagged" field, with the reason as a comment (D8).
- Existing task files are rewritten once, with each blocked task's prior state read from its git history (D5).

## Sequence

Wide refactor per `skills/tasks/slicing.md`. The edges are on the task files.

| Phase | Task |
|---|---|
| expand | TASK-196 — the `tasks` skill reads both forms |
| migrate | TASK-197 `feature` · TASK-198 `roadmap` · TASK-199 `fix-next` · TASK-200 `specs` · TASK-201 both front doors · TASK-202 tracker sync · TASK-203 the migration tool |
| contract | TASK-204 — the writers switch to the new form |
| rewrite | TASK-205 — run the migration on this repo and the consumer repos |
