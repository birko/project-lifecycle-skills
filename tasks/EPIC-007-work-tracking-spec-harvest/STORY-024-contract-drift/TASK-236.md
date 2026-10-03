---
id: TASK-236
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-17, SH-21, SH-22, SH-23]
pr: null
github-issue: null
jira-key: null
---

# `roadmap`'s renders and output model have drifted from the collection they describe

## Context

Found by the project-roadmap spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). All four are in
`skills/roadmap/SKILL.md` §§ 4–5 and the two *Render* sections, and would be fixed in one pass over them.

- **SH-17 — compact slice order.** The prose says "Lead the line with any `review`-phase feature count (verification
  debt)". The example line directly above lists phases in lifecycle order, with `review` after `building`.
- **SH-21 — compact divergence line.** Its only slot is `<FEATURE-NNN DV<x>>`. DV5 (a story or epic), DV7, DV10 and
  DV11 (a spec or the map), DV9 (a task) and DV12 (a story) have no target of that shape, and nothing says how they
  render there.
- **SH-22 — prototype line dropped.** Step 2 collects each feature's `## Prototype` line, and the output model in § 5
  has no field for it, while renderers are told not to re-derive anything. Either the collection is dead or the model
  is missing a field.
- **SH-23 — ordering.** DV11 sits between DV8 and DV9 in the table. The full render's step 1 lists `review`-phase
  features first and step 2 groups by epic, without saying whether a `review` feature also appears in its epic group.

## Acceptance criteria

- [ ] The compact slice's example and its prose agree on where the `review` count goes
- [ ] The compact divergence line says how a finding whose target is not a feature renders
- [ ] The prototype line is either in the output model or no longer collected
- [ ] The DV table is in id order, and the full render says whether a `review` feature appears once or twice
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing any DV rule's condition (TASK-207, TASK-231, TASK-232)

## Human test plan

N/A — render and model text, checked by rendering the compact slice by hand from an invented model with one finding
of each target kind.

## Implementation plan

_Populated by `/tasks plan TASK-236` — leave empty until then._
