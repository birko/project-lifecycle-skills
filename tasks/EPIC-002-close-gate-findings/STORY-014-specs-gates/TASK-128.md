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
findings: [DRILL-109-3]
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

## Out of scope

- **Redefining `coverage`, `coverage-drift` or `tracked-files-at-scan`** — TASK-033 and TASK-079 own the
  contract; this is about one enumeration being incomplete.
- The area-granularity floor — **TASK-129**, same drill, same step, different defect.
- The ask/blessing gaps — **TASK-127**.

## Human test plan

- [ ] Cold-drill `/specs init` on a fixture containing at least one clearly non-source tracked file, and
      confirm the run reaches `ignore` by following step 4 rather than against it
- [ ] Confirm the run's reported `coverage-drift` still distinguishes housekeeping from real source

## Implementation plan

_Populated by `/tasks plan TASK-128` — leave empty until then._
