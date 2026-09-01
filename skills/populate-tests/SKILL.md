---
name: populate-tests
description: Populate and maintain a project's automated tests and its manual coverage ledger, on any stack. Use when the user says "/populate-tests", "author tests", "add test coverage", "generate e2e/integration tests", "populate tests for module X", "fill in the test checklist", "what's untested", or wants to turn a manual test checklist into automated specs. Reads the project's CLAUDE.md § Testing convention to learn the stack, test framework and layered model (generated smoke → authored happy-path flows → manual-judgement ledger), then surveys coverage gaps, authors grounded tests per surface (reusing the project's own test toolkit — Playwright, xUnit, vitest, pytest, …), verifies + triages them (pass / graceful-skip / quarantine real bugs), and keeps each surface's [auto]/[manual] ledger current. Fans out via the Workflow tool for scale and integrates with the feature lifecycle and tasks.
---

# populate-tests

Populate and maintain a project's tests + manual coverage ledger, on any stack. Sibling to
[[new-project]] (seeds the testing convention), [[feature]] (acceptance criteria), [[tasks]] (done-gate).

## First, always: read the convention

Read the project's `CLAUDE.md` § Testing (the layered model [[new-project]] seeds). Learn: the stack +
test framework, where tests live (`tests/`), the layers, the done-gate. No § Testing? Infer the stack
from the repo and offer to seed the convention first (use the [[new-project]] template). **Never author
tests for code you haven't read — that produces brittle, wrong tests.** Ground every selector/API/field
in real source.

## The layered model (what you populate)

1. **Generated smoke** — sweep every surface (route / screen / endpoint) for "it loads, no errors".
   Derive the surface list from the app's **own manifest/router** so it stays self-maintaining. Highest
   ROI, ~zero upkeep — do this first.
2. **Authored happy-path flows** — a few hand-written E2E/integration flows per important entity
   (create → … → delete), reusing the project's test toolkit + shared page objects.
3. **Manual-judgement ledger** — only what a human must eye (copy reads naturally, layout/feel, visual).
   A per-surface `[auto]`/`[manual]` checklist.

## Modes

`/populate-tests [adopt|survey|populate|verify|ledger] [scope]` (bare = survey).

- **adopt** — **wire the test harness** if the project doesn't have one yet (idempotent). Detect the
  stack, then scaffold what `populate` needs: the test dir, the runner config, and a pinned dev-dep on
  the runner. If the project's `CLAUDE.md` § Testing names a **shared/in-house test toolkit**, follow
  that toolkit's own adoption doc to wire it (the project layer owns those specifics — keep this skill
  stack-agnostic). Re-running is a no-op when the harness already exists. **Read [REFERENCE.md](REFERENCE.md)
  § Adopt before wiring** — it carries the harness invariants (single runner instance, supported runtime,
  module mode, ignores). `survey`/`populate` call `adopt` first when no harness is found; a project's
  scaffolder can invoke it too.
- **survey** — list surfaces (from the manifest/router/endpoint map) vs what's tested; report gaps as a
  table: surface → tested? → layer. No edits.
- **populate** — per untested surface: ground in real source (page model, required filters, schema,
  delete pattern), author a spec from the project's pattern + toolkit. For web apps, author/refresh the
  **generated route-smoke** from the app's manifest.
- **verify** — run the suite (serially or low parallelism to spare dev servers) and triage each result:
  **pass** / graceful **skip** (missing seed data — never hang or red) / **quarantine + file a bug task**
  (real app bug). Never loosen an assertion to hide a failure. **A guard that cannot reach its subject
  is worse than a missing guard** — it reads as covered. When a test fails *upstream* of what it
  asserts (a feature toggle off, a missing fixture, a 404 before the interesting call), fixing the
  precondition is only half the job: prove the assertion can still fail (below), then check whether
  sibling tests share that precondition. (Real failure this guards: ~22 authz tests whose
  `expect([401, 403])` was being satisfied by a module-disabled 403, never once by the permission
  check they claimed to cover.) **Run it against a disposable/seeded test
  environment, never dev or production data** — live-API/DB suites (an in-house E2E toolkit's
  CRUD flows) really create/update/delete. If only a shared/prod-ish stack is reachable, run the
  read-only smoke and say so rather than mutating real data.
