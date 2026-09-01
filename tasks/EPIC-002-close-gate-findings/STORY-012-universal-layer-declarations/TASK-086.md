---
id: TASK-086
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-08-31
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-027-2, DRILL-097-1]
pr: null
github-issue: null
jira-key: null
---

# Adoption cannot tell its own unlanded writes from the user's work in progress

## Context

**Spawned from TASK-027's close gate on 2026-08-31** (`/code-review`).

`present, uncommitted` exists to catch **one** situation: *an earlier adoption pass wrote layer files and
stopped before committing.* The whole justification — *"the next clone will not have it and the next pass
will write over it"* — is about files **adoption itself wrote**. The offer that follows is to land the file
**in the adoption commit**.

The probe cannot see intent. It reports that git does not have all of a path, and every reason for that
looks identical:

| Why the path is unlanded | What the run should do |
|---|---|
| an earlier adoption pass wrote it and stopped | land it — the state's whole purpose |
| the **user** has work in progress under a layer path — a half-written `README.md`, edits staged in `docs/` | **not** adoption's business |

In the second case adoption offers to sweep the user's half-finished work into a commit whose message says
*adoption*, having neither written nor reviewed it.

**Not introduced by TASK-027, and the honest framing matters.** The old rule already matched ` M` — a
tracked file modified and unstaged — which is the single most likely shape of a developer's WIP. TASK-027
widened the aperture to staged work as well, so the exposure grew; it did not appear. Filing it against the
widening alone would misdate the defect and imply the previous rule was safe.

**Why it was not simply narrowed at the point of discovery.** Every candidate is a real design decision
with consequences beyond this row: comparing content against what the fill *would* write (which needs the
fill to have run); restricting the state to artifacts the run itself created (which defeats the re-run case
the state exists for, since a *previous* run wrote them); showing the paths and asking; or accepting the
conflation and making the offer per-path rather than wholesale. Picking one inside a close gate, unattended,
is exactly the "decision nobody sanctioned" that the guardrails forbid.

**The sharpest sub-case to keep in view:** a *directory* artifact like `tasks/`, where the probe returns
members. One member from an old adoption pass and one from the user's WIP produce a single row and a single
offer.

### Independent second instance, 2026-09-01 (DRILL-097-1)

A cold drill of `WorkoutTracker` reached this exact conflation from the other direction, with no knowledge of
this task, and articulated the defect more sharply than the filing did:

> *"The probe rule is mechanical and I applied it mechanically. But the seven modified files here are **not**
> an unlanded adoption pass — they are current work (two generated files `/feature status` owns, three
> generated spec bodies, one in-flight task file). **"The file is already right" is an assumption that does
> not hold for someone's WIP**, and *"offer it in the adoption commit"* would sweep unrelated work into an
> adoption commit. Nothing in the instructions distinguishes the two provenances, so I assigned the state and
> am flagging that the remedy attached to it looks wrong for this instance."*

**What this adds to the filing.** The original was written around the *offer* being wrong. This runner
locates it one step earlier: the state's **justification** — *"the file is already right; what is missing is
the commit"* — is itself false for WIP, so the remedy is wrong because the premise is. That reframes the fix:
narrowing the offer is not enough if the state's own rationale still asserts something untrue about half the
cases it catches.

**It also raises the count of measured instances to two, on different repos, from independent runners** — and
this one is seven files at once, including three files a *different* verb owns (`/specs regen` bodies) plus a
task file mid-edit. A wholesale land offer here would commit another verb's in-flight regeneration.

**Not resolved by TASK-091's location work or TASK-097's `unknown` split** — both were checked. This is
provenance, not location, and not a state-versus-finding question: the state is correct and its attached
remedy is not.

## Acceptance criteria

