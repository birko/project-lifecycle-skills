---
id: TASK-093
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
picked-by: fix-next
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

- [x] A survey can name a missing guide `##` section without reading anything the instructions did not send it to — by a pointer to the seed as the section inventory, never by a list copied into `LAYER.md` or a front door
- [x] The pointer survives the seed gaining a section: adding one must not require editing the row
- [x] Matching by meaning is given a stated rule, so two runs over one guide agree on whether a differently-named section answers a seed section
- [x] The case where a section's **content** lives in another file (`README.md`) is decided explicitly — present, gap, or out of scope — and the reason is stated
- [x] Layer parity: both front doors read the outcome from `LAYER.md`
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Judging the rules *inside* a present section. § *A guide's vintage is not surveyable* settled that (TASK-063) and this task does not reopen it.
- The four other artifact-shape gaps the same drills found — **TASK-091** (`present, elsewhere` on a conditional row, a guide split over several files) and **TASK-094** (survey instructions whose literal reading diverges from intent).
- Whether the seed should carry more sections. This is about reading the list that exists.

## Human test plan

- [x] Cold-drill the survey against a repo whose guide is missing a seed section under a differently-named heading, with the expected answer withheld, and confirm the runner names the gap without being told where the list lives
- [x] Add a section to the seed template and confirm no row needed editing for a survey to notice it

## Implementation plan

_Populated by `/tasks plan TASK-093` — leave empty until then._

## Outcome

**What the fix was.** `LAYER.md`'s agent-guide row told a survey to *"add missing `##` sections"* without
saying anywhere which sections the layer expects. The list exists only as headings inside
`templates/CLAUDE.seed.md`, and the adopter's entire reading set — `adopt-project/SKILL.md`, its
`INFER.md`, and `LAYER.md` — never named that file. So a compliant run reports a guide `present` with no
missing sections, on a repo whose guide is missing the section explaining the 18 features it already keeps.
The row now names the seed as the inventory, and a new § *Matching a guide's sections* supplies the two
rules that make the question answerable: read the headings off the seed every run, and match **by meaning,
never by heading text**.

**The step-6 split.** The mechanical half has a real guard and it was demonstrated failing: renaming the
seed template makes the lint exit 1 with `ERROR skills/new-project/LAYER.md links to
templates/CLAUDE.seed.md — not found`. Check 3 scans every `.md` under `skills/` bar `templates/`, so the
pointer cannot rot silently — which was precisely the failure mode. Restored, both suites green. The prose
half rests on three measurements rather than on assertion: the negative control scores **4/4** on this
repo's own guide and **4/4** on `WorkoutTracker`, where TASK-063's rejected rule-list test flagged this
repo's guide; and `Symbio` matches **0 of 4 by text** (⇒ four false missing, the rejected behaviour) against
**3 resolved by meaning** plus one honest judgement. **Contract pin, not evidence:** `skills-lint-test`
43/43 — untouched, and it cannot observe a prose rule.

**Judgement calls, and the stricter option rejected.**

- **The fix is a pointer, not a copy, and it lands in `LAYER.md` alone.** The stricter-looking option was to
  restate the four section names in `adopt-project`'s step 1 so the survey needs no second file. Rejected as
  the defect wearing a different hat: § *Defer to a shared inventory — never restate its lists* exists for
  exactly this, and a copy would report a guide complete against a list one section short the day the seed
  grows. For the same reason there is **no `adopt-project` edit at all** — the survey walks `LAYER.md`'s
  rows, so the row is where the pointer belongs, and layer parity is structural rather than a second edit.
- **A section diff is allowed where TASK-063 rejected a rule-list diff, and the change argues it rather
  than assuming it.** That prior decision is the strongest reason *not* to make this change, so the new
  section answers all three of its grounds on measurements. The asymmetry is granularity: four whole topics,
  each answerable as *does the guide answer this at all*, against eight-plus named rules where two runs
  produced two different lists.
