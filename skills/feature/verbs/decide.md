# /feature decide — stamp each decision's state

Walk the `proposed` decisions (and revisit older ones) and record the stakeholder's verdict with rationale. This is the approval gate.

## Steps

1. **Locate the feature** and read `decisions.md`.

2. **Show the undecided rows** — list every `proposed` decision (and any `deferred` ones up for revisit). For each, drive a verdict via `AskUserQuestion` (or take the user's batch input if they dictate several at once):

   | State | Pick when | Must also capture |
   |-------|-----------|-------------------|
   | `approved` | build it as proposed | rationale (1 line) |
   | `changed` | build it, but altered | **the delta** — what changed vs. the original, and why |
   | `deferred` | good, not now | the **unblock condition** (what must be true to revisit) |
   | `removed` | rejected / out of scope / out of budget | rationale |

3. **Record who decided** — `By` column: the stakeholder/role (PM, product owner, end user). If the user is relaying a stakeholder's call, capture the stakeholder, not "ai".

4. **Update `decisions.md`:**
   - Set each row's `State`, `Rationale`, `Date`, `By`.
   - For `changed`, write the delta into the Decision/Rationale cell so the new shape is unambiguous for `decompose`.
   - **Append a History log line** per change: `{{DATE}} — D3 proposed → removed (out of budget, per PM)`. Never overwrite history; append.

5. **Confirm + next step:**
   - Summarize counts (`3 approved, 1 changed, 1 deferred, 2 removed`).
   - If any `approved`/`changed` exist → "Decompose into tasks: `/feature decompose FEATURE-NNN`".
   - If `proposed` remain → note how many still need a verdict.
   - Chain `/feature status FEATURE-NNN` (single-feature mode) automatically to refresh the rollup + index row — a suggestion the user can skip leaves the stakeholder view stale.

## Deciding rules

- **Track by impact, not by source.** A choice belongs in `decisions.md` if it changes the
  feature's observable behavior, scope, contract, or an already-recorded decision — whether it
  came from a grill, a stakeholder demo, a review, or the agent discovering mid-implementation
  that the approved plan won't work. Pure implementation detail (internal naming, data
  structures, algorithms with no observable effect) stays in code and `architecture.md`.
- **The row is live, History is append-only.** Rewrite the row to the *current* form whenever
  the shape changes; the trail of why/when lives in History lines. A row describing a form you
  already replaced is the classic lie.
- **Decision change ≠ parameter tuning.** A change in behavior/shape/approach earns a History
  line and a row update; nudging a tunable records only the final settled value. When unsure,
  treat it as a decision.
- **Reconcile at checkpoints** — row text + one summarizing History line before committing and
  before `/feature review`, so stored state never lags the working tree at a durable boundary.

## Changing a closed (`done`) feature — surface-dependent revert

A later change to a signed-off feature is a tracked decision change plus a status question,
never a silent edit:

1. **Preview before editing a human-verifiable surface** (visual/UX/feel): show a mockup or
   2–3 options and get the user's pick before touching live files — "a small CSS fix" is still
   a change to a stakeholder-facing surface.
2. **Re-home to the owner** — record the change in the feature that *owns* the affected
   behavior, not the one you were working in; rewrite its row + append a History line.
3. **Trace the ripple** — fix downstream constants, comments, and other features' decision text
   so no artifact lies about the new value.
4. **Status rule:** a change with a human-verifiable surface reverts the owning feature **and**
   its implementing task(s) `done → review` (re-run their Human test plans before re-closing);
   a change fully covered by automated tests stays `done`. Then re-run `/feature status` so
   `status.md` and the index recompute — the revert touches four surfaces (`idea.md`, task
   file(s), `status.md`, index) and isn't done until all four agree.

## Edge cases

- **Re-deciding an approved item later** — allowed; e.g. `approved → removed` after a failed spike. Append the reason to History; if tasks were already created, note they should be cancelled (`/tasks` — set status `cancelled`, don't delete).
- **Decision with no clear owner** — don't fabricate one; mark `By: —` and flag in History that it needs stakeholder confirmation.
- **User wants to add a brand-new decision now** — add a fresh row (`proposed`) then stamp it; record in History.
- **Reopening a `removed`/`deferred` decision from field evidence** — production feedback (a user demand, an incident, a monitoring signal) can overturn a past "no". Don't edit the old row: add a **new `proposed` row** that references the superseded one (e.g. "supersedes D4, removed 2026-03"), append a History line (`D4 removed → reopened: customers keep hitting it, per ops`), then stamp the new row like any other. The old row stays — both the original "why" and the reversal are auditable. This is the [[tasks]] / [[populate-tests]] feedback loop reaching the decision tree; a `deferred` row's unblock condition is exactly this trigger.
- **Everything removed** — that's a valid outcome (feature killed). Set `idea.md` frontmatter `status: dropped` and append a History line. No tasks generated.
- **A decision changes mid-build, from any trigger** — whether a stakeholder demo, a review, or the **agent discovering during coding** that the approved approach won't work, log it the same way: a History line for the change + rewrite the row to the current form (the Deciding rules above apply regardless of who or what triggered the change).
