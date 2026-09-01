---
id: TASK-079
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
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

- [x] `docs/specs/.map.yml` carries a real `areas:` list over `skills/` and `skills-pi/`, replacing `areas: []`
- [x] Areas are **capabilities, not files** — each named as something a consumer would recognise, with its `sources:` globs, and the count lands in the 5–20 range or the deviation is argued
- [x] `skills-pi/`'s three fallback skills are handled deliberately: either their own area or folded into the review-gate capability, with the reason — they exist in one runtime only ([ADR 0010](../../../../docs/adr/0010-skills-pi-is-frozen-and-pi-only.md))
- [x] The seed comment explaining `areas: []` is removed, not left contradicting the file it sits in
- [x] `/roadmap --check` afterwards shows DV7/DV8 **evaluating** rather than skipping — the check that the layer is genuinely on
- [x] No spec bodies are generated — that is TASK-080, and generating them here is the churn STORY-008 exists to avoid
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Generating the specs** — **TASK-080**, which depends on this and holds the epic's ordering constraint.
- Fixing DV10's blindness to a prose codebase — **TASK-025**. This task makes the finding moot for *this* repo; the check stays broken for the next one.
- `ignore:` glob tuning beyond what the areas need. The seed's globs are already repo-appropriate.

## Human test plan

