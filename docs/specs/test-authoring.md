---
area: test-authoring
generated-at: e7828fc02eb23298ab367cab0853f2c8e97c2375
generated-on: 2026-10-07
sources:
  - skills/populate-tests/REFERENCE.md
  - skills/populate-tests/SKILL.md
  - skills/tdd/SKILL.md
  - skills/tdd/deep-modules.md
  - skills/tdd/interface-design.md
  - skills/tdd/mocking.md
  - skills/tdd/refactoring.md
  - skills/tdd/tests.md
shaped-by: [FEATURE-001]
shaped-by-derived: true
shaped-by-unresolved: 5
---

# Writing tests first, filling coverage gaps, and proving a test can actually fail

## Purpose

Test authoring covers two skills that share one belief: a test is only worth what it can catch. `tdd` drives new code through a red-green-refactor loop, one test at a time, with tests written against public interfaces. It also owns the project's shared code-smell inventory and its interface-design heuristics, which other skills read too. `populate-tests` takes an existing project of any stack, wires a test harness if one is missing, surveys which surfaces are untested, writes grounded tests in layers, triages the results without faking green, and keeps a per-surface `[auto]`/`[manual]` coverage ledger. Both require that a test written to pin a defect be shown able to fail. For a product made of prose, `populate-tests` also defines the cold drill: a test run by a reader who knows neither the change nor its subject. `tasks close`, `fix-next` and `verify-conventions` depend on these rules. So does every task whose human test plan is a drill.

## Requirements

### Requirement: Use the project's own test stack, not the examples' stack

The system SHALL treat its TypeScript examples as illustrations only and SHALL take the test framework and conventions from the project's `CLAUDE.md` § Testing. The red-green-refactor loop and the good-test/bad-test heuristics apply unchanged in every language.

#### Scenario: A .NET project runs the TDD loop

- **Given** a project whose `CLAUDE.md` § Testing names xUnit with FluentAssertions
- **When** the tdd skill writes its first test
- **Then** the test is an xUnit test, not a TypeScript `test(...)` block, and it still follows one-test-then-one-implementation

### Requirement: Tests verify behaviour through public interfaces

The system SHALL write integration-style tests that exercise real code paths through the public API and describe what the system does. Each test SHALL carry one logical assertion. The system SHALL treat the following as red flags: mocking internal collaborators, testing private methods, asserting on call counts or call order, a test name that describes how rather than what, and verifying through an external means such as querying the database directly instead of reading back through the interface.

#### Scenario: Verifying that a user was created

- **Given** a `createUser` function and a matching `getUser` function
- **When** a test checks that creating a user works
- **Then** it creates the user and reads it back through `getUser`, rather than querying the users table directly

#### Scenario: A test breaks on a rename

- **Given** a test that fails when an internal function is renamed and behaviour has not changed
- **When** the test is judged against the checklist
- **Then** it is classed as an implementation-detail test, not a behaviour test

### Requirement: Mock only at system boundaries

The system SHALL mock only system boundaries: external APIs, time and randomness, and sometimes databases (a test database is preferred) and the file system. It SHALL NOT mock the project's own classes or modules, internal collaborators, or anything else the project controls. At a boundary it SHALL prefer dependency injection and SDK-style interfaces, with one function per external operation, over a generic fetcher.

#### Scenario: A payment client

- **Given** a function that charges a payment provider
- **When** it is designed for testing
- **Then** the payment client is passed in as a parameter instead of being constructed inside the function, and the test substitutes it

#### Scenario: An internal helper

- **Given** an order-total calculator that the project wrote itself
- **When** a test of checkout runs
- **Then** the calculator is not mocked

### Requirement: Verify the real artifact, not a model of it

The system SHALL exercise the real entry point the way the real consumer does. For a browser app that means loading the page in a real or headless browser and failing on any console error or failed network request. When the system integrates a third-party dependency, it SHALL verify that dependency's whole import graph, not just its entry file. Where the real client cannot run, it SHALL add a structural proxy, such as walking the entry HTML's module imports and asserting that each one resolves. If it verified only a model (curl calls, mocked routes, unit tests), it SHALL say so and SHALL NOT report the work as verified.

#### Scenario: Only mapped routes were curled

