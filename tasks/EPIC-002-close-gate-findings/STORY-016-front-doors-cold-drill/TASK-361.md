---
id: TASK-361
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-360-1]
pr: null
github-issue: null
jira-key: null
---

# `/specs init` inside an adoption cannot see the files the same run wrote

## Context

Filed 2026-11-13 from a cross-drill comparison. Three cold full-adoption runners hit it, each from a different side:

| Drill (under `%LOCALAPPDATA%/Temp/`) | What the runner saw |
|---|---|
| `d102b` (point 11) | "the scan is **every file git tracks**". Nothing this run wrote was committed, so the scan saw only the original 7 files |
| `d360` (point 15) | the same: 5 tracked files, while the run had created the guide, `tasks/`, `docs/` and more |
| `d072/a` (point 9) | files created after `specs init` (`pytest.ini`, `CHANGELOG.md`) are not in the map's `ignore` list, and will show as unmapped once committed |

**The mechanism.** `/specs init`'s scan universe is the tracked files, which is right in general and keeps a
working copy's junk out. An adoption chains `specs init` in the middle of a run that writes files and commits
nothing until its closing offer. So the map is built over a repo that no longer exists, and the first commit makes
it report drift that the same run created. Whatever this run created is either unmapped or never considered for
`ignore`.

## Acceptance criteria

- [ ] What `specs init` scans when chained from an adoption is stated. Options include the tracked files plus the
      paths this run created, or running `specs init` after every other fill, or reporting the gap explicitly as
      part of its `coverage:` verdict
- [ ] Layer files the adoption itself creates (the guide, `tasks/`, `docs/`, `CHANGELOG.md`, the harness) do not
      show up as unmapped drift on the first commit, or the report says that they will and why
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `specs init`'s scan rule outside an adoption: the tracked-files universe is settled (TASK-033)

## Human test plan

- [ ] Run a cold full adoption of a fresh copy of `%LOCALAPPDATA%/Temp/d065/adopted`, then commit everything it
      wrote and run `/specs verify`. Expected: no unmapped drift caused by the adoption's own files, or a report
      line the adoption printed naming them in advance

## Implementation plan

_Populated by `/tasks plan TASK-361` — leave empty until then._
