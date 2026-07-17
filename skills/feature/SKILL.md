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

Same project-root resolution as the [[tasks]] skill's shape detection: walk up to the project root (`*.slnx`/`*.sln`, then `.git`). Place `docs/features/` under the project root. In a polyrepo family with an aggregator repo (see the tasks skill's shape-detection override), a cross-cutting feature lives in the aggregator's `docs/features/`; a sub-project feature lives in that sub-repo's own `docs/features/`. If `docs/` doesn't exist, create `docs/features/` (don't disturb existing docs).

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

**Track by impact, not by source** — a choice is ledger-worthy if it changes observable
behavior, scope, contract, or a recorded decision, *even when the agent (not a human) made the
call mid-implementation*. Rows stay live (rewritten to the current form); History is append-only;
parameter tuning records only the settled value; reconcile before committing and before
`/feature review`. The full rules live in [decide.md § Deciding rules](verbs/decide.md) — the
verb that owns stamping.

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

A feature is **`done` only after the `review` gate passes, including the human visual/manual
sign-off** (Gate B/C — enforced in [review.md](verbs/review.md)). Code merged + tests green is
phase `review`, never `done`, and never a hybrid like "✅ done (sign-off pending)" — in *any*
artifact or chat reply. If sign-off hasn't happened, the word is **`review` / "awaiting
sign-off"**.

### Verification debt surfaces first — before any new scope

In every rendering (bare `/feature`, `show`, the `status` digest) and **any "what's next?"
answer**, phase-`review` features lead the output, above `idea`/planned ones — they're
outstanding work. Never headline "all shipped" while one exists; state the pending sign-off as
the next action first.

### Changing a closed (`done`) feature — surface-dependent revert

A change landing on a signed-off feature is a tracked decision change plus a status question,
never a silent edit: preview human-verifiable surfaces before touching them, re-home the change
to the owning feature, trace the ripple, and — if the change has a human-verifiable surface —
revert feature *and* implementing task(s) `done → review`, then re-run `/feature status` so all
four surfaces (`idea.md`, tasks, `status.md`, index) agree. Full procedure in
[decide.md § Changing a closed feature](verbs/decide.md). This is the down-the-tree counterpart
to the [[tasks]] roll-up rule: reopening a feature reopens its tasks; closing the last reopened
task re-closes the feature at the next `/feature review`.

### Field feedback re-enters the lifecycle — it's a loop, not a line

A production signal (user report, incident, monitoring alert) has the same right to re-enter as
a test-found bug: missing capability → `/feature new` or a new `proposed` decision; an
overturned `removed`/`deferred` decision → reopen via `/feature decide`; a regression →
a [[tasks]] bug (possibly triggering the revert above). Routing details live in
[new.md](verbs/new.md) + [decide.md](verbs/decide.md)'s edge cases. Nothing in the ledger is
terminal; `removed` is a state, not a tombstone.

## The prototype step is a recorded decision, not a silent skip

Whether you prototype is an **explicit, recorded choice** — every `idea.md` carries a
`## Prototype` line (`Built — <link>` / `Skipped — <reason>` / `N/A / Pending`); a missing line
is the bug. Lean toward building one for pure look/UX features, toward skipping for headless
logic. The line's states and seeding live in [new.md](verbs/new.md); `prototype` records the
`Built` value.

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
- [[code-review]] — correctness review (runtime-provided, e.g. a Claude Code built-in; the verbs carry inline fallbacks for runtimes without it). Runs **per task** at each `/tasks close` (the merge gate, where code is reviewed once); `/feature review` may run it once more on the *cumulative* diff only to catch cross-task integration issues — the gate is per-task, not feature-wide.
- [[verify-conventions]] — adherence lint against `CLAUDE.md § Conventions`; flags a new cross-cutting pattern that wasn't recorded (register-on-introduce). Runs per task at `/tasks close` alongside `code-review`; `/feature review` only *confirms* a new pattern got recorded.
- [[review]] — reviews the **PR diff** on GitHub at `/tasks close` (the per-task merge gate), complementing the working-tree `code-review`. Runtime-provided, same fallback rule.
- [[populate-tests]] — turns each task/surface into standing coverage and keeps the `[auto]`/`[manual]` ledger; a field-found bug routes back here for a regression spec.
- [[specs]] — the record of *actuality* to this skill's record of *intent*. `/feature review` Gate A checks each approved decision landed in a harvested spec (`shaped-by: FEATURE-NNN` provenance, machine-written at regen time — never a hand-maintained link); a decision with no spec landing = incomplete feature. The regen diff review is where "intended change" (decisions) meets "actual change" (spec diff).
- [[roadmap]] — Unified cross-tree view of `docs/features/` + `tasks/` with a drift audit. It **owns the canonical collection + divergence engine** (a feature whose phase contradicts its linked tasks, a broken `feature:` back-link, etc.); this skill's [Collection pass](#collection-pass) delegates to it rather than re-implementing it. Run `/roadmap --check` to catch feature↔task drift before it compounds.
- [[new-project]] — creates `docs/features/` at project birth and seeds CLAUDE.md with this lifecycle so future agents follow it.
- [[handoff]] — same agent-pickable-context principle; an `idea.md` + `decisions.md` pair is effectively a feature-scoped handoff.
