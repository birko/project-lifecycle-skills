---
id: TASK-347
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-346-1, DRILL-346-2, DRILL-346-3, DRILL-346-4, DRILL-346-5, DRILL-346-6, DRILL-346-7, DRILL-346-8, DRILL-346-9, DRILL-346-10]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` leaves eight more readings open in its list, its hand-off and its plan offer

## Context

Spawned 2026-11-12 from TASK-346's Human test plan drill: two cold runs of TASK-255's brief on the `d255` fixture
(`%LOCALAPPDATA%/Temp/d255`, reports kept there as `report-346a.md` and `report.md`). This is a **group**: every
reading is in `skills/tasks/verbs/pick.md` or the `plan.md` hand-off it chains, each is small, and they share one
fixture and one drill, so they are cheaper done and re-drilled together.

**Raised by both runners independently** (the agreement bar FEATURE-002 D10 uses):

- **DRILL-346-1:** step 3's `taken (hidden)` line goes "under the list", but the list and its question are step 4. Before or after the question is unstated.
- **DRILL-346-2:** step 3 captures "parent IDs (story + epic)", while step 4's example renders titles (`EPIC-001 Authentication → STORY-001 Password login`). Both runners read the titles to match the example.
- **DRILL-346-3:** the multiple-in-progress warning prints "after the choice", with no position relative to steps 5–9.
- **DRILL-346-4:** step 9's dispatch bullet ends by putting the 9b offer, but the `github-issue:` and boundary bullets come after it. Their order relative to the offer is unstated.
- **DRILL-346-5:** step 6's "touches more than one file" trigger cannot be judged before a plan exists, and "its Context names unknowns" is undefined.
- **DRILL-346-6:** 9b's T1 ("names what decides it") was judged to fail on "visible in the CLI output" by both runners, but each called it a judgement, against the test's claim that two readers reach the same answer.
- **DRILL-346-7:** the in-progress line's `<worktree path>`: git's absolute path, or the declared relative form.
- **DRILL-346-8:** a verify-on-branch check reads `git show task/TASK-NNN:…`, which has no local ref for a remote-only task. It made no difference on this fixture.

**Raised by one runner** (recorded, not held to the bar; fold them in if the fix reaches them):

- **DRILL-346-9:** `plan.md` chained from `pick` prints its own confirmation, including "Start work with `/tasks pick`", mid-pick; only a chain from `new` is exempted. Its grilling field has no value for `--no-grill`.
- **DRILL-346-10:** step 8's rows for "anywhere, with an upstream" and "in a worktree … never reached here" both seem to apply to a worktree pick with an upstream. Separately, when 6b restores the main copy's task file relative to the commit and push is unstated.

## Acceptance criteria

- [ ] DRILL-346-1 … 8 each have one stated answer in `pick.md` (or in `plan.md` where the reading is plan's)
- [ ] DRILL-346-9 and 10 are either answered or recorded on this task as not reproduced by a second runner
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The four readings TASK-346 settled (step 4's question, the fetch, step 6's no-answer path, the `pr:` question at 6b Match)

## Human test plan

- [ ] Re-run TASK-255's brief on the `d255` fixture with a cold runner (recipe on TASK-255). Expected: none of DRILL-346-1 … 8 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-347` — leave empty until then._
