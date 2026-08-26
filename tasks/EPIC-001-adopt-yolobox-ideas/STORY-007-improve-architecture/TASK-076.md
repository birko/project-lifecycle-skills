---
id: TASK-076
parent: STORY-007
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-26
depends-on: [TASK-075]
blocks: [TASK-077]
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `improve-architecture` — the skill, its scoping pass, and the candidate filter

## Context

The core of STORY-007: **a pass whose subject is the shape of the code**, rather than a feature or a defect.
Every existing entry point is one or the other, so structural friction currently gets *noticed* and never
*addressed*.

Depends on **TASK-075**, which puts the four missing ideas into `tdd/`'s files first — this skill points at
them rather than carrying its own copies.

### What the skill has to get right

**Scope before you scan.** If the user named a direction, take it. Otherwise walk the commit history for hot
spots — the files and areas that keep coming up — and weight those first, because *deepening pays off only
where change is coming*. Scattered history with no hot spot is itself a result: widen the net rather than
picking arbitrarily.

**The finding classes** STORY-007 enumerates, each needing an observable signal rather than a definition:
understanding one concept requires bouncing between many small modules; an interface nearly as complex as
what it hides; pure functions extracted for testability while the real bugs live in *how they are called*;
tightly-coupled modules leaking across their seams; what is untestable through its current interface.

**The deletion test as the filter, not a step.** Every shallow-module candidate passes through it, and
*"merely moves it"* kills the candidate. Without that, the skill reports every small module and becomes noise
— which is the failure mode that makes an architecture review get ignored.

**Existing decision records are respected.** A candidate contradicting one is surfaced **only** when the
friction is real enough to warrant reopening it, and is **marked as such**. This matters more here than the
story's one line suggests: `docs/adr/` now holds ten records, and a refactor pass that silently proposes
undoing a recorded trade-off is how a settled decision gets re-litigated by accident.

**Naming:** `improve-architecture` is verb-noun, matching the action-skill convention.

## Acceptance criteria

- [ ] The skill exists at `skills/improve-architecture/SKILL.md` with mandatory frontmatter — `name` matching the folder, and a `description` carrying the trigger phrases users actually type, including the Slovak ones
- [ ] The scoping pass is **ordered**: user direction first, then commit-history hot spots, and *"scattered history, no hot spot"* is a stated outcome that widens the net rather than a dead end
- [ ] Each finding class carries an **observable signal** — what you look at to decide it applies — not just a name
- [ ] The deletion test gates every candidate, and *"merely moves it"* is recorded as a rejection with its reason, so the same candidate is not re-raised next run
- [ ] A candidate contradicting a `docs/adr/` record is surfaced only on real friction, **marked as contradicting**, and names the record — never silently proposed
- [ ] It points at `tdd/deep-modules.md` and `tdd/interface-design.md` via `[[tdd]]` rather than restating them
- [ ] `bash .github/workflows/skills-lint.sh` passes, and the skill's `[[links]]` resolve

## Out of scope

- **The report surface** — Artifact, fallback, per-candidate shape: **TASK-077**.
- **The `/tasks intake` handoff and installer registration** — **TASK-078**.
- The four backfilled ideas — **TASK-075**, which this depends on.
- Actually running the pass on this repo. That is TASK-078's drill, once findings have somewhere to go.

## Human test plan

- [ ] Run the scoping pass on this repo with **no** direction given, and confirm it either names hot spots from the commit history or says plainly that the history is scattered — not an arbitrary pick dressed as a finding
- [ ] Take one candidate it surfaces and check the deletion test was actually applied, with its answer stated
- [ ] Point it at an area covered by an existing ADR and confirm a contradicting candidate is marked and names the record

## Implementation plan

_Populated by `/tasks plan TASK-076` — leave empty until then._
