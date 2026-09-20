---
id: TASK-161
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [FIELD-003]
pr: null
github-issue: null
jira-key: null
---

# A human test plan that ran and failed cannot be told from one that never ran

## Context

Found by running `/feature review FEATURE-002` on 2026-09-20 — by using the skills, not by reviewing
them, which is this epic's remit. `feature: null` deliberately: the defect is in the **`tasks` and
`feature` skills**, not in the feature whose review exposed it.

**The state that has no representation.** TASK-141's `## Human test plan` has three steps. All three
were executed. Step 2 — *ask a cold runner to apply the rule to `skills-lint.sh` and report
violations* — **ran and failed**: its recorded expectation was *"Expected: none"* and two independent
readers found nine things between them. The findings were filed (TASK-157, TASK-158, TASK-160) and the
task correctly sits at `review`.

Both gates read that plan as a binary:

| Source | Says |
|---|---|
| [[feature]] `review` Gate B | *"Each plan must be either: all steps checked `[x]` (manually run), or explicitly `N/A — fully covered by automated tests`."* |
| [[tasks]] `close` step 5 | *"If it has real steps with unchecked `[ ]` boxes, **don't close to `done`**"* — and `review → done` only *"after the human step is checked off"* |

So there are two writable states and three real ones:

| Real state | Box | What a reader concludes |
|---|---|---|
| never run | `[ ]` | correct |
| ran, passed | `[x]` | correct |
| **ran, failed, findings filed** | `[ ]` or `[x]` | **both wrong** — untick says nobody tested it; tick says it passed |

**Ticking is the tempting reading and it is the worse one.** `close.md`'s gloss is *"(manually run)"*,
not *"(passed)"*, so the letter permits it. But `close`'s own rule then reads *"`review` → `done` only
after the human step is checked off"* — so a ticked box is the thing that lets a task close, and
ticking a failed step makes a failing test into a closure permit. TASK-141 would have closed today on
a test that found nine defects.

**Leaving it unticked is what this repo did, and it is also wrong.** `/feature review` Gate B just
reported TASK-141 as *"3 unrun steps"* alongside five tasks whose plans genuinely have never been run.
The one plan in the feature that **was** executed — at real cost, six cold runners across two rounds —
is indistinguishable in that report from five that were not.

**Why this is not cosmetic.** A failed test is the ordinary outcome of testing; it is the outcome that
produces work. A convention that can only record *pass* or *absent* pushes every failure into one of
two lies, and the lie is load-bearing in both directions — it gates closure on one side and it
misreports verification debt on the other.

## Acceptance criteria

- [ ] The plan format can express **ran and failed** distinctly from **never run** — a third marker, a required outcome line per step, or whatever shape survives the drill below. One shape, stated once, in whichever file owns it.
- [ ] `close` cannot flip `review → done` on a step recorded as run-and-failed. The current rule keys on the box; whatever replaces it must key on the outcome.
- [ ] `/feature review` Gate B reports the three states separately. *"3 unrun steps"* for a plan that was run is the report this task exists to stop.
- [ ] Both files agree — [[tasks]] `close` step 5 and [[feature]] `review` Gate B state the same rule today and must still state the same rule afterwards, or a task and its feature will disagree about whether it can close.
- [ ] The change is **recorded in `AGENTS.md` § Conventions** if it establishes a new cross-cutting pattern — register-on-introduce applies to a convention about how every consumer records verification.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- TASK-141's own status — it stays at `review` until the file it was meant to exonerate is clean; that is correct under either convention.
- The findings that run produced — TASK-157 (done), TASK-158, TASK-160.
- Whether an automated check should replace the manual step — `close` step 5 already owns *automate before you accept a manual step*, and this one cannot be automated: it needs a reader who does not already know the answer.

## Human test plan

- [ ] Write a task whose plan has one step, mark it run-and-failed in the new shape, and run `/tasks close` on it. Expected: it refuses `done` and says why, naming the failed step.
- [ ] Run `/feature review` over a feature holding one never-run plan, one passed plan and one run-and-failed plan. Expected: three distinct lines. Today two of the three collapse.
- [ ] Expected failure to watch for: the new marker is added to the format and neither gate reads it, so the state is now writable and still unenforced — which is worse than the binary, because it reads as handled.

## Implementation plan

_Populated by `/tasks plan TASK-161` — leave empty until then._
