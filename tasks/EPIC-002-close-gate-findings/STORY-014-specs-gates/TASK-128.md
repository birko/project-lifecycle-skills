---
id: TASK-128
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-16
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-109-3, DRILL-033-2, DRILL-109-4]
pr: null
github-issue: null
jira-key: null
---

# Step 4 offers two exits for an unmapped file and the paragraph below it defines a third

## Context

**From the cold drill run for TASK-109 on 2026-09-16** (B2 — `/specs init` against a three-file Python
fixture, runner confirmed cold). The runner hit a direct contradiction inside one step and reported which
way it went:

> *"Step 4's two remedies for an unmapped file omit the one I used. **'any source file matching neither an
> area nor `ignore` → list as unmapped and either extend an area or add one.'** Neither branch is 'add an
> `ignore` entry' — yet the classification paragraph four lines later defines exactly that exit (**'Into
> `ignore` — it was never project source'**), and step 6 expects **'any `ignore:` entries step 4's
> reconciliation added'**. The sentence and the paragraphs around it disagree; I followed the paragraphs."*

So one step states a two-way choice, the prose immediately below states a three-way one, and a *later* step
depends on the third way having been available. The runner resolved it correctly — but by choosing which of
two contradictory instructions to obey, which is not a thing a reader should have to do.

### Why this matters more than a wording slip

The third exit is the one that carries a **judgement**. `coverage-drift` is defined as the paths that were
real source all along, as opposed to housekeeping sent to `ignore` — so the `ignore` exit is precisely where
a file is classified as *not behaviour*. A reader who obeys the two-way sentence literally has nowhere to put
a non-source file except into an area, which would fold prose and build furniture into the behavioural map
and inflate every later `coverage-drift` reading.

In this drill the file in question was `README.md`, and the runner sent it to `ignore` with a recorded
reason — the right answer, reached against the instruction rather than because of it.

**Adjacent, same step, do not lose it:** the runner also flagged that step 4 asks it to state a close
classification call, and did so. That part worked and is evidence the surrounding design is sound; it is the
enumeration of exits that is wrong.

### Merged in 2026-09-26: TASK-088 — Nothing says whether one source file may belong to two capability areas

_Merged because all three are /specs init step 4 remedies and area-granularity rules for unmapped or oddly-sized sources. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-088.md`._

**Raised by both 2026-09-01 cold drills of `/specs init`**, independently.

Step 4's remedy for an unmapped file is *"extend an area or add one"* — singular, and the template's
examples never test the case. But the situation is real and already shipped in two consumer maps:

- **WorkoutTracker** does it deliberately and says so: `ProgressEndpoints.cs` appears under both
  `exercise-progress` and `training-activity`, with a comment explaining that one file hosts two read
  models. The same map now also shares `plans-segments.ts` between `plan-hierarchy` and
  `exercise-library` — one segment bar rendered by two surfaces.
- **Presenter**'s drill put `appsettings.json` in **three** areas, because its `Fetch.*`, `Session.*` and
  `Database.*` sections are consumed by three different capabilities.

Both drills flagged the same gap: the practice exists, it looks correct, and no rule sanctions it.

**What has to be decided, and it is not obvious.** Sharing is right when one file genuinely hosts several
capabilities, and wrong when it means the areas are drawn around files instead of behaviour. Consequences
travel downstream: `/specs regen` harvests each area from its `sources:`, so a shared file is read once
per area and can produce two specs asserting overlapping things; `verify`'s staleness check will mark
**every** sharing area stale on one edit; and `coverage-drift`'s list may name a path already present
elsewhere.

### Merged in 2026-09-26: TASK-129 — A project with fewer capabilities than the floor has no stated answer, so the guidance invites padding

_Merged because all three are /specs init step 4 remedies and area-granularity rules for unmapped or oddly-sized sources. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-129.md`._

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

#### Why the pull is toward the wrong answer

Splitting to hit a number is the easy move and it is invisible afterwards: five areas over two capabilities
reads as a well-decomposed map, not as padding, and every later consumer inherits the inflated shape.
`/specs regen` then generates five spec bodies where two belong, `/roadmap`'s DV7 reports staleness five
times for one behavioural change, and `shaped-by` provenance is spread across areas that were never real.
The failure is silent in the direction the range was meant to prevent — the whole point of *"capability, not
class"* is to stop exactly this, and the number sitting beside it undercuts it.

**The same sentence is fine at the top of the range**, which is why this is a one-sided fix: a project with
thirty capabilities genuinely should reconsider its granularity, and nothing here changes that.

## Acceptance criteria

- [ ] Step 4's unmapped-file sentence enumerates **every** exit the step's own prose defines, including
      `ignore`, so no reader has to pick between two contradictory instructions
- [ ] The fix names which side was wrong — the sentence or the paragraphs — rather than quietly editing both
      to meet in the middle
- [ ] Step 6's expectation of *"any `ignore:` entries step 4's reconciliation added"* is reachable by
      following step 4 literally
- [ ] The `coverage-drift` / `ignore` distinction stays exactly as documented — this task fixes which exits
      are listed, not what they mean
- [ ] `bash .github/workflows/skills-lint.sh` passes

*From TASK-088:*

- [ ] Whether a file may appear in more than one area's `sources:` is stated, with the test for when it should
- [ ] The consequence for `regen` (one file harvested into several specs) is named, not left to be discovered
- [ ] The consequence for `verify` (one edit marks several areas stale) is named
- [ ] The existing deliberate instances are consistent with whatever is decided, or are called out as needing change — `ProgressEndpoints.cs`, `plans-segments.ts`, and Presenter's `appsettings.json` if that map is ever written
- [ ] `bash .github/workflows/skills-lint.sh` passes

*From TASK-129:*

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

- **Redefining `coverage`, `coverage-drift` or `tracked-files-at-scan`** — TASK-033 and TASK-079 own the
  contract; this is about one enumeration being incomplete.
- The area-granularity floor — **TASK-129**, same drill, same step, different defect.
- The ask/blessing gaps — **TASK-127**.

*From TASK-088:*

- Re-drawing any consumer repo's areas. This decides the rule; applying it is that repo's own work.
- Whether config files count as behavioural source — that judgement is [[specs]]' `coverage-drift` classification, and TASK-033 settled that it is a judgement recorded as paths.

*From TASK-129:*

- **Changing what an "area" is.** Capability-not-class is the settled rule this task protects, not one it
  reopens.
- The unmapped-file exit contradiction — **TASK-128**, same drill, same step.
- The ask/blessing gaps — **TASK-127**.
- Whether `/specs init` should refuse to run below some floor. It should not, and nothing here proposes it;
  if that turns out to be arguable it is a decision, not a wording fix.

## Human test plan

- [ ] Cold-drill `/specs init` on a fixture containing at least one clearly non-source tracked file, and
      confirm the run reaches `ignore` by following step 4 rather than against it
- [ ] Confirm the run's reported `coverage-drift` still distinguishes housekeeping from real source

*From TASK-088:*

N/A — the deliverable is a stated rule plus two named consequences, checkable by reading it against the
three existing instances. No run exercises "is this rule wise"; the next re-discovery of WorkoutTracker's
map is where it gets used in anger.

*From TASK-129:*

- [ ] Cold-drill `/specs init` on a fixture with two clear capabilities and confirm the run writes two
      areas and says why that is correct, rather than padding or apologising for the count
- [ ] Confirm a fixture with no behavioural code still reaches the existing `not-applicable` verdict
      unchanged

## Implementation plan

_Populated by `/tasks plan TASK-128` — leave empty until then._
