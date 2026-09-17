---
id: TASK-126
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-09-16
depends-on: [TASK-109]
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Sweep every template for a shipped value its own skill says must be declared or derived

## Context

**Spawned from TASK-109 (2026-09-16), which fixed two instances and deliberately did not sweep** — its
`## Out of scope` says so outright: *"Auditing every other template for the same shape. If the rule is
worth stating, that sweep is its own task; say so rather than widening this one."* The rule turned out to
be worth stating, so the sweep is now owed.

The rule TASK-109 recorded, in `AGENTS.md` § Conventions → *Code structure & patterns*: **a template
ships nothing a render cannot make true.** A template is read as a thing to reproduce faithfully, so a
plausible value in one is minted as fact by a **correct** render rather than by a mistake — which is why
it survives review where an obvious stub would not.

Two instances were fixed there:

| Template | Was | Now |
|---|---|---|
| `skills/tasks/templates/config.yml:12` | live `integration: pr-per-task` | commented, carrying a `<pr-per-task\|single-branch>` choice |
| `skills/specs/templates/map.yml:20-22` | `coverage: verified` + `tracked-files-at-scan: 0` | `coverage: unverified`, companions commented |

### The nearest neighbour, already found — start here

**`mode: local` on line 4 of that same `skills/tasks/templates/config.yml`.** It is the same shape: a live
value for a field a run is supposed to resolve. It was **deliberately not changed** by TASK-109, and the
reason is recorded so this task does not have to re-derive it: `/tasks init` step 2 always resolves `mode`
— from a `mode=` arg, else a documented detection flow that scans signals and asks the user — and it has a
documented fallback. So unlike `integration:`, no branch leaves it unresolved, and a live default is
reachable only through a path that overwrites it.

**That reasoning is what this task must adjudicate rather than inherit.** "Always resolved in step 2" is a
claim about one verb; `skills/tasks/verbs/new.md:117` renders the same template with no such guard, which
is exactly the second render path that made `integration:` reachable. Whether that path can also ship a
defaulted `mode:` is the open question.

### Why a sweep rather than case-by-case

Every instance found so far was found by a reviewer noticing prose and template disagree — an expensive,
lucky channel. A population-wide pass is also the point at which a **mechanical** guard becomes worth its
cost: TASK-109 rejected a lint check for two lines, and said so, but the trade-off inverts over a
population. See `## Out of scope` for what that check would look like.

### Adjacent evidence from the TASK-109 cold drill (2026-09-16)

`DRILL-109`'s B2 runner rendered `templates/map.yml` into a **Python** fixture and carried all five of its
`ignore:` globs verbatim — `**/bin/**`, `**/obj/**`, `**/node_modules/**`, `**/*.test.*`, `**/*Tests*/**` —
reporting *"None of them matches anything in this repo; I kept them because step 6 says to render the
template."* Not separately filed: it is the same question this sweep asks, one step out. A shipped `ignore:`
list is not a *declaration* the way `integration:` is, so it may well be defensible — but `new-project`
promises *"stack-appropriate `ignore:` globs"* and a faithful render delivers .NET/JS ones to any stack, so
the sweep should adjudicate it rather than leave it unexamined.

## Acceptance criteria

- [x] Every file under `skills/*/templates/` and `skills-pi/*/templates/` is examined for a shipped value
      whose owning skill says the field is **declared** (a choice someone makes) or **derived** (computed
      by a run) — the inventory is the deliverable, not just the fixes
- [x] Each instance found gets a verdict — **fixed**, or **deliberately kept with the reason recorded on
      this task** — and no instance is left with neither, which is the state this sweep exists to end
- [x] `mode:` in `skills/tasks/templates/config.yml` is adjudicated explicitly, including whether
      `verbs/new.md:117`'s unguarded render can ship a defaulted value the way `integration:` could
- [x] Wherever a template is fixed, the prose that points at it is reconciled in the same change, naming
      which side was wrong — the same rule TASK-109 applied
- [x] A decision is recorded on whether the rule gets a **mechanical guard** (see `## Out of scope`), with
      the reason either way; "we did not consider it" is not an outcome
- [x] _(n/a — no guard built; decision and its measurement recorded above)_ If a guard is built, a case in `.github/workflows/skills-lint-test.sh` **fails without it** — the
      repo's standing rule for any lint change
- [x] `bash .github/workflows/skills-lint.sh` passes and the test suite stays green

