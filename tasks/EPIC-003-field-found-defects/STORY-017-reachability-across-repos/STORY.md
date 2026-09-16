---
id: STORY-017
parent: EPIC-003
# status — one of: planned, in-progress, done, cancelled
status: planned
created: 2026-09-16
theme: correctness-invariants
---

# Work that is filed correctly and reachable by nothing

## User story

As a developer using these skills across more than one repository, I want a task I filed **where the
skills told me to file it** to be visible to the dashboard, to `pick`, and to `fix-next` — so that
following the convention does not make work disappear.

## Behaviour

Both tasks under this story are the same failure at two different layers, and the story exists to keep
that connection visible rather than leaving two unrelated-looking defects:

- **TASK-130 — the collection layer.** `/tasks` documents a polyrepo split (single-sub-project work lives
  in that sub-repo's own `tasks/`) and then resolves exactly one task root by walking up from cwd. There
  is no roll-up, so a correctly-filed sub-repo task is visible only when cwd happens to be inside that
  repo. Measured: 178 sub-projects, 1 `tasks/` folder, 449 tasks filed — the prescribed placement has
  been followed zero times, which is the rule being unusable rather than ignored.
- **TASK-131 — the ranking layer.** `fix-next`'s pool is explicit and should stay so, but its documented
  escape hatch for hand-filed defects — *"put its finding id in `findings:`"* — assumes an id that
  nothing mints. The door is named and no key is cut.

**They compound.** A sub-repo task is unreachable by collection *and*, if hand-filed, ineligible for the
pool. Either fix alone still leaves that task unreachable, which is why they are decided together even
though they are built separately.

## Theme

`correctness-invariants` — in both cases a documented rule and the tooling that must execute it disagree,
and the disagreement is silent. Neither is a security, data-integrity or performance matter; both are the
architectural-rule-broken shape that theme covers.

## Not in this story

- Cross-cutting **epic** placement in an aggregator — that half works.
- The blast-radius ranking itself — it works, and neither task questions it.
