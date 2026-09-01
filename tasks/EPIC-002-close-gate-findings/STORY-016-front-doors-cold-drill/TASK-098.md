---
id: TASK-098
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-096-3, DRILL-086-1, DRILL-086-2, DRILL-086-3]
pr: null
github-issue: null
jira-key: null
---

# A row prescribes an action and is silent on the case where it is already done

## Context

**From the 2026-09-01 cold drills of `adopt-project` — filed from the `Latent` run, widened by `Symbio` and `drill-086`.**

`LAYER.md` § *The adopted-repo brief* prescribes a stamp for a repo joining the layer: an `## Origin`
section recording the adoption date and that no original brief exists, plus an empty `## Amendments` log.
It is written entirely for the case where **nothing survives** — which is the common case and the reason
the section exists.

`Latent`'s `docs/BRIEF.md` has neither section. It has something better: a genuine dated
`## Opening ask (2026-07-14)` quoted verbatim, plus a scope confirmation. The runner:

> *"`docs/BRIEF.md` has neither, but it **does** have a genuine dated verbatim opening ask — which is
> exactly the thing the stamp substitutes for when it is absent. I chose `present` with nothing owed,
> reasoning that the stamp exists for repos with no surviving original ask. **The text does not say this;
> it describes the stamp without saying what to do when the real thing is there.**"*

Its reading is right, and the cost of the gap is small — the row lands `present` either way, so nothing is
mis-surveyed. What it costs is a judgement a runner should not have to make, and the risk is the wrong
direction: a runner who reads the stamp as *the* required shape reports a brief with a real verbatim ask as
thin, or worse offers to append an `## Origin` section saying no original exists **beside** the original.

### Why it stayed small, and why it is no longer P3

Raised P3 → P2 when the instance count reached four across three repos: no single instance is worse than it was, but a judgement four independent runners each had to make is a rule, not a rough edge. No state is wrong, no artifact is at risk, and the fix is still small. The temptation to over-answer is the
real hazard: this must not turn into a prescribed schema for `docs/BRIEF.md`, because the brief is
append-only ground truth whose whole point is that it carries whatever the user actually said. The
`## Amendments` half may genuinely be owed in both cases — an adopted repo with a real opening ask still
needs somewhere for later requirement changes to land — and that is the one part worth thinking about
rather than asserting.