- **ledger** — fill/refresh each surface's manual checklist: collapse generic "renders / CRUD / no
  errors" items to `[auto]` (name the spec), keep only human-judgement as `[manual]`.

## Fan out for scale

For many surfaces, use the **Workflow** tool — one agent per surface (ground → author → verify) — but
**only with explicit user opt-in** (it spawns many agents; large token spend). Otherwise go
surface-by-surface inline. **Pre-fix any shared toolkit/helper yourself** before fanning out, so parallel
agents don't collide on the same file. Run authored tests in a **single serial verification pass** (not
N parallel test runs) to avoid thrashing a dev server / racing shared auth state.

## Prove the guard can fail

**A passing test is not evidence — a passing test that cannot fail is decoration.** Every test written
to pin a specific defect earns one of these before it counts, and it takes a minute:

- **Revert-and-split** (unit / integration, where the fix is a small diff). Stash *only the production
  change* and re-run. Then account for the result **exactly**:
  - every test you believed was fix-dependent must be in the failure list;
  - every test still passing is a **contract pin, not evidence** — say so, by name, wherever you're
    recording the work. Don't let it read as proof;
  - a test you expected to fail that passed is a finding about your **test**, not about the fix: it
    isn't asserting what you thought. Fix the test before continuing.
- **Reintroduce-and-confirm** (E2E / UI, where stashing means a rebuild anyway). Put the bug back on
  one file, rebuild, confirm the spec goes **red**, then restore and rebuild. A spec whose trigger
  doesn't actually reproduce the bug — a filter change that refreshes a table but never re-runs the
  code path — is a **false guard**; find the trigger that does.
- **Bidirectional assertion** — assert the correct value is present *and* the buggy value is absent.
  Self-evidently a guard, no second run needed. Cheapest option when it fits.

This is the same instinct as *don't fake green*, pointed at the other failure mode: not a real failure
hidden by a loosened assertion, but a real fix unprotected by a test that was never able to catch it.
[[fix-next]] runs this as a required step; [[tasks]] `close` requires it before an automated check can
retire a `[manual]` ledger line.

## The cold drill — the one test method that works on prose

Layer 3's `[manual]` lines exist because a human must eye something. **A repo whose product *is* prose —
instructions an agent reads — has a fourth case, and neither automation nor eyeballing reaches it.** The
failure mode there is not a crash: it is a sentence that carries its meaning only for someone who already
knows the intent. **The author cannot test for that, because they cannot un-know the intent.**

So the instrument is a **cold drill**: hand the changed instructions to a reader who has not seen the
change, have them *execute* the instructions against a real target, and report where the prose led them.

**The mechanism is withholding the answer, and it is the whole mechanism.** A `## Human test plan` says
*"confirm the survey reports `not applicable`"* — handed to a runner verbatim, that converts the test into a
confirmation: the runner knows the target and reports hitting it. **The plan and the brief are two different
documents**, and that distinction is the method:

| | The `## Human test plan` | The drill brief |
|---|---|---|
| Written for | the author, and the record | the runner |
| States the expected outcome | **yes** — that is what makes it checkable | **never** |
| Asks | *confirm X* | *carry out the steps and report what you concluded* |

### The brief's shape — five asks, and five things they do not cover

1. **Execute, don't evaluate.** *"Follow these instructions against this target and report where they led
   you"* — not *"is this skill any good"*. A runner asked to critique writes criticism; one asked to execute
   produces evidence.
2. **Ask for the outcome in the instructions' own terms** — the table it was told to print, the states it
   assigned, the questions it would ask — and never name the value you expect.