- [x] Adoption does not offer to commit user work it neither wrote nor reviewed — by narrowing the state, by making the offer per-path with the paths shown, or by a **recorded decision** that the conflation is acceptable and why
- [x] The re-run case still works: a *previous* adoption pass's unlanded files are still caught, since that is the state's entire purpose
- [x] The directory-artifact sub-case is covered explicitly — mixed provenance among members cannot collapse into one silent offer
- [x] Whatever is chosen, `LAYER.md` states which situation the state claims to identify, so the next reader is not left inferring it from the rationale
- [x] Layer parity: both front doors read the outcome from `LAYER.md`
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The porcelain reading rule itself — **TASK-027** settled that, including the deletion, unmerged and ancestor-repo exclusions.
- Landing versus regenerating precedence — **TASK-066**.
- Whether adoption should commit at all. It should; this is about *what* it sweeps in.

## Human test plan

- [x] In a repo with a layer already present, make an unrelated edit under a layer path (staged, and again unstaged), run the survey, and confirm the run does not offer to commit it without saying what it is
- [x] With genuinely unlanded layer files from a previous pass, confirm the land offer still fires
- [x] With a `tasks/` directory holding one unlanded layer file and one user-edited file, confirm the two are distinguishable in the report

## Implementation plan

_Populated by `/tasks plan TASK-086` — leave empty until then._

## Outcome

**What the fix was.** `present, uncommitted` answers one question — *is all of this in history?* — and every
reason for *no* looks identical to it: an earlier pass's leftovers, the user's work in progress, and a third
case nobody had named until DRILL-097-1 measured it, **another verb mid-regeneration**. The state's remedy
nonetheless asserted *"The file is already right; what is missing is the commit"* and offered to land
everything wholesale. The state is kept and its **claim** is dropped: `LAYER.md` gains
§ *`present, uncommitted` says nothing about whose work it is*, and the offer becomes **one itemised offer, a
subset acceptable**, with a directory row listing its members.

**Why the design question dissolved instead of being decided.** This task lost to five others this session on
key 4, because its own Context lists four live candidates and says choosing one unattended is *"the 'decision
nobody sanctioned' that the guardrails forbid"*. DRILL-097-1 relocated the defect from the **offer** to the
**premise**, and two candidates fell out on reasoning: *restrict the state to what this run created* destroys
the state's purpose, since the whole case is a **previous** run's leftovers; *diff each file against what the
fill would write* needs the fill to have already run, so it cannot inform the decision that precedes it. What
was left was not a choice between four designs but a false sentence to delete.

**All three plan items passed, on one fixture.** The runner produced the offer verbatim, and it is the
evidence:

- **Item 1** — WIP staged *and* unstaged, neither offered blind. On the unstaged README: *"This looks like
  your work in progress. My recommendation: do not land it, and I am not going to finish or delete the
  sentence."* On the staged file: *"Staged, so someone was mid-commit. Recommendation: yours to land, not
  mine."* The offer opens *"I cannot tell whose work any of these is… A yes here is your judgement, not my
  confirmation."*
- **Item 2** — the land offer still fires. Both self-attributed paths listed, with *"My recommendation: land
  1 and 2 only."*
- **Item 3** — the mixed `tasks/` directory is distinguishable, in the table **and** in the offer, as items
  with opposite recommendations. The runner rated this the most consequential thing the instructions settled
  for it: *"`tasks/` holds one adoption leftover and one file the user is editing; a wholesale yes commits
  both."*

**Judgement calls, and the stricter option rejected.**

- **Keep the state, drop the claim.** Rejected narrowing the state itself — the two rejected candidates above
  are both forms of that, and each breaks the case the state exists for.
- **One itemised offer, not one question per path.** Caught in my own wording before the gate: "offer per
  path" reads as N questions, which is the interrogation the one-frontier-round rule exists to prevent.
  Per-path *granularity*, not per-path *questions*.
- **Self-attribution is evidence, never a licence.** Two paths said adopt-project wrote them and the runner
  still asked, which is the intended behaviour: the same file may have been hand-edited since, and nothing in
  the probe would show it.

**Two of the runner's findings were checked and neither survived — a correct "no" twice over.**

