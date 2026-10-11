---
id: TASK-296
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-11
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-294-2]
pr: null
github-issue: null
jira-key: null
---

# With an upstream, two gates leave their record uncommitted and nothing has measured where it goes next

## Context

Spawned by TASK-294's out-of-scope sweep (2026-10-11). It groups two instances of one open question, because
answering it once answers both.

On a project whose default branch tracks a remote, two gates write a record and deliberately commit nothing:
- a container close (`skills/tasks/verbs/close.md` § *Closing a STORY / EPIC*, step 5) names its flipped
  `STORY.md`/`EPIC.md` as uncommitted "for a person to land through an ordinary PR" — TASK-292's Outcome flagged
  this as unmeasured;
- `/feature review` (`skills/feature/verbs/review.md` step 5b, TASK-294) names its History lines, status change
  and rollup the same way.

Neither has been run on a repo with an upstream. Nothing says who opens that PR, or what keeps a later
close or review from finding the files and committing them by accident.

## Acceptance criteria

- [ ] Both gates are run on a fixture whose default branch tracks a bare local remote, and what happens to
      the named files afterwards is recorded
- [ ] Either the current "name them for a PR" rule is confirmed with that evidence, or both verbs gain one
      shared rule for where the record goes, stated once and pointed at from the other
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-upstream path, which commits the record — TASK-292 and TASK-294

## Human test plan

- [ ] On an upstream fixture, close a STORY and run `/feature review`, then run `/tasks pick` on another task.
      Expected: the report from each gate names its files, and the next verb neither commits them silently nor
      stops on them without saying why.

## Implementation plan

_Populated by `/tasks plan TASK-296` — leave empty until then._
