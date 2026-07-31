# /feature pick — choose a feature and enter it at the right stage

The acting front door for "I want to work on this feature". Unlike [show](show.md) (read-only),
`pick` resolves what the feature is *missing* and **offers the verb that unblocks it** — most often
`decompose`, because a feature with approved decisions and no tasks is the single most common
lifecycle stall.

`pick` never implements. It hands off to `/tasks pick` once — and only once — real tasks exist.

## Steps

1. **Resolve the feature**:
   - Bare ID (`/feature pick FEATURE-012`, or `012` if unambiguous) → skip to step 2.
   - No arg → run the [Collection pass](../SKILL.md#collection-pass) and present a numbered list of
     features that aren't `done`/`dropped`, **verification debt first** (phase `review` above
     `building` above `idea`), each line showing phase + decision counts + task progress:
     ```
     1. FEATURE-007  Stock count reconciliation   review     5 decisions (4✓ 1~)  6/6 tasks   ⚠ awaiting sign-off
     2. FEATURE-011  Barcode scan on mobile       deciding   4 decisions (0✓ 4 proposed)  no tasks
     3. FEATURE-012  Bulk CSV import              building   3 decisions (3✓)  1/5 tasks
     ```
     Ask the user to pick by number or ID.

2. **Read the feature** — `idea.md` (coarse `status`), `decisions.md` (every row + state +
   `→ Tasks`), `status.md` if present, and which prototype artifact exists. Grep `tasks/` for
   `feature: FEATURE-NNN` and bucket the back-links by status.

3. **Readiness check — walk the gates in lifecycle order and stop at the first one that fails.**
   Each gate names the verb that clears it; **offer it, and on `y` chain straight into it**, then
   re-run this step so the feature can advance several stages in one sitting.

   | Gate | Fails when | Offer |
   |---|---|---|
   | **A · Decisions exist** | `decisions.md` has no rows, or only placeholder template rows | `/feature new` (re-grill) — there's nothing to build yet |
   | **B · Decisions decided** | any `proposed` rows remain | `/feature decide FEATURE-NNN` — "N decision(s) still awaiting a verdict. Decide them now? [Y/n]" |
   | **C · Prototype (soft)** | the feature is UI/UX-shaped, has approved rows, and no prototype artifact | `/feature prototype FEATURE-NNN` — suggest once, `[y/N]`, never block. Some approved decisions genuinely need no mockup |
   | **D · Decomposed** | any `approved`/`changed` row has an empty `→ Tasks` cell, or names tasks that don't exist on disk | **`/feature decompose FEATURE-NNN` — "N approved decision(s) have no tasks. Decompose now? [Y/n]"** |
   | **E · Signed off** | phase is `review` (all tasks done/`review`, sign-off not recorded) | `/feature review FEATURE-NNN` — verification debt outranks new scope; lead with this |

4. **Gate D is the important one — default yes, and say why on a refusal.** List exactly which
   rows are uncovered before asking, so the offer is concrete:
   ```
   Not decomposed:
     D2  Warn on negative delta        approved   → no tasks
     D4  Export count sheet as PDF     changed    → no tasks
   Decompose these 2 decisions into tasks now? [Y/n]
   ```
   - `Y` → chain [decompose.md](decompose.md) for **only** the uncovered rows (it reconciles
     against the `→ Tasks` column, so partial decomposition is safe), then continue to step 5.
   - `n` → **print the task-first gate, don't just move on**: "Implementation code must never
     precede task creation. Without tasks there's nothing to pick, and code written now has to be
     backfilled." Then stop at step 6 without handing off to work. `pick` will not start
     implementation on an undecomposed feature.
   - A row whose `→ Tasks` names a `TASK-NNN` that no longer exists on disk is a **broken link**,
     not a decomposed row — treat it as uncovered and flag the dangling ID.

5. **Hand off to work** (all gates clear, tasks exist):
   - Chain `/tasks pick --feature FEATURE-NNN` — the task tree owns the work loop from here
     (branch, plan, implement, close). Don't re-implement the picker.
   - Surface this feature's tasks already `in-progress` or `review` **first** — an in-review task
     is finished code awaiting a human step; closing it out beats starting a new one.
   - If every task is `done` but sign-off isn't recorded, that's gate E — route to
     `/feature review`, not to more work.

6. **Confirm** — print the feature title + derived phase, which gate fired, what was chained, and
   the single concrete next action. Never report a feature as `done` when sign-off is pending
   (SKILL.md § `done` means signed off).

## Working inside a picked feature

Once work starts, two standing rules keep the feature honest — surface them at handoff:

- **New scope discovered mid-work gets its own task, never an extra criterion on the one in hand**
  — run `/tasks spawn`, which inherits `feature: FEATURE-NNN` and reconciles this ledger (a new
  `proposed` row when no decision covers the discovery, so it comes back through `decide`).
- **Choices made mid-implementation that change observable behaviour, scope, or contract are
  ledger-worthy** even though no stakeholder was in the room — record them via
  [decide.md § Deciding rules](decide.md).

## Edge cases

- **Feature is `dropped`** — refuse: every decision was `removed`. Suggest `/feature new` if the
  idea is genuinely back, or `/feature decide` to reopen a specific row with a new `proposed` row.
- **Feature is `superseded`** — redirect to the `superseded-by: FEATURE-NNN` target; don't start
  work on the shell.
- **Feature is `done`** — confirm intent. New work on a signed-off feature reopens it: record a
  `changed` decision first (and per SKILL.md, a change to a human-verifiable surface sends the
  implementing task back to `review`).
- **Mixed states** — some rows decomposed, others not, plus leftover `proposed` rows: gates run in
  order, so `decide` clears first, then `decompose` picks up everything approved in that pass. One
  `pick` can legitimately chain decide → decompose → tasks pick.
- **`deferred` rows only** (nothing approved) — nothing to build. Show the unblock conditions and
  stop; don't offer decompose on a feature whose every live row is parked.
- **No `docs/features/` at all** — the project hasn't adopted the feature lifecycle. Point at
  `/feature new` (or [[new-project]] for a fresh repo) instead of erroring.
