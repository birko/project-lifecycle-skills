---
id: TASK-009
parent: null
feature: null
status: todo
priority: P3
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# verify-conventions has no rule about generated and vendored files

## Context

Spawned from the TASK-006 verification, not part of it.

Symbio's live working diff is four files: `index.html` (cache-busting hashes), `sw.js`,
`wwwroot/app.js` and `wwwroot/app.js.map`. Three are **build output**. Linting a bundled
`app.js` against naming or structure conventions produces noise at best, and at worst
findings against code no human wrote and nobody can act on.

`skills/verify-conventions/SKILL.md` says nothing about this. It lints "each changed file",
so generated output is in scope by default — and generated files are exactly the ones most
likely to violate hand-written conventions.

The same applies to vendored dependencies (`node_modules`, `vendor/`, `packages/`), lockfiles,
and minified assets.

## Acceptance criteria

- [ ] The skill states that generated, vendored and minified files are out of scope for adherence linting, and how to recognise them (path conventions, `.map` files, minified-line heuristics, `.gitattributes linguist-generated`, a project's own ignore lists)
- [ ] A diff consisting **only** of generated files reports "nothing to lint — all changes are generated output" rather than either silence or noise; the distinction matters because silence reads as a pass
- [ ] Prefer the project's own declaration where one exists over a built-in list
- [ ] Verified against Symbio's current working diff, which is the case that surfaced it

## Out of scope

- The rulebook-location ladder → TASK-006.
- Whether generated files should be committed at all; that is the project's call.

## Human test plan

- [ ] Run on Symbio's working diff and confirm the generated files are excluded with the reason stated
- [ ] Run on a mixed diff (hand-written + generated) and confirm only the hand-written files are linted

## Implementation plan

_Populated by `/tasks plan TASK-009`._
