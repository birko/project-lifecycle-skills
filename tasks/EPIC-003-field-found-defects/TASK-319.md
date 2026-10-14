---
id: TASK-319
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
findings: [FIELD-015]
pr: null
github-issue: null
jira-key: null
---

# A `decide` revert sends a task back to `verify` with its old test step still ticked, so a re-close can count the old pass

## Context

Found by TASK-307's drill (2026-10-14). `skills/feature/verbs/decide.md`'s surface-dependent revert sends the implementing task `done → verify` and says to re-run its Human test plan before re-closing. It leaves the plan as it was. The step stays `[x]` with its old pass line, and [[tasks]] § *Lifecycle* reads `[x]` as **passed**, so `close` can take the task to `done` on a pass recorded against behaviour that no longer exists.

It is worse when the changed decision has not been built yet: the drill's runner reverted a task to `verify` ("code complete, awaiting a check") while the code still did the old thing, and noted that nothing says whether a `changed` row with an existing task should reopen that task or wait for a new one at decompose.

## Acceptance criteria

- [ ] A revert leaves the reverted task's plan reading **not run** for every step the change affects, keeping the old pass lines as history
- [ ] `decide.md` states whether a `changed` row whose change is not built yet reverts its task to `verify` or leaves it for decompose, and why
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Committing the revert (TASK-307)

## Human test plan

- [ ] On a no-upstream fixture with a `done` feature whose task's plan is ticked, record a `changed` decision. Expected: the task reads `verify` and `/tasks close` on it does not reach `done` without a new pass.

## Implementation plan

_Populated by `/tasks plan TASK-319` — leave empty until then._