- **Given** a no-build ESM app whose routes each return 200 when curled
- **When** the work is reported
- **Then** the report says that only a model was verified, unless the page was also loaded in a browser or its import graph was walked with every import resolving

### Requirement: Plan the interface and the behaviours with the user before writing code

The system SHALL, before writing any code, confirm with the user which interface changes are needed and which behaviours to test, in priority order. It SHALL look for deep-module opportunities, design interfaces for testability, list the behaviours rather than implementation steps, and get the user's approval of the plan. The question it puts is "What should the public interface look like? Which behaviors are most important to test?" The prose defines no outcome for the case where no answer comes.

#### Scenario: Starting a TDD cycle

- **Given** a user asks to build a feature test-first
- **When** the tdd skill starts
- **Then** it asks "What should the public interface look like? Which behaviors are most important to test?" and waits for the plan to be approved before writing a test

### Requirement: Use the project's vocabulary and respect its decision records

The system SHALL, while exploring, use the project's domain glossary for test names and interface vocabulary, and SHALL respect the decision records in `docs/adr/` for the area it touches. It SHALL check whether these exist rather than assuming they do, and SHALL NOT start a glossary or a decision record in the middle of a cycle.

#### Scenario: No glossary exists

- **Given** a project with no `docs/glossary.md`
- **When** a TDD cycle needs a name for a concept
- **Then** the cycle goes on without creating a glossary entry

### Requirement: Vertical slices, one test at a time

The system SHALL NOT write all tests first and then all implementation. It SHALL work in vertical slices. A tracer-bullet test comes first and fails; then the minimal code to pass it; then the next test, and so on. Each cycle writes only enough code to pass the current test, does not anticipate future tests, and adds no speculative features.

#### Scenario: Five behaviours to build

- **Given** five planned behaviours
- **When** the loop runs
- **Then** the order is test 1, implementation 1, test 2, implementation 2, and so on, never all five tests followed by all five implementations

### Requirement: Refactor only on green

The system SHALL refactor only after all tests pass, and SHALL never refactor while a test is red. In the refactor step it SHALL look for duplication to extract, modules to deepen, natural applications of SOLID principles, and what the new code reveals about existing code. It SHALL run the tests after each refactor step.

#### Scenario: A smell spotted while red

- **Given** a failing test and duplicated code nearby
- **When** the duplication is noticed
- **Then** the code is first made to pass, and the duplication is extracted afterwards, with the tests run again after the extraction

### Requirement: One shared code-smell inventory, read by several skills

The system SHALL keep a single smell table in `skills/tdd/refactoring.md`. Each row gives a smell, an observable signal and a suggested move, and covers mysterious name, duplicated code, long method, feature envy, data clumps, primitive obsession, repeated switches, shotgun surgery, divergent change, speculative generality, message chains, middle man, refused bequest, shallow module, and existing code that the new code reveals as problematic. Every row SHALL be a judgement call, not a violation. The table SHALL serve both the TDD refactor step and `verify-conventions` (as its baseline for a repo with no recorded conventions). Other skills SHALL point at it, not copy it.

#### Scenario: verify-conventions runs on a repo with no rulebook

- **Given** a repo whose agent guide records no conventions
- **When** verify-conventions needs a baseline
- **Then** it reads the smell rows from the tdd refactoring file and reports them as judgement calls

#### Scenario: The new code reveals a problem

- **Given** a change that was awkward because of existing code
- **When** the refactor step finds the cause
- **Then** the cause is either fixed or filed through `tasks spawn`

### Requirement: Deep modules and the deletion test

The system SHALL prefer deep modules, meaning a small interface over a substantial implementation. Before calling something shallow, it SHALL run the deletion test: inline the module into all of its callers on paper and compare the total logic. If the total shrinks, the module concentrates logic and is a finding (delete or merge it). If the total stays the same or grows, the logic merely moves and this is not a deletion finding, though the module may still need deepening. For a single caller where the logic merely moves, the *Speculative generality* row decides. Pure data-shape types (config sections, DTOs, wire formats) SHALL never be a finding under this test. A "merely moves" result SHALL be recorded in the review's own record, such as its list of dropped findings with the callers checked, and never in a code comment.

#### Scenario: A pass-through wrapper

