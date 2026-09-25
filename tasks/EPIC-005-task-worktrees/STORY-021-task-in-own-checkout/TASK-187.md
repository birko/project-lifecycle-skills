---
id: TASK-187
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: ai
created: 2026-09-24
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-F001-2, CR-F001-3, VC-F001-2]
pr: null
github-issue: null
jira-key: null
---

# The linked-worktree probe differs across verbs and gives a false positive from a subfolder; one report line is orphaned

## Context

Found by `/feature review FEATURE-001` Gate A (2026-09-24). The finding was raised by the cross-task seam and conventions passes over the feature's cumulative diff `f4b982e..HEAD`. Per the review verb, it is filed here rather than fixed at the gate.

- **CR-F001-2 / VC-F001-2, high.** `pick.md` step 6b and `triage.md` compare `git rev-parse --git-dir` with `--git-common-dir` as plain strings. `close.md` 4b uses `--path-format=absolute`. Measured with git 2.47.1: from `skills/` in the main copy, the two paths print as `C:/Source/project-lifecycle-skills/.git` and `../.git`. They differ, though this is not a linked worktree, so `pick` prints the wrong-tree line and stops, and every chained `triage` silently skips the dashboard.
- **CR-F001-3, medium.** `close.md`'s *held-elsewhere* report line (`close it from there; nothing was changed`) is now printed by no row: TASK-181 replaced that 4b row with "resume into it". Its instruction also contradicts the resume.

## Acceptance criteria

- [x] One probe, `--path-format=absolute` on both sides, at every site, stated once and pointed at from the others.
- [x] Run from a subfolder of the main copy, `pick` and `triage` do not report a linked worktree.
- [x] The orphaned held-elsewhere line is removed or re-pointed so that every report line has a row that prints it.

## Out of scope

- Nothing else.

## Human test plan

- [x] From a subfolder of a main copy with `workspace: worktree`, run `/tasks pick`. Expected: no wrong-tree line; the pick proceeds.

## Implementation plan

Written at the FEATURE-001 review gate; the fix follows the acceptance criteria one to one.

**Close gate (2026-09-24).** The human-test step comes down to the probe `pick` runs. Measured on this repo from `skills/`: the plain form prints `C:/…/.git` against `../.git` (a false positive), and the absolute form prints the same path twice. All three sites now use the absolute form, and `close` states both sides explicitly. The confirmation pass found it holding. `skills-lint` is OK.
