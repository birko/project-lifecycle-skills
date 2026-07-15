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

3. **Record who decided** — `By` column: the stakeholder/role (PM, stocktaker, user). If the user is relaying a stakeholder's call, capture the stakeholder, not "ai".

4. **Update `decisions.md`:**
   - Set each row's `State`, `Rationale`, `Date`, `By`.
   - For `changed`, write the delta into the Decision/Rationale cell so the new shape is unambiguous for `decompose`.
   - **Append a History log line** per change: `{{DATE}} — D3 proposed → removed (out of budget, per PM)`. Never overwrite history; append.

5. **Confirm + next step:**
   - Summarize counts (`3 approved, 1 changed, 1 deferred, 2 removed`).
   - If any `approved`/`changed` exist → "Decompose into tasks: `/feature decompose FEATURE-NNN`".
   - If `proposed` remain → note how many still need a verdict.
   - Suggest `/feature status FEATURE-NNN` to refresh the stakeholder rollup.

## Edge cases

- **Re-deciding an approved item later** — allowed; e.g. `approved → removed` after a failed spike. Append the reason to History; if tasks were already created, note they should be cancelled (`/tasks` — set status `cancelled`, don't delete).
- **Decision with no clear owner** — don't fabricate one; mark `By: —` and flag in History that it needs stakeholder confirmation.
- **User wants to add a brand-new decision now** — add a fresh row (`proposed`) then stamp it; record in History.
- **Reopening a `removed`/`deferred` decision from field evidence** — production feedback (a user demand, an incident, a monitoring signal) can overturn a past "no". Don't edit the old row: add a **new `proposed` row** that references the superseded one (e.g. "supersedes D4, removed 2026-03"), append a History line (`D4 removed → reopened: customers keep hitting it, per ops`), then stamp the new row like any other. The old row stays — both the original "why" and the reversal are auditable. This is the [[tasks]] / [[populate-tests]] feedback loop reaching the decision tree; a `deferred` row's unblock condition is exactly this trigger.
- **Everything removed** — that's a valid outcome (feature killed). Set `idea.md` frontmatter `status: dropped` and append a History line. No tasks generated.
- **A decision changes mid-build, from any trigger** — whether a stakeholder demo, a review, or the **agent discovering during coding** that the approved approach won't work, log it the same way: a History line for the change + rewrite the row to the current form. Track by impact (observable behavior / scope / contract / a recorded decision), not by source; keep pure implementation detail in code/commits/`architecture.md`. Fold repeated parameter tuning into one settled value, and reconcile before commit / `/feature review`. See [SKILL.md → Tracking decisions as they evolve](../SKILL.md#tracking-decisions-as-they-evolve-any-stage-any-trigger).
