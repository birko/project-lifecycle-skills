---
id: TASK-279
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-118, SH-119, SH-123]
pr: null
github-issue: null
jira-key: null
---

# `improve-architecture`'s records line cannot say what happened when filing fails or nothing is found

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-118:** `skills/improve-architecture/SKILL.md`'s records-line templates (the page header and stdout) give two forms. Step 7 adds a third ("not filed — no task tree; …") that neither lists, and "not filed yet — this report is the only copy" is unreachable, because Step 7 files before the report is written.
- **SH-119:** a failed or partial `/tasks intake` has no defined outcome; the unused "not filed yet" form is its natural home.
- **SH-123 (weak):** a run with no candidate and no rejection: intake's "write it `done`" sits inside its dropped-finding bullet, so this run's epic status is covered only by extension.

## Acceptance criteria

- [ ] The records line has one list of forms, used by both the page and stdout, covering filed, no task tree, intake failed (with what was and was not filed) and nothing to file
- [ ] An intake that fails part-way has a stated outcome
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The gate and decision-record outcomes (TASK-280)

## Human test plan

N/A: report wording, checked by reading Step 7 against both templates.

## Implementation plan

_Populated by `/tasks plan TASK-279` — leave empty until then._
