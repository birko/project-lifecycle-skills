---
id: EPIC-001
# status: planned | in-progress | done | cancelled
status: in-progress
created: 2026-08-18
owner: František Bereň
affects: skills/, docs/, tasks/, .github/
---

# Adopt the yolobox skill ideas into the lifecycle set

## Area of concern

The in-house `yolobox` sandbox (`krivulcik/yolobox`, `home/yolo/.pi/agent/skills/`) carries a
16-skill set built on a different bet from ours: **decision-first and tracker-pluggable**, where
the durable artifacts are a domain glossary, ADRs, and issues on a configured tracker. Ours is
**artifact-first and file-based** — `docs/features/`, `tasks/`, `docs/specs/` — and survives
session resets by construction.

This epic adopts what that set does better, reimplemented against our artifact model, and closes
the two gaps it exposed:

1. **No vocabulary or rationale record.** We have four decision records and none of them answers
   *what does this word mean* or *why did we choose this*. `tdd/SKILL.md:79` already instructs
   agents to "use the project's domain glossary … and respect ADRs" — pointing at nothing.
2. **We persist answers and discard questions.** `decisions.md` is a durable, stateful ledger of
   resolved decisions; `idea.md`'s open questions are a prose bullet list. That asymmetry is why
   `/feature new` cannot span sessions — reopen it and the resolved half is on disk while the
   frontier is gone with the conversation.

**Out of scope at the epic level:** porting `to-spec`, `to-tickets` or `setup-skills` (covered by
existing verbs, or solved deliberately differently — we do not want a tracker-abstraction layer);
a standalone decision-map tree (rejected — the feature folder is the map); a multi-context
glossary (deferred until a monorepo consumer needs one).

**Provenance:** yolobox is an in-house repo with no LICENSE at time of writing. The ideas are
adopted; the prose is **reimplemented, not copied** — their files reference `CONTEXT.md`,
`.scratch/` and `docs/agents/issue-tracker.md`, an artifact model we do not share, so every ported
file would need a rewrite pass regardless. Credit belongs in `README.md`.

## Success criteria

- A project has one place for *what a word means* (`docs/glossary.md`) and one for *why we chose it* (`docs/adr/`), with a routing rule that keeps them distinct from the three records we already had.
- `/feature new` survives a session reset: unanswered questions persist with their blocking edges, and `/feature pick` resumes at the frontier.
- The merge gate answers three questions, not two — adherence (`verify-conventions`), correctness (`code-review`), and **fidelity** (`verify-intent`: what was asked for but missing, what is here that nobody asked for).
- An existing repo can be brought onto the current universal layer in one command (`adopt-project`), and that command stays current as the layer grows (the layer-parity rule).
- This repo uses its own skills — the layer exists here, and re-running `adopt-project` on it reports zero gaps.

## Requirement → feature matrix

_This epic owns the brief-level requirements. No status column — status is read live from `/roadmap`. There is no Feature column entry because this epic is deliberately **task-tree only**: no stakeholder reacts to a prototype and there is no sign-off gate, which is the router's own test for using `/tasks` directly._

| Req | Brief quote (abridged, from docs/BRIEF.md) | Feature | Story |
|-----|--------------------------------------------|---------|-------|
| R1 | _"look at these skills here what we have in our yolobox … lets discuss what would be good to implement in our life circle skills"_ | — (task-only) | STORY-003, 004, 005, 006, 007 |
| R2 | _"a new skill maybe or werb for projects taht already have the old sructure to rescan it and generate missing parts with user grilling"_ | — (task-only) | STORY-002 |
| R3 | _"for project that already have some code and dont use these skills if i wanna to init it"_ | — (task-only) | STORY-002 |

## Sequence

The STORY template carries no `blocked-by` field, so the dependency edges live here.

| Story | Blocked by | Why |
|---|---|---|
| STORY-001 bootstrap the universal layer | — | the tree must exist to hold this epic |
| STORY-002 `adopt-project` | 001 | build the upgrader before shipping upgrades, or every later story strands existing projects |
| STORY-003 `domain` | 001 | load-bearing: 004, 007 and `wait-what` all consume its vocabulary |
| STORY-004 durable question ledger | 003 | the grill's frontier is written in glossary terms |
| STORY-005 `verify-intent` + smell baseline | 001 | independent — pull forward for a short session |
| STORY-006 slicing doctrine + prototype branch | 001 | independent — pull forward for a short session |
| STORY-007 `improve-architecture` | 003 | names modules using glossary terms |
| STORY-008 `specs` regen across the skill set | 002–007 | regenerating before the set stabilises means regenerating twice |

## State as of 2026-08-19 — read before picking new work

**Verification debt is zero** — nothing at `review`, nothing in-progress. It stood at seven on
2026-08-18 and cleared over that day and the next. `/tasks pick` still will not mention debt when it
exists (TASK-010, open), so keep running bare `/tasks` first.

**The backlog has inverted.** 18 of 21 open tasks are unparented defect debt and every one is P2/P3;
**STORY-002 closed 2026-08-20** with all 15 tasks done, so no story has open tasks at all — every
remaining item is unparented defect debt, and STORY-003 to 009 have never been decomposed. Seven of the
loose tasks were filed on 2026-08-19 by two close
gates — the 5d out-of-scope sweep, `/verify-conventions` and `/code-review` each produced work. Closing
tasks currently *creates* more tracked work than it removes, which is the drills-find-more-than-building
judgement below, still holding a day later.

Three judgements that the task files alone will not convey:

1. **The drills found more than the building did.** Two review passes on `skills-lint.sh` produced
   16 defects; drilling seven real repos found that `verify-conventions` had been silently doing
   nothing on the two largest consumers. Prefer drilling what exists over starting STORY-003.
2. **`adopt-project`'s fill is now drilled, twice.** Superseding the 2026-08-18 note: TASK-020 drilled
   a throwaway `widget-store` fixture end to end — once unadopted (full fill, fix-now and declined
   defect paths) and once over a complete layer (the re-run path, where the run's only output was a
   filed task). What is still barely tested is the fill on a *large real* repo; Presenter remains the
   honest next target for that.
3. **The recurring defect class is "checking for the shape we would have made".** It produced the
   literal `## Conventions` match, the `tests/`-only probe, and the CI offer to a repo that cannot
   build in isolation. Expect it again wherever a skill inspects a repo it did not create.

## Notes

**Bootstrap exemption, recorded honestly.** STORY-001 was executed *before* its task file existed
— unavoidable, since the task tree is what STORY-001 creates. Per the task-first gate ("if you
catch edits already made without a task, backfill the task with honest status"), STORY-001 was
backfilled at `in-progress` with its acceptance criteria reconstructed from the scaffold spec, not
written after the fact and dropped into `done`. This is the *only* story permitted that exemption.
