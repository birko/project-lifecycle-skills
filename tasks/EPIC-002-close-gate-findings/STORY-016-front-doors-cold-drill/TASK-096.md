---
id: TASK-096
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
findings: [DRILL-093-1, DRILL-093-2]
pr: null
github-issue: null
jira-key: null
---

# A conditional row cannot say what "here" means, or which kind of env var counts

## Context

**From the 2026-09-01 cold drills of `adopt-project` step 1 on `Latent` and `Birko.Framework`.** Grouped
because both are the same row's scope question — `.env.example`'s *"does anything **here** read runtime
config from the environment?"* — and neither is answerable from the row as written.

### DRILL-093-1 — "here" is undefined for an aggregator

`LAYER.md` § *Conditional rows* says to ask the artifact's own question and that **"any component
answering yes settles it."** That presumes the components are inside the surveyed repo. `Birko.Framework`
is an aggregator: **its root holds no source at all** — two directories, `docs/` and `tasks/` — while its
`.slnx` registers **343 projects**, every one resolving to a sibling directory outside the repo root, each
its own git repo. The runner:

> *"The components of this *solution* live in 176 sibling directories that are **separate git repos**,
> outside the adopted root. I chose to scope 'here' to the adopted repo (which contains no source at all),
> so `.env.example` and `Dockerfile` are `not applicable`. **Scoped to the whole solution the answer might
> differ** — `Birko.Communication.REST.Server`, `.AspNetCore` and `.gRPC.Server` exist, though as
> shared-project libraries rather than hosts. **Nothing in the instructions settles whether an aggregator
> surveys its aggregate.**"*

Its choice is almost certainly right — the layer is per-repo, and a survey that reached across 176 repos
would report gaps nobody adopting *this* repo can fill. But it is a choice the row does not make, and the
two readings give opposite states on two rows. Note this is **not** the same question as
§ *CI a repo cannot pass*, which already handles out-of-root paths as a **blocker**: that section decides
obtainability, this one decides whether the component even counts as evidence.

### DRILL-093-2 — build-time and runtime env vars are not distinguished

The row asks about **runtime config from the environment**. Every Birko consumer reads `BIRKO_SRC`, a
genuine, documented environment variable — consumed by MSBuild at **build** time to locate framework
source. **Three separate runners across four drills each reasoned this out from scratch** and each recorded
it as an inference rather than a reading:

> *"`BIRKO_SRC` is a **build-time** MSBuild variable in `Directory.Build.props`, not runtime config"*
> — the BardStudio run

> *"The one env var the repo documents, `BIRKO_SRC`, is a **build**-time MSBuild/esbuild path override …
> not runtime config. I record the consideration here because **the row does not distinguish build-time
> from runtime env vars in so many words**."* — the Birko.Framework run

> *"`BIRKO_SRC` is a genuine, repo-documented environment variable, but MSBuild reads it at build time and
> `.env` files are not how it reads it."* — the Latent run

Every one landed on the same answer, which is the point: **a rule three readers must each derive is a rule
that is not written down**, and the fourth reader is the one who gets it wrong. Getting it wrong produces a
`missing .env.example` on a desktop app with no runtime configuration at all — a false gap on the row whose
whole purpose is to avoid them.

## Acceptance criteria

- [x] The conditional rows state what **"here"** scopes to, and an aggregator repo whose components live in sibling repos gets a defined answer rather than a runner's judgement
- [x] The answer distinguishes this question from § *CI a repo cannot pass*, which already treats out-of-root paths as a blocker for a different reason
- [x] The `.env.example` row says that **build-time** environment variables do not satisfy its condition, with `BIRKO_SRC` or an equivalent as the worked example
- [x] A repo whose only env var is build-time surveys `.env.example` as `not applicable`, not `missing`, without the runner having to derive why
- [x] Layer parity: the rows live in `LAYER.md`, which both front doors read
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The guide-section inventory and by-meaning matching — **TASK-093** settled those.
- `present, elsewhere` on a conditional row, and a licence file under a non-canonical name — **TASK-091**.
- Whether `Dockerfile`/`.env.example` should be layer rows at all. They are, and the conditional-row design is not reopened here.
- Making the survey cross repo boundaries. Almost certainly wrong, and if anyone wants it, it is a much larger question than this row.

