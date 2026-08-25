---
id: TASK-070
parent: STORY-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
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

# The decline clauses the rulebook owes — and one record it actually does

## Context

> **⚠ This task's original premise was overturned on 2026-08-22, after it was filed.** It was written to say
> *"the set is missing a record more clearly than it has a surplus one"* and to add records for the
> generated-file rule and the declare-versus-derive pair. **Both are rulebook entries**, and under the
> rescoped bar (TASK-069) a rulebook entry keeps its reasoning inline and gets **no** record. The two
> candidates are therefore correctly absent, not owed. The original text is kept below the line because the
> *evidence* it gathered is still good — only the conclusion changed.

**What is actually owed.** A cold read found that of every § Conventions bullet carrying a trade-off with no
record, **exactly one** carried the decline clause the rule requires (*"name the test that failed when you
decline, and decline out loud"*). Every other is silently absent — which the rule itself names as the failure
mode: *"a skipped record and an unnoticed one are indistinguishable afterwards."*

Bullets identified as needing a clause: the `(lazy)` layer artifact rule, the derived-state rule, the
format-is-a-contract rule, the owner-verb-reconciles rule, and the placeholder-token rule. Two more were
written during TASK-069 and already carry one (review axes, shared vocabulary), which is the shape to copy.

**And one record genuinely is owed — from a section nobody swept.** The companion rule only ever patrols
§ Conventions, so **§ Architecture** was never checked. It carries this:

> Both installers **link** rather than copy, so an edit here is live in every consuming project immediately.
> The corollary bites: a link is created per *folder*, at install time … The installers only ever *add*, so
> renaming or deleting a skill also needs a manual sweep of both roots; nothing prunes the old junction.

Under the rescoped bar this is a **project decision with a footprint outside the rulebook**: junctions exist
on every developer machine and in every consuming project, and every consumer depends on edit-liveness.
Reversing to copy semantics does not remove them and silently changes the contract. Surprising, and a real
trade-off (link versus copy, with a stated cost). **That is a record.**

---

_Original context, filed before the bar was rescoped:_

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

- [ ] Every § Conventions bullet that carries a trade-off and has no record gains a **decline clause** naming why — matching the shape of the two written at TASK-069
- [ ] The generated-file rule and the declare-versus-derive pair are recorded as **correctly absent** with the reason (rulebook entries), not left silent — the evidence gathered below is what the clause cites
- [ ] The declare-versus-derive **triplication** is fixed regardless: the squash-merge counter-example currently sits in two bullets and ADR 0004; it ends up in one place with the others pointing at it
- [ ] The installer link-versus-copy decision in § Architecture gets a record, numbered from `0009` (`0006` and `0007` are retired and must not be reused)
- [ ] § Architecture is swept for any other unrecorded project decision, and the sweep's outcome is stated either way — this was the unpatrolled lane
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
