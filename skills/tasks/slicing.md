# Slicing — how to cut work into tasks

**The one owner of how work is cut into tasks.** Every verb that creates, splits or sizes a task points
here. Point at it, never copy it: a copy goes wrong silently the moment a row is added here.

"Atomic and independently completable" is the property. This file is the method that produces it.
Without a method the slicing is improvised every time, and the failure it produces is specific:
**tasks that cannot land green on their own.**

## The four rules

| Rule | What it means | Rejects |
|---|---|---|
| **Vertical, not horizontal** | Each slice cuts a narrow but complete path through every layer the change touches. | A slice of one layer across the whole change ("all the templates first", "all migrations first"). |
| **Verifiable alone** | Once its `depends-on` are done, the slice can be shown or checked without any sibling. | A slice whose test plan needs a sibling landed first. |
| **Sized to one fresh context window** | It passes the three checks in § *One fresh context window*. | A slice that needs another task open to be understood. |
| **Prefactor first** | Make the change easy, then make the easy change. The prefactor is **its own task**, and it `blocks` the change it enables. | A prefactor folded into the change, so the task mixes a behaviour-neutral move with a behaviour change. |

**Worked pair, from this skill set's own history.** A new skill had to exist before other skills could
link to it, because the lint fails a `[[link]]` to a folder that is not there.
- **Lands green alone:** one task created the skill folder **and** turned the existing plain-text
  mentions of it into links, in the same change. It is a narrow path through every layer: the folder,
  its behaviour, and its readers.
- **Cannot land:** the horizontal cut "first link every mention, then write the skill". The first task
  is red by construction. The measured cost: one reader held the name in plain text for three days
  because the link could not land yet.
- **Prefactor order:** a rule's delimiter markers landed first, and the lint check comparing the
  marked copies landed after them. In the reverse order, the check would have failed on the first commit.
- **The same shape in code:** one field end to end (migration, endpoint and UI) is vertical;
  "every migration for the feature first" is horizontal.

(Provenance: TASK-051, TASK-074 and TASK-140/141 → TASK-146 in the project-lifecycle-skills
repository's own task tree. The ids are not this project's.)

## One fresh context window

"Small" is taste. Use these checks instead. **Every hard check must pass.** A signal may trip, but
then the task's Context carries **one line saying why** it is still one task, and a missing line is
itself the finding.

