---
id: TASK-072
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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
picked-by: fix-next
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

- [x] `adopt` mode states what it does for a project with **no package manager** — either a recipe it can actually follow, or an explicit statement that it declines and why
- [x] Whatever it produces is recognised by `LAYER.md`'s ladder as evidence, so the two skills agree about what counts as a harness — the fix and the detector must not drift apart
- [x] The three current deliverables (test dir / runner config / pinned dev-dep) are marked as the **package-manager** recipe rather than reading as universal
- [x] The docs-only case is stated explicitly: a project with nothing to test yet is not a gap, and adopt mode should say so rather than scaffolding an empty runner — the same *would-lie-when-empty* reasoning as the layer's `(lazy)` rows
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-101:*

- [x] The test-harness row states what **working** means, and it is a bar a survey can meet without executing a build
- [x] The harness row and § *CI a repo cannot pass* no longer read one fact in opposite directions — either by scoping the two questions apart explicitly, or by cross-referencing so a reader meets both
- [x] Where the row's own terminating predicate cannot be settled, there is somewhere for that to go — extending TASK-097's rule-ran-out route to a **row predicate**, or a stated reason it stays out
- [x] The cost-asymmetry inversion is either licensed in the row (*here, do not fire when unsure, because the action wires a duplicate*) or removed
- [x] Layer parity: the rule lands in `LAYER.md`, which both front doors read
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `LAYER.md`'s detection ladder — **TASK-062**, closed. This task is what happens after detection says `missing`.
- Authoring actual tests for any project. This is harness wiring only.
- The `[auto]`/`[manual]` ledger and *Prove the guard can fail* — those are `populate-tests`' other halves and are stack-agnostic already.

*From TASK-101:*

- The CI row's own verdict. `$(BirkoSrc)` blocking a runner is correct and settled; this is about the harness row reading the same fact.
- Whether adoption should ever execute a test suite. It should not, and this task must not make that the bar.
- The `unknown` split itself — **TASK-097** settled the artifact-state case; this asks whether a row predicate needs the same route.

## Human test plan

- [x] Run `populate-tests adopt` against a throwaway docs-only repo with no manifest and no CI, and confirm it either wires something runnable or declines with a reason — never leaves a half-scaffolded runner
- [x] Confirm whatever it wires is then reported `present` by `adopt-project`'s survey, so the two skills agree
- [x] Run it against a conventional stack (a `dotnet new` or `npm init` project) and confirm the ordinary recipe is unchanged

*From TASK-101:*

- [x] Cold-drill a consumer whose build cannot resolve in isolation, expected answers withheld, and confirm the runner reports both rows without listing the harness predicate as something it had to decide
- [x] Confirm a repo with no test runner at all still reaches the `populate-tests` delegation

**All five steps passed 2026-11-13** in three cold drills under `%LOCALAPPDATA%/Temp/d072`, each with `skills/` at
this fix and its brief and report kept there. All three runners had no skills listed and no Skill tool.
- **Drill A, `a/`.** A full adoption of a fresh `d065/adopted`, a Python script with no manifest, using the d065b
  full brief.
  - It reached the harness delegation (step 5 of the plan): the row was `missing`, and every rung was empty.
  - It wired `pytest.ini`, `tests/__init__.py` and `tests/README.md`, and created no `requirements-dev.txt`.
  - It printed `harness wired: pytest 8.x — pin documented, not enforced (no package manager)`. The README carries
    the one-time prerequisite.
- **Drill B, `b/`.** `/populate-tests adopt` on two invented repos.
  - **`docsrepo/`** (Markdown only) printed `nothing to test yet — no harness wired` and created no files (step 1).
  - **`npmrepo/`** (`package.json`, no runner) got vitest pinned in `package.json`'s `devDependencies`, a config,
    `tests/` and a README. That is the ordinary recipe, unchanged (step 3).
