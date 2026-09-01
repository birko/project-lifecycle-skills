---
id: TASK-097
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-096-1]
pr: null
github-issue: null
jira-key: null
---

# `unknown` is the only container for two different situations, and one of them is not ignorance

## Context

**From the 2026-09-01 cold drill of `adopt-project` on `WorkoutTracker`.** The runner reached a conditional
row it could not settle, chose `unknown`, and then said plainly that the state was the wrong shape for
what it had actually found:

> *"**But I reasoned past the text to do it:** `unknown` is defined as 'you could not determine it', and
> the row is told to name 'the fact that was missing' — **no fact is missing here.** I read every config
> source and every env read in the repo. **What is unsettled is the row's own boundary, not my
> knowledge**, and `unknown` is the wrong-shaped container for that. I used it because it is the only
> non-laundering option on offer."*

That is a distinction the state list does not carry. Two situations reach `unknown`:

| Situation | What it means | What resolves it |
|---|---|---|
| **Evidence ran out** | the survey could not find the fact — a kind nothing declares, a licence with no signal in any direction | asking the user, in step 2's round |
| **The rule ran out** | the survey found *every* relevant fact and the row still does not say which side they fall on | **amending the row** — no answer from the user can fix it |

Collapsing them costs exactly what the `not applicable` / `not applicable yet` split was introduced to
protect: whether anybody should look again, and *at what*. A user asked to resolve an `unknown` of the
second kind is being asked to adjudicate a defect in the inventory, and their answer will not be
reproducible on the next run — which is the non-reproducibility this repo removes everywhere else by
declaring a value rather than deriving it.

**The immediate instance was fixed, and that is why the shape matters.** TASK-096 amended the
`.env.example` row so the required-vs-optional boundary is now stated, so this particular repo would land
`not applicable` today. But the runner's `unknown` was **correct at the time** and carried no signal that a
rule needed amending rather than a user needing asking — so the finding would have reached step 2 as a
question, been answered, and left the row exactly as broken for the next repo.

### What makes this hard, and worth doing carefully

- **A third state is not obviously right.** The state list has grown twice and TASK-085 already reports it
  as having outgrown its shape; adding a fourth `unknown`-adjacent label may be the wrong move.
- **The two are not always cleanly separable in the moment.** A runner who has not read exhaustively cannot
  always tell "evidence ran out" from "I stopped looking", and the honest default in that case is the
  existing `unknown`.
- **The cheapest fix may be a reporting rule rather than a state** — an `unknown` that names *what is
  missing* is already required, so an `unknown` whose named-missing-thing is **the rule itself** could be
  routed differently by the report (to a finding against the layer) without a new label. That would keep
  the state list still and put the signal where step 3b already sends things.

## Acceptance criteria

- [ ] The two situations are distinguishable in what the survey reports, by whatever mechanism is chosen
- [ ] An `unknown` caused by the **rule** being unsettled produces a finding against the layer — not only a question in step 2's round, which cannot fix it
- [ ] An `unknown` caused by **evidence** still routes to step 2 exactly as it does now, with no extra ceremony
- [ ] The choice between a new state and a reporting rule is reasoned against TASK-085's finding that the state list has already outgrown its shape
- [ ] The undetermined-by-a-runner-who-stopped-looking case still lands in the existing `unknown`, so the distinction cannot be used to dress up an incomplete survey
- [ ] Layer parity: whatever lands is defined in `LAYER.md` and both front doors read it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `.env.example` boundary itself — **TASK-096** settled required-vs-optional and the build-time carve-out.
- Reshaping the survey-state list generally — **TASK-085**. This task may *conclude* that a new state is right, but the list's overall shape is that task's subject.
- `present, elsewhere` and the location states — **TASK-091**.

## Human test plan

- [ ] Cold-drill a repo against a row whose condition is deliberately left ambiguous, expected answers withheld, and confirm the runner's report distinguishes "I could not find out" from "the row does not say"
- [ ] Confirm a genuinely evidence-limited row (a licence with no posture signal) still reports the way it does today, with no added ceremony

## Implementation plan

_Populated by `/tasks plan TASK-097` — leave empty until then._
