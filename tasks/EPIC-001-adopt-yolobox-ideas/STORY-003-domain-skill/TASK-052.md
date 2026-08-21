---
id: TASK-052
parent: STORY-003
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
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

- [ ] `skills/domain/` gains the ADR half: the file shape, the numbering (`NNNN-slug.md`), and the prose
      title convention
- [ ] The **three-part bar is stated as a conjunction**, with the consequence of loosening it named — a
      directory of records nobody reads is worse than no directory
- [ ] Lazy creation applies here too: no `docs/adr/` until there is a record to write
- [ ] The `§ Conventions` back-pointer rule is stated, including **which half carries what** — ADR: the
      trade-off and the rejected alternatives; convention: the enforceable one-liner
- [ ] The `docs/adr/` path choice is recorded with its reason (the `docs/features/*/decisions.md`
      collision, and external tooling), so a later reader does not "tidy" it to `docs/decisions/`
- [ ] The skill states the difference between an ADR and a feature decision, since the repo has both and
      the § *five records* table already draws that line — point at it rather than restating it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Writing any actual ADR** — TASK-054 backfills the ones already owed. This task ships the shape.
- **Seeding `docs/adr/` from either front door** — TASK-053.
- Changing `AGENTS.md`'s existing three-part bar, which is already correct; this task makes the skill
  agree with it, and if the two disagree the guide wins.

## Human test plan

- [ ] Offer an ADR for a decision that meets only two of the three tests and confirm the skill declines,
      naming which test failed — a bar that is stated but not applied is the failure mode here
- [ ] Write one record end to end and confirm a reader can reconstruct the rejected alternatives from it
      without the conversation that produced it
- [ ] Confirm no `docs/adr/` directory appears in a repo where nothing qualifies

## Implementation plan

_Populated by `/tasks plan TASK-052` — leave empty until then._