- **Drill C, `c/`.** A scoped survey of drill A's result, and of `dotnetrepo/`: a `src/` project and an xunit
  `tests/` project, both importing `$(BirkoSrc)\Birko.Build\Common.props`.
  - A's harness was `present` (uncommitted), read off its runner-config rung (step 2).
  - `dotnetrepo`'s harness was `present` (the xunit manifest rung), and its CI was `missing, not offered`, naming
    `$(BirkoSrc)`.
  - The runner quoted the row's "a repo can be `present` here and `missing, not offered` there with no
    contradiction", and did not list the harness predicate as undecided (step 4).
  - Both repos were unchanged afterwards.

**Readings these drills raised, compared against every other drill this session:**
- **Filed as TASK-360:** C's point 6, the round exceeding five questions with workspace depending on integration.
  d353 raised it too, so two runners.
- **Already TASK-356:** C's points 5 and 7.
- **Recorded here, one runner each, not filed:**
  - **A:** CI offered to a repo with no tests yet, whose first run `pytest` would fail with exit 5; and fills created
    after `specs init` that are not in the map's `ignore`.
  - **B:** the stack table has no plain-JS-library row; what "pinned" means as a version; how to pin the runtime;
    what counts as "the test dir"; whether adopt adds a test script or a placeholder test; which output dirs to
    ignore for vitest; the README's content in the package-manager recipe; the `<path>` slot in § Testing's question
    when nothing is testable.
  - **C:** an untracked runner config with no tests counting as working (the rule decided it, the runner questioned
    it); `owner not asked` composing with `uncommitted`; the adoption commit offer on a scoped run.

## Implementation plan

Written 2026-11-13 by `/fix-next` after the user's two decisions (Progress log).

1. **`populate-tests` `REFERENCE.md` § Adopt** gains a recipe table keyed on what the project already has:
   - **a package manager:** the current recipe, with the pin going in that manifest;
   - **source but no package manager:** a test dir and runner config, no manifest created, and the runner and its
     version written into the test dir's README as a one-time prerequisite, reported as "pin documented, not
     enforced";
   - **no source to test:** nothing wired, reported as `nothing to test yet`.
   A project whose checks are a CI script already has a harness by the ladder.
2. **`populate-tests` `SKILL.md`'s adopt bullet** points at that table rather than naming the package-manager
   recipe as universal.
3. **LAYER.md's harness row:**
   - "working" = any rung of § *Detect*'s evidence ladder, with nothing built or run;
   - the CI row answers a different question, so the two can differ without contradicting;
   - ladder unable to tell → `unknown`, a stated question in step 2's round, nothing wired with no answer (the
     inversion, licensed and explained);
   - no source → `missing, not offered: nothing to test yet`, re-derived every run.
   The row predicate needs no separate route: it reads the ladder, so it is unsettled only when the evidence is,
   and that is the evidence `unknown`.
4. **LAYER.md's detection ladder** adds `test_*.*`, pytest's default name. One runner (d354) raised it, and it is in
   this row.
5. **Respec** `project-baseline` (the harness row) and `test-authoring` (the adopt recipe).

## Outcome

**The fix (the user's two decisions, 2026-11-13, plus what the task's own Context argued).**
- **`/populate-tests adopt` picks its recipe by what the project already has:**
  - **a package manager:** pin the runner in that manifest, as before;
  - **code but no package manager:** wire the test dir and runner config, **create no manifest**, and write the
    runner and its version into the test README as a prerequisite, reported as "pin documented, not enforced";
  - **nothing to test:** wire nothing, and report `nothing to test yet`.
- **LAYER.md's harness row:**
  - **"working runner"** means any rung of the evidence ladder, with nothing built or run;
  - it **answers a different question from the CI row**, so `present` here and `missing, not offered` there is not
    a contradiction;
  - **when the ladder cannot tell**, the row is `unknown`, a stated question goes in the round, and nothing is wired
    without an answer (the inversion of "act when unsure", licensed and explained);
  - **a repo with no source to test** is `missing, not offered: nothing to test yet`.
