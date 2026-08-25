---
id: TASK-057
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-053-1, CR-053-3, CR-053-6, VC-053-3]
pr: null
github-issue: null
jira-key: null
---

# Four summaries that contradict the body they summarise

## Context

**A group task, deliberately.** Found by the `/code-review` and `/verify-conventions` passes at TASK-053's
close gate. Four separate files, one failure shape: **a short pointer, count, or list that restates
something maintained elsewhere, and has since drifted from it.** Splitting them would bury the shape,
which is the only interesting thing about them — each fix on its own is one or two lines.

Every one of these is *readable prose that is confidently wrong*, which is worse than an obvious gap: an
agent that skims the summary never reaches the body that contradicts it.

### The four

| # | Where | The drift |
|---|---|---|
| 1 | `skills/fix-next/SKILL.md:257` | Says `close` § step 2's table governs **"four steps"**. The table has 10 rows spanning ~7 distinct steps (4, 5, 5c, 5d, 7, 11, plus the Jira edge case). An agent trusting the count believes three steps are unguarded and re-implements or works around them. The same paragraph warns the table *"grew once already"* — so the count is the one thing it should not have stated. |
| 2 | `skills/verify-intent/SKILL.md:174` | *"[[feature]] — owns the decision ledger **a later release will read** as a second intent source."* It reads it **now**: the § *Intent* table takes `approved`/`changed` rows, and `close` 5b depends on that. |
| 3 | `skills/verify-intent/SKILL.md:175` | *"[[specs]] — owns `docs/specs/`, **the third intended source**"* — flatly contradicting the same page's core rule, *"`docs/specs/` is **not** an intent source, and treating it as one is the mistake to avoid."* This is the worst of the four: an agent that skims Related skills treats spec drift as an unbuilt requirement, the exact inversion § *Baseline* was written to prevent. |
| 4 | `docs/architecture.md:105` | The repo's own-artifacts list says `docs/adr/` *"(arrives with the `domain` skill at STORY-003)"* — it arrived at TASK-052 — and omits `docs/glossary.md`, which exists. |

### Why these are one task and not five

`skills/tdd/SKILL.md:79` is the fifth instance of the same shape and is **already filed as TASK-055**;
leave it there rather than folding it in — it was spawned first and its scope is stated. Cross-reference
the two so a reader of either finds the pattern.

**Do not generalise this into a lint.** Three of the four are semantic contradictions between a summary
and a body in the same file; no grep finds those, and `skills-lint.sh` checking that a `Related skills`
line agrees with the page it sits on is not a thing a shell script can do. If a *mechanical* subset turns
up — a stated count that could be derived — spawn it separately rather than widening this.

## Acceptance criteria

- [x] `fix-next/SKILL.md:257` no longer states a count — it points at the table instead, so the sentence survives the table growing again
- [x] `verify-intent/SKILL.md:174` describes the ledger as an intent source **read now**, matching the § *Intent* table
- [x] `verify-intent/SKILL.md:175` no longer calls `docs/specs/` an intent source; it names it as the **baseline**, matching the body
- [x] `docs/architecture.md:105` lists `docs/glossary.md`, and the `docs/adr/` entry reads as arrived rather than arriving
- [x] Each fix is checked against the body it summarises, not just made internally consistent — the body is the authority in all four
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `skills/tdd/SKILL.md:79` — **TASK-055** owns it. Same shape, already filed.
- Any mechanical lint for stated-vs-derived counts. Spawn it if a checkable subset turns up; three of these four are semantic and unlintable.
- The `(lazy)` rows and both front doors — **TASK-053**, the task whose gate surfaced these.
- Re-auditing every skill for this shape. These four are what two review passes found on one diff; a full sweep is its own task if anyone wants one.

## Human test plan

N/A — fully covered by reading each changed sentence against the body it summarises, plus the lint. There
is no runtime surface: the defect and its fix are both prose, and the check is that two passages in the
same file now agree. A human running a drill would be re-reading the same two paragraphs.

## Implementation plan

_Populated by `/tasks plan TASK-057` — leave empty until then._

## Outcome

**What was broken.** Four places where a short summary restated something maintained elsewhere and had since
drifted from it. All four were *readable prose that is confidently wrong*, which is worse than a gap: an
agent skimming the summary never reaches the body that contradicts it.

