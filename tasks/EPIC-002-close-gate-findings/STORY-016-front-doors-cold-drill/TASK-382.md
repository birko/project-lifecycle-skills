---
id: TASK-382
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-15
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-024-1, DRILL-024-2, DRILL-024-3]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Three re-adoption readings that both TASK-024 runners left undecided

## Context

Filed 2026-11-15 from TASK-024's two cold re-adoption runs of the d065b brief: `%LOCALAPPDATA%/Temp/d024` (over d378's
adopted output) and `%LOCALAPPDATA%/Temp/d024b` (over d024's committed output), each `report.md`. Both runs raised
each reading below, so each meets FEATURE-002 D10's two-runner bar. TASK-024's Outcome lists them as not yet filed.

| Id | Reading | Where |
|---|---|---|
| DRILL-024-1 | **A re-run that finds nothing "writes nothing at all"**, while `/tasks init` and `/feature status` rewrite their files' timestamps on every run. Whether a timestamp-only rewrite counts as a write, and whether the re-run should call those verbs at all when their rows are current | `skills/adopt-project/SKILL.md` (the re-run rule), `LAYER.md`'s rows for `tasks/README.md` and the features index |
| DRILL-024-2 | **The CI row's test-step rule** names a missing harness or one wired this run, not a harness present with no tests in it. Whether the CI step runs the runner, skips it, or reports it | `skills/new-project/LAYER.md`, the CI row |
| DRILL-024-3 | **Whether the test-harness row's terminating sentence counts as its verb answering**, for the verdict *complete*. The row ends "A repo with a working runner is already adopted — say so and move on", so `populate-tests` `adopt` is never asked, and AGENTS.md's owner-verb convention reads as if it should be | `LAYER.md`'s test-harness row, `adopt-project` step 3 |

## Acceptance criteria

- [x] DRILL-024-1 … 3 each have one stated answer, in the file that owns the rule — 1 in `adopt-project` (a re-run writes nothing *of its own*; chained owner verbs regenerate, reported as theirs), 2 and 3 in `LAYER.md` (the CI rule keys on a test file; the harness row delegates with a working runner)
- [x] DRILL-024-3's answer says whether an adoption reaches `populate-tests` `adopt` once a runner exists, and the
      `AGENTS.md` owner-verb entry agrees with it — it does (user's decision, option a); the entry covers rows whose cell hands the artifact to a verb, and this row now does in every case
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- Everything TASK-024 decided (the four `/specs init` outcomes, the harness check by reading, the changelog left alone,
  the features index *regenerated*)
- TASK-379's five readings, from the same brief

## Human test plan

- [x] Re-run the d065b brief on a fresh copy of an adopted fixture (not WorkoutTracker) with `skills/` at the fix and a
      cold runner, twice in succession. Expected: none of DRILL-024-1 … 3 in either run's "left undecided" section
  - **Passed 2026-11-15**, cold runners: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d382`, the cwd holding only `brief.txt`, a copy of `skills/` and a clone of d024b's adopted repo
    (a `pytest.ini`, no test files), run twice, the second over the first's committed output; each report lists no
    skills. Both delegated the harness to `populate-tests` `adopt`, which reported *left as it is* naming a real miss
    (no `.pytest_cache/` ignore); both reported CI `missing, not offered: nothing to run yet` with "no test file"; both
    reported the dashboard rewrites as the verbs' own. None of DRILL-024-1 … 3 was raised by both; run 2 alone
    quoted the re-run sentence and resolved it as the text says. Both raised a new reading the delegation exposed,
    filed as TASK-383.

## Implementation plan

Not planned (step 3b): two files, three criteria.

## Outcome

**What was fixed:** three things two cold re-adoption runners had to decide for themselves.
- **A re-run's writes:** `adopt-project` says a re-run that finds nothing writes nothing *of its own*; the owner
  verbs it chains still regenerate their generated files, reported under *regenerated* as theirs.
- **CI without tests:** `LAYER.md`'s rule leaves the test step out whenever the repo holds no test file its runner
  would collect, whatever the harness row says (a configured runner with nothing to run included).
- **The harness row (user's decision, option a):** adoption delegates to `populate-tests` `adopt` with a working runner
  too; that path builds, runs and writes nothing and answers *already current* or *left as it is*. `LAYER.md`'s
  whole-cell passage no longer cites this row as a terminating condition.

**Step 6, as a split:** the old text, 3 of 3 readings raised by 2 of 2 runners (d024, d024b); the fixed text, 0 of 3
raised by both of 2 (d382). No automated test: prose, so the cold drill is the instrument.

**Judgement calls:**
- **Option a over b** was the user's, on the recommendation that the check is read-only and the only way TASK-024's
  harness check reaches an adoption; b would have reported a harness current with nobody having looked.
- "Writes nothing *of its own*" rather than suppressing the dashboards' timestamp rewrite: the dashboards belong to
  their verbs, and an adoption that skipped them would leave them stale.

**Flagged, not fixed:** TASK-383, the ignore line the new delegation surfaces (both d382 runners). Single-runner
readings of d382 recorded here only: the guide-section letters (TASK-379's DRILL-378-1), the verdict line's position
against the commit offer, and `amended` without consent.

**Close gate (inline; two skill files, one spec):** standards and intent met; correctness by d382; layer parity holds
(`LAYER.md` is the inventory both doors read, and `new-project` has no harness to reconcile); security and comments
not applicable; local lint passes; project-baseline respecced.

## Progress log

- step 2 — picked; ranked above TASK-379 because keys 1–3 tie (instructions runners read differently; reachable on every re-adoption; silent) and key 4 separates: three readings in two files against five across five
- step 3 — verified: held — adopt-project's intro says a re-run that finds nothing "writes nothing at all" while its own 3c row says chained owner verbs regenerate; LAYER.md's CI rule names a missing harness or one wired this run, not a present one with no test file; the test-harness row ends "already adopted — say so and move on" and never asks populate-tests
- step 3b — not planned: two files, 3 criteria, no feature:, the one unknown is a decision for the user, not a plan
- step 4 — layer: local
- step 5 (part) — DRILL-024-1 and -2 fixed: adopt-project says a re-run writes nothing *of its own* and chained owner verbs regenerate by their rules; LAYER.md's CI rule keys "no tests yet" on the absence of a test file, whatever the harness row says
- step 4b — decision asked and answered by the user 2026-11-15: (a) adoption calls populate-tests adopt whenever a runner exists
- step 5 — DRILL-024-3 fixed: LAYER.md's test-harness row delegates with a working runner too, and its whole-cell passage no longer cites that row as a terminating condition
- step 6 — old text 3/3 readings by 2/2 runners; fixed 0/3 by both of 2 (d382); one new two-runner reading, spawned as TASK-383
- step 7 — respecced project-baseline (re-run writes, CI test step, harness delegation, its scenario)
- step 8 — closed inline; outcome in status:, commit in git log
