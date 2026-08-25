---
id: TASK-051
parent: STORY-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-21
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `domain` — the skill and its glossary half

## Context

STORY-003's foundation, and the slice that unblocks everything else in it.

`domain` is a **discipline**, not an action — hence the bare noun, alongside [[tdd]]. It is applied
*during* a grill or a design, not run as a one-shot verb, and that shapes the whole file: its content is
four things to do while a conversation is happening, not a numbered procedure to execute.

**This slice ships the glossary only.** `docs/glossary.md` is useful on its own — it fixes the project's
vocabulary so an agent uses the team's words instead of inventing synonyms — and the ADR half (TASK-052)
is additive. Splitting them keeps each landable and each independently valuable.

**Two dangling references must land in this same change, and one of them is why.**
`skills/tdd/SKILL.md:79` already tells agents to *"use the project's domain glossary … and respect ADRs
in the area you're touching"* — pointing at artifacts no skill creates. And
`skills/adopt-project/INFER.md` names `domain` in **plain text** rather than as `[[domain]]`, because a
wikilink to an absent skill fails the lint. So the promotion cannot land before the skill folder exists,
and leaving it after means the repo keeps a deliberate lint-driven workaround for a skill that is now
present. Same change, both files.

## Acceptance criteria

- [x] `skills/domain/` exists, frontmatter `name: domain` matching the folder, `description` carrying the
      trigger phrases including the Slovak ones this team uses
- [x] The **four live behaviours** are the body of the skill, each with the signal that triggers it:
      challenge a term that conflicts with the glossary; sharpen a fuzzy or overloaded term into a
      canonical one; stress-test relationships with concrete edge-case scenarios; cross-reference against
      the code and surface contradictions
- [x] **Lazy creation** is stated: `docs/glossary.md` is written only when there is something to write.
      No empty scaffold — an empty glossary is worse than none, because it reads as "the vocabulary is
      settled and thin"
- [x] The glossary's boundaries are stated: **no implementation detail, no spec, no scratch pad**. A term
      and what it means; where a definition wants a file path or an interface, that belongs elsewhere
- [x] `skills/tdd/SKILL.md:79` becomes a proper `[[domain]]` link
- [x] `skills/adopt-project/INFER.md`'s plain-text `domain` becomes `[[domain]]`
- [x] `bash .github/workflows/skills-lint.sh` passes, and **both installers are re-run** — a new skill
      folder gets no junction until then, so neither runtime can resolve `[[domain]]` (the TASK-011
      defect, and check 4 now reports it)

## Out of scope

- **The ADR half** — TASK-052. This slice must be worth having without it, and the skill's own text
  should not promise ADR behaviour it does not yet carry.
- **Seeding from `new-project` / `adopt-project`** — TASK-053, which owns layer parity and `LAYER.md`.
- **Backfilling the ADRs already owed** — TASK-054.
- Teaching any other skill to *read* the glossary beyond the `tdd` reference that already exists.

## Human test plan

- [x] Run it during a real grill in this repo and confirm it challenges at least one term that is used
      loosely here — it fired behaviour 2 on **`review`**, the skill set's most-used word, which carries
      four distinct senses including two that mean opposite things (*in review* = unfinished, *passed
      review* = finished). Also on **`decision`**, two records under one word
- [x] Confirm the lazy rule behaves — and it was exercised in the **firing** direction, which is the
      more useful half: two genuinely overloaded terms existed, so `docs/glossary.md` was written. Five
      entries, all from the drill, none padded
- [x] Drill on a consumer repo with established vocabulary and confirm the cross-reference behaviour
      surfaces a real contradiction — **run on Symbio 2026-08-21, and it found one.** See the Outcome:
      `Machine` and `Device` are two vocabularies for what looks like one physical thing, meeting inside
      one event handler that carries both ids and dispatches on the device
- [x] After re-running the installers, confirm `[[domain]]` resolves from both roots — both junctions
      created; check 4 reported it unlinked the moment the folder appeared, then in sync

## Implementation plan

_Populated by `/tasks plan TASK-051` — leave empty until then._

## Progress log

- step 2 — picked interactively. **Not a `fix-next` run** — see the review note below; the
  `picked-by:` stamp I first wrote was wrong.
- step 3 — verified: held. `tdd/SKILL.md:79` and `adopt-project/INFER.md` both pointed at artifacts
  nothing created, and INFER's plain text was an explicit lint-driven workaround.
- step 5 — `skills/domain/SKILL.md`, both references promoted, both installers re-run.
- step 6 — **no guard to fail**; the lint reads frontmatter, wikilinks and file references, not a
  skill's behaviour. Evidence is the drill.
- step 7 — no usable spec map in this repo (`areas: []`). Nothing to respec.
- step 8 — `/code-review`: 9 findings, all confirmed, all addressed. See Outcome.

## Outcome

