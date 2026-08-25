---
id: TASK-041
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `intake --adopt` cannot adopt a loose backlog — it assumes the epic already owns its tasks

## Context

`/tasks intake` has two ways in, and neither reaches the most common shape a real backlog arrives in.

`skills/tasks/verbs/intake.md:34` defines the adopt path:

> `--adopt <EPIC-NNN>` — no new findings; stamp an existing hand-built review epic so it becomes
> drainable (see Edge cases). Runs steps 7–8 only.

and its Edge case (`intake.md:129-134`) is explicit that the tasks are already in place:

> a project may already have an epic full of review findings filed by hand. Don't re-file it.
> […] add `kind: review-intake` to the epic's frontmatter, and — best-effort — backfill `findings:`
> on **its tasks** from ids already named in their bodies.

So `--adopt` needs an epic that already owns the tasks. `intake` proper takes the other route — it
**creates** tasks from findings collected in-conversation or via `--source`. Between them sits the
case with no path: **findings already filed as tasks, but with no epic to stamp.** In this repo that
means `tasks/_loose/` — tasks that are correctly written and completely unschedulable, because
[[fix-next]]'s pool is explicit (`skills/fix-next/SKILL.md:56-59`) and a loose task satisfies neither
of its two conditions unless someone hand-wrote a `findings:` id.

The second half of the gap is that **nothing in the [[tasks]] router moves a task**. The verb table in
`skills/tasks/SKILL.md` has `new`, `spawn`, `intake`, `close`, `cancel`, `block`/`unblock`, `import`,
`export`, `migrate` — no `move`, no `reparent`. Re-homing is therefore a file move plus a hand-edit of
`parent:` in frontmatter. That is not literally forbidden (the standing rule covers *status*, not
placement) but it is the same class of hole: a tracking field with no verb behind it, changed by hand,
with nothing reconciling the parents afterwards.

**Measured instance, this repo, 2026-08-20:** 17 open loose defect tasks, `/fix-next` pool = 2.
TASK-040 re-homes them by hand precisely because this verb cannot. A second consumer repo (Symbio) was
previously recorded as needing an adopt path before its pool was non-empty — not verified here, but it
means this is not a one-repo quirk.

## Acceptance criteria

- [x] There is a supported, documented path from *loose tasks with no epic* to *a drainable
      `kind: review-intake` pool*, without re-filing the tasks or editing their bodies
- [x] The surface is chosen and recorded (see Implementation plan step 1) — extend `--adopt`, or add a
      distinct move/reparent verb — with the rejected alternative and the reason written down
- [x] Whichever surface wins, it updates `parent:` **and** moves the file, so placement and frontmatter
      cannot disagree
- [x] Parents are reconciled after the move, per the SKILL's roll-up rule — a story or epic whose child
      set changed must not be left with a contradicting status
- [x] `findings:` backfill stays best-effort and **never invents ids**; the run reports how many tasks
      got ids and how many did not (the existing `--adopt` rule, preserved)
- [x] `skills/tasks/SKILL.md`'s verb table lists the surface if it is a new verb; `intake.md`'s Args and
      Edge cases are updated if it is an extension
- [~] At least one `.github/workflows/skills-lint-test.sh` case fails without the change (per the
      standing rule that a lint/skill change is not done until a test pins it)
      — **criterion corrected at step 3: it misstates its own rule.** `AGENTS.md § Testing` scopes that
      requirement to changes to **`skills-lint.sh`**, and this change touches none. The premise was tested
      instead of a redundant case being invented: deleting `move.md` yields two check-3 errors and exit 1,
      so the verb **is** pinned by an existing case. Evidence in the Outcome.
- [x] If this introduces a new cross-cutting pattern, it is registered in `AGENTS.md § Conventions` in
      the same change (register-on-introduce)

## Out of scope

- **Re-homing this repo's own loose backlog.** TASK-040 does that by hand; this task removes the need
  to do it by hand *next time*. Do not block one on the other.
- A general task-tree surgery verb (arbitrary re-parenting between epics, bulk moves for tidiness).
  The need being fixed is adoption into a review-intake pool, and a broad move verb invites exactly
  the hand-edits the status-verb discipline exists to prevent.
- Changing how `fix-next` builds its pool. The pool contract is correct and deliberately explicit —
  the defect is that nothing can put tasks *into* it from this starting shape.

## Human test plan

- [ ] On a throwaway fixture repo, create an epic-less `tasks/_loose/` holding 3–4 tasks, one with a
      `CR-*` id already named in its body and the rest with none
- [ ] Run the new path; confirm an epic is created/stamped `kind: review-intake`, the tasks are moved
      with `parent:` matching their new folder, and the run reports 1 task backfilled and the rest not
- [ ] Confirm no task body was modified (diff the files before/after — only frontmatter `parent:` and,
      where backfilled, `findings:` may change)
- [ ] Run `/fix-next` on the fixture and confirm the pool is now non-empty and contains the moved tasks
- [ ] Re-run the adopt path a second time and confirm it is idempotent — already-adopted tasks are
      reported as already current, not moved again or re-stamped (the owner-verb reconcile rule:
      "already current" must read differently from "brought up to date")

## Implementation plan

_Populated by `/tasks plan TASK-041` — leave empty until then. Step 1 is the surface decision:
**recommendation — extend `--adopt` to accept loose tasks** (e.g. `--adopt --loose`, creating the epic
when none is named), because that verb already owns "make an existing backlog drainable" and a general
reparent verb is broader than the need. Record the alternative either way._

