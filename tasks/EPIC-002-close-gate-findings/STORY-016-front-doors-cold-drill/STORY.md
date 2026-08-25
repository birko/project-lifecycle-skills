---
id: STORY-016
parent: EPIC-002
# status — one of: planned, in-progress, done, cancelled
status: planned
created: 2026-08-22
# theme: review-intake stories only — this story's slug on intake's subject ladder.
# fix-next reads it as tie-break key 6; omit it on an ordinary story.
theme: correctness-invariants
---

# The front doors under a cold drill — what the prose says versus what it does

## User story

As someone adopting these skills into a real repo, I want `new-project` and `adopt-project` to mean what
they say — a layer that is actually the whole layer, a detection ladder that can see my project, and a
survey whose states can express what it found — so that the front doors are trustworthy on a repo their
author never saw.

## Provenance

**One pass, one story, so "how much of the drill is left?" stays answerable.** These findings came from a
single **cold drill** at TASK-053's close gate on 2026-08-22: a fresh agent was handed the repo and told
to *execute* both skills as written, with the test plan's **expected answers withheld**, then to report
what the prose led it to and — the valuable half — where it had to decide something the instructions did
not settle. Three runs: a scaffold of a throwaway docs-only library, and read-only surveys of
`Birko/Consumers/WorkoutTracker` and of this repo.

TASK-053's own four drills **passed**. Everything here is collateral: defects in the surrounding skills
that the pass exposed and that the author of the change provably could not see, because every one of them
reads as obvious once stated. Routed out of TASK-060.

## Behaviour

Eight findings, five root causes, and they are not variations on one theme — that is why they are
separate tasks rather than one sweep:

- **The inventory is not the whole layer.** `LAYER.md` opens by calling itself *the* single definition of
  what a lifecycle-ready repo contains, while `new-project` creates three artifacts it has no rows for.
  Adoption walks the inventory, so it can never notice a missing `LICENSE`. This is the layer-parity
  failure occurring *inside* the file the parity rule points at.
- **Two detection ladders cannot see a repo whose product is prose.** The test-harness evidence ladder's
  globs miss this repo's own suite, so applied literally it reports `missing` on the repo that ships it.
  Only the section's "detect by evidence, not by path" preamble saved the drill — a preamble is not a
  ladder.
- **The upgrade path's headline case has no state and no remedy.** `adopt-project` advertises itself as
  the thing to re-run whenever the layer grows, and the artifact the layer grows fastest is the agent
  guide. A guide that is a stale *vintage* but has every `##` section fits neither `present, outdated`
  (nothing can tell you the delta) nor the merge-by-section remedy (nothing is missing).
- **The skills assume every run is a full run.** A scoped or read-only survey has no state for a present
  row whose owner verb has not been invoked, and § 4's report owes output only § 2 produces. A
  pre-flight survey is a reasonable thing to want and cannot currently express its central result.
- **Degenerate cases are undefined, so each agent invents one.** What `## Conventions` contains when the
  stack is "none"; what a generated file looks like with zero items. Both were invented during the drill,
  and the second is why this repo's own features index carries a hand-written line its verb cannot derive.

Two findings from the same pass are **not** here, deliberately: the silent `integration:` default is
evidence appended to **TASK-035**, which already owns that question, and the cold-drill method itself is
**TASK-068**, filed at epic level because it is method rather than a defect in one subject.
