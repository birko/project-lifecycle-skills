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
     features that aren't `done`/`dropped`, **verification debt first** ([SKILL.md](../SKILL.md)
     § *Verification debt surfaces first*: a feature in phase `review`, or with any task awaiting
     sign-off whatever its phase), each line showing phase + decision counts + task progress:
     ```
     1. FEATURE-007  Stock count reconciliation   review     5 decisions (4✓ 1~)  6/6 tasks   ⚠ awaiting sign-off
     2. FEATURE-030  Checkout redesign            building   4 decisions (3✓ 1 changed)  3/3 tasks   ⚠ 1 task awaiting sign-off
     3. FEATURE-011  Barcode scan on mobile       deciding   4 decisions (0✓ 4 proposed)  no tasks
     4. FEATURE-012  Bulk CSV import              building   3 decisions (3✓)  1/5 tasks
     ```
     Ask the user to pick by number or ID.

2. **Read the feature** — `idea.md` (coarse `status`, and its open-questions table per
   [questions.md](../questions.md), or the note that the section predates it), `decisions.md` (every row + state +
   `→ Tasks`), `status.md` if present (its `**Phase:**` line, for step 6), and which prototype artifact exists. Grep `tasks/` for
   `feature: FEATURE-NNN` and bucket the back-links by status.

3. **Readiness check — walk the gates in lifecycle order and stop at the first one that fails.**
   Each gate names the verb that clears it; **offer it, and on `y` chain straight into it**, then
   re-run this step so the feature can advance several stages in one sitting.

   | Gate | Fails when | Offer |
   |---|---|---|
   | **Q · Open questions** | the open-questions table has a frontier ([questions.md](../questions.md) § *The frontier*) | resume the grill there — step 3b. **Runs first: unanswered questions are what decisions are made from, so it outranks A–D. Only E outranks it** — when the feature is in `review`, lead with E |
   | **A · Decisions exist** | `decisions.md` has no rows, or only placeholder template rows | `/feature new` (re-grill) — there's nothing to build yet |
   | **B · Decisions decided** | any `proposed` rows remain | `/feature decide FEATURE-NNN` — "N decision(s) still awaiting a verdict. Decide them now? [Y/n]" |
   | **C · Prototype (soft)** | the feature is UI/UX-shaped or adds states, has approved rows, and `idea.md`'s `## Prototype` line records no prototype. Read the line, not the folder: a prototype is deleted once it has answered its question, so a missing file does not mean one was never built | `/feature prototype FEATURE-NNN` — suggest once, `[y/N]`, never block. Some approved decisions genuinely need no mockup |
   | **D · Decomposed** | any `approved`/`changed` row has an empty `→ Tasks` cell, or names tasks that don't exist on disk | **`/feature decompose FEATURE-NNN`** — the question is step 4's |
   | **E · Signed off** | phase is `review` (all tasks `done` or `verify`, sign-off not recorded), computed by [status.md](status.md) step 2, never read off `idea.md` | `/feature review FEATURE-NNN` — verification debt outranks new scope; lead with this. **Never fires beside D:** a row D would offer to decompose makes the phase `building`, so a change that is not built is offered as work, not as sign-off |

   **Gates A, B and C — the questions, and what silence does.** Each chained verb needs a person: a grill,
   a verdict, or a prototype someone looks at. So with nobody present none of them runs, and the run never
   reports one as declined. Q has its own paragraph (step 3b) and D has step 4.

   | Gate | Put this question | No answer, or nobody to ask |
   |---|---|---|
   | **A** | **FEATURE-NNN has no decisions to build from yet. Re-grill the idea with `/feature new` now? [Y/n]** | change nothing; report `not grilled: FEATURE-NNN has no decisions — nobody answered`, and stop at step 6. Nothing past A can run without decisions |
   | **B** | **FEATURE-NNN has N decision(s) still awaiting a verdict: <ids>. Decide them now? [Y/n]** | change nothing; report `not decided: <ids> still proposed — nobody answered`, and stop at step 6. A verdict nobody gave would read as decided, and C–E all read the verdicts |
   | **C** | **FEATURE-NNN is UI- or state-shaped and records no prototype. Build one with `/feature prototype` before decomposing? [y/N]** | do not prototype; report `prototype: suggested, nobody answered`, and continue to gate D. C never blocks, so silence passes it exactly as `N` does, and the suggestion comes back next run |