- **The ladder now recognises pytest's `test_*.*` files.**

**Step-6 split.**
- **Text assertions:** 8 of 8 fail on `HEAD`'s copies and pass on the fix, all fix-dependent. The script is
  `task072-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** four runners on the old text (d065b/full, d354, d102, d102b) each created a `requirements-dev.txt`.
  - **After:** drill A created none, and drills B and C passed every plan step.
- **Contract pins, not evidence:**
  - skills-lint;
  - drill B's npm recipe, which shows the ordinary path unchanged, not the fix.

**Judgement calls.**
- **The two decisions were the user's:** no new manifest, and do not wire when unsure.
- **Settled without asking, because the task's own Context argued each and none trades anything away:**
  - "working" sits on the observable ladder, never on a run;
  - the CI and harness rows are scoped apart;
  - nothing to test is not a gap.
- **The row-predicate route (from TASK-101) is not added: stated why instead.** The predicate now reads the ladder, so
  it is unsettled only when the evidence is, and that is the existing evidence `unknown`.
- **The README is the prerequisite's home, not § Testing.** TASK-354 made chained verbs write nothing into an owned
  file. The guide gets it only through populate-tests' own § Testing question.
- **`test_*.*` was folded in** (one runner): it is the same ladder line, and pytest's default name.
- **Spec stamps:** `project-baseline` is restamped. `test-authoring` got its sentence, but its stamp stays for
  TASK-359.

**Close gate (inline, about 30 lines over three files):**
- **Standards:** layer parity holds. The row lives in LAYER.md, and `new-project`'s step-5 harness flows through the
  same `populate-tests` recipe. Every new ask states its question and its no-answer path.
- **Intent:** all eleven criteria met.
- **Correctness:** the § Testing write conflicted with TASK-354's rule, and was routed through the README before the
  drills.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-360**, the round overflow, filed from drill C plus d353.
- **One-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked; ranked first among the remaining STORY-016 tasks (correctness-invariants, key 6 inert) because four cold runners on 2026-11-13 (d065b/full, d354, d102, d102b) each had to invent where to pin a runner with no manifest and created a `requirements-dev.txt` the project never had: a wrong write into a user's repo on every full adoption of a manifest-less codebase (keys 1–2)
- step 3 — verified: held. REFERENCE.md's adopt recipe presumes a manifest ("Pin the runner as a dev-dependency"), LAYER's harness row says "a working runner" with no bar, and nothing states the docs-only case. Reproduced 2026-11-13 by four runners inventing `requirements-dev.txt`
- step <guardrail> — decisions put to the user (2026-11-13): (1) no package manager → no new manifest; wire the test dir and runner config, document the runner and version as a one-time prerequisite, report the pin as documented, not enforced; (2) unsure whether a runner exists → `unknown`, ask in the round, wire nothing. Recommendation taken on both. Settled without asking, as the task's own Context argues: "working" = a rung of the evidence ladder, no execution; the CI row and the harness row answer different questions; nothing to test → not a gap
- step 3b — planned: see Implementation plan
- step 4 — layer: local
- step 5 — fix in skills/populate-tests/REFERENCE.md (§ Adopt recipe table), skills/populate-tests/SKILL.md (adopt bullet points at it), skills/new-project/LAYER.md (harness row: working, CI scoping, unknown and its question, nothing to test; ladder adds `test_*.*`)
- step 6 — reverted fix (HEAD copies): 8/8 assertions failed; fix-dependent = G1–G8; contract pins = skills-lint. Behaviour: drills A (full adoption, manifest-less Python), B (populate-tests adopt on docs-only and npm) running; C (scoped survey of A's result and of a .NET repo escaping its root) after A
- step 7 — respecced project-baseline (fill-order requirement: the harness terminating condition) restamped, and test-authoring (adopt recipe), surgical, stamp left at 222c36d for TASK-359; intended — TASK-072 criteria and the user's decisions
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
