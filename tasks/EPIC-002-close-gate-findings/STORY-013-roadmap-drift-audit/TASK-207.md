---
id: TASK-207
parent: STORY-013
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-10-01
depends-on: []
blocks: []
findings: [DRILL-198-1, DRILL-198-2]
pr: null
github-issue: null
jira-key: null
---

# DV1 cannot fire on a feature with no `status.md`, and its condition reads two ways

## Context

Found by the TASK-198 drill (2026-10-01). Two independent cold runners ran `/roadmap --check` on one
fixture: two features, each with an approved decision and a `done` task, `idea.md` reading `idea`, and no
`status.md`. They disagreed.

- **DRILL-198-1.** DV1 is keyed on the feature's **phase**, which § 2 reads from `status.md`'s `**Phase:**` line.
  `/feature new` creates no `status.md`, so every newly created feature has no phase until someone runs
  `/feature status`. One runner substituted `idea.md`'s coarse marker and fired DV1. The other said DV1 could not
  be checked. Neither was told which to do. This is the exact window DV1 exists for: work moved on while the
  feature side never did.
- **DRILL-198-2.** DV1's condition is written "Feature phase `idea` / all decisions `proposed`". Both runners
  independently asked whether the slash means **either** or **both**. Read as *both*, DV1 never fires on a
  feature whose decisions are approved, which is the common case once work starts.

## Acceptance criteria

- [ ] DV1 states what stands for the phase when `status.md` is absent (for example: the coarse marker, or "phase unknown, report it"), and does not leave the reader to choose
- [ ] DV1's condition says whether its two halves are alternatives or both required, with the reason
- [ ] DV6, the other rule that reads the phase, gets the same treatment where it applies
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Making `/feature new` write a `status.md`. That would be a change to `feature`, decided there if wanted.

## Human test plan

- [ ] Re-run the TASK-198 round-1 fixture (no `status.md`) with two fresh runners. Both report the same DV1 outcome.
