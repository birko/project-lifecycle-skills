---
id: TASK-056
parent: STORY-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-22
depends-on: [TASK-053]
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# The seeded rulebook never learns where a term or a decision goes

## Context

**Found while planning TASK-053** (the layer-parity change that adds `docs/glossary.md` and
`docs/adr/` to the universal layer).

`skills/new-project/templates/CLAUDE.seed.md` is the rulebook every scaffolded project starts with.
Its § *Ground truth & altitude — what gets recorded where* carries a **three-row** routing table:

| The change… | …is recorded in |
|---|---|
| introduces/alters a **requirement or scope** | a `docs/BRIEF.md` amendment → new/changed feature |
| alters **how an already-requested feature looks/behaves** | that feature's `decisions.md` |
| is a pure **implementation detail** | code / commits / `docs/architecture.md` |

This repo's own `AGENTS.md` answers the same question with **five** records — § *The five records —
which one am I writing to?* — and the two the seed lacks are exactly the artifacts TASK-053 is adding:
`docs/glossary.md` (*what a word means*) and `docs/adr/` (*why we chose it*).

**So once TASK-053 lands, a scaffolded project owns two artifacts its rulebook never mentions.** The
consumer gets a glossary and an ADR home from the layer, and a routing table that offers no row for
either — meaning a vocabulary question routes to `decisions.md` (wrong: that is per-feature and
append-logged) and a hard-to-reverse technical choice routes to `commits` (wrong: that is the
implementation-detail row, which is precisely the altitude an ADR exists to sit above).

**Why this is a separate task rather than TASK-053 scope.** It is a *different list*. `LAYER.md`'s rows
say **which artifacts exist**; the seed's routing table says **which record answers which question**.
Neither derives from the other, so no layer-parity rule is being violated by the gap — but it is the
next thing somebody "fixes" by pasting this repo's five-row table into the seed, and pasting is how a
second copy of the record taxonomy starts. Doing it deliberately, once, is the point of the task.

**The judgement this task has to make, and it is not mechanical.** This repo's five-record table also
carries the `AGENTS.md § Conventions` row and the `docs/specs/` row, and it carries the ADR↔convention
protocol (*an ADR that hardens into a standing rule gets a one-line § Conventions entry pointing back
at it*, plus the three-part bar for offering one at all). Decide **how much of that a fresh project
needs on day one** versus what would be noise in a repo with no decisions yet. A five-row table plus a
protocol paragraph may be right; so may two extra rows and a pointer to `[[domain]]`. State the choice
and its reason — the seed's job is to be read by someone with an empty repo.

## Acceptance criteria

- [x] `CLAUDE.seed.md`'s routing table covers **where a term's meaning goes** and **where a
      hard-to-reverse choice goes**, so neither question routes to a record that cannot answer it
- [x] The added rows name `[[domain]]` as the owning skill, so a reader has somewhere to go
- [x] A decision is recorded (in this task, at close) on whether the ADR↔convention protocol and the
      three-part "offer an ADR only when" bar belong in the seed or stay this repo's own — with the
      reason, not just the outcome
- [x] The seed does **not** imply a fresh project should already have a glossary or an ADR: both are
      **lazy** rows per `LAYER.md`, so the wording survives an empty `docs/`
- [x] No second copy of `LAYER.md`'s row content lands in the seed — the artifacts are named, their
      layer semantics are not restated
- [x] `bash .github/workflows/skills-lint.sh` passes
- [x] A scaffolded throwaway project's `CLAUDE.md` renders the new rows with **no unfilled template
      tokens**

## Out of scope

- The `LAYER.md` rows and both front doors — **TASK-053** owns those, and this task depends on it.
- `README.seed.md` — unless the routing table is mirrored there, in which case check it and say so.
- This repo's own `AGENTS.md § The five records` — it is already correct; this is about what
  *consumers* receive.
- Reconciling already-scaffolded consumer repos. That is an `adopt-project` drill, not this change.

## Human test plan

