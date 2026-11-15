---
id: TASK-383
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
findings: [DRILL-382-1]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
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

- [x] An ignore line the existing-harness check finds missing has one stated route: into the `.gitignore` letter
      (foreseeable, since step 1 knows the runner) or reported `offered, not asked — found after the round`
- [x] `populate-tests` `REFERENCE.md` § Adopt says whether its existing-harness report hands such a line back to the
      caller — it does: a missed generated-dirs ignore is handed back as lines, never written
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- TASK-382's three readings, settled there
- The single-runner readings of the same drill

## Human test plan

- [x] Re-run the d065b brief on a fresh clone of `%LOCALAPPDATA%/Temp/d382/adopted` (before its run-1 commit) with
      `skills/` at the fix and a cold runner, twice. Expected: neither raises the ignore line's route as undecided
  - **Passed 2026-11-15**, cold runners: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d383`, the cwd holding only `brief.txt`, a copy of `skills/` and a fresh clone of d024b's
    adopted repo (the state before d382's run 1), run twice from that same state; each report lists no skills. Both put
    `.pytest_cache/` into the fill item's `.gitignore` letter, and both reported the harness *left as it is* with the
    miss pointing at that letter, not offered twice. Neither raised the route. Single-runner readings, recorded only:
    whether a miss pending in the letter still makes the row `present, outdated` (run 1); whether timestamp-only
    writes belong in the commit offer (run 1); the guide-section letters (both, already TASK-379's DRILL-378-1).

## Implementation plan

Not planned (step 3b): two files, three criteria.

## Outcome

**What was fixed:** once TASK-382 made adoption check an existing test harness, a missing ignore line for the
runner's output (`.pytest_cache/`) had no defined route. `adopt-project` now foresees those lines whenever it knows
the runner, missing or present, so they join the `.gitignore` offer in the one question round; `populate-tests`
`adopt` says it hands such a line back as an offer and writes none.

**Also fixed, a sibling TASK-382 missed:** `REFERENCE.md` still said a harness that is a CI-run script is never
reached by `adopt`, false since TASK-382. It now says that harness takes the same read-only path.

**Step 6, as a split:** the old text, the route raised by 2 of 2 runners (d382); the fixed text, by 0 of 2 (d383). No
automated test: prose, so the cold drill is the instrument.

**Judgement call:** route the line into the letter (foreseen) rather than report it `found after the round`. Step 1
already knows the runner, and both runners had chosen the letter; the stricter option, a late report, would have
left a known gap unoffered until the next run.

**Flagged, not fixed:** the single-runner readings above, recorded on this task only.

**Close gate (inline; two skill files, two specs):** standards and intent met; correctness by d383; layer parity
not touched (no `LAYER.md` change); security and comments not applicable; local lint passes; project-baseline and
test-authoring respecced.

## Progress log

- step 2 — picked; ranked above TASK-379 because keys 1–3 tie (instructions runners read differently; reachable on every adoption of a repo with a runner; silent) and key 4 separates: two criteria in two files against five readings in five
- step 3 — verified: held, and wider by one sentence — adopt-project step 2 foresees ignore lines only for a missing harness, REFERENCE § Adopt hands lines back only under the wiring invariants, and REFERENCE still says a CI-script harness is never reached by adopt, false since TASK-382 (a sibling that change missed)
- step 3b — not planned: two files, 3 criteria, no feature:, no unknowns
- step 4 — layer: local
- step 5 — fix in skills/adopt-project/SKILL.md (step 2's foresee rule) and skills/populate-tests/REFERENCE.md (§ Adopt: hand back the line; the CI-script sentence); no test file (prose)
- step 6 — old text: route raised by 2/2 runners (d382); fixed: 0/2 (d383)
- step 7 — respecced project-baseline (foreseeable ignore lines), test-authoring (hand back, CI-script harness)
- step 8 — closed inline; outcome in status:, commit in git log
