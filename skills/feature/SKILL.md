---
name: feature
description: Per-feature/idea lifecycle for stakeholder-facing work — capture an idea, grill it into a decision tree, build an interactive prototype for stakeholders (stocktakers / PMs), record which decisions are approved / deferred / changed / removed, decompose approved decisions into tracked tasks, publish a stakeholder status rollup, and run a review gate. Use when the user says "/feature new", "/feature prototype", "/feature decide", "/feature decompose", "/feature status", "/feature review", "novy feature", "new feature", "prototype for stakeholders", "feature decisions", "approve/defer/drop a feature decision", "stakeholder status", or wants to take a raw idea through to tracked, testable, reviewed work. Sits on top of the [[tasks]] skill (decomposition + tracking) and reuses [[grill-me]] (idea interrogation) and [[code-review]] (review gate).
---

# feature

Takes a raw idea through a repeatable lifecycle and leaves a paper trail that serves **two audiences at once**: developers (what to build, how to test it) and stakeholders — stocktakers, project managers (what was decided, why, and where the work stands).

```
new ─▶ prototype ─▶ decide ─▶ decompose ─▶ (work happens in /tasks) ─▶ status ─▶ review
 │         │           │           │                                      │          │
grill-me  pick form  stamp      /tasks new                            rollup    completeness
(interview) HTML/MD/  approved/  --from-feature                      for PMs    + human test
            spike     deferred/                                                   plans + sign-off
                                 (code reviewed per-task at /tasks close, the merge gate)
                      changed/
                      removed
```

The lifecycle is **not strictly linear** — you loop back to `decide` after a prototype demo, re-`prototype` a changed decision, or `decompose` incrementally as decisions get approved.

## The feature list is a living artifact — keep it complete and current

The set of `docs/features/FEATURE-*/` folders **is** the project's feature list;
bare `/feature` renders it live from them. Two standing obligations:

1. **Completeness.** Every committed requirement must exist as a `FEATURE-*`
   folder (even a one-line `idea.md` stub with `status: idea`). A requirement that
   lives only in chat, a roadmap bullet, or a half-remembered plan is *not*
   tracked and will be dropped. Soft/qualitative asks ("make it look good",
   "fast") get their own feature — never fold them into another feature's bullet.
2. **Currency.** The list must reflect reality at all times: `new` adds a folder,
   `decide`/`decompose`/`status`/`review` update that feature's `status` +
   decisions, and the owning EPIC's requirement→feature table is reconciled
   whenever scope is added, changed, displaced, or shipped. Never leave the stored
   state lying about what's planned, in-flight, or done.
3. **Keep the companion docs in sync.** Two files rot silently if you only touch
   feature folders — refresh them as part of every feature transition:
   - **`docs/features/README.md`** — the features *index* (the human entry point),
     rendered from [templates/README.md.tmpl](templates/README.md.tmpl). **`/feature status`
     (all-features mode) owns full regeneration** (its step 7); `new` adds the row, and
     `decide`/`review`/re-home update the affected row's phase/`superseded` marker (or just
     re-run `/feature status` to regenerate). It's the committed counterpart to the computed
     bare-`/feature` view — don't hand-maintain it freeform; it has a template and an owning verb
     now, like `status.md`.
   - **`docs/architecture.md`** — when a feature changes the system's structure
     (a new module, engine, server shape, protocol), update it. It is a *living*
     document; a scaffold-era architecture doc that still describes day-1
     assumptions is a real defect, not stale-but-harmless.

If you ever can't point to *where* a requirement is tracked, that is the bug —
create the feature folder before continuing.

## Verbs (router)

User invokes as `/feature <verb> [args]`. Read **only** the verb file matching the request.

| Verb | What it does | File |
|---|---|---|
| `new` | Capture an idea; grill it into a decision tree; create the feature folder | [verbs/new.md](verbs/new.md) |
| `prototype` | Build an interactive prototype for stakeholders (form decided per-feature) | [verbs/prototype.md](verbs/prototype.md) |
| `decide` | Stamp each decision: approved / deferred / changed / removed (+ rationale) | [verbs/decide.md](verbs/decide.md) |
| `decompose` | Turn approved decisions into tracked tasks via `/tasks new --from-feature` | [verbs/decompose.md](verbs/decompose.md) |
| `status` | Regenerate the stakeholder-facing status rollup | [verbs/status.md](verbs/status.md) |
| `review` | Completeness gate: all decisions built + tasks merged + human-test verification + stakeholder sign-off (code already reviewed per-task at `/tasks close`) | [verbs/review.md](verbs/review.md) |
| `show` | Read-only view of a feature by ID | [verbs/show.md](verbs/show.md) |
| `help` | Print this verb table | [verbs/help.md](verbs/help.md) |

