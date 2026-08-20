---
id: EPIC-002
# status: planned | in-progress | done | cancelled
status: planned
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
filed by the close gate of the re-homing work itself, which is why the epic holds 20 and not 17. The
stories group by the **skill each defect lands in**, so a drain session stays inside one skill's surface
instead of ping-ponging across the set.

**The grouping deviates from `intake`'s theme ladder, and that has a cost.** `intake` step 5
(`verbs/intake.md:92-98`) mandates a fixed seven-theme subject ladder — security & tenancy, correctness
& invariants, data integrity, contract drift, performance, reuse & dead code, docs & coverage — and
says to keep its order because it doubles as [[fix-next]]'s tie-breaker. These stories group by the
**skill each defect lands in** instead, so a drain session stays inside one skill's surface.

The cost is concrete, not theoretical: `fix-next` breaks ties on that ladder as ranking key 6
(`skills/fix-next/SKILL.md:124-125`). No story here maps to a ladder theme, so on a tie — likely, since
all 20 tasks are P2/P3 prose defects with similar blast radius — key 6 has nothing to match and ranking
falls through to `priority:` then `created`. **This is a recorded deviation awaiting a decision, not a
settled choice**: either regroup onto the ladder, or teach a story to declare its ladder theme so the
tie-breaker keeps working. Tracked as TASK-044.

## Success criteria

- Every story's tasks are drained to `done` through `/tasks close`, or explicitly `cancelled` with a reason
- No finding is closed without the regression check its fix implies — a skill defect that shipped once
  can ship again, and `.github/workflows/skills-lint-test.sh` is where that check lives for anything
  lint-visible
- The epic ends empty. It is a holding pen for found work, not a living area of concern — when the last
  task closes it goes `done`, and the next review pass gets its own intake epic rather than reopening this one