- **Given** a wrapper class whose methods all delegate, used by three callers
- **When** the wrapper is inlined on paper and the pass-through calls disappear
- **Then** the total shrinks and the wrapper is reported as a finding to delete or merge

#### Scenario: A DTO

- **Given** a type that only mirrors a wire format
- **When** shallow modules are being judged
- **Then** it is not a finding

### Requirement: Interface heuristics for testability

The system SHALL design interfaces that accept dependencies rather than create them, return results rather than produce side effects, and keep a small surface. With only one adapter, it SHALL keep passing the dependency in but type it as the concrete class, and SHALL extract an interface only when a second adapter is actually written. A test double at a system boundary counts as a second adapter; a mock of an internal collaborator does not. A behaviour observable only by reaching past the interface SHALL be treated as an interface defect and fixed by changing the interface, never by widening the test's reach. Side effects at a system boundary, observed through that boundary's double, are exempt from this.

#### Scenario: An interface with one implementation

- **Given** an injected storage interface with one implementation and no boundary double
- **When** interfaces are reviewed
- **Then** the advice is to type the dependency as the concrete class until a second adapter exists

#### Scenario: Behaviour visible only in a log

- **Given** a behaviour that can be observed only in a log line or a private field
- **When** a test would need to check it
- **Then** the interface is changed so the behaviour shows through it, and the test is not given extra reach

### Requirement: Design an interface twice before committing to it

The system SHALL, when about to commit to an interface that has only one drafted shape, draft a deliberately different second shape. The two drafts SHALL be made in isolation (two agents, or two passes that cannot see each other). A single agent that cannot isolate them SHALL say so and write the second draft from the requirements before rereading the first. The system SHALL pick the shape that hides more behind a smaller interface, and SHALL record which shape won and why the other lost in the task or design record, not in the code. "The first draft won" is an acceptable result.

#### Scenario: One agent, no isolation

- **Given** a single agent designing an interface
- **When** it applies design-it-twice
- **Then** it states that the drafts are not isolated, writes the second draft from the requirements alone, and records the winner on the task

### Requirement: Read the testing convention before authoring

The system SHALL read the project's `CLAUDE.md` § Testing first, to learn the stack, the test framework, where tests live, the layers and the done-gate. If that section is missing, it SHALL infer the stack from the repo and offer to seed the convention from the new-project template. It SHALL never write tests for code it has not read, and SHALL ground every selector, API and field in real source.

#### Scenario: No § Testing section

- **Given** a repo with a `pyproject.toml` and no § Testing in its agent guide
- **When** populate-tests runs
- **Then** it infers pytest and offers to seed the testing convention before authoring

### Requirement: A three-layer coverage model

The system SHALL populate coverage in three layers. Layer 1 is generated smoke over every surface, derived from the app's own manifest or router. It is done first. Layer 2 is a few hand-written happy-path flows per important entity, reusing the project's toolkit and shared page objects. Layer 3 is a manual-judgement ledger holding only what a human must look at.

#### Scenario: A web app with routes

- **Given** a router-driven web app with no tests
- **When** populate-tests fills coverage
- **Then** the route smoke is authored before any hand-written flow

### Requirement: Five modes with survey as the default

The system SHALL accept `/populate-tests [adopt|survey|populate|verify|ledger] [scope]`, and a bare invocation SHALL run `survey`. `survey` SHALL list surfaces against what is tested, as a table of surface → tested? → layer, and SHALL make no edits in any case. With no harness found (neither a test directory nor a runner config), it SHALL report every surface untested and end with `no harness — run /populate-tests adopt to wire one`. Of the five modes, only `populate` SHALL call `adopt` first when no harness is found.

#### Scenario: Bare invocation in a repo with a harness

- **Given** a repo with a test harness
- **When** the user runs `/populate-tests`
- **Then** a gap table of surface, tested and layer is printed and no file changes

#### Scenario: Survey in a repo with no harness

- **Given** a repo with no test directory or runner config
- **When** the user runs `/populate-tests survey`
- **Then** no file changes, every surface is reported untested, and the report ends by pointing at `/populate-tests adopt`

### Requirement: Adopt wires the harness idempotently

