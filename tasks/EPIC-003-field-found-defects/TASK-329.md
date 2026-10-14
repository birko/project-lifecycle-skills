---
id: TASK-329
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-328-1]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick TASK-NNN` by bare id skips the taken filter, so an in-place pick can take a task another clone holds

## Context

Found by TASK-328's cold drill (2026-10-14). Both runners raised it. `skills/tasks/verbs/pick.md` step 1 says: *"Bare ID arg (`/tasks pick TASK-014`) → skip the picker, jump to step 5."* That skips step 3, where the taken filter lives (a `todo` task whose `task/TASK-NNN` branch exists locally or on a remote, [[tasks]] SKILL.md § *Collection pass*). Under `workspace: worktree` with an upstream, 6b's taken-elsewhere check still catches it, and since TASK-328 every fallback runs that check too. Two cases have no check at all:
- an ordinary in-place pick (`workspace: in-place`, a PR-per-task default);
- any pick with no upstream, where a local `task/TASK-NNN` from another session marks the task as taken.

Scenario: a person names a task someone else has pushed a branch for. The pick flips it to `in-progress` and cuts a second branch over the other person's work.

## Acceptance criteria

- [ ] A bare-id pick refuses a task the Collection pass counts as taken, whatever `workspace:` says, with a stated report line
- [ ] A bare-id pick of a task taken by this clone's own branch still resumes where the resume rules say it does
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- 6b's own taken-elsewhere check (TASK-328)

## Human test plan

- [ ] On an in-place PR-per-task fixture with `task/TASK-001` already on the remote, run `/tasks pick TASK-001`. Expected: the run refuses and names the branch; nothing is flipped or cut.

## Implementation plan

_Populated by `/tasks plan TASK-329` — leave empty until then._
