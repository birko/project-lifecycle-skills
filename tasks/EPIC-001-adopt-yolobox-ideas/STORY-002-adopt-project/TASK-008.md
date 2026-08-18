---
id: TASK-008
parent: STORY-002
feature: null
status: todo
priority: P1
assignee: unassigned
created: 2026-08-18
depends-on: [TASK-003]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The survey must detect what a repo has, not check for the seed's layout

## Context

Drilling seven real repos exposed one root cause behind several separate wrong answers: **the
survey looks for the exact paths and headings `new-project` would have created, and reports
anything shaped differently as absent.**

Concrete, both from clean repos:

- **WorkoutTracker** — reported `test harness MISSING`. It has **54 test files** across `Reps.Api.Tests/`, `Reps.Domain.Tests/`, and a Playwright e2e suite under `Reps.Web/tests/ui-e2e/`. The probe looked only for a top-level `tests/` directory. Sibling `X.Tests` projects are *the* .NET convention, so the survey is wrong on the majority of this team's repos.
- **BardStudio** — reported the rulebook incomplete because its guide has `## Key Conventions` rather than `## Conventions`. Not a translation problem; a two-word heading.

This is worse than a cosmetic miss. Adoption acts on the survey: "missing" invites filling, so a
repo with 54 tests could be offered a fresh harness, and one with a real rulebook could be told it
has none. **A false "missing" is the dangerous direction** — it leads to writing over a working
setup, which is exactly what the never-overwrite rule exists to prevent, arriving from underneath.

Same shape as the mis-cased wikilink and the literal `## Conventions` match: a check that
recognises only the canonical form and silently reports failure as absence.

## Acceptance criteria

- [ ] **Test harness** is detected by evidence, not path: a test runner in the manifest (xunit, vitest, pytest, go test), `*.Tests`/`*_test.*`/`*.spec.*` files anywhere, or a configured runner — before concluding a repo has no tests
- [ ] **Rulebook** detection is delegated to whatever TASK-006 settles for `verify-conventions`, so the two skills agree on what counts as a rulebook rather than each guessing
- [ ] The same principle is applied to every row of `LAYER.md`: docs may live somewhere other than `docs/`, a changelog may be `HISTORY.md`
- [ ] When something is found in a **non-standard location**, report it as *present, elsewhere* with the path — never as missing, and never silently relocate it
- [ ] A row the survey cannot decide is reported as **unknown**, not as missing. "I could not tell" is honest; "you don't have it" is a lie that invites a destructive fill
- [ ] Verified against all seven drilled repos: WorkoutTracker reports its tests, BardStudio its rulebook

## Out of scope

- Moving anyone's files into the canonical layout. The layer describes what a repo needs, not where it must live; a repo that solved it differently has *solved it*.
- The `verify-conventions` heading fix itself → TASK-006.

## Human test plan

- [ ] Re-survey all seven drilled repos; every "missing" must be genuinely absent, checked by hand
- [ ] Confirm a repo with tests in a non-standard location is never offered a new harness
- [ ] Confirm the report distinguishes present / present-elsewhere / unknown / missing

## Implementation plan

_Populated by `/tasks plan TASK-008`._
