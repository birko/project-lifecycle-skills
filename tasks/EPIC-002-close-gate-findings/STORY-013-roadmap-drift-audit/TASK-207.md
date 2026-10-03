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
findings: [DRILL-198-1, DRILL-198-2, SH-16, SH-20]
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

**Linked at intake of the first spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b)** — the
project-roadmap harvester raised the same two rules from the text alone:

- **SH-16 — DV1 and DV4 overlap, and DV4 has no empty case.** Read as *either*, DV1's "all decisions `proposed`"
  arm plus an `in-progress`/`done` task is also DV4's condition ("linked tasks but every decision is still
  `proposed`"), so one feature gets both findings for one drift. DV4 also does not say what it does with a feature
  whose `decisions.md` has **no rows**: "every decision is `proposed`" is vacuously true there.
- **SH-20 — a feature with no `status.md`** has no phase for the full render's phase column either, not only for DV1;
  the same answer DRILL-198-1 needs should cover the render.

## Acceptance criteria

- [ ] DV1 states what stands for the phase when `status.md` is absent (for example: the coarse marker, or "phase unknown, report it"), and does not leave the reader to choose
- [ ] DV1's condition says whether its two halves are alternatives or both required, with the reason
- [ ] DV6, the other rule that reads the phase, gets the same treatment where it applies
- [ ] DV1 and DV4 do not both fire for one drift, or the overlap is stated as intended; DV4 says what a ledger with no rows does (SH-16)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Making `/feature new` write a `status.md`. That would be a change to `feature`, decided there if wanted.

## Human test plan

- [ ] Re-run the TASK-198 round-1 fixture (no `status.md`) with two fresh runners. Both report the same DV1 outcome.
