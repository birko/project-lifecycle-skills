# /tasks spawn — turn discovered work into its own task

Work surfaces mid-flight that isn't the task in hand. Decide whether it's genuinely new scope; if
it is, create the task, place it under the right parent, wire it into the origin task's
implementation plan, and reconcile the feature ledger — then return to what you were doing.

This is the **anti-scope-creep valve**. The acceptance list of an in-flight task is a fixed,
independent target; appending criteria to it mid-work turns it into a transcript of whatever
happened. Spawn instead of widening.

## When this fires

- Any time during work — while implementing a picked task, drafting a plan, reviewing, or at
  `close` — something surfaces that "should probably be its own task": a refactor the change
  exposed, a bug found in passing, a missing capability, a plan step that turned out to be its
  own unit of work.
- **The agent offers it, unprompted.** Don't wait to be asked. When you notice work outside the
  current task's acceptance criteria, say so and offer to spawn — silently doing it, or silently
  dropping it, are both lifecycle violations.
- **There is a quiet third violation, and it is the most tempting one: writing the discovery into
  `## Out of scope` without an id.** That *feels* like tracking — the sentence is durable, it sits in
  the right section, a reader would find it. But nothing ranks it, so it is read only by whoever
  re-opens a closed task. `## Out of scope` is for a **boundary** ("X is not covered; TASK-NNN owns
  it"); a bullet that describes unowned **work** is a spawn that was skipped. Noting a spawned task
  there is correct and expected — the id is what makes it a boundary rather than a wish.
  Interrupting mid-fix is the usual excuse, and it is answered by step 8: spawn returns you here, so
  the thread is not lost. [`close`](close.md) step 5d sweeps for the ones that slipped anyway.
- The user can trigger it directly: `/tasks spawn "<what was discovered>"`, or plain "that should
  be its own task".

## Steps

1. **Scope test — is this really a new task?** Run it *before* creating anything:
   - Does it satisfy an **existing acceptance criterion** of the origin task? → in scope. Just do
     it; don't spawn.
   - Is it a one-line incidental inside a file you're already editing (typo, dead import, a
     rename the compiler forces)? → do it; no task.
   - Otherwise → **spawn**. Positive signals: it needs its own acceptance criteria; it's
     independently completable and mergeable; it changes observable behaviour the origin task
     doesn't claim; a reviewer would judge it separately.
   - **Genuinely torn → spawn.** A spare task is cheap noise you can `cancel`; untracked scope is
     work that silently disappears.

