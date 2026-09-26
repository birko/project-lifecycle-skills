---
id: TASK-133
parent: STORY-017
feature: null
status: todo
priority: P2
assignee: unassigned
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-131]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-131-1, DRILL-131-1, DRILL-131-2]
pr: null
github-issue: null
jira-key: null
---

# `spawn`'s pool rescue fires only for a review finding, so a field-shaped discovery still lands loose

## Context

Spawned by the `/code-review` pass at [[TASK-131]]'s close gate, 2026-09-17. `CR-131-1`.

`skills/tasks/verbs/spawn.md` step 4 tells the caller, when the parent fallback bottoms out at `_loose`:

> **If you reach `_loose` and the discovery is a review finding, stop and place it in a pool instead** —
> `_loose` with no `findings:` id and no `kind: review-intake` ancestor is outside [[fix-next]]'s pool
> entirely, so the task is filed and unranked.

That rescue is **conditioned on the discovery being a review finding**, and when it was written that
condition was doing no harm: a discovery with no pass behind it had no id it could have been given, so
naming it would have pointed at nothing. TASK-131 removed that constraint — `/tasks new task --from-field`
now mints a `FIELD-NNN` for exactly the pass-less case — and the condition became a live gap instead of a
tautology.

### The mechanism

A `/fix-next` run is the common origin. Its step 5 discovers something adjacent that is a genuine defect
but was **not** raised by any review pass — nobody code-reviewed it, it came out of doing the work. Spawn
parents it to the origin's STORY, else EPIC, else `_loose`. If the origin is itself loose, the discovery
lands loose, the rescue does not fire because the discovery is not a *review* finding, and the task is
filed with `findings: []` under no `review-intake` ancestor — outside the pool, ranked by `priority:`
alone. This is the identical end state TASK-131 fixed at the front door, reached through a side one.

**Why it is small but not nil:** the rescue's own precondition (a loose origin) is uncommon, and this
repo's `_loose/` holds one task. But the rule exists precisely for the case nobody chooses — the
SKILL.md text says so: *"a finding spawned from a task that is itself loose lands loose by inheritance,
with nobody choosing that."*

### Merged in 2026-09-26: TASK-137 — The `--from-field` door opens, but two of its edges are undefined — a cold runner reached both by inference

_Merged because both are --from-field follow-ups from TASK-131. The original file stays, cancelled, at `tasks/EPIC-003-field-found-defects/STORY-017-reachability-across-repos/TASK-137.md`._

**From TASK-131's cold drill, 2026-09-17** — the drill that confirmed the door itself works. The runner
**passed every arm of the pass/fail bar**, so neither of these is a failure of that task; they are the two
places it had to reason past the text to get there, and it logged both as inferences rather than reads.
That is the shape this repo treats as a defect: *"a rule three readers must each reconstruct is a rule
that is not written down."*

#### DRILL-131-1 — the mint rule has no empty case

`new.md`'s `--from-field` step says to grep every `findings:` list tree-wide for the current max
`FIELD-NNN`, increment, and zero-pad. **It never says what the first one is.** The runner's own words:

> *"The mint rule says 'take the max, increment' and never states the empty case. I took it from new.md
> step 6's parallel rule for task ids (`First of a type: EPIC-001 / STORY-001 / TASK-001`) plus the
> zero-pad-to-three instruction."*

It landed on `FIELD-001`, which is right. The defect is that it is right **by analogy to a different
rule about a different counter**, so a second runner is free to land on `FIELD-000`, `FIELD-1`, or to
stall. Every field report is a first one until it isn't.

#### DRILL-131-2 — "joins the same way" names a route, not a scope

`fix-next` § Step 1: *"An already-filed task joins the same way — mint the id by that route and write it
in."* `new.md`'s `--from-field` block is written as steps inside a **create** flow, and its later steps
have no meaning for a task that already exists — step 11 regenerates the dashboard, step 12 auto-runs
`plan`. The runner:

> *"'The same way' names the route, not how much of it applies. I ran the mint and the write, and stopped."*

Stopping was the sensible reading, and nothing says it is the right one. A runner that instead ran step 11
would regenerate a dashboard; one that ran step 12 would draft an implementation plan onto someone else's
filed task. Three defensible readings, no rule.

## Acceptance criteria

- [ ] 1. `spawn.md`'s `_loose` rescue covers a discovery with **no pass behind it**, not only a review
      finding, and names `--from-field` as the route that gives it an id.
- [ ] 2. The rescue does **not** widen into "anything spawned into `_loose` joins the pool". Tree hygiene
      and meta-work about the tree legitimately stay loose and unranked — [[tasks]] SKILL.md § *A task
      outside a pool* calls that arm explicitly not a loophole, and this must not quietly overturn it.
      Whatever wording lands has to keep the two distinguishable.
- [ ] 3. Whatever `spawn.md` ends up asserting about `--from-field` is pinned by `skills-lint.sh`
      check 4 — i.e. if it names the flag in an invocation, the receiving verb must still declare it.

*From TASK-137:*

- [ ] `new.md`'s `--from-field` mint states the first-id case explicitly, rather than leaving it to
      analogy with the task-id counter
- [ ] The already-filed path states **which** of `new`'s steps apply to it and which do not — by naming
      them, not by a general sentence a reader must scope themselves
- [ ] Both are stated where the runner actually reads them; a rule added only to `fix-next` does not
      reach someone who entered through `/tasks new`
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `--from-field` mechanism itself — built and closed under [[TASK-131]]; this task only routes to it.
- [[TASK-130]] — cross-repo collection, a separate mechanism, and still undecided.

*From TASK-137:*

- The `--from-field` door itself, and the `FIELD-*` prefix — both work, [[TASK-131]] drilled them.
- The field-report `## Context` standard (*"repo, version or invocation"*) for an **already-filed**
  task. The runner raised it as a third undecided point and it is a weaker claim: the requirement is
  written for a task being created, and whether a pre-existing one must be backfilled to it is a
  question about filing standards, not about this door. File separately if it recurs.

## Human test plan

N/A — fully covered by the lint. AC1 and AC2 are prose judgements a reader checks at review, and AC3 is
`skills-lint.sh` check 4, which already fails on an undeclared flag (proven by TASK-131 step 6). A cold
drill would add nothing here: this task changes the *condition* on a rescue whose behaviour TASK-131's
own drill already exercises, so a second runner would be re-reading the same paragraph.

*From TASK-137:*

- [ ] Re-run TASK-131's drill recipe on a tree with **no** `FIELD-*` id anywhere and a hand-filed defect
      task, with a cold runner, and confirm the report cites a rule for the first id rather than deriving
      one. Then re-run it on a tree that already has `FIELD-001` and confirm the increment still holds.

## Implementation plan

_Populated by `/tasks plan TASK-133` — leave empty until then._
