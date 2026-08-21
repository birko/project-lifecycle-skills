---
id: TASK-052
parent: STORY-003
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-21
depends-on: [TASK-051]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `domain`'s decision-record half — the three-part bar and where records live

## Context

The second artifact `domain` owns: `docs/adr/NNNN-slug.md`, a record of **why** a choice was made, so
nobody re-litigates a settled trade-off.

**The path is `docs/adr/`, and that is a decision rather than a default.** `docs/decisions/` would read
better in isolation and is wrong here: it collides with `docs/features/*/decisions.md`, which means
something different — a per-feature ledger of what stakeholders agreed, not a repo-wide technical record.
External ADR tooling also expects `docs/adr/`. Records are *titled* "Decision record: …" in prose, so the
human-facing wording stays plain while the path stays conventional.

**The three-part bar is the whole point, and it is an AND.** Offer an ADR only when the decision is
**hard to reverse**, **surprising without context**, *and* **the result of a real trade-off**. Miss any
one and skip it — otherwise every skill starts minting ADRs and the directory becomes a diary nobody
reads. This bar is already recorded in `AGENTS.md`; the skill must state it rather than restating a
softer version of it.

**An ADR that hardens into a standing rule gets a one-line `§ Conventions` entry pointing back at it.**
The division is load-bearing: the ADR carries the trade-off and the alternatives, the convention carries
the enforceable one-liner. This repo currently has the inverse problem — § Conventions entries carrying
their trade-offs inline because there was nowhere to put them — which TASK-054 pays down.

## Acceptance criteria

- [x] `skills/domain/` gains the ADR half: the file shape, the numbering (`NNNN-slug.md`), and the prose
      title convention
- [x] The **three-part bar is stated as a conjunction**, with the consequence of loosening it named — a
      directory of records nobody reads is worse than no directory
- [x] Lazy creation applies here too: no `docs/adr/` until there is a record to write
- [x] The `§ Conventions` back-pointer rule is stated, including **which half carries what** — ADR: the
      trade-off and the rejected alternatives; convention: the enforceable one-liner
- [x] The `docs/adr/` path choice is recorded with its reason (the `docs/features/*/decisions.md`
      collision, and external tooling), so a later reader does not "tidy" it to `docs/decisions/`
- [x] The skill states the difference between an ADR and a feature decision, since the repo has both and
      the § *five records* table already draws that line — point at it rather than restating it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Writing any actual ADR** — TASK-054 backfills the ones already owed. This task ships the shape.
- **Seeding `docs/adr/` from either front door** — TASK-053.
- Changing `AGENTS.md`'s existing three-part bar, which is already correct; this task makes the skill
  agree with it, and if the two disagree the guide wins.

## Human test plan

- [x] Offer an ADR for a decision that meets only two of the three tests and confirm the skill declines,
      naming which test failed — two real candidates declined: **`domain` is a bare noun** fails *real
      trade-off* (§ Naming already mandates it, so there was no rejected alternative), and **the tick
      never selects a finding's class** fails *hard to reverse* (a prose rule in one file, changeable in
      a line). Both genuinely met the other two tests, which is what makes them the right examples
- [x] Write one record end to end and confirm a reader can reconstruct the rejected alternatives from it
      without the conversation — `docs/adr/0001-unattended-close-merges.md`. Both rejections are
      recoverable from the record alone: `blocked` would come to mean two things, and a per-repo field
      needs a default which would be this
- [x] Confirm no `docs/adr/` directory appears in a repo where nothing qualifies — the `smellA` fixture
      (a rate tool with two code smells and no architectural choices) produces neither a record nor the
      directory. Lazy creation holds on both artifacts

## Implementation plan

_Populated by `/tasks plan TASK-052` — leave empty until then._

## Progress log

- step 2 — picked; unblocked by TASK-051 and the dependency TASK-054 waits on.
- step 3 — verified: held. The skill shipped glossary-only by design; `AGENTS.md` already carried the
  three-part bar and the § five records line, so the work was making the skill agree with them.
- step 5 — `skills/domain/SKILL.md` gains the decision-record half; frontmatter description widened.
- step 6 — **no guard to fail**; the lint does not read a skill's reasoning. Evidence is three drills.
- step 7 — no usable spec map (`areas: []`). Nothing to respec.

## Outcome

**What shipped.** `domain` now owns both artifacts. The decision-record half states the shape (four
parts, and *rejected alternatives* is the one people drop — without it a record cannot stop the
re-litigation it exists to prevent), the `docs/adr/` path with its reason, lazy creation, and the
back-pointer split.

**The bar is written as a conjunction with a failure table**, because "all three" is easy to agree with
and hard to apply. And declining is now **out loud, naming the failed test** — a skipped record and an
unnoticed one are indistinguishable afterwards, and the second is how a bar stops applying without
anyone deciding to drop it.

**Judgement call: point at § The five records, don't restate it.** The ADR-versus-feature-decision
distinction is exactly the kind of list that grows, and the guide already draws the line. The skill
carries a two-clause summary and a pointer.

**The drill found TASK-054's list short by one.** The `close --unattended` merge decision was not among
its eight, and it is the strongest candidate of the set — a real decider, an explicit question, two
recorded rejections. Written as `0001`, which makes it the only **contemporaneous** record in the group
and therefore the shape the eight retroactive ones should aim at. TASK-054 updated: eight remaining,
numbering from `0002`.

**What the inverse problem looks like, stated in the skill.** A § Conventions line carrying its own
trade-off inline is what happens when there is nowhere to put the reasoning — the rule list becomes an
essay collection and `/verify-conventions` ends up linting prose. This repo has four such lines, which is
TASK-054's actual job.
