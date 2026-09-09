---
id: TASK-123
parent: STORY-006
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-09
depends-on: [TASK-122]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Wide refactors — the case no vertical slice can cover, sequenced expand → migrate → contract

## Context

TASK-122's doctrine has one explicit exception, and it is not a rare one: **a mechanical change whose
blast radius fans across the codebase** — rename a shared symbol, retype a column. It breaks thousands
of call sites at once, so **no vertical slice can land green**. A doctrine that does not say this sends
a slicer to produce slices that cannot exist.

### The sequence, from the story

| Phase | Shape | Task shape |
|---|---|---|
| **expand** | add the new form beside the old so nothing breaks | one task, blocks everything below |
| **migrate** | move call sites in batches **sized by blast radius** | one task per batch, each blocked by the expand; CI green batch to batch, because the old form still exists |
| **contract** | delete the old form last | one task, blocked by **every** batch |

**And the escape hatch, which is the part that is easy to drop:** when even the batches cannot stay
green alone, they share an integration branch and all block a final **integrate-and-verify** task —
green is promised only there, and the sequence says so rather than pretending each batch is safe.

### Why this is a task-shape rule, not just advice

Every phase above is expressed in `depends-on` / `blocks` edges. That makes it something `/tasks new`
and `/feature decompose` must be able to *emit*, not merely describe — and it collides with a known
limitation: **TASK-001**, *"STORY.md cannot express dependency edges"*. This task must state where the
edges live for a refactor sequence, given that constraint.

The integration-branch case also touches `.config.yml`'s `integration:` declaration — a repo on
`single-branch` has nowhere to put a shared integration branch. That interaction needs an answer, not
an assumption.

## Acceptance criteria

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

- **The general doctrine** — TASK-122.
- **Fixing STORY.md's inability to carry edges** — TASK-001 owns that; this task works within it.
- Automating the batch split. This is doctrine an agent applies, not a tool.

## Human test plan

- [ ] Take a real wide change — a shared rename in this repo's own skills would do — and sequence it by
      the rule without executing it. Expected: the emitted task set has an expand nothing depends on,
      batches that each depend only on the expand, and a contract depending on all of them.
