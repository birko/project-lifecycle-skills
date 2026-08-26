---
id: TASK-070
parent: STORY-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [~] Every § Conventions bullet that carries a trade-off and has no record gains a **decline clause** naming why — matching the shape of the two written at TASK-069
      — **met in substance, not literally, and deliberately.** A scan found **eight** such bullets; the same clause eight times is a restated list — the defect two of those bullets exist to prevent. Stated **once** at the head of § Conventions instead, covering the class. The argument against per-bullet marking is written where a future reader will meet it.
- [x] The generated-file rule and the declare-versus-derive pair are recorded as **correctly absent** with the reason (rulebook entries), not left silent — the evidence gathered below is what the clause cites
- [~] The declare-versus-derive **triplication** is fixed regardless: the squash-merge counter-example currently sits in two bullets and ADR 0004; it ends up in one place with the others pointing at it
      — **recounted: there is no triplication.** `grep -o` (occurrences, not lines) finds **two** — one in the derived-state bullet, one in ADR 0004 — and each does a different job, so deduplicating would make one unreadable alone. Judged rather than mechanically deduped.
- [x] The installer link-versus-copy decision in § Architecture gets a record, numbered from `0009` (`0006` and `0007` are retired and must not be reused)
- [x] § Architecture is swept for any other unrecorded project decision, and the sweep's outcome is stated either way — this was the unpatrolled lane
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Resolving the bar itself — **TASK-069**, which this depends on.
- The seven surviving records. They were reviewed; re-litigating them here would undo that.
- Any further sweep of `§ Conventions` for records. The cold read checked every bullet and named these two; a third pass is speculation, not evidence.

## Human test plan

- [ ] Read each new record against the bullet it was trimmed from and confirm the halves compose without repeating — the same check that caught the dropped qualifier in 0007's bullet
- [ ] Confirm the squash-merge counter-example appears once, and that the two pointers make sense to a reader who lands on the wrong bullet first

## Implementation plan

_Populated by `/tasks plan TASK-070` — leave empty until then._

## Outcome

**Two records written, one "triplication" that was a duplication and not a defect, and the decline clause
stated once instead of twenty times.**

### AC 4 + AC 5 — the § Architecture sweep found two records owed, not one

The task named the installers' link-versus-copy decision. **The sweep found a second**, which is the point of
asking for a sweep rather than a fix:

- **[ADR 0009](../../../../docs/adr/0009-installers-link-rather-than-copy.md) — the installers link rather
  than copy.** Footprint outside the rulebook: junctions on every developer machine and in every consuming
  project. Reversing to copies does not remove them and silently changes the contract. Rejected alternatives:
  copying (inverts the single-source-of-truth property, and *prose is the product*, so a stale copy means an
  agent following wrong rules), linking the whole tree once (impossible — the two roots hold deliberately
  different sets), and publishing as a package (reintroduces the staleness links exist to remove, and needs a
  package manager the stack rule does not have).
- **[ADR 0010](../../../../docs/adr/0010-skills-pi-is-frozen-and-pi-only.md) — `skills-pi/` is frozen and
  pi-only.** Not in the task, found by the sweep. Footprint: a whole tree, one installer that links it and one
  that must not, and three skill names that resolve in one runtime only. Its rejected alternatives are sharp:
  putting the fallbacks in `skills/` would **shadow Claude Code's native review passes** with inferior
  markdown copies — on the pass whose job is finding defects; and having no fallbacks at all makes a review
  that silently did not run indistinguishable from one that found nothing.

**The two are coupled, and each names it:** 0010 is only expressible *because* 0009 links per folder rather
than per tree. That is the kind of dependency a record catches and a bullet does not.

**Sweep outcome stated either way (AC 5):** § Architecture makes four other claims — the three-tree split,
`skills/` as the only dual-linked tree, `docs/`+`tasks/` as this repo's own artifacts, and the skill-folder
shape. None is a trade-off with a rejected alternative; they are descriptions. **Two records owed, two
written, nothing further found.**

### AC 3 — recounted, and there is no triplication to fix

