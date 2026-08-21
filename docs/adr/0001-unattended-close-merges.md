# Decision record: an unattended close merges to the default branch

- **Date:** 2026-08-21
- **Decided by:** the maintainer, asked directly — this was not a judgement the implementer could take
- **Status:** accepted
- **Rule it produced:** none yet. The behaviour lives in `skills/tasks/verbs/close.md` step 5c; if it
  hardens into a standing rule, that rule gets a one-line § Conventions entry pointing here.

## Context

[[fix-next]] drains a defect backlog unattended and delegates the merge gate to
[`/tasks close`](../../skills/tasks/verbs/close.md), which is correct — `close` owns the gate and
re-implementing it would fork the rules. But `close` step 5c asks the user *"Merge `task/TASK-NNN` into
the default branch as part of this close?"*, and on a `pr-per-task` project — the documented default —
that question is reached on every run.

With nobody present, every reading of "unanswered" is bad. Blocking hangs the run. Skipping the merge
means `done` would claim a state the repo does not have, which the skill set explicitly forbids: `done`
means *merged*.

So a decision was needed before `--unattended` could be defined at all (TASK-050), and it is hard to
reverse in the way that matters — not because the code is hard to change, but because once an autonomous
loop has been merging to the default branch, the history it produced was produced under this policy.

## Decision

**An unattended close merges.** `close --unattended` resolves 5c as *yes* without asking, and says so in
the flag's own definition rather than leaving each caller to infer it.

The load-bearing part is *where* it is written: at the flag, not at the call site. `fix-next` reads the
table in `close` step 2; it does not carry its own copy of the answer.

## Rejected alternatives

**End at `blocked` instead.** The safer-looking option, and rejected because it makes the drain
pointless: every unattended run would leave a finished-but-unmerged task for a human to sweep, so the
loop would generate work rather than retire it. It also overloads `blocked`, which already means *waiting
on a dependency*, with a second meaning — *waiting on a human* — and a state that means two things is
the kind this vocabulary exists to avoid.

**Declare it per repo, e.g. `unattended-merge: true|false` in `tasks/.config.yml`.** Most in keeping with
the repo's *read the declaration, never infer it* convention, and rejected on cost: it needs a default,
the default would be `true`, and every consumer would then have to learn a knob that almost nobody would
turn. Worth revisiting if a consumer actually wants the other behaviour — at which point the field is a
small change and this record explains why it did not exist first.

## Consequences

**Easier.** An unattended drain completes without a human, which is the whole point of the loop. And
because the merge is no longer in question, `close`'s earlier gates carry the weight: standards, fidelity,
correctness, and the PR-diff pass all run *before* 5c, so the merge is the consequence of those passing
rather than a separate judgement.

**Harder.** An autonomous agent writes to the default branch. Anything that weakens the gates before 5c
now weakens the merge directly — which is why TASK-050's contract table treats an unenumerated ask as a
defect in the table, and why a repo wanting review-before-merge should keep a human on `close` rather
than relying on the flag to be cautious.

**Not affected.** Interactive closes are unchanged; 5c still asks. A `single-branch` project never
reaches 5c at all, which is exactly why this defect shipped unnoticed in a repo that declares
`integration: single-branch` — see the same day's TASK-050.