If user types `/feature` with no verb → list all features with their decision counts + task progress (the [Collection pass](#collection-pass) rendered to stdout).
If user types `/feature help` → print the verb table and exit.

## File layout

Features live in `docs/features/` (stakeholder-facing), **separate from** `tasks/` (dev-facing). This is the deliberate "hybrid" split: stakeholder docs and the executable test plans have different audiences and lifecycles.

```
docs/features/
  FEATURE-NNN-slug/
    idea.md            ← the problem statement + grill-me transcript distilled (stakeholder readable)
    decisions.md       ← the decision tree with states: approved/deferred/changed/removed (+ history log)
    prototype.html     ← OR prototype.md OR a link to a code-spike branch (form decided per-feature)
    status.md          ← auto-generated rollup for PMs/stocktakers: where this feature stands
```

The **human-test plan does NOT live here** — it lives inside each TASK file (`## Human test plan`), because a test plan must travel with the unit of work and be checkable at `/tasks close`. The feature folder links to tasks; tasks link back via `feature: FEATURE-NNN` frontmatter.

See [templates/](templates/) for exact file shapes.

## ID generation

`FEATURE-NNN` is its own global counter, parallel to (not the same as) EPIC/STORY/TASK. A feature is stakeholder-facing and time-boxed; an epic is an open-ended dev area of concern. To find the next ID, Glob `docs/features/FEATURE-*/` (or Grep `^id: FEATURE-(\d+)$` in `decisions.md` files), take the max, increment, zero-pad to 3.

## Where `docs/features/` lives

Same project-root resolution as the [[tasks]] skill's shape detection: walk up to the project root (`*.slnx`/`*.sln`, then `.git`). Place `docs/features/` under the project root. On a Birko.Framework-style meta-repo, a cross-cutting feature lives at the meta-root `docs/features/`; a sub-project feature lives in `Birko.X/docs/features/`. If `docs/` doesn't exist, create `docs/features/` (don't disturb existing docs).

## Decision states (the core model)

Every idea, after grilling, is a set of **decisions**. Each carries exactly one state:

| State | Meaning | Generates tasks? |
|---|---|---|
| `approved` | Stakeholder said build it | ✅ yes, at `decompose` |
| `deferred` | Good idea, not now (note the unblock condition) | ❌ no (revisit later) |
| `changed` | Approved but altered from the original idea — record the delta | ✅ yes (the changed form) |
| `removed` | Rejected / out of scope / out of budget | ❌ no |
| `proposed` | Default fresh state straight out of `grill-me`, awaiting `decide` | ❌ not yet |

State changes are **append-logged** in `decisions.md` (a history block under the table) — you keep *why it changed and when*, not just the current value. This is the tracking requirement: more than a changelog of code, it's a ledger of intent.

### Tracking decisions as they evolve (any stage, any trigger)

Decisions get refined and replaced throughout a feature's life — not just at a
stakeholder demo. A coding agent hits a constraint and abandons the approved
approach; a benchmark forces a tradeoff; a review surfaces an edge case; a visual
sign-off rejects the look. **What decides whether something is tracked is the
*nature* of the change, not how or by whom it was triggered.**

- **Track by impact, not by source.** A choice belongs in `decisions.md` if it
  changes the feature's *observable behavior, scope, contract, or an
  already-recorded decision* — whether it came from a grill, a stakeholder demo, a
  code review, or **the agent discovering mid-implementation that the approved plan
  won't work**. "We approved X but built Y because Z" is a decision change and gets
  logged *even if no human was in the loop when it happened* — the agent is
  responsible for surfacing it, not waiting to be asked.
- **Pure implementation detail stays out of the ledger.** Internal naming, a data
  structure, an algorithm with no observable or contract effect → that lives in the
  code, commit messages, and `docs/architecture.md`, not the stakeholder ledger. The
  moment a detail starts affecting behavior / scope / a public contract, it
  graduates into a tracked decision.
- **The decision row always describes the *current* form.** History is append-only
  (the trail of *why* and *when*); the table cell is a *live* value — rewrite it
  whenever the shape changes, including any helper names / files / artifacts it
  cites. The classic failure is appending a history line while leaving the row text
  describing a form you already replaced, so the row lies about what exists.
- **Separate a *decision change* from *parameter tuning*.** A change in
  behavior / shape / approach earns a History line **and** a row update. Nudging a
  tunable (a threshold, timeout, retry count, opacity, a rename) is polish — record
  the **final settled value** once, not every nudge. When unsure, treat it as a
  decision.
- **Reconcile at checkpoints, not mid-tweak.** Within a rapid loop you needn't
  rewrite the ledger after every micro-change — but you MUST reconcile (row text +
  one summarizing History line) **before committing and before `/feature review`**,
  so stored state never lags the working tree at a durable boundary.

## Feature status (coarse) vs. phase (derived)

`idea.md` carries a coarse `status:` — the single stored lifecycle marker — with exactly these values:

| `status` | Set by | Meaning |
|---|---|---|
| `idea` | `new` (initial) | captured; not yet built |
| `review` | `review` (gate opened, code/tasks complete, human sign-off pending) | **built but NOT signed off** — verification debt; never call this "done" |
| `done` | `review` (all gates pass + sign-off) | shipped and signed off |
| `dropped` | `decide` (when every decision ends `removed`) | feature killed; no work generated |
| `superseded` | when a feature is re-homed into another (scope moved, not killed) | requirement still lives, but tracked elsewhere; add `superseded-by: FEATURE-NNN` and keep the folder for the audit trail |

A feature whose code/tasks are complete but whose human/visual sign-off hasn't
happened carries **`status: review`** — *not* `idea` (it's built, not unstarted) and
*not* `done` (it's not signed off). This is the first-class coarse marker behind the
no-"done-pending" rule below, and it mirrors the [[tasks]] skill's `review` task status.

`status.md` shows a richer **phase** (`idea · prototyping · deciding · building · review · done`) that `status` does **not** duplicate — phase is *derived* by the `status` verb from the data (decisions + task progress) and the coarse marker. For a killed or re-homed feature the phase simply **mirrors the coarse marker** (`dropped` / `superseded`) — those two are terminal mirrors, not derivable phases, so the full rendered set is the six derived values plus the two mirrors. Stored marker = `status`; computed display = phase. Don't hand-maintain phase.

### `done` means signed off — there is no "done, pending"

A feature is **`done` only after the `review` gate passes, including the human
visual/manual sign-off** (Gate B/C). Code merged + tests green is **not** done — it
is phase `review` (awaiting sign-off). This is a hard rule with two corollaries:

- **Never write a hybrid like "✅ done (sign-off pending)"** in any artifact —
  `idea.md`, `status.md`, `docs/features/README.md`, the EPIC table, a task
  dashboard, or a chat reply. "done" with a qualifier is the exact failure that
  lets unverified work read as finished. If sign-off hasn't happened, the word is
  **`review` / "awaiting sign-off"**, never "done".
- Automated tests / a CI pass are not enough on their own. A change with any visual,
  UX, or multiplayer surface needs Gate B (a human ran the test plan) before `done`.

### Verification debt surfaces first — before any new scope

When you render the feature list (bare `/feature`, `show`, the `status` digest) or
**answer any "what's next?" question**, features in phase `review` (shipped,
awaiting sign-off) are **outstanding work** and lead the output — listed *above*
`idea`/`planned` features. Finishing what's in flight (closing the sign-off on the
last thing built) takes priority over starting new scope. Never headline "all
shipped / N/N tasks done" while a `review`-phase feature exists — that buries the
debt. State the pending sign-off as the next action, then mention new features.

### Changing a closed (`done`) feature — surface-dependent revert

A change can land on a feature that is **already signed off** (a later tweak, a
follow-up request, an agent revisiting shipped code). It is *not* a silent edit — it
is a tracked decision change plus a status question.

**First, if the change has a human-verifiable surface (visual / UX / feel),
preview before you edit.** Show a mockup or 2–3 concrete options and get the user's
pick *before* touching the live files — the same "lean toward a prototype for
look/UX work" rule below applies to *changing* a shipped surface, not just to new
features. Editing a signed-off visual surface straight off skips the stakeholder's
choice and pre-commits them to whatever you picked; a request that reads like "a
small CSS fix" is still a change to a stakeholder-facing surface. Then handle both
halves:

1. **Re-home to the owner.** Record the change in the feature that *owns* the
   affected behavior, not the one you happened to be working in when you hit it. (A
   tick-rate tweak noticed while theming the planet belongs to the cadence/rendering
   decision; the theming feature stays untouched.) Rewrite the decision row to its
   current form + append a History line — same as *Tracking decisions as they
   evolve* above.
2. **Trace the ripple.** A changed decision routinely touches more than its own
   feature — downstream constants, code comments, *another feature's* decision text.
   Fix every stale reference so no artifact lies about the new value.
3. **Surface-dependent revert (the status rule).** If the change has a
   **human-verifiable surface** (visual / UX / multiplayer / feel), the owning
   feature reverts **`done → review`** and the task(s) implementing the changed
   surface reopen **`done → review`** (re-run their `## Human test plan` before
   re-closing) — it now carries fresh verification debt and surfaces first, like any
   `review`-phase work. If the change is **fully covered by automated tests** (Gate
   A, nothing for a human to check), the feature and its tasks stay `done`. Never
   leave an unverified visual/behavioral change reading as `done`.
4. **Regenerate the rollups — the revert isn't done until the derived views agree.**
   After flipping `idea.md` `status` and the task statuses, **re-run `/feature status`
   for the feature** so `status.md`'s phase recomputes to `review`, and update the
   `docs/features/README.md` index row. `status.md` is *derived*, not hand-edited:
   skipping this is the classic failure where `idea.md`/tasks/index all say `review`
   but the stale `status.md` still reads `done` — the rollup the stakeholder actually
   opens ends up lying. The revert touches **four** surfaces — `idea.md`, the task
   file(s), `status.md`, and the index — reconcile all four in the same pass.

This is the *down-the-tree* counterpart to the [[tasks]] skill's roll-up rule:
reopening a feature reopens its implementing tasks; closing the last reopened task
re-closes the feature at the next `/feature review`.

### Field feedback re-enters the lifecycle — it's a loop, not a line

Work doesn't only flow idea → done; signal flows back. A production signal — a user
report, an incident, a monitoring alert — gets the same right to re-enter as a
test-found bug does (the [[tasks]] / [[populate-tests]] feedback loop). Route it by
*nature*, the same router as `new`:

- **Missing capability** the field exposed (it has open questions again) → a new
  `/feature new`, or a new `proposed` decision on the owning feature.
- **A `removed`/`deferred` decision overturned by evidence** → **reopen it** via
  `/feature decide` — a new `proposed` row linking the superseded one (see decide.md's
  reopen edge case). The original "why" and the reversal both stay auditable.
- **A regression in shipped behavior** → a [[tasks]] bug, which under the
  surface-dependent-revert rule above may also flip the owning feature `done → review`.

Nothing in the ledger is terminal; `removed` is a state, not a tombstone.

## The prototype step is a recorded decision, not a silent skip

`prototype` is opt-in (a separate verb), but **whether you prototype must be an
explicit, recorded choice** — never just absent. Every feature's `idea.md` carries
a `## Prototype` line, exactly like the per-task `## Human test plan` carries an
explicit "N/A — covered by tests":

- **Built** → `Built — <prototype.html | .md | spike link>`.
- **Skipped** → `Skipped — <reason>` (e.g. "headless engine; the test suite is the
  proof", or "built as a runnable increment; the live app was the prototype,
  validated at sign-off").
- **N/A / Pending** → for superseded features, or stubs not yet reached.

If the line is missing, that's the bug — an absent prototype reads as an omission,
not a decision. **Lean toward actually building one for pure look/UX features**
(a static style mockup is cheap and prevents building the wrong feel); lean toward
skipping for headless logic and for small increments you can validate by running.

## Collection pass

Shared by the bare-`/feature` listing and `status` — and **owned by [[roadmap]]**, not here.
Run the [[roadmap]] skill's [Cross-tree pass](../roadmap/SKILL.md#cross-tree-pass-shared-engine)
and consume its output model; don't re-implement the enumeration or the join. Its step 2 already
reads each feature's decision counts by state, coarse `status`, phase, title, and `## Prototype`
line; step 3 joins tasks via `feature: FEATURE-NNN` back-links. Two feature-side notes:

- Bucket each feature's tasks by status (todo/in-progress/review/blocked/done/cancelled) from the
  model's task collection — `review` matters: phase derivation and verification-debt ordering both
  need it.
- The model's `divergences` come along for free — the bare-`/feature` listing may surface them
  (one `⚠ DV<n>` mark per affected feature), same rules as `/roadmap --check`.

One engine, many renderers: [[roadmap]] owns the join + divergence rules; this skill only renders
feature-centric slices of the model.

## Conventions

- **No `Co-Authored-By:` trailers** in commits this skill produces (user preference).
- PowerShell-compatible (no `2>/dev/null`, no inline `VAR=x cmd`).
- A decision row is never deleted — `removed` is a state, not a deletion. The ledger must stay auditable for stakeholders.
- Don't invent decisions the user/stakeholder never made. `proposed` rows come only from the grill or explicit user input.
- Stakeholder-facing files (`idea.md`, `status.md`, `decisions.md`) avoid code jargon — a PM/stocktaker reads them.
- **Never silently displace planned scope.** When a new feature reuses a planned slot (an epic's story line, a roadmap entry, an ID) or a feature is renamed/re-scoped, the *original* scope must be **re-homed into its own tracked feature/story**, not overwritten. A requirement that was once on the roadmap and is no longer tracked anywhere is a regression in the plan. (Failure mode this guards against: a planned story's slot is renamed or reused for new scope, and the original requirement silently disappears until someone notices it's gone.) When in doubt, keep a requirement→feature traceability table in the owning EPIC and reconcile it whenever the roadmap shifts.

## Related skills

- [[grill-me]] — the engine of `feature new`. Its interview output *is* the proposed decision tree. Default-on at `new`, skippable for tiny features.
- [[tasks]] — decomposition + tracking target. `decompose` calls `/tasks new --from-feature`; tasks carry `feature:` frontmatter; the `## Human test plan` lives in the TASK file.
- [[code-review]] — correctness review. Runs **per task** at each `/tasks close` (the merge gate, where code is reviewed once); `/feature review` may run it once more on the *cumulative* diff only to catch cross-task integration issues — the gate is per-task, not feature-wide.
- [[verify-conventions]] — adherence lint against `CLAUDE.md § Conventions`; flags a new cross-cutting pattern that wasn't recorded (register-on-introduce). Runs per task at `/tasks close` alongside `code-review`; `/feature review` only *confirms* a new pattern got recorded.
- [[review]] — reviews the **PR diff** on GitHub at `/tasks close` (the per-task merge gate), complementing the working-tree `code-review`.
- [[populate-tests]] — turns each task/surface into standing coverage and keeps the `[auto]`/`[manual]` ledger; a field-found bug routes back here for a regression spec.
- [[specs]] — the record of *actuality* to this skill's record of *intent*. `/feature review` Gate A checks each approved decision landed in a harvested spec (`shaped-by: FEATURE-NNN` provenance, machine-written at regen time — never a hand-maintained link); a decision with no spec landing = incomplete feature. The regen diff review is where "intended change" (decisions) meets "actual change" (spec diff).
- [[roadmap]] — Unified cross-tree view of `docs/features/` + `tasks/` with a drift audit. It **owns the canonical collection + divergence engine** (a feature whose phase contradicts its linked tasks, a broken `feature:` back-link, etc.); this skill's [Collection pass](#collection-pass) delegates to it rather than re-implementing it. Run `/roadmap --check` to catch feature↔task drift before it compounds.
- [[new-project]] — creates `docs/features/` at project birth and seeds CLAUDE.md with this lifecycle so future agents follow it.
- [[handoff]] — same agent-pickable-context principle; an `idea.md` + `decisions.md` pair is effectively a feature-scoped handoff.
