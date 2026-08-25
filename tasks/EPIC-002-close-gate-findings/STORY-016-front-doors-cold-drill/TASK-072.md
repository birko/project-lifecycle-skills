---
id: TASK-072
parent: STORY-016
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-23
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-2b]
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

## Acceptance criteria

- [ ] `adopt` mode states what it does for a project with **no package manager** — either a recipe it can actually follow, or an explicit statement that it declines and why
- [ ] Whatever it produces is recognised by `LAYER.md`'s ladder as evidence, so the two skills agree about what counts as a harness — the fix and the detector must not drift apart
- [ ] The three current deliverables (test dir / runner config / pinned dev-dep) are marked as the **package-manager** recipe rather than reading as universal
- [ ] The docs-only case is stated explicitly: a project with nothing to test yet is not a gap, and adopt mode should say so rather than scaffolding an empty runner — the same *would-lie-when-empty* reasoning as the layer's `(lazy)` rows
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `LAYER.md`'s detection ladder — **TASK-062**, closed. This task is what happens after detection says `missing`.
- Authoring actual tests for any project. This is harness wiring only.
- The `[auto]`/`[manual]` ledger and *Prove the guard can fail* — those are `populate-tests`' other halves and are stack-agnostic already.

## Human test plan

- [ ] Run `populate-tests adopt` against a throwaway docs-only repo with no manifest and no CI, and confirm it either wires something runnable or declines with a reason — never leaves a half-scaffolded runner
- [ ] Confirm whatever it wires is then reported `present` by `adopt-project`'s survey, so the two skills agree
- [ ] Run it against a conventional stack (a `dotnet new` or `npm init` project) and confirm the ordinary recipe is unchanged

## Implementation plan

_Populated by `/tasks plan TASK-072` — leave empty until then._