## Out of scope

- **The cold drill of the two render instructions this task wrote** — spawned as **TASK-132** at the
  close gate, not dropped. The render evidence here covers the template; the prose needs a cold reader.
- **Re-opening the two instances TASK-109 fixed.** Their shape is settled; this task finds the rest.
- **Re-litigating what `coverage:` or `integration:` mean** — TASK-021, TASK-023, TASK-033 and TASK-079
  own those.
- **Templates outside `skills/`** — this repo's own `tasks/` and `docs/` artifacts are instances of
  templates, not templates themselves.
- Building the mechanical guard is **in scope to decide**, and in scope to build only if that decision
  says yes. The shape TASK-109 sketched and declined, for the record: a marker comment (`# DECLARED:` /
  `# DERIVED:`) above such a key, with the lint asserting the key under it is commented or tokenised —
  **keyed on the marker rather than a hard-coded skill list**, the same design check 4 already argues for.
  Its cost is a new repo-wide convention token, which is why two lines could not justify it.

## Sweep inventory (the deliverable)

**Population: 13 files.** `skills-pi/` has **no `templates/` folder at all**, so the acceptance's
second glob matches nothing — recorded here rather than left looking unexamined.

Every file was walked field by field, per the rule's *per field, not per file* clause.

| Template | Field | Class | Verdict |
|---|---|---|---|
| `specs/templates/map.yml` | `ignore:` (5 globs) | derived per stack | **fixed** — commented out, examples labelled by stack |
| `specs/templates/map.yml` | `areas:` (example entry) | derived by discovery | **fixed** — now `areas: []`, entry shape commented |
| `specs/templates/map.yml` | `coverage: unverified` | derived | kept — TASK-109 settled it; out of scope |
| `specs/templates/spec.md` | `shaped-by: []` | derived | kept — see below |
| `specs/templates/spec.md` | all other fields | — | clean (`{{TOKEN}}`) |
| `tasks/templates/config.yml` | `mode: local` | declared | **kept** — adjudicated below |
| `tasks/templates/config.yml` | `integration:` | declared | kept — TASK-109 settled it; out of scope |
| `tasks/templates/config.yml` | `external:` block | declared | clean — already commented |
| `tasks/templates/TASK.md` | `depends-on/blocks/findings: []`, `pr/github-issue/jira-key: null` | initial state | kept — a new task genuinely has none; a render makes it true |
| `tasks/templates/EPIC.md`, `STORY.md`, `README.md.tmpl` | all fields | — | clean (`{{TOKEN}}`) |
| `feature/templates/decisions.md` | `D1` example row | illustrative | kept — italic `_e.g. …_`, an obvious stub, and `state: proposed` is the true initial state |
| `feature/templates/idea.md`, `status.md`, `README.md.tmpl` | all fields | — | clean (`{{TOKEN}}`) |
| `new-project/templates/CLAUDE.seed.md`, `README.seed.md` | all fields | — | clean (`{{TOKEN}}`) |

### The two fixes, and why their shapes differ

Same file, same contradicting sentence — `skills/new-project/SKILL.md:97` promised a seed with
*"empty `areas:` list, stack-appropriate `ignore:` globs"* while the template shipped a populated
`areas:` and five .NET/JS globs. **The prose was right and the template was wrong**, both times.
`ignore:` was already observed reaching a Python fixture verbatim (DRILL-109 B2, with the runner
reporting it kept them *"because step 6 says to render the template"* — a correct render, which is
the shape the rule exists for). `areas:` was not named by the finding and came in with it: one
sentence, one file, one root cause.

They take **different shapes**, which is the rule's *read it off the schema, per field* clause doing
real work:

- **`areas: []`** — the schema has a "nobody established this" **value**: `specs/SKILL.md` reads an
  empty list as *absent* everywhere, so `[]` is the one state a render can make true. Commenting the
  key out would invent a fourth state nothing reads.
- **`ignore:` commented out** — the schema has no such value here, and this file's own list
  convention (`coverage-drift`: *"`[]` = looked, found none"*) makes `ignore: []` a **claim** that a
  scan happened. So absence is the honest shape. It also fails in the safe direction: with no
  `ignore:` key every path is unmapped, which over-reports rather than hiding.

Prose reconciled in the same change, naming which side was wrong: `new-project/SKILL.md:97` now says
*write* the globs rather than describing what the template carries, and `specs/verbs/init.md` step 6
gained the render-branch rule — step 3 proposes an ignore list and step 6 must write it **live**,
because a renderer facing a commented key and no instruction is the same defect arriving from the
other side.

