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

5. **Refresh the rollup** — chain `/feature status FEATURE-NNN` (single-feature mode) automatically to refresh
   the rollup + index row — a suggestion the user can skip leaves the stakeholder view stale. A revert
   (§ *Changing a closed feature* step 4) also chains [[tasks]] `triage`.

6. **Commit what this run wrote.** Left uncommitted, the ledger sits in a dirty tree that no step owns. It
   then rides into whatever unrelated commit comes next, or is lost with it, and the next `/tasks close` meets
   it as somebody's uncommitted work. A verdict is a record, so it gets a commit of its own, as
   [review.md](review.md) step 5b gives a review's.
   - **The files are the ones this run wrote**, counted off the steps that ran: `decisions.md` when a row
     or History line changed, `idea.md` when its `status:` changed, and for a revert each task file it moved
     to `verify`, each `STORY.md` or `EPIC.md` it reopened, the owning feature's files a re-home touched,
     any file the ripple trace edited, `tasks/README.md` when `triage` ran, and `status.md` and
     `docs/features/README.md` from step 5. A run where every verdict was skipped wrote nothing and commits
     nothing.
   - **Git repo, no upstream** (`git rev-parse --abbrev-ref <default>@{upstream}` fails) → commit exactly
     those files and nothing else from the index:
     `git commit --only -m "chore: decide FEATURE-NNN" -- <the files written>`. The subject does not lead
     with a task id, so [[specs]] attributes no behaviour to it: a verdict changes no code, and a reverted
     task's own behaviour is attributed when that task closes again. No `Co-Authored-By:` trailer.
   - **With an upstream** → commit the same files on `record/FEATURE-NNN`, by the record-branch rule in
     [[tasks]] `close` § *Closing a STORY / EPIC* step 5, with the subject above. It is the branch name a
     review uses, on purpose: both write the same `decisions.md`, so a decide and a review of one feature
     must not race, and that rule stops the second with `record/FEATURE-NNN exists, land it first`.
   - **No git** → commit nothing. Step 7 names each file as uncommitted.
   - **Nothing else in the working tree is committed.** A file this run did not write stays as it was,
     uncommitted, even when it sits beside the ledger.

