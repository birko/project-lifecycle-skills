---
id: TASK-269
parent: STORY-025
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [IA-2]
pr: null
github-issue: null
jira-key: null
---

# `adopt-project` changes with `new-project`'s LAYER.md in 19 commits, and both keep needing fixes

## Context

Filed by `/improve-architecture` (EPIC-008, author run at `30f9716`).

Candidate key: 4:skills/adopt-project/SKILL.md — IA-2

- **Files:** `skills/adopt-project/SKILL.md` (main) and `skills/new-project/LAYER.md`, in two skill folders.
- **Problem:** class 4, leaky seam, `4, co-change`. The pair changed together in 19 commits, out of 24 for `adopt-project/SKILL.md` and 33 for `LAYER.md`, and `adopt-project` reads `LAYER.md` by path, an internal reference across folders.
- **Solution:** move the logic to where the data lives, or ask the owning module for what is wanted (Step 4's class 4 move). Here: whatever `adopt-project` restates about the layer's rows (the survey states, the conditional and lazy markers) moves into `LAYER.md`, and `adopt-project` asks `LAYER.md` rather than duplicating it.

  `Gate: not a shallowness claim — 4, co-change`. **Tension to weigh first:** AGENTS.md § *Layer parity* requires a layer change to update `new-project` and `adopt-project` together, through `LAYER.md`. So co-change through `LAYER.md` is intended; co-change of `adopt-project/SKILL.md` itself is the share to remove.
- **Benefits:**
  - Leverage: not measured, because which `adopt-project` lines restate `LAYER.md` is a reading.
  - Locality: 2 → 1 files per layer change, in the 19 commits where both changed.
- **Before/after:** before, two folder frames (`adopt-project`, `new-project`) with a co-change edge labelled 19 and a reference arrow from `adopt-project/SKILL.md` to `LAYER.md`. After, the same reference arrow, and the co-change edge gone.
- **Strength:** `strong`, because fix landings in its own files corroborate a candidate raised on co-change: `LAYER.md` 24, `adopt-project/SKILL.md` 18.

## Acceptance criteria

- [ ] Every rule `adopt-project/SKILL.md` restates about the layer's rows (survey states, the `(lazy)` and `(conditional)` markers) is listed in this task, and each is replaced by a pointer to the `LAYER.md` section that owns it
- [ ] `adopt-project/SKILL.md` names no layer row's state or marker except through such a pointer (checked by grepping it for each marker and state name)
- [ ] `bash .github/workflows/skills-lint.sh` passes

> Criteria rewritten 2026-10-06, before work started: a cold reader found "a later run no longer reports this pair" uncheckable at merge time, and the "or records why" clause let the criterion pass with no change (TASK-078's test plan).

## Out of scope

- The layer parity rule itself (AGENTS.md)

## Human test plan

N/A: a prose restructuring verified by the lint and a later run's co-change figures.

## Implementation plan

_Populated by `/tasks plan TASK-269` — leave empty until then._