2. **Establish the origin** — the task currently in flight (arg, or the one at `status:
   in-progress` you're working). Capture its `id`, `parent`, `feature`, priority, assignee, and
   its `## Implementation plan`. If there is no origin task (a conversational fix), that's fine —
   skip the wiring in step 5.

3. **Route it to the right lane** — not everything discovered is a task:

   | What surfaced | Lane |
   |---|---|
   | Follow-up / refactor / cleanup this work exposed | **task** under the origin's parent |
   | Defect in behaviour the origin task doesn't cover | **task** — and it isn't `done` until it carries a regression test (SKILL.md § field feedback) |
   | Something that must land *before* the origin can finish | **task** + `/tasks block <origin> --on TASK-NNN` |
   | A whole new user-visible **capability** | **feature first** — chain `/feature new`, then `decide` → `decompose`. Do **not** mint a bare task that quietly implements unapproved scope |
   | Evidence a `deferred`/`removed` decision was wrong | back to `/feature decide` — reopen the decision, then decompose |

4. **Create the task** — chain [verbs/new.md](new.md) (`/tasks new task`) with these defaults
   pre-filled so the user only confirms or corrects:
   - **parent** — the origin's STORY; else the origin's EPIC; else `_loose`. Inheriting the
     parent is what "place it correctly in the plan" means structurally — a spawned task that
     lands loose when its origin sits under a story is misfiled.
   - **feature** — inherit the origin's `feature: FEATURE-NNN` when the item belongs to the same
     feature (step 6 reconciles the ledger). Otherwise `null`.
   - **priority** — a blocker inherits the origin's priority; a follow-up defaults to P2.
   - **assignee** — inherit the origin's.
   - **Context** — must state *what* was discovered, *where* (`file:line`, or the diff), and
     *that it was found while doing TASK-origin*. That provenance line is the re-discovery
     context the next picker needs.
   - **Acceptance criteria** — write the discovered item's own criteria. If you can't state them,
     the item isn't understood well enough to be a task yet — capture it as a `## Context` note on
     the origin instead and say so.
   - Pass `--no-plan` by default (the plan gets drafted when it's picked); drop it if the user
     wants the plan now.

5. **Wire origin ↔ new task** — this is the "place it correctly in the plan" half:
   - **`## Out of scope`** on the origin — add `- Deferred to TASK-NNN — <one line>`. The template
     already invites this; an origin whose out-of-scope list doesn't name the spawned task will
     read as an unexplained gap at `close`.
   - **`## Implementation plan`** on the origin — keep it matching what will actually be built:
     - A plan step now owned elsewhere is **rewritten in place** to `→ deferred to TASK-NNN`,
       never deleted. A silently shortened plan hides the handoff.
     - If the spawned task is a new *prerequisite*, insert it as a step referencing TASK-NNN.
     - If the origin has no plan yet, note the split in `## Context` instead.
   - **`depends-on` / `blocks`** frontmatter on both files, whichever direction applies.
   - If the origin genuinely can't proceed → `/tasks block <origin> --on TASK-NNN`
     ([verbs/block.md](block.md)), with the reason.

6. **Reconcile the feature ledger** — whenever the origin or the new task carries `feature:
   FEATURE-NNN`. New scope must never enter a feature through the back door:
   - **It's covered by an existing `approved`/`changed` decision row** (just an extra task to
     realize it) → append `TASK-NNN` to that row's `→ Tasks` column and add a History line:
     `{{DATE}} — D<n> — TASK-NNN spawned from TASK-origin (<one line>)`.
   - **It alters an already-approved decision** → the row moves to `changed` via
     `/feature decide`, with the delta recorded. Never quietly widen an approved row by hanging a
     bigger task off it — the stakeholder approved the old shape.
   - **No decision covers it** → append a **new `proposed` row** to `decisions.md` (+ History
     line) and tell the user it needs `/feature decide`. Leave the task `todo` (or `blocked` on
     the decision) — implementing an undecided row is the same violation as coding without a task.
   - Chain `/feature status FEATURE-NNN` (single-feature mode) so the rollup and index row don't
     lag.
   - **No `feature:` link, but the item is stakeholder-visible** (new behaviour a PM or user would
     notice) → offer `/feature new` per step 3's routing table, rather than burying it as a loose
     task.

7. **Regenerate dashboard** — chain [verbs/triage.md](triage.md).

8. **Return to the origin** — print, compactly:
   - the new `TASK-NNN` + file path, its parent and `feature:`;
   - what changed on the origin (plan step deferred / out-of-scope line / `blocks` wired);
   - the ledger reconciliation (row touched, or "new `proposed` row D<n> — needs `/feature decide`");
   - then **"resuming TASK-origin"** and pick the thread back up. Spawning is an interruption, not
     a context switch — never leave the user mid-air on the task they were actually doing.

## Scope escalation — when the task itself was mis-sized

Everything above handles work that is *adjacent* to the task in hand. This section handles the other
direction: the task's **own** subject turns out bigger than it was filed as. Here, spawning is
sometimes exactly the wrong move — a task filed against a symptom shouldn't be closed on the symptom
just because the honest fix is larger.

**Measure it, then decide. Never resize a task silently — in either direction.** Three shapes, and
they are *not* handled the same way:

| Shape | Example | Handling |
|---|---|---|
| **Wider population, same fix** | filed as "2 endpoints return 500", measured as 115 of 170; one central change closes all of them | **No ask.** Sweeping *is* the task. Do it, and report the real number — the count was a sample, not the scope. |
| **Higher altitude, same defect** | filed against one screen; the same defect is on every screen sharing that base class | **No ask** while it stays one coherent change. Fix it where it actually lives and say which other surfaces that covered. Ask only if going up a level drags in unrelated subsystems. |
| **Different problem wearing the task's clothes** | "two consecutive runs produce identical counts" turns out to be test-fixture ownership across ~35 files, unrelated to the two collisions filed | **Stop and ask.** This is not the task growing; it's a different task discovered underneath it. |

In the third case, before you ask:

1. **Finish every part the task genuinely covers.** A pending question is not a reason to hand back
   half-done work that was never in doubt.
2. **Record the measurement in the task file — numbers, not adjectives.** "Much bigger than expected"
   decides nothing; three runs reading `312/2/19 → 309/0/24 → 310/2/21` makes the split obviously
   right. The numbers are what let the user answer in one line instead of re-investigating.
3. **File the residue as its own task** (steps 4–6 above) so it can't evaporate while the question is
   open.
4. **Leave the unmet criterion visibly unticked** — `- [ ] <criterion> — ⚠ NOT MET — split to
   TASK-NNN`. Never tick it, never soften its wording to fit what you did, never delete it
   ([close.md](close.md) step 6).
5. **Then ask**, offering three concrete options and recommending one: close on delivered scope · fold
   the residue back in now · close and pick the residue next.

While the ask is pending, don't start new scope — including, in a [[fix-next]] `--loop` run, the next
defect.

## Edge cases

- **No origin task** (spotted during a conversational fix or a review) — still create the task;
  skip step 5's wiring; place it under the best-matching story/epic, else `_loose`.
- **Several items at once** — batch them: one task each, one shared History line per decision row.
  Don't merge unrelated discoveries into one task to save typing.
- **Discovered during `/tasks close`** — spawn first, *then* re-ask whether the origin can close.
  The origin closes only if its own acceptance criteria are genuinely met; the spawn doesn't excuse
  an unmet one, and an unmet one doesn't justify holding the spawn hostage.
- **It duplicates an existing open task** — link, don't create (the [audit](audit.md) duplicate
  rule). Add the new context to the existing task and reference it from the origin.
- **Origin's feature is already `done` / `review`** — new work on a signed-off feature reopens it:
  record the `changed`/new decision, and if the change touches a human-verifiable surface, the
  implementing task goes back to `review` per SKILL.md. Don't attach silent work to a shipped
  feature.
- **The "task" is really an epic's worth of work** — spawn a STORY (or EPIC) instead and put the
  first task under it; `/tasks new`'s decision test applies unchanged.
