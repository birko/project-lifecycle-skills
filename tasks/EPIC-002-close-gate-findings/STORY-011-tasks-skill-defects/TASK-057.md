---
id: TASK-057
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
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

- [ ] `fix-next/SKILL.md:257` no longer states a count — it points at the table instead, so the sentence survives the table growing again
- [ ] `verify-intent/SKILL.md:174` describes the ledger as an intent source **read now**, matching the § *Intent* table
- [ ] `verify-intent/SKILL.md:175` no longer calls `docs/specs/` an intent source; it names it as the **baseline**, matching the body
- [ ] `docs/architecture.md:105` lists `docs/glossary.md`, and the `docs/adr/` entry reads as arrived rather than arriving
- [ ] Each fix is checked against the body it summarises, not just made internally consistent — the body is the authority in all four
- [ ] `bash .github/workflows/skills-lint.sh` passes

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
