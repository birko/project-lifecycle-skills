---
id: TASK-144
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-18
depends-on: [TASK-142]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Wire `review-comments` into `/tasks close` as its own reported axis

## Context

Implements FEATURE-002 **D8**. `close` step 5b already runs three passes that answer different
questions — standards ([[verify-conventions]]), fidelity ([[verify-intent]]) and correctness
([[code-review]]) — and this repo's rulebook requires each to keep its own verdict and its own
severity ordering, with nothing sorted across them. `review-comments` becomes a fourth such axis.

**Merging it into one ranked list is the thing to avoid, and it will be tempting** precisely
because a comment finding usually *is* less severe than a correctness bug. That ease is the harm:
one ranked list makes "blocker" from a comment lint read as the same quantity as "blocker" from a
correctness pass, and any fixed weighting that puts correctness first buries the case the axis
exists to catch.

Two contracts to satisfy while wiring it, both already enforced here. `close` takes
`--unattended`, meaning no user is present to answer — and that flag's definition **enumerates
every step that would otherwise depend on a user**, so adding a step that can ask means adding a
row to that table. TASK-143's relocation question is exactly such a step. A flag scoped to some
steps while another still asks is worse than no flag, because the caller reads the promise, not the
scope. Separately, the lint checks that every flag passed to a skill verb names a flag the
receiving verb declares.

This is the one task in the epic that can be done last and skipped without breaking the others —
hence P2. The command is useful standing alone; the wiring is what makes it automatic.

## Acceptance criteria

- [ ] `close` step 5b invokes `review-comments` on the task's diff.
- [ ] Its verdict is reported **beside** the other axes, with its own severity ordering. Nothing sorts or reranks across axes.
- [ ] A merge decision states each axis's verdict separately — *standards pass, comments fail* is expressible.
- [ ] `--unattended`'s contract table gains a row for every step this adds that could otherwise ask, including TASK-143's relocation question, with its unattended behaviour stated.
- [ ] The unattended behaviour never converts a suppressed question into a written decision — an only-copy comment stays put and is reported, exactly as TASK-143 requires.
- [ ] Every flag passed to `review-comments` from `close` is declared by the receiving verb (lint check 4 passes).
- [ ] Skip conditions are stated: what happens on a trivial diff, and on a diff that touches no comments at all.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- Building the command — TASK-142, TASK-143.
- Making any of this CI-enforced rather than agent-run — out of scope at the epic level.

## Human test plan

- [ ] Close a task whose diff contains one comment violation and one correctness issue. Expected: two findings under two headings with two verdicts. Expected failure: one list with the comment finding ranked against the correctness one.
- [ ] Close a task with `--unattended` whose diff contains an only-copy comment. Expected: the run completes, the comment is untouched, and the report names it unresolved. Expected failure: the run blocks waiting for an answer, or it deletes the comment.
- [ ] Close a docs-only task. Expected: the axis states it was skipped and why, rather than printing nothing — a caller cannot tell "clean" from "didn't run" when both are silent.

## Implementation plan

_Populated by `/tasks plan TASK-144` — leave empty until then._
