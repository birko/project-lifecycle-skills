---
id: TASK-072
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-23
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-2b, DRILL-098-1]
pr: null
github-issue: null
jira-key: null
---

# `populate-tests adopt` cannot wire a harness for a project with no package manager

## Context

**Spawned from TASK-062's out-of-scope sweep on 2026-08-23.** That bullet was conditional — *"widening
`populate-tests`' own stack detection. If it shares the assumption, spawn it."* It does, so here it is.

TASK-062 fixed `LAYER.md`'s evidence ladder, which decides **whether** a repo has a test harness. This is
the other half: what `populate-tests` does when the answer is *no*.

`skills/populate-tests/SKILL.md`'s **adopt** mode reads:

> **adopt** — **wire the test harness** if the project doesn't have one yet (idempotent). Detect the stack,
> then scaffold what `populate` needs: the test dir, the runner config, and **a pinned dev-dep on the
> runner**.

All three deliverables presume a **package manager**: a dev-dep needs a manifest and a lockfile, a runner
config needs a runner to configure. A project whose checks are a shell script invoked by CI — this repo's own
shape — has none of them, and the skill has nothing to say about that case.

**Why the exposure is narrower than it looks, and why it is still real.** With TASK-062's fix the ladder now
reports this repo `present`, and the row's terminating condition (*"a repo with a working runner is already
adopted — say so and move on"*) stops the invocation. So the *combination* that would have misfired is
closed. What remains is a genuine greenfield case: a **docs-only or prose project with no CI yet** asks for a
harness, and `adopt` mode's only recipe is one it cannot follow. Measured during TASK-062's step-6 check —
the `drill-a` fixture (docs-only, no tests, no CI) correctly reports `missing`, and `missing` is exactly what
routes to this mode.

**The interesting question is what "a harness" even means there**, and it should be answered rather than
assumed. For a prose repo the honest answer may be *a script plus a CI step that runs it* — which is what
this repo actually built, and what `LAYER.md` now recognises as evidence. If so, `adopt` mode's recipe gains
a fourth shape rather than a special case. Do not reach for a package manager the project does not want.

### Merged in 2026-09-26: TASK-101 — Two rows read one fact in opposite directions, because "a working runner" names no bar