The system SHALL, in `adopt`, detect the stack and scaffold the test directory, the runner config, and a pinned dev-dependency on the runner. Where § Testing names a shared or in-house toolkit, it SHALL follow that toolkit's own adoption doc. If the test directory or runner config already exists, it SHALL do nothing. Whatever the stack, the harness SHALL honour these invariants: one runner instance (injected into any source-linked helper), a runtime the runner supports, a module mode compatible with the runner, and the runner's output directories added to `.gitignore`. One-time prerequisites SHALL be documented in the test directory's README.

#### Scenario: Re-running adopt

- **Given** a repo that already has `vitest.config` and `tests/`
- **When** `adopt` runs
- **Then** nothing is written

#### Scenario: A fresh TS repo

- **Given** a TS web app with no harness
- **When** `adopt` runs
- **Then** it adds a Playwright config and `tests/` directory, pins the runner as a dev-dependency, and ignores the runner's results, report and auth-state directories

### Requirement: Stack detection maps signals to toolkits

The system SHALL map repo signals to a toolkit and a surface source: `*.csproj` → xUnit (+ FluentAssertions), endpoint map; a `package.json` web app with a router → Playwright + vitest, route table; vitest/jest only → vitest/jest, exported API; `pyproject.toml`/`requirements.txt` → pytest, route map or public functions; a Go module → `testing` with table tests, http mux or exported functions. A shared toolkit named in § Testing SHALL take precedence over this table.

#### Scenario: A Go module

- **Given** a repo with `go.mod` and no § Testing
- **When** the stack is detected
- **Then** the toolkit is Go's `testing` package with table tests, and the surface source is the http mux or the exported functions

### Requirement: Generated smoke is derived from the app's own surface list

The system SHALL derive generated smoke from the list the app itself is built from, never from a hand-maintained route list. For a web app: navigate to each route, assert a stable element rendered, and assert no console errors and no 4xx/5xx responses. When routes are discovered at run time, it SHALL use a single test with one `test.step` per route and soft assertions. For an API: unauthenticated calls expect 401, authenticated calls expect a non-5xx. For a library: every public export is importable and has its documented shape. SPA smoke SHALL wait on `domcontentloaded` with web-first assertions, never `networkidle`.

#### Scenario: An app with a persistent WebSocket

- **Given** an SPA that keeps a WebSocket open
- **When** route smoke is authored
- **Then** it waits on `domcontentloaded` rather than `networkidle`

### Requirement: Authored flows follow a grounding checklist

The system SHALL, before writing a CRUD or E2E flow, read the surface's base or page class (which decides the delete path), any required filters or parent entities, the form schema with dotted-path keys for grouped fields, any selector ambiguity between host and inner controls, and safety concerns. It SHALL pick a safely deletable entity and avoid irreversible operations. Where the backend cannot delete, it SHALL do create-then-verify and file the gap.

#### Scenario: Delete is not supported

- **Given** an entity whose backend has no delete endpoint
- **When** its flow is authored
- **Then** the flow creates and verifies only, and the missing delete is filed as a gap

### Requirement: Data-gated specs seed themselves idempotently

The system SHALL un-skip a spec gated on missing data by seeding the prerequisite through the API in a `beforeAll`. The seed SHALL be idempotent (GET first, POST only when empty), grounded in the create endpoint's request DTO and validator, created in dependency order, and SHALL replay the app's scoping headers (for example, a tenant header decoded from the login token). A fallback `test.skip` SHALL remain only for prerequisites that have no API create path.

#### Scenario: A multi-tenant seed

- **Given** a multi-tenant app whose browser sends `X-Tenant-Id` on every call
- **When** a seed POST creates a parent entity
- **Then** the seed sends the same tenant header, so the UI can see the seeded row

### Requirement: Verify triages every result without faking green

The system SHALL, in `verify`, run the suite serially or with low parallelism and put each result into one of three buckets. **Pass** is kept. **Skip** is for missing seed data, with an explicit reason, and never hangs or goes red. **Quarantine** is for a real app bug: the test is marked `test.fixme` or excluded with a `// BUG:` note, a task is filed, and the app is fixed if the fix is one line. The system SHALL never loosen or delete an assertion to hide a failure. A generated smoke that finds crashes SHALL quarantine the broken routes through a tracked exclude list, not a blanket disable.