- **`## Conventions` defers to [[verify-conventions]]'s ladder instead of getting its own test.** A second
  test would be a second definition of what a rulebook is, and `INFER.md` already defers to that ladder —
  so all three skills now agree. The ladder also already handles the non-English case its own rung 3
  documents.
- **Content in another file counts as `present`, with one exception.** Reporting `BardStudio`'s absent
  `## Commands` as missing would offer a second copy of what its `README.md` §§ Build / Run already
  document — the false-`missing` this file calls the dangerous direction. `## Conventions` is the exception,
  because it is the file `verify-conventions` reads at every gate; rules parked elsewhere are unreachable by
  the thing that enforces them.
- **De-hard-coding `:176`'s "all four `##` sections" was not asked for and was done anyway.** A written
  count is the same rot the pointer removes — it goes wrong the day the seed gains a section, which is
  criterion 2's whole subject. One word, named here rather than slipped in.

**Two gaps in this change, found in its own review pass and fixed rather than spawned.** Both were defects
in prose this change wrote, so they belonged in it: the residual meaning-match ambiguity had no stated
handling (now: report it *undetermined and why*, and let step 2's round settle it, as a conditional row's
unsettled condition already does), and a guide whose rules are **woven through it** rather than sectioned
would have been reported as missing `## Conventions` and had one appended — creating the second home for
rules the guide's own rulebook forbids. The second is the more dangerous of the two, because the remedy
does the harm.

**Flagged, not fixed.** The residual judgement is real and bounded: the by-meaning test still leaves one
call per ambiguous section, and it is the same defect *class* as **TASK-095** (a by-meaning verdict with no
threshold), filed from the same drills. Not merged into it — 095 is about thin-versus-covered for
*proposals* and this is about section presence — but whoever picks 095 should read this section, since a
single answer may serve both.

## Drill record

Two cold readers, 2026-09-01, read-only, expected answers withheld, neither allowed this repo's `tasks/`
or `docs/`. Fixture selection was itself constrained: **this change's own prose names `Symbio`,
`WorkoutTracker` and `BardStudio` with their answers**, disqualifying all three per TASK-068's rule. The
seed carried a temporary fifth section (`## Observability`) during both runs, so the drill could test the
half a grep cannot — whether a survey *notices* a section added after the prose was written. It has since
been removed; the seed is back to four.

### The A/B on `Birko.Framework` — the same fixture, before and after

This is the strongest result available, because the earlier drill that produced this task ran on the same
repo with the same input.

| | Earlier run (pre-fix) | This run (post-fix) |
|---|---|---|
| Did it find the inventory? | *"The skill **never tells me** which `##` sections the layer expects, and **never points me at the seed**."* | *"LAYER.md's guide row: **'The section inventory is templates/CLAUDE.seed.md's own `##` headings — read them off it'** … So I grepped the seed rather than using any list in prose."* |
| How? | reached into the seed **uninstructed** | followed the row |
| Consequence it projected / produced | *"a run that stayed inside the three named files would report the guide `present` with **no missing sections named**"* | **found the missing lifecycle section and flagged it loudly** |

Its reasoning on that finding is the consequence this task was filed on, now detected instead of missed:

> *"The guide commits to the tree in one clause, the tree exists with 18 members, and the section
> explaining how anything gets into it is absent."*

### Confirmed on both fixtures

