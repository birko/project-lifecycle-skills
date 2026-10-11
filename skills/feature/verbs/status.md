# /feature status — regenerate the stakeholder rollup

Rebuild `status.md` for a feature (or all features) so a PM or other non-technical stakeholder can see where it stands without reading code or task files.

## Steps

1. **Collect** — run the [[roadmap]] skill's Cross-tree pass for the target feature (or all features if no ID given) and consume its output model; don't re-enumerate. Bucket each feature's tasks by status (todo/in-progress/review/blocked/done/cancelled) from the model — `review` matters for the phase derivation and debt ordering below.

2. **Compute the phase** — derive it from the data. **Take the first rule that matches, top to bottom**, so every
   feature gets exactly one phase. The rules overlap (a built prototype beside approved rows, say), and without an
   order two runs pick differently. Read the prototype from `idea.md`'s `## Prototype` line, not from the folder,
   because a prototype is deleted once it has answered its question. The line reads **Built**, **Built, then
   deleted**, **Skipped**, or records nothing yet (blank, or still the template's placeholder).

   | # | When | Phase |
   |---|---|---|
   | 1 | `idea.md` status is `done`, `dropped`, `superseded` or `review` | that status |
   | 2 | ≥1 linked task that is not `cancelled`, and every such task is `done` or awaiting verification (`verify`, or the older `review`, read per [[tasks]] § *Lifecycle*) | `review` |
   | 3 | ≥1 `approved` or `changed` row | `building` |
   | 4 | the prototype line reads **Built** (the artifact is still there) | `prototyping` |
   | 5 | ≥1 row stamped `deferred` or `removed`, or the prototype line reads **Skipped** or **Built, then deleted** | `deciding` |
   | 6 | anything else: no row stamped, no prototype recorded | `idea` |

   - **`done`, `dropped` and `superseded` are mirrors of the stored marker**, not derived: `done` means reviewed and
     signed off, `dropped` means every decision was `removed` (show the rollup but mark it killed), and
     `superseded` means the scope moved to another feature (show the `superseded-by:` pointer). Stored marker =
     `status` in `idea.md`; computed display = phase. Never hand-maintain phase.
   - **`review` from rule 2 means built but not signed off.** Client tasks awaiting sign-off carry `status: verify`.
   - **`building` with no tasks yet is the normal case**, not a corner: `decide` chains this verb right after
     stamping. Render `0/0 tasks` and point the next-step line at `/feature decompose`.
   - **`deciding` with no `proposed` row left** is a ledger whose every verdict is `deferred` or `removed` but whose
     `idea.md` was never marked `dropped`. Nothing can be built until a row is approved, so the next-step line says
     so: reopen a row with `/feature decide`, or drop the feature.
   - A recorded **Skipped** counts as the prototype step being over, the same as **Built, then deleted**. Only a
     prototype still standing holds the feature at `prototyping`.

3. **Cross-reference tasks** — take the feature's tasks from step 1's model: ids, titles and statuses, bucketed
   there. Don't grep `tasks/` again, because two collections of one fact can disagree, for example on a task taken
   on a branch. Compute `done/total`. List each task with its id and title.
   The model does not carry test plans, so read each listed task's file for its `## Human test plan`, and mark
   which ones are ready to run (filled, not `N/A`) for the "what can be tested now" section.

4. **Render** [templates/status.md](../templates/status.md) — fill decision counts by state, build progress, and:
   - `{{TESTABLE_SUMMARY}}` — the tasks whose Human test plan is filled and ready to run.
   - `{{PROTOTYPE_LINK}}` — link to `prototype.html` / `prototype.md` / `prototype-states.html` / the spike branch, or "none yet". A prototype already deleted renders as the `idea.md` line says (`built, then deleted — answered D<n>`), never as a link to a file that is gone.
   - `{{NEXT_STEP}}` — one concrete action, e.g. "PM to review 2 proposed decisions", "3 tasks in progress", "ready for /feature review".
   (The template is stakeholder-facing and carries no author comments — these hints live here.)

5. **Write** `docs/features/FEATURE-NNN-slug/status.md` (overwrite).

6. **If invoked for all features** — also print a one-line-per-feature digest to stdout:
   `FEATURE-012 Checkout redesign — building (4/7 tasks, 3 approved / 1 deferred)`.
   **Order the digest with phase-`review` (awaiting sign-off) features first** — they
   are outstanding verification debt and are the next action, ahead of `idea`/planned
   ones. Never headline "all shipped" while a `review`-phase feature exists — that buries
   the debt. A feature whose tasks are all `done` but unsigned prints as `review (awaiting
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
- Chain this automatically after `decide` and `decompose`, and after a `/tasks close` that changes a feature-linked task's status — those verbs each carry the chain instruction on their side, so the rollup never goes stale.
- **Also chain it after a surface-dependent revert** (a `changed` decision that reverts a
  `done` feature to `review` — see [decide.md § Changing a closed feature](decide.md)).
  Flipping `idea.md`/tasks without re-running `status` leaves `status.md` reading `done`
  while everything else says `review` — the stakeholder's rollup then lies.
