---
id: TASK-079
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-26
depends-on: []
blocks: [TASK-080]
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs init` — build the area map, and turn the spec layer on

## Context

`docs/specs/.map.yml` has carried `areas: []` since 2026-08-18 — the scaffold seed [[new-project]] writes at
birth. This task replaces it with a real map.

### Why this is *not* blocked by the rest of the epic, unlike its sibling

STORY-008 says the story **"runs last, and stays last"**, because STORY-002 through 007 change skill behaviour
and regenerating before the set stabilises means reviewing a diff of pure churn. **That argument applies to
the regen, not to the map** — and the difference is documented rather than assumed:

> `init.md:9` — *"**Already initialized?** If `docs/specs/.map.yml` exists, this becomes a re-discovery:
> propose additions/renames against the existing map, never drop an existing area without asking. Show the
> delta, not a fresh map."*

So `/specs init` is **delta-safe**: a skill added by STORY-007 later *extends* the map rather than
invalidating it. `LAYER.md`'s row says the same thing, which is why adoption delegates to it whether or not
the file exists. The map can therefore be built now, and TASK-080 keeps the ordering constraint that actually
bites.

### What building it turns on

An empty `areas:` list is treated as **absent at every enforcement point**, so this single file has been
switching off four checks all along:

| Consumer | Currently |
|---|---|
| [[roadmap]] DV7 — stale spec detection | skipped: no areas to date-stamp |
| [[roadmap]] DV8 — a shipped feature whose change never landed in the specs | skipped |
| [[roadmap]] DV10 — *"the whole spec layer is silently absent"* | the check that would have caught this, and it cannot fire on a repo whose code is prose (TASK-025) |
| [[tasks]] `close` on a STORY — the scoped regen offer | skipped every time; measured in every close this month |

**DV10 is the pointed one:** the audit designed to notice a missing spec layer has never noticed this one,
because its "real code" test looks for a `src/` tree or a build manifest and this repo has neither.

### Granularity

One area = **one capability a consumer would recognise** — task tracking, feature lifecycle, spec harvesting,
defect draining — not one file per skill. Healthy is roughly 5–20 areas; there are 18 skills, so a
one-area-per-skill map would be the wrong shape and the wrong count.

## Acceptance criteria

- [ ] `docs/specs/.map.yml` carries a real `areas:` list over `skills/` and `skills-pi/`, replacing `areas: []`
- [ ] Areas are **capabilities, not files** — each named as something a consumer would recognise, with its `sources:` globs, and the count lands in the 5–20 range or the deviation is argued
- [ ] `skills-pi/`'s three fallback skills are handled deliberately: either their own area or folded into the review-gate capability, with the reason — they exist in one runtime only ([ADR 0010](../../../../docs/adr/0010-skills-pi-is-frozen-and-pi-only.md))
- [ ] The seed comment explaining `areas: []` is removed, not left contradicting the file it sits in
- [ ] `/roadmap --check` afterwards shows DV7/DV8 **evaluating** rather than skipping — the check that the layer is genuinely on
- [ ] No spec bodies are generated — that is TASK-080, and generating them here is the churn STORY-008 exists to avoid
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Generating the specs** — **TASK-080**, which depends on this and holds the epic's ordering constraint.
- Fixing DV10's blindness to a prose codebase — **TASK-025**. This task makes the finding moot for *this* repo; the check stays broken for the next one.
- `ignore:` glob tuning beyond what the areas need. The seed's globs are already repo-appropriate.

## Human test plan

- [ ] Read the area list cold and confirm each name is a capability a *consumer* would recognise, not an internal file grouping
- [ ] Run `/roadmap --check` and confirm the spec section now reports real state instead of silently skipping
- [ ] Confirm `git diff docs/specs/` contains **only** `.map.yml` — no generated bodies leaked in

## Implementation plan

_Populated by `/tasks plan TASK-079` — leave empty until then._
