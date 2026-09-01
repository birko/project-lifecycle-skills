---
id: TASK-091
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
findings: [DRILL-063-2, DRILL-063-3, DRILL-035-5, DRILL-094-1, DRILL-096-2]
pr: null
github-issue: null
jira-key: null
---

# Two artifact shapes the row definitions do not cover

> **Priority raised P3 → P2 on 2026-09-01**, on evidence rather than opinion. Filed as a tidiness gap in
> row wording; it is now a **measured reproducibility failure** — two independent runners assigned opposite
> states to one unchanged file (DRILL-096-2), and the instance count reached five findings across three
> row kinds, one of them a plain row rather than a conditional one. A survey whose state depends on which
> agent ran it is not a survey, and P3 no longer describes that.

## Context

**From the 2026-09-01 cold drill of `adopt-project`'s survey.** Two rows the drill had to resolve by
inference, grouped because both are the same omission — a state or a shape the row cells never discuss.

### `present, elsewhere` on a conditional row

`Symbio` has `deploy/Dockerfile` and `deploy/Dockerfile.dockerignore`, not root-level ones. The state
exists generically — *"found in another location or form. **Say where.**"* — but the conditional rows added
2026-09-01 only ever discuss `missing` / `not applicable` / `unknown` / *leave it*. The drill used
`present, elsewhere` anyway and flagged that nothing confirms it applies: *"no other label fit a Dockerfile
that plainly exists just not at the canonical path; the text doesn't confirm that's the intended use."*

It is almost certainly right — a conditional row's condition decides **whether the row applies**, and the
location states are orthogonal to that, exactly as `present, uncommitted` composes with any row. But
"almost certainly right by analogy" is what a rule is for.

### A guide split across several files

The agent-guide row names two shapes: `CLAUDE.md`, or `AGENTS.md` plus a one-line bridge. `Symbio` carries
`CLAUDE.md` **and** `CLAUDE-module-checklist.md`, `CLAUDE-project-status.md`, `CLAUDE-ui-prompt.md`,
`CLAUDE-ui-rules.md`. The drill left them unclassified and said so: nothing states whether they are part of
the one graded artifact, `present, elsewhere` content, or out of scope.

This matters more than a tidy-up because the guide is the artifact the whole layer is built to feed. A
survey that silently ignores four sibling guide files is not reporting on the thing it says it is.

### Second instance of the same gap, from the 2026-09-01 `Birko.Framework` drill (DRILL-035-5)

Independent corroboration on a **different conditional row**, which is why it is appended here rather than
filed separately: this task already owns the rule, and a second task would re-litigate it.

That repo's licence is `License.md`, not `LICENSE`. The row's branches are binary — *"Open posture and no
`LICENSE` file → **missing**"* / *"Present → **leave it**"* — and neither covers a licence file under a
different name. The runner reached the same conclusion by the same route as the Dockerfile case:

> *"The row's binary … does not say which side a differently-named licence file lands on. I chose
> `present, elsewhere`, naming `License.md` — because § *Detect what the repo has* is emphatic that
> detection is by evidence and not by path, and reporting `missing` here would have been exactly the
> false-`missing` that section calls the dangerous direction."*

**Two conditional rows, two independent runners, the same missing state.** The Dockerfile case was a
canonical artifact at a non-canonical *path*; this one is a canonical artifact under a non-canonical
*name*. Both resolve correctly under `present, elsewhere` and neither row says so, which sharpens the fix:
whatever lands must cover name as well as location, or the next differently-named artifact reopens it.

### Third instance, from the 2026-09-01 `BardStudio` drill (DRILL-094-1)

A **plain** row this time, not a conditional one, which widens the rule the fix owes.

`docs/architecture.md`'s cell reads only *"Leave it; report if absent"* — which taken alone yields
`missing`. But § *Detect what the repo has* says architecture notes *"may live in the README, a `wiki/`, or
`Documentation/`"*. The runner:

> *"The two do not resolve each other, and the row names no verb to defer to. **I chose
> `present, elsewhere`**, because the false-`missing` direction is the one the file calls dangerous … and
> because the row's own instruction — *report if absent* — is satisfied by naming where it actually is.
> Reporting `missing` would invite creating a second architecture document beside `CLAUDE.md`
> § Architecture."*

It is right, and it had to derive it. **So the gap is not specific to conditional rows:** a `Dockerfile` at
a non-canonical path, a licence under a non-canonical name, and now architecture notes in a different
*file* are three shapes of one omission — the location states exist generically and no row cell mentions
them. Whatever lands should therefore say once, where the states are defined, that the location states
compose with **every** row rather than being enumerated per row.

