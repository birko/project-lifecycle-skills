# /feature decompose — turn approved decisions into tracked tasks

Bridge from the stakeholder ledger to the dev tracker. Only `approved` and `changed` decisions generate tasks.

## Steps

1. **Locate the feature** and read `decisions.md`. Collect the rows in state `approved` or `changed`. Ignore `proposed` (not decided yet — tell the user to `/feature decide` first), `deferred`, and `removed`.

2. **Check for an owning EPIC/STORY** (optional but recommended):
   - A feature usually maps to one STORY (a user behaviour) or a small EPIC. Ask the user whether to attach the tasks under an existing epic/story, create one, or leave them loose.
   - If creating, chain `/tasks new epic` / `/tasks new story` first so the tasks have a parent.

3. **Decompose each approved/changed decision into one or more small tasks:**
   - Keep tasks atomic and independently completable (the [[tasks]] granularity rule). A decision may yield several tasks.
   - For each task, call `/tasks new task --from-feature FEATURE-NNN --no-plan` (batch mode), passing the parent chosen in step 2. The `--from-feature` flag makes `/tasks new`:
     - stamp `feature: FEATURE-NNN` in the task frontmatter,
     - pull Context from the decision row + `idea.md` (no re-asking),
     - draft the `## Human test plan` from the prototype + decision (UI/UX, edge cases, integrations) — or mark `N/A` when automated tests fully cover it.
   - Drop `--no-plan` (or run `/tasks plan` after) if you want the per-task implementation plan drafted now.

4. **Backfill the `→ Tasks` column** in `decisions.md` — write the created `TASK-NNN` IDs into each decision's row so the ledger shows what each decision became. Append a History line: `{{DATE}} — D1 (approved) decomposed → TASK-051, TASK-052`.

5. **Confirm + next step:**
   - List the created tasks per decision.
   - "Track progress in `/tasks` (they carry `feature: FEATURE-NNN`)."
   - "Refresh the stakeholder rollup: `/feature status FEATURE-NNN`."

## Edge cases

- **`changed` decision** — decompose the *changed* shape (per the delta in the row), not the original idea.
- **Decision already has tasks** (re-decompose) — only create tasks for the unaddressed part; don't duplicate. Reconcile against the `→ Tasks` column.
- **Decision too big to be one task** — that's expected; split into several. If it's really story-sized, make it a STORY and put its tasks under it.
- **No approved/changed decisions** — nothing to do; point the user at `/feature decide`.
