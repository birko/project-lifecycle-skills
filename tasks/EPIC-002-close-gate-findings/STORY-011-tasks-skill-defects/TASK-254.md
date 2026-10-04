---
id: TASK-254
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-193-1]
pr: null
github-issue: null
jira-key: null
---

# `pick`'s in-place fallback with an upstream never says where the status flip is committed

## Context

Found by TASK-193's cold drill (2026-10-04). The runner answered the question it was set correctly, then noted
in passing: *"The spec doesn't say exactly where an in-place upstream flip is committed, but 'nothing is
committed on the local default branch' settles that it must be the task branch."*

`skills/tasks/verbs/pick.md` step 6b: **"A fallback with an upstream** follows the in-place pick in step 7
(status flip, branch cut) and then runs `git push -u <remote> task/TASK-NNN`". Step 7 flips the status with an
edit and cuts the branch, and commits nothing. So the flip is an **uncommitted** edit carried onto the task branch,
and it first lands in a commit at `close`. That works, because the pushed branch, not the status line, is the taken
signal (FEATURE-001 D25). But a reader has to derive it, and the no-upstream path commits its pick explicitly
(`TASK-NNN: pick`), so the asymmetry reads like an omission.

Not linked to FEATURE-001: it changes no decided behaviour (D23, D25), only says what the text already implies.
If the fix changes behaviour (for example, committing the pick on the task branch before the push), it becomes a
`changed` decision on FEATURE-001 and the link is added then.

## Acceptance criteria

- [ ] Step 6b's upstream fallback says where the status flip lives after the push: an uncommitted edit until `close`, or a `TASK-NNN: pick` commit on the task branch, whichever is chosen
- [ ] If the choice changes behaviour, FEATURE-001's ledger records it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The worktree path, which commits its pick explicitly
- Naming (TASK-193)

## Human test plan

N/A — wording. If behaviour changes, a drill of the fallback (a `-p` runner always takes it; see the cold-runner notes) replaces this line.

## Implementation plan

_Populated by `/tasks plan TASK-254` — leave empty until then._
