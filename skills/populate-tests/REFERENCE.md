# populate-tests — reference

## Detecting the stack

Read `CLAUDE.md` § Testing first. If absent, infer from the repo and confirm:

| Signal | Stack | Test toolkit | Surface source (for generated smoke) |
|---|---|---|---|
| `*.csproj`, ASP.NET host | .NET | **xUnit (+ FluentAssertions)**, `WebApplicationFactory` for integration | minimal-API endpoint map / controller list |
| `package.json` web app, a router lib | TS/JS web | **Playwright** (E2E) + **vitest** (unit) | the route table the router consumes |
| `vitest`/`jest` only, no app routes | TS library | **vitest/jest** | exported public API surface |
| `pyproject.toml` / `requirements.txt` | Python | **pytest** | FastAPI/Flask route map, or public functions |
| Go module | Go | **`testing` + table tests** | http mux / exported funcs |

If the project's `CLAUDE.md` § Testing names a **shared/in-house test toolkit**, prefer it and follow
its own adoption doc — the project layer owns those specifics; this skill stays stack-agnostic.

Adapt — don't hardcode. The *shape* (smoke floor → authored flows → manual ledger) is constant; the
tools differ.

## Adopt — wire the harness (idempotent)

If the project has no test harness yet, scaffold it before authoring. Idempotent: if the test dir /
runner config already exists, do nothing.

- **Init the runner the stack expects** — e.g. `dotnet new xunit` + a project reference to the unit
  under test; a `vitest.config` + `tests/` for TS; a `tests/` package for pytest; a Playwright config
  + a `tests/` dir for a web E2E suite. Pin the runner as a dev-dependency at a version the runtime
  supports.
- **Shared/in-house toolkit** — if `CLAUDE.md` § Testing names one, the project layer (its scaffolder
  skill) owns the exact wiring; follow that doc rather than reinventing it here. Typical pieces such a
  toolkit needs: a dependency link to the toolkit, path/alias config, a thin local `fixtures` file, and
  a login/setup step.

Whatever the stack, the harness MUST honor the invariants below (they're what turn "wired" into
"actually runs"):
- **One runner instance** — the runner must be a single copy reachable by both specs and any shared
  helper package; a source-linked helper must have the runner **injected**, not import its own.
- **Supported runtime** — pin the runtime to a version the runner supports (e.g. an even-numbered Node
  LTS for JS runners); bleeding-edge runtimes break test loaders.
- **Runner-compatible module mode** — don't force a module mode that breaks the runner's own transform
  (e.g. a pure-ESM test package can break named imports from a CJS runner).
- **Ignore generated dirs** — add the runner's output dirs (results/report/auth-state/`node_modules`)
  to `.gitignore`.

Document the project's own one-time pre-reqs (install deps, install the browser/SDK) in its test dir's
README so a fresh checkout can run the suite.

## Generated smoke — derive the surface list, don't hand-write it

The win is self-maintenance: read the **same list the app uses to build itself**.

- **Web (router-driven):** fetch/inspect the route manifest the router is built from (a routes module,
  or an endpoint the app serves its nav/route list from). One test per route: navigate → assert it
  rendered (a stable element like `h1`) → assert no console errors / no 4xx-5xx network. Run-time
  discovery → one test with per-route `test.step` + soft assertions (Playwright collects tests at load
  time, so a dynamically-fetched list can't be one-test-per-route).
- **API:** enumerate endpoints from the route builder; hit each unauthenticated→expect 401, then
  authenticated→expect non-5xx.
- **Library:** assert every public export is importable and has its documented shape.

Wait condition for SPA smoke: use `domcontentloaded` + web-first assertions, **not** `networkidle` —
apps holding a persistent WS/SSE connection never reach networkidle.

## Authored happy-path flows — grounding checklist

Before writing a CRUD/E2E flow, read the real source and capture:

- [ ] The surface's **base/page class** — it dictates the delete path (e.g. list-with-row-actions vs
      master-detail-panel). Don't assume.
- [ ] **Required filters/preconditions** that gate the surface (a building/config select, a parent
      entity). If unsatisfiable (no seed data) → `test.skip(reason)`.
- [ ] The **form schema** — required fields + their control types (native `<select>` vs searchable
      combo vs text). Grouped schemas key fields by **dotted path** (`group.field`), not leaf name.
- [ ] **Field/selector ambiguity** — a control may render a host element *and* an inner input both
      carrying `name=`; target the inner control via the toolkit's field helper, not a raw selector.
- [ ] **Safety** — pick a safely-deletable entity; avoid irreversible/heavy ops (issuing invoices,
      creating tenants). If delete isn't supported by the backend, do create→verify and **file the gap**.

## Self-seeding prerequisites (to un-skip data-gated specs)

A spec that skips on "no options / no parent entity" can be made to run on any fresh DB by **seeding
its prerequisite over the API in a `beforeAll`** (arrange via API, act via UI):

- **Idempotent** — GET the list first; POST only when empty. Re-runs must add nothing.
- **Ground the payload** — read the create endpoint's request DTO + validator for the *required* fields;
  seed the whole chain (a child needs its parent first).
- **Replay the app's scoping headers** — if the app is multi-tenant (or otherwise scopes by a header),
  the browser sends a scoping header (e.g. `X-Tenant-Id` from the JWT tenant claim) on every call. A
  seed POST *without* that header lands in a different scope the UI never sees. Decode the claim from
  your own login token and send the same header on the seed requests.
- Keep a fallback `test.skip` only for prerequisites with **no** API create path (e.g. an order that
  only exists after a checkout flow).

## Verify + triage

Run once, serially (or low `--workers`) to spare dev servers and shared auth state. Bucket each:

- **pass** — keep.
- **skip** — missing seed data / non-creatable entity. Acceptable; the reason must be explicit.
- **quarantine** — real app bug. Mark `test.fixme`/exclude **with a `// BUG:` note**, file a `tasks/`
  item, and (if a one-liner) fix the app. Never delete the assertion to go green.

If the generated smoke finds page crashes, quarantine the broken routes with a tracked exclude list
(not a blanket disable) so a regression on any *other* route still fails.

## Fan-out workflow shape (when opted in)

Pre-fix shared helpers yourself, then:

```
phase('Author')                                  // one agent per surface
parallel(surfaces.map(s => () => agent(
  `Ground in <source for s>; author tests/<s>.spec using <toolkit> from the proven pattern;
   obey the principles (single runner, no-hang selectors, scope-to-open, graceful skip, ground-don't-guess).
   Do NOT run tests.`, { schema, agentType: 'general-purpose' })))
// then a SINGLE serial verify pass (you, not the agents) → triage → fix/skip/quarantine
```

For repair rounds, give each agent its exact failure + the fix lesson, and have it verify ONLY its own
spec with the runner's "skip global setup / reuse auth" flag (e.g. Playwright `--no-deps`) to avoid the
shared-setup race. Or fix inline when diagnoses are clear.

## Manual ledger format

Per surface, one checklist; tag every item:

```
- [ ] <surface> · _`[auto]` <spec/layer that covers it> · `[manual]` <human-judgement residue>_
```

Collapse "list loads / renders / CRUD / no console errors" to `[auto]` (name the spec). Keep only what a
bot can't judge as `[manual]`. A file with no `[manual]` items left can be reduced to a one-line pointer
to its spec.
