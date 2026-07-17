# /feature decompose — turn approved decisions into tracked tasks

Bridge from the stakeholder ledger to the dev tracker. Only `approved` and `changed` decisions generate tasks.

## Hard rule: task-first gate

**Implementation code must never precede task creation.** Decompose runs — and the tasks exist (`status: todo`, with acceptance criteria) — before any code is written for a feature. If code was already written before decomposing: **stop implementing**, backfill the task(s) via step 3 with honest status (`in-progress`, never straight into `review`/`done`), note the backfill in the decision's History line, then continue. Backfilling is the recovery path, not an alternative to the gate.

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

4. **Verify the `→ Tasks` column** in `decisions.md` — `/tasks new --from-feature` writes each created `TASK-NNN` into its decision's row as it goes (its ledger-backfill step 10b); confirm every row is complete and fill any gap. Then append one History line per decision: `{{DATE}} — D1 (approved) decomposed → TASK-051, TASK-052`.

5. **Refresh the rollup + confirm:**
   - Chain `/feature status FEATURE-NNN` (single-feature mode) automatically — don't just suggest it; the rollup and index row must never lag a decomposition.
   - List the created tasks per decision.
   - "Track progress in `/tasks` (they carry `feature: FEATURE-NNN`)."

## Edge cases

- **`changed` decision** — decompose the *changed* shape (per the delta in the row), not the original idea.
- **Decision already has tasks** (re-decompose) — only create tasks for the unaddressed part; don't duplicate. Reconcile against the `→ Tasks` column.
- **Decision too big to be one task** — that's expected; split into several. If it's really story-sized, make it a STORY and put its tasks under it.
- **No approved/changed decisions** — nothing to do; point the user at `/feature decide`.
