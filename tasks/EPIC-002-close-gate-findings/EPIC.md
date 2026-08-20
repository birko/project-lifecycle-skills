---
id: EPIC-002
# status: planned | in-progress | done | cancelled
status: in-progress
created: 2026-08-20
owner: František Bereň
affects: skills/, .github/
# kind: omit for a normal epic; `review-intake` marks the epic a review pass was filed into
kind: review-intake
# source: review-intake epics only — where the findings came from (report path, PR, or "security-review <date>")
source: close-gate passes at /tasks close, 2026-08-18 → 2026-08-20 — /verify-conventions, /code-review, and the step 5d out-of-scope sweep. Filed as loose tasks at the time; adopted into this epic by TASK-040.
---

# Close-gate findings on the skill set

## Area of concern

The defects this repo's own merge gate found while building EPIC-001. Every task here was produced by
`/tasks close` — its `/verify-conventions` pass, its `/code-review` pass, or its step 5d sweep for
work described in prose but never given an id — while shipping something else. They are real findings
against shipped skills, not planned work.

They were filed as tasks under `tasks/_loose/` as they arose, which is correct as far as it goes: each
is self-contained, evidenced, and independently pickable. What it does not do is make them **drainable**.
[[fix-next]] builds its pool explicitly (`skills/fix-next/SKILL.md:56-59`): a `todo` task qualifies only
if it carries a non-empty `findings:` list, or **sits under an epic stamped `kind: review-intake`**.
Loose tasks satisfy neither unless someone hand-wrote a finding id, so 15 of the 17 that accumulated
were invisible to the one verb built to drain them; the other two were visible only by accident of
carrying `CR-*` ids.

This epic exists to supply that stamp. Those 17 were re-homed into it unchanged — placement and
`parent:` only, no body edits. Three more (TASK-041, TASK-042, TASK-043) were authored directly here,
filed by the close gate of the re-homing work itself, and TASK-044 by the close gate of *that* —
which is why the epic holds 21 and not 17. The
stories group by the **skill each defect lands in**, so a drain session stays inside one skill's surface
instead of ping-ponging across the set.

**The grouping deviates from `intake`'s theme ladder, and that has a cost.** `intake` step 5
(`verbs/intake.md:92-98`) mandates a fixed subject ladder — that table is the single source of it, so
it is not copied here — and says to keep its order because it doubles as [[fix-next]]'s tie-breaker. These stories group by the
**skill each defect lands in** instead, so a drain session stays inside one skill's surface.

**Resolved by TASK-044, and the resolution changed what the deviation costs.** Each story now declares
its ladder position in a `theme:` field, which `fix-next` reads as tie-break key 6 — so subject grouping
and the ladder coexist and nothing is inferred from a title. What the stamping exposed is that the
ladder is **near-degenerate here**: as stamped, five of the six stories are `correctness-invariants`, because a
codebase whose product is prose rules generates almost only broken-architectural-rule defects.
Regrouping onto the ladder would therefore have produced one enormous correctness story and a small
docs one, and discriminated no better — so the by-skill grouping costs nothing the ladder would have
provided. Key 6 stays mostly inert on this epic; `fix-next` now has to *say* so rather than let a
skipped key read like an applied one.

## Success criteria

- Every story's tasks are drained to `done` through `/tasks close`, or explicitly `cancelled` with a reason
- No finding is closed without the regression check its fix implies — a skill defect that shipped once
  can ship again, and `.github/workflows/skills-lint-test.sh` is where that check lives for anything
  lint-visible
- The epic ends empty. It is a holding pen for found work, not a living area of concern — when the last
  task closes it goes `done`, and the next review pass gets its own intake epic rather than reopening this one
