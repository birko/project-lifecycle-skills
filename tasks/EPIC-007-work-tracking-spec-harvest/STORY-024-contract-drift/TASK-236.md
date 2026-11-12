---
id: TASK-236
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-17, SH-21, SH-22, SH-23]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `roadmap`'s renders and output model have drifted from the collection they describe

## Context

Found by the project-roadmap spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). All four are in
`skills/roadmap/SKILL.md` §§ 4–5 and the two *Render* sections, and would be fixed in one pass over them.

- **SH-17 — compact slice order.** The prose says "Lead the line with any `review`-phase feature count (verification
  debt)". The example line directly above lists phases in lifecycle order, with `review` after `building`.
- **SH-21 — compact divergence line.** Its only slot is `<FEATURE-NNN DV<x>>`. DV5 (a story or epic), DV7, DV10 and
  DV11 (a spec or the map), DV9 (a task) and DV12 (a story) have no target of that shape, and nothing says how they
  render there.
- **SH-22 — prototype line dropped.** Step 2 collects each feature's `## Prototype` line, and the output model in § 5
  has no field for it, while renderers are told not to re-derive anything. Either the collection is dead or the model
  is missing a field.
- **SH-23 — ordering.** DV11 sits between DV8 and DV9 in the table. The full render's step 1 lists `review`-phase
  features first and step 2 groups by epic, without saying whether a `review` feature also appears in its epic group.

## Acceptance criteria

- [x] The compact slice's example and its prose agree on where the `review` count goes
- [x] The compact divergence line says how a finding whose target is not a feature renders
- [x] The prototype line is either in the output model or no longer collected
- [x] The DV table is in id order, and the full render says whether a `review` feature appears once or twice
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing any DV rule's condition (TASK-207, TASK-231, TASK-232)

## Human test plan

N/A — render and model text, checked by rendering the compact slice by hand from an invented model with one finding
of each target kind.

> **Rendered 2026-11-12** from an invented model: 6 features (1 debt in phase `building`, phases building 3, review 1,
> done 2), with findings FEATURE-031 DV4, STORY-007 DV12, TASK-114 DV9, specs/auth-session DV7, and DV10 on the map:
> ```
> features/  ⚠ sign-off 1 · 6 features · building 3 · review 1 · done 2
>   ⚠ divergence (5): FEATURE-031 DV4, STORY-007 DV12, TASK-114 DV9, specs/auth-session DV7, specs/.map.yml DV10
> ```
> Every finding had a place; the buckets sum to 6 with the debt count outside them.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Trigger: five acceptance criteria.

1. **SH-17** — the prose has since been reworded to lead with `⚠ sign-off <n>`, but the example line still has no
   slot for it. Put the slot in the example, right after `features/`.
2. **SH-21** — the divergence slot becomes `<target> DV<x>`, defined as the output model's `target`, printed as the
   full render's audit line prints it, with an example per target kind. Align the two other renders of the same line
   (`triage.md` step 8b, `feature/templates/README.md.tmpl`), which carry the same feature-only slot.
3. **SH-22** — drop the `## Prototype` collection. Nothing in `roadmap` reads it (no DV rule, no render), `/feature
   status` reads it itself, and its value list is stale ("Built, then deleted" is missing).
4. **SH-23** — move DV11's row after DV10, and say a debt feature listed first still appears in its epic group.
5. Respec `project-roadmap`.

## Outcome

**The fix.** `roadmap`'s renders and output model had drifted from the collection they describe, in four places:
- **Sign-off lead:** the compact slice's prose said to lead with a sign-off count that its example line had no slot
  for.
- **Divergence slot:** it took only `<FEATURE-NNN DV<x>>`, so a finding on a story, task, spec or the map had no
  stated rendering. This repo's dashboard was already improvising `EPIC-001 … DV5`.
- **Prototype line:** collected and then dropped by the output model.
- **Ordering:** the DV table ran 8, 11, 9, 10, and the full render did not say whether a debt feature also appears in
  its epic group.

All four are settled in `roadmap/SKILL.md`. The same feature-only slot is also corrected in `triage.md` and the
`feature` index template.

**Step 6 split.** 5 of 5 assertions failed on HEAD's `roadmap/SKILL.md` and pass on the fix, all fix-dependent: the
example carries the lead, non-feature targets are stated, the prototype is not collected, the DV table is in id order,
and the full render says "appears in its epic group". Contract pin, **not evidence**: skills-lint passes on both.

**Judgement calls.**
- **Prototype collection dropped, not added to the model.** The criterion allowed either. Nothing in the roadmap reads
  it: no DV rule and no render. `/feature status` reads `idea.md`'s line itself, and the roadmap's copy of the value
  list had already gone stale ("Built, then deleted" missing). A model field nothing renders is a second copy waiting to
  drift.
- **A debt feature appears twice** (lead list and epic group), rather than once. The lead is a pointer to outstanding
  work, while the epic group is the tree that shows phase and sync. Removing a feature from its group would make an
  epic's line count disagree with its tasks.
- **`triage.md` and the feature index template aligned too.** They render the same line from the same engine, and
  carried the same feature-only slot. They now point at the roadmap's definition rather than restating the list of
  target kinds in full a third time.
- **SH-17's prose had already been reworded** since the harvest, from "`review`-phase count" to the debt count. The
  remaining defect was the example, and only that was changed.
- **Spec** `project-roadmap`: the collection requirement and its scenario lose the prototype line, the full render
  gains "appearing again in its epic group", and the compact slice gains the target rule. Restamped. `shaped-by`
  unchanged: the one intervening `skills/roadmap` commit (9abf3f7, TASK-207) is not feature-linked and updated this
  spec itself.
- **Close gate ran inline** on a ~30-line prose diff.
  - Standards: no finding.
  - Intent: all five criteria met, plus the two sibling renders.
  - Correctness: the DV table rows were moved whole; every DV id still appears once.
  - Security: not applicable.
  - Comments: the feature template comment now carries the target rule, a rendering instruction.

**Flagged, not fixed.** Nothing.

## Progress log

- step 2 — picked; ranked above TASK-238 because both are drifted copies in a skill's rules (key 1 wrong results), but `roadmap`'s compact slice is rendered by the bare `/tasks` snapshot and `/feature` listing on every call, while `specs verify`/`show`'s restated rules fire only on those two verbs (key 2, reachability). Last run's runner-up. Key 6 did not separate them: both `contract-drift`
- step 3 — verified: SH-21, SH-22, SH-23 held as written; SH-17 held reworded (prose now leads with `⚠ sign-off <n>`, the example has no slot for it). Also found: `triage.md` 8b and the feature index template carry the same feature-only divergence slot
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (trigger: five acceptance criteria)
- step 4 — layer: local
- step 5 — fix in skills/roadmap/SKILL.md (sign-off slot in the example; `<target> DV<x>` with per-kind examples; prototype collection dropped; DV11 row moved after DV10; debt feature appears in its epic group too), skills/tasks/verbs/triage.md and skills/feature/templates/README.md.tmpl (same slot)
- step 6 — reverted fix (HEAD's roadmap/SKILL.md): 5/5 assertions failed; fix-dependent = all five; contract pins = skills-lint (passes on both)
- step 7 — respecced project-roadmap (surgical); requirements changed: feature collection (no prototype line, and its scenario), full render (debt feature also in its epic group), compact slice (divergence entries by target and rule id); intended — TASK-236's criteria. shaped-by unchanged: intervening 9abf3f7 (TASK-207) is feature: null and respecced this area itself
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