- [ ] Read the area list cold and confirm each name is a capability a *consumer* would recognise, not an internal file grouping — **unticked deliberately: two cold reads, the second still objecting to four names. The file-layout half of this item passes (no name refers to the repo's directories any more); the capability half does not, and the residue is filed as TASK-103. Not ticked with a caveat beside it, because a caveat disappears and an unticked box does not.**
- [x] Run `/roadmap --check` and confirm the spec section now reports real state instead of silently skipping
- [x] Confirm `git diff docs/specs/` contains **only** `.map.yml` — no generated bodies leaked in

## Implementation plan

_Populated by `/tasks plan TASK-079` — leave empty until then._

## Progress log

- picked 2026-09-01 via `/tasks pick`, **not** `/fix-next` — this is planned work in EPIC-001, not a defect in the review-intake pool, so the drain was structurally blind to it. That blindness is the reason it waited: `fix-next` step 7 printed *"no usable spec map — run `/specs init`"* on **nine** closes today, correctly and uselessly, because the verb that would act on the line cannot pick the task that fixes it.
- discovery — scan set resolved by the shared rules before counting anything, and **two of my own command errors were caught by doing so**. `':(glob)*'` does not cross `/`, so my first scan returned 12 files and **zero** from `skills/` — I read that as a finding for a moment before recognising it as my pathspec. Then `':(glob)!…'` is not exclusion magic and silently excluded nothing, returning 221 of 221. The correct form is `':(glob,exclude)…'`. This is exactly what `init.md` means by *"a count taken under any other reading is not reproducible"* — three readings, three different numbers, and only one of them true.
- discovery — final scan set **63 of 221 tracked**. Removed by ignore: 122 `tasks/`, 14 `docs/`, 13 `*/templates/*`, 1 `ci.yml`, 8 root furniture files.
- **coverage-drift, and it changed the ignore list.** At first scan the seed ignored `.github/**` wholesale, which hid `skills-lint.sh` and `skills-lint-test.sh` — **548 lines of executable shell, five checks, 43 test cases, and the only executable behaviour in the repo**. `ci.yml` beside them is genuinely config; the two scripts are not. The ignore was narrowed to `ci.yml` alone and the scripts became their own area. Classified as **drift** (behaviour the map could not see), not housekeeping — the distinction `init.md` step 4 requires. The 8 root files (`AGENTS.md`, `README.md`, licence, dotfiles) went the other way, into `ignore` as housekeeping: normative for contributors, not a capability the product provides.
- **15 areas, verified mechanically rather than asserted.** `git ls-files` over the scan set against the area globs: **63 in scope, 63 mapped, 0 unmapped, 0 mapped-but-ignored, no file in two areas**, and no area empty (largest `work-tracking` 18, smallest five at 1). `coverage: verified` is therefore a measured verdict, not a claim.
- **`skills-pi/` given its own area, per criterion 3.** Not folded into the rulebook checks: those three are frozen fallbacks existing in **one runtime only** ([ADR 0010](../../../../docs/adr/0010-skills-pi-is-frozen-and-pi-only.md)), so a consumer's answer to *"what reviews my code"* differs by runtime. That is a capability boundary, not a packaging detail, and folding them in would make one spec describe two runtimes at once.
- **Fixed a contradiction in my own header comment before the gate** — it claimed *"the four review skills are one area"* while the map below splits them into two. The map was right and the comment was a leftover from an earlier draft.
- **contract check caught two defects in my own file before the gate.** `/specs` defines exactly **three** coverage keys, and I had invented a fourth (`scan-set-at-scan`) — silently ignored by every consumer, and worse, a second number beside the tree size reads as a coverage fraction, which `SKILL.md` warns against by name. And I had written `coverage-drift` as a **comment block** rather than a real key: the contract is emphatic that it is *"a list of paths and never a bare count"*, and an **absent** key means *not computed* — which was false, since I had computed it. Both fixed; the file now carries exactly `coverage`, `tracked-files-at-scan`, `coverage-drift`, `areas`, `ignore`.
- **human test plan item 1 (cold read of the names): FAILED first, and the failure was the point.** A reader given only the 15 names and titles — no repo, no files — called **four of them internal groupings**: `review-gate-fallbacks` (*"names a circumstance, not a capability… nobody installs a library wanting fallbacks"*), `cross-tree-reporting` (*"'tree' is a word the authors earned by having two directories. Zero consumers have that word"*), `adherence-and-intent-review` (*"the only name with an 'and', which almost always means two things were stapled"*), and `skill-set-validation` (*"whose skills?"*). It also caught `spec-harvesting` as an author-side metaphor hiding the actual selling point, and `domain-vocabulary` as a name it would never look under for a decision record. Its structural observation was the sharpest: **the titles leaned on definite articles for concepts the reader had not met** — *"**the** universal project layer"*, *"**the** close gate"* — which it called *"the clearest single symptom that these were written from the inside out."*
- renamed rather than ticked: `review-gate-fallbacks` → **`code-and-security-review`**; `cross-tree-reporting` → **`roadmap`**; `spec-harvesting` → **`specs-from-code`**; `skill-set-validation` → **`skill-contract-lint`**; `domain-vocabulary` → **`vocabulary-and-decision-records`**; and `adherence-and-intent-review` **split into two areas**, `convention-conformance` and `intent-verification`, because the reader was right that the "and" was two skills stapled. **16 areas**, still in the 5-20 range, coverage re-verified at **63/63 with nothing unmapped**. Every title rewritten to stop presuming the reader already holds the term.
- re-drilled the revised names cold rather than ticking on the strength of my own fix — that is exactly the author's-own-pass the drill method rejects.
- **second cold read: better, still not clean, and the two readers contradict each other.** Confirmed working: `specs-from-code` (*"the best name in the set"*) and `code-and-security-review` (*"capability, clear"*). Still objected to: `installation` (*"not a capability at all — this is a README section"*), `skill-contract-lint` (maintainer-facing), `vocabulary-and-decision-records` (*"the 'and' is the confession"*), and — **directly against reader one** — `roadmap`, which reader one proposed by name and reader two calls *"actively misleading… promises a timeline and delivers a drift report"*. One genuine naming defect: reader two **guessed `intent-verification` wrong**, taking it for *inferring what code intends to do*.
- **stopped iterating rather than chasing a third reader.** Two independent readers disagreeing on one name is the point at which further rounds fit individual taste, and a check that reports differently every run is worth what an unrun one is — this repo's own argument about degenerate ranking keys. Applied only what both agreed on: the `skill-contract-lint` title now names its audience outright, and `vocabulary-and-decision-records` records that its "and" is the **skill's** scope, not a filing choice, so the map has no split available.
- **the residue is a product finding wearing a naming complaint, and is filed as TASK-103.** Both reads independently produced the same structural objection: four areas that all read as *"something checks my change"* and cannot be sorted from names alone, three overlapping places work can live, and `idea-interrogation` reading as a phase of `feature-lifecycle` rather than a peer. Renaming areas cannot fix a boundary the product does not draw.
- **closed at `review`, not `done`.** Human test plan item 1 failed twice and is unticked; items 2 and 3 pass. All seven acceptance criteria are met and the map itself is verified — 63 of 63 mapped, no overlaps, contract keys correct — but ticking a cold-read item after two failing cold reads would be exactly the caveat-beside-a-tick this session has been refusing all day.
