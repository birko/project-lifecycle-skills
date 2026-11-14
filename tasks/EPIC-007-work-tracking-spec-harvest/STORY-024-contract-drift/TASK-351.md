---
id: TASK-351
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
picked-by: fix-next
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-240-4, DRILL-240-5, DRILL-240-6, DRILL-240-7]
pr: null
github-issue: null
jira-key: null
---

# `/feature status` in single-feature mode leaves four rendering details to the reader

## Context

Spawned 2026-11-12 from TASK-240's Human test plan drill (`%LOCALAPPDATA%/Temp/d240`, `report.md`). **Raised by one
runner only**, so each is a candidate to confirm, not a measured defect. A group: small readings from one run of
`skills/feature/verbs/status.md` in single-feature mode.

- **DRILL-240-4:** a single-feature run updates one index row and leaves the `_Generated <timestamp>_` header, which
  then dates a row it did not produce.
- **DRILL-240-5:** the collection pass finds divergences (DV5 here), but a single-feature run renders no drift note and
  `status.md` has no slot for one, so the finding is surfaced nowhere.
- **DRILL-240-6:** `{{TASK_LIST}}` and `{{TESTABLE_SUMMARY}}` have no wording for a feature with no tasks, and
  `{{TIMESTAMP}}` no format.
- **DRILL-240-7:** `{{NEXT_STEP}}` has examples only; `deciding` with a proposed row left has no stated wording.

## Acceptance criteria

- [x] Each of DRILL-240-4 … 7 is either confirmed by a second cold runner and then answered in `status.md`, or recorded here as not reproduced
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Who writes the index row — TASK-240

## Human test plan

- [x] Re-run TASK-240's brief on a fresh copy of its fixture with a cold runner. Expected: none of the confirmed findings in its "left undecided" section
  - **Passed 2026-11-14**, as TASK-373's d373 run 3: `/feature status FEATURE-004` by a cold runner on a clone of this
    repo, `skills/` at the fix. None of DRILL-240-4 … 7 came back as undecided: the index header was left alone (4),
    the single-feature drift line had nothing to print (5), the task list and testable summary used the stated forms
    (6), and the next step was the `building` row's sentence (7).

## Implementation plan

Inline, together with its sibling task: state each rendering choice in `status.md`.

## Outcome

**Each reading answered in `status.md`, without a separate second-runner confirmation**, because the fix landed with
TASK-373's and was drilled with it:
- **DRILL-240-4:** a single-feature run leaves the index header's timestamp alone; it dates the last full render.
- **DRILL-240-5:** a single-feature run prints its feature's open findings in one line, since `status.md` has no slot.
- **DRILL-240-6:** `{{TASK_LIST}}` is `_None_` with no task, `{{TESTABLE_SUMMARY}}` reads `Nothing to test yet.`, and
  `{{TIMESTAMP}}` takes `triage`'s form.
- **DRILL-240-7:** `{{NEXT_STEP}}` has one sentence per phase, including `deciding` with a proposed row left.

**Close gate (inline, worked with its sibling task; three skill files plus two specs):**
- **Standards:** every rule is in the verb that renders it, and what `triage` already settled is pointed at.
- **Intent:** all criteria met.
- **Correctness:** checked by d373; the one variance it found is outside `status.md` and is fixed (below).
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

## Progress log

- step 2 — picked together with TASK-373: both settle `/feature status`'s rendering choices in one file; ranked first among the P3 defects because the committed rollups are not reproducible (d375's two runs differed on wording and order)
- step 3b — planned inline with the sibling task: state each rendering choice in `status.md` (counts without cancelled tasks, task order, verbatim titles, ready-to-test meaning built, the TESTABLE and NEXT_STEP forms, empty lists, the digest's order and decision part, prototype labels by form, open-only drift note, single-feature timestamp and drift), and drop "describe in human terms", which no input can recompute
- step 5 — fix in skills/feature/verbs/status.md (steps 3, 4, 6, 7, Notes) and the index template's comments
- step 6 — behavioural: d373 run 3 (single feature), none of the four undecided
- step 7 — respecced with TASK-373 (feature-lifecycle), restamped
- step 8 — closed inline; commit in git log
