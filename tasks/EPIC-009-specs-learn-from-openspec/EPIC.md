---
id: EPIC-009
# status — one of: planned, in-progress, done, cancelled
status: planned
created: 2026-10-08
owner: František Bereň
affects: []
---

# Specs learn from OpenSpec

## Area of concern

How `/specs regen` reviews a spec diff, the shape of the spec files it writes, and a standing watch on OpenSpec,
the most-used tool in the same space. FEATURE-004 holds the decisions. Specs stay harvested from the code:
FEATURE-004 D9 removed the option of adopting OpenSpec's proposal-first flow.

Out of scope here: `/specs init`'s area discovery, and `/specs verify`'s staleness check (D8: it is already honest).

## Success criteria

- A regen review can be read one requirement at a time, and anything it drops is named.
- A structurally broken spec fails CI in this repo.
- A new OpenSpec release becomes a labelled issue within a week, without anyone checking by hand.

## Requirement → feature matrix

| Req | Brief quote (abridged, from docs/BRIEF.md) | Feature | Story |
|-----|--------------------------------------------|---------|-------|
| R1  | _"we need maye update our spec regen https://openspec.dev/ has some updates"_ | FEATURE-004 | STORY-026, STORY-027 |
| R2  | _"maybe add also a copilont agent on github to chek the openscpecs site?"_ | FEATURE-004 | STORY-027 |
