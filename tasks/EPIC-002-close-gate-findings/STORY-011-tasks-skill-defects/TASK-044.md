---
id: TASK-044
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
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

# EPIC-002 groups by subject, so `fix-next`'s theme tie-breaker has nothing to read

## Context

Filed by `/code-review` at TASK-040's close gate.

`/tasks intake` step 5 (`skills/tasks/verbs/intake.md:92-98`) mandates a **fixed seven-theme ladder**
for the stories it creates:

> security & tenancy → correctness & invariants → data integrity → contract drift → performance →
> reuse & dead code → docs, i18n & coverage

and says to keep that order because **it doubles as [[fix-next]]'s tie-breaker**. `fix-next` confirms
it from the other side (`skills/fix-next/SKILL.md:124-125`): *"Ties break on the intake theme ladder …
then `priority:`, then oldest `created`."* It is tie-break key 6.

(That sentence as filed said "key 6 of 6". It was wrong when written: the skill numbered only keys 1-5
and then added three unnumbered tie-breaks, so the ordering had eight criteria and nothing named which
was which. `/code-review` caught it at this task's own close gate; the fix numbers them 6/7/8.)

EPIC-002 groups its six stories by **the skill each defect lands in** instead — `verify-conventions`,
`tasks`, the universal layer, `roadmap`, `specs`, CI. That grouping is genuinely useful here: it keeps a
drain session inside one skill's surface instead of ping-ponging across the set, and these findings
arrived from many passes over three days rather than from one pass with a shared severity scale.

**But it silently disables a ranking key.** No story under EPIC-002 maps to a ladder theme, so when
`fix-next` reaches key 6 it has nothing to match and falls through to `priority:` then `created`. All
20 tasks are P2/P3 prose defects with broadly similar blast radius, which is exactly the tie condition
key 6 exists to break — so the degradation is likely, not hypothetical. Worse, it is **silent**: nothing
reports that a ranking key was inert, so the ordering looks deliberate.

A related question the fix must not dodge: `skills/tasks/SKILL.md`'s router row describes `intake` as
producing *"STORYs by severity theme"*, which is **not** what the verb does — the ladder is a subject
ladder and severity maps to `priority:` instead. That one-liner is what led to this grouping being
justified against a rule that does not exist. Under *a verb owns its rules* the verb file wins, so the
router line is wrong and should be corrected whichever way this decision goes.

## Acceptance criteria

- [x] The choice is made and recorded with its rationale: **regroup** EPIC-002's stories onto the
      ladder, or **let a story declare its ladder theme** so subject grouping and the tie-breaker can
      coexist, or **accept the deviation** and say plainly that key 6 is inert for this epic
- [x] Whichever is chosen, `fix-next`'s ranking is never left silently short a key — if a key cannot
      apply, the ranking paragraph it prints says so
- [x] If the "declare a theme" route wins, the declaration is machine-readable rather than prose —
      `fix-next` already carries a note that a prose marker beat it once (its DV12 carve-out) and that
      a machine-readable marker would have been better
- [x] `skills/tasks/SKILL.md`'s router row for `intake` no longer says "by severity theme"
- [x] If the ladder itself should admit subject grouping for adopted backlogs, that change lands in
      `intake.md` step 5 — not as a local exception in this epic

## Out of scope

- **Re-homing tasks again.** TASK-040 placed them; if regrouping wins, that is this task's own work,
  but no task's body changes and no id is reassigned.
- Changing `fix-next`'s other five ranking keys.
- **This is a decision task.** [[fix-next]] excludes anything whose acceptance is *"decide X"* from its
  pool, so it will surface this rather than pick it — that is correct, and it is why the acceptance
  above puts the decision first and the edits second.

## Human test plan

- [x] After the change, run `/fix-next` against EPIC-002 and read its ranking paragraph: confirm it
      either names the ladder theme that broke the tie, or states that the key did not apply
- [x] Confirm two tasks from different stories that tie on every other key resolve in a defensible,
      explainable order — and that a reader can tell *why* from the printed paragraph alone — **drilled
      2026-08-20 on TASK-039 vs TASK-029**, see the Outcome below

## Implementation plan

**Decision taken: let a story declare its ladder theme.** Regrouping onto the ladder was rejected on
evidence — see the finding below, which changes what this task can honestly claim to fix.

**The finding that shapes the rest.** Mapping EPIC-002's six stories onto the ladder gives **theme 2
(correctness & invariants) five times** and one arguable 7. That is not an artefact of the by-skill
grouping: a repo whose product is prose rules produces almost only "broken architectural rule" defects,
so *regrouping onto the ladder would have produced one enormous theme-2 story and a small theme-7 one*
and discriminated no better. The ladder is **near-degenerate for this repo**, and the by-skill grouping
therefore loses nothing the ladder would have provided.

So this task cannot restore ranking power that was never available. What it can do — and what the
acceptance criteria actually ask for — is stop the key failing **silently**:

1. **`theme:` becomes an optional STORY frontmatter field** (`skills/tasks/templates/STORY.md`), an
   integer 1-7 naming its ladder position. Machine-readable, per the acceptance criterion: `fix-next`
   already carries a note that a prose marker beat it once and a machine-readable one would have won.
2. **`intake` step 5 writes it** when it scaffolds a theme story — it already knows the number, it just
   never recorded it, which is why `fix-next` had to infer the theme from a title.
3. **`fix-next` step 2 reads it** for key 6, and its ranking paragraph must say when the key did not
   discriminate — absent on the candidates, or identical across them. Both cases are real here.
4. **`skills/tasks/SKILL.md`** — the router row saying `intake` produces "STORYs by severity theme" is
   corrected to subject theme, and the "Four optional frontmatter fields" paragraph becomes five.
5. **EPIC-002's six stories are stamped** with their honest theme, degeneracy included. Stamping five
   identical values is the point: it makes the inertness visible instead of leaving it to be rediscovered.
6. **`AGENTS.md § Conventions`** records the new field, per register-on-introduce.

No `skills-lint.sh` change, so no new lint case is owed; the drill is the test.

## Progress log

- 2026-08-20 — `theme:` added to the STORY template, written by `intake` step 5, read by `fix-next` as
  tie-break key 6. Router row corrected (`intake` themes by **subject**, not severity — the wrong
  one-liner that caused this defect). Six EPIC-002 stories stamped. Registered in `AGENTS.md`.
- 2026-08-20 — `/verify-conventions`: one warning, fixed. The new standing rule stated a **live count**
  ("five of six stories are theme 2"), which is the same restating-a-growing-number defect `/code-review`
  had just caught in STORY-015. Rewritten to state the mechanism instead of the tally.
- 2026-08-20 — `/code-review`: 9 findings, all confirmed, all addressed. Two were high and one was
  design-changing:
  - **`theme:` is on the STORY, but `fix-next` ranks TASKs** — nothing said to resolve `parent:` to the
    story to read it, so an agent would look on the task, find nothing, and report the key inert on a
    backlog that does declare themes. Grepping `fix-next` for `parent:` or `STORY.md` returned zero hits.
  - **`intake --adopt` never backfilled `theme:`** — the one path the change exists to serve was the one
    path where the field stayed absent forever. It now offers a slug per story.
  - **The field stored a row number**, freezing `intake`'s table order into every stamped story: insert
    or reorder a theme and they all silently remap. Switched to a **slug**, with the table declared the
    single source of the order and the restatement in `fix-next` deleted.
  - Also: undeclared themes now sort *after* declared ones (a partially-declared pool had no defined
    order, so two runs could rank it differently); tasks in `_loose/` or parented straight to an EPIC are
    named as theme-less by construction; the tie-breaks are numbered 6/7/8 so "key 6" means something;
    the Collection-pass capture list gained `theme`; the template comment and the stamped comment are now
    byte-identical; and EPIC-002's body was reconciled — it still said no story mapped to a theme, and
    still counted 20 tasks when TASK-044 made 21.
- 2026-08-20 — human test plan **partially** run. The `theme:` lookup works end to end: `fix-next`
  resolved each candidate's `parent:` to its `STORY.md` and read the slug, which is the contract that
  did not exist before. The ranking paragraph correctly reports key 6 as **not engaged** — the pool
  separated on keys 1-5 — and the top pick is `docs-i18n-coverage`, the theme that sorts *last*,
  which demonstrates key 6 is a tie-break rather than a primary sort. The second test-plan item is
  **not** satisfied: it needs two candidates tying on every one of keys 1-5, and no such pair arose at
  the decision point in this run. Task stays at `review` until a run produces one; closing it on a
  drill that did not exercise the rule would make the tick a lie.

- 2026-08-20 — second test-plan item **discharged**, on the pool as it stood (19 todo). The pair is
  **TASK-039** (STORY-011, `correctness-invariants`) against **TASK-029** (STORY-015,
  `docs-i18n-coverage`), and they tie on every one of keys 1-5:

  | Key | TASK-039 | TASK-029 | |
  |---|---|---|---|
  | 1 severity | nothing is wrong, the dashboard is thinner than it could be | the guide's case count lags; no wrong results | tie — both bottom tier |
  | 2 reachability | internal only | internal only | tie |
  | 3 silence | no answer is produced, so nothing can be plausibly wrong | same | tie — the key does not apply to either |
  | 4 self-containment | add a template placeholder + a triage step line | document what the cases pin | tie — contained, no open design question |
  | 5 verified | filed from TASK-034's criterion with evidence | noticed at TASK-026's close with evidence | tie |

  **Key 6 breaks it**: `correctness-invariants` is ladder row 2, `docs-i18n-coverage` is row 7, so
  TASK-039 ranks first. The demonstration is stronger than a confirmation — key 7 (`priority:`) also
  ties at P3, and key 8 (oldest `created`) would have put **TASK-029 first** (2026-08-19 against
  2026-08-20). So the ladder **reversed** the order the remaining keys would have produced. Had
  `theme:` been absent, as it was before this task, the pool would have ordered these two the other way
  round with nothing recording that a key had been skipped.