7. **Confirm + next step:**
   - Summarize counts (`3 approved, 1 changed, 1 deferred, 2 removed`).
   - Name the commit from step 6, the `record/FEATURE-NNN` branch it pushed (`record/FEATURE-NNN pushed —
     open a PR to land it`), or, when the rule stopped or there is no git, its line and **every file left
     uncommitted, by path**. A clean report over a dirty tree is the defect step 6 exists to remove.
   - If any `approved`/`changed` exist → "Decompose into tasks: `/feature decompose FEATURE-NNN`". A
     `changed` row that § *Changing a closed feature* step 4 found **built** does not count: its change is
     in the code, and its reverted task's re-run covers it. For each such row print
     `Re-run TASK-NNN's Human test plan, then /tasks close TASK-NNN`, and offer decompose only when a row
     is left that does count. **Not
     when step 6 pushed `record/FEATURE-NNN`**: the record-branch rule restored this copy's ledger, so it
     reads as it did before this run, and `decompose` would refuse it. Print instead
     `Land record/FEATURE-NNN, then decompose: /feature decompose FEATURE-NNN`.
   - If `proposed` remain → note how many still need a verdict.

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
- **Decisions carry no file paths and no code — with one exception.** Paths and code go stale as
  the product changes, and a decision record that has quietly gone stale is worse than none, because
  it is still believed. So a row states *what was agreed* in plain words.
  **The exception is a prototype-derived snippet.** A snippet from a prototype this feature built may
  be attached to a decision **only when all four hold**:

  | Test | Admits | Rejects |
  |---|---|---|
  | **It came from a prototype** | a state table, reducer, schema or type shape written while building any of the forms in [prototype.md](prototype.md) step 2 | anything written for the ledger, or copied from the product's code |
  | **It encodes the decision itself** | the agreed states and transitions, the cases a reducer handles, the fields and constraints of a shape | how the product will implement it: handlers, styling, wiring, imports |
  | **Prose would lose precision** | the row's own one-sentence statement of the decision drops a case, an edge or a constraint the snippet carries | that sentence says everything the snippet does. That is *more convenient*, not *more precise*, and the prose wins. (Any table can be spelled out in enough sentences; the comparison is with the row, not with a transcript.) |
  | **It is trimmed and marked** | cut to the decision-rich lines (keep what tells one case from another; drop rationale, elisions and presentation), headed `Prototype-derived (<form>, <date the prototype was built>) — not the shipped code, and not expected to match it` | a snippet missing either the trim or the marker |

  Put it under `## Prototype-derived snippets` below the table, one `### D<n>` block each. The row still
  states what was agreed in one sentence and adds `see snippet`, so a reader who never opens it is not
  misled. **A later reader treats it as the agreed model, never as the code.** Nobody
  diffs it against the repo; where the product and the snippet disagree, that is a question for
  `/feature decide` about whether the agreement changed, not a bug against either.

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
4. **Status rule:** a change with a human-verifiable surface reverts the owning feature out of `done`;
   a built change fully covered by automated tests stays `done`. A change that is not built yet leaves `done`
   either way, by the second row below, because a feature reading `done` is listed nowhere as work. Where the feature and its implementing task(s) go
   depends on whether the change is already in the code:

   | The changed shape is | Feature (`idea.md` `status:`) | Implementing task(s) |
   |---|---|---|
   | **built** — code implementing it is in the tree | `done → review`: built, sign-off pending | `done → verify`; re-run their Human test plans before re-closing, after resetting each step the change affects to *not run* by [[tasks]] § *Lifecycle* ("A change landing on a closed feature"). A step left ticked reads as passed and lets `close` skip the re-run |
   | **not built yet** | `done → idea`, the one stored value that does not claim the work is built: `review` says built and awaiting sign-off, and the coarse set has no `building`. The phase then derives `building` from the emptied row ([status.md](status.md) step 2's not-decomposed rule), and `/feature review` sets `review` or `done` again once the change ships | stay `done`: their work shipped and nothing in the code changed. **Move their ids out of the row's `→ Tasks` cell** into the History line (`D<n> changed — TASK-NNN built the prior shape`) and leave the cell `—`. The row then reads as not decomposed everywhere it is checked (`pick`'s gate D, `decompose`, `review` Gate A), so the change cannot pass as built. Step 7 offers `decompose`, which files it as a new task with its own Human test plan |

   Read *built* off the code, never off the request. **Unsure counts as not built:** a task filed for work
   that turns out to exist closes quickly, while a `verify` over unbuilt work claims code is complete when
   it is not. Roll each reverted task's parents up by
   [[tasks]] § *Roll status up to parents* (the reopening direction). Then re-run `/feature status` so
   `status.md` and the index recompute, and chain [[tasks]] `triage` so `tasks/README.md` shows the reverted
   tasks. With an upstream the dashboard rides on `record/FEATURE-NNN` with the rest (step 6), as it does for
   a review, and never stays on the default branch. The
   revert touches `idea.md`, the task file(s), `status.md`, the index and the dashboard, plus any parent it
   reopened, and isn't done until they all agree and step 6 has committed them.

## Edge cases

- **Re-deciding an approved item later** — allowed; e.g. `approved → removed` after a failed spike. Append the reason to History; if tasks were already created, note they should be cancelled (`/tasks` — set status `cancelled`, don't delete).
- **Decision with no clear owner** — don't fabricate one; mark `By: —` and flag in History that it needs stakeholder confirmation.
- **User wants to add a brand-new decision now** — add a fresh row (`proposed`) then stamp it; record in History.
- **Reopening a `removed`/`deferred` decision from field evidence** — production feedback (a user demand, an incident, a monitoring signal) can overturn a past "no". Don't edit the old row: add a **new `proposed` row** that references the superseded one (e.g. "supersedes D4, removed 2026-03"), append a History line (`D4 removed → reopened: customers keep hitting it, per ops`), then stamp the new row like any other. The old row stays — both the original "why" and the reversal are auditable. This is the [[tasks]] / [[populate-tests]] feedback loop reaching the decision tree; a `deferred` row's unblock condition is exactly this trigger.
- **Everything removed** — that's a valid outcome (feature killed). Set `idea.md` frontmatter `status: dropped` and append a History line. No tasks generated.
- **A decision changes mid-build, from any trigger** — whether a stakeholder demo, a review, or the **agent discovering during coding** that the approved approach won't work, log it the same way: a History line for the change + rewrite the row to the current form (the Deciding rules above apply regardless of who or what triggered the change).