### `mode:` in `tasks/templates/config.yml` — adjudicated, kept

The task required this be settled rather than inherited from TASK-109, whose reasoning was a claim
about **one** verb while `verbs/new.md:117` renders the same template. Checked both:

- `verbs/init.md` step 2 — `mode=` arg, else the detection flow.
- `verbs/new.md` mode-detection flow — step 2 **asks the user** via AskUserQuestion (three options,
  suggestion pre-selected); step 5 writes the config. The ask is not a guard bolted on to that flow,
  it *is* the flow.

So new.md:117 is **not** the unguarded second path `integration:` had. That is the discriminator, and
it is the opposite of `integration:`, which had no ask anywhere in new.md.

`mode:` also fails the schema test for the other shape: nothing anywhere defines an **absent**
`mode:` line, and consumers read it unconditionally (`SKILL.md:85` renders `(local)` / `(hybrid: …)`
from it). Commenting it out would mint a state no reader handles, to replace a documented, safe,
self-correcting default — `hybrid` without external config does not work, `local` does, and
`/tasks migrate` is the documented switch.

**Residual risk, named and routed:** if nobody answers the ask, a faithful render still ships `local`.
That is a defect in *the asking*, not in the template, it applies identically to a commented key
(a config with no `mode:` is worse than one with the documented default), and it is
**[[TASK-127]]**'s scope — `mode:` is literally one of the four ask-steps that task enumerates. Not
duplicated here.

### Mechanical guard — decided: no

Required to be decided either way. **No guard**, because the sweep measured the population the
inversion argument depends on and it did not invert:

- The shape can only occur in **2 of 13** templates. The other 11 are `{{TOKEN}}`-driven markdown,
  where an unrendered field is a visible gap — self-guarding, which is why `AGENTS.md` already gives
  `{{TOKEN}}` the reviewer disposition rather than a check.
- After this change those 2 files hold **5** such fields, every one now commented or absent.
- The guard TASK-109 sketched costs a new repo-wide convention token (`# DECLARED:` / `# DERIVED:`)
  plus a lint check plus test cases. TASK-109 rejected it for 2 lines; the sweep's own premise was
  that a population would invert that. The population is 2 files that change about once a year.
- The alternative — a lint keyed on a hard-coded list of declaration keys — is the design check 4
  already argues against, and would need editing every time a schema gains a field.

So the rule keeps the reviewer disposition `AGENTS.md` already gives it. Recorded so the next sweep
inherits a decision with a number behind it rather than re-deriving one.

## Human test plan

- [x] For each template the sweep changes, render it faithfully into a throwaway tree outside the repo
      with nothing overwritten, and confirm no field arrives carrying a value nobody chose or computed —
      the same before/after render TASK-109 used as its evidence
- [x] Confirm each rendered file still parses (YAML templates especially — commenting a key must not
      leave a document that fails to load)

## Implementation plan

_Populated by `/tasks plan TASK-126` — leave empty until then._

## Outcome

**What the fix was.** Two templates were shipping values that nobody in the consuming project had
chosen or computed, and a *correct*, faithful render turned them into fact in that project's repo.
`skills/specs/templates/map.yml` now ships `areas: []` and its `ignore:` key commented out, so a
render mints nothing; before the change a faithful render produced six such values, after it, none.

**The step-6 split.** There is no fix-dependent automated test, because this task also decided *not*
to build a mechanical guard, and the split says so rather than implying otherwise. Reverting all
three changed files and re-running the gate gave **47/47 passing and exit 0 — identical to the fixed
tree**, so every lint case here is a **contract pin, not evidence**. The evidence is the faithful
render, run into throwaway trees both ways: 6 minted values before, 0 after, both parsing as YAML.

**Judgement calls, and why the stricter option was rejected each time.**

- **`ignore:` commented rather than `ignore: []`.** Stricter would have been an explicit empty list.
  Rejected because this same file establishes `[]` as *"looked, found none"* — an empty list would be
  a **claim that a scan ran**, re-creating the defect in a new place. Absence also fails loud: with
  no ignore globs every path reports unmapped, so the error direction is over-reporting, not hiding.