The cold read reported the squash-merge counter-example in **three** places. Measured today with
`grep -o` (occurrences, not lines): **two** — one in `AGENTS.md`'s derived-state bullet, one in ADR 0004.
Either an intervening edit consolidated the third or the original count double-counted a shared line.

**And two is correct, not a defect.** They do different jobs: the rule needs the counter-example inline to be
followable at all — which is the documented carve-out, *"a single **invariant** restated where it is
load-bearing is fine, since there is no list to fall out of sync"* — and ADR 0004 needs it to explain why
`integration:` is a declared field. Deduplicating would make one of them unreadable alone. **Recounted and
judged rather than mechanically deduped**, since the criterion said "fixed regardless" and the honest answer
is that there was nothing to fix.

### AC 1 + AC 2 — stated once, not twenty times

A scan found **eight** § Conventions bullets carrying a trade-off with no record and no clause. Writing the
same clause eight times **is a restated list** — the exact defect two of those very bullets exist to prevent,
and a sentence a reader meets eight times is a sentence they learn to skip.

So the clause is stated **once, at the head of § Conventions**: these are rulebook entries, a convention's
footprint is the prose it will shape, [[domain]]'s bar is scoped to project decisions, and a rulebook entry
keeping its trade-off inline is the intended shape rather than a defect. Where a bullet *does* have a record
it points at it; where one was plausibly expected and declined for a reason of its own, the bullet still says
so — the two written at TASK-069 stay.

**AC 2's two named bullets are covered by that statement**, and this is the substantive change from what the
task expected: it was filed believing the generated-file rule and the declare-versus-derive pair were
**owed records**. TASK-069's rescoping demoted both to rulebook entries, and the banner at the top of this
task's Context already recorded that inversion. So they are declared correctly absent — by the section
statement that covers every bullet of their kind, rather than by two bespoke clauses.

**AC 1 is met in substance and not literally**, and that is stated rather than glossed: no bullet gained an
individual clause, because one statement covering the class carries the same information with one copy. If a
future reader wants per-bullet marking, the argument against it is written down where they will meet it.

### Step 6

| Check | Result | Role |
|---|---|---|
| both new records exist and are reachable | `docs/adr/` holds 0009 and 0010; all four `AGENTS.md` → `docs/adr/` links resolve | **fix-dependent** |
| retired numbers not reused | `0006` and `0007` remain absent; the new records are `0009`/`0010` | **fix-dependent** — `domain` § Shape's never-reused rule |
| the squash-merge count | 2 occurrences, one per job, verified with `grep -o` rather than `grep -c` | fix-dependent — and the recount corrected the premise |
| lint | OK (18 skills) | contract pin |

### Step 7

No usable spec map (`areas: []`) — no regen. Stated, not skipped.

### Not done

**No cold read.** Whether one section-level statement actually reads as covering every bullet — rather than
as a preamble a reader skips on the way to the list — is a judgement about prose written here, and the
strongest test is a fresh reader asked *"does this rule have a record, and how do you know?"* about a bullet
picked at random. Recorded as unrun.

## Progress log

- step 2 — picked to close out STORY-003, whose remaining work blocks STORY-007 (the epic's Sequence table: *"names modules using glossary terms"*). Its sibling TASK-056 was deferred to a batch with TASK-064, since a scan showed both edit `CLAUDE.seed.md`. Key 6 (theme) n/a — this task is in EPIC-001, which carries no `kind: review-intake` stamp.
- step 3 — verified: **held, with two premises corrected.** The § Architecture sweep found **two** records owed rather than the one named; and the "triplication" is a duplication with two legitimate jobs.
- step 4 — layer: **local.**
- step 5 — `docs/adr/0009`, `docs/adr/0010`, the single decline statement at § Conventions' head, and two pointers in § Architecture.
- step 6 — records exist and resolve; retired numbers untouched; count corrected by `grep -o`; lint green.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: Out of scope bullets are boundaries (TASK-069 owns the bar; the seven surviving records are not re-litigated; no third sweep of § Conventions). Nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