**What shipped.** `skills/domain/` — a discipline, not a verb: four behaviours keyed on signals that
occur mid-conversation, plus one narrow cold path. `docs/glossary.md` is written lazily, on the first
term worth recording, with three boundaries stated (no implementation detail, no spec, no scratch pad)
because each is a way the file rots.

**The drill found a real overload in this repo's own vocabulary.** `review` — the skill set's most-used
word — carries four senses, two of which mean opposite things: *"the task is in review"* (unfinished)
against *"the task passed review"* (finished). Both sentences are said here. `decision` is two records
under one word. So the glossary exists because there was something to record, which exercised the lazy
rule in the direction that matters.

**My own stamp was the highest-severity finding.** I wrote `picked-by: fix-next` out of habit on a task
that is not in `fix-next`'s pool — `findings: []`, and EPIC-001 carries no `kind: review-intake` — and
without the `## Progress log` that stamp is contractually paired with. Step 0 of the next drain would
have hit an `in-progress` task it could neither own nor safely leave. The stamp is the defect, not the
missing log: this was interactive story work. Removed.

**Two regressions I introduced while fixing a dangling reference.** Rewriting `INFER.md`'s glossary
handoff dropped both the *target* (which guide subsection the candidates land in) and the *retirement
path* ("retire this copy once `docs/glossary.md` exists") — turning a deliberately temporary duplicate
into a permanent second record of one vocabulary, which is precisely the rot § *The five records* exists
to prevent. And it made `adopt-project` branch on a file `LAYER.md` does not list, which is the layer
parity rule. Both restored; the branching is deferred to TASK-053, which owns the row.

**Judgement call: define the cold path rather than drop the trigger.** The description advertised
`/domain` while the body said "not a one-shot command" and defined nothing for it. Dropping the trigger
was simpler and wrong — people will type it. It now runs behaviour 4 over the existing glossary, and
says so.

**A ripple traced rather than left.** TASK-043 reasoned from `[[domain]]` as its *live* forward-reference
case; this change resolved it, so both its premises are now false. Its Context and one criterion are
updated: the constraint is still real and will recur, but the example is gone, so the mechanism must be
built against a fixture and the outcome must say no real instance existed.

**And I put a live count in a glossary** — "363 uses", unreproducible by any grep variant — the exact
defect I have flagged three times this session in other people's prose. Removed, along with two
enumerative lists that would go stale when a review pass or a gate is added.

**Left outstanding:** the consumer-repo drill (behaviour 4 against Symbio's Slovak prose definitions).
Not ticked, because a vocabulary defined in prose in another language is the case most likely to break
cross-referencing, and the this-repo drill is not evidence for it.

- 2026-08-21 — outstanding drill run. Symbio has **no** `docs/glossary.md`, so the cold path applied:
  cross-reference against the guide's prose definitions. Finding below. Behaviour 4 held in the hardest
  case — vocabulary defined in prose, in Slovak, with no glossary to compare against.

## Outcome — addendum: the Symbio cross-reference

**Machine vs Device, one concept under two names.** `Device*` types are IoT-shaped
(`IDeviceCollector`, `IDeviceAdapter`, `DeviceConfigBase`, `DeviceRef`) and live under
`Edge/Symbio.Edge.IoT` and `Sdk/Symbio.Sdk.IoT`. `Machine*` types are scheduling-shaped (`MachineJob`,
`MachineAssignment`, `MachineJobTelemetry`) and live under
`Modules/Business/Symbio.Module.Manufacturing`.

They meet in one event flow, and nothing names the relationship.
`Symbio.Module.IoT/EventHandlers/MachineJobCancelledHandler.cs:22` logs *"Machine job {MachineJobId}
cancelled for device {DeviceId}"* and then dispatches on the device — so the event holds both ids while
no type states whether a Machine *is* a Device with a schedule, or a Device hosts many Machines.

The sharpest evidence is `MachineJobTelemetry`: a Manufacturing entity carrying `Progress`,
`MetricsJson` and `Timestamp`, while telemetry is collected by `IDeviceCollector` on the Edge side. That
reads as one concept crossing a module boundary and changing its name as it crosses.

The guide does not settle it — 9 mentions of *device*, 1 of *machine*, no definition of either — and it
tilts the other way from the entities: `iot:device:create` is the permission format and "device IDs" are
what get validated, so `device` holds authority in the permission model while `Machine` owns the domain
entities.

**Why this is the right kind of finding.** Each module's vocabulary is internally consistent, which is
exactly why nobody inside the project would notice: you only see it by reading two modules against each
other. And per the skill's own rule it stays a **finding** — unifying the names would be a `/tasks spawn`
in Symbio, not something this drill does to someone else's repo.

Two further candidates left unresolved, since one question per drill is enough to prove the behaviour:
`User`(16 files) / `Account`(35), and `Customer`(31) / `Client`(2) — the second lopsided enough to look
like a leftover rather than a live concept.
