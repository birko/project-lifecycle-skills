---
id: TASK-307
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-305-1]
pr: null
github-issue: null
jira-key: null
---

# `/feature decide` commits nothing, so a revert's task files and rollups stay uncommitted

## Context

Found by the correctness pass at TASK-305's close (2026-10-13). `skills/feature/verbs/decide.md` changes `decisions.md`, and for a surface-dependent revert (step 4) also `idea.md`, the reverted task files, their reopened parents, `status.md`, the index and now `tasks/README.md`. It never says to commit any of them. Line 44 mentions only reconciling "before committing". `/feature review` step 5b gained a commit step for the same reason (TASK-294), and an upstream record branch (TASK-296). `decide` has neither, so its record floats uncommitted in the working tree. With an upstream, it sits on the default branch, which must mirror the remote.

## Acceptance criteria

- [ ] `decide` commits exactly the files it wrote, under a subject that does not lead with a task id, with no upstream; and by the record-branch rule (`close.md` § *Closing a STORY / EPIC* step 5) with one
- [ ] Its confirmation names the commit, the pushed branch, or every file left uncommitted
- [ ] AGENTS.md's list of commit subjects that do not lead with a task id gains the new one
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- What a revert changes (TASK-303, TASK-305)

## Human test plan

- [ ] On a fixture with no upstream, record a `changed` decision on a `done` feature with a human-verifiable surface. Expected: one commit carries the ledger, the reverted task, its reopened story, the rollups and the dashboard, and the tree is clean.

## Implementation plan

_Populated by `/tasks plan TASK-307` — leave empty until then._
