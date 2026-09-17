---
id: TASK-138
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-110]
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-110-1]
pr: null
github-issue: null
jira-key: null
---

# A conditional row says what settles **Yes** and never what settles **No** — and a wrong No is the one state nothing reports

## Context

**From TASK-110's cold drill, 2026-09-17** — the drill that confirmed the fix works. Both front doors
reached the same verdict on the same repo, so this is not a failure of that task; it is the one judgement
its runner could not point at a sentence for, and it named that plainly:

> *"This is the judgement I'm least able to point at a sentence for. `LAYER.md` says any component
> answering yes settles Yes, but doesn't state the symmetric rule for No. … The consequence of being
> wrong here is invisible, because `not applicable` earns no checklist line, so I'm naming it plainly."*

### The asymmetry

`LAYER.md` § *Conditional rows* is explicit in one direction — *"**any** component answering yes settles
it"* — which is the right rule for a compound repo: one service among four projects makes the answer Yes.
**It never states the No.** A reader must decide for themselves whether No requires *every* component to
answer no, and whether "no component answers yes" is the same thing as "every component answers no" when
some component could not be classified at all.

The runner supplied the missing rule correctly (all three components enumerated, each with its run mode
given explicitly, so the evidence **determines** rather than merely permits) and said it would have asked
had the brief been vaguer — *"Had the brief said only 'a note-taking app', I would have asked."* That is
the right instinct, arrived at without a rule, which is the defect: the next reader may not have it.

### Why it is P2 rather than a nicety — the error is silent by construction

A wrong **Yes** is visible: an artifact appears, or the survey reports `missing`, and somebody looks at it.
A wrong **No** produces `not applicable`, which by design **suppresses the fill, the offer, and any later
re-ask** — and, since TASK-110, earns no line in `new-project`'s step 6 closing checklist either, on the
reasoning that a settled No was decided and needs no report. That reasoning holds only while the No is
actually settled. The two rules compose into: *the one verdict a reader is least equipped to reach is also
the only one nothing will ever surface again.*

## Acceptance criteria

- [ ] `LAYER.md` § *Conditional rows* states what settles **No**, symmetrically with the existing
      *"any component answering yes settles it"*
- [ ] It says what to do when a component **cannot be classified** — specifically whether "no component
      answered yes" may be read as No, or whether an unclassifiable component forces `unknown`
- [ ] The rule distinguishes *evidence determines the answer* from *evidence is merely consistent with it*,
      matching the test the consuming guide's § *A derived state must never be cached as a decision* sets
- [ ] Re-examine whether a settled `not applicable` should stay silent in `new-project` step 6's checklist,
      **given that this task's whole argument is that a wrong No is unreportable** — either state why
      silence is still right, or give it a line
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The **Yes** rule, and the `requires`-vs-`reads` calibration — [[TASK-136]] owns the latter.
- Whether `not applicable` and `not applicable yet` stay distinct; that is settled and not in question.

## Human test plan

- [ ] Cold-drill the adopter against a **deliberately ambiguous** compound repo — one component clearly not
      a service, one whose run mode cannot be determined from the repo at all — and confirm the runner
      reaches `unknown` and asks, rather than reading "nothing answered yes" as a settled No. The brief must
      not say which component is the ambiguous one.
