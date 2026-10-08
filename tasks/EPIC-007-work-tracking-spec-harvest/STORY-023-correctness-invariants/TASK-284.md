---
id: TASK-284
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-273]
pr: null
github-issue: null
jira-key: null
---

# `fix-next` step 0 cannot see a `close` interrupted between its status write and its commit

## Context

Found by the correctness pass at TASK-227's close gate (2026-10-08).

- **CR-273.** `/tasks close` step 6 writes the task's new `status:` (`done`, `verify`, or `in-progress` plus a
  `blocked:` field), and step 7 commits it. A session reset between the two leaves the task file reading the new
  status, **uncommitted**. `skills/fix-next/SKILL.md` step 0 finds in-flight runs only by `status: in-progress`
  (and, under `workspace: worktree`, by branch copies reading `in-progress`). So a file reading an uncommitted
  `done` is invisible to it. The next `/fix-next` picks a second task on top of a dirty tree, and the first task's
  work is never committed. That breaks *one task in-progress at a time*, and the reset contract
  (§ *Verify the reset really is safe*).
- If step 0 did find it, `close` step 4 under `--unattended` refuses an already-`done` task, so a re-close would
  stop too. Whether that refusal should tell an uncommitted `done` from a committed one is part of this task.
- TASK-227 made step 8 judge completion from `status:` plus git. This is the one interruption point where
  `status:` alone says the close happened when git says it did not.

## Acceptance criteria

- [ ] `/fix-next` step 0 detects a skill-owned task whose `status:` change is uncommitted (the task file is
      modified against `HEAD`, and its log ends at step 8), and resumes it instead of picking new work
- [ ] The resume completes the close (commit, plus the merge where one applies) without `close` step 4 refusing
      it as already `done`, or the task says which verb owns that path
- [ ] Holds in `single-branch`, PR-per-task and `workspace: worktree` projects
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- How `close` orders its own steps 6 and 7. The ordering is deliberate (`close.md` step 6, *Ordering rationale*)

## Human test plan

- [ ] Drill: on a `single-branch` fixture, stage the state by hand (task file at `status: done` with step 8's line
      last, uncommitted), then run `/fix-next`. It resumes that task and ends with a clean tree; it does not pick
      another

## Implementation plan

_Populated by `/tasks plan TASK-284` — leave empty until then._
