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
   | 1 | `idea.md` status is `done`, `dropped` or `superseded` | that status |
   | 2 | ≥1 `approved` or `changed` row is not decomposed: its `→ Tasks` cell is empty, or names a task that is not on disk | `building` |
   | 3 | `idea.md` status is `review` | `review` |
   | 4 | ≥1 linked task that is not `cancelled`, and every such task is `done` or awaiting verification (`verify`, or the older `review`, read per [[tasks]] § *Lifecycle*) | `review` |
   | 5 | ≥1 `approved` or `changed` row | `building` |
   | 6 | the prototype line reads **Built** (the artifact is still there) | `prototyping` |
   | 7 | ≥1 row stamped `deferred` or `removed`, or the prototype line reads **Skipped** or **Built, then deleted** | `deciding` |
   | 8 | anything else: no row stamped, no prototype recorded | `idea` |

   - **`done`, `dropped` and `superseded` are mirrors of the stored marker**, not derived: `done` means reviewed and
     signed off, `dropped` means every decision was `removed` (show the rollup but mark it killed), and
     `superseded` means the scope moved to another feature (show the `superseded-by:` pointer). Stored marker =
     `status` in `idea.md`; computed display = phase. Never hand-maintain phase.
   - **`review` from rules 3 and 4 means built but not signed off.** Client tasks awaiting sign-off carry `status: verify`.
   - **Rule 2 runs before both `review` rules, whatever is stored, because a row with no tasks is work nobody has
     built.** Without it the old tasks of a `changed` row still back-link through `feature:`, so rule 4 reads them
     all `done` and the rollup tells stakeholders an unbuilt change awaits sign-off. Its condition is the one
     [pick](pick.md)'s gate D fails on, so gate E, which reads this phase, never fires beside it. A stored `review`
     with tasks parked at `verify` shows `building` too while a new row waits, and its `verify` tasks still
     lead every listing ([SKILL.md](../SKILL.md) § *Verification debt surfaces first* keys that on tasks as
     well as phase).
   - **`building` with no tasks yet is the normal case**, not a corner: `decide` chains this verb right after
     stamping. Render `0/0 tasks` and point the next-step line at `/feature decompose`.
   - **`deciding` with no `proposed` row left** is a ledger whose every verdict is `deferred` or `removed` but whose
     `idea.md` was never marked `dropped`. Nothing can be built until a row is approved, so the next-step line says
     so: reopen a row with `/feature decide`, or drop the feature.
   - A recorded **Skipped** counts as the prototype step being over, the same as **Built, then deleted**. Only a
     prototype still standing holds the feature at `prototyping`.

3. **Cross-reference tasks** — take the feature's tasks from step 1's model: ids, titles and statuses, bucketed
   there. Don't grep `tasks/` again, because two collections of one fact can disagree, for example on a task taken
   on a branch. Compute `done/total` **leaving cancelled tasks out of both numbers**, the rule [[tasks]] `triage`
   uses, so a finished feature reads `n/n`. List every task, cancelled ones included, in [[tasks]] § *Collection
   pass*'s task order, one per line as `- TASK-NNN <title> — <status>`: the title verbatim from the task file and the
   status as the file reads it. **Never reword a title**: a paraphrase is a line no input can recompute, so two runs
   write two files.
   The model does not carry test plans, so read each listed task's file for its `## Human test plan`. A task is
   **ready to test** when its plan is filled (not `N/A`) **and** the work is built: it reads `done`, or awaits
   verification. A `todo`, `in-progress` or `cancelled` task is never on that list, whatever its plan says, because
   there is nothing to run the plan against yet.