## Human test plan

- [x] Cold-drill the survey against an aggregator repo with no source of its own, expected answers withheld, and confirm the runner reaches the scope answer from the row rather than deriving it
- [x] Confirm a repo whose only environment variable is build-time surveys `.env.example` as `not applicable` without commentary about having had to decide

## Implementation plan

_Populated by `/tasks plan TASK-096` — leave empty until then._

## Outcome

**What the fix was.** `.env.example`'s and `Dockerfile`'s conditions asked whether *"anything **here**"* did
something, and *"any **component** answering yes settles it"* — with neither *here* nor *component* scoped
anywhere. On an aggregator whose root holds only `docs/` and `tasks/` while its solution registers 343
projects in sibling git repos, the two available readings give opposite states on two rows. And the
`.env.example` condition asked whether anything *reads* runtime env config while the row's own definition of
the artifact is *"the template of **required** env vars"* — so it over-triggered on any app with an optional
override. § *Conditional rows* now scopes "here" to the surveyed work tree, separates that from
§ *CI a repo cannot pass* (which answers *blocker* about the very same sibling tree this section calls
irrelevant), states that a repo with no components of its own answers *no* **settled** rather than
`unknown`, aligns the condition to *requires* rather than *reads*, and carves out build-time variables with
`BIRKO_SRC` as the worked example.

**Both test-plan items passed, the second only after I fixed my own fixture error.**

- **Item 1** passed in the strongest available form: the scope question moved out of the runner's
  *had-to-decide* list and into *questions the instructions settled for me*. It called the CI separation
  *"the single most useful sentence on the page for this repo"*, because it told the runner to reach
  opposite conclusions from one fact — *"which I would otherwise have agonised over or, worse,
  collapsed."*
- **Item 2 failed first on the wrong fixture.** The criterion specifies a repo whose **only** env var is
  build-time; `WorkoutTracker` reads three at runtime (verified by hand, all optional with committed
  defaults), so it landed `unknown` with pages of reasoning. Re-run on `Latent`, whose only env var is
  `BIRKO_SRC`: **`not applicable`**, and `.env.example` appears nowhere in that runner's had-to-decide
  list. Its own words — *"Made `.env.example` a one-line answer"*, and on the build-time rule, *"without
  the paragraph I would have reasoned it out (as three prior runners apparently did) or reported a false
  `missing`."*

**Judgement calls, and the stricter option rejected.**

- **An out-of-root component never creates an obligation, and may still evidence a capability.** The
  stricter reading — "nothing outside the root is evidence, full stop" — is what I first wrote, and drill 1
  caught it conflicting with the harness row's deliberate *"`*.Tests` files **anywhere**"*. Rejected because
  a parallel test tree this repo's own solution registers **is** its harness, and a false `missing` there
  invites [[populate-tests]] to wire a second runner over a working one.
- **The condition was re-worded rather than the definition.** The alternative was to widen `.env.example` to
  cover optional overrides, which would put a valueless template in every repo with a defaulted env var —
  a false gap on the row whose entire purpose is avoiding them.
- **Required-vs-optional was pulled in, not spawned; `unknown`'s shape was spawned, not pulled in.** The
  first is the same row, the same root cause and one paragraph. The second needs a design decision weighed
  against TASK-085's finding that the state list has already outgrown its shape, and the cheapest answer
  may be a reporting rule rather than a fourth state.
- **No criterion was added after the fact.** Required-vs-optional is recorded as an out-of-scope repair
  rather than a criterion I wrote myself and then ticked, which is the reverse of what a criterion is for.