3. **Ask what the instructions left undecided**, quoting the sentence.
4. **Ask what had to be inferred** rather than read off a file or a rule.
5. **Ask what it read that nothing sent it to.**

**Rows 3 to 5 are where the yield is, and they are the rows most likely to be dropped.** Measured: they are
what produced the defects, repeatedly, including defects *in the change being drilled*. Row 3 paired against
its inverse — *"and separately, what did the instructions settle for you that you would otherwise have had to
work out"* — is stronger still, because an absence in one list only means something beside the other.

**These are prompts to include, not text to paste** — and a drill of this very section found five gaps in
them, each of which the runner had to invent before it could write a usable brief. They are load-bearing:

1. **Bar the lookup; do not assume it.** *"A reader who has not seen the change"* describes a starting
   state, not a prohibition — and it **expires at the first `git log`**. Say plainly: no diffs, no history,
   no task notes, no planning docs. Row 5 then audits whether that held.
2. **A setup step can leak the axis by itself, and the withholding rule above does not cover it.** A plan
   that says *"make an unrelated edit, staged and again unstaged"* announces that staged-versus-unstaged is
   the subject, and the state cannot be built without saying so. The workable line: **give provenance
   mechanically, never the classification** — *"a file the tooling created"* and *"a file you wrote
   yourself"*, never *"an unlanded artifact"* and *"user work in progress"*, which are the verdict.
3. **Say what to do with a question the instructions raise.** Where the prose has the runner *ask* the user
   something, a runner who actually asks either stalls or is handed the answer. Tell it to **write the
   question out verbatim and continue as if unanswered** — often the question *is* the finding.
4. **Matching the report back to the plan is the author's step, and it is where honesty is spent.** The plan
   states outcomes and the brief must not, so nobody but the author can tick the boxes. That is also where a
   discounted or weak-evidence result must stay unticked rather than ticked with a caveat beside it — a
   caveat disappears, an unticked box does not.
5. **A fresh agent with no prior context is runner enough.** Tell it that it is running a drill; withhold
   only the change. Concealing the exercise buys nothing, concealing the change is the entire mechanism.

### Choosing a target, which is harder than it looks

**A rule that cites a named file in a named repo cannot be drilled on that repo** — the instructions have
already adjudicated the case, so the runner's judgement is not independent. Measured repeatedly: a change
that justified itself with three named repos disqualified all three as fixtures for its own drill, and one
measurement fingerprinted its fixture so precisely (*"holds only `docs/` and `tasks/`… 343 projects"*) that
the runner recognised itself.

Three corollaries, each measured:

- **Contamination is per *question*, not per repo.** A repo named for its guide can still drill an unrelated
  row. Say which question is contaminated and discount that part of the report.
- **The strongest form is an A/B on one unchanged target** — drill it before the change and after. Same
  input, opposite outcome, and nothing else can move.
- **A contaminated drill can still produce a conclusive *negative*.** If the runner still reports having to
  decide, the fix failed, whatever it guessed about the answer. Use the asymmetry deliberately and say that
  a pass there is weak evidence.

**Prefer a real target to a fixture you built.** A fixture tests the author's model: one built to defeat
source discovery simply failed to — the runner read the README and recovered.

**Leave the target as you found it.** A real target usually has someone's uncommitted work in it — measured
across this fleet, four of five consumer repos did — so a drill that must dirty the tree runs on a **clone or
worktree**, and a drill that only needs to *read* is told read-only in the brief and never stages, commits or
edits anything. A clone with real history is still a real target; the git state the drill sets up is its
**input**, not a fabricated repo.

**But a clone drops every uncommitted and untracked file, which is exactly what some drills are about.**
`git clone` copies history, not a working tree — so the state you deliberately construct arrives and *all
other* in-flight state silently does not. A runner reasoning from that absence reports a defect that does
not exist. Measured: a drill on a cloned consumer reported that a filed task *"describes a repo state that
does not exist"* — the `.claude/` directory it cited was untracked and the `.gitignore` block it quoted was
uncommitted, so both were real in the source repo and neither survived the clone. What saved it was that the
runner had flagged its own reasoning as an inference.

