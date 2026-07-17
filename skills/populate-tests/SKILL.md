---
name: populate-tests
description: Populate and maintain a project's automated tests and its manual coverage ledger, on any stack. Use when the user says "/populate-tests", "author tests", "add test coverage", "generate e2e/integration tests", "populate tests for module X", "fill in the test checklist", "what's untested", or wants to turn a manual test checklist into automated specs. Reads the project's CLAUDE.md § Testing convention to learn the stack, test framework and layered model (generated smoke → authored happy-path flows → manual-judgement ledger), then surveys coverage gaps, authors grounded tests per surface (reusing the project's own test toolkit — Playwright, xUnit, vitest, pytest, …), verifies + triages them (pass / graceful-skip / quarantine real bugs), and keeps each surface's [auto]/[manual] ledger current. Fans out via the Workflow tool for scale and integrates with the feature lifecycle and tasks. Sibling to new-project/feature/tasks.
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
  (real app bug). Never loosen an assertion to hide a failure. **Run it against a disposable/seeded test
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
