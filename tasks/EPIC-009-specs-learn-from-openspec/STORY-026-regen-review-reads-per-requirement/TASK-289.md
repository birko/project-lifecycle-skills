---
id: TASK-289
parent: STORY-026
feature: FEATURE-004
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
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen` keeps a spec file's existing line endings

## Context

FEATURE-004 D6. On Windows a rewrite can turn an LF spec into CRLF, or the reverse, and the review then shows a whole-file diff. This repo already keeps a watch item about CRLF drift. OpenSpec v1.13.2 keeps a file's existing line endings when it rewrites a spec.

## Acceptance criteria

- [ ] `regen` step 5 writes with the line endings the existing file has, and writes a new file with the endings the repo declares in `.gitattributes`, where it declares any
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Normalising files already committed with mixed line endings

## Human test plan

- [ ] Drill: regenerate an area whose spec is checked out with CRLF endings. The diff shows only the changed requirement

## Implementation plan

_Populated by `/tasks plan TASK-289` — leave empty until then._
