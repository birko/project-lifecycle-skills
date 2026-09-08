---
id: EPIC-002
# status — one of: planned, in-progress, done, cancelled
status: in-progress
created: 2026-08-20
owner: František Bereň
affects: skills/, .github/
# kind: omit for a normal epic; `review-intake` marks the epic a review pass was filed into
kind: review-intake
# source: review-intake epics only — where the findings came from (report path, PR, or "security-review <date>")
source: close-gate passes at /tasks close, 2026-08-18 → 2026-08-20 — /verify-conventions, /code-review, and the step 5d out-of-scope sweep. Filed as loose tasks at the time; adopted into this epic by TASK-040. Second pass 2026-09-08: /code-review medium over origin/main...HEAD during TASK-106's close gate, 8 findings CR-1…CR-8, filed by /tasks intake --epic EPIC-002.
---

# Close-gate findings on the skill set

## Area of concern

The defects this repo's own merge gate found while building EPIC-001. Every task here was produced by
`/tasks close` — its `/verify-conventions` pass, its `/code-review` pass, or its step 5d sweep for
work described in prose but never given an id — while shipping something else. They are real findings
against shipped skills, not planned work.

### Second intake pass — `/code-review`, 2026-09-08

Run as the correctness axis of TASK-106's close gate, scoped to `origin/main...HEAD` (146 files) rather
than that task's own diff — so everything it found is **adjacent**, in already-committed work, and none
of it blocked the close it was run for. Both gates were independently reproduced by the pass: lint OK
(18 skills), suite 43/43.

**8 findings, `CR-1` … `CR-8`. None dropped.** Two were duplicates of open tasks and were linked rather
than re-filed — `CR-2` → **TASK-081** (the check-4/check-5 contradiction, both sites named), `CR-8` →
**TASK-083** (a stutter in the same sentence-region, one edit). `CR-3` and `CR-5` share one root cause —
*a template shipping a live value its own rules say must be chosen* — and are one task by the
findings-travel-in-packs rule.

| Task | Findings | Subject |
|---|---|---|
| TASK-108 | CR-1 | check 4 misses a flag that does not immediately follow the verb — ~20% of invocations |
| TASK-109 | CR-3, CR-5 | two templates mint a value a faithful render should have left for a run to decide |
| TASK-110 | CR-4 | the scaffolder gates two conditional rows on a kind list the inventory replaced |
| TASK-111 | CR-6 | `regen.md` quotes a template format that no longer exists |
| TASK-112 | CR-7 | the adopter's report list omits the `not applicable` state |

**What this pass says about the epic:** three of the five are rules written *in this epic* whose
enforcement half or template never followed — the conventions caught their own authors, which is the
outcome § *Area of concern* above already claims for this tree.

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

## State as of 2026-08-22 — read before picking new work

**6 of 26 tasks done.** Nothing is `in-progress` and nothing is at `review`, so there is no verification
debt here — every open item is a `todo` that has never been started.

**TASK-060 sits at epic level and is the highest-value pick.** It is P1 and it is a *holding pen with a
deadline*: it carries **ten findings** from a single cold-drill pass and its own job is to be
decomposed, not fixed. Until it is routed, ten defects are ranked as one item, which understates them —
three are structural (`LAYER.md` declaring itself the canonical inventory while `new-project` creates
three artifacts it has no rows for; the test-harness evidence ladder reporting `missing` on the repo
that ships it; `present, outdated` being unclaimable for the agent guide, which is the upgrade path's
headline case). It is filed at epic level rather than under a story precisely because it fans out across
`new-project`, `adopt-project`, `LAYER.md` and `tasks`, and any single story would pre-judge that.

**⚠ Do not trust `/fix-next`'s ordering on this epic until TASK-058 lands.** STORY-015 carries
`theme: docs-i18n-coverage` over four correctness defects in `skills-lint.sh` — the repo's *only*
automated gate. That theme is rung 7, the bottom of `intake`'s ladder, and `fix-next` reads it as
tie-break key 6, so the gate's own defects currently rank below every other story here (all
`correctness-invariants`). TASK-044 added the field to make ranking reproducible rather than inferred
from titles; here it is reproducibly wrong, which is the trade a declared field makes. Fix the label
before draining by rank, or drain by hand.

**Where the newest findings came from, and why that shifts the epic's character.** The `source:` line
records this epic's original intake. Everything filed since — TASK-057, TASK-058, TASK-060 — came from
**close gates on other tasks**, not from a standing review pass: TASK-053's gate alone produced two
tasks plus the ten-finding drill. So the "ends empty" success criterion is under real pressure. That is
not a reason to relax it; it is the measurement that makes the pressure visible, and the honest reading
is that this epic drains slower than the work feeding it. Whether that means a second intake epic or a
faster drain is a judgement for whoever picks next.

**One finding here is about this repo's own records.** `docs/features/README.md` carries a hand-written
line (`_No features yet._ See EPIC-001 in tasks/ — the current work is deliberately task-only.`) that
`AGENTS.md` forbids in a generated file. It reached two independent passes from opposite directions at
TASK-053's gate: the cold drill flagged the line itself, and `/code-review` caught that same line being
used to justify suppressing the dashboard's DV5 drift callout. Its home is an EPIC body's
`§ State as of` — like this one. Tracked inside TASK-060.