_Merged because both are the test-harness row: what a working runner is, and wiring one without a package manager. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-101.md`._

**From the 2026-09-01 cold drill of `adopt-project` on `Latent`.**

The test-harness row terminates its own delegation with:

> *"A repo with a working runner is already adopted — say so and move on."*

Nothing says what **working** is measured against, and on a Birko consumer the omission produces two rows
reading one fact in opposite directions:

| Row | Same fact | Verdict |
|---|---|---|
| CI gate | the build imports `$(BirkoSrc)\…`, which resolves outside the repo root and no runner can obtain | `missing, not offered` — *this cannot build on a runner* |
| Test harness | the same imports | *"a working runner — already adopted, move on"* |

The runner named it precisely:

> *"What is unsettled: what 'working' is measured against. … It bites here specifically, because this repo's
> build depends on `$(BirkoSrc)` escaping the root — the very fact that makes the CI row
> `missing, not offered`. So the two rows lean opposite ways on one fact."*

It resolved to `present` and did not delegate, on a cost-asymmetry argument worth keeping: `populate-tests
adopt` **wires a runner**, and wiring a second one over two registered xUnit projects with 24 test
attributes and compiled assemblies on disk is the false-`missing` fill this inventory calls the dangerous
direction. That is almost certainly right — but note it **inverts** the standing *when you cannot tell, the
action fires* rule, and the row gives no licence for the inversion.

#### It also marks a limit in TASK-097's `unknown` split, which is why this is P2

The runner reached for the rule-ran-out `unknown` and correctly could not use it:

> *"This is the closest I came to a rule-ran-out `unknown`, and I deliberately did **not** claim it: the
> **artifact's** state is not in doubt, only the row's **terminating predicate**, and `LAYER.md` scopes that
> state to the artifact. Worth raising upstream as a row that could name its own bar."*

That is exact. TASK-097 gave an unsettled **row condition** a route upstream by attaching it to the
artifact's state. A row's *terminating predicate* — the clause that ends a delegation — is unsettled in the
same way and has **no** channel at all, because the artifact is not in doubt. So the reporting rule that
task installed is one case short, and this is the second case rather than a repeat of the first.

#### What the fix probably is, and one thing to be careful of

`working` most plausibly means **the repo has a runner it already uses**, not *a runner that would pass on a
clean CI machine* — the row's whole purpose is to avoid wiring a second harness over a working one, and
whether a build succeeds in isolation is what the CI row exists to answer separately. Say that, and the two
rows stop contradicting each other because they were never asking the same question.

**Be careful not to require execution.** A bar of *observed green run* would make every read-only survey
report `unknown`, and would have adoption building consumer repos as a side effect of surveying them. The
existing evidence ladder is deliberately a ladder of observable artefacts; the bar should sit on it.

## Acceptance criteria

- [ ] `adopt` mode states what it does for a project with **no package manager** — either a recipe it can actually follow, or an explicit statement that it declines and why
- [ ] Whatever it produces is recognised by `LAYER.md`'s ladder as evidence, so the two skills agree about what counts as a harness — the fix and the detector must not drift apart
- [ ] The three current deliverables (test dir / runner config / pinned dev-dep) are marked as the **package-manager** recipe rather than reading as universal
- [ ] The docs-only case is stated explicitly: a project with nothing to test yet is not a gap, and adopt mode should say so rather than scaffolding an empty runner — the same *would-lie-when-empty* reasoning as the layer's `(lazy)` rows
- [ ] `bash .github/workflows/skills-lint.sh` passes

*From TASK-101:*

- [ ] The test-harness row states what **working** means, and it is a bar a survey can meet without executing a build
- [ ] The harness row and § *CI a repo cannot pass* no longer read one fact in opposite directions — either by scoping the two questions apart explicitly, or by cross-referencing so a reader meets both
- [ ] Where the row's own terminating predicate cannot be settled, there is somewhere for that to go — extending TASK-097's rule-ran-out route to a **row predicate**, or a stated reason it stays out
- [ ] The cost-asymmetry inversion is either licensed in the row (*here, do not fire when unsure, because the action wires a duplicate*) or removed
- [ ] Layer parity: the rule lands in `LAYER.md`, which both front doors read
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `LAYER.md`'s detection ladder — **TASK-062**, closed. This task is what happens after detection says `missing`.
- Authoring actual tests for any project. This is harness wiring only.
- The `[auto]`/`[manual]` ledger and *Prove the guard can fail* — those are `populate-tests`' other halves and are stack-agnostic already.

*From TASK-101:*

- The CI row's own verdict. `$(BirkoSrc)` blocking a runner is correct and settled; this is about the harness row reading the same fact.
- Whether adoption should ever execute a test suite. It should not, and this task must not make that the bar.
- The `unknown` split itself — **TASK-097** settled the artifact-state case; this asks whether a row predicate needs the same route.

## Human test plan

- [ ] Run `populate-tests adopt` against a throwaway docs-only repo with no manifest and no CI, and confirm it either wires something runnable or declines with a reason — never leaves a half-scaffolded runner
- [ ] Confirm whatever it wires is then reported `present` by `adopt-project`'s survey, so the two skills agree
- [ ] Run it against a conventional stack (a `dotnet new` or `npm init` project) and confirm the ordinary recipe is unchanged

*From TASK-101:*

- [ ] Cold-drill a consumer whose build cannot resolve in isolation, expected answers withheld, and confirm the runner reports both rows without listing the harness predicate as something it had to decide
- [ ] Confirm a repo with no test runner at all still reaches the `populate-tests` delegation

## Implementation plan

_Populated by `/tasks plan TASK-072` — leave empty until then._
