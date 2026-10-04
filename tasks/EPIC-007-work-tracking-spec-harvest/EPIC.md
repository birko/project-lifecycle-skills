---
id: EPIC-007
parent: null
kind: review-intake
source: specs regen work-tracking, 2026-10-03, harvested at b7bd8fc, spec committed in 0c84b8a — suspected bugs found while reading skills/tasks/**; specs regen feature-lifecycle, project-roadmap, defect-draining, specs-from-code (first harvests), 2026-10-03, specs committed in b24eb8b — suspected bugs found while reading skills/feature/**, skills/roadmap/SKILL.md, skills/fix-next/SKILL.md, skills/specs/**; specs regen project-baseline, change-review (first harvests, TASK-080), 2026-10-04, harvested at adc4c27 — suspected bugs found while reading skills/new-project/**, skills/adopt-project/**, skills/verify-conventions/**, skills/verify-intent/**, skills/review-comments/**, skills-pi/**
# status — one of: planned, in-progress, done, cancelled
status: planned
owner: human
affects: []
created: 2026-10-03
---

# First spec harvest review 2026-10

## Area of concern

**First pass — `work-tracking`.** The first harvest of the `work-tracking` spec (`/specs regen work-tracking`,
2026-10-03) read all 24 files under `skills/tasks/**` at `b7bd8fc`. The spec describes the skill as written; while
reading, the harvester raised 12 places where the prose contradicts itself or another file. Each was specced as-is, as
the regen rules require, and is filed here as work. Spot-checked at intake against the files: every claim checked held.

13 findings (SH-1 … SH-13 — the harvester's seventh point held two separate problems, split at intake) → 7 tasks,
grouped by root cause. None dropped, none routed to a decision.

**Second pass — four more first harvests**, run the same day and committed in `b24eb8b`: `feature-lifecycle`
(`skills/feature/**`), `project-roadmap` (`skills/roadmap/SKILL.md`), `defect-draining` (`skills/fix-next/SKILL.md`)
and `specs-from-code` (`skills/specs/**`). Their harvesters raised 38 findings. Every one was checked against the files
at intake; one (`project-roadmap`'s sixth point) held two separate problems and was split, giving 39 ids.

39 findings (SH-14 … SH-52) → 15 new tasks (TASK-227 … TASK-241), grouped by root cause · 2 linked to the open
TASK-207 (SH-16, SH-20) · 2 dropped (below) · none routed to a decision.

**Third pass — two more first harvests**, run under TASK-080 on 2026-10-04 at `adc4c27`: `project-baseline`
(`skills/new-project/**`, `skills/adopt-project/**`) and `change-review` (`skills/verify-conventions/**`,
`skills/verify-intent/**`, `skills/review-comments/**`, `skills-pi/**`). Their harvesters raised 30 findings. Each
was checked against the files by a second reader before intake: 21 confirmed, 7 partly confirmed (filed for the half
that holds), 2 refuted.

30 findings (SH-53 … SH-82) → 10 new tasks (TASK-242 … TASK-251), grouped by root cause · 2 linked to the open
TASK-085 (SH-53, SH-55) · 2 dropped (below) · none routed to a decision.

### Findings dropped at intake

| Finding | Claim | Why dropped |
|---|---|---|
| SH-18 | `roadmap` DV12's "open TASK" is undefined against `verify`/`review`, `in-progress` or blocked children | The rule defines it in its own parenthesis — "all children `done`/`cancelled`, or none exist" — so every other state, those included, is open. Not ambiguous as written |
| SH-52 | `feature` § Conventions ships "No `Co-Authored-By:` trailers (user preference)", one author's preference, as a rule to every consumer | Intentional: the rule is a fleet rule, shipped to every consumer by `skills/new-project/templates/CONVENTIONS-universal.md` and stated in this repo's AGENTS.md § Working rules; six other skills carry it too. The "(user preference)" label is loose wording in three skills (`feature`, `new-project`, `roll-changelog`), not a `feature` defect, and changing the rule itself would be a decision, not a fix |
| SH-66 | `LAYER.md` § *Ordering* says `tasks init` then `specs init`, and `new-project` writes `docs/specs/.map.yml` before `/tasks init` | `new-project` never runs `/specs init`; it seeds the map from a template, which LAYER's own `docs/specs/` row allows. The "already does this" sentence refers only to the features-before-tasks order |
| SH-69 | LAYER's `LICENSE` row (open posture, no licence → `missing`, filling out of scope) has no bucket in the adopter's report | The adopter's catch-all report rule, plus its `unknown`-vs-`missing` bullet, covers a `missing` row left unfilled |

## Stories

- STORY-023 — correctness and invariants: behaviour that leaves the tree contradicting itself, or a run with no
  defined next step (19 tasks)
- STORY-024 — contract drift: lists, labels and references that no longer match what they describe (13 tasks)
