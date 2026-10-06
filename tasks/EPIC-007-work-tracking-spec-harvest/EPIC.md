---
id: EPIC-007
parent: null
kind: review-intake
source: specs regen work-tracking, 2026-10-03, harvested at b7bd8fc, spec committed in 0c84b8a — suspected bugs found while reading skills/tasks/**; specs regen feature-lifecycle, project-roadmap, defect-draining, specs-from-code (first harvests), 2026-10-03, specs committed in b24eb8b — suspected bugs found while reading skills/feature/**, skills/roadmap/SKILL.md, skills/fix-next/SKILL.md, skills/specs/**; specs regen project-baseline, change-review (first harvests, TASK-080), 2026-10-04, harvested at adc4c27 — suspected bugs found while reading skills/new-project/**, skills/adopt-project/**, skills/verify-conventions/**, skills/verify-intent/**, skills/review-comments/**, skills-pi/**; specs regen idea-interrogation (first harvest, TASK-080), 2026-10-06, harvested at 07de657 — suspected bugs found while reading skills/grill-me/SKILL.md; specs regen test-authoring, glossary-and-adrs, changelog-maintenance, session-handoff, installation, skill-authoring-rules, code-shape-review (first harvests, TASK-080 stage 2), 2026-10-06, harvested at 20c038b
# status — one of: planned, in-progress, done, cancelled
status: in-progress
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

**Fourth pass — `idea-interrogation`**, a first harvest run under TASK-080 on 2026-10-06 at `07de657`
(`skills/grill-me/SKILL.md`, after STORY-004 changed it). The harvester raised 4 findings, and each was checked
against `skills/feature/verbs/new.md`, `pick.md` and `questions.md` before intake. All 4 held.

4 findings (SH-83 … SH-86) → 3 new tasks (TASK-258 … TASK-260) · none dropped · none routed to a decision.

**Fifth pass — seven first harvests**, run under TASK-080 stage 2 on 2026-10-06 at `20c038b`: `test-authoring`,
`glossary-and-adrs`, `changelog-maintenance`, `session-handoff`, `installation`, `skill-authoring-rules` and the new
`code-shape-review`. Seven harvesters raised 37 findings. A second reader checked every one against the files: 23
confirmed, 8 partly confirmed (filed for the half that holds), 6 refuted. It reproduced SH-108 (Git Bash
`ln -s` copies while the installer reports success) and checked SH-113/114 against pi's own YAML parser.

37 findings (SH-87 … SH-123) → 10 new tasks (TASK-271 … TASK-280; TASK-277 at P1) · 2 linked to open tasks
(SH-89 → TASK-024, SH-117 → TASK-029) · 6 dropped (below) · none routed to a decision (SH-93 needs one, and its
task says so).

### Findings dropped at intake

| Finding | Claim | Why dropped |
|---|---|---|
| SH-97 | `domain`'s "all three, or no record" contradicts a fourth gate checked before the three | The scope gate only removes cases; "all three" still holds as a necessary condition, so nothing contradicts |
| SH-105 | `handoff` requires a "suggested skills" section with no rule for when none applies | Writing "none" satisfies the section |
| SH-106 | `handoff` has no no-argument path | The body is the no-argument behaviour; arguments only tailor it |
| SH-107 | `handoff`'s redaction leaves no marker | No rule requires one; the harvester itself doubted it |
| SH-110 | an empty source tree makes the bash installers link a folder named `*` | Real but unreachable: both trees are populated, and `pi-install` guards with `[ -d ]` |
| SH-116 | a block-scalar description is never length-checked by the lint | Deliberately left out on TASK-190: no skill uses one, and AGENTS.md says keep the description on one line |
| SH-18 | `roadmap` DV12's "open TASK" is undefined against `verify`/`review`, `in-progress` or blocked children | The rule defines it in its own parenthesis — "all children `done`/`cancelled`, or none exist" — so every other state, those included, is open. Not ambiguous as written |
| SH-52 | `feature` § Conventions ships "No `Co-Authored-By:` trailers (user preference)", one author's preference, as a rule to every consumer | Intentional: the rule is a fleet rule, shipped to every consumer by `skills/new-project/templates/CONVENTIONS-universal.md` and stated in this repo's AGENTS.md § Working rules; six other skills carry it too. The "(user preference)" label is loose wording in three skills (`feature`, `new-project`, `roll-changelog`), not a `feature` defect, and changing the rule itself would be a decision, not a fix |
| SH-66 | `LAYER.md` § *Ordering* says `tasks init` then `specs init`, and `new-project` writes `docs/specs/.map.yml` before `/tasks init` | `new-project` never runs `/specs init`; it seeds the map from a template, which LAYER's own `docs/specs/` row allows. The "already does this" sentence refers only to the features-before-tasks order |
| SH-69 | LAYER's `LICENSE` row (open posture, no licence → `missing`, filling out of scope) has no bucket in the adopter's report | The adopter's catch-all report rule, plus its `unknown`-vs-`missing` bullet, covers a `missing` row left unfilled |

## Stories

- STORY-023 — correctness and invariants: behaviour that leaves the tree contradicting itself, or a run with no
  defined next step (28 tasks)
- STORY-024 — contract drift: lists, labels and references that no longer match what they describe (18 tasks)
