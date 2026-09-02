---
id: TASK-025
parent: STORY-013
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# DV10's "real code" test cannot see a repo whose code is prose

## Context

Found running `/roadmap` on this repo for TASK-002's drill (2026-08-18).

DV10 exists so the spec layer cannot go silently missing: *"the project has real code (a `src/` tree
or build manifest with tracked sources) but no `docs/specs/.map.yml` — **or the map's `areas:` list is
empty** … every spec check skips when the map is missing/empty, so nothing else will ever surface
this."*

This repo is exactly the situation DV10 is for. `docs/specs/.map.yml` exists with `areas: []`, seeded
empty and never filled; STORY-008 exists to harvest the specs and has not been started; sixteen
skills' worth of behaviour is unspecified. And DV10 **does not fire**, because the repo has no `src/`
tree and no build manifest — its source is `skills/**/*.md`. The rule's own escape hatch reads
"tracked sources", but the two detectors offered for it are both artifacts of compiled/packaged
projects.

So the check that exists to catch a silently-absent spec layer is itself silently absent, on the repo
that ships it. Worth fixing rather than noting, because the failure is invisible by construction: a
project of this shape gets a clean `/roadmap` forever, and `docs/specs/` stays a scaffold nobody is
reminded about.

The same blind spot hits any docs-first or config-first repo — a documentation site, a Terraform
module collection, a prompt library, an ADR archive.

**Sibling, not duplicate: TASK-062** (closed 2026-08-23) fixed the *same blind spot* in a different file —
`LAYER.md`'s test-harness evidence ladder returned `missing` for this repo's own script suite, because every
entry asked for a declaration (manifest, filename, config) and none asked what the gate actually runs.

