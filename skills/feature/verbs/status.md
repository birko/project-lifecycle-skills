# /feature status — regenerate the stakeholder rollup

Rebuild `status.md` for a feature (or all features) so a PM/stocktaker can see where it stands without reading code or task files.

## Steps

1. **Run the [Collection pass](../SKILL.md#collection-pass)** for the target feature (or all features if no ID given).

2. **Compute the phase** — derive from the data:
   - `idea` — only `idea.md` exists, no decisions stamped, no prototype.
   - `prototyping` — a prototype artifact exists, decisions still mostly `proposed`.
   - `deciding` — prototype done, `proposed` rows still outnumber decided ones.
   - `building` — has `approved`/`changed` decisions with tasks, not all done.
   - `review` — `idea.md` status `review`, OR all feature tasks `done`/`review` but not yet signed off. (Client tasks awaiting sign-off carry `status: review` too.)
   - `done` — reviewed + signed off (`idea.md` status `done`).
   - `dropped` — `idea.md` status `dropped` (every decision was `removed`); show the rollup but mark it killed.
   - `superseded` — `idea.md` status `superseded` (scope re-homed into another feature); show the rollup with the `superseded-by:` pointer.
   - (`dropped`/`superseded` are terminal **mirrors of the coarse marker**, not derived phases — see [SKILL.md](../SKILL.md#feature-status-coarse-vs-phase-derived).)

3. **Cross-reference tasks** — Grep `tasks/` for `feature: FEATURE-NNN`; bucket by status; compute `done/total`. List them with their IDs and titles. Mark which have a ready (filled, non-`N/A`) `## Human test plan` for the "what can be tested now" section.

4. **Render** [templates/status.md](../templates/status.md) — fill decision counts by state, build progress, and:
   - `{{TESTABLE_SUMMARY}}` — the tasks whose Human test plan is filled and ready to run.
   - `{{PROTOTYPE_LINK}}` — link to `prototype.html` / `prototype.md` / the spike branch, or "none yet".
   - `{{NEXT_STEP}}` — one concrete action, e.g. "PM to review 2 proposed decisions", "3 tasks in progress", "ready for /feature review".
   (The template is stakeholder-facing and carries no author comments — these hints live here.)

5. **Write** `docs/features/FEATURE-NNN-slug/status.md` (overwrite).

6. **If invoked for all features** — also print a one-line-per-feature digest to stdout:
   `FEATURE-012 Stocktake redesign — building (4/7 tasks, 3 approved / 1 deferred)`.
   **Order the digest with phase-`review` (awaiting sign-off) features first** — they
   are outstanding verification debt and are the next action, ahead of `idea`/planned
   ones (see [SKILL.md](../SKILL.md#verification-debt-surfaces-first--before-any-new-scope)).
   A feature whose tasks are all `done` but unsigned prints as `review (awaiting
   sign-off)`, never `done`.

7. **Regenerate the features index** (all-features mode only) — this verb **owns**
   `docs/features/README.md`, the human entry-point index. From the same collection pass,
   render [templates/README.md.tmpl](../templates/README.md.tmpl): one row per feature (link ·
   title · derived phase · decision counts a/c/d/r/p · `done/total` tasks · prototype link),
   the verification-debt note (lead with any `review`-phase features), and the drift note (reuse
   [[roadmap]]'s divergence check — don't re-derive it). Write `docs/features/README.md`
   (overwrite; it's generated, like `status.md`). Single-feature runs update only that feature's
   `status.md` and **its row** in the index, not the whole file.

## Notes

- `status.md` is **stakeholder-facing**: plain language, no code identifiers in prose. The task list may cite `TASK-NNN` but describe each in human terms.
- This verb never changes decisions or tasks — read-only aggregation + write of the rollup file.
- Chain this automatically after `decide` and `decompose` so the rollup never goes stale.
- **Also chain it after a surface-dependent revert** (a `changed` decision that reverts a
  `done` feature to `review` — see [SKILL.md](../SKILL.md#changing-a-closed-done-feature--surface-dependent-revert)).
  Flipping `idea.md`/tasks without re-running `status` leaves `status.md` reading `done`
  while everything else says `review` — the stakeholder's rollup then lies.