- **`areas: []` rather than commenting it out.** The stricter, more uniform choice would have been to
  comment both keys the same way. Rejected because the schema already defines an empty `areas:` as
  *absent*, and commenting it out would invent a fourth state no reader handles. The two fields
  differ deliberately — that is the rule's *per field, not per file* clause, not an inconsistency.
- **`mode: local` kept.** The stricter option — comment it out like `integration:` — was rejected on
  evidence, not inheritance: **both** render paths resolve it (`init.md` step 2 by arg or detection;
  `new.md`'s flow *is* an ask), so `new.md:117` is not the unguarded second path `integration:` had.
  And nothing defines an absent `mode:`, while consumers read it unconditionally — commenting it out
  would replace a safe documented default with a state nobody handles.
- **No mechanical guard.** The stricter option was a `# DECLARED:` / `# DERIVED:` marker convention
  plus a lint check. Rejected on the sweep's own premise: it argued the trade-off inverts *over a
  population*, and the measured population is **2 of 13** templates holding **5** such fields, the
  other 11 being self-guarding `{{TOKEN}}` markdown. A new repo-wide convention token for two files
  that change about once a year does not pay, and the keyed-on-a-hard-coded-list alternative is the
  design check 4 already argues against.

**Flagged, not fixed.**

- **No spec regen was run, and the reason is not "no map".** The map exists and is populated, but
  `docs/specs/` holds **`.map.yml` and nothing else** — no area has ever been harvested, so there is
  no spec stating the old behaviour and no diff to review as evidence. Two areas cover the changed
  files (`specs-from-code`, `project-baseline`; the template itself is under the map's own
  `**/templates/**` ignore). Running a first harvest of two areas here would be a large token spend
  producing a whole-area spec, not the intended-change check. **Already filed as TASK-080**
  (*"`/specs regen` — generate the specs, and review the diff as the deliverable"*, `todo`), so this
  is routed, not dropped.
- `mode:`'s residual — what a render writes when nobody answers the ask — is **[[TASK-127]]**'s, which
  enumerates `mode:` as one of its four ask-steps. Not duplicated here.

## Close gate — three verdicts, side by side, unmerged

Per `AGENTS.md` — *independent review axes are reported side by side and never merged or reranked*.
[[security-review]] **not applicable**: the diff is markdown and YAML skill definitions — no auth, data
access, user input, path handling, crypto, secrets, dependency or endpoint. Said in a line rather than
by silence, since a skipped pass and a clean one look identical otherwise.

**Standards ([[verify-conventions]]) — pass with 2 findings.**
Rulebook: `AGENTS.md` § Conventions via the `CLAUDE.md` @import bridge — ladder rung 1. Subsections read:
Framework/stack, Output/prose rules, Code structure & patterns, Naming, Testing, Keeping conventions
current, Working rules; also § Architecture. Project extension: **none found** (no `.claude/skills/`).
Linted 4 of 4 changed files; none excluded.

- ⚠ **§ Working rules — *"Plan before implementing. A non-trivial task gets its `## Implementation
  plan` before work starts."*** This task's plan section is still the template line, and the work ran
  without one. Recorded rather than back-filled: writing a plan now and presenting it as prior would make
  the record say something untrue, which is worse than the gap. Mitigating but not excusing — this task's
  acceptance criteria *are* a procedure (sweep → verdict per instance → adjudicate → decide the guard), so
  the target the plan rule protects was never absent. [[fix-next]] has no plan step between its pick and
  its fix; whether it should is a gap in that skill, not a judgement made here.
- 💡 **§ Testing — the drill.** The `## Human test plan` is a mechanical render check, correct for the
  template and clean, but the change also rewrote **prose two verbs render from**, whose failure mode is
  a correct reader following it. Spawned as **TASK-132**.
- **Register-on-introduce: nothing to register.** The change *applies* § Code structure & patterns'
  existing *"a template ships nothing a render cannot make true"*; it introduces no new pattern, and
  § Architecture is untouched.
- **Layer parity: satisfied, and checked rather than assumed.** `LAYER.md:27` gives `docs/specs/.map.yml`
  the owner `[[specs]]` and has **both** front doors delegate to `/specs init` — which this change
  updated — so [[adopt-project]] inherits it with no edit. `new-project/SKILL.md:97` needed its own line
  only because it is the one path that renders the template directly. **`LAYER.md:27` already said
  *"Seed `areas: []`"***, so the inventory and the template had been contradicting each other, and this
  change removes the contradiction rather than creating one.

**Fidelity ([[verify-intent]]) — pass.** Ran inline against the acceptance criteria, judging each against
the diff rather than its checkbox. All seven met; criterion 6 is conditional on a guard the task decided
against and is marked n/a with the decision beside it, not ticked as though built. **Nothing built that
was not asked for**: the one addition beyond the template itself — `specs/verbs/init.md` step 6 — is
criterion 4 (*"the prose that points at it is reconciled in the same change"*) and is the render branch
of the very file being fixed. **Nothing implemented-but-wrong**: criterion 1's second glob
(`skills-pi/*/templates/`) matches nothing, and the inventory says so instead of reporting it examined.

**Correctness ([[code-review]]) — pass.** Every reference to the template traced: `specs/SKILL.md:45`
(*"the template itself makes no determination"* — still true, and more so), `specs/verbs/init.md:55` and
`:59` (both about an *existing* map, unaffected), `new-project/SKILL.md:97` (updated). No script parses
the template. The rendered file parses as YAML, and the one behavioural consequence — a map with no
`ignore:` key — fails in the safe direction, reporting every path unmapped rather than silently
exempting some. `areas: []` is the state `specs/SKILL.md` already reads as *absent*, so no consumer
meets a new state.

**Out-of-scope sweep (step 5d) — four bullets, all boundaries; two flags, both owned.** The `## Out of
scope` bullets each name an owner (TASK-109; TASK-021/023/033/079) or state a deliberate limit, and the
guard bullet is now a recorded decision with its measurement. The two items under *Flagged, not fixed*
name existing ids (TASK-080, TASK-127). One new id created: **TASK-132**.

## Progress log

- step 2 — picked; ranked above TASK-131 because a template's wrong value is minted into a *consumer's* repo by a correct render (confirmed live in DRILL-109's Python fixture), reachable on the most ordinary path there is, where TASK-131 leaves one task unranked in this tree and carries an unresolved mint-ids-vs-stamp fork
- step 3 — verified: held. 13 template files swept (`skills-pi/` has **no** `templates/` folder at all — the acceptance's second glob matches nothing, recorded rather than left looking unexamined). Two live instances confirmed in `skills/specs/templates/map.yml`, both contradicted by one sentence — `skills/new-project/SKILL.md:97` promises a seed with *"empty `areas:` list, stack-appropriate `ignore:` globs"* while the template ships a populated `areas:` and five .NET/JS `ignore:` globs. `ignore:` was already observed reaching a Python fixture verbatim (DRILL-109 B2). `areas:` was **not** named by the finding and is pulled in per *findings travel in packs*: same file, same promising sentence, same root cause.
- step 4 — layer: local (this repo owns every template swept)
- step 5 — fix in `skills/specs/templates/map.yml` (areas + ignore), prose reconciled in `skills/new-project/SKILL.md:97` and `skills/specs/verbs/init.md` step 6; no automated guard added (decided: no, reasons on this task). `skills-lint.sh` OK (18 skills), `skills-lint-test.sh` 47/47.
- step 6 — **no fix-dependent automated test exists, by decision, and the account says so rather than dressing the suite up as proof.** Reverted all three skill files to HEAD and re-ran the lint: **0 of its checks failed — 47/47 and exit 0 on the reverted tree, identical to the fixed one.** That is the guard decision measured, not a gap: every lint case here is a **contract pin**, none is evidence for this change. Fix-dependent evidence is the faithful render (human-test item 1), run both ways into throwaway trees outside the repo: **before — 6 values minted by a correct render** (`areas`: 1 entry nobody discovered; `ignore`: 5 stack globs nobody chose); **after — 0**, with both renders parsing as YAML (human-test item 2). The render is the only thing that separates the two trees, which is exactly the claim.
- step 7 — no regen: map is populated but `docs/specs/` holds only `.map.yml` — zero areas ever harvested, so no spec asserts the old behaviour and there is no diff to review. Covering areas would be `specs-from-code` + `project-baseline` (the template is under the map's own `**/templates/**` ignore). Routed to the already-filed TASK-080, not spawned again.
- step 8 — close: gate ran (standards pass w/ 2 findings, fidelity pass, correctness pass, security n/a); 5d spawned TASK-132; `integration: single-branch` so 5c/8 skip
- step 8 — closed done; 56b7fe5 (single-branch: committed to main = merged). Dashboard regenerated; EPIC-002 stays in-progress (43/74).
