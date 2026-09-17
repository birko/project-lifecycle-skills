---
id: TASK-137
parent: STORY-017
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-131]
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-131-1, DRILL-131-2]
pr: null
github-issue: null
jira-key: null
---

# The `--from-field` door opens, but two of its edges are undefined — a cold runner reached both by inference

## Context

**From TASK-131's cold drill, 2026-09-17** — the drill that confirmed the door itself works. The runner
**passed every arm of the pass/fail bar**, so neither of these is a failure of that task; they are the two
places it had to reason past the text to get there, and it logged both as inferences rather than reads.
That is the shape this repo treats as a defect: *"a rule three readers must each reconstruct is a rule
that is not written down."*

### DRILL-131-1 — the mint rule has no empty case

`new.md`'s `--from-field` step says to grep every `findings:` list tree-wide for the current max
`FIELD-NNN`, increment, and zero-pad. **It never says what the first one is.** The runner's own words:

> *"The mint rule says 'take the max, increment' and never states the empty case. I took it from new.md
> step 6's parallel rule for task ids (`First of a type: EPIC-001 / STORY-001 / TASK-001`) plus the
> zero-pad-to-three instruction."*

It landed on `FIELD-001`, which is right. The defect is that it is right **by analogy to a different
rule about a different counter**, so a second runner is free to land on `FIELD-000`, `FIELD-1`, or to
stall. Every field report is a first one until it isn't.

### DRILL-131-2 — "joins the same way" names a route, not a scope

`fix-next` § Step 1: *"An already-filed task joins the same way — mint the id by that route and write it
in."* `new.md`'s `--from-field` block is written as steps inside a **create** flow, and its later steps
have no meaning for a task that already exists — step 11 regenerates the dashboard, step 12 auto-runs
`plan`. The runner:

> *"'The same way' names the route, not how much of it applies. I ran the mint and the write, and stopped."*

Stopping was the sensible reading, and nothing says it is the right one. A runner that instead ran step 11
would regenerate a dashboard; one that ran step 12 would draft an implementation plan onto someone else's
filed task. Three defensible readings, no rule.

## Acceptance criteria

- [ ] `new.md`'s `--from-field` mint states the first-id case explicitly, rather than leaving it to
      analogy with the task-id counter
- [ ] The already-filed path states **which** of `new`'s steps apply to it and which do not — by naming
      them, not by a general sentence a reader must scope themselves
- [ ] Both are stated where the runner actually reads them; a rule added only to `fix-next` does not
      reach someone who entered through `/tasks new`
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `--from-field` door itself, and the `FIELD-*` prefix — both work, [[TASK-131]] drilled them.
- The field-report `## Context` standard (*"repo, version or invocation"*) for an **already-filed**
  task. The runner raised it as a third undecided point and it is a weaker claim: the requirement is
  written for a task being created, and whether a pre-existing one must be backfilled to it is a
  question about filing standards, not about this door. File separately if it recurs.

## Human test plan

- [ ] Re-run TASK-131's drill recipe on a tree with **no** `FIELD-*` id anywhere and a hand-filed defect
      task, with a cold runner, and confirm the report cites a rule for the first id rather than deriving
      one. Then re-run it on a tree that already has `FIELD-001` and confirm the increment still holds.
