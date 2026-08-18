---
id: TASK-013
parent: null
feature: null
status: todo
priority: P2
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# verify-conventions must say which sections it read — the output format has no slot for it

## Context

TASK-006's fix (`8762f74`) gave the skill a ladder for finding a rulebook under any heading, and
added the rule that makes the ladder auditable:

> **Say which sections you read** at the top of the report. The user needs to see what you treated
> as the rulebook, both to trust the findings and to catch you reading the wrong thing.

But § *Output format* — the section an agent actually follows when writing the report — was not
touched. It specifies severity groups and a sample, with no line for what was read, and its clean
branch is a bare one-liner:

```
✅ Change follows the project's documented conventions.
```

So on a clean run the instruction is not merely unimplemented, it is contradicted: the output
states a verdict and hides which rulebook produced it. A clean pass from a skill that read the
wrong section — or found little and linted against almost nothing — is indistinguishable from a
real one. That is the same invisible-gate defect the same batch fixed properly in
`skills/tasks/verbs/close.md` step 12, where the sweep's outcome is printed even when it passes.

The ladder's value is precisely that it may pick an unexpected section; unreported, the user
cannot correct a wrong pick.

## Acceptance criteria

- [ ] § Output format opens with the sections that were treated as the rulebook — file + heading names, in the guide's own language
- [ ] The **clean** branch carries it too, not just the findings branch
- [ ] Which rung of the ladder matched is visible (seed `## Conventions`, a named-rules heading, normative content, whole-guide), so an unexpected pick is legible as one
- [ ] The rule appears once, in § Output format, with § *Finding the rulebook* pointing at it rather than restating it

## Out of scope

- The ladder itself → TASK-006 (in `review`).
- Generated/vendored file exclusion → TASK-009.

## Human test plan

- [ ] Run `/verify-conventions` on a clean diff in Symbio (Slovak headings) and confirm the pass line names the sections read
- [ ] Run it on this repo and confirm it reports `AGENTS.md § Conventions` via the bridge from `CLAUDE.md`, not `CLAUDE.md` alone
- [ ] Run it on a guide with no rules and confirm the "not recorded yet" message still reads as a true negative, not as an empty section list

## Implementation plan

_Populated by `/tasks plan TASK-013`._