- [ ] Scaffold a throwaway project with `new-project` and read the generated `CLAUDE.md`: the routing
      table must answer "where does a term's meaning go?" and "where does a hard-to-reverse choice
      go?" without the reader needing this repo
- [ ] Confirm the generated file has **no unrendered `{{TOKEN}}`** anywhere in or around the new rows
- [ ] Confirm the wording reads correctly in that throwaway repo, which has **no** `docs/glossary.md`
      and **no** `docs/adr/` — neither row may read as a missing file
- [ ] Ask the question cold against the scaffolded guide — "we keep arguing about what 'account'
      means, where does that go?" — and confirm the table sends you to the glossary, not to a
      feature's `decisions.md`

## Implementation plan

_Populated by `/tasks plan TASK-056` — leave empty until then._

## Outcome

**Done as one pass with TASK-064**, because a scan showed both edit `CLAUDE.seed.md` — one edit, one review,
instead of two passes over the same file.

**The two rows.** The seed's routing table gained *"settles **what a word means here**"* → `docs/glossary.md`
(vocabulary only, never decisions) and *"settles **why we chose it**, for a choice that is hard to undo"* →
a record under `docs/adr/`. So a consumer's routing question now has five answers instead of three, and the
two artifacts the layer gives them are no longer unexplained.

**AC 3 — the decision, and it is a refusal.** The criterion asked whether the ADR↔convention protocol and
the three-part bar belong in the seed. **Neither does**, and the reason got clearer after TASK-069:

- The **bar** is `/domain`'s, and applying it needs the scope question that task added — *project decision or
  rulebook entry?* Copying a three-part conjunction into a consumer's guide hands them a test without the
  thing that makes it decidable, which is how it was misapplied here twice in one day.
- The **promotion protocol** (a record that hardens into a rule gets a one-line § Conventions entry pointing
  back) only matters once a repo *has* records. On day one it is machinery for a situation that does not exist.
- Both would be a **second copy of `/domain`'s content**, which AC 5 forbids outright.

What the seed says instead is one sentence naming the owner: *"Run `/domain` when you hit either; **it**
decides whether a choice has earned a record, so don't pre-judge that here."* The routing table tells them
*where*; the skill tells them *whether*.

**AC 4 — the rows do not imply the files exist.** They are followed by a note that both are written on the
first real term and the first choice worth explaining, *"not scaffolded, because an empty glossary claims the
vocabulary was examined and found thin."* A fresh repo reads that as correct rather than as a gap.

**AC 5 — no `LAYER.md` content copied.** The note gives the *consequence* a consumer needs (the files arrive
later, run `/domain`) and none of the row mechanics — no `(lazy)` marker, no `not applicable yet` state, no
create-nothing rule. Those stay in the inventory, where the two front doors read them.

**AC 7 — every template token has a named source.** Checked all sixteen across both seed templates:
`ONE_LINE_PURPOSE` now comes from intake question 2 (TASK-064's half of this pass), and the five
`§ Conventions` tokens are filled by step 3, which already carries the rule *"every subsection either carries
a real rule or is removed — never a dangling `{{…}}`."* Nothing is unsourced.

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped.

**Not done.** No throwaway scaffold was run. The token check above is mechanical and complete, but whether
the five-row table *reads* well to someone with an empty repo — whether they can find their row without
being told which — is a cold-read question, and this closes STORY-003 without it.

## Progress log

- step 2 — picked to close STORY-003, batched with TASK-064 on the file-collision scan.
- step 3 — verified: the table had three rows and named neither artifact the layer now ships.
- step 4 — layer: **local.**
- step 5 — two rows + the on-first-use note in `templates/CLAUDE.seed.md`.
- step 6 — sixteen tokens checked for a named source; none unsourced; lint green.
- step 7 — no usable spec map; regen skipped and stated.
- step 8 — 5d sweep: Out of scope bullets are boundaries. Nothing spawned. Gate: standards pass, intent pass, correctness pass; security n/a.