#### Scenario: A real app bug

- **Given** an authored spec that fails because the app saves the wrong value
- **When** verify triages it
- **Then** the spec is quarantined with a `// BUG:` note, a task is filed, and the assertion is left unchanged

#### Scenario: One route crashes

- **Given** generated smoke where one route of forty crashes
- **When** the result is triaged
- **Then** only that route goes on a tracked exclude list, and a regression on any other route still fails

### Requirement: Verify runs only against a disposable environment

The system SHALL run mutating suites only against a disposable or seeded test environment, never against dev or production data. Defaults SHALL point at localhost, mutating specs SHALL create, assert and delete, and CI SHALL be guarded off production hosts. If only a shared or production-like stack is reachable, the system SHALL run the read-only smoke and say so.

#### Scenario: Only a shared stack is reachable

- **Given** no disposable environment is available
- **When** verify runs
- **Then** only the read-only smoke runs, and the report says that mutating suites were not run

### Requirement: A guard that cannot reach its subject is treated as worse than none

The system SHALL, when a test fails before reaching what it asserts (a feature toggle off, a missing fixture, a 404 before the interesting call), fix the precondition, then prove that the assertion can still fail, and then check whether sibling tests share the same precondition.

#### Scenario: Authorization tests satisfied by the wrong 403

- **Given** authorization tests expecting `[401, 403]` that pass because the module is disabled
- **When** the module toggle is fixed
- **Then** each assertion is proved able to fail against the permission check itself, and the sibling tests sharing the toggle are checked too

### Requirement: Every defect-pinning test is proved able to fail

The system SHALL require a test written to pin a specific defect to earn one of three proofs before it counts:

- **Revert-and-split.** Stash only the production change and re-run. Every test believed to depend on the fix must fail. Each test that still passes is named as a contract pin, not evidence. An expected failure that passes means the test is wrong and must be fixed before going on.
- **Reintroduce-and-confirm.** For E2E or UI work, put the bug back, rebuild, and confirm the spec goes red. A trigger that never re-runs the buggy path is a false guard.
- **Bidirectional assertion.** Assert that the correct value is present and the buggy value is absent.

`fix-next` runs this proof as a required step. `tasks close` requires it before an automated check can retire a `[manual]` ledger line.

#### Scenario: A test passes with the fix stashed

- **Given** three regression tests, and with the production change stashed only two fail
- **When** the result is recorded
- **Then** the third is named as a contract pin and not counted as evidence, or, if it was expected to fail, it is fixed before work continues

#### Scenario: A filter change does not re-run the bug

- **Given** a UI spec whose filter change refreshes the table without re-running the buggy code path
- **When** the bug is reintroduced and the spec stays green
- **Then** the spec is called a false guard and a trigger that reproduces the bug is found

### Requirement: Field-found bugs earn a regression spec before done

The system SHALL require a bug reported from production to get a regression spec before its fix is marked `done`. It SHALL update feature acceptance sections as coverage lands, and SHALL file the bugs it finds as `tasks/` items. The done-gate is met only when tests are green and the manual checks have been run.

#### Scenario: A production bug report

- **Given** a bug reported by a user in production
- **When** its fix task is closed
- **Then** a regression spec covering it exists in the suite

### Requirement: The manual ledger keeps only human judgement

The system SHALL keep one checklist per surface in the form `- [ ] <surface> · _[auto] <spec> · [manual] <residue>_`. Generic "loads / renders / CRUD / no console errors" items SHALL be collapsed to `[auto]` with the covering spec named, and only what a bot cannot judge SHALL stay `[manual]`. A ledger file with no `[manual]` items left may be reduced to a one-line pointer to its spec.

#### Scenario: Refreshing a ledger

- **Given** a surface checklist with "list renders" and "copy reads naturally"
- **When** `ledger` runs and route smoke covers that surface
- **Then** "list renders" becomes `[auto]` naming the smoke spec, and "copy reads naturally" stays `[manual]`

### Requirement: Fan out only with explicit opt-in, and verify serially

The system SHALL use the Workflow tool, with one agent per surface, only when the user explicitly opts in. Otherwise it SHALL work surface by surface inline. Before fanning out it SHALL fix any shared helper itself. Authoring agents SHALL NOT run tests. Verification SHALL be a single serial pass run by the orchestrator. For repair rounds, an agent verifies only its own spec, using the runner's skip-global-setup flag.

