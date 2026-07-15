---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", wants integration tests, or asks for test-first development.
---

# Test-Driven Development

> **Birko note** — when running TDD inside the Birko.Framework or any consumer using Birko: the project's test convention is **xUnit + FluentAssertions** (see `CLAUDE-maintenance.md` § "Test Requirements"). Substitute that stack for the TypeScript examples below. The red-green-refactor loop and the good-vs-bad-test heuristics are identical regardless of language.

## Philosophy

**Core principle**: Tests should verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't.

**Good tests** are integration-style: they exercise real code paths through public APIs. They describe _what_ the system does, not _how_ it does it. A good test reads like a specification - "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal collaborators, test private methods, or verify through external means (like querying a database directly instead of using the interface). The warning sign: your test breaks when you refactor, but behavior hasn't changed. If you rename an internal function and tests fail, those tests were testing implementation, not behavior.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Verify the real artifact, not your model of it

A test that asserts *what you already assumed* is circular — it confirms you built
what you intended, not that the thing actually works. The classic trap: you serve
a set of routes, then write a test that those exact routes return 200. That proves
nothing about what the **real consumer** requests.

Hard rules:

- **Exercise the real entry point the way the real consumer does.** For a browser
  app that means actually loading the page in a real or headless browser and
  **failing the check on any console error or failed network request** — not
  curling the individual routes you happened to map. (The built-in `verify`/`run`
  skills are the place to drive this; a green unit suite does NOT substitute for a
  real load.)
- **Third-party dependencies have transitive behavior you don't control.** When
  you integrate a library — especially **ESM in a no-build setup** — verify its
  **whole import graph**, not just the entry file. A module often re-exports
  internal sibling chunks; a bundler resolves these for you, but a hand-rolled
  static server or import map does not — so serving only the entry file 404s on
  its dependencies. Serve the dependency's package directory (or recursively
  resolve the entry's imports and assert no 404), don't hand-map one file you
  guessed at.
- **When you can't run the real client (headless/CI), add a structural proxy for
  it** — e.g. fetch the entry HTML, walk its module import graph, and assert every
  import resolves. This catches the "only my assumed routes were tested" class of
  bug before a human does.
- Name the gap out loud: if you verified only a model (curl, mocked routes, unit
  tests) and not the real artifact, say so — don't report it as "verified".

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" - treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes - they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behavior matters and how to verify it.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

## Workflow

### 1. Planning

When exploring the codebase, use the project's domain glossary so that test names and interface vocabulary match the project's language, and respect ADRs in the area you're touching.

Before writing any code:

- [ ] Confirm with user what interface changes are needed
- [ ] Confirm with user which behaviors to test (prioritize)
- [ ] Identify opportunities for [deep modules](deep-modules.md) (small interface, deep implementation)
- [ ] Design interfaces for [testability](interface-design.md)
- [ ] List the behaviors to test (not implementation steps)
- [ ] Get user approval on the plan

Ask: "What should the public interface look like? Which behaviors are most important to test?"

**You can't test everything.** Confirm with the user exactly which behaviors matter most. Focus testing effort on critical paths and complex logic, not every possible edge case.

### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This is your tracer bullet - proves the path works end-to-end.

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:

- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

### 4. Refactor

After all tests pass, look for [refactor candidates](refactoring.md):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

## Checklist Per Cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```