**A second observation from the same drill was considered and deliberately not filed.** The seed's guide
carries an opening bullet list (`**Stack:**`, `**Kind:**`, `**Specs:**`, `**Changelog:**`, …) and `Latent`'s
guide omits two of them while both artifacts exist. The runner noticed that, unlike the rule-list diff
§ *A guide's vintage is not surveyable* rejected, *"this omission **is** reproducible and mechanical"* — and
still declined to call it a gap, because § *Matching a guide's sections* scopes the inventory to `##`
headings. That is the right call and the reason not to file it: widening the inventory to header bullets
reopens exactly the question TASK-063 measured and settled, and it would fail the same negative control
(this repo's own guide omits seed bullets too). Recorded so the next reader finds a decision instead of
rediscovering the idea.

### Widened 2026-09-01: this is a pattern, not one row

Filed from one instance. The `Symbio` and `drill-086` runs turned up three more of the same shape — **a row
tells you to do something and never says what to do when the repo has already done it, or has done it
differently** — so the fix is one rule rather than four row edits.

| Instance | The row says | What the runner met | What it chose |
|---|---|---|---|
| `docs/BRIEF.md` (DRILL-096-3) | stamp `## Origin` + an empty `## Amendments` | a genuine dated verbatim opening ask, and neither heading | `present`, nothing owed — *"the text does not say this"* |
| `docs/BRIEF.md` again (DRILL-086-1) | same | same shape, different repo — *"no `## Amendments` heading exists yet"* | `present`, absence noted as an aside; declined to append a heading to ground truth |
| `README.md` (DRILL-086-2) | *"Offer to append a short 'How we work' pointer at the end"* — unconditional | the README **already** links `tasks/README.md` and `docs/features/README.md` | suppressed the offer: *"Nothing in the row says the offer is suppressible"* |
| `LICENSE` (DRILL-086-3) | evidence for the posture is *a licence line in the README, a `license:` field, an SPDX header* | a bare `<Copyright>` with no grant — which the row's evidence list does not cover | evidence-`unknown`; the row **enumerates evidence for the open side and names the proprietary side without saying what evidences it** |

**The first three are one question: is a prescribed action suppressible when already satisfied?** Every runner
answered yes and every one flagged that the row does not say so. **The fourth is its mirror** — an evidence
list that is one-sided, so the *absent* posture has no stated signal at all.

**Two things not to do.** Do not answer it per row: four rows today and the inventory grows. And do not
resolve it toward *always offer* — a second "How we work" pointer beside an existing one is the
false-`missing` fill this file calls the dangerous direction, and appending an `## Amendments` heading to a
brief someone wrote is editing ground truth.

## Acceptance criteria

- [x] § *The adopted-repo brief* says what to do when the repo already carries a genuine verbatim ask — one sentence, not a schema
- [x] The general case is stated once — **a prescribed action is suppressed when the repo already satisfies it**, with the report saying so — rather than four rows each gaining a clause
- [x] The `LICENSE` row's evidence list covers the **proprietary** side too, or says plainly that no signal evidences it and the row therefore lands `unknown`
- [x] Whether `## Amendments` is owed in that case is decided explicitly rather than left to follow from the stamp's absence
- [x] Nothing in the change prescribes the *content* of `docs/BRIEF.md` beyond what the append-only rule already requires
- [x] The never-reconstruct rule is untouched and still unambiguous
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The seed guide's header bullet list — considered and declined above, with reasons.
- Anything about `## Amendments` content or how later requests are appended. [[new-project]] owns the append-only rule and it is not in question.
- Reconstructing a brief from a README. Forbidden, and this task does not soften it.

## Human test plan

- [x] Cold-drill a repo whose `docs/BRIEF.md` carries a real verbatim ask, expected answers withheld, and confirm the runner reports the row without listing it as something it had to decide

## Implementation plan

_Populated by `/tasks plan TASK-098` — leave empty until then._

## Outcome

**What the fix was.** Four runners across three repos each met a row telling them to *offer X* / *stamp Y*
on a repo that already carried what the action would produce, each suppressed it correctly, and each said
the text did not license them to. The parent principle was already in the file one step short —
*"Never move a repo's files into the canonical layout… A repo that solved it differently has solved it"*
covers a repo that solved something **differently** and is silent on one that solved it **already**. The
general rule now sits beside it, and the two rows that needed their own answer got one.

**The rule carries its own limit, because three of the four instances were cases where suppression was
right** — which makes this the easiest kind of rule to over-answer into a licence to skip work. *Already
satisfied* means the artifact carries what the action would have produced, not that something nearby is
close enough; **where you cannot tell, the action fires**, because an unnecessary offer costs one *no* and a
suppressed necessary one costs the artifact.

**Two decisions rather than consequences.** `## Amendments` is owed **either way** — the stamp's halves
answer different questions, and `## Origin` explaining *why there is no original* is moot where one
survived, while the append-only log is where the next request lands regardless. And the `LICENSE` row's
evidence list is now two-sided, with **a bare copyright notice explicitly not evidence of anything**,
because templates emit `<Copyright>` unconditionally.

**The drill passed, and the new declined-actions section is what makes it legible.** All three suppressions
appear under *actions a row told me to take that I did not take*, each with its reason quoted from the new
rule, and **none** appears under *had to decide* — all three moved to *questions the instructions settled
for me*. On the licence half the runner was explicit that the fix changed the outcome: *"this alone stopped
me landing `not applicable` on `LICENSE`."*

**Contamination, and why it did not undermine this one.** Three of the four instances are the drilled
repo's, and my prose describes their shapes without naming it. Elsewhere in this session that would be
disqualifying — a runner recognising a fingerprint and inferring an answer it had not earned. Here the
rule's *purpose* is to pre-decide these cases, so applying them **is** the pass condition; what would be
illegitimate is claiming the runner discovered them independently, which the plan never asks. The plan asks
whether they appear in the had-to-decide list, and the brief measured that by asking for declined actions as
a section of its own — so a silent suppression would have been as visible as a reasoned one.

**One conflict of my own, fixed after the drill found it.** My new text said the `## Amendments` offer goes
*"as an offer, in the report"*, which contradicts step 2's one-frontier-round rule. The runner put it in the
round and said the text left it undecided. It was right; the wording now says **an item in step 2's one
frontier round**, never queued separately.

**Flagged, not fixed.**

- **TASK-101** — *"a working runner"* names no bar, so the harness row and § *CI a repo cannot pass* read one
  fact in opposite directions: the same `$(BirkoSrc)` imports mean *cannot build on a runner* to one row and
  *already adopted, move on* to the other. It also marks a **limit in TASK-097's work**, which the runner
  identified exactly: that task routed an unsettled **artifact state** upstream, and a row's *terminating
  predicate* is unsettled in the same way with no channel at all, because the artifact is not in doubt.
- **TASK-102** — nothing says whether a step-3 fill offer joins step 2's round or comes after it. The runner
  hit it twice and folded both in, reasoning from the interrogation clause rather than from anything that
  addresses the case. It interacts with TASK-035's rule that a declaration is passed *from* step 2 precisely
  so it does not surface inside step 3 — the same argument, never generalised to fill offers.

## Progress log

- step 2 — picked. Four findings from four independent runners across three repos, each of whom made the **same** unstated judgement — which is the definition of a rule that is missing rather than a rough edge, and why this was raised P3 → P2. Beat TASK-099 and TASK-100 on key 5 (they have two and one instance); beat TASK-100 on key 3 as well, since 100's failure leaves a dashboard one row short — visible — where this one has runners silently suppressing a prescribed action with nothing recording that they did. Key 6 inert. **The trap here is over-answering**: three of the four instances are cases where the runner was right to suppress, so the fix must license the suppression without prescribing a schema for anyone's ground truth.
- step 3 — verified: all four held, and the parent principle was already in the file one step short. `LAYER.md:592` says *"Never move a repo's files into the canonical layout… A repo that solved it differently has **solved it**"* — which covers a repo that solved something **differently** and says nothing about one that solved it **already**. The BRIEF section opens *"an existing repo **usually** has no surviving original ask"* and then gives the stamp with no branch for the exception its own "usually" admits. The `README.md` row's offer is unconditional. The `LICENSE` row's three evidence forms are **all open-posture signals**, and it names the proprietary outcome without naming anything that evidences it.
- step 4 — layer: local.
- step 5 — fix in `skills/new-project/LAYER.md` — the general rule stated once beside its parent (*"the sentence above covers a repo that solved something differently; this covers one that solved it already"*), with the four measurements, why suppression is the default rather than laziness, and **the limit**: *already satisfied* means the artifact carries what the action would have produced, and where you cannot tell the action fires, because an unnecessary offer costs one *no* and a suppressed necessary one costs the artifact. Then the two rows that need their own answer: § *The adopted-repo brief* gains the surviving-ask branch, and the `LICENSE` row's evidence list is made two-sided with *a bare copyright notice is not evidence of anything* and the reason (templates emit it unconditionally). `skills/adopt-project/SKILL.md` step 3 gains a pointer, not a copy.
- step 5a — **`## Amendments` decided rather than left to follow.** The stamp's two halves answer different questions: `## Origin` explains *why there is no original*, which a surviving ask makes moot; `## Amendments` is where the **next** requirement-changing request lands, which every adopted repo eventually has. So it is owed either way — offered, in the report, never appended unasked. Criterion 4 asked for this to be explicit and the honest answer was not the symmetrical one.
- step 5b — checked rather than assumed: three of my new sections are **bold paragraphs** cited with `§`, not `##` headings. That is this file's existing convention — `§ *Presence and shape, not content currency*` predates today and is itself a bold paragraph — so no inconsistency was introduced.
- step 6 — reverted fix: prose, so the drill is the guard. Textual split: `LAYER.md` had **one** sentence for a repo that solved something *differently* and none for one that solved it *already*; the BRIEF section had no branch for the exception its own word "usually" admits; the `LICENSE` evidence list was three open-posture signals with nothing for the other side. **Fixture: `Latent`, and it is the only one available — which is fine here for a reason worth stating.** Three of the four instances are its: a real verbatim ask in `docs/BRIEF.md`, a `README.md` already carrying its lifecycle pointer, and a bare `<Copyright>` with no grant. The other BRIEF instance was a clone of the same repo. **Contamination does not undermine this test the way it did earlier ones.** Elsewhere the worry was a runner recognising a fingerprint and inferring an answer it had not earned; here the rule's *purpose* is to pre-decide these cases, so applying them is the pass condition. What would be illegitimate is claiming the runner discovered the answers independently — it cannot, and the plan does not ask it to. The plan asks whether the rows appear in its **had-to-decide** list, and that is what the brief measures: it asks for actions **declined** as a section of its own, beside the undecided list, so a suppression that happens silently is as visible as one that is reasoned.
- step 7 — respecced: skipped, documented branch. `docs/specs/.map.yml` carries `areas: []`; `/specs init` is TASK-079. Requirements changed: none.
- step 8 — three-axis gate. **standards — pass.** Rulebook `AGENTS.md § Conventions`, rung 1; two skill files, 0 excluded. The general rule is stated **once**, beside the parent principle it extends, and `adopt-project` step 3 carries a pointer rather than a copy. **Register-on-introduce: no entry owed, checked** — this finishes an existing sentence (*a repo that solved it differently has solved it*) rather than introducing a pattern. Section-citation style checked too: three of my new `§` targets are bold paragraphs, which is this file's own convention — `§ *Presence and shape, not content currency*` predates today and is one. **fidelity — pass**, all seven criteria built, including criterion 4's requirement that `## Amendments` be decided explicitly rather than left to follow. **correctness — one finding, fixed inline:** the *in the report* versus one-round conflict, found by the drill. **security-review — not applicable:** two markdown files. 5c skipped — `single-branch`. 5d: `## Out of scope` bullets are boundaries naming TASK-063 and the append-only rule; nothing spawned from the sweep.
- step 8a — drill passed; `in-progress` → `done`. All three suppressions landed in the declined-actions section with reasons and none in had-to-decide. Two findings filed (TASK-101, TASK-102), one wording conflict of my own fixed.
