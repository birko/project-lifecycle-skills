---
id: TASK-097
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
findings: [DRILL-096-1]
pr: null
github-issue: null
jira-key: null
---

# `unknown` is the only container for two different situations, and one of them is not ignorance

## Context

**From the 2026-09-01 cold drill of `adopt-project` on `WorkoutTracker`.** The runner reached a conditional
row it could not settle, chose `unknown`, and then said plainly that the state was the wrong shape for
what it had actually found:

> *"**But I reasoned past the text to do it:** `unknown` is defined as 'you could not determine it', and
> the row is told to name 'the fact that was missing' — **no fact is missing here.** I read every config
> source and every env read in the repo. **What is unsettled is the row's own boundary, not my
> knowledge**, and `unknown` is the wrong-shaped container for that. I used it because it is the only
> non-laundering option on offer."*

That is a distinction the state list does not carry. Two situations reach `unknown`:

| Situation | What it means | What resolves it |
|---|---|---|
| **Evidence ran out** | the survey could not find the fact — a kind nothing declares, a licence with no signal in any direction | asking the user, in step 2's round |
| **The rule ran out** | the survey found *every* relevant fact and the row still does not say which side they fall on | **amending the row** — no answer from the user can fix it |

Collapsing them costs exactly what the `not applicable` / `not applicable yet` split was introduced to
protect: whether anybody should look again, and *at what*. A user asked to resolve an `unknown` of the
second kind is being asked to adjudicate a defect in the inventory, and their answer will not be
reproducible on the next run — which is the non-reproducibility this repo removes everywhere else by
declaring a value rather than deriving it.

**The immediate instance was fixed, and that is why the shape matters.** TASK-096 amended the
`.env.example` row so the required-vs-optional boundary is now stated, so this particular repo would land
`not applicable` today. But the runner's `unknown` was **correct at the time** and carried no signal that a
rule needed amending rather than a user needing asking — so the finding would have reached step 2 as a
question, been answered, and left the row exactly as broken for the next repo.

### What makes this hard, and worth doing carefully

- **A third state is not obviously right.** The state list has grown twice and TASK-085 already reports it
  as having outgrown its shape; adding a fourth `unknown`-adjacent label may be the wrong move.
- **The two are not always cleanly separable in the moment.** A runner who has not read exhaustively cannot
  always tell "evidence ran out" from "I stopped looking", and the honest default in that case is the
  existing `unknown`.
- **The cheapest fix may be a reporting rule rather than a state** — an `unknown` that names *what is
  missing* is already required, so an `unknown` whose named-missing-thing is **the rule itself** could be
  routed differently by the report (to a finding against the layer) without a new label. That would keep
  the state list still and put the signal where step 3b already sends things.

## Acceptance criteria

- [x] The two situations are distinguishable in what the survey reports, by whatever mechanism is chosen
- [x] An `unknown` caused by the **rule** being unsettled produces a finding against the layer — not only a question in step 2's round, which cannot fix it
- [x] An `unknown` caused by **evidence** still routes to step 2 exactly as it does now, with no extra ceremony
- [x] The choice between a new state and a reporting rule is reasoned against TASK-085's finding that the state list has already outgrown its shape
- [x] The undetermined-by-a-runner-who-stopped-looking case still lands in the existing `unknown`, so the distinction cannot be used to dress up an incomplete survey
- [x] Layer parity: whatever lands is defined in `LAYER.md` and both front doors read it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `.env.example` boundary itself — **TASK-096** settled required-vs-optional and the build-time carve-out.
- Reshaping the survey-state list generally — **TASK-085**. This task may *conclude* that a new state is right, but the list's overall shape is that task's subject.
- `present, elsewhere` and the location states — **TASK-091**.

## Human test plan

- [x] Cold-drill a repo against a row whose condition is deliberately left ambiguous, expected answers withheld, and confirm the runner's report distinguishes "I could not find out" from "the row does not say"
- [x] Confirm a genuinely evidence-limited row (a licence with no posture signal) still reports the way it does today, with no added ceremony

## Implementation plan

_Populated by `/tasks plan TASK-097` — leave empty until then._

## Outcome

**What the fix was.** `unknown` was one line — *"you could not determine it"* — and every routing sentence in
the file sent it the same way, to step 2's question round. But two different situations arrive there: the
survey could not find the fact, which a user can supply; or the survey found **every** relevant fact and the
row still does not say which side they fall on, which no answer from any user can fix. The second reached the
one party unable to act on it, got answered, and left the row broken for the next repo with nothing recording
why. `LAYER.md` now carries § *Two things reach `unknown`* — the split, the routing, and the bar for claiming
the second kind — and `adopt-project` reads it in two places.

