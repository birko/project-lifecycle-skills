---
id: TASK-379
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-378-1, DRILL-378-2, DRILL-378-3, DRILL-378-4, DRILL-378-5]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Five adoption readings that two or more cold runners left undecided

## Context

Filed 2026-11-14 by comparing the undecided sections of three cold runs of one brief: the d065b full `/adopt-project`
run on a fresh copy of `d065/adopted`, as `%LOCALAPPDATA%/Temp/d365`, `d269` and `d378` (each `report.md`, § 7). Each
reading below was raised by at least two of them, so each meets FEATURE-002 D10's two-runner bar. They were noted as
one-runner leftovers on TASK-365 and TASK-269 before the comparison showed the overlap.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-378-1 | **The fill item's granularity.** "one itemised offer naming each missing section": one letter per guide section, or one letter for all of them | d365, d269, d378 |
| DRILL-378-2 | **When the verdict line counts.** "Every run ends its report with one verdict line" does not say whether its counts are the survey's states or the states after the fill (7 missing against 2 on the same repo) | d269, d378 |
| DRILL-378-3 | **"A `tests/` package for pytest".** Whether it means creating `tests/__init__.py`; one runner did, one did not, and the harness table says "the test dir and the runner config only" | d365, d378 |
| DRILL-378-4 | **The drift note's reason wording.** `/feature status`'s drift note `<target> DV<x> <short reason>` fixes no reason text, so each runner wrote its own ("no spec map", "never generated") | d269, d378 |
| DRILL-378-5 | **Which rows "a verb creates".** TASK-365's form `missing — <verb> creates it in step 3` covers "every row whose cell names its creating verb", but `docs/features/`'s cell creates the folder by hand and only the index by `/feature status`, and the test harness's cell says "delegate", not "create" | d269, d378 |

## Acceptance criteria

- [x] DRILL-378-1 … 5 each have one stated answer, in the file that owns the rule (`adopt-project`, `LAYER.md`,
      `populate-tests`, `feature` `status`, `roadmap`) — 1 `LAYER.md` (one letter per section), 2 `adopt-project` (the
      states the run leaves), 3 `populate-tests` (a `tests/` dir and config, no `__init__.py`), 4 `roadmap` (a fixed
      short reason per rule, read verbatim by `triage` and `/feature status`), 5 `adopt-project` (wholly or in part)
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- Single-runner readings from the same drills (`amended` defined by consent while `/tasks init` changes a file
  unasked; the re-run wording on a row that never existed): file them when a second runner raises them
- Everything TASK-365, TASK-269 and TASK-378 settled

## Human test plan

- [x] Re-run the d065b brief (`%LOCALAPPDATA%/Temp/d378/brief.txt`) on a fresh copy of `d065/adopted` and of `skills/`
      at the fix, with a cold runner. Expected: none of DRILL-378-1 … 5 in its "left undecided" section
  - **Passed 2026-11-15**, two cold runners in parallel: `claude -p --disable-slash-commands --permission-mode
    acceptEdits` in `%LOCALAPPDATA%/Temp/d379a` and `d379b`, each cwd holding only d378's `brief.txt`, a copy of
    `skills/` and a fresh clone of `d065/adopted`; each report lists no skills. Neither raised any of DRILL-378-1 … 5:
    both wrote `specs/greeting DV7 never generated` (resp. `specs/console-greeting`), both ended `not complete: 2
    missing, 1 unknown` citing the new sentence, both used `missing — /feature status creates its index in step 3`.
    Both raised one reading the partial-create wording opened (the features index: *created* or *regenerated*),
    settled in the same change: the folder *created*, the index *regenerated*. Single-runner readings recorded only:
    CHANGELOG's "seed the skeleton" as a creating verb (a); DV11 for a mapped area with no spec file (a); the
    `.gitignore` letter's shape (b).

## Implementation plan

Not planned (step 3b): five one-line answers.

## Outcome

**What was fixed:** five things cold adoption runners each had to decide alone now have one answer, in the file that
owns each:
- **Guide sections** are offered one letter per section (`LAYER.md`).
- **The verdict line** counts the rows as the run leaves them, after its fills (`adopt-project`).
- **pytest's harness** is a `tests/` directory and a config, with no `__init__.py` (`populate-tests` `REFERENCE.md`).
- **A drift finding's reason** is fixed per rule: `/roadmap`'s rule table gains a *Short reason* column, which the
  roadmap, the tasks dashboard and the feature index print verbatim.
- **"A verb creates it"** covers a verb that writes part of the artifact or scaffolds it; for `docs/features/` the
  folder is reported *created* and the index *regenerated*.

**Step 6, as a split:** the old text, the five readings raised by 2–3 of 3 runners (d365, d269, d378); the fixed text,
0 of 5 by 2 of 2 (d379a, d379b). No automated test: prose, so the cold drill is the instrument.

**Judgement calls:**
- The verdict counts the end state, not the survey: a verdict describes the repo the run leaves, and a survey count
  would call a repo `not complete` for gaps this run filled.
- The reasons are fixed in `/roadmap`, the owner of the rules, not in each view; three views wording one finding
  three ways is the defect.

**Flagged, not fixed:** the single-runner readings above, recorded here only.

**Close gate (inline; six skill files, five specs):** standards and intent met; the reason list lives in its owner and
the views point at it; correctness by d379a/b; layer parity holds (`LAYER.md` is the inventory both doors read);
security and comments not applicable; local lint passes; project-baseline and project-roadmap respecced,
test-authoring, work-tracking and feature-lifecycle restamped.

## Progress log

- step 2 — picked; ranked above none — the last task in the pool
- step 3 — verified: held — all five read as filed; DRILL-378-1 raised again by both d383 runners; DRILL-378-4's `short reason` is free text in roadmap's compact slice, which the feature index and the dashboard both reuse
- step 3b — not planned: five readings, one stated answer each, no feature:, no unknowns
- step 4 — layer: local
- step 5 — fixes: LAYER.md guide row (one letter per section); adopt-project (verdict counts the states the run leaves; "a verb creates it" covers a partial or scaffolding delegation); populate-tests REFERENCE (pytest: a tests/ dir and config, no __init__.py); roadmap rule table gains a Short reason column, which triage, feature status and the index read verbatim
- step 6 — old text: 5 readings by 2–3 of 3 runners; fixed: 0/5 by 2/2 (d379a, d379b); one two-runner reading the fix opened, settled in the same change
- step 7 — respecced project-baseline (partial create, the verdict line), project-roadmap (the fixed reason); restamped test-authoring, work-tracking, feature-lifecycle
- step 8 — closed inline; outcome in status:, commit in git log
