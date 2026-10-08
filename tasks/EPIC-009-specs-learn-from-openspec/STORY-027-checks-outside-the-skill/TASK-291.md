---
id: TASK-291
parent: STORY-027
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

# A weekly workflow opens one labelled issue per new OpenSpec release

## Context

FEATURE-004 D7 and D10. The owner asked for a GitHub watcher on OpenSpec, and chose a plain issue, labelled `upstream: openspec` and assigned to nobody, over auto-assigning Copilot or using a Claude routine. Releases are read from `Fission-AI/OpenSpec`; v1.14.1 was the latest on 2026-10-08.

## Acceptance criteria

- [ ] A scheduled workflow under `.github/workflows/` runs weekly, and on manual dispatch, and opens one issue per OpenSpec release not yet seen, with the release name, date, link and notes
- [ ] Each issue carries the label `upstream: openspec`, which the workflow creates if it is missing, and is assigned to nobody
- [ ] A release is never filed twice: the workflow finds the releases already seen from existing labelled issues, not from stored state
- [ ] The first run does not file the whole release history; it starts from the newest release, or from a declared starting version
- [ ] The workflow needs no secret beyond the default token, and its permissions are limited to issues
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Acting on a release: assigning the issue to Copilot was declined (D10)

## Human test plan

- [ ] Run the workflow by manual dispatch on the real repo. Exactly one issue appears, for the newest release, with the label; a second run files nothing

## Implementation plan

_Populated by `/tasks plan TASK-291` — leave empty until then._