**Flagged, not fixed.**

- **TASK-097** — `unknown` is the only container for two situations: *evidence ran out*, which a user can
  answer, and *the rule ran out*, which only an amendment can. The runner named it: *"`unknown` is the
  wrong-shaped container for that. I used it because it is the only non-laundering option on offer."*
- **TASK-098** — § *The adopted-repo brief* describes the stamp for a repo with no surviving ask and is
  silent on the repo that has one. Small, and the task says to keep it small.
- **TASK-091 raised P3 → P2 on evidence.** Two runners assigned **opposite states to one unchanged
  `License.md`** (DRILL-096-2), each reasoning soundly — no longer a wording gap but a measured
  reproducibility failure, now five findings across three row kinds including a plain row.
- **Defects in the drilled repos**, correctly left unfiled by every runner and reported to the user:
  `Birko.Framework`'s `.vscode/tasks.json` and `launch.json` target a `Birko.Framework.csproj` that exists
  nowhere in that repo; `WorkoutTracker`'s `README.md:7` and `CLAUDE.md:6` both link `../Birko.Framework`,
  which resolves into `Consumers/` rather than the real `../../Framework`, and it has a tracked
  `Reps.Api/test-results/.last-run.json` frozen at `{"status": "failed"}`; `Latent` has
  `.claude/scheduled_tasks.lock` uncovered by its own `.gitignore`. One pleasing confirmation: the `Latent`
  runner found TASK-020 already filed and said *"No new task owed"* — the filing earlier today did its job.

**All four were filed on 2026-09-01, into the repos that own them**, each verified by hand first rather
than taken from its runner's report — and the verification changed two of them:
**`Birko.Framework` TASK-290** (`_loose`, commit `0c0d6f8`) — the `.vscode` targets are dead, and the
sharper fact is that the repo contains **no `.csproj` at all**, so these are the *only* task-runner targets
in it; anything asking what the gate runs meets a broken build task first, which is what the survey itself
hit. **`WorkoutTracker` TASK-174 + TASK-175** (commit `410b1c3`, filed under `STORY-010-reps-adopt-cleanups`,
the story that owns this class) — the link is on line 8 not 7 as reported, and the test-output defect has
**two halves with different remedies**: the file needs `git rm --cached` because an ignore line will not
untrack it, and `playwright.config.ts` sets no `outputDir`, so an explicit one may beat a root ignore line.
**`Latent` TASK-021** (`_loose`, commit `ae02808`) — filed on the *shape* rather than the file: the ignore
names one `.claude` path by filename, this is the second file to appear there, and the negation list is the
part to get right. Every commit staged explicit paths only; all three repos' pre-existing uncommitted work
was left untouched.

## Progress log