| # | Fix |
|---|---|
| 1 | `fix-next` said `close` step 2's table governs **"four steps"**; it spans far more. Now says **every** step, plus *"read the table for the count; do not restate it here — it has grown twice."* The count is gone rather than corrected, so it cannot drift again. |
| 2 | `verify-intent`'s *Related skills* said [[feature]]'s ledger is what *"a later release will read"*. It reads it **now** — the § *Intent* table takes `approved`/`changed` rows and `close` 5b depends on it. Reworded to say so, and to name which rows. |
| 3 | The same list called `docs/specs/` *"the third intended source"*, flatly contradicting the page's own rule two hundred lines up. Now names it the **baseline, not an intent source**, with the one-line reason (a spec says what an area *currently promises*, being harvested from code) and the different question it answers. |
| 4 | `docs/architecture.md` listed `docs/adr/` as *"arrives with the `domain` skill"* — it arrived at TASK-052 — and omitted `docs/glossary.md` entirely. Both now listed as arrived, and named as the layer's two **lazy** rows. |

**Step 3 — one finding was verified wrong before being believed, then re-verified right.** Finding 4 initially
appeared not to hold: a grep for its sentence returned nothing. The sentence wraps across two lines, so the
single-line pattern missed it. Worth recording because the instinct at that moment is to reject the finding
and move on — which would have left a live defect closed as a false positive. The task's own step-3 rule
(*"do not trust the task's own description"*) cuts both ways.

**Step 6 — the shape of the check, honestly.** There is nothing to revert-and-split: the fix is prose, and the
guard is a reader noticing that two passages agree. What *is* checkable, and what this task did instead, is
the **sweep** — every stated count of the repo's own structure in shipped prose, tested against reality:

| Claim | Reality | Verdict |
|---|---|---|
| `AGENTS.md` — lint has "36 cases" | `skills-lint-test: 36 passed` | correct |
| `AGENTS.md` + ADR 0008 — `fix-next`'s "eight" keys | 8 numbered keys in step 2 | correct |
| `AGENTS.md` + `domain` — "five records" | the five-records table has 5 rows | correct |
| `LAYER.md` — "the other three entries" (ladder) | 4 entries, so 3 others | correct (this task's own text) |
| `LAYER.md` — "two rows that work this way today" | 2 unconditional delegations; the test-harness row has a terminating condition and is discussed separately | defensible as written |
| `LAYER.md` — "a cold read of seven records" | dated 2026-08-22, when there were seven | correct — a dated measurement does not go stale |
| `specs` — "the two keys"; `migrate` — "two passes"; `INFER.md` — "two records" | not structural counts | cannot drift |

**So the conditional out-of-scope bullet did not fire, and that is the finding.** It said to spawn a
mechanical lint *"if a checkable subset turns up"*. One did — a stated count — but it was eliminated by
**deleting the count** rather than by checking it, and every other stated count in shipped prose is currently
accurate. Nine claims, one wrong, and it is fixed. **This is a review concern, not a class**, so no lint task
is owed. Recorded rather than left silent, because a condition nobody evaluated looks identical to one that
did not fire.

**Cross-referenced TASK-055** both ways, as this task's Context asked — it was the fifth instance of the same
shape and was filed first.

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped.

## Progress log

- step 2 — picked; ranked top of the pool. Key 1 (severity): finding 3 makes a **gate invert its own rule** — an agent skimming `verify-intent`'s Related skills reports spec drift as an unbuilt requirement, the exact inversion § *Baseline* was written to prevent. Silent (key 3), self-contained (key 4). Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **all four held.** Finding 4 needed a second look — a single-line grep missed a wrapped sentence and briefly read as a false positive.
- step 4 — layer: **local**; three skill files and this repo's own architecture doc.
- step 5 — fix in `skills/fix-next/SKILL.md`, `skills/verify-intent/SKILL.md` (two lines), `docs/architecture.md`.
- step 6 — no revert-and-split applies to prose; ran the **stated-count sweep** instead: 9 claims checked, 8 accurate, 1 fixed. Lint + 36-case suite green.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: conditional lint bullet **evaluated and did not fire** (not a class). Nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