**So when a drill's subject is uncommitted state, say in the brief what the checkout is** — that it is a
clone, and that the absence of any *other* in-flight work is an artefact of cloning rather than evidence
about the repo. Without that line the fixture manufactures findings, and they look exactly like real ones.

### When it is warranted, and when it is over-ceremony

It costs one runner, several minutes, and a brief that must be *written* rather than pasted. **That is not
free and it is not always right.**

| Drill it | Don't |
|---|---|
| the change **adds or rewrites a rule** a reader must apply | a typo, a link, a rename, a deletion |
| the rule has a **branch** — states, conditions, an ordering | prose that only restates something already true |
| getting it wrong is **silent** — a clean-looking report, a laundered state | a change whose failure is loud, or one a lint already pins |
| the change **cites its own justification** and you cannot tell whether the prose or the example is doing the work | a change whose test is mechanical: a link resolves, a count matches, a case fails without the fix |

**The test in one question:** *could a careful reader, without knowing what I intended, reach a different
answer than the one I intended?* If no, a drill tells you nothing you don't have. If you cannot tell — drill
it; that uncertainty is the condition.

**Expect the drill to find something in the change itself.** That is the normal outcome, not the alarming
one, and it is the strongest argument for the cost.

**This does not replace anything.** § *Prove the guard can fail* still governs a regression test, and
[[tasks]] `close` step 5's *automate before you accept a manual step* still applies first: a drill is what a
step that stays manual gets, never a reason to leave a mechanisable check unautomated.

## Transferable principles (learned the hard way)

- **Single test-runner instance** — the runner (Playwright/vitest/…) must be ONE copy reachable by both
  the specs and any shared helper package; two copies break test registration. A source-linked helper
  package must have the runner **injected**, not import its own.
- **No-hang selectors** — bound every wait; fail fast on missing/empty, never the full test timeout.
- **Scope to the open thing** — when ids repeat across shadow roots/components (`#modal`, `.btn-confirm`),
  assert the *open* element (`dialog[open] …`), not the bare id.
- **Graceful skip on missing seed data** — `test.skip(reason)` beats a hang or a red. A skip with a clear
  reason is honest coverage, not a gap hidden.
- **Isolated test environment** — suites that drive a live API/DB must point at a disposable target
  (throwaway DB/tenant, dedicated test account), never dev/prod. Default origins/creds to `localhost`,
  make mutating specs create→assert→delete + clean up, and guard CI off any production host.
- **Generated smoke from the app's own manifest** — don't hand-maintain a route list; read the one the
  router is built from.
- **Don't fake green** — a real app bug → quarantine + file a task; never weaken the assertion. (The
  payoff of populating tests is the bugs they surface.)
- **Even-numbered LTS / supported toolchain** — pin the test runner + runtime to versions it actually
  supports; bleeding-edge runtimes break test loaders.

## Integrate

- Update each `docs/features/FEATURE-*/` acceptance section as coverage lands ([[feature]]).
- File bugs found as `tasks/` items; satisfy the done-gate "tests green AND manual checks run" ([[tasks]]).
- **Close the loop on field-found bugs too.** A bug reported from production — not just one this
  suite surfaces — earns a regression spec here before its fix is `done`, so it can't recur. Same
  "quarantine becomes a permanent spec" rule, pointed at the field. This is the backflow that
  makes the pipeline a loop ([[tasks]] § field feedback, [[feature]] reopened decisions).

## More

**Read [REFERENCE.md](REFERENCE.md) before `adopt` or `populate` work** — it holds the operational detail
this file only summarizes: per-stack toolkit table, adopt invariants, generated-smoke derivation per app
kind, the grounding checklist for authored flows, self-seeding prerequisites (idempotent API seeding,
scoping headers), verify/triage buckets, the fan-out workflow shape, and the manual-ledger format.
