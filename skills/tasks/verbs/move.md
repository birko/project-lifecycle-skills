# /tasks move — re-home a task or story under a different parent

Change where a task lives, so its **file location and its `parent:` field change together**. That
pairing is the whole point: they are two records of one fact, and a hand-edit changes one of them.

## Why this verb exists

`SKILL.md § Conventions` says status changes go through their verbs, never hand-edits — because a
hand-flipped status skips the gates that make it trustworthy. **Placement was the same shape of field
with no verb behind it.** Re-homing meant moving a file and editing `parent:` by hand, with nothing
reconciling the parents afterwards, and nothing stopping the two from disagreeing.

The measured need is the review backlog. [[fix-next]]'s pool is explicit — a `todo` task is in it only
with a non-empty `findings:` list or an EPIC ancestor stamped `kind: review-intake` — so a correctly
written finding sitting in `tasks/_loose/` is unschedulable. Observed on this repo: **17 open loose
defect tasks, pool = 2.** They were re-homed by hand because no verb could.

## Args

- `<ID>` — required. One or more `TASK-NNN` / `STORY-NNN`, space-separated. **Not `EPIC-NNN`**: an epic is a root and has nothing to be re-homed under.
- `--to <ID | _loose>` — required. The destination `STORY-NNN`, `EPIC-NNN`, or the literal `_loose`.
- `--dry-run` — print the moves and the rollups they would trigger; write nothing.

## Steps

1. **Find task root** (SKILL.md § Shape detection).

2. **Resolve each ID and the destination.** Grep `^id: <ID>$` across the task root; grep the
   destination the same way unless it is `_loose`. Refuse, with the reason, when:
   - an ID resolves to nothing, or to an `EPIC-*` (epics are roots — say so rather than failing obscurely);
   - the destination does not exist. **Never create it** — a typo would otherwise silently mint a container;
   - the destination is a TASK (tasks hold nothing);
   - a STORY is being moved under a STORY, or under itself.

3. **Report the plan and confirm** — one line per move, `TASK-041: STORY-011 → STORY-015`, plus the
   parents that will need re-evaluating on **both** sides. Stop here for `--dry-run`.

4. **Move the file.** Use `git mv` in a work tree so history follows; a plain `mv` otherwise. The file
   name never changes — ids are global, so the destination cannot collide.

5. **Update `parent:`** in the moved file's frontmatter, anchored to the field: match `^parent:` between
   the first two `---` fences. **Not an unanchored substring replace** — the frontmatter's own commented
   enum lines contain the words a loose match will hit, which is a defect this repo has already had
   twice (see `verbs/close.md` step 7's note and TASK-036).

6. **Roll up both sides, per SKILL.md § Roll status up to parents.** A move changes two child sets, and
   the *source* is the one that gets forgotten: a STORY that just lost its last open task may now be
   `done`, and a STORY that gained one may no longer be. Re-evaluate the old parent, the new parent, and
   each of their epics. Never leave a container asserting a state its children contradict.

7. **Regenerate the dashboard** — chain [verbs/triage.md](triage.md).

8. **Report**: each move, each parent whose status changed, and each that was re-evaluated and left
   alone. Say the second part out loud — "checked, unchanged" and "not checked" look identical
   afterwards, and this verb's whole risk is a stale parent.

## What this verb does NOT do

- **Backfill `findings:`, or stamp `kind: review-intake`.** Getting a task into a *pool* is
  [`intake --adopt`](intake.md)'s job; this verb only changes where the task lives. The two compose —
  move the loose tasks under an epic, then adopt that epic — and keeping them apart is deliberate: a
  move is a tree operation, and most moves have nothing to do with review findings.
- **Change status.** A moved task keeps it. `close`, `block` and `cancel` own status, and a re-home is
  not a reason to re-open or re-close anything.
- **Edit the task's body.** If the move makes its `## Context` wrong, that is an edit for whoever knows
  why — flag it, do not rewrite it.

## Edge cases

- **Moving a `done` or `cancelled` task** — allowed, and normal when re-homing a backlog whose history you want kept together. Roll-ups still run: the source may become `done`, and a `done` STORY that gains a closed task stays `done`.
- **Moving every task out of a STORY** — leaves an empty container. Do not delete it; report it and let the user `cancel` it if it is finished. Silent deletion loses the record of what was planned.
- **Destination is `_loose`** — legitimate: work that turns out not to belong to its story. But if the task is a **review finding**, warn — `_loose` is outside every pool (SKILL.md § *A task outside a pool*), so this move makes it unschedulable.
- **The task is `in-progress`** — allowed, and worth a word in the report: an agent may be working from its old path.
- **Not a git work tree** — `mv` and say so; nothing else changes.

## Related

- [[tasks]] — the router; `SKILL.md § A task outside a pool` is why the loose case matters.
- [`intake`](intake.md) — `--adopt` stamps an epic once its tasks are under it; this verb is how they get there.
- [[fix-next]] — the consumer whose pool a move can put a task into, or out of.
