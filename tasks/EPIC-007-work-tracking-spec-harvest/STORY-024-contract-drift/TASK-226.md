---
id: TASK-226
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-8, SH-9, SH-10]
pr: null
github-issue: null
jira-key: null
---

# Three references point at things that do not exist

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). Each sends a reader to something absent.

- **SH-8 — `move.md` step 5** cites "`verbs/close.md` step 7's note and TASK-036" for the anchored-`parent:`
  hazard. `close` step 7 has no such note — the warning lives in `specs` regen — and TASK-036 is this repo's own
  task id, which does not exist in a consumer's install.
- **SH-9 — `show.md`'s STORY view** prints "owner", but the STORY template has no `owner` field (only the EPIC
  template does).
- **SH-10 — `export.md` step 5** warns that a `# labels:` comment line can be mistaken for the title. The TASK
  template carries no `# labels:` comment — only the status, blocked and findings comments.

## Acceptance criteria

- [ ] `move.md` points at where the hazard is actually stated, or states it itself, with no repo-local task id
- [ ] `show`'s STORY view lists only fields a story has
- [ ] `export`'s warning names the comment lines the template actually emits
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other references to this repo's records — TASK-210's classification sweep

## Human test plan

N/A — references, checked by following each to its target.

## Implementation plan

_Populated by `/tasks plan TASK-226` — leave empty until then._
