# /tasks plan — draft an implementation plan for a TASK

Spawn the `Plan` subagent against a TASK file, write the result into a `## Implementation plan` section, then optionally hand off to `grill-me` to stress-test it.

Only operates on TASKs. EPICs and STORIES are containers — they don't get plans.

## Args

- Bare ID (`/tasks plan TASK-014`) — required; the TASK to plan against.
- `--replan` — required to overwrite an existing non-empty `## Implementation plan` section. Without it, refuse and tell the user to add the flag.
- `--no-grill` — skip the grill prompt at the end (default is to ask).

## Steps

1. **Find task root** using shape detection.

2. **Locate the TASK file** — grep for `^id: TASK-NNN$` in the task root. Error if missing or if the ID resolves to an EPIC/STORY.

3. **Read the TASK file** in full. Capture: title, `## Context`, `## Acceptance criteria`, `## Out of scope`, and any existing `## Implementation plan` content.

4. **Replan guard**:
   - If `## Implementation plan` section exists AND its body is non-empty AND user did not pass `--replan` → refuse. Print: "This task already has an implementation plan. Re-run with `--replan` to overwrite." Exit.
   - If the section exists but is empty (just the placeholder from the template) → proceed without `--replan`.

5. **Spawn the `Plan` subagent** via the Agent tool with `subagent_type: Plan`. Brief it with:
   - The TASK title.
   - The TASK's `## Context`, `## Acceptance criteria`, and `## Out of scope` sections verbatim.
   - The file path of the TASK so the agent can read related code from the repo.
   - Explicit scope: "Produce an implementation plan against the **existing** acceptance criteria. Do not propose changes to the criteria themselves. If you believe a criterion is wrong, missing, or ambiguous, surface it as a single note prefixed with `⚠ Acceptance criteria question:` at the top of your output — the human decides whether to edit the TASK."
   - Output shape: step-by-step plan, critical files to touch, architectural tradeoffs, anything risky. Markdown, no preamble.

6. **Write the draft** into the TASK file:
   - Replace the `## Implementation plan` section body with the agent's output. If the section doesn't exist (older TASK file pre-dating the template change), append it after `## Out of scope`.
   - Preserve any `⚠ Acceptance criteria question:` notes the agent emitted — keep them at the top of the section so the human sees them on next read.

7. **Offer to grill** (unless `--no-grill`):
   - Print: "Draft plan written. Grill it via `grill-me`? [y/N]"
   - `y` → invoke the `grill-me` skill via Skill, passing the TASK title + the draft plan as context. The user defends the decisions against the grilling questions. When grilling concludes, write the refined plan back into the same `## Implementation plan` section (overwrite the draft).
   - `N` → leave the draft as-is.

8. **Confirm** — print:
   - File path
   - Whether grilling ran
   - Next-step hint: "Start work with `/tasks pick {{ID}}`"

## Edge cases

- **ID not found** — error with the resolved task root path so user can verify they're in the right place.
- **ID is EPIC/STORY** — error: "Plans only apply to TASKs. EPICs and STORIES are containers."
- **TASK has no `## Context` or `## Acceptance criteria`** — warn ("planning a thinly-specified task — the plan will be vague") but proceed; pass whatever exists to the Plan agent.
- **Plan agent fails or returns empty** — leave the TASK file untouched, report the failure, don't write a half-section.
- **`--replan` on an in-progress task** — extra confirm: "This task is `status: in-progress`. Overwrite the existing plan? [y/N]". Prevents accidentally nuking a plan that work is already running against.
- **Grill refuses or aborts mid-way** — keep the original draft in the TASK file; don't lose it.
