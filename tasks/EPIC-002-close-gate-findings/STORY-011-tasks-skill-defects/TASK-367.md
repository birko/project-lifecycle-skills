---
id: TASK-367
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-366-1, DRILL-366-2]
pr: null
github-issue: null
jira-key: null
---

# `block`'s uncommitted line and the generated files' project name leave their form to the reader

## Context

Filed 2026-11-13 at TASK-366's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d366`, `report.md`, § 3)
against d358 and d360. Both readings meet FEATURE-002 D10's two-runner bar.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-366-1 | `block`'s confirmation ends `uncommitted: <files>` (added by TASK-348). Whether paths are relative to the repo or to `tasks/`, and how they are separated, is unstated. Both runners chose repo-relative and comma-separated | d358, d366 |
| DRILL-366-2 | `{{PROJECT_NAME}}` is "the name of the directory containing `tasks/`" (`triage`), or containing `docs/` (`/feature status`). On a repo whose README or guide names the project differently ("Fixture CLI", "Ledger"), runners asked whether the folder name is really meant. Both generators already state the folder name, so the gap is the *why*, which is missing | d358, d360, d366 |

## Acceptance criteria

- [ ] `block` and `unblock` state the `uncommitted:` line's path form and separator
- [ ] `triage` and `/feature status` say why `{{PROJECT_NAME}}` is the folder name and not a title read from a file
      (`/feature status` already argues it: "a path any run derives the same way"), so a reader with a differently
      titled README does not re-decide it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Column padding and the timestamp: TASK-366 (done)

## Human test plan

- [ ] Re-run TASK-212's brief on a fresh copy of `d212/repo` with `skills/` at the fix, using a cold runner. Expected:
      neither DRILL-366-1 nor 2 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-367` — leave empty until then._
