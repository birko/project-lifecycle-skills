---
id: TASK-383
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-15
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-382-1]
pr: null
github-issue: null
jira-key: null
---

# An existing harness's missing ignore line has no defined route into the `.gitignore` offer

## Context

Spawned 2026-11-15 from TASK-382's drill (`%LOCALAPPDATA%/Temp/d382`, `report1.md` and `report2.md`, § 7). TASK-382
made adoption delegate to `populate-tests` `adopt` even when a runner exists. On the fixture (a `pytest.ini`, no test
files) that check reported the harness *left as it is*: `.gitignore` has no `.pytest_cache/`. Both runners then had to
decide where that line goes, so it meets FEATURE-002 D10's two-runner bar.

- **DRILL-382-1.** `skills/adopt-project/SKILL.md` step 3 (around *"are foreseeable, so they join the fill item's
  `.gitignore` letter"*) makes a runner's output directories foreseeable only when step 1 finds the test harness
  **missing**. With a present harness the miss now surfaces from `populate-tests`, after the round. Run 1 also asked
  whether `populate-tests` hands the line back at all on an existing harness, since its *"offer the lines instead of
  writing them"* sits under the wiring invariants, not the existing-harness branch. Both runners put the line into the
  fill item's `.gitignore` letter anyway; the text does not say so.

## Acceptance criteria

- [ ] An ignore line the existing-harness check finds missing has one stated route: into the `.gitignore` letter
      (foreseeable, since step 1 knows the runner) or reported `offered, not asked — found after the round`
- [ ] `populate-tests` `REFERENCE.md` § Adopt says whether its existing-harness report hands such a line back to the
      caller
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- TASK-382's three readings, settled there
- The single-runner readings of the same drill

## Human test plan

- [ ] Re-run the d065b brief on a fresh clone of `%LOCALAPPDATA%/Temp/d382/adopted` (before its run-1 commit) with
      `skills/` at the fix and a cold runner, twice. Expected: neither raises the ignore line's route as undecided

## Implementation plan

_Populated by `/tasks plan TASK-383` — leave empty until then._
