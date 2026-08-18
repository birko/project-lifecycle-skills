---
id: STORY-008
parent: EPIC-001
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-18
---

# Harvest the skill set's own specs

## User story

As a maintainer, I want capability specs harvested from the skill definitions themselves, so that
this repo has a behavioural map that cannot rot and `roadmap`'s drift audit has something real to
compare against.

## Behaviour

- `/specs init` proposes the area map over `skills/` and `skills-pi/`, replacing the empty `areas: []` seeded in STORY-001. One area is a capability a consumer would recognise (task tracking, feature lifecycle, spec harvesting, defect draining), not one file per skill. Healthy is roughly 5-20 areas.
- `/specs regen` then generates the capability specs, each stamped with its generated-at commit, sources and shaped-by provenance.
- The regen **diff** is reviewed as an intended-versus-unintended behavioural-change check — that review is the point, not the file.
- **Runs last, and stays last.** STORY-002 through STORY-007 all change skill behaviour and STORY-003 changes the vocabulary the specs would be written in. Regenerating before the set stabilises means regenerating twice and reviewing a diff that is pure churn.
- If the epic slips, this story slips with it. It is the natural stopping point, not a nice-to-have.
- **Self-check worth watching:** this repo is a polyrepo-free, markdown-only project — the exact shape where the staleness anchor bugs fixed in the 2026-08 commits were found. A regen here is also a live test of those fixes.
