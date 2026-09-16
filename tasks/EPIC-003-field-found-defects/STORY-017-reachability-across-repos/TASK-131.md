---
id: TASK-131
parent: STORY-017
feature: null
status: todo
priority: P2
assignee: unassigned
created: 2026-09-16
depends-on: []
blocks: []
related: [TASK-130]
findings: []
pr: null
github-issue: null
jira-key: null
---

# `fix-next` names an opt-in for hand-filed defects that has no key — a field-found bug cannot mint a finding id

## Context

Found 2026-09-16 alongside [[TASK-130]], while a hand-filed defect in the Birko family had to be picked
by naming it explicitly because nothing would rank it.

`fix-next` SKILL.md §&nbsp;Step 1 defines the pool:

> A `status: todo` TASK is in the pool when **either** holds:
> - its frontmatter carries a non-empty `findings:` list; **or**
> - it sits under an EPIC stamped `kind: review-intake`.
>
> … **the pool is explicit or it doesn't exist.** (A field-found bug filed by hand joins the pool the
> moment someone puts its finding id in `findings:`; that's the whole mechanism.)

**The gating itself is correct and should stay.** An explicit pool is the whole reason this skill can run
unattended, and widening it to "any task that looks like a bug" would be exactly the prose-sniffing the
same paragraph rules out.

## The actual defect is the escape hatch

That parenthesis names an opt-in — *"put its finding id in `findings:`"* — which **assumes the bug has a
finding id.** A defect found in the field has no harvest behind it: no sweep, no `SH-*` number, and
**nothing in any skill mints one**. Measured: no verb in `tasks/` or `fix-next/` issues a finding id, and
no documented scheme describes what a hand-filed one should look like.

So the door is named and no key is cut for the case the sentence is explicitly about.

This is the pattern the consuming project's own conventions record as
§&nbsp;SH-H037 — ***verify the escape hatch opens; a guard whose opt-out throws is a wall wearing a door's
label***. Here it does not throw, it simply cannot be satisfied, which is quieter.

### Observed cost

A genuine reproducibility defect (`Birko.Random`, seeded noise not stable across .NET versions) sat in
`_loose/` with `findings: []` and no `review-intake` parent. It was worked only because a human named it.
Had nobody done so it would have aged indefinitely while `fix-next --loop` reported the pool empty —
**and reported it empty truthfully**, which is what makes this hard to notice.

## Candidate fixes

1. **Mint ids.** `/tasks new` (or a `--defect` flag) issues a local finding id — e.g. `FIELD-001` — and
   writes it to `findings:`. Smallest change, keeps the pool explicit, makes the documented opt-in real.
2. **A `kind: defect` task stamp** that the pool also accepts, mirroring the existing `kind: review-intake`
   epic stamp one level down.
3. **Document that hand-filed defects are out of scope** and route them to `/tasks pick`. Honest, cheapest,
   and contradicts the skill's own parenthesis — so if this is the answer, **delete that sentence**.

Option 1 or 2. ⚠ Not 3 without editing the text that promises otherwise; a documented mechanism that does
not exist is worse than an absent one.

## Acceptance criteria

- [ ] 1. A defect found in the field can enter the pool **through a documented step**, without inventing
      an id by hand or borrowing an unrelated one.
- [ ] 2. The pool stays explicit. No inference from titles, prose, labels, or `priority:`. This must not
      become "rank anything that reads like a bug".
- [ ] 3. The opt-in is **exercised by a test** — a task filed through the documented path is picked by a
      subsequent `fix-next` run. Asserting the sentence exists is not asserting the door opens; that
      distinction is the whole of this task.
- [ ] 4. If option 3 is chosen instead, the parenthesis in §&nbsp;Step 1 is **deleted**, not left standing
      beside a contradicting rule.
- [ ] 5. ⚠ Minted ids must not collide with harvest ids (`SH-*`, `CR-*`) — a field id should be visibly a
      field id, so provenance stays readable at a glance.

## Out of scope

- The blast-radius ranking itself — it works, and is not in question.
- [[TASK-130]] — cross-repo collection is a different mechanism. Note they **compound**: a sub-repo task
  is invisible to collection *and*, if hand-filed, ineligible for the pool. Fixing either alone still
  leaves that task unreachable.