| Hard check | How to check it |
|---|---|
| **H1 — Context stands alone** | Strike every other task id out of Context and the criteria. The task can still be acted on; any id left is provenance or a boundary, not a prerequisite for understanding. |
| **H2 — Verifiable inside the task** | No acceptance criterion and no human-test step needs another task landed first, beyond its `depends-on`. |
| **H3 — Lands green alone** | Name the gate (the lint, CI, the test suite). After this task's change, with its `depends-on` done, can the gate be red? If yes, it is not a slice. Judge it against the gate's state **before** the change: a gate already red is measured as "no new failures", and the task says so. **Green is necessary, not sufficient**: where the gate cannot see behaviour (a prose repo's lint checks links, not meaning), also ask whether the change leaves a state nothing can act on, such as a value written that no reader handles yet. That fails H3 too. |

| Signal | Where it is defined |
|---|---|
| Too many acceptance criteria, a title joining clauses with "and" / "+", Context spanning unrelated areas | [`audit`](verbs/audit.md)'s `splittable` row, which owns the thresholds |
| More than one owner edited beyond one-line pointer edits (an owner is a skill folder or a module) | here. A pair that a repo rule forces to change together, such as both front doors under a layer-parity rule, counts as one owner. |
| A reviewer could approve one part and reject another | [`spawn`](verbs/spawn.md)'s scope test, turned around |

**A shape one owner writes and another reads is an edge, not one owner.** If a slice changes the shape, the writer's task `blocks` the reader's. If the shape stays compatible, the two slices are independent. Say which in the Context.

## Before slicing — is this the exception?

Run this **before** cutting anything, so the exception is found before slices that cannot land exist:

1. Does the change alter something **other code or prose reads**: a symbol, a column, a path, a
   flag, a heading, a term?
2. Grep the old form. Do its readers span more owners than one slice may touch?
3. Yes to both → **no vertical slice can pass H3.** Sequence it as a wide refactor (below).
4. Then: can the old and new forms **coexist**? Yes → green batches. No → § *When batches cannot
   stay green*.

## Wide refactors — expand → migrate → contract

A mechanical change whose readers fan across the codebase, such as renaming a shared symbol or
retyping a column, breaks every call site at once. Sequence it in three phases:

| Phase | Shape | Edges |
|---|---|---|
| **expand** | Add the new form beside the old one, so nothing breaks. | one task; `blocks` every batch |
| **migrate** | Move the readers in batches **sized by blast radius**. | one task per batch; each `depends-on` the expand only |
| **contract** | Delete the old form. | one task; `depends-on` **every** batch |

**CI stays green from batch to batch because the old form still exists** until contract. That is the
whole reason for the expand.

**When the writer cannot carry both forms** (one template writes one heading; a column has one type),
the expand is on the **read** side: every reader accepts both forms. Switching the writer is then the
contract, which is why it waits for every batch. **When some readers are out of reach** (copies rendered
into other repos), the read-side alias is permanent: contract switches the writer and removes the old
form only from what the repo holds, and says so.

**Blast radius here means fan-out, not severity.** It is not [[fix-next]]'s ranking key, which measures
how bad a defect is. Measure it this way:
- **In a prose or skill repo:** `git grep -l -w '<old form>'`, grouped by owner. Mark which references a
  lint check resolves, because those go red when broken. Count separately the copies the repo renders
  into **other** repos from templates: those are out of reach, so the old form must stay readable there,
  and contract covers only what the repo holds.
- **In a code repo:** the compiler's or find-usages' references, grouped by module or owner, **plus**
  what the compiler cannot see: reflection, string keys, SQL, config, serialized data. For a column,
  also count the rows and their readers.
- **One batch is one owner group's references.** Split a group further only when it trips a size signal.

## Where the edges live

Edges go on **task frontmatter, on both sides**: `blocks:` on the earlier task, `depends-on:` on the
later one. If the sequence has no parent yet, creating it comes first. `STORY.md` has no edge fields,
so keep the whole sequence under one parent (give the same story at `new`'s parent step for every
task) and let the task files carry the order.

- Create each task with `/tasks new task --no-plan` (add `--from-feature FEATURE-NNN` from `decompose`), then write the edges in the same change.
- **Do not use `/tasks block --on`** to record order: it also marks blocked (the `blocked:` field) a task that is
  merely waiting its turn.
- `/tasks audit` then checks the edges for broken links and cycles, and `pick` warns on an unmet
  `depends-on`.

## When batches cannot stay green

Read `integration:` from `tasks/.config.yml`. **Never change it to make a sequence fit**: a policy
minted for convenience is a declaration nobody made.

| `integration:` | Do |
|---|---|
| `pr-per-task` | The batches share one **integration branch**, cut by hand, because `pick` cuts task branches from the default branch. Each batch closes through `close`'s deferred-merge path: it ends `blocked`, with a reason note naming the integrate-and-verify task, and **no** `depends-on` back to it, which would be a cycle. A final **integrate-and-verify** task `depends-on` every batch, merges the branch, runs the full gate, and is **the only point where green is promised**. It then closes the batches. Contract comes after it. |
| `single-branch` | There is no shared branch, and every commit lands where `done` means *on the default branch*. Either **collapse the non-green batches into one task** (H3 outranks the size signals, and the task says so), or **widen the expand** with an alias or adapter until the forms coexist. Report which, with one of two fixed lines: `integration fallback unavailable under single-branch — non-green batches collapsed into TASK-NNN`, or `integration fallback unavailable under single-branch — expand widened with <alias or adapter> so both forms coexist`. |

## Report what you rejected

When a candidate slice is discarded, **name the rule or check that rejected it** ("H3: lint check
fails on the link before the folder exists"). A slicing whose rejections are unexplained cannot be
reviewed; it is taste again.

## Not to be confused with

- **[[tdd]]'s "horizontal slices"** is the same word at a different scale: the order of tests and code
  **inside one task**. This file is about how work is cut **across** tasks. Both prefer vertical.
- **[[fix-next]]'s "blast radius"** ranks defects by how much damage they do. Here it counts how many
  readers a change has.
