---
id: TASK-179
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: human
created: 2026-09-24
depends-on: [TASK-175, TASK-176, TASK-177, TASK-181]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# End-to-end drill: pick → work → close in a worktree on a real consumer

## Context

FEATURE-001 D1 treats the worktree as a first-class workspace. The per-task human test plans exercise
each verb; this drill runs the whole loop once, cold, on a real `pr-per-task` project — which this repo
is not (it declares `integration: single-branch`, so the path is unreachable here).

Obtain the runner per `skills/populate-tests/SKILL.md` § *Acquiring a cold runner* — a subagent is never
cold in this environment, because these skills are installed at user level — and record the command,
working directory and coldness check (AGENTS.md § Testing).

## Acceptance criteria

- [ ] Drill run and recorded on this task: runner, cwd, coldness check, brief, outcome.
- [ ] One run covers: undeclared root → question asked; worktree created outside the repo; move proved; a second task picked while the first is open (the parallelism D1 claims); close merges, removes, deletes; main copy on the default branch throughout.
- [ ] Every defect found is filed as its own task (`/tasks spawn`), not fixed inside this one.

## Out of scope

- Fixing what the drill finds.

## Human test plan

- [ ] Brief (withholding expected outcomes): "On <consumer>, declare `workspace: worktree`, pick task A, make a small change and commit it, pick task B, close task A." Expected, kept here and not in the brief: A gets its own folder outside the repo; B gets another; closing A merges it into the default branch in the main copy and removes A's folder and branch; B's worktree is untouched.

## Implementation plan

_Populated by `/tasks plan TASK-179` — leave empty until then._
