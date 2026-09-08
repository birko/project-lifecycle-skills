---
id: TASK-079
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-26
depends-on: [TASK-106]
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
- **The area-name collisions the third read found** — **TASK-105**. `change-review` vs `work-tracking`,
  `feature-lifecycle` vs `glossary-and-adrs`, `defect-draining` vs `work-tracking`. Two of those three
  pairs did not exist when this task's map was written; the `change-review` one was created by
  TASK-104's merge.
- **Making a cold reader available at all** — **TASK-106**, which this task now `depends-on`. Until it
  lands, human test plan item 1 cannot be run, only approximated.

## Human test plan

**RETIRED 2026-09-08 — not ticked, not softened, and deliberately not a checkbox.** The original item is
  preserved verbatim below because `close` forbids rewriting a criterion to fit the result, and this must be
  auditable as a *retirement with evidence* rather than a bar quietly lowered.

  > ~~Read the area list cold and confirm each name is a capability a *consumer* would recognise, not an
  > internal file grouping.~~

  **Why it cannot be met by any run.** The item has two halves. The file-layout half is a fact about the
  names and is stable. The *"a consumer would recognise"* half requires a reader's reaction, and four reads
  produced four different sets of objections — about four names each, with only `glossary-and-adrs` objected
  to more than once. Two reversals settle it:

  | Name | Verdict |
  |---|---|
  | `installation` | read 2: *"not a capability at all… a README section."* read 4: *"unambiguous — yes."* Unchanged name, opposite verdicts. |
  | `project-baseline` | **exists only because read 2 asked for it**; read 4 calls it *"a builder's word for the initialized state. Nobody shops for a baseline."* The fix one reader requested is what the next reader failed. |

  So the loop has no terminal state: rename what a reader flags, and the next reader flags four others. The
  test measures the reader, not the names. Read 4 was the **first verified-cold runner** this repo has ever
  had (task 0 returned `NONE`; zero product vocabulary absent from its brief), so this is not a contamination
  artefact — it is the item's own shape.

- [x] **The achievable half, checked and passing:** no area name refers to the repo's file layout.
      `cross-tree-reporting`, `review-gate-fallbacks` and `skill-set-validation` did; none of the 14 does now.
      This is a fact about the names rather than a reaction to them, and every read has agreed on it since
      read 1.

**NOT claimed** (a note, deliberately not a checkbox — a box nobody can ever tick is the defect just
  retired above, arriving again): that the names are good. Four cold reads say otherwise and their objections rotate.
      The residue is **TASK-105**, which owns the part renaming cannot fix — two areas describing the same
      gate — and **TASK-113**, which owns the capabilities no area covers. Left unticked on purpose: this
      line is a pointer to open work, not a result.
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
- **third cold read attempted 2026-09-08, and the instrument turned out to be broken.** The runner was
  given the 14 names and titles alone — no repo, no files, no tools, and it used none — but its report
  named ten skills whose names appear nowhere in the brief (`grill-me`, `handoff`, `populate-tests`,
  `fix-next`, `new-project`, `adopt-project`, `roll-changelog`, `domain`, `tdd`, `write-a-skill`). A
  subagent spawned in this repo inherits `AGENTS.md`, whose § *Naming* lists exactly those. **It could
  not have been cold, and neither can any subagent runner here.** Filed as TASK-106; `populate-tests`
  § *The cold drill* claims the opposite in as many words.
- **item 1 stays unticked, now for a better-understood reason.** The method's own rule is that a
  discounted or weak-evidence result stays unticked rather than ticked with a caveat, and a
  contaminated runner is the definition of weak evidence in the pass direction. What the run *did*
  produce is a conclusive **negative** — a reader who knew the product still could not choose between
  `change-review` and `work-tracking` (*"the same sentence twice"*) — and that survives contamination
  by the asymmetry the method names. Filed as TASK-105.
- **what is NOT known, recorded rather than smoothed over:** this log's two earlier readers are
  described above as *"given only the names and titles — no repo, no files"*, and nothing here records
  **how they were obtained**. If they were subagents they were contaminated identically, and those two
  entries claim more than the evidence supports. TASK-106 owns correcting that; it is not being
  rewritten here, because an append is the honest shape and a rewrite would hide that the question was
  ever open.
- **the channel is now identified, and it was not the one this log blamed. (TASK-106, 2026-09-08.)** Two
  contamination channels exist, not one: the project guide, **and** the user-level installed skill roster.
  Measured — a print-mode session started in `WebChecker`, a repo with no agent guide at all, still listed
  the full roster with descriptions; only disabling installed skills emptied it. So **no acquisition method
  in use before 2026-09-08 excludes contamination**: subagent or fresh session, in this repo or any other,
  the roster was loaded unless a flag nobody knew mattered was passed.
- **what is not known, and now permanently:** whether readers one and two were subagents. Nothing recorded
  it and nothing can reconstruct it. The entries above describe the **brief** they were given — *"given only
  the names and titles — no repo, no files"* — which is silent about the channel that decides. That is
  precisely the failure the new rule in `AGENTS.md` § Testing exists to prevent, and this log is the
  measured instance it cites.
- **what follows, stated conservatively.** Their pass-direction verdicts are weak evidence. Their
  *objections* survive by the asymmetry the method names — a reader holding the answer who still could not
  follow the prose has demonstrated something about the prose. **The renames applied on their strength are
  not being unwound**, and the reason is not that the reads were sound: the map was verified mechanically
  (63 of 63 mapped, no overlaps, contract keys correct) and the names have since been reviewed on their own
  terms in TASK-103 and TASK-104. Say that, rather than implying the renames were cold-read-backed.
- **what is now possible:** a cold runner is obtainable by the recipe recorded in `populate-tests`
  § *Acquiring a cold runner*, so human test plan item 1 becomes runnable for the first time. That happens
  under this task, not under TASK-106 — TASK-106 scopes it out explicitly, and harvesting its verification
  run for item 1 would be the same author's-own-pass the drill method rejects.
- **item 1 retired 2026-09-08, on the first verified-cold read this repo has obtained.** Runner acquired by
  the recipe TASK-106 documents; titles generated from `.map.yml` rather than retyped, after the TASK-106 run
  was found to have abbreviated `installation`'s title and drawn an objection to my transcription rather than
  to the product. Result: 4 × `no` (`feature-lifecycle`, `project-baseline`, `glossary-and-adrs`,
  `idea-interrogation`), 3 called internal groupings, and `defect-draining` / `idea-interrogation` flagged as
  a *separate* failure — coined vocabulary rather than internal naming.
- **the decision was the user's, taken on the rotating-objection evidence**, not mine to make: keep the half
  that can pass, retire the half that cannot, and record why so nobody opens round five. The original wording
  is preserved struck-through rather than edited away.
- run preserved at `docs/DRILL-079-item1-2026-09-08.txt`.
- closed 2026-09-08 via `/tasks close`. `integration: single-branch`, so no branch and no merge step.
