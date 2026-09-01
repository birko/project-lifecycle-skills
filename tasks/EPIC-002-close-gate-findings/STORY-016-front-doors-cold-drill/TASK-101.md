---
id: TASK-101
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-098-1]
pr: null
github-issue: null
jira-key: null
---

# Two rows read one fact in opposite directions, because "a working runner" names no bar

## Context

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

### It also marks a limit in TASK-097's `unknown` split, which is why this is P2

The runner reached for the rule-ran-out `unknown` and correctly could not use it:

> *"This is the closest I came to a rule-ran-out `unknown`, and I deliberately did **not** claim it: the
> **artifact's** state is not in doubt, only the row's **terminating predicate**, and `LAYER.md` scopes that
> state to the artifact. Worth raising upstream as a row that could name its own bar."*

That is exact. TASK-097 gave an unsettled **row condition** a route upstream by attaching it to the
artifact's state. A row's *terminating predicate* — the clause that ends a delegation — is unsettled in the
same way and has **no** channel at all, because the artifact is not in doubt. So the reporting rule that
task installed is one case short, and this is the second case rather than a repeat of the first.

### What the fix probably is, and one thing to be careful of

`working` most plausibly means **the repo has a runner it already uses**, not *a runner that would pass on a
clean CI machine* — the row's whole purpose is to avoid wiring a second harness over a working one, and
whether a build succeeds in isolation is what the CI row exists to answer separately. Say that, and the two
rows stop contradicting each other because they were never asking the same question.

**Be careful not to require execution.** A bar of *observed green run* would make every read-only survey
report `unknown`, and would have adoption building consumer repos as a side effect of surveying them. The
existing evidence ladder is deliberately a ladder of observable artefacts; the bar should sit on it.

## Acceptance criteria

- [ ] The test-harness row states what **working** means, and it is a bar a survey can meet without executing a build
- [ ] The harness row and § *CI a repo cannot pass* no longer read one fact in opposite directions — either by scoping the two questions apart explicitly, or by cross-referencing so a reader meets both
- [ ] Where the row's own terminating predicate cannot be settled, there is somewhere for that to go — extending TASK-097's rule-ran-out route to a **row predicate**, or a stated reason it stays out
- [ ] The cost-asymmetry inversion is either licensed in the row (*here, do not fire when unsure, because the action wires a duplicate*) or removed
- [ ] Layer parity: the rule lands in `LAYER.md`, which both front doors read
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The CI row's own verdict. `$(BirkoSrc)` blocking a runner is correct and settled; this is about the harness row reading the same fact.
- Whether adoption should ever execute a test suite. It should not, and this task must not make that the bar.
- The `unknown` split itself — **TASK-097** settled the artifact-state case; this asks whether a row predicate needs the same route.

## Human test plan

- [ ] Cold-drill a consumer whose build cannot resolve in isolation, expected answers withheld, and confirm the runner reports both rows without listing the harness predicate as something it had to decide
- [ ] Confirm a repo with no test runner at all still reaches the `populate-tests` delegation

## Implementation plan

_Populated by `/tasks plan TASK-101` — leave empty until then._
