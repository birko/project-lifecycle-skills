---
id: STORY-013
parent: EPIC-002
# status — one of: planned, in-progress, done, cancelled
status: planned
created: 2026-08-20
# theme: review-intake stories only — this story's slug on intake's subject ladder.
# fix-next reads it as tie-break key 6; omit it on an ordinary story.
theme: correctness-invariants
---

# The drift audit — a check that cannot see prose, and a finding that cannot be accepted

## User story

As someone running `/roadmap` on a real repo, I want the audit to fire on the repos it is meant to
cover and to stay quiet about decisions already made, so that its findings keep being worth reading.

## Behaviour

- **DV10's real-code test cannot see a repo whose code is prose.** It looks for a `src/` tree or a
  build manifest with tracked sources; a markdown skill library has neither, so an entirely absent spec
  layer reports as fine. This repo is the measured instance — `docs/specs/.map.yml` has sat at
  `areas: []` since 2026-08-18 and no run has ever flagged it.
- **A divergence cannot be recorded as accepted.** DV5 fires on this repo every run because `tasks/`
  has work and `docs/features/` is deliberately empty — a recorded choice the audit has no way to
  hold, so it re-raises a settled question indefinitely. A check that nags about a decision already
  made gets muted, and a muted check is worth what an unrun one is.
- Common thread, and it points in two directions at once: one check is silent where it should fire,
  the other fires where it should be silent. Both make the audit less trustworthy as a whole, which is
  why they are worth fixing together rather than by severity.