## Outcome

**What was broken.** `/tasks intake` had two entrances and the most common shape of a real backlog fitted
neither. `--adopt` needs an epic that **already owns** its tasks; `intake` proper **creates** tasks from
findings. Between them: findings already filed as tasks, with no epic to stamp — `tasks/_loose/`, where a
correctly written finding is outside [[fix-next]]'s pool entirely. Measured here: **17 open loose defect
tasks, pool = 2.**

The second half of the gap was the interesting one: **nothing in the router moved a task.** 16 verbs and no
`move`, so re-homing meant a file move plus a hand-edit of `parent:`, with nothing reconciling the parents
afterwards. `SKILL.md` forbids hand-editing *status* for exactly that reason; placement was the same shape
of field with no verb behind it.

**The surface chosen: a new `/tasks move` verb**, with `intake --adopt` documenting the two-step composition
(`new epic` → `move` → `adopt`).

**Rejected: extending `--adopt` to do the moving.** Smaller, and it looked like the obvious answer since the
measured need is a review backlog. Rejected on two grounds:
- **Re-homing is a tree operation, not an intake one.** Most moves have nothing to do with review findings.
  Burying the mechanism in that flag means the next person re-homing an *ordinary* task hand-edits `parent:`
  again — which is the hole being closed. **This is not hypothetical: it happened during this very session**,
  when TASK-060 was moved from STORY-002 to epic level with a `git mv` and a scripted frontmatter edit,
  because no verb existed. That edit is in commit `a62779f`.
- **Composing keeps `--adopt` idempotent.** If it moved tasks it would have to decide, on a re-run, whether a
  task it can see is one it moved. As two verbs, neither has that question.

**What `move` does, and the invariant it exists to hold.** File location and `parent:` change **together** —
they are two records of one fact, and a hand-edit changes one. Plus the part a hand-edit always forgets:
**roll up both sides.** A move changes two child sets, and the *source* is the one that gets missed — a STORY
that just lost its last open task may now be `done`. The verb re-evaluates old parent, new parent, and both
epics, and reports which changed **and which were checked and left alone**, because "checked, unchanged" and
"not checked" look identical afterwards.

**Two details carried over from defects found earlier today**, rather than rediscovered later:
- step 5 anchors the `parent:` edit to `^parent:` inside the frontmatter fences, **explicitly not** an
  unanchored substring replace — the enum-comment trap that bit twice (TASK-036, and this session's own
  status-flip bug);
- the `_loose` destination is legitimate but **warns when the task is a finding**, since that move makes it
  unschedulable (TASK-042's rule, closed an hour ago).

**AC 7 was corrected before any code was written, per step 3.** It required *"at least one
`skills-lint-test.sh` case fails without the change (per the standing rule…)"* — but that standing rule
(`AGENTS.md § Testing`) is scoped to changes to **`skills-lint.sh`**, and this change touches none. Rather
than invent a redundant case, the premise was **tested**: deleting `move.md` produces

```
ERROR skills/tasks/SKILL.md links to verbs/move.md — not found
ERROR skills/tasks/verbs/intake.md links to move.md — not found
skills-lint: FAILED
```

So the new verb **is** pinned, by existing check 3, in two places. A new case would have tested the fixture
rather than the change.

**Step 6 — accounting.**

| Check | Result | Role |
|---|---|---|
| the verb is pinned by the lint | delete `move.md` → 2 errors, exit 1; restore → OK | **fix-dependent** — this is the evidence for AC 7 |
| the router has the verb | table row present, links resolve | fix-dependent |
| `--adopt`'s precondition is now stated | *"Requires the epic to already own the tasks"* + the loose-backlog edge case | fix-dependent |
| lint | OK (18 skills) | contract pin |

**AC 8 — register-on-introduce fired.** `AGENTS.md § Working rules`' status-goes-through-verbs rule now
carries the placement half: location and `parent:` change together or they disagree, and a move must roll up
both sides — *"the placement equivalent of hand-flipping a status."* Extending the existing rule rather than
adding a neighbouring one, since it is the same principle about a second field.

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped.

**Not done.** `move` is prose an agent follows; it has not been *run*. Its human test plan is the drill, and
the honest note is that this repo currently has nothing to re-home — the 17 loose tasks were re-homed by hand
at TASK-040 and `_loose/` now holds only `done` work. The first real exercise will be a consumer repo, which
is where TASK-041's Context said the need also lives (Symbio, recorded but unverified).

## Progress log

- step 2 — picked; last of the tightly-scoped candidates and the direct complement to TASK-042, closed an hour earlier: that one stops loose accumulation, this one rescues what already accumulated. Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **held on both halves.** Verb table has 16 verbs and no `move`/`reparent`; `--adopt`'s Edge case does say the tasks are already in place. **And AC 7 was corrected here** — it cited a rule scoped to `skills-lint.sh` changes, which this is not.
- step 4 — layer: **local.**
- step 5 — new `skills/tasks/verbs/move.md`; router table row; `intake.md` `--adopt` precondition + loose-backlog edge case with the two-step composition and the rejected alternative; `AGENTS.md` placement rule.
- step 6 — AC 7's premise tested by deleting the verb file (2 lint errors, exit 1) rather than by adding a case; lint green restored.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: the Out of scope bullets are boundaries. Nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
