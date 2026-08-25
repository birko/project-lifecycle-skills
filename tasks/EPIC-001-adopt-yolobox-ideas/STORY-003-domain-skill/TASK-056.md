---
id: TASK-056
parent: STORY-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
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

- [ ] `CLAUDE.seed.md`'s routing table covers **where a term's meaning goes** and **where a
      hard-to-reverse choice goes**, so neither question routes to a record that cannot answer it
- [ ] The added rows name `[[domain]]` as the owning skill, so a reader has somewhere to go
- [ ] A decision is recorded (in this task, at close) on whether the ADR↔convention protocol and the
      three-part "offer an ADR only when" bar belong in the seed or stay this repo's own — with the
      reason, not just the outcome
- [ ] The seed does **not** imply a fresh project should already have a glossary or an ADR: both are
      **lazy** rows per `LAYER.md`, so the wording survives an empty `docs/`
- [ ] No second copy of `LAYER.md`'s row content lands in the seed — the artifacts are named, their
      layer semantics are not restated
- [ ] `bash .github/workflows/skills-lint.sh` passes
- [ ] A scaffolded throwaway project's `CLAUDE.md` renders the new rows with **no unfilled template
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
