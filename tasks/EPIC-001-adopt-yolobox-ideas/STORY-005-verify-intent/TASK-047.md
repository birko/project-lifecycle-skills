---
id: TASK-047
parent: STORY-005
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-20
depends-on: [TASK-046]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `verify-intent` reads the feature ledger and the specs, not just the task

## Context

TASK-046 ships the fidelity axis grounded in one source: the closing task's `## Acceptance criteria`.
That is the narrowest complete slice, and it is not the whole of "what was asked". Two more records in
this repo state intent, and the story names both:

- **The feature's approved decisions** (`docs/features/FEATURE-NNN/decisions.md`) — what was agreed,
  which a task's criteria may implement only partially or may have drifted from.
- **`docs/specs/` for the touched area** — what the code is supposed to do, harvested rather than
  hand-written. The story argues this beats a tracker lookup precisely because **it is in the repo**,
  so it cannot be stale relative to a ticket nobody updated.

The ordering matters and needs stating: these sources can **disagree**. A task criterion that
contradicts an approved decision is itself a finding, not a tiebreak to resolve silently — the
[[feature]] ledger is the record of what was agreed, so a diff matching the task but contradicting the
decision is exactly the "clean code implementing the wrong thing" this axis exists to catch.

**This repo cannot fully drill it yet.** `docs/features/` holds no features and `docs/specs/.map.yml`
is still `areas: []` (STORY-008). So the spec and decision paths need either a fixture or a consumer
repo to exercise — say which was used rather than marking the plan run on the task path alone.

## Acceptance criteria

- [x] Given a task carrying `feature: FEATURE-NNN`, the approved and `changed` decisions in that
      feature's ledger are read as intent alongside the task's criteria
- [x] Given a diff touching files a `docs/specs/` area covers, that area's spec is read as intent
- [x] The precedence between disagreeing sources is **stated**, and a contradiction between them is
      reported as its own finding rather than silently resolved
- [x] Absent sources degrade cleanly and **say so** — no features, no spec map, or a task with
      `feature: null` must report which sources it actually read, not fall silently back to one
- [x] Reuses [[roadmap]]'s collection pass and [[specs]]' area mapping rather than re-deriving either
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Generating or repairing specs — [[specs]] owns that; this only reads them.
- The empty spec map and empty feature tree in this repo — STORY-008 and a future feature own those.
  This task works against whatever exists and reports what it read.
- Changing the decision ledger's shape.

## Human test plan

- [x] On a repo or fixture with a real feature ledger — **Symbio** (93 features, 93 `decisions.md`,
      218 tasks carrying `feature:` links). Ledger shape confirmed against the real table: the `Decision`
      column is the statement, `→ Tasks` names the tasks meant to carry it, and a decision outranks a
      task criterion with any disagreement reported against the decision
- [x] Run against a diff touching a spec-covered area and confirm the spec is named among the sources
      read — and the drill **rescoped the design**: see the Outcome. The spec is named as a **baseline**,
      not as intent
- [x] Run in this repo — no features, empty spec map — and confirm it reports reading only the task's
      criteria, explicitly. Also drilled **Presenter** (42 mapped areas, **0** generated bodies, no
      features): the second degradation shape, where a spec layer is declared and empty
- [x] Record which repo or fixture was used — Symbio for the ledger, Presenter and this repo for the
      two degradation shapes, with Birko.Framework and WorkoutTracker available as independent
      confirmations. No fixture was needed; all four are real

## Implementation plan

_Populated by `/tasks plan TASK-047` — leave empty until then._

## Progress log

- step 2 — picked as STORY-005's last task. Drill targets supplied by the user: Symbio, Presenter,
  WorkoutTracker and `Birko.Framework` under `C:\Source\Birko`.
- step 3 — verified: held, and **rescoped**. See the Outcome: `docs/specs/` is not an intent source.
- step 4 — layer: local.
- step 5 — fix in `skills/verify-intent/SKILL.md`: § *What it reads* split into Intent / Baseline /
  absent-source reporting, plus the non-intent decision states.
- step 6 — **no guard to fail**; the lint does not read a skill's source resolution. Evidence is the
  drills against four real repos.
- step 7 — no usable spec map in *this* repo (`areas: []`). Nothing to respec here.

## Outcome

**The rescope is the substance.** The task, and STORY-005 before it, framed this as *three intent
sources*: the task's criteria, the feature's approved decisions, and `docs/specs/`. Reading a real
ledger and a real spec map showed the third is not intent at all. **Specs are harvested from the code**,
so a spec states what an area *currently promises* — using it as "what was asked" would have the skill
judging a diff against the very behaviour the diff is changing, and reporting every intended change as a
deviation.

It is still valuable, for a different question: a diff contradicting a spec requirement that **no
decision or criterion asked to change** is unasked-for behavioural change — scope creep at spec altitude,
which a per-file read cannot see. So the section is now Intent (criteria + decisions) versus Baseline
(specs), and the two are labelled separately in the report header.

**Precedence, stated.** A decision outranks a task criterion, because the ledger is what was agreed and
the criteria are one decomposition of it — which can drift. A diff satisfying its task while
contradicting an `approved` decision is exactly this axis's reason to exist.

**What real data added.** Symbio's ledgers carry 332 `approved`, 4 `changed`, **3 `removed`**, 1
`deferred` and 1 `proposed`. The non-intent states are not noise: a diff implementing a `removed` or
`deferred` row is scope creep of the worst kind — decided against, with the rationale in the same row to
quote back. A `proposed` row implemented in code is a decision taken by whoever wrote it.

**Absent sources are the normal case, not an edge.** Across the four repos, most mapped spec areas have
**no generated body** — 199 of 224 in `Birko.Framework`, 121 of 134 in WorkoutTracker, 92 of 124 in
Symbio, all 42 in Presenter. So "name the sources you read and the ones that were not there" is the
common path, and a header that silently implies three sources would mislead on nearly every run.

**A measurement error caught in passing:** counting areas with `grep -c '^\s*- '` also counts the
`ignore:` block and inflates every figure. Areas must be read from the `areas:` block alone. My first
survey reported Presenter as 60 areas; it is 42.