### Two runners, opposite states, one file — the sharpest evidence yet (DRILL-096-2)

The `Birko.Framework` drill of 2026-09-01 met the **same `License.md`** as the run recorded above and
reached the **other** answer:

> *"The row names `LICENSE`; the file is `License.md`. **Chosen: `present`**, naming the actual path — on
> the 'solved it differently' rule. I specifically did **not** use `present, elsewhere`, on the reasoning
> that the file is in the expected *location* and differs only in name and extension. **That distinction
> between 'another location' and 'another name' is mine; the text does not draw it**, and a reader could
> defensibly report `present, elsewhere` instead."*

So one runner reported `present, elsewhere` and another reported `present`, on one unchanged file, each
with sound reasoning. That is no longer an argument that the rule is *missing* — it is a measured
demonstration that the survey is **not reproducible** on this row today, which is the property this repo
removes everywhere else by declaring rather than deriving.

**It also names the axis the fix must cover:** *location* and *name* are different, and the state list
mentions only the first (*"found in another location or form"* — where "form" is doing unexamined work).
With DRILL-094-1's plain-row instance, the fix now owes three axes — another path, another name, another
file — stated once where the states are defined rather than per row.

## Acceptance criteria

- [x] Whether the location/tracking states compose with a conditional row is stated once, where a reader of either will find it — not repeated on each row
- [x] The agent-guide row says what a companion file is: part of the artifact, a separate finding, or out of scope, with the reason
- [x] Whatever is decided holds for the measured cases: `Symbio`'s `deploy/Dockerfile` and its four `CLAUDE-*.md` companions
- [x] Neither answer reintroduces judging content — a companion file is classified by **existence and role**, never by whether its prose is any good ([[new-project]] `LAYER.md` § *A guide's vintage is not surveyable*)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Whether the guide's rules are current — settled as a limitation by **TASK-063**, and this task must not reopen it.
- Adding more conditional rows. This is about how the existing ones compose with states that already exist.

## Human test plan

- [x] Survey `Symbio` and confirm both shapes land in a stated outcome rather than in the surveyor's judgement

## Implementation plan

_Populated by `/tasks plan TASK-091` — leave empty until then._

## Outcome

**What the fix was.** `present, elsewhere` was defined once, as *"found in another location or form"*, with
*"or form"* silently carrying both a different **name** and a different **file** — and nothing said the state
composed with a row whose cell did not mention it. Four runners had reached for it across three row kinds and
two had reached **opposite** answers on one unchanged file. The state now names three axes (path / name /
file); a new § *Location is orthogonal too*, modelled on the existing tracking rule, states the composition
once for **every** row; the `License.md` tie is decided; and the companion-file question is answered in both
the states section and the guide row.

**The test plan passed, and the runner confirmed the hole I found in my own fix was load-bearing.** On
`Symbio`, both specified shapes landed in **stated outcomes**: `deploy/Dockerfile` → `present, elsewhere`
(path, and the `.dockerignore` by name), and the four `CLAUDE-*.md` companions → three folded into the one
artifact, `CLAUDE-ui-prompt.md` explicitly *"not part of the artifact and not a gap"*. Both appeared under
*questions the instructions settled for me*, and on the unlinked branch the runner wrote: **"Without this I
would have had to adjudicate a fourth file with no rule to hand."** That branch existed only because
verifying criterion 3's own measured cases caught my first wording one file short.

Also confirmed working, unprompted: *"**Location composes with every row, including plain ones.** … This is
what made `docs/architecture.md` → `docs/00-architecture.md` a `present, elsewhere` rather than a
`missing`."* Its one complaint about the mechanism is fair and not a defect — it *"had to read 420 lines
further down to find the rule"*, which is the cost of stating a rule once instead of on every row.

**Judgement calls, and the stricter option rejected.**

- **The `License.md` tie is broken by what the state is *for*.** `present, elsewhere` carries *never offer to
  create a second one*; plain `present` carries no guard, and a repo with `License.md` is exactly one that
  must not be offered a `LICENSE`. Directory depth was never the question.
- **The link is the discriminator for a guide companion, not the name prefix.** Rejected the tidier reading
  — *anything called `CLAUDE-*` is part of the guide* — because it would have the survey judging a document
  the guide never adopted. The measured fourth file is 79 lines of copy-paste prompt template for a human.
- **The composition rule is stated once, not per row.** Rejected pointing every affected row at it: that is
  the restated-list defect at row granularity, and the rows that forgot would silently report `missing`.
- **No register-on-introduce entry owed, checked rather than assumed.** "An orthogonal axis composes with
  every row" is the *existing* tracking rule applied to a second axis; modelling the new section on that one
  is what makes it recognisable rather than novel.

**Two conflicts fixed inline, one of them across tasks.**

- **The `## Conventions` exception contradicted this change's companion rule.** TASK-093 wrote that the guide
  *"must carry itself"*; this change wrote that a linked companion is part of one artifact. The runner hit
  both on a repo holding fourteen UI rule sections in a linked companion and resolved it only because that
  guide *also* carried forty of its own — *"had the rules been only in the companion, the two sentences would
  genuinely conflict and the text does not say which wins."* Checking `verify-conventions` settled which was
  wrong: its ladder explicitly reads *"any project-specific checklist the guide links to"*, so a linked
  companion **is** reachable by the enforcing skill. The test is now **reachability**, not residence — a
  linked companion counts, an unlinked file or a `README.md` the ladder never treats as a rulebook does not.
- **"Inside another file" needed to mean the artifact's *purpose* is served there.** The runner found a
  deployment guide documenting a required environment variable in detail and asked whether that made the
  `.env.example` row `present, elsewhere`: *"the text does not settle which wins when another file documents
  the **fact** but not the artifact's **form**."* Now settled — such a row is `missing`, and the report says
  where the fact is documented, which satisfies the never-duplicate guard without mislabelling the state.

**Flagged, not fixed.** **TASK-099** — a row naming two artifacts (`Dockerfile (+ .dockerignore)`) never says
whether the second carries its own state; the last unstated axis of the composition rules, and a
convention-bound companion may not take the same answer as a linked one. **DRILL-091-1 appended to
TASK-095** — by-meaning matching has no depth bar either: the runner resolved the lifecycle section `present`
on a README section it called *"pointer-depth"* and named the shortfall itself. That widened TASK-095 past
what it was filed for, so it gained two criteria, including that a **shallow** answer must be
distinguishable from an **ambiguous** one — its existing undetermined route was written for the second.

**Defects in the drilled repo, correctly left unfiled by the runner and reported to the user:** `Symbio`'s
guide routes an agent to a *"register-on-introduce in the lifecycle section"* that does not exist — the guide
has no lifecycle section and the phrase appears nowhere in it or its three linked companions; and
`CLAUDE-project-status.md:66` links `../Birko.Framework/tasks/README.md`, which has no correct target under
any resolution.

**Both filed into `Symbio` on 2026-09-01** (its commit `45cc0eda`), under
`EPIC-028/STORY-059-docs-test-coverage-sync` rather than `_loose` — that epic is `kind: review-intake`, so
they are drainable by `/fix-next` there, and the story already holds doc-drift findings. **`Symbio` TASK-646
(P2)** and **TASK-647 (P3)**. Verifying by hand before filing **overturned the runner's conclusion on the
second**: it reported the link as having *"no correct target under any resolution"* because it checked
`Framework/tasks/` and found nothing — but `Framework/Birko.Framework/tasks/` **does** exist. `Framework/` is
the tree, `Framework/Birko.Framework/` is the aggregator repo inside it, so the link *text* is right and only
the `../` prefix is wrong. The remedy inverts on that: *"points nowhere, delete it"* versus *"off by one
segment, fix it"*. Filing the runner's version would have destroyed a working pointer to a real backlog, and
the trap that caught it — a tree and a repo one level apart sharing a name — is recorded in the task so the
next reader is not caught the same way.

## Progress log

- step 2 — picked. Five findings from five independent runners across three row kinds, including a **measured non-reproducibility** (DRILL-096-2: two runners, opposite states, one unchanged `License.md`). Beat TASK-097 on key 4 — three drills have already converged on what this fix owes, where 097 needs a design decision weighed against TASK-085. Beat TASK-068 (the pool's last P1) on key 1, same as last round: a missing practice is not a wrong result. Key 3 is where it is weakest and I am recording that rather than dressing it up — a false `missing` surfaces an offer the user can refuse, so this is louder than the laundered states I have been prioritising; it wins on the sheer weight of key 5 plus reproducibility, which is the property the whole survey depends on. Key 6 inert.
- step 3 — verified: held. `present, elsewhere` is defined in exactly **one** place (`LAYER.md:424`), as *"found in another location or form"* — and *"or form"* is the whole of what covers a name or a file. Nothing says the state composes with a row whose cell does not mention it, and the precedent proving such a sentence is needed already exists for the sibling axis: § *Detect what the repo has* carries **"Tracking is orthogonal to the *Already present?* column"**, with the explicit note that *"without this line the two instructions read as a contradiction, and the row wins"*. Location had no equivalent.
- step 4 — layer: local.
- step 5 — fix in `skills/new-project/LAYER.md`: the state definition now names three axes (**path / name / file**) instead of "location or form"; a new § *Location is orthogonal too* is modelled on the tracking rule and states the composition once, for **every** row, with the plain-row instance (architecture notes inside the guide) as the reason it is not filed under § *Conditional rows*; the `License.md` tie is **decided** rather than left open; and the companion-file question is answered in both the states section and the guide row, per criterion 2. The guide row gains a pointer, not a copy.
- step 5a — **the `License.md` split is settled by what the state is for, not by directory depth.** Two runners reasoned soundly to opposite answers. `present, elsewhere` carries *"never offer to create a second one"*; plain `present` carries no guard. A repo with `License.md` is precisely a repo that must not be offered a `LICENSE`, so the guard is the load-bearing half and any deviation in **name** lands there exactly as a deviation in **path** does.
- step 6 — reverted fix: textual split is clean (one definition, no composition sentence, "or form" carrying name and file silently). But the real evidence is **DRILL-096-2's measured non-reproducibility** — two independent runners, opposite states, one unchanged file, each with sound reasoning. That is stronger than any grep: it demonstrates the rule was absent by showing the survey producing two answers. **Verification also caught a hole in my own fix**, see 6a. **Contract pins, not evidence:** `skills-lint` (18 skills) and `skills-lint-test` — neither can observe a prose rule.
- step 6a — **checking criterion 3's measured cases against my own wording found it one file short.** I wrote that a companion the guide **links** is part of the artifact. Verified directly on `Symbio`: `deploy/Dockerfile` resolves cleanly (conditional row, another path), and of the four `CLAUDE-*.md` companions **three are linked** from `CLAUDE.md` — a routing table at `:69-70` sends UI and new-module work to two, a documentation index at `:2673-2675` names a third — while **`CLAUDE-ui-prompt.md` is linked from nothing at all** (`grep -rn` across every `.md` returns only itself). So my rule resolved three of four and left the fourth exactly where TASK-091 found it. Reading the file settled which way it should go: 79 lines of copy-paste prompt template for a human, not rules the guide delegates to — so **the link is the right discriminator and a shared name prefix is not**, and the fix now says so in both branches. Had I trusted the criterion's phrase *"its four `CLAUDE-*.md` companions"* without opening them, the gap would have shipped inside its own remedy.
- step 7 — respecced: skipped, documented branch. `docs/specs/.map.yml` carries `areas: []`; `/specs init` is TASK-079. Requirements changed: none.
- step 8 — three-axis gate. **standards ([[verify-conventions]]) — pass.** Rulebook `AGENTS.md § Conventions` via the bridge, rung 1; 1 skill file, 0 excluded. § *Defer to a shared inventory* honoured — the composition rule is stated **once** where the states are defined, and the guide row carries a pointer plus its own answer (which criterion 2 requires) rather than a copy. Layer parity structural via `LAYER.md`. One prose cleanup during the pass: the guide row named § *A guide's vintage is not surveyable* twice, so my clause now reads *"its prose is content, not shape"* and the cell keeps a single reference. **Register-on-introduce: no entry owed, and this one was worth checking** — "an orthogonal axis composes with every row" is not a new pattern, it is the **existing** tracking rule applied to a second axis, and modelling the new section on that one is what makes it recognisable rather than novel. **fidelity ([[verify-intent]]) — pass**, all five criteria built; criterion 4's no-content-judgement constraint is met explicitly in both places the companion rule appears. **correctness ([[code-review]]) — one finding, fixed inline:** the unlinked-companion branch, found by verifying criterion 3's own measured cases (step 6a). **[[security-review]] — not applicable:** one markdown inventory file; no auth, data access, input handling, crypto, secrets or dependency surface. 5c skipped — `integration: single-branch`. 5d: `## Out of scope`'s bullets are boundaries naming TASK-085 and the content-currency rule; nothing spawned.
- step 8a — suites confirmed after the prose cleanup, not assumed: `skills-lint` OK (18 skills), `skills-lint-test` **43 passed, 0 failed**. Criterion 5 met. All criteria now met except the human test plan, which is the `Symbio` drill in flight — task stays `in-progress` until it returns, rather than flipping on a claim its evidence has not arrived for.
- step 8b — drill passed; `in-progress` → `done`. Both specified shapes landed in stated outcomes and both appeared under settled-for-me. Two conflicts fixed inline (the cross-task `## Conventions` exception, and form-vs-fact in `present, elsewhere`); one finding filed (TASK-099), one appended to TASK-095 with two criteria added there; two repo defects reported to the user unfiled.