- **The `PathValidator` traversal suspicion is not a defect.** It flagged that `BatchProcessor` builds every
  output path with `CombineAndValidateUnchecked` while the README claims traversal-safe construction, and
  refused to file it blind because the framework tree was absent from the clone. Verified against the real
  source: the method sanitizes, combines, normalizes and **throws on traversal** via boundary-aware
  containment; `Unchecked` means *without requiring the base directory to exist*, as its own doc comment
  says. The usage is correct and the README's claim is accurate. Refusing to file it blind was right.
- **The TASK-021 "describes a state that does not exist" finding is an artefact of my fixture.** The real
  `Latent` has `.claude/` with both files and the secrets block at `.gitignore:27-29`, uncommitted. A `git
  clone` takes history only, so both vanished. **That is a gap in guidance I wrote this morning**, and it is
  now fixed in [[populate-tests]] § *The cold drill*: a clone drops every uncommitted and untracked file,
  which is exactly what some drills are about, so a brief whose subject is uncommitted state must say the
  checkout is a clone and that other absences are an artefact rather than evidence. The runner had flagged
  its own reasoning as an inference, which is what stopped it becoming a false filing.

**Flagged, not fixed.**

- **TASK-100** — step 3c derives its regeneration set from what a run *created*, and **landing is the one act
  that invalidates a generated file without creating its input**. Taking the landing offer leaves
  `tasks/README.md` a row short, and 3c's set is empty by its own derivation rule. The runner found the hole
  and correctly did neither thing available to it.
- **TASK-098 widened to a pattern and raised P3 → P2**, with three further instances: a row prescribes an
  action and never says what to do when the repo already satisfies it (`docs/BRIEF.md` twice, the `README.md`
  pointer offer), plus its mirror — the `LICENSE` row enumerates evidence for the *open* posture and names
  the proprietary side without saying what evidences it. Four independent runners each made the same
  judgement, which makes it a rule rather than a rough edge.

## Progress log

