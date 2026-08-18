---
id: STORY-007
parent: EPIC-001
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-18
---

# `improve-architecture` — make the codebase itself a subject of the lifecycle

## User story

As a maintainer, I want a pass that treats the codebase itself as the subject — not a feature, not a
defect — and files what it finds as tracked work, so that structural friction gets addressed instead
of noticed.

## Behaviour

- **Closes a lane we do not have.** Every current entry point is a feature or a defect; nothing lets the shape of the code be the thing under review.
- **Scope before you scan.** If the user named a direction, take it. Otherwise walk the commit history for hot spots — the files and areas that keep coming up — and weight those first. Deepening pays off only where change is coming; scattered history with no hot spot means widen the net.
- Surfaces **deepening opportunities**: where understanding one concept requires bouncing between many small modules; where an interface is nearly as complex as the implementation it hides; where pure functions were extracted for testability while the real bugs live in how they are called; where tightly-coupled modules leak across their seams; what is untestable through its current interface.
- Applies the **deletion test** to anything suspected shallow: would deleting it concentrate complexity, or merely move it? Only "concentrates" is a finding.
- **Reports as an Artifact** (a shareable published page), falling back to a temp HTML file where the runtime has no Artifact surface — the same runtime-degradation pattern `tasks/close` already uses for `code-review`. Each candidate gets files, problem, solution, benefits in terms of leverage and locality, a before/after visual, and a recommendation strength.
- **Findings end at `/tasks intake`, not at a grill.** The report is the means; tracked, ranked, pickable refactor tasks are the deliverable. Ending at "here is a report, pick one" means the other findings evaporate — `intake` already exists to drain exactly this kind of pass.
- Existing decision records are respected: a candidate that contradicts one is surfaced only when the friction is real enough to warrant reopening it, and is marked as such.
- **Reuses `tdd/deep-modules.md` and `interface-design.md` rather than duplicating them**, and backfills the four things they are missing: the deletion test, "one adapter means a hypothetical seam, two means a real one", "the interface is the test surface", and designing an interface twice in parallel before choosing.
