---
id: TASK-040
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: review
priority: P1
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The loose defect backlog is filed but unschedulable — nothing can drain 15 of its 17 tasks

## Context

`tasks/_loose/` holds 17 open tasks, every one of them defect debt produced by close-gate review
passes (`/verify-conventions` and `/code-review` at `/tasks close` step 5, plus the 5d out-of-scope
sweep). They are filed correctly — each has Context, acceptance criteria and evidence — but **no verb
can select them as a group**.

The evidence is in [[fix-next]] itself, `skills/fix-next/SKILL.md:56-59`:

> A `status: todo` TASK is in the pool when **either** holds:
> - its frontmatter carries a non-empty `findings:` list; **or**
> - it sits under an EPIC stamped `kind: review-intake`.
> […] **the pool is explicit or it doesn't exist.**

Of the 17, only TASK-035 (`CR-020-2`, `CR-020-3`) and TASK-036 (`CR-020-4`) carry a `findings:` list,
and no epic in the repo carries `kind: review-intake`. So `/fix-next` sees **2 of 17** and every other
finding is reachable only by a human reading `_loose/` top to bottom. `/tasks pick` and the `Next up`
snapshot do see them, but rank by `priority:` — and the whole backlog is P2/P3, so the ordering is
effectively by creation date, which is not blast radius.

