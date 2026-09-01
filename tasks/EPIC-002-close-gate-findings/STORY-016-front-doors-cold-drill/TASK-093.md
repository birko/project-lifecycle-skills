---
id: TASK-093
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-035-1]
pr: null
github-issue: null
jira-key: null
---

# The guide row demands a diff against a section list no surveyed file carries

## Context

**From the 2026-09-01 cold drills of `adopt-project` step 1, on `BardStudio` and `Birko.Framework`.
Both runners hit this independently**, which is why it is P1 rather than P3: it is not one agent's
misreading.

`LAYER.md`'s agent-guide row says **"Add missing `##` sections"**, and § *A guide's vintage is not
surveyable* says **"Report the guide `present`, name any missing `##` section, and leave the rules inside
alone."** Naming a missing section requires knowing which sections the layer expects. **No file in the
survey's reading set carries that list.** `adopt-project/SKILL.md`, its `INFER.md`, and `LAYER.md` name
`## Conventions` and nothing else.

Both runners resolved it the same way and both flagged it:

> *"The skill never tells me which `##` sections the layer expects, and never points me at the seed. I
> chose to read `new-project/templates/CLAUDE.seed.md` … because the guide row names 'new-project seed' as
> the owner of that shape, and naming a missing section is impossible without it. **Without that reach I
> would have had to report no missing sections at all.**"*

> *"The mapping from BardStudio's guide headings to the seed's four `##` sections. **No file gives a
> synonym table.**"*

**The consequence is measured, not theoretical.** The `Birko.Framework` runner projected what a run that
stayed inside the three named files would produce:

> *"A second run that stayed inside the three named files would report the guide `present` with **no**
> missing sections named — dropping round items 4 and 5 entirely, **and with them the highest-value gap
> this repo has.**"*

Those two items were the absent `## How we work — feature lifecycle` section in a repo that already keeps
**18 features**, and an absent `## Commands`. A survey that silently reports a guide complete is worse
than one that reports nothing, because the row exists to call a missing rulebook *"the highest-value gap
in an adoption — flag it loudly."*

### Two distinct halves, and the second is the harder one

1. **The list is unreachable.** Fixable by a pointer: the row names `[[new-project]]` seed as Owner, so say
   that the seed template *is* the section inventory and is to be read. Per `AGENTS.md` § *Defer to a shared
   inventory — never restate its lists*, it must be a pointer and **not** a copied list of four headings —
   the seed gains sections, and a copy would go silently wrong exactly as that rule predicts.
2. **Matching is by meaning, and nothing says how.** `LAYER.md` § *Detect what the repo has* demands
   *"never check for the shape you would have made"*, so a heading-text match is forbidden — yet both
   runners then had to invent a synonym mapping. Measured instances: `## Work Tracking & Lifecycle` ↔
   `## How we work — feature lifecycle` (accepted as present), and `## Commands` whose *content* lives in
   `README.md` §§ Build / Run while no guide section answers it. The `BardStudio` runner named the
   undecided question exactly: *"Nothing tells me whether a section answered in another file counts as
   present."*

## Acceptance criteria

- [ ] A survey can name a missing guide `##` section without reading anything the instructions did not send it to — by a pointer to the seed as the section inventory, never by a list copied into `LAYER.md` or a front door
- [ ] The pointer survives the seed gaining a section: adding one must not require editing the row
- [ ] Matching by meaning is given a stated rule, so two runs over one guide agree on whether a differently-named section answers a seed section
- [ ] The case where a section's **content** lives in another file (`README.md`) is decided explicitly — present, gap, or out of scope — and the reason is stated
- [ ] Layer parity: both front doors read the outcome from `LAYER.md`
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Judging the rules *inside* a present section. § *A guide's vintage is not surveyable* settled that (TASK-063) and this task does not reopen it.
- The four other artifact-shape gaps the same drills found — **TASK-091** (`present, elsewhere` on a conditional row, a guide split over several files) and **TASK-094** (survey instructions whose literal reading diverges from intent).
- Whether the seed should carry more sections. This is about reading the list that exists.

## Human test plan

- [ ] Cold-drill the survey against a repo whose guide is missing a seed section under a differently-named heading, with the expected answer withheld, and confirm the runner names the gap without being told where the list lives
- [ ] Add a section to the seed template and confirm no row needed editing for a survey to notice it

## Implementation plan

_Populated by `/tasks plan TASK-093` — leave empty until then._