- step 2 — picked. Beat **TASK-091** (whose scope widened earlier today with DRILL-094-1) on key 3: this task's failure is a **laundered** `not applicable` that makes a real gap disappear, where 091's false `missing` surfaces an offer the user can refuse. 091 wins keys 4 and 5 (more contained, four findings from four runners), but silence outranks both. Beat **TASK-068** — the pool's only remaining P1 — on key 1: 068 is a missing *practice*, not a wrong *result*, and key 4 disfavours it further since its "when is a drill warranted" test is an open judgement. **Noted against my own interest:** this session has minted `DRILL-035-*`, `DRILL-063-*`, `DRILL-093-*` and `DRILL-094-*` ids, so it has actively enlarged 068's unregistered-prefix half. That is an argument for doing 068 soon, not for reordering the keys. Key 6 inert — `correctness-invariants` throughout.
- step 3 — verified: both halves held. `LAYER.md:150` reads *"does anything **here** read runtime config from the environment?… and **any** component answering yes settles it"* — neither *here* nor *component* is scoped anywhere in the section, and `grep -c "build-time"` over the whole file returned **0**.
- step 4 — layer: local.
- step 5 — fix in `skills/new-project/LAYER.md` § *Conditional rows*, four paragraphs: **"here" is the surveyed git work tree and nothing outside it**, with the reason being what the answer is *for* (an artifact a sibling needs has no owner in this repo); an explicit **separation from § *CI a repo cannot pass***, which asks obtainability and answers *blocker* about the very same sibling tree this section calls irrelevant; **a repo with no components of its own answers *no*, settled rather than `unknown`**, because nothing that does not run can read runtime config — determined evidence, not merely-consistent evidence; and **a build-time variable does not satisfy the condition**, with `BIRKO_SRC` as the worked example and the three-runners-derived-it measurement as the justification. The `.env.example` row gains a pointer to both, not a copy.
- step 5a — **fixed a contradiction TASK-094 left one task ago, deliberately and out of scope.** That change corrected § *Covered means covered in the repo* from *"a file this repository tracks"* to *which file carries the line* (because "tracks" wrongly folded in the commit question), but left the `.gitignore` **row cell** still saying *"covered by a file the repo tracks"* — so the row contradicted the section it points at, and the row is what a survey reads first. One phrase, repaired here rather than filed: leaving a known contradiction in shipped prose to preserve a task boundary is the wrong trade, and a task for it would be longer than the fix. Recorded against TASK-094 as well, since that is where a reader would look for the history.
- step 6 — reverted fix: textual split is unambiguous — pre-change `grep -c "build-time"` over `LAYER.md` returned **0** and the section scoped neither *here* nor *component*; post-change both are stated. But the load-bearing evidence is that **three runners each derived the env-var rule from scratch and logged it as an inference**, which is a stronger demonstration that it was unreadable than any grep. Both halves are prose, so the drill is the guard.
- step 6a — **fixture contamination, stated rather than worked around.** My own new prose fingerprints the aggregator it measures — *"root holds only `docs/` and `tasks/`"* plus *"343 projects"* identifies exactly one repo in this fleet, and the same sentence reports that *"its runner scoped 'here' to the adopted repo, reached the right states"*. So a drill of that repo cannot independently confirm the **answer**. It can still test what I actually need: **whether a runner has to *decide***. Nothing in the prose tells a reader they will not have to, so the asymmetry is usable — a runner still listing scope under *"points the instructions left me to decide"* is a **conclusive failure**, while its absence is only weak-positive. Recorded so nobody later reads a pass here as strong evidence. Item 2's fixture is clean: `WorkoutTracker` is named in `LAYER.md` for the guide-section negative control and the vintage rule, **neither of which is this question**, and no repo is named for the build-time rule (the prose says "every repo in this fleet"). Both briefs withhold *here*, *scope*, *component*, *env*, *build-time*, `.env.example` and *not applicable*, and both ask for the decided-for-me list as a **separate** section from the had-to-decide list — the pairing is what makes an absence meaningful rather than merely unmentioned.
- step 8b — **drill 1 (aggregator scope): passed, in the strongest available form.** The scope question moved out of the runner's *"points the instructions left me to decide"* list and into *"questions the instructions DID settle for me"* — all three new rules quoted there, with the CI separation called *"the single most useful sentence on the page for this repo"* and this note: *"It told me to reach opposite conclusions from one fact — 343 escaping paths ⇒ CI blocked, and the same 343 ⇒ no evidence about Docker or env config — **which I would otherwise have agonised over or, worse, collapsed.**"* The settled-no rule landed too: *"Without it, a repo whose entire content is docs and tasks is the most natural `unknown` in the world."* Contamination caveat from step 6a holds — the runner did recognise itself (*"this repo, and the count still matches"*), so the **answer** was partly given; what the asymmetry tested is that scope no longer appears under had-to-decide, and that came back clean.
- step 8c — **drill 1 also found a conflict this change created, fixed inline.** I scoped the "here" rule inside § *Conditional rows*, but § *Detect what the repo has* tells the harness row to count `*.Tests` files **anywhere** and calls sibling `X.Tests` projects *the* .NET convention. Two sentences in one file pulling opposite ways for a non-conditional row; the runner spotted it, resolved to `present, elsewhere`, and flagged that *"nothing in the text says a solution file's references count as harness evidence — that step is mine."* Both sentences are right and the distinction was unstated: **an out-of-root component never creates an obligation, and may still evidence a capability.** A conditional row asks *would this repo need us to create X?* — a sibling's needs cannot create an obligation here. The harness row asks *does this repo already have a working Y?* — and a parallel test tree this repo's own solution registers **is** its harness, where a false `missing` would invite [[populate-tests]] to wire a second runner over a working one. Stated in the same paragraph now.
- step 8d — **drill 2 (build-time env var): item 2 NOT satisfied, and the failure was worth more than a pass.** Two separate results. (i) **The build-time rule itself is confirmed working** — the runner listed it under settled-for-me: *"Without this I would have taken `Reps.Web/build.js:18`'s `process.env.BIRKO_SRC` as a straight Yes."* (ii) **But the fixture did not match the criterion** — item 2 specifies *a repo whose only environment variable is build-time*, and `WorkoutTracker` genuinely reads three at runtime (`ASPNETCORE_ENVIRONMENT`, `Reps__Seed__Enabled`, `REPS_BASE_URL`, all verified by hand, all optional with committed defaults). So it surveyed `unknown`, not `not applicable`, with extensive commentary — which does not falsify the rule, it tests a case the rule never covered. Re-drilling on `Latent`, whose only env var is `BIRKO_SRC`; item 2 stays unticked until that returns.
- step 8e — **drill 2 exposed a second gap in the same row and it is fixed here, deliberately, as same-root-cause rather than spawned.** The row's *condition* asked whether anything *reads* runtime config while the row's own *definition* of the artifact is *"the documented, valueless template of **required** env vars"* — so the condition over-triggered: a web app booting fine with nothing set, every value in committed `appsettings*.json`, still answered yes. The runner found the mismatch and reasoned past the text: *"What is unsettled is the row's own boundary, not my knowledge."* Fixed by aligning the condition with the definition — the row now reads *does anything here **require** an environment variable to run?*, with the required-vs-optional paragraph and the plain test *"would a new contributor be unable to run this without being told a value?"* Three stale quotations of the old wording were updated in the same pass; `grep` for the old phrasing now returns 0. **Recorded as an out-of-scope repair, not a new ticked criterion** — writing myself a criterion after the fact to match work I had already done is the reverse of what acceptance criteria are for.
- step 8f — **spawned TASK-097** for the part that is *not* this row's business: `unknown` is the only container for two different situations — *evidence ran out* (a user can answer) and *the rule ran out* (only an amendment can). The runner named it exactly: *"`unknown` is the wrong-shaped container for that. I used it because it is the only non-laundering option on offer."* Left out because the fix needs a design decision weighed against TASK-085's finding that the state list has already outgrown its shape, and because the cheapest answer may be a reporting rule rather than a fourth state. **Also raised TASK-091 P3 → P2 on evidence**: DRILL-096-2 has two runners assigning opposite states to one unchanged `License.md`, each with sound reasoning — no longer a wording gap but a measured reproducibility failure, across five findings and three row kinds.
- step 8g — **drill 3 (`Latent`, build-time-only fixture): item 2 passed.** `.env.example` surveyed **`not applicable`**, reasoning straight off the row, and absent from the had-to-decide list. Both items now green; `in-progress` → `done`. Two findings spawned (TASK-097, TASK-098), one priority raised on evidence (TASK-091 → P2), two defects fixed inline in prose this change wrote (the obligation-vs-capability conflict, and three stale quotations of the reworded condition).