**They stay separate deliberately.** That was `adopt-project`'s survey deciding an artifact is absent; this is
`roadmap`'s DV10 deciding a repo has no code worth speccing. Different consumer, different failure (a false
`missing` that invites a fill, versus a check that never fires), different file. What they share is the
premise — *detection written for compiled languages, applied to a repo whose product is prose*. TASK-062's
fix is worth reading first: it generalised to **observed execution** rather than adding a glob, and the same
move may apply here (what does the repo's gate treat as source?).

## Acceptance criteria

- [x] DV10's code-detection test recognises a repo whose tracked source is neither a `src/` tree nor a build manifest. What counts as "real code" is the judgement to make explicitly — a candidate is *tracked files that the spec map's own `ignore:` list does not exclude*, which for this repo is `skills/**` and nothing else
- [x] The rule reads off the map's `ignore:` list rather than a second hard-coded notion of source, so a project that already told the spec layer what its source is does not have to tell `roadmap` again
- [x] DV10 fires on **this** repo until `areas:` is filled, and stops firing once STORY-008 lands
- [x] It does **not** fire on a genuinely source-free repo — a notes vault, a fresh scaffold with nothing but the layer — where the absent spec map is correct rather than a gap
- [x] Whatever the test becomes, it lives in [[roadmap]]'s Cross-tree pass, which owns the divergence rules; [[tasks]] and [[feature]] render slices and must not carry a second copy
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Filling `areas:` for this repo — that is STORY-008, and this task only makes the reminder work.
- The other divergence rules' heuristics; DV5's "one tree only" behaviour on this repo is correct and reported as by-design.
- `/specs init`'s own area-discovery for prose repos. If it turns out `specs` cannot map a markdown skill library either, that is a second finding and gets its own task.

## Human test plan

- [x] ~~Run `/roadmap` on this repo and confirm DV10 fires~~ — **inverted by TASK-079**, which filled `areas:` a day before this task ran, removing the firing case the plan was written against. Tested in the achievable direction: a throwaway clone with the empty seed restored fires at step 1 (63 tracked files the map's own `ignore` does not exclude), and the real repo is correctly silent
- [x] Fill `areas:` in a throwaway copy and confirm DV10 goes quiet
- [x] Run it on a notes-only fixture (markdown, no skills, no manifest) and confirm DV10 stays silent — the false positive is the failure mode that would make the rule ignorable
- [x] Run it on a normal `src/`-tree project and confirm the existing behaviour is unchanged

## Implementation plan

_Populated by `/tasks plan TASK-025` — leave empty until then._

## Progress log

- step 2 — picked. Won keys 1, 3 and 5 over eleven siblings, but the deciding argument is one the pool could not have shown yesterday: **TASK-079 fixed this defect's consequence and left its cause standing.** DV10 exists to notice a silently-absent spec layer; this repo's sat at `areas: []` from 2026-08-18 to 2026-09-01 with sixteen skills unspecified, and DV10 **never fired once**. I filled the map by hand. The check is still blind for the next repo of this shape.
- step 3 — verified: held, and the task's own two pointers were both right. `roadmap/SKILL.md:92` tested for *"a `src/` tree or build manifest with tracked sources"* — both artifacts of compiled/packaged projects. Criterion 5 confirmed structurally: `grep -rn DV10` outside `skills/roadmap/` returns **nothing**, so there is no second copy to keep in sync.
- step 4 — layer: local.
- step 5 — fix in `skills/roadmap/SKILL.md`: DV10's row now points at a new § *DV10: what counts as code*, which **asks the repo what its source is** rather than testing for one shape, in a four-rung ladder that stops at the first answer — the spec map's own `ignore:` list; failing that, what the repo's **gate** runs over; failing that, `src/`-or-manifest, **kept last rather than deleted** so a conventional project is untouched; and failing all three, **stay silent and say the check could not decide**. `coverage: not-applicable` on the map short-circuits the whole thing, because that is `/specs init`'s own declaration that it looked and found nothing.
- step 5a — **the ladder ends in silence for a reason criterion 4 demanded.** *"Non-empty tracked set"* is the obvious test and it over-fires: a notes vault, an ADR archive and a fresh scaffold all have tracked markdown, and a check that cries wolf on correct repos is worth what an unrun one is. Markdown alone cannot distinguish a skill library from a notes vault — which is exactly the pair that must not collapse — so steps 1-3 are all **declarations the repo made about itself** and step 4 is the absence of one. This is the same declaration-over-inference rule the rest of the set runs on, and it is why the remedy DV10 prints is `/specs init`: that verb can report `not-applicable`, where DV10 can only suspect it.
- step 5b — took TASK-062's move rather than its shape. That sibling fixed the same blind spot in `LAYER.md` by asking **what the gate actually executes** instead of adding a glob; step 2 of this ladder is that generalisation, and adding `**/*.md` to a hard-coded list would have fixed this repo and no other.
- step 6 — reverted fix: all four fixtures from the test plan walked, and **two of them have their order inverted by TASK-079**, which filled `areas:` yesterday and so removed the firing case the plan was written against. Tested in the achievable direction instead: **A** this repo as-is, 14 areas ⇒ clause 1 false ⇒ **silent** ✓; **B** a throwaway clone with the empty seed restored ⇒ step 1 finds **63** tracked files the map's own `ignore` does not exclude ⇒ **fires** ✓; **C** a notes-vault fixture (2 tracked markdown files, no map, no gate, no manifest) ⇒ step 4 ⇒ **silent** ✓, which is the false positive criterion 4 forbids; **D** a `src/`-plus-`pyproject.toml` fixture ⇒ **fires at step 3** ✓. **C and D differ only at step 3** — the original test — so the ladder demonstrably preserves existing behaviour and only adds declarations above it and silence below. Fixtures removed.
- step 6a — **honest gap: step 2 is unexercised.** No repo in this fleet has a CI gate except this one, and here step 1 answers first, so *"what the repo's gate runs over"* is reasoned rather than tested. Recorded rather than glossed: it is the rung most likely to be wrong, because it is the only one with no measured instance behind it.
- step 7 — respecced: **not skipped this time.** `docs/specs/.map.yml` now carries 14 real areas, so step 7's usual *no usable spec map* branch no longer applies — the first task all session where it does not. The changed file is `skills/roadmap/**`, which the map assigns to **`project-roadmap`**; no spec **body** exists yet for it (TASK-080 generates them), so there is no spec text to contradict and nothing to regen. Recorded because the state changed: from here on, a task touching a mapped area with a generated body owes a real regen at this step.
- step 8 — three-axis gate. **standards — pass.** Rulebook `AGENTS.md § Conventions`, rung 1; one skill file. § *Defer to a shared inventory* honoured — step 1 reads the map's own `ignore:` rather than adding a second notion of source, which is what criterion 2 asked for. Criterion 5 structural: DV10 exists in exactly one file. **One convention catch on my own diff:** I had copied *"sixteen skills' worth"* from the task's 2026-08-18 context into shipped prose. There are eighteen now, and § *A count in evidence names where the count came from* says name the source or give no number — so it now reads *"every skill in the set… for two weeks"*, which cannot rot. **fidelity — pass**, all six criteria built. **correctness — pass**, with the step-2 gap recorded rather than hidden. **security-review — not applicable:** one markdown file, no surface. 5c skipped — `single-branch`. 5d: `## Out of scope` bullets are boundaries naming STORY-008, DV5 and a possible second finding; nothing spawned.
- step 8a — closed `done`. All four fixtures walked, two with their order inverted by TASK-079. The one honest gap — step 2 unexercised, because no repo in this fleet has a CI gate — is on the record rather than papered over.
