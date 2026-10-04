---
id: TASK-115
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: agent
created: 2026-09-08
depends-on: [TASK-195]
blocks: [TASK-114, TASK-117, TASK-257]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Open questions survive a session reset — the question table, written by `/feature new`, resumed by `/feature pick`

## Context

**Re-cut 2026-10-04 by TASK-195** under `skills/tasks/slicing.md`. This is now the story's first vertical
slice: the shape, its writer and its reader land together. TASK-114 used to ship the table alone, which
fails H3 because it leaves a shape no verb writes or reads. Its shape criteria moved here; its reconcile
half stays on TASK-114. `claimed-by` moved to TASK-257. **The size signal trips** (≥6 criteria), and this
stays one task because splitting writer from reader fails H3 in either direction. It is one owner
(`skills/feature/`: the `idea.md` template, `verbs/new.md`, `verbs/pick.md`).

**Edges:** TASK-114 (reconcile older files), TASK-257 (`claimed-by`) and TASK-117 (`grill-me` rounds) all
read or extend the shape defined here, so this task `blocks` each of them.

### The gap

STORY-004's gap is **an asymmetry, not a missing skill**: `decisions.md` is a durable, stateful ledger of
resolved decisions, while `skills/feature/templates/idea.md`'s `## Open questions distilled from the grill`
is a prose bullet list with no state, no edges and no claim. Reopen a feature tomorrow and the answers are
on disk while the frontier is gone with the conversation.

### The table

`id · question · type · blocked-by · state`. The story's sixth column, `claimed-by`, is TASK-257's.
`blocked-by` yields the edges, and `state` + `blocked-by` together yield the **frontier query** (*state
open, and every blocker resolved*).

**The boundary, which everything downstream inherits:** a row is for a question you can *state*
precisely, answerable or not. Fog stays prose. Anything vaguer stays in the section until it sharpens. And
`## Out of scope (initial)` keeps its existing meaning: **ruled-out scope never graduates into a
question.** A table that swallows fog produces rows nobody can act on; a table that refuses a
precise-but-unanswered question loses exactly what the story exists to keep.

**Define the states nowhere but here.** Four skills will read this vocabulary, and this repo's own rule,
*defer to a shared inventory, never restate its lists*, applies the moment the second reader appears.

### Writing it: `/feature new`

Today `/feature new` grills until the session ends, and whatever was not reached goes with the
conversation. The story's fix: **grill the frontier it can reach, then write the rest down as open
questions with edges.** `/tasks spawn` is the named precedent: work discovered mid-flight becomes a
durable record, not an intention. This is the same move, applied to questions.

### Reading it: `/feature pick`

The story is emphatic: **"No new verb, no new skill, no new tree."** `/feature pick` is already the front
door to an existing feature and already routes on state, so it gains **one** branch: open questions
outstanding, resolve the next frontier one. The temptation is a `/feature resume`, and the story rejects it,
because a second front door is how two doors drift apart.

**`pick` must also not misread an older file.** Every `idea.md` already on disk predates this table (one
consumer repo has 94 features). If a prose list reads as an empty frontier, `pick` reports "no open
questions" on every one of them. So this slice tells the two apart. Reconciling them is TASK-114.

## Acceptance criteria

*From TASK-114 (the shape):*

- [ ] `skills/feature/templates/idea.md` carries the table with five columns, `id · question · type · blocked-by · state`,
      replacing the prose bullet list, with a filled example row showing a blocked question. (TASK-114's original
      six-column criterion was split at the re-cut; the sixth column, `claimed-by`, is TASK-257's.)
- [ ] The **state vocabulary** is defined once, in the file that owns it, and every state has a verb or a
      step that sets it — no state reachable only by hand-editing
- [ ] The **frontier query** is stated precisely enough that two readers compute the same set from the
      same table: *state open, and every id in `blocked-by` resolved*
- [ ] The **fog boundary** is written as a rule an agent can apply — what earns a row, what stays prose,
      and that `## Out of scope (initial)` is neither
- [ ] Nothing else in `skills/` restates the states or the query; the other tasks point here

*From TASK-119 (via TASK-114):*

- [ ] `feature` can tell a pre-table `idea.md` from a current one, and says which — never treating the
      absence of a table as an empty frontier

*From TASK-115 (`new`):*

- [ ] `/feature new` ends by writing every unreached question as a row, with its `blocked-by` edges — not
      a flat list of leftovers
- [ ] Edges are recorded when the question is *raised*, not reconstructed at the end from memory
- [ ] A run that reached everything says so explicitly rather than writing an empty table — silence
      cannot be told from "the grill never got there"
- [ ] The verb states what it wrote, in its closing output, so a user can see the frontier they are
      leaving behind

*From TASK-116 (`pick`):*

- [ ] `/feature pick` detects outstanding open questions and offers to resume at the frontier, as one
      branch among its existing routing — no new verb, no new file
- [ ] The branch's position in the routing is stated: what it outranks and what outranks it, so two
      readers resolve the same feature to the same offer
- [ ] A feature with a table but an empty frontier — every open question blocked — reports **that**,
      distinctly from having no open questions at all
- [ ] Nothing restates the frontier query

- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **`claimed-by`** — TASK-257.
- **Reconciling an `idea.md` written before this table existed** — TASK-114. This task only *recognises* one.
- **`grill-me` frontier rounds and the `research` question type** — TASK-117.
- Changing `decisions.md`. It already works; this story fixes the other half of the asymmetry.
- Any change to `/feature pick`'s existing decompose-offer branch.

## Human test plan

*From TASK-114:*

- [ ] Hand a cold runner — acquired per [[populate-tests]] § *Acquiring a cold runner* — the revised
      template plus a half-filled example, and ask it to name which questions it would work next and why.
      Expected: it computes the frontier from the table without being told the rule, and it does not
      place a vague worry in a row. Withhold both expectations from its brief.

*From TASK-115:*

- [ ] Run `/feature new` on a real idea and stop it deliberately part-way. Reopen the folder and read
      only `idea.md`. Expected: a reader who was not present can tell what remains open and what each
      remaining question waits on.

*From TASK-116:*

- [ ] Take that part-way feature, in a fresh session with no memory of it, and run `/feature pick`.
      Expected: it resumes at a question you did not have to find yourself.

## Implementation plan

_Populated by `/tasks plan TASK-115` — leave empty until then._