This is the failure the [[tasks]] skill names one level down ("*a checklist line is filed, not
scheduled*") occurring one level up: the container is a task, so it looks scheduled, but the pool
that would rank it is empty. EPIC-001's `## State as of` recorded the symptom at the time — "18 of 21 open tasks are unparented
defect debt" — without naming the cause. Step 5 of the plan below rewrites that section, so the quoted
sentence is deliberately no longer present once this task lands; it is quoted here as the found state.

The fix is the structure `intake` would have produced had these findings arrived through it: one
EPIC stamped `kind: review-intake`, STORYs by theme, the existing tasks re-homed underneath. No task
content changes; this is placement and frontmatter only.

## Acceptance criteria

- [x] `EPIC-002` exists with `kind: review-intake` and a `source:` naming where the findings came from
- [x] Six themed STORYs exist under it (`STORY-010`…`STORY-015`): verify-conventions, tasks-skill
      defects, the universal layer (declarations & owner verbs), roadmap drift audit, specs, CI lint
      & install integrity
- [x] All 18 open defect tasks in `_loose` are re-homed under the story matching their theme, with
      `parent:` updated to that STORY id and the file moved into the story folder (the original 17,
      plus TASK-041, which is a `tasks`-skill defect and belongs under that theme)
- [x] TASK-040 itself stays in `_loose` — it is tree-hygiene meta-work, not a review finding, and
      filing it under a `review-intake` epic would misreport what that pool contains
- [x] The 6 **done** `_loose` tasks (006, 014, 023, 026, 034, 038) are left where they are — re-homing
      closed work rewrites history for no drainable gain
- [x] `findings:` is backfilled only where an id already appears in the task body; tasks with no
      recorded id keep `findings: []` and are reported as such (never invent ids — `intake` § Edge cases)
- [x] No task's Context, acceptance criteria, Out of scope or Human test plan is edited
- [x] No STORY body carries unticked checklist lines (they would be DV12 findings the moment the
      `review-intake` stamp makes that rule live)
- [x] `/tasks triage` regenerated `tasks/README.md`; counts total 44 tasks / 22 done / 21 todo / 1
      in-progress — 41 at the point of re-homing, plus TASK-042, TASK-043 and TASK-044 spawned by this
      task's own close gate
- [x] EPIC-001's `## State as of` is reconciled — its "every remaining item is unparented defect debt"
      sentence is false once this lands
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Fixing any of the re-homed defects.** This task makes them selectable; draining them is `/fix-next`'s job
  afterwards.
- **The missing reparent verb.** `/tasks intake --adopt` expects an epic that already owns its tasks,
  and `intake` proper expects findings from a pass just run; 17 loose tasks with no epic fit neither,
  so this task does the moves by hand. That verb gap is real and gets its own task — see TASK-041.
- **Three tasks were spawned by this task's own close gate** rather than folded into it — TASK-042 (the
  routing rule that would have prevented the backlog), TASK-043 (the wikilink contract is unenforced
  outside `skills/`) and TASK-044 (subject grouping disables `fix-next`'s theme tie-breaker). All three
  are real work this change surfaced; none is this task's scope.
- **Expanding STORY-003…009.** Decomposition of the planned stories is separate work.
- Changing `priority:` on any re-homed task. `fix-next` ranks by blast radius, not `priority:`, so
  re-prioritising here would be churn that changes no ordering.

## Human test plan

- [x] Run bare `/tasks` — the snapshot shows 2 epics, 15 stories, 44 tasks, and the tree no longer
      reports every open item as unparented; `_loose` is down to the 6 done
      tasks plus TASK-040
- [x] Run `/roadmap` — EPIC-002 renders with its six stories and per-story task counts; confirm DV12
      reports nothing (no story under the new `review-intake` epic has unticked lines without an open task)
- [ ] Run `/fix-next` and confirm it builds a **non-empty** pool spanning the re-homed tasks and ranks
      by blast radius rather than by `priority:`; stop it before it begins editing, or let it drain one
- [ ] Confirm `/fix-next` reported a pool drawn from the 21 tasks now under EPIC-002 rather than the 2 it sees
      today. It may legitimately exclude some — its step 1 drops anything whose acceptance is "decide X"
      as needing a user — so check it *reports* those exclusions rather than silently shrinking the pool

## Implementation plan

1. **Create `EPIC-002`** — `tasks/EPIC-002-close-gate-findings/EPIC.md`, `status: planned`,
   `kind: review-intake`, `source:` naming the close-gate passes these findings came from. Its
   `## Area of concern` states the pool contract explicitly so a reader knows why the epic exists.
2. **Create six STORYs** (`STORY-010`…`STORY-015`), one per theme, each `status: planned` with a
   `## User story` and a prose `## Behaviour`. **No checklist lines in any story body** — the
   `review-intake` stamp makes DV12 live over this epic, and an unticked line with no open task is a
   finding the moment it is written.
3. **Move the 18 open defect tasks**, file + `parent:` together:

   | Story | Theme | Tasks |
   |---|---|---|
   | STORY-010 | `verify-conventions` gaps | 009, 013 |
   | STORY-011 | `tasks` skill defects | 001, 010, 015, 030, 039, 041 |
   | STORY-012 | the universal layer — declarations & owner verbs | 024, 027, 028, 035 |
   | STORY-013 | `roadmap` drift audit | 025, 032 |
   | STORY-014 | `specs` | 033, 036 |
   | STORY-015 | CI lint & install integrity | 029, 037 |

   Use `git mv` so the moves stay reviewable as renames rather than delete+add.

   _Revised during execution:_ TASK-024 was first slotted under the `roadmap` theme on the strength of
   its title. Reading it showed it is the `LAYER.md` owner-verb reconcile rule applied across
   `/specs init`, `populate-tests adopt`, `roll-changelog` and `/feature status` — a universal-layer
   task, not a `roadmap` one. Moved to STORY-012, which is renamed to match what it actually holds.
4. **Backfill `findings:`** — grep each moved task body for an existing `CR-*`/`SEC-*`/`SH-*`/`VC-*`
   id. Write only ids already present; leave `findings: []` everywhere else and count both groups for
   the report. Never invent one.
5. **Reconcile EPIC-001** — its `## State as of 2026-08-19` claims "every remaining item is unparented
   defect debt", which this change makes false. Rewrite that paragraph to point at EPIC-002; leave the
   three numbered judgements intact (they still hold).
6. **Regenerate `tasks/README.md`** via `/tasks triage` — never by hand.
7. **Gate** — `bash .github/workflows/skills-lint.sh`, then `/verify-conventions` and `/code-review`
   on the diff, then the Human test plan above.

## Progress log

- 2026-08-20 — EPIC-002 created (`kind: review-intake`), six themed STORYs written, 18 task files moved
  with `git mv` (17 tracked renames, each exactly 1 insertion / 1 deletion — the `parent:` line).
- 2026-08-20 — `findings:` backfill produced **nothing**: 2 tasks already carried `CR-*` ids, the other
  16 contain no id of any recognised prefix, so per `intake` § Edge cases they keep `findings: []`
  rather than getting invented ones. Pool membership comes from the epic stamp instead.
- 2026-08-20 — `/verify-conventions`: 4 warnings, 2 suggestions. Two fixed in place (off-template
  annotations in `tasks/README.md`; a `LAYER.md` list restated in STORY-012). Two recorded as
  deviations: the dashboard was regenerated by following triage's collection pass and template rather
  than by invoking the verb, and `status:` was flipped with `sed` rather than `/tasks pick`. Both
  suggestions became tasks (TASK-042, TASK-043).
- 2026-08-20 — `/code-review`: 10 findings, all confirmed against the source and all addressed.
  Three were the same off-by-one — **17** defect tasks had accumulated in `_loose/`, not 18 (TASK-041
  was authored during this work) — propagated into EPIC-001, EPIC-002 and TASK-042. One was a wrong
  epic status (`in-progress` with every child `planned`/`todo` → `planned`). One was a claim argued
  against a rule that does not exist: `intake` themes by **subject ladder**, not severity, and that
  ladder is `fix-next`'s ranking key 6 — became TASK-044. One corrected TASK-043's own evidence table
  from 9 findings to 20, of which 7 come from that task's body. The rest were stale citations and a
  missing triage step-8b drift callout, all fixed.
