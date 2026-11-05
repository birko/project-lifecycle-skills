---
id: TASK-207
parent: STORY-013
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-10-01
depends-on: []
blocks: []
findings: [DRILL-198-1, DRILL-198-2, SH-16, SH-20]
pr: null
picked-by: fix-next
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

- [x] DV1 states what stands for the phase when `status.md` is absent (for example: the coarse marker, or "phase unknown, report it"), and does not leave the reader to choose
- [x] DV1's condition says whether its two halves are alternatives or both required, with the reason
- [x] DV6 and DV2, the other rules that read the phase, get the same treatment where it applies (DV2 added at step 3: it reads the phase too)
- [x] DV1 and DV4 do not both fire for one drift, or the overlap is stated as intended; DV4 says what a ledger with no rows does (SH-16)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Making `/feature new` write a `status.md`. That would be a change to `feature`, decided there if wanted.

## Human test plan

- [x] Re-run the TASK-198 round-1 fixture (no `status.md`) with two fresh runners. Both report the same DV1 outcome.
  - **Passed 2026-11-05 (second pair):** TASK-198's round-1 shape rebuilt as `%LOCALAPPDATA%/Temp/d207a` and `d207b`: two features, each with an approved decision, a `done` linked task, `idea.md` reading `idea`, and no `status.md`; `roadmap`, `tasks` and `feature` copied after the amended fix. Two fresh runners, `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep < brief.txt`, brief "Run /roadmap --check, read-only: change no file. Give its output verbatim." Both printed `Divergences (2):` with `FEATURE-001 DV1 no rollup — run /feature status FEATURE-001` and the same line for FEATURE-002, no DV2 and no DV6, and changed nothing. The first pair also agreed on DV1, but both fired DV2 beside it from this task's ambiguous DV2 clause, since fixed. Coldness: no runner listed skills

## Progress log

- step 2 — picked; ranked above TASK-089 because key 1: DV1, the drift check for docs frozen while work moved, silently cannot fire on a feature with no status.md (the window it exists for), a wrong result, where TASK-089 concerns a verdict branch never observed rather than a wrong verdict; key 5: two cold runners disagreed on it (DRILL-198) and a spec harvest raised the same rules (SH-16, SH-20); key 6 ties (correctness-invariants)
- step 3 — verified: held. roadmap SKILL.md's DV1 row still reads "Feature phase `idea` / all decisions `proposed`" with the phase read from status.md (§ 2), which /feature new never creates; DV4's "every decision is still `proposed`" is vacuous on an empty ledger; DV6 reads the same phase. The coarse idea.md marker cannot stand in, since it reads `idea` through every healthy build
- step 3 (rescope) — criterion 3 widened to name DV2, which also reads the phase (raised by the plan, before any edit)
- step 3b — planned: /tasks plan --no-grill (five criteria); no split signal
- step 4 — layer: local
- step 5 — fix in skills/roadmap/SKILL.md (§ 2 null phase; DV1 stored phase or no status.md, suppressed under DV4; DV2 and DV6 phase arms skipped without status.md; DV4 positive; § 5 model; render `—` and the `no rollup` bucket); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill
- step 7 — respecced project-roadmap; requirements changed: Collect features, DV1 (+2 scenarios), DV2, DV4 (+1 scenario), DV6, Full render, Compact slice; intended — TASK-207's criteria
- step 5 (amended after the first drill pair) — both runners reported the same DV1 outcome (`no rollup — run /feature status` on both features), but both read "the phase arm is skipped" as "drop the condition" and fired DV2 beside DV1. The intent was the reverse, so DV2 is now "not evaluated at all when there is no status.md", in the skill and the spec. Re-run on rebuilt fixtures (first pair kept as d207a-run1, d207b-run1)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
