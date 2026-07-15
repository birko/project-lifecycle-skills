# {{PROJECT_NAME}}

{{ONE_LINE_PURPOSE}}

- **Stack:** {{STACK}}
- **Kind:** {{KIND}}
- **Task tracking:** `tasks/` ({{TASK_MODE}}) — see [tasks/README.md](tasks/README.md)
- **Feature lifecycle:** `docs/features/` — see "How we work" below
- **Specs:** `docs/specs/` — capability specs harvested *from code* via `/specs` (never hand-written; regen offered at story close)

## How we work — feature lifecycle

Real work flows through a repeatable lifecycle so it stays **tracked, testable, reviewable, and visible to stakeholders** (project managers, stocktakers, end users). Don't jump straight to code for anything non-trivial.

```
idea ─▶ prototype ─▶ decisions ─▶ tasks ─▶ human-test ─▶ review
```

1. **Capture + grill the idea** — `/feature new`. The idea is interrogated until every branch is resolved; each branch becomes a *decision*.
2. **Prototype for stakeholders** — `/feature prototype`. A clickable HTML mockup, a markdown wireframe, or a code spike — whatever lets a stakeholder react to something concrete.
3. **Record decisions** — `/feature decide`. Every decision gets a state: **approved / deferred / changed / removed**, with rationale, date, and who decided. The ledger in `docs/features/FEATURE-NNN/decisions.md` is append-logged — we keep *why* things changed, not just the current value. This is for stakeholders to see the state of the work, not only for devs.
4. **Decompose into small tasks** — `/feature decompose` → `/tasks new`. Approved/changed decisions become atomic, independently-completable tasks under `tasks/`. Each task links back via `feature: FEATURE-NNN`.
5. **Make it testable** — every task carries a `## Human test plan` (in the TASK file). When unit/AI tests can't cover it (UI/UX, edge cases, system integrations), write concrete manual steps a tester can follow. Mark `N/A — fully covered by automated tests` only when that's genuinely true.
6. **Stakeholder status** — `/feature status` regenerates a plain-language rollup for PMs/stocktakers: decision counts, build progress, what's testable, where it stands.
7. **Review gate** — `/feature review`: a **completeness** check (every decision built + every task merged — code correctness was already reviewed *per task* at `/tasks close`, the merge gate) + verify every human-test plan was run + stakeholder sign-off. A feature is "done" only when all three pass; it's a completeness gate, not a wholesale code re-review. **Automated tests passing ≠ the feature works** — exercise the change in the real runtime (run the app / hit the endpoint / load the UI) before calling it done; if you only ran tests, say "verified headlessly, sign-off pending" rather than claiming it works.
8. **Changing something already shipped** — a later change to a `done`/signed-off feature is still a recorded **`changed`** decision, logged in the feature that *owns* the behavior (re-home if you hit it elsewhere), with the ripple traced (downstream constants, comments, other features' decisions). If the change has a **human-verifiable surface** (visual/UX/feel), **preview it first** — show a mockup or 2–3 options and get the user's pick before editing live files (a request that reads like "a small fix" is still a change to a stakeholder-facing surface) — then that feature *and* its implementing task revert to `review` until re-confirmed; a **tests-only** change stays `done`. Never let an unverified change keep reading as done.
9. **Spec check at story close** — `docs/specs/` holds capability specs **generated from the code** (`/specs regen`), never hand-written. Closing a story (`/tasks close STORY-NNN`) offers a scoped `/specs regen` over the areas the story touched; the resulting spec **diff** is reviewed as a "was this behavioral change intended?" check. An unexpected spec diff at story close is a finding, not churn. (Needs `docs/specs/.map.yml` — run `/specs init` once the project has real code.)
10. **Production feedback re-enters the pipeline** — work flows back, not only forward. A field signal (user report, incident, monitoring alert) is triaged like any new work: a **regression** → a `tasks/` bug that ships **with a regression test** so it can't recur; a **missing capability** → a new feature; evidence that a `removed`/`deferred` **decision** was wrong → reopen it (`/feature decide` — a new `proposed` row linking the old). `done` is never the terminus; `done → field → triage → …` is the cycle.

**Ground truth & altitude — what gets recorded where.** `docs/BRIEF.md` stores the user's requests **verbatim**: the opening ask is **immutable**, and later requirement-changing requests are **appended verbatim** (dated, naming the feature they became). Every distilled doc (this file, `README.md`, each `idea.md`) reconciles *against* it — if they disagree, the brief wins (or the divergence is a logged decision). Record each change at the altitude that fits it:

| The change… | …is recorded in |
|---|---|
| introduces/alters a **requirement or scope** (what we build) | a `docs/BRIEF.md` amendment → new/changed feature |
| alters **how an already-requested feature looks/behaves** | that feature's `decisions.md` (a `changed` decision) |
| is a pure **implementation detail** (naming, data structure) | code / commits / `docs/architecture.md` |

Append to `BRIEF.md` **only** for the top row — a refinement of already-requested scope is a *decision*, not a brief amendment. Recognizing "this is new scope, not a tweak", and capturing the verbatim text *before* paraphrasing it into a feature, is the agent's job, not something to wait to be asked.

**Why this exists:** tracking must go beyond a changelog of code. We track *decisions and their reasoning*, decompose into small verifiable units, and keep stakeholders informed of state throughout — not just at the end.

## Architecture

{{ARCHITECTURE_NOTES}}
<!-- Filled from the optional scope grill at scaffold time; expand as the project grows. -->

## Conventions

This section is the project's **canonical, living rulebook** — the rules every change must follow so the codebase stays consistent. It lives here in `CLAUDE.md` (not a side doc) **because this file is auto-loaded into every task's context** — that's what makes "the next task follows the same pattern" actually true. Keep it current (see *Keeping conventions current* below); `/verify-conventions` lints diffs against exactly these rules.

### Framework / stack
- {{STACK}} — the approved foundation. Don't introduce a new framework or major dependency without recording it here first (a new dependency is a tracked decision, not a silent import).
<!-- List approved libraries and any explicitly-disallowed ones. -->

### UI / UX rules
<!-- For web/UI projects: design tokens (color/spacing/type scale), the component library, layout/spacing rules, the accessibility bar, interaction patterns. Delete this subsection for headless/library/CLI projects. For look/UX work, lean toward a prototype first (see the lifecycle above). -->
- {{UI_UX_RULES}}

### Code structure & patterns
<!-- Layering and folder layout, dependency direction, the patterns to follow and the anti-patterns to avoid, error-handling style. Keep this in step with ## Architecture below. -->
- {{CODE_STRUCTURE_RULES}}

### Naming
<!-- File / type / symbol naming conventions. -->
- {{NAMING_RULES}}

### Testing
- Tests: {{TEST_CONVENTION}} <!-- e.g. xUnit + FluentAssertions for .NET; vitest for TS; pytest for Python -->
- Every new public capability gets tests; UI/UX and integration behaviour gets a Human test plan on its task.

**Verification is an attribute of the feature/task being built — not a separate parallel tree.** Don't grow a stand-alone, module-indexed test-checklist tree that's disconnected from `docs/features/` and `tasks/`; that's a third axis that drifts. Instead:

- **Automated tests live in `tests/`** (unit / integration / E2E) — runnable, version-controlled, the single source of "proof it works". One organizing home, not scattered under `docs/`.
- **Layer automated coverage** (esp. for UI/web apps) — cheapest-first:
  1. **Generated smoke** — sweep *every* route/screen for "it renders + no console errors + no failed requests". Derive the route list from the app's own manifest/router so it's **self-maintaining** (new screens are covered automatically, zero per-screen authoring). This one layer covers the bulk of any "does the page load" checklist.
  2. **Authored happy-path flows** — a few hand-written E2E flows (create→…→delete) for the important entities, reusing shared page objects.
  3. **Manual judgement** — only what a human must eye (copy reads naturally, layout/feel, visual polish). Keep these as a **coverage ledger** (each item tagged `[auto]` — naming the spec/layer that covers it — or `[manual]`) or as the task's `## Human test plan` — co-located with `tests/` or the task, **not** a free-floating doc tree.
- **Acceptance criteria belong on the feature** (`docs/features/FEATURE-NNN/`, authored at `/feature decompose`) and the task's Human test plan — that's how "what must be true" stays tied to "why we built it".
- **Done-gate:** a task/feature is done only when **automated tests pass *and* its manual/acceptance checks were actually run** (see lifecycle step 7 — "automated tests passing ≠ the feature works"). The generated smoke is the floor, not the ceiling.

### Keeping conventions current (register-on-introduce)
- When a change **introduces a new cross-cutting pattern** — a new framework/major dependency, a UI pattern, a new architectural layer or module shape, a new naming or testing convention — **record it in this section in the same change**. Updating the rulebook is part of "done", exactly like updating the decision ledger. A pattern that lives only in one file is not a convention; it's drift waiting to be copied wrong.
- If the change alters structure, update **## Architecture** too — a stale architecture doc is a defect, not stale-but-harmless.
- `/verify-conventions` flags a change that introduced a new pattern without recording it here.

### Working rules
- For non-trivial work, create the task (`status: todo`, with acceptance criteria) **before** implementing — then tick boxes as they're met. Don't write a task after the code is done and drop it straight into `review`. Small conversational fixes can track at the parent EPIC level.
- Before flipping a **non-trivial** task to `done`, run `/verify-conventions` (adherence to the rules above) **and** `/code-review` (correctness) on the diff, then address the findings or note in the task why any are deferred — tests passing ≠ reviewed-and-conventional. Skip for trivial mechanical changes (docs, renames, one-liners). **This `/tasks close` step *is* the merge gate** — for git/PR projects the default is one branch + PR per task (plus `/review` on the PR diff), and `done` means *merged*, not just locally reviewed. Code is reviewed once, here, per task; `/feature review` then only confirms completeness, it doesn't re-run these wholesale.
  - **These two checks are agent-run, not CI-enforced.** The CI workflow gates build + tests; it does **not** run `/verify-conventions` or `/code-review` (they're agent skills). So the convention/review gate is a *convention the agent follows*, not a hard guarantee. To make it enforced, wire a git pre-commit hook (via the `update-config` skill) that blocks on convention/review findings — recommended once the rulebook above stabilizes.
- Keep `docs/features/*/status.md` current — it's how non-devs see progress.
- To see where things stand, use `/tasks` (the status snapshot is feature-aware — it cross-checks `docs/features/` and flags any drift) or `/roadmap` for the full epic→feature→task view plus a divergence audit. Both span the two trees, so "what's next / what's planned" never misses a feature.
- No `Co-Authored-By:` trailers in commit messages.

## Commands

{{BUILD_RUN_COMMANDS}}
<!-- e.g. `dotnet build` / `npm run build` / `pytest` — fill in once the stack skeleton exists. -->