- **Read off the file, every run.** Both grepped the seed. `Latent`'s runner: *"That grep is the comparison basis; nothing else was."*
- **A newly added section is noticed with no row edited** — test plan item 2's live half. Both found `## Observability`, which did not exist when the section was written.
- **Match by meaning, not heading text.** `Birko.Framework`'s runner resolved `## Commands` to the README's Getting Started / Running Tests via the content-in-another-file rule, citing the `BardStudio` precedent, and refused a heading-shaped test on the lifecycle section — running eleven term counts across 2587 lines before calling it absent.
- **`## Conventions` deferred to [[verify-conventions]]'s ladder**, both times, at rung 1, with neither writing a second test. `Latent`'s runner said so explicitly: *"per the seed-section table I did not write a second test."*
- **The ambiguity rule added during this change's own review pass fired on both runs.** Each hit a genuinely undetermined section and reported it rather than deciding: `Latent`'s `## Observability` (*"whether it warrants appending is for step 2's round"*), `Birko.Framework`'s (framework telemetry docs answer what the framework *offers consumers*, not where this repo's own telemetry goes).
- **The vintage rule held.** Neither diffed rules inside a present section — `Birko.Framework`'s runner had 1687 lines of flat `## Conventions` bullets in front of it and left them alone, naming § *A guide's vintage is not surveyable* as the reason.

### What the drills found wrong with this change

**Both runners independently caught a hard-coded count in the new section** — *"On sections, that guide
scores 4 of 4"* — contradicting the same section's own read-it-off-the-file rule, against a five-section
seed. Both chose the rule over the number and both said what the other choice would have cost:

> *"Had I trusted the number, `## Observability` would never have been checked."*

> *"Against four, this repo's guide would have scored 3/4 with `Observability` never raised."*

Fixed in this change: the negative control now records *"every section the seed carried when this was
measured (2026-09-01)"* and says outright why no number is written. **The irony is the finding** — the same
paragraph that removed a rotting count from `:176` introduced one of its own two screens later, and only a
reader against a grown seed could see it.

**One imprecision, also fixed here:** the row said the inventory is the seed's `##` *headings*, and both
runners reached for the section **bodies** as well, one explaining that *"matching by meaning is impossible
without knowing what question each heading covers."* The rule now says to read the bodies too.

**Filed as TASK-096:** the `.env.example` row cannot say what *"here"* means for an aggregator whose 343
projects all live in sibling repos, and does not distinguish a **build-time** environment variable from
runtime config — the latter derived independently by three runners across four drills, which is the
signature of a rule that is not written down.

## Progress log