#### Scenario: Twenty surfaces, no opt-in

- **Given** twenty untested surfaces and no opt-in from the user
- **When** populate runs
- **Then** it works through the surfaces one by one inline and spawns no agents

### Requirement: A product made of prose is tested by a cold drill

The system SHALL test instruction prose with a cold drill. A reader who has not seen the change, and whose context does not already hold the subject, executes the instructions against a real target and reports where they led. The human test plan states the expected outcome. The drill brief SHALL never state it. The brief SHALL ask the reader to:

- execute rather than evaluate;
- report the outcome in the instructions' own terms;
- report what the instructions left undecided, quoting the sentence;
- report what it had to infer;
- report what it read that nothing sent it to.

The brief SHALL also bar any lookup of diffs, history, task notes or planning docs. It SHALL give setup provenance mechanically, never as a classification. It SHALL tell the reader to write out any question the instructions raise, word for word, and to carry on as if no answer came. It SHALL tell the reader that it is running a drill while withholding the change. Matching the report back to the plan is the author's job. A result based on weak evidence SHALL stay unticked rather than be ticked with a caveat.

#### Scenario: Turning a plan into a brief

- **Given** a test plan saying "confirm the survey reports `not applicable`"
- **When** the drill brief is written
- **Then** the brief asks the reader to carry out the survey and report the states it assigned, and never mentions `not applicable`

### Requirement: Coldness is acquired outside both loaders and confirmed

The system SHALL acquire the drill reader outside both the project guide and user-level installed instructions. A different working directory alone is not enough. Each brief SHALL open by asking the reader to list the instruction files and skills it has loaded. The report SHALL be scanned for any term from the subject's own vocabulary that the brief did not supply, and one such term is enough to count. A reader that fails either check still produces a usable negative result, but not a pass. The drill record SHALL name the command, the working directory and the result of the coldness check.

#### Scenario: A session started in an unrelated repo

- **Given** a reader session started in a repo with no agent guide, with user-level skills still loaded
- **When** its report uses a term from the drilled skill that the brief never gave it
- **Then** the reader is classed as contaminated, only a negative result from it counts, and the record says so

### Requirement: Drill targets must not have adjudicated the case, and are left as found

The system SHALL NOT drill a rule on a repo that the rule itself names. Contamination is judged per question, and the affected part of the report is discounted. Real targets SHALL be preferred over built fixtures, and an A/B run on one unchanged target is the strongest form. A drill that changes the tree SHALL use a clone or worktree. When the target's `tasks/.config.yml` declares `worktree-root:`, the worktree goes at `<worktree-root>/<repo-name>-drill-<label>`. Otherwise it goes in the reader's scratch directory, never inside the target. The drill that made the checkout SHALL remove it at the end, without `--force`; a dirty checkout is reported by its path. Read-only drills SHALL be told so in the brief. When a drill is about uncommitted state, the brief SHALL say that the checkout is a clone or worktree, and that any missing in-flight work is an artefact of how it was made.

#### Scenario: The checkout is left dirty

- **Given** a drill worktree that still holds modified files at the end of the drill
- **When** the drill cleans up
- **Then** the worktree is not removed with `--force`, and its path is recorded in the drill record as not removed

#### Scenario: No worktree root is declared

- **Given** a target whose `tasks/.config.yml` declares no `worktree-root:`
- **When** a drill needs to change files
- **Then** the clone is made in the reader's scratch directory, outside the target

### Requirement: A drill is run only where a careful reader could diverge

The system SHALL drill a change that adds or rewrites a rule, has branches, fails silently, or cites its own justification. It SHALL NOT drill typos, links, renames, deletions, restatements, changes that fail loudly, or anything a lint already pins. The deciding question is: "could a careful reader, without knowing what I intended, reach a different answer than the one I intended?" A drill SHALL NOT replace a regression-test proof, and SHALL NOT excuse leaving a mechanisable check unautomated.

#### Scenario: A link fix

- **Given** a change that only fixes a broken link
- **When** the author decides whether to drill it
- **Then** no drill is run, because a link resolving is a mechanical check
