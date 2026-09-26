---
id: TASK-122
parent: STORY-006
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-09
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The slicing doctrine — what "atomic and independently completable" actually means

## Context

`decompose` and `plan` today say a task should be *"atomic and independently completable"* and stop
there. That is a property to check, not a method to follow, so the actual slicing is improvised every
time — and the failure it produces is specific: **tasks that cannot land green on their own.**

The doctrine, from the story:

- **Vertical, not horizontal.** Each slice cuts a narrow but complete path through every layer — not a
  slice of one layer across the whole feature.
- **Demoable or verifiable alone.** A completed slice can be shown or checked without its siblings.
- **Sized to one fresh context window.** Not "small"; a stated, checkable bound.
- **Prefactoring goes first** — make the change easy, then make the easy change.

### The design question this task must settle, not assume

**Where the doctrine lives.** Two verbs consume it — `/tasks plan` and `/feature decompose` — and this
repo's rule is that a vocabulary shared by several skills has **one owning file, and the owner is
wherever it already lives**. Nothing owns slicing today, so this task picks the owner and the others
point at it. Expanding an existing home beats minting a neutral one; a partial copy is worse than
either, because it diverges like a full copy while being silently narrower.

**"One fresh context window" needs an operational reading.** As written it is a metaphor. A slicer needs
to know what to actually check — files touched, layers crossed, whether the task's own Context can be
read without opening anything else. Left as prose it becomes taste, and taste is what the doctrine
exists to replace.

### Merged in 2026-09-26: TASK-123 — Wide refactors — the case no vertical slice can cover, sequenced expand → migrate → contract

_Merged because wide refactors are the doctrine's own named exception; the doctrine is incomplete without it. The original file stays, cancelled, at `tasks/EPIC-001-adopt-yolobox-ideas/STORY-006-slicing-doctrine/TASK-123.md`._

TASK-122's doctrine has one explicit exception, and it is not a rare one: **a mechanical change whose
blast radius fans across the codebase** — rename a shared symbol, retype a column. It breaks thousands
of call sites at once, so **no vertical slice can land green**. A doctrine that does not say this sends
a slicer to produce slices that cannot exist.

#### The sequence, from the story

| Phase | Shape | Task shape |
|---|---|---|
| **expand** | add the new form beside the old so nothing breaks | one task, blocks everything below |
| **migrate** | move call sites in batches **sized by blast radius** | one task per batch, each blocked by the expand; CI green batch to batch, because the old form still exists |
| **contract** | delete the old form last | one task, blocked by **every** batch |

**And the escape hatch, which is the part that is easy to drop:** when even the batches cannot stay
green alone, they share an integration branch and all block a final **integrate-and-verify** task —
green is promised only there, and the sequence says so rather than pretending each batch is safe.

#### Why this is a task-shape rule, not just advice

Every phase above is expressed in `depends-on` / `blocks` edges. That makes it something `/tasks new`
and `/feature decompose` must be able to *emit*, not merely describe — and it collides with a known
limitation: **TASK-001**, *"STORY.md cannot express dependency edges"*. This task must state where the
edges live for a refactor sequence, given that constraint.

The integration-branch case also touches `.config.yml`'s `integration:` declaration — a repo on
`single-branch` has nowhere to put a shared integration branch. That interaction needs an answer, not
an assumption.

## Acceptance criteria

- [ ] The four rules are written where a slicer will read them, in one owning file, with the owner chosen
      and the reason recorded
- [ ] `/tasks plan` and `/feature decompose` both reach the doctrine — by pointer, never by copy
- [ ] **Vertical vs horizontal** is illustrated with a worked pair on this repo's own material: one
      slice that lands green alone and one that cannot, so the distinction is demonstrated rather than
      asserted
- [ ] "Sized to one fresh context window" has an operational test a slicer can apply
- [ ] Prefactoring is stated as an ordering rule — the prefactor is its own slice, before the change it
      enables, not folded into it
- [ ] The doctrine says what to do when a change **cannot** be sliced vertically, and points at
      TASK-123 rather than leaving the case open
- [ ] `bash .github/workflows/skills-lint.sh` passes

*From TASK-123:*

- [ ] The three phases are written with their task-shape consequences — which task blocks which, and
      why CI stays green between batches
- [ ] **Batch sizing is defined by blast radius**, with a stated way to measure it, not by a count
      pulled from the air
- [ ] The integration-branch fallback is included, including that green is promised only at the final
      integrate-and-verify task
- [ ] The interaction with `integration: single-branch` is answered — what a repo with no branch-per-task
      does when the batches cannot stay green
- [ ] Where the edges are recorded is stated, given that `STORY.md` cannot carry them (TASK-001)
- [ ] The exception says how to recognise it **before** slicing, so a slicer does not discover it after
      producing slices that cannot land
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Wide refactors** — TASK-123, the explicit exception, which depends on this rule existing.
- **`/feature prototype`'s fourth form** — TASK-124, the story's other half.
- Changing what `plan` or `decompose` otherwise do.

*From TASK-123:*

- **The general doctrine** — TASK-122.
- **Fixing STORY.md's inability to carry edges** — TASK-001 owns that; this task works within it.
- Automating the batch split. This is doctrine an agent applies, not a tool.

## Human test plan

- [ ] Give a cold runner — per [[populate-tests]] § *Acquiring a cold runner* — a real undecomposed
      story from this repo and the doctrine, and have it slice. Expected: it produces vertical slices and
      says which rule rejected any slice it discarded. Withhold both from its brief.

*From TASK-123:*

- [ ] Take a real wide change — a shared rename in this repo's own skills would do — and sequence it by
      the rule without executing it. Expected: the emitted task set has an expand nothing depends on,
      batches that each depend only on the expand, and a contract depending on all of them.

