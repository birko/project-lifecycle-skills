---
id: TASK-014
parent: null
feature: null
status: todo
priority: P2
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The repo's own records don't reflect the day's shipped skills (architecture doc + changelog)

## Context

Grouped deliberately: two records, one cause — a batch of skill work landed on 2026-08-18 and the
records that describe it to a reader were written before it.

**`docs/architecture.md:44`** still marks the skill as unbuilt:

```
adopt-project ─reconciles──▶ the same layer, for a repo that already has code   [planned]
```

It shipped at 15:15 (`ef22e64`, `7375162`). `AGENTS.md` § Conventions requires a structural change
to update § Architecture *and* `docs/architecture.md` in the same change; the § Architecture half
was done, this half was not. The same doc names the layer-parity rule but never names `LAYER.md`,
the shared inventory file that now makes the rule real — and a file inside one skill consumed by
another via relative path is a new structural pattern worth a line in the skill-anatomy block.

**`CHANGELOG.md`** was backfilled at 13:54 (`1886df7`). Everything user-facing after that is
absent: `adopt-project` and its `INFER.md`, the LAYER.md refactor, the verify-conventions rulebook
ladder, and the `## Out of scope` sweep at `tasks close`. The changelog is the record for people
who *install* these skills, so a new front door missing from it is the omission that matters most.

Both are cheap and share a reader; splitting them buries the connection (`close` step 5d,
*group rather than fragment*).

## Acceptance criteria

- [ ] `docs/architecture.md` no longer marks `adopt-project` as `[planned]`, and its compose diagram shows the built relationship
- [ ] `LAYER.md` appears in that doc as the shared inventory both front doors consume, with the cross-skill relative-path reference noted in the skill-anatomy block
- [ ] `CHANGELOG.md` § Unreleased covers the 2026-08-18 skill work, written for someone installing these skills rather than as a commit list — produced by `/roll-changelog`, not hand-edited
- [ ] A skim of both files finds no other artifact from today still described as planned or absent

## Out of scope

- Cutting a release; there has been none, and `Unreleased` is the right home.
- Re-backfilling entries that predate `1886df7` — that backfill stands.

## Human test plan

- [ ] Read `docs/architecture.md` cold and confirm it describes the tree as it exists today
- [ ] Confirm `/roll-changelog` (not a hand edit) produced the changelog entries, per the generated-files-owned-by-their-verbs rule

## Implementation plan

_Populated by `/tasks plan TASK-014`._