- step 2 — picked, after losing to five other tasks this session and for a reason that has now changed. It kept losing **key 4**: four live design candidates, and its own Context says choosing one unattended is *"the 'decision nobody sanctioned' that the guardrails forbid"*. **DRILL-097-1 dissolved most of that** by relocating the defect — the problem is not that the *offer* is too wide, it is that the state's **justification** (*"the file is already right; what is missing is the commit"*) is **false** for work in progress, so the remedy is wrong because the premise is. That reframing rules out two of the four candidates on its own. It is also the only remaining defect in the pool whose failure mode is a **write** — every other one produces a wrong report — and it is now twice-measured on two repos by independent runners, the second instance being seven files at once including three a *different* verb owns mid-regeneration. Key 6 inert.
- step 3 — verified: held, and the false claim sits in **two** places, not one. `LAYER.md:420`'s state *definition* is already provenance-free and correct — *"found on disk, but git does not have all of it"* — but the same bullet then says the state *"is normally an earlier adoption pass"* and attaches an unconditional *"offer to land it"*, and `adopt-project` step 3 asserts it flatly: **"The file is already right; what is missing is the commit."** That sentence is the defect. It is true for a leftover pass, false for a user's WIP, and false again for another verb's half-finished regeneration — which is the third case neither the filing nor the first drill had named, and which DRILL-097-1 measured (three `/specs regen` bodies and a `/feature status` output modified at once).
- step 4 — layer: local.
- step 5a — **the design choice, and two of the four candidates are ruled out by DRILL-097-1's reframing rather than by preference.** Rejected *restrict the state to artifacts this run created*: it reads as the clean fix and destroys the state's purpose, since the whole case is a **previous** run's leftovers. Rejected *diff each file against what the fill would write*: it needs the fill to have already run, so it cannot inform the decision that precedes it. What remains is the state's **claim**, not its scope — so the state is kept, the claim is dropped, and the offer follows the probe's granularity instead of the row's.
- step 5 — fix in `skills/new-project/LAYER.md` (the "normally" clause now points at a new § *`present, uncommitted` says nothing about whose work it is*, carrying the three-way table, the dropped claim, the three consequences, the self-attribution-is-evidence rule and both rejected candidates) and `skills/adopt-project/SKILL.md` in two places — step 3's *landed, not rewritten* bullet, whose false premise is removed and replaced by the itemised offer, and step 4's report bucket, which now owes **each path** rather than one line for the row.
- step 5b — **fixed an ambiguity in my own new wording before the gate.** "Offer per path" reads as N questions, which is precisely the interrogation the one-frontier-round rule exists to prevent. Now stated as **one itemised offer, a subset acceptable** — per-path *granularity* without per-path *questions*. Worth noting the offer lives in step 3, not step 2's round, so it never competed with that rule; the risk was the shape, not the placement.
- step 6 — reverted fix: prose, so the drill is the guard. Textual split: the sentence *"The file is already right; what is missing is the commit"* is gone from `adopt-project` step 3 and its unconditional wholesale offer with it; `LAYER.md`'s *"normally an earlier adoption pass"* now points at a section that states the state claims **nothing** about provenance. **Fixture built deliberately, and my own § *The cold drill* licenses exactly this shape:** all three plan items require *constructing* git states, so the drill runs on a **clone of a real consumer repo** — real history, eleven commits, its own layer — with only the git state supplied as the drill's **input**. Per that section, *"a clone with real history is still a real target; the git state the drill sets up is its input, not a fabricated repo"*, and the alternative would have meant dirtying somebody's working tree, which the same section forbids.
- step 6a — the fixture covers all three plan items in one target: ` M README.md` (user WIP, **unstaged**) and `M  docs/architecture.md` (user WIP, **staged**) for item 1's two halves; `?? docs/specs/.map.yml` carrying a self-attributed header — *"Proposed by adopt-project 2026-08-18; never committed"* — for item 2; and `tasks/_loose/` holding **mixed provenance** for item 3, one untracked file seeded by an adoption pass beside one tracked file the user has edited. Brief withholds provenance, "whose work", the per-path shape and the fact that the offer's wording is what is under test — it asks only for the survey plus *"every offer or question you would put to the user, verbatim and in full"*, which is the instructions' own output rather than a question about it.
- step 6b — suites confirmed **after** the step-5b interrogation fix, not before it: `skills-lint` OK (18 skills), `skills-lint-test` **43 passed, 0 failed**. Both are **contract pins, not evidence** — neither can observe an offer's wording. Criteria 1-5 are built; criterion 6 is met. The task stays `in-progress` until the drill returns rather than flipping on a claim whose evidence has not arrived.
- step 7 — respecced: skipped, documented branch. `docs/specs/.map.yml` carries `areas: []`; `/specs init` is TASK-079. Requirements changed: none.
- step 8 — three-axis gate. **standards — pass.** Rulebook `AGENTS.md § Conventions`, rung 1; three skill files, 0 excluded. The rule is stated once in `LAYER.md` and read from `adopt-project` in two places, both pointers; no list is restated. Layer parity structural via `LAYER.md`. **Register-on-introduce: no entry owed, checked** — *a state must not claim what its probe cannot see* is § *Read the declaration, never infer it* applied to a probe rather than a field, an existing convention in a second place. **fidelity — pass**, all six criteria built. **correctness — one finding, fixed inline:** the per-path-reads-as-N-questions ambiguity. **security-review — not applicable** to the diff (three markdown files); separately, the one security-shaped finding the drill raised was verified against real source and is not a defect. 5c skipped — `single-branch`. 5d: `## Out of scope` bullets are boundaries naming TASK-027 and TASK-066; nothing spawned.
- step 8a — drill passed all three plan items; `in-progress` → `done`. Fixture cleaned up. One finding filed (TASK-100), one existing task widened and re-prioritised (TASK-098), two runner findings verified and correctly rejected, and one gap in this morning's own drill-method guidance found by my own fixture and fixed.