3b. **Gate Q — resume at the frontier.** Compute the frontier fresh. **Leave out every question claimed today by
   another name** ([questions.md](../questions.md) § *Claims*), naming each one (`Q4 is being answered by <name>
   (claimed today)`). A claim dated before today is stale: offer that question, and say you are taking it over.
   Then put this question:

   > **FEATURE-NNN has N open question(s) on the frontier: Q4 — <question>, Q6 — <question>. Resume the grill there? [Y/n]**

   If every frontier question is claimed by someone else today, do not offer: report them and continue to gate A.

   - `Y` → **claim each question just before you put it or look it up** (`claimed-by: <name> on <today>`). Put the
     frontier's `decision` questions to the user (through [[grill-me]] when installed), and look up its
     `research` questions yourself — a fact is the agent's job, not the user's. A lookup that finds nothing or
     finds answers that disagree is marked `open — lookup failed: <why>` and put to the user, never dropped. For each answer, set the
     state per [questions.md](../questions.md) § *States* — a `decision` answered writes a `proposed` row to
     `decisions.md` and `resolved → Dn` here; a question the user rules moot is `dropped — <reason>` and leaves
     every `blocked-by`; either way its claim goes back to `—`. Recompute the frontier and offer the next one, until
     it is empty or the user stops. **When the session stops — the user stops, or no answer comes — clear every
     claim this session wrote, and only those.** Then re-run step 3.
   - `n`, or **no answer** → change nothing; report `not resumed: N open question(s) on the frontier — <ids>`
     and continue to gate A. The questions stay on disk; nothing is lost by declining.
   - **Open rows but no frontier** → do not offer; report it as itself — *"N open questions, none answerable
     now: Q7 waits on Q8, Q8 waits on Q7"* (or the broken edge, by id) — and continue to gate A.
   - **No open rows in a current table** → the gate passes silently.
   - **No open-questions section** ([questions.md](../questions.md) § *Current or pre-table*) → do not offer, and
     never report *no open questions*. Report `open questions: no section in idea.md — none recorded` and continue
     to gate A.
   - **A pre-table section** (a bulleted or prose list, [questions.md](../questions.md) § *Current or
     pre-table*) → never report *no open questions*. Unless it carries the declined line, put this question:

     > **FEATURE-NNN's open questions are in the earlier format (N item(s)), so no frontier can be computed. Bring them into the question table now? [Y/n]**

     - `Y` → upgrade the section in place, exactly as [questions.md](../questions.md) § *Bringing a pre-table
       section up to date* says, print its report line, then run this gate again on the result.
     - `n` → write the declined line that section defines, report `open questions: pre-table, kept by choice on
       <date>`, and continue to gate A.
     - **No answer** → change nothing, report `open questions: pre-table — N item(s) in the earlier format`, and
       continue to gate A. Silence is not a no, so the offer comes back next run.
     - **Declined line present** → do not offer; report `open questions: pre-table, kept by choice on <date>`
       and continue to gate A.

4. **Gate D is the important one — default yes, and say why on a refusal.** List exactly which
   rows are uncovered before asking, so the offer is concrete:
   ```
   Not decomposed:
     D2  Warn on negative delta        approved   → no tasks
     D4  Export count sheet as PDF     changed    → no tasks
   FEATURE-NNN has 2 approved or changed decision(s) with no tasks: D2, D4. Decompose now? [Y/n]
   ```
   That last line is the question, word for word.
   - `Y` → chain [decompose.md](decompose.md) for **only** the uncovered rows (it reconciles
     against the `→ Tasks` column, so partial decomposition is safe), then continue to step 5.
   - `n` → **print the task-first gate, don't just move on**: "Implementation code must never
     precede task creation. Without tasks there's nothing to pick, and code written now has to be
     backfilled." Then stop at step 6 without handing off to work. `pick` will not start
     implementation on an undecomposed feature.
   - **No answer, or nobody to ask** → do not decompose, and do not hand off. Report
     `not decomposed: <row ids> with no tasks — nobody answered`, print the task-first gate as for `n`,
     and stop at step 6. The `Y` default does not apply: decompose files tasks and asks where to place them,
     so running it with nobody present makes placements and a task split nobody chose. Silence is not a no
     either, so nothing is recorded as declined and the offer comes back next run.
   - A row whose `→ Tasks` names a `TASK-NNN` that no longer exists on disk is a **broken link**,
     not a decomposed row — treat it as uncovered and flag the dangling ID.

5. **Hand off to work** (all gates clear, tasks exist):
   - Chain `/tasks pick --feature FEATURE-NNN` — the task tree owns the work loop from here
     (branch, plan, implement, close). Don't re-implement the picker.
   - Surface this feature's tasks already `in-progress` or awaiting verification (`review`/`verify`) **first** — an in-review task
     is finished code awaiting a human step; closing it out beats starting a new one.
   - If every task is `done` but sign-off isn't recorded, that's gate E — route to
     `/feature review`, not to more work.

6. **Confirm** — print the feature title + derived phase, the open-questions line
   (exactly one report line from [questions.md](../questions.md) § *Current or pre-table*, or its `brought up to
   date` line when this run upgraded the section), which gate fired, what was chained, and the next action, stated once. On a debt feature
   ([SKILL.md](../SKILL.md) § *Verification debt surfaces first*), that line names its tasks awaiting sign-off
   first and the offer from the gate that fired second:
   `Next: sign off TASK-NNN (run its human test plan, then /tasks close TASK-NNN), then decompose D2, D4`.
   Gate D outranks `/feature review`, the feature's own sign-off, never a task's: those tests are built and
   waiting, so leaving them out would hide the debt the listing led with.
   When `status.md` exists and its `**Phase:**` line differs from the derived phase, also report
   `status.md says <stored>, derived <phase> — refresh with /feature status FEATURE-NNN`. Compare after any
   verb this run chained, each of which re-runs `/feature status`, so a gap still showing comes from a hand
   edit or a skipped write. Report it and nothing more: `pick` writes no rollup. Never report a feature as `done` when sign-off is pending
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
  `changed` decision first. A change to a human-verifiable surface sends the implementing task back to
  `verify` when the change is already built, and otherwise arrives as new work to decompose
  ([decide.md](decide.md) § *Changing a closed feature*).
- **Mixed states** — some rows decomposed, others not, plus leftover `proposed` rows: gates run in
  order, so `decide` clears first, then `decompose` picks up everything approved in that pass. One
  `pick` can legitimately chain decide → decompose → tasks pick. **Except with an upstream:** a `decide`
  that pushed `record/FEATURE-NNN` restored this copy's ledger, so the chain stops there. Report the
  branch and that decompose waits until it lands ([decide.md](decide.md) step 7).
- **`deferred` rows only** (nothing approved) — nothing to build. Show the unblock conditions and
  stop; don't offer decompose on a feature whose every live row is parked.
- **No `docs/features/` at all** — the project hasn't adopted the feature lifecycle. Point at
  `/feature new` (or [[new-project]] for a fresh repo) instead of erroring.
