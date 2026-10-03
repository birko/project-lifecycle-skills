---
id: EPIC-007
parent: null
kind: review-intake
source: specs regen work-tracking, 2026-10-03, harvested at b7bd8fc, spec committed in 0c84b8a — suspected bugs found while reading skills/tasks/**
# status — one of: planned, in-progress, done, cancelled
status: planned
owner: human
affects: []
created: 2026-10-03
---

# work-tracking spec harvest review 2026-10

## Area of concern

The first harvest of the `work-tracking` spec (`/specs regen work-tracking`, 2026-10-03) read all 24 files under
`skills/tasks/**` at `b7bd8fc`. The spec describes the skill as written; while reading, the harvester raised 12
places where the prose contradicts itself or another file. Each was specced as-is, as the regen rules require,
and is filed here as work. Spot-checked at intake against the files: every claim checked held.

13 findings (SH-1 … SH-13 — the harvester's seventh point held two separate problems, split at intake) → 7 tasks, grouped by root cause. None dropped, none routed to a decision.

## Stories

- STORY-023 — correctness and invariants: behaviour that leaves the tree contradicting itself
- STORY-024 — contract drift: lists, labels and references that no longer match what they describe
