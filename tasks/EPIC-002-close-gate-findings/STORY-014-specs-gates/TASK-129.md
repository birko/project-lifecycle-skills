---
id: TASK-129
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-16
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-109-4]
pr: null
github-issue: null
jira-key: null
---

# A project with fewer capabilities than the floor has no stated answer, so the guidance invites padding

## Context

**From the cold drill run for TASK-109 on 2026-09-16** (B2 — `/specs init` against a three-file Python
fixture with two genuine capabilities, runner confirmed cold):

> *"**Area count for a codebase too small to support the target.** 'Target granularity: **capability, not
> class** — ~5–20 areas.' This repo has two capabilities in two files. I wrote two and did not pad to five.
> The instructions never say what a project below the floor should do; the nearest counterweight is the edge
> case 'don't invent areas for a project with no observable behavior', which is about a different
> situation."*

The runner did the right thing. Nothing in the skill told it to, and the one nearby rule covers the
**zero**-capability case, not the *below-the-floor* case — so a reader who takes "~5-20" as a target rather
than a typical range has explicit permission to split by class until the count looks right.

### Why the pull is toward the wrong answer

Splitting to hit a number is the easy move and it is invisible afterwards: five areas over two capabilities
reads as a well-decomposed map, not as padding, and every later consumer inherits the inflated shape.
`/specs regen` then generates five spec bodies where two belong, `/roadmap`'s DV7 reports staleness five
times for one behavioural change, and `shaped-by` provenance is spread across areas that were never real.
The failure is silent in the direction the range was meant to prevent — the whole point of *"capability, not
class"* is to stop exactly this, and the number sitting beside it undercuts it.

**The same sentence is fine at the top of the range**, which is why this is a one-sided fix: a project with
thirty capabilities genuinely should reconsider its granularity, and nothing here changes that.

## Acceptance criteria

- [ ] The granularity guidance states what a project **below** the range does, and says plainly that the
      range is descriptive of typical projects rather than a target to reach
- [ ] A two-capability project is a legitimate, recorded outcome — not an edge case handled by silence, and
      not conflated with the existing zero-behaviour edge case, which stays as it is
- [ ] The wording cannot be read as licence to split by class to reach a count; the *"capability, not
      class"* rule stays the stronger of the two statements
- [ ] Wherever the range is restated across the skill, it is reconciled — the fix does not leave one copy
      saying "target" and another saying "typical"
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Changing what an "area" is.** Capability-not-class is the settled rule this task protects, not one it
  reopens.
- The unmapped-file exit contradiction — **TASK-128**, same drill, same step.
- The ask/blessing gaps — **TASK-127**.
- Whether `/specs init` should refuse to run below some floor. It should not, and nothing here proposes it;
  if that turns out to be arguable it is a decision, not a wording fix.

## Human test plan

- [ ] Cold-drill `/specs init` on a fixture with two clear capabilities and confirm the run writes two
      areas and says why that is correct, rather than padding or apologising for the count
- [ ] Confirm a fixture with no behavioural code still reaches the existing `not-applicable` verdict
      unchanged

## Implementation plan

_Populated by `/tasks plan TASK-129` — leave empty until then._