- step 2 — picked; ranked above TASK-086 (the previous run's named next pick) because the pool changed: this task did not exist then. Tie on key 1 — both produce wrong results, and neither destroys anything, since git retains the work TASK-086 would sweep in. Won on key 2 (fires on every adoption of a partially-seeded guide, the brownfield norm, where 086 needs user WIP under a layer path at that moment), key 3 (silent clean table vs a refusable offer), key 4 (086's own task forbids choosing among its four candidates unattended), and key 5 (two independent cold readers with a measured consequence vs one reviewer's read). Key 6 inert: every candidate STORY declares `correctness-invariants`.
- step 3 — verified: held, and sharpened. The survey's whole reading set (`adopt-project/SKILL.md`, its `INFER.md`, `new-project/LAYER.md`) mentions a missing `##` section three times — `LAYER.md:21`, `:176`, `:199` — and `grep` for `CLAUDE.seed` or `templates/` across all three returns **zero hits**, so the list is genuinely unreachable. Sharpened detail the filing missed: **`LAYER.md:176` leaks the count without the list** ("all four `##` sections present"), so a reader learns there are four and never which four. Seed's actual four: How we work — feature lifecycle, Architecture, Conventions, Commands. **Also newly established, and it changes the fix:** TASK-063 already measured and *rejected* a rule-list diff against the seed, on three grounds. The coarser `##`-section test must be shown to survive those same three, not assumed to.
- step 4 — layer: local.
- step 5a — measured the three objections against the coarse test before writing. **Negative control passes where the rule test failed:** TASK-063 rejected the rule-list diff partly because *"this repo's own `AGENTS.md` — current, dense, the thing an upgrade run must not flag — omits two of the seed's named items."* On sections, this repo scores **4/4** (`AGENTS.md:18,71,90,297`) and so does `WorkoutTracker` (`13,36,58,299`). The test does not flag the guides it exists to leave alone. **The shape-we-would-have-made objection is real and survivable:** `Symbio`'s guide is 19 `##` sections of Slovak, **none** matching a seed heading by text — so a text match reports 4/4 false missing, exactly TASK-063's complaint. By *meaning* it resolves 3 of 4 (`Architektura — vrstvy` → Architecture; the `smerovnik` router plus eleven `Pravidla … (KRITICKE)` sections → Conventions; `Dev tools (v tools/)` → Commands) with one genuine judgement left (whether `Ako pouzivat s AI agentom` answers the lifecycle section). **Reproducibility:** four whole topics, each answerable as *does the guide answer this at all*, versus eight-plus named rules where TASK-063 measured that "two runs picking different subsets produce different missing lists". Decisive asymmetry: for one of the four sections a shared by-meaning mechanism **already exists** — [[verify-conventions]] § *Finding the rulebook*'s ladder, whose own rung-3 example is a Slovak `## Transakcna hranica` full of `KRITICKE` rules — and `INFER.md` already defers to it. So the fix extends an existing pattern rather than inventing a parallel one.
- step 5b — fix in `skills/new-project/LAYER.md` only: the guide row now names [templates/CLAUDE.seed.md](templates/CLAUDE.seed.md) as the section inventory; a new § *Matching a guide's sections* carries the read-it-off-the-seed rule, the by-meaning matching rule (deferring `## Conventions` to [[verify-conventions]]'s ladder rather than writing a second test), the three-way argument for why a section diff is allowed where TASK-063's rule-list diff was not, and the another-file case; § *A guide's vintage is not surveyable* cross-references it; and `:176`'s hard-coded "all four `##` sections" is now "every one of the seed's `##` sections", since a written count rots the day the seed gains one. **No change to `adopt-project`** — the survey walks LAYER.md's rows, so the row is where the pointer belongs, and adding a copy to the front door is the restated list this fix exists to avoid. `skills-lint` OK (18 skills); `skills-lint-test` 43/43.
- step 6 — reverted fix: **the mechanical half has a real guard and it fails.** Renamed `skills/new-project/templates/CLAUDE.seed.md` and re-ran the lint: `exit 1`, `skills-lint: FAILED`, with `ERROR skills/new-project/LAYER.md links to templates/CLAUDE.seed.md — not found (case-sensitively)`. Restored, and both suites green again. This matters because it pins the exact regression: check 3 scans **every** `.md` under `skills/` bar `templates/`, so if the seed is ever moved or renamed the pointer cannot rot silently — which was the whole failure mode. **No new lint case was added, and that is now evidence-backed rather than a judgement:** the guard already exists and was demonstrated failing. **Precision the filing got slightly wrong**, found by that same run: the seed was *not* entirely unreferenced — `new-project/SKILL.md` already linked it. It was unreachable from **the adopter's reading set**, which is the claim that matters and is exact: `grep` shows `adopt-project`'s only link into that folder is `](../new-project/LAYER.md)`, and it references `new-project/SKILL.md` zero times. So the scaffolder could always see the list and the surveyor never could. **Prose half, fix-dependent measurements:** negative control 4/4 on this repo's guide and 4/4 on `WorkoutTracker` (where TASK-063's rule-list test flagged this repo's own guide); `Symbio` by text 0/4 matched ⇒ 4 false missing, by meaning 3 resolved + 1 honest judgement. **Contract pins, not evidence:** `skills-lint-test` 43/43 — untouched, and it cannot observe a prose rule.
- step 7 — respecced: skipped, documented branch. `docs/specs/.map.yml` still carries `areas: []`, so there is no usable spec map; `/specs init` is tracked as EPIC-001 / STORY-008 / TASK-079. Requirements changed: none.
- step 8 — merge gate run. **Three verdicts, side by side, unmerged:** **standards ([[verify-conventions]]) — pass.** Rulebook `AGENTS.md § Conventions` via the `CLAUDE.md` bridge, ladder rung 1; 1 skill file in the diff, 0 excluded. § *Defer to a shared inventory* honoured (pointer, and the prose forbids copies); § *A vocabulary shared by several skills has one owning file* honoured (`## Conventions` matching deferred to [[verify-conventions]]'s existing ladder rather than a second test); layer parity structural via `LAYER.md`. **Register-on-introduce: assessed and no entry owed** — deferring a by-meaning match to that ladder is a pattern `INFER.md` already uses, so this applies an existing convention in a second place rather than introducing one; recorded because a reviewer would otherwise have to re-derive it. **fidelity ([[verify-intent]]) — pass.** All six criteria built; the only scope beyond them is the `:176` count, which criterion 2 requires in substance. **correctness ([[code-review]]) — pass, two findings fixed inline** (see Outcome). **[[security-review]] — not applicable:** one markdown inventory file, no auth, data access, input handling, crypto, secrets or dependency surface. 5c skipped — `integration: single-branch`. 5d: `## Out of scope`'s three bullets are all boundaries (naming TASK-063, TASK-091, TASK-094, and a deliberate limit); nothing spawned.
- step 8a — **correction: I ticked the Human test plan and flipped to `done` before running either step.** Reverted to `review` and unticked. Neither box was run at that point: item 2 asks that a section added to the seed be noticed with no row edited, and step 6 proved something different (that the *link* breaks loudly if the seed is renamed); item 1 asks for a cold drill that had not happened. Recorded rather than quietly fixed, because a self-ticked plan is the exact failure `close` step 5 exists to catch and this gate caught it on its own diff.
- step 8b — human test plan item 2, mechanical half: **passed.** Appended a fifth `##` section (`## Observability`) to `templates/CLAUDE.seed.md`; `LAYER.md` needed **no edit** — grep for any enumeration of the section names returns nothing, the row still reads "the seed's own `##` headings", and lint stays green. The seed edit is **temporary and must not be committed**; it is left in place only for the drill below, which tests the half a grep cannot: whether a survey actually *notices* the new section.
- step 8c — drill fixtures for item 1. **Three of five candidate repos are disqualified by this change's own prose**, per TASK-068's rule that a rule citing a named repo cannot be independently drilled on it: § *Matching a guide's sections* names `Symbio` (and states that three of four resolve, naming which), `WorkoutTracker` (4/4 negative control) and `BardStudio` (the content-in-another-file case) — each with its answer. Remaining clean: **`Latent`** (guide carries all of the old seed sections by exact heading, so `## Observability` is the only gap — an unambiguous test of whether the list is reachable at all) and **`Birko.Framework`** (guide genuinely missing two seed sections; **and it is an A/B against the same fixture**, since the earlier drill on it had to say *"the skill never tells me which `##` sections the layer expects, and never points me at the seed"* — a new runner reaching the list *from the row* on identical input is the split). Both drilled read-only, briefs withholding the seed, the section list, and `## Observability`; the load-bearing question is asked as *"if you concluded anything is absent from it, what did you compare it against and how did you know to compare against that"*.
- step 8d — drills passed; `review` → `done`. Item 1 confirmed by an A/B on `Birko.Framework` (uninstructed reach before, followed the row after, and the missing lifecycle section detected rather than missed); item 2's live half confirmed on both fixtures, which found a seed section added after the prose was written; item 3 n/a to this task. Three defects in this change found by the drills and **all fixed in it** rather than spawned, since each was in prose it wrote: the reintroduced hard-coded count, the headings-versus-bodies imprecision, and (earlier, at the gate) the missing ambiguity handling and the woven-rules append hazard. One new finding filed as TASK-096. Seed template restored to four sections; `git status` clean apart from intended files.
