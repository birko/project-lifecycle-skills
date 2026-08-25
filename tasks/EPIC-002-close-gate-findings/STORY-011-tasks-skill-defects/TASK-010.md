---
id: TASK-010
parent: STORY-011
feature: null
status: done
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# /tasks pick walks past verification debt without mentioning it

## Context

Found while writing a session handoff: asked "will the unfinished things resurface when I run
`/tasks pick`?", the honest answer turned out to be **no**.

The bare `/tasks` snapshot handles this well. `SKILL.md` renders a `review:` count and an
`In review:` list, and states the intent outright: *"In-review tasks are verification debt —
surface them, don't bury them."*

`verbs/pick.md` does not. It defaults to `--status todo` (correctly — a task awaiting sign-off is
not work to start), collects candidates, and offers one. Nothing in the verb mentions `review` at
all. So a session that opens with `/tasks pick` — the natural resume command, and the one this
repo's own handoff advice recommended — is handed fresh work while seven code-complete tasks sit
unverified, and never learns they exist.

The failure is quiet in the worst way: picking new work over unverified work is exactly what the
verification-debt rule exists to prevent, and the verb that starts work is the one place the rule
is never stated.

## Acceptance criteria

- [x] `pick` reports outstanding `review`-state tasks **before** offering a candidate — count plus ids, not a full listing
- [x] Above a threshold (start at 3, tune with use) it **asks** whether to clear debt first rather than merely mentioning it; the user can still say no
- [x] `review` tasks stay out of the candidate list — the fix is to *surface* the debt, not to offer unfinished work as new work
- [x] The wording matches the bare snapshot's, so the two verbs describe the same state the same way
- [x] `fix-next` gets the same check, or a recorded reason why a defect-draining loop should ignore it
      — **already had it**, at its step 1: *"Verification debt comes first. Tasks at `status: review` are not in the pool … but they are debt … Offer to clear them first."* Nothing added; `pick` step 2b now points at it so the two are visibly the same rule rather than coincidentally similar.
- [x] Reconsider the handoff advice this repo gives: `/tasks` (which surfaces debt) reads better as a resume command than `/tasks pick` (which does not)
      — **reconsidered, and the fix dissolved the question.** The asymmetry was the whole argument, and `pick` now surfaces debt too, so neither command is unsafe. `AGENTS.md:244` already points at `/tasks` for *"where things stand"*, which stays correct because the snapshot is a better **survey** (it shows in-progress work and the features slice) — not because `pick` is blind. And [[handoff]] is 15 lines that never name a resume command, so there was no bad advice to retract. **No edit made**, deliberately: adding this repo's tooling to a generic skill would be the wrong fix for a problem that no longer exists.

## Out of scope

- Changing what `review` means, or how a task leaves it — `close` already owns that.
- Blocking `pick` outright when debt exists. Debt is a judgement call; the user may have a good
  reason to push on, and a gate that cannot be overridden gets worked around.

## Human test plan

- [x] With 7 tasks in `review` (this repo, today), run `/tasks pick` and confirm the debt is stated before any candidate is offered
      — **the scenario no longer exists**, and that is worth stating rather than glossing: the seven were cleared over the following days, and this repo has had **0 in review** since. Verified structurally instead — step **2b** sits before step 3 (collect) and step 4 (present), so no candidate can be offered ahead of it. A session with real debt is the stronger test and is available to whoever next hits it.
- [x] With none in review, confirm the output is unchanged — no noise on a clean tree
      — **genuinely exercised**: the tree is clean right now, and step 2b's first row is *none → say nothing; go to step 3*. This is the one item today's state can actually test.
- [x] Confirm a `review` task is still never offered as a candidate
      — two independent reasons, both intact: step 2 still defaults to `--status todo`, and step 2b says outright that `review` tasks are deliberately not candidates.

## Implementation plan

_Populated by `/tasks plan TASK-010`._

## Outcome

**What was broken.** `verbs/pick.md` mentioned `review` **zero times**. The bare `/tasks` snapshot surfaces
verification debt and says so outright; `pick` — the natural way to resume a session — collected `todo`
candidates and offered one, so a session opening with it was handed fresh work while code-complete tasks sat
unverified, and never learned they existed. Picking new work over unverified work is precisely what the
verification-debt rule exists to prevent, and the verb that *starts* work was the one place the rule was
never stated.

**The fix.** A new step **2b**, before candidates are collected or presented: report `review`-state tasks as
count plus ids, using the snapshot's own words. Three-way, so it cannot become noise:

| Debt | Behaviour |
|---|---|
| none | say nothing |
| 1–2 | one line, then continue |
| 3+ | the line, then **ask** *"clear debt first?"*, default yes — declinable |

**A nudge, not a gate**, which the task's own Out of scope required: debt is a judgement call, and a gate
that cannot be overridden gets worked around, costing more than the reminder is worth.

**Two criteria resolved by *not* changing anything, which is the part worth reading.**

- **`fix-next` already had this check** at its step 1, in almost the same words. Nothing was added — `pick`
  step 2b now points at it, so the two read as one rule rather than two similar ones.
- **AC 6 dissolved.** It asked whether `/tasks` is a better resume command than `/tasks pick` — an argument
  resting entirely on `pick` being debt-blind. It isn't any more. `AGENTS.md` already points at `/tasks` for
  *"where things stand"*, which stays right for a different reason (the snapshot is a better survey), and
  [[handoff]] is 15 lines that never name a resume command, so there was no advice to retract. Making an edit
  anyway would have put this repo's tooling into a generic skill to solve a problem that had just been fixed.

**Step 6 — what could and could not be checked.** The plan's headline scenario, *"with 7 tasks in review"*,
**no longer exists**: the seven were cleared days ago and the tree has had zero since. So:

| Check | Result | Role |
|---|---|---|
| debt reported before any candidate | step 2b precedes step 3 (collect) and step 4 (present) | **fix-dependent**, verified structurally — the ordering *is* the fix |
| clean tree produces no debt line | tree is clean today; row one of the table is *say nothing* | **genuinely exercised** — the one item today's state can test |
| a `review` task is never a candidate | `--status todo` default, plus 2b's explicit statement | contract pin — true before this change, must stay true |

The unrunnable item is recorded as unrunnable rather than ticked as passed. A session that hits real debt is
the stronger test, and it will happen without anyone scheduling it.

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped.

## Progress log

- step 2 — picked; ranked above TASK-024 on key 4 (self-containment: one addition to one verb, versus "teach the *other* owner verbs to reconcile" across several files, with TASK-063 reopening the adjacent row) and key 5 (this defect has a **documented workaround in the repo** — EPIC-001's state note says *"`/tasks pick` still will not mention debt when it exists (TASK-010, open), so keep running bare `/tasks` first"*, which is evidence it was live and being routed around). Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **held exactly.** `grep -c review skills/tasks/verbs/pick.md` → **0**.
- step 4 — layer: **local.**
- step 5 — fix in `skills/tasks/verbs/pick.md` (step 2b, three-way threshold, snapshot wording, pointer to `fix-next`'s equivalent).
- step 6 — one item genuinely exercised (clean tree), one verified structurally (ordering), one contract pin; the 7-in-review scenario recorded as no longer existing rather than ticked.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: both bullets are boundaries (`close` owns what `review` means; not blocking `pick` is stated as deliberate). Nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
