---
id: TASK-070
parent: STORY-003
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-22
depends-on: [TASK-069]
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-054-4, DRILL-054-5]
pr: null
github-issue: null
jira-key: null
---

# Two records the backfill missed, found by looking for the wrong thing

## Context

**From the cold read of `docs/adr/` on 2026-08-22.** TASK-054 backfilled the records this repo owed and
was checked for records that should not exist. The cold reader was also asked the inverse question — *is
any `§ Conventions` bullet still carrying its own trade-off inline?* — and its answer was blunt:

> **The set is missing a record more clearly than it has a surplus one.**

Two candidates, both stronger against the bar than the record that got deleted.

### DRILL-054-4 — "Nothing goes in a generated file that its verb cannot derive"

`AGENTS.md § Working rules`, **184 words** — roughly two and a half times the largest bullet that *does*
have a record. It carries an explicitly labelled rejected alternative as a nested sub-bullet:

> **Why not simply give the generator a preserved region?** Because a partly-hand-owned generated file is
> the ambiguity that produces the problem: every regeneration becomes a judgement call, and the second copy
> grows back. Measured instance — `tasks/README.md` carried caveats about TASK-004 and TASK-018 that were
> *lossy summaries* of fuller records already on those task files, plus a verification-debt count that said
> "9" while `EPIC.md` said "seven". Two hand-written copies of one non-derivable fact, disagreeing.
> Deleting the copies lost nothing.

Against the bar, three for three:

- **Hard to reverse** — and the argument is *asymmetric*, which is the strong form: content was **deleted**
  from `tasks/README.md` under this rule, and the bullet's own point is that reintroducing a preserved
  region regrows the second copy. Reversal does not restore the prior state.
- **Surprising without context** — a preserved region is the obvious design and essentially every real
  generator offers one. Refusing it is what needs explaining.
- **Real trade-off** — named alternative, measured instance, stated consequence.

By the repo's own diagnosis this is the textbook case: *"the rule list becomes an essay collection and
`/verify-conventions` has to lint prose."*

### DRILL-054-5 — the declare-versus-derive pair, as **one** record

Two bullets — *"Read the declaration, never infer it"* and *"A derived state must never be cached as a
decision"* — are two halves of a single trade-off, and each restates the other's counter-example. One
sentence now exists in **three** places:

| Where | Text |
|---|---|
| bullet 1 | "a squash-merge history and a commit-to-main history are the same log" |
| bullet 2 | "(a squash-merge history and a commit-to-main history are the same log)" |
| ADR 0004 | "a squash-merge history and a commit-to-main history produce the same `git log`" |

Bullet 2 also carries its discriminating test inline at length and says outright that the judgement is the
hard part: *"Deciding whether something is a declaration to read or a derivation to recompute is the actual
judgement; getting it wrong in either direction is the same defect."* That is a trade-off sentence sitting
in a rulebook.

Bar: **hard to reverse** — the inferred version was already built, and TASK-021 and TASK-023 were spent
killing it; `integration:` exists because of it. **Surprising** — two rules pointing opposite ways with a
non-obvious dividing line is the definition of *the next reader would not have done the same*.
**Real trade-off** — stated explicitly in the bullet.

**One record on where the declare/derive line falls**, both bullets trimmed to rule-plus-pointer, kills a
three-way duplication in the same change.

## Why this depends on TASK-069

Both candidates are judged against a bar that **currently contradicts itself** (DRILL-054-1). Writing two
records under an unresolved bar is how the inconsistency TASK-054 was caught for gets repeated with a
larger blast radius. Resolve the bar, then apply it here — and if the resolved bar rejects either
candidate, **record the refusal** and name the test it failed, exactly as TASK-054 did.

Numbering continues from `0009`; **`0006` is retired and must not be reused** (`domain`: *"allocated in
order and never reused"*), so the gap in the directory is deliberate and this task should not fill it.

## Acceptance criteria

- [ ] The generated-file rule is judged against the **resolved** bar and either gets a record or a recorded refusal naming the failed test
- [ ] The declare-versus-derive trade-off is judged the same way, as **one** record covering both bullets — not two
- [ ] If records are written: numbered from `0009`, `0006` left vacant, and each bullet trimmed to rule-plus-pointer in the same change
- [ ] The triplicated squash-merge sentence exists in **one** place afterwards, with the other two pointing at it
- [ ] Every record written carries the graded-provenance and `Filed:` shape TASK-054's cold read settled on
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Resolving the bar itself — **TASK-069**, which this depends on.
- The seven surviving records. They were reviewed; re-litigating them here would undo that.
- Any further sweep of `§ Conventions` for records. The cold read checked every bullet and named these two; a third pass is speculation, not evidence.

## Human test plan

- [ ] Read each new record against the bullet it was trimmed from and confirm the halves compose without repeating — the same check that caught the dropped qualifier in 0007's bullet
- [ ] Confirm the squash-merge counter-example appears once, and that the two pointers make sense to a reader who lands on the wrong bullet first

## Implementation plan

_Populated by `/tasks plan TASK-070` — leave empty until then._
