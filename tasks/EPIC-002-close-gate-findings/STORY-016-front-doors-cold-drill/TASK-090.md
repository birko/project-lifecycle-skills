---
id: TASK-090
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
findings: [DRILL-063-1]
pr: null
github-issue: null
jira-key: null
---

# The survey cannot say whether this is a first adoption or a re-run

## Context

**From the 2026-09-01 cold drill of `adopt-project`'s survey** (TASK-063's).

The skill has **two** advertised use cases, and its description gives them equal billing: bring a repo onto
the layer, and *"the UPGRADE path — re-run it whenever the universal layer grows, to reconcile a repo that
adopted an older version."* Which one a given run is doing changes what nearly every row means — `missing`
on a first adoption is expected, `missing` on a re-run means something regressed or the layer grew.

**The survey has nowhere to say which it is.** The drill surveyed two repos and found that **both** carried
`docs/BRIEF.md` whose `## Origin` reads *"Adopted 2026-08-18"* — so both runs were reconciliation passes,
not first adoptions. It surfaced that only because it happened to **open** the file rather than stat it,
and said so plainly: *"nothing in step 1 asks the survey to characterize whether this is a first adoption
or a re-run — I inferred it mattered because the skill's own framing depends on it."*

**Why this outranks its size.** The fact is free — it is one line in an artifact the survey already visits,
and the adopted-repo brief is *designed* to carry exactly this stamp. An agent that stats `docs/BRIEF.md`
for presence and moves on has the answer in its hand and discards it. And the consequence is not cosmetic:
a reader handed a table of `missing` rows reads a young repo being onboarded, when they may be looking at a
mature repo that has drifted or a layer that has grown three artifacts since.

**Related, not duplicate:** the states in § *Detect what the repo has* describe **one artifact each**. This
is a property of **the run**, so it is not a state and must not become one — the risk in fixing this is
inventing a nineteenth row for something that belongs in the report's header.

## Acceptance criteria

- [ ] The survey establishes whether the repo has been adopted before, from evidence it already collects — `docs/BRIEF.md`'s `## Origin` stamp is the obvious source, and the row already exists
- [ ] The answer appears where a reader sees it before the table, not as a row inside it
- [ ] A repo with no brief, or a brief with no origin stamp, yields an honest "cannot tell" rather than an assumption of first adoption
- [ ] The distinction changes something concrete in the report — at minimum, how a `missing` row is worded on a re-run versus a first pass — or the task records why it is presentation-only
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing what any row's state means. This is about the run, not the artifacts.
- `docs/BRIEF.md`'s own shape — [[new-project]] and `LAYER.md` § *The adopted-repo brief* own that, and the stamp this task reads already exists.

## Human test plan

- [ ] Run the survey against a repo whose brief carries an adoption stamp and one that has never been adopted, and confirm a reader can tell the two runs apart without opening any file themselves

## Implementation plan

_Populated by `/tasks plan TASK-090` — leave empty until then._