**The design call, which criterion 4 required be reasoned rather than assumed: a reporting rule, not a ninth
state.** TASK-085's argument is real — eight states, ~350 words in one bullet, and the states *are* a branch
an agent picks exactly one from. But the decisive reason is different and worth stating because it is what
makes the answer stable: **these are not two states of the artifact.** Its condition is identical in both —
the survey cannot say — and what differs is *who can resolve it*. A state describes the artifact; a resolution
route is a property of the finding. Adding a label that does not describe the artifact would answer a routing
question with vocabulary. `unknown` already had to name what was missing, so the mechanism existed: when the
named-missing-thing is **the row**, the finding also goes to the report's defect section.

**The consequence I nearly missed, and it is the load-bearing half.** A rule-ran-out `unknown` is a defect in
*the layer*, and § 3b says plainly *"the task lands in its `tasks/`, never the caller's."* A reader at 3b would
file an upstream defect into the consumer's tracker — where nobody can act on it, while the next repo meets
the identical row. So the change needed a carve-out **at 3b**, not only at the report bucket: this is the one
defect that does not get filed into the adopted repo, mirroring [[fix-next]] § *Fix at the right layer*.

**Criterion 5's guard is an enumeration, not a feeling.** A runner who stopped looking and one who read
everything both feel certain, and only one may blame the rule. The claim therefore requires the gathered
evidence *in the report*; without it the state is plain `unknown` and the round asks.

**Both plan items passed, and the drill never mentioned unknowns.** The brief asked only for the table with
per-row reasoning plus the had-to-decide / settled-for-me pair — so the distinction had to appear unprompted,
and it did:

- **Item 2 (evidence-limited row, no added ceremony).** `LICENSE` → `unknown` after an enumerated sweep of
  README, five csproj, props, `package.json` and an SPDX pass, and the runner classified it itself: *"This is
  an **evidence** `unknown`, not a rule one — the fact is simply absent from the repo and the user can supply
  it in step 2."* It then produced the step-2 question verbatim. Same behaviour as before, no ceremony added.
- **Item 1 (distinguishes the two), and it passed the informative way — by *not* over-triggering.** On the
  `Dockerfile` row, whose condition a previous runner had already found undecidable: *"Had I resolved it the
  other way I would have been claiming a **rule-ran-out `unknown`** — **I have the enumeration the claim
  requires** — and that finding would belong upstream against these instructions rather than in this repo's
  tracker. I am reporting the state as `missing` and flagging the ambiguity rather than doing both."* It knew
  the category, knew the evidence bar, knew the routing, and still declined to use it because it could resolve
  the row on other grounds. A rule that fires only when it should is better evidence than one that fires.

**No fixture was built, and that was the right call.** The plan's own wording — *"a row whose condition is
deliberately left ambiguous"* — invites manufacturing one, and § *The cold drill* (written an hour earlier)
warns that a fixture tests the author's model. It was unnecessary: the `Dockerfile` row is **already**
undecidable on a real repo and unfixed, and the same repo carries the evidence-ran-out case, so one target
exercised both items with neither manufactured.

**Flagged, not fixed.**

- **DRILL-097-1 appended to TASK-086**, which it strengthens materially. That task was written around the
  *offer* being wrong; this runner locates the defect one step earlier — the state's own justification,
  *"the file is already right; what is missing is the commit"*, is **false for work in progress**, so the
  remedy is wrong because the premise is. Second measured instance, different repo, and this one is seven
  files at once including three a *different* verb owns mid-regeneration.
- **DRILL-097-2 appended to TASK-099, raised P3 → P2.** The `tasks/` row carries the same parenthesised
  shape as `Dockerfile`, and here the reading *changes the state*: both named files were clean while a third
  file inside the directory was modified, so the narrow reading says `present` and the directory reading says
  `present, uncommitted`. Two rows now, and they may want different answers — a sibling paired by filename is
  not the same as members of a directory the row names.
- **One gap considered and declined:** the harness ladder's first rung names *"a `package.json` script"*
  without saying whether a **nested** manifest counts or whether the gate must run *automatically*. The runner
  treated a nested e2e script as satisfying it, which is defensible, and the next rung would have caught the
  harness anyway. A rule for a case that has arisen once, with no wrong outcome, is the kind this repo deletes.
- **A dormant trap in the drilled repo, reported not filed:** `.gitignore:36`'s `.env.*` would silently ignore
  a future `.env.example`, with no `!.env.example` negation. Harmless while that row is `not applicable` —
  there is no template to lose — and the runner correctly called it an observation rather than a defect.

## Progress log

