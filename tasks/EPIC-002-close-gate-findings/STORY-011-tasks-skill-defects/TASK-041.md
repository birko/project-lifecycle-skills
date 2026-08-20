---
id: TASK-041
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
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

- [ ] There is a supported, documented path from *loose tasks with no epic* to *a drainable
      `kind: review-intake` pool*, without re-filing the tasks or editing their bodies
- [ ] The surface is chosen and recorded (see Implementation plan step 1) — extend `--adopt`, or add a
      distinct move/reparent verb — with the rejected alternative and the reason written down
- [ ] Whichever surface wins, it updates `parent:` **and** moves the file, so placement and frontmatter
      cannot disagree
- [ ] Parents are reconciled after the move, per the SKILL's roll-up rule — a story or epic whose child
      set changed must not be left with a contradicting status
- [ ] `findings:` backfill stays best-effort and **never invents ids**; the run reports how many tasks
      got ids and how many did not (the existing `--adopt` rule, preserved)
- [ ] `skills/tasks/SKILL.md`'s verb table lists the surface if it is a new verb; `intake.md`'s Args and
      Edge cases are updated if it is an extension
- [ ] At least one `.github/workflows/skills-lint-test.sh` case fails without the change (per the
      standing rule that a lint/skill change is not done until a test pins it)
- [ ] If this introduces a new cross-cutting pattern, it is registered in `AGENTS.md § Conventions` in
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
