---
id: TASK-341
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-337-1, DRILL-337-2, DRILL-337-3]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` calls a `verify` task "in review", cannot find the default branch with no remote, and flips the status before cutting the branch

## Context

Raised by the second TASK-337 drill run (2026-11-05, recorded on TASK-337), in `skills/tasks/verbs/pick.md`:

- **DRILL-337-1:** step 2b's debt line template reads `⚠ 2 in review awaiting sign-off: …`, and a runner kept "in review" for a task at `status: verify`, which is the current name. It is the older name, still read as an alias.
- **DRILL-337-2:** steps 6b and 7 turn on "the default branch" and `<default>@{upstream}`, but nothing says how to find the default branch when there is no remote or `origin/HEAD`. Both TASK-182 runners took the only checked-out branch, by inference.
- **DRILL-337-3:** step 7 lists the status edit (`todo` → `in-progress`) before "Cut the task branch". An in-place run edits on the default branch and carries the change onto the new branch uncommitted. Nothing says whether that order is intended, or which step 8 row then applies.

## Acceptance criteria

- [ ] 2b's debt line names the state the tasks carry (`verify`, or `review` for the older form), or says why "in review" covers both
- [ ] The default branch's source is stated, including a repo with no remote
- [ ] Step 7 states the order of the status edit and the branch cut, and step 8's row for the result is unambiguous
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [ ] Re-run TASK-182's brief (on TASK-337's Progress log) with a cold runner. Expected: none of the three in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-341` — leave empty until then._