- step 2 — picked. Best-evidenced of what remains and the most **silent** failure left in the pool: an `unknown` raised because *the rule* is unsettled reaches step 2 as a question, gets answered by a user who cannot fix it, and leaves the row exactly as broken for the next repo — with nothing anywhere recording that a rule needed amending. Three tasks have now brushed against it (TASK-085 on the state list's shape, TASK-091 on location states, TASK-096 which produced it). Beat TASK-086 on key 5 and key 4: 086 still carries four undecided design candidates, where this one's design question is bounded and TASK-085 already frames it. Key 6 inert. **Its own design question is real and not pre-decided** — a fourth state versus a reporting rule — and the criterion requiring that choice to be reasoned against TASK-085 is the part to honour rather than skip.
- step 3 — verified: held. `unknown` is defined in **one line** at `LAYER.md:436` — *"you could not determine it. Honest, and it stops the fill."* Every routing sentence sends it one way: `:217` *"the state is unknown … and step 2's question round settles it"*, `:444` *"When in doubt, report unknown and ask."* So a rule-ran-out `unknown` is not merely undistinguished, it is actively routed to the one party who cannot fix it.
- step 4 — layer: local.
- step 5a — **the design call, which criterion 4 requires be reasoned rather than assumed: a reporting rule, not a ninth state.** Two arguments, and the second is the real one. (i) TASK-085 measures the list at eight states and ~350 words in one bullet, and notes the states **are** a branch an agent picks exactly one from — a ninth makes that worse. (ii) Decisive: **the two situations are not different states of the artifact.** Its condition is identical — the survey cannot say — and what differs is *who can resolve it*. A state describes the artifact; the resolution route is a property of the finding. A label that does not describe the artifact would be answering a routing question with vocabulary. `unknown` already requires naming what is missing, so the mechanism exists: when the named-missing-thing is **the row**, the finding also goes to the report's defect section.
- step 5 — fix in `skills/new-project/LAYER.md` (the `unknown` bullet gains *say which kind*, and a new § *Two things reach `unknown`* carries the table, the state-versus-finding reasoning, the upstream routing and the enumeration bar) and `skills/adopt-project/SKILL.md` in **two** places: step 4's `unknown` bucket, and **step 3b** — which without a carve-out says plainly *"the task lands in its `tasks/`, never the caller's"*, so a reader there would file an upstream layer defect into the consumer's tracker, where nobody can act on it and the next repo meets the same row. Criterion 5's guard is the enumeration: the claim needs the evidence gathered *in the report*, so a runner who stopped looking lands in plain `unknown`.
- step 6 — reverted fix: prose, so the drill is the guard. Textual split: `unknown` had **one** routing destination in the whole file (`:217` and `:444` both send it to step 2's round) and now has two, with the second carrying a filing prohibition that did not exist. **No fixture was built, and that matters** — [[populate-tests]] § *The cold drill* warns that a fixture tests the author's model, and the plan's own wording (*"a row whose condition is deliberately left ambiguous"*) invites building one. It was unnecessary: the `Dockerfile` row's condition is **already** undecidable on a real repo, unfixed, and a previous runner named it — *"'Deployed' … shape or fact? … Read as *is deployed today*, the same evidence gives `not applicable` or `unknown`. **The text does not choose.**"* That is a live rule-ran-out. The same repo also carries the evidence-ran-out case (`LICENSE`, no posture signal in any of the three forms the row names), so **one target exercises both plan items** — item 1's rule case and item 2's evidence case — with neither manufactured.
- step 6a — brief design: the drill **never mentions `unknown`, the two kinds, or either row**. Asking *how do you characterise what you could not determine* would leak that the answer has structure. Instead the brief asks only for the table with per-row reasoning plus the standard had-to-decide / settled-for-me pair — so if the rule works, the distinction appears **unprompted** in the runner's own states, because the rule is what tells it to name which kind. Contamination: `WorkoutTracker` is named in `LAYER.md` for the guide-vintage measurement, a different question, and the new section names no repo at all.
- step 7 — respecced: skipped, documented branch. `docs/specs/.map.yml` carries `areas: []`; `/specs init` is TASK-079. Requirements changed: none.
- step 8 — three-axis gate. **standards — pass.** Rulebook `AGENTS.md § Conventions`, rung 1; two skill files, 0 excluded. The rule is stated **once** in `LAYER.md` and read from `adopt-project` in two places, both pointers. Layer parity structural via `LAYER.md`. **Register-on-introduce: no entry owed, checked** — *report a finding at the layer it belongs to* is [[fix-next]] § *Fix at the right layer* applied to a survey row, an existing convention in a second place rather than a new one. **fidelity — pass**, all seven criteria built, including criterion 4's reasoning requirement, which is answered in the Outcome rather than merely satisfied. **correctness — one finding, fixed inline:** the 3b carve-out, without which a reader files an upstream defect into a consumer's tracker. **security-review — not applicable:** two markdown files; no auth, data access, input handling, crypto, secrets or dependency surface. 5c skipped — `single-branch`. 5d: `## Out of scope` bullets are boundaries naming TASK-085, TASK-091 and TASK-096; nothing spawned.
- step 8a — drill passed both plan items; `in-progress` → `done`. Item 1 passed by the rule declining to fire on a row the runner could resolve otherwise, while demonstrating it knew the category, the evidence bar and the upstream routing — better evidence than a trigger. Two findings appended to existing tasks (TASK-086, TASK-099 raised to P2), one declined with reasons, one repo observation reported.
