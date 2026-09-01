---
id: TASK-102
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
findings: [DRILL-098-2, DRILL-098-3]
pr: null
github-issue: null
jira-key: null
---

# Nothing says whether a step-3 fill offer joins step 2's round or comes after it

## Context

**From the 2026-09-01 cold drill of `adopt-project` on `Latent`.** Two instances, one question, so they are
filed together.

Step 2 closes with a hard rule:

> *"Put the inferences and the choices in **one frontier round** ([[grill-me]]'s shape), not a queue of
> single questions. A 15-rule proposal asked one at a time becomes an interrogation."*

Step 3 then makes **offers** — land this, append that, add these lines — and nothing says whether they
belong in that round or come afterwards. The runner hit it twice and folded both into the round, reasoning
from the interrogation clause rather than from anything that addresses the case:

> *"What is unsettled: whether the offer is a round item or a separate ask. … **I put it in the round**
> rather than deferring it to the report: it is a yes/no about writing to a file, the user is being asked
> three other questions in the same breath, and a fourth queued separately is the interrogation the
> one-round rule exists to prevent."*

> *"What is unsettled: which step the landing offer belongs to. It is described in step 3, but making it
> there would open a question after the round closed. **I folded it into the round.**"*

Its answer is almost certainly right, and it produced a genuinely good round — four items, itemised,
answerable as a subset. But it is a judgement the text does not make, and the other reading is available:
step 3's offers are *described in step 3*, so a reader who follows the steps in order asks them there, one
at a time, which is the interrogation the rule forbids.

### Why this is not just tidiness

**The one-round rule has a stated failure mode and this reintroduces it by the back door.** Step 2 is
protected; step 3 is where the actual writes are, and it currently makes at least four separate offers —
land the unlanded paths, append the `## Amendments` heading, add the `.gitignore` lines, create each missing
artifact. Asked serially those are exactly the queue the rule was written against, and the user's attention
is worst at the end.

**It also interacts with a rule installed the same day.** TASK-035 made step 2 pass declarations to their
owning verbs *"from here, so the question stays in this round instead of surfacing inside step 3's
delegation, which is the one-round rule below breaking by another route."* That sentence establishes the
principle for *declarations*. Fill offers are the same shape and were not covered — so the fix is likely to
be one sentence generalising what TASK-035 already argued, rather than a new mechanism.

**What must not happen is a second round.** Two rounds is the interrogation split in half. If offers cannot
all be known before step 3 begins — and some cannot, since what needs creating depends on what the round
answered — then the rule has to say which offers are foreseeable at step 2 and what happens to the rest.
That is the interesting part and it should not be waved through.

## Acceptance criteria

- [ ] Where a step-3 fill offer is asked is stated — in step 2's round, or at the fill, or a stated split — and the reason is given
- [ ] The answer covers offers that **cannot** be known until the round has been answered, rather than assuming all are foreseeable
- [ ] No second round is introduced, and the one-round rule's failure mode is not reachable by asking step 3's offers serially
- [ ] Consistent with TASK-035's rule that a declaration is passed from step 2 rather than surfacing inside step 3's delegation
- [ ] The measured instances both resolve without a runner having to reason it out: the `## Amendments` offer and the `present, uncommitted` landing offer
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The *shape* of the landing offer — **TASK-086** settled that (one itemised offer, subset acceptable, members listed).
- Whether `## Amendments` is owed — **TASK-098** settled that it is.
- The content of step 2's inference round. This is about where fill offers go, not about what the round proposes.

## Human test plan

- [ ] Cold-drill a repo with at least two step-3 offers available, expected answers withheld, and confirm the runner does not list offer placement among the things it had to decide
- [ ] Confirm the run still produces one round, not two

## Implementation plan

_Populated by `/tasks plan TASK-102` — leave empty until then._