4. **Render** [templates/status.md](../templates/status.md) — fill decision counts by state, build progress, and:
   - `{{TIMESTAMP}}` — [[tasks]] `triage`'s form: local time, no zone.
   - `{{TASK_LIST}}` — step 3's lines; `_None_` when the feature has no linked task.
   - `{{TESTABLE_SUMMARY}}` — `Ready to test: TASK-NNN, TASK-NNN.` in task order, then, when any built task's plan is
     `N/A`, `No manual test: TASK-NNN.`; `Nothing to test yet.` when no task is ready.
   - **Which part of `idea.md`'s `## Prototype` section is "the line".** The section can hold several paragraphs: an
     italic placeholder hint, the state, and later notes. The state is the **first paragraph that opens with a state
     word**, bold or plain: `Built`, `Skipped`, `N/A`, `Pending`, or the deleted form (`Built — …` and `**Skipped**
     (2026-09-24) — …` both open with one). Render that paragraph
     alone, its lines joined into one, and nothing else from the section: the hint and any later note are for the
     feature's authors, and the rollup is stakeholder-facing. No such paragraph → "none yet", as **Pending**.
   - `{{PROTOTYPE_LINK}}` — link to `prototype.html` / `prototype.md` / `prototype-states.html` / the spike branch, or "none yet". A prototype already deleted renders as the `idea.md` line says (`built, then deleted — answered D<n>`), never as a link to a file that is gone. A prototype recorded as
     **Skipped** or **N/A** renders as the `idea.md` line says, reason included (`Skipped — headless logic, the
     test suite is the proof`), and links nothing; **Pending** renders as "none yet". A standing prototype renders
     as one link, `[<label>](<target>)`, with the label from step 7's table, and nothing else on the line.
   - `{{NEXT_STEP}}` — one line, chosen by phase, so two runs agree:

     | Phase | Next step |
     |---|---|
     | `idea` | `Grill the idea with /feature new, or build a prototype with /feature prototype.` |
     | `prototyping` | `Stakeholders try the prototype; then record the verdicts with /feature decide.` |
     | `deciding`, a `proposed` row left | `Decide <n> proposed decisions with /feature decide.` |
     | `deciding`, none left | the sentence step 2 gives: reopen a row with `/feature decide`, or drop the feature |
     | `building`, no task yet | `Break the approved decisions into tasks with /feature decompose.` |
     | `building`, tasks | `<n> tasks to do, <m> in progress.` (a zero term left out) |
     | `review` | `Run each ready test plan, then sign off with /feature review.` |
     | `done` | `Nothing — the feature is signed off.`, plus ` Still open: TASK-NNN.` when a linked task is |
     | `dropped` | `Nothing — the feature was dropped.` |
     | `superseded` | `Nothing — superseded by <superseded-by>.` |

   - **Every count noun this verb prints is singular for a count of exactly 1**, in the next-step line above, in the
     template's fixed lines and in step 6's digest alike. The template's `tasks done.` agrees with the total, so a
     feature with one task reads `1 / 1 task done.`; the digest's `(<done>/<total> tasks, …)` and `<n> tasks awaiting
     sign-off` follow the same rule (`(1/1 task, …)`, `1 task awaiting sign-off`).
   (The template is stakeholder-facing and carries no author comments — these hints live here.)

5. **Write** `docs/features/FEATURE-NNN-slug/status.md` (overwrite).

6. **If invoked for all features** — also print a one-line-per-feature digest to stdout (its counts follow step 4's
   singular rule):
   `FEATURE-012 Checkout redesign — building · 2 tasks awaiting sign-off (4/7 tasks, 3 approved / 1 deferred)`.
   **Order the digest with debt features first**, per [SKILL.md](../SKILL.md) § *Verification debt
   surfaces first*: phase `review`, or any task awaiting sign-off, whatever the phase. They are the
   next action, ahead of everything else. Never headline "all shipped" while one exists — that buries
   the debt. A feature whose tasks are all `done` but unsigned prints as `review (awaiting
   sign-off)`, never `done`.
   **The rest follow in id order**, and so do debt features among themselves. **The decision part** lists only the
   non-zero states, as `<n> <state>`, in the ledger's order (approved / changed / deferred / removed / proposed),
   joined by ` / `; a feature with no stamped row prints `no decisions`. The task part is step 3's `done/total`.

7. **Regenerate the features index** (the whole file in all-features mode; one row otherwise) — this verb **owns**
   `docs/features/README.md`, the human entry-point index. From the same collection pass,
   render [templates/README.md.tmpl](../templates/README.md.tmpl): one row per feature (link ·
   title · derived phase · decision counts a/c/d/r/p · `done/total` tasks · prototype link),
   where the Prototype cell links the artifact while it stands, and otherwise holds the `idea.md` line's state in
   lower case (`pending` · `skipped` · `n/a` · `deleted`), never a link. **The label is the prototype's form as the
   `idea.md` line names it**, never the file extension or the host, so a playground published as a hosted page is
   still `[playground]`:

   | Form | Label |
   |---|---|
   | HTML mockup | `[html]` |
   | markdown wireframe | `[md]` |
   | state-model playground | `[playground]` |
   | code spike | `[spike]` |
 `{{TIMESTAMP}}` takes [[tasks]] `triage`'s form: local time, no zone. `{{PROJECT_NAME}}` is the name of the directory containing `docs/`, the project root this verb
   resolved: a path any run derives the same way, where a README heading can be missing or say something else.
   the verification-debt note (lead with every debt feature, as SKILL.md § *Verification debt surfaces
   first* defines it, with its task count), and the drift note (reuse
   [[roadmap]]'s divergence check — don't re-derive it). **The drift note carries open findings only**, as
   [[tasks]] `triage`'s callout does: an accepted one ([[roadmap]] § *Accepted divergences*) stays out, and when every
   finding is accepted the note is one quiet line, `> Drift: none open · <a> accepted (<target> DV<x>, …) — see
   /roadmap --check.`. With nothing found and nothing accepted it is omitted. Write `docs/features/README.md`
   (overwrite; it's generated, like `status.md`). **With no features, `{{FEATURE_ROWS}}` is one table row whose first cell is `_None_` and
   whose other cells are empty**, so the table stays well-formed and reads like `tasks` `triage`'s empty lists. **The template's `<!-- … -->` comments are notes to you and are
   never rendered**: drop each with its token, whether the token filled or was omitted. Single-feature runs update only that feature's
   `status.md` and **its row** in the index, not the whole file. **They leave the header's timestamp alone**: it
   dates the last full render, which is what the notes under the table were computed from, and a row-only run
   recomputes neither note. **A single-feature run prints its feature's open findings** to stdout, one line,
   `drift: <target> DV<x> <reason> — run /roadmap --check`, since `status.md` has no slot for them and the index's
   note is not rewritten; nothing when there are none.
   **When the index does not exist, a single-feature run renders all of it**, exactly as all-features
   mode does, and reports `created docs/features/README.md — it was absent`. A row needs a file to hold
   it, and this verb owns that file. Every line in it is derived from the collection pass, so rendering
   it whole decides nothing, and two runs over the same tree write the same file. Never skip it: an absent
   index is a gap in the layer (`skills/new-project/LAYER.md` requires it), not a choice to respect.

## Notes

- `status.md` is **stakeholder-facing**: the template's own prose is plain language. The task lines carry each
  task's title verbatim (step 3), because a rollup holds only what its inputs determine; a title that reads badly to
  a stakeholder is fixed in the task file, where the next render picks it up.
- This verb never changes decisions or tasks — read-only aggregation + write of the rollup file.
- Chain this automatically after `decide` and `decompose`, and after a `/tasks close` that changes a feature-linked task's status — those verbs each carry the chain instruction on their side, so the rollup never goes stale.
- **Also chain it after a surface-dependent revert** (a `changed` decision that reverts a
  `done` feature to `review`, or to `idea` when the change is not built — see
  [decide.md § Changing a closed feature](decide.md)).
  Flipping `idea.md`/tasks without re-running `status` leaves `status.md` reading `done`
  while everything else says otherwise — the stakeholder's rollup then lies.
