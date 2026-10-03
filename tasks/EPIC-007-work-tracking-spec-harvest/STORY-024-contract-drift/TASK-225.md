---
id: TASK-225
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
findings: [SH-2, SH-13]
pr: null
github-issue: null
jira-key: null
---

# Two sentences still describe the task states before FEATURE-003

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). FEATURE-003 made `blocked` a flag and renamed the
task status `review` to `verify`; these two sentences were missed by its sweeps (TASK-213, TASK-219).

- **SH-2 — `tasks/SKILL.md` § Conventions, "The merge is part of done":** the alternative to merging is "a captured
  deferral reason in `## Out of scope`". `close` steps 5c and 6 now record a deferred merge as `in-progress` with a
  `blocked:` field.
- **SH-13 — `triage.md` step 3b:** "Omit the whole section when no task is in `review`", and the
  template placeholder is still named `{{TK_REVIEW}}` — the task status is `verify` (the old form still reads the
  same).

## Acceptance criteria

- [ ] § Conventions describes a deferred merge as `close` records it
- [ ] Step 3b's omission rule speaks of tasks awaiting verification; the placeholder's name follows if it is renamed
      in both `triage.md` and `templates/README.md.tmpl` together
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature's own `review` phase and gate

## Human test plan

N/A — wording, checked by reading against `close` and the reading table.

## Implementation plan

_Populated by `/tasks plan TASK-225` — leave empty until then._
