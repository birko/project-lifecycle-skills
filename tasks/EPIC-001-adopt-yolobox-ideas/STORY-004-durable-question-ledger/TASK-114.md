---
id: TASK-114
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: agent
created: 2026-09-08
depends-on: []
blocks: [TASK-115, TASK-116, TASK-117, TASK-118, TASK-119]
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# The question table — the shape every other task in this story reads

## Context

STORY-004's gap is **an asymmetry, not a missing skill**: `decisions.md` is a durable, stateful ledger of
resolved decisions, while `skills/feature/templates/idea.md:21`'s `## Open questions distilled from the
grill` is a prose bullet list with no state, no edges and no claim. Reopen a feature tomorrow and the
answers are on disk while the frontier is gone with the conversation.

This task changes **one thing**: that bullet list becomes a table. Everything else in the story — `new`
writing the rest down, `pick` resuming, `grill-me`'s rounds, the `research` type, reconciling older files
— reads this shape, which is why they all depend on it and why it ships alone first.

### The columns, from the story

`id · question · type · blocked-by · state · claimed-by`

Each earns its place: `blocked-by` yields the edges, `state` + `blocked-by` together yield the **frontier
query** (*state open, and every blocker resolved*), and `claimed-by` stops two parallel sessions
answering the same question.

### The boundary this task must draw, because everything downstream inherits it

**A row is for a question you can *state* precisely — answerable or not. Fog stays prose.** Anything
vaguer stays in the section until it sharpens. And `## Out of scope (initial)` keeps its existing
meaning: **ruled-out scope never graduates into a question.** A table that swallows fog produces rows
nobody can act on; a table that refuses a precise-but-unanswered question loses exactly what the story
exists to keep.

### What this task must NOT do

Define the states as a copy anywhere but here. Four skills will read this vocabulary, and this repo's
own rule — *defer to a shared inventory, never restate its lists* — applies the moment the second reader
appears. The state list can grow; a copy goes silently wrong when it does.

## Acceptance criteria

- [ ] `skills/feature/templates/idea.md` carries the table with all six columns, replacing the prose
      bullet list, with a filled example row showing a blocked question
- [ ] The **state vocabulary** is defined once, in the file that owns it, and every state has a verb or a
      step that sets it — no state reachable only by hand-editing
- [ ] The **frontier query** is stated precisely enough that two readers compute the same set from the
      same table: *state open, and every id in `blocked-by` resolved*
- [ ] The **fog boundary** is written as a rule an agent can apply — what earns a row, what stays prose,
      and that `## Out of scope (initial)` is neither
- [ ] `claimed-by` states what claims it, when a claim is released, and what a reader does with a stale
      claim — a claim that cannot expire is a deadlock
- [ ] Nothing else in `skills/` restates the states or the query; the other five tasks point here
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **`/feature new` writing unreached questions down** — TASK-115.
- **`/feature pick` resuming at the frontier** — TASK-116.
- **`grill-me` frontier rounds** — TASK-117.
- **The `research` question type and sub-agent dispatch** — TASK-118.
- **Reconciling an `idea.md` written before this table existed** — TASK-119.
- Changing `decisions.md`. It already works; this story fixes the other half of the asymmetry.

## Human test plan

- [ ] Hand a cold runner — acquired per [[populate-tests]] § *Acquiring a cold runner* — the revised
      template plus a half-filled example, and ask it to name which questions it would work next and why.
      Expected: it computes the frontier from the table without being told the rule, and it does not
      place a vague worry in a row. Withhold both expectations from its brief.
