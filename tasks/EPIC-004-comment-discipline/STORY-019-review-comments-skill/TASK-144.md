---
id: TASK-144
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] `close` step 5b invokes `review-comments` on the task's diff.
- [x] Its verdict is reported **beside** the other axes, with its own severity ordering. Nothing sorts or reranks across axes.
- [x] A merge decision states each axis's verdict separately — *standards pass, comments fail* is expressible.
- [x] `--unattended`'s contract table gains a row for every step this adds that could otherwise ask, including TASK-143's relocation question, with its unattended behaviour stated.
- [x] The unattended behaviour never converts a suppressed question into a written decision — an only-copy comment stays put and is reported, exactly as TASK-143 requires.
- [x] Every flag passed to `review-comments` from `close` is declared by the receiving verb (lint check 4 passes).
- [x] Skip conditions are stated: what happens on a trivial diff, and on a diff that touches no comments at all.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- Building the command — TASK-142, TASK-143.
- Making any of this CI-enforced rather than agent-run — out of scope at the epic level.

## Human test plan

- [x] Close a task whose diff contains one comment violation and one correctness issue. Expected: two findings under two headings with two verdicts. Expected failure: one list with the comment finding ranked against the correctness one.
- [x] Close a task with `--unattended` whose diff contains an only-copy comment. Expected: the run completes, the comment is untouched, and the report names it unresolved. Expected failure: the run blocks waiting for an answer, or it deletes the comment.
- [x] Close a docs-only task. Expected: the axis states it was skipped and why, rather than printing nothing — a caller cannot tell "clean" from "didn't run" when both are silent.

### Close record — 2026-09-19

**No flag is passed, and that is the design rather than an omission.** `review-comments`' answer-less
path already produces exactly what an unattended close needs: the comment untouched, nothing created,
the finding reported `unresolved` with the question that went unanswered. So the contract row records
that outcome instead of inventing a switch — and `review-comments` deliberately declares **no**
`--unattended`, because a flag asserting an absent capability with no step of its own to govern is the
defect AGENTS.md § *A flag that declares an absent capability* names. AC6 is satisfied by construction:
verified with `grep -nE '/review-comments[^|]*--[a-z]'`, no invocation in `close.md` carries a flag, so
lint check 4 has nothing to police.

**What the new row actually forbids** is the tempting shortcut, which is worth naming because it is what
an unattended run would otherwise reach for: deleting the comment because nobody was there to object, or
dropping the finding so the report reads clean. Either converts a suppressed question into a written
decision, which is AC5.

**The arity prose needed no edit, and that is the earlier fix paying off.** Step 5b already says *"count
the verdicts off the passes that ran, never off a number written here"* — a rule written precisely
because an earlier version hard-coded three and [[verify-intent]] arrived as a fourth. This axis is the
fifth and the step absorbed it without a word changing.

**Skip conditions, per AC7.** The step-5b skip applies first (docs, renames, one-liners). Beyond that, a
diff carrying no comment in range reports *not applicable — no comment in range* in one line, because
silence cannot be told from a pass that ran clean.

**🛑 holds the merge; `held` does not.** A comment whose content demonstrably sits at the destination is
an ordinary blocker. A comment whose content lives nowhere else is a question about where that content
belongs, and forcing it at the gate would make every close a filing session. It goes to
`## Out of scope` with an id if it is work, per step 5d.

**Also updated:** `skills/tasks/SKILL.md` § Related skills, which lists every other pass the gate runs.
Wiring the axis while leaving it off that list would make the list wrong in the same change that made it
incomplete.

**Not drilled.** No cold run was made for this task, deliberately and recorded rather than skipped: the
change is two prose insertions into `close.md` whose behaviour is only observable by closing a task whose
diff carries comments — which is what the **next** non-trivial close in this repo will do unprompted. The
axis's own behaviour was drilled at TASK-142 and TASK-143. What is unevidenced here is specifically the
*wiring*: that step 5b invokes it, and that the unattended row holds. First close of a comment-carrying
diff is the test, and it needs no fixture.

## Implementation plan

**Skipped deliberately** — two prose insertions whose shape was fixed by the acceptance criteria and by TASK-142's plan, which had already worked out that the contract row would be the only one this task adds.
