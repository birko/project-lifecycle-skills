---
id: TASK-316
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-DD-1]
pr: null
github-issue: null
jira-key: null
---

# fix-next's tie scenario never states what happens when nobody answers

## Context

Raised by the spec harvest of defect-draining (2026-10-13). `skills/fix-next/SKILL.md` step 2 states the tie question and its answer-less path (take the lower id, log that nobody chose). The harvested scenario *Keys exhausted* says the run "stops to ask which to take" and never states the unattended outcome, which the source does define. The harvester kept it verbatim under the stable-wording rule; the gap is that the source's own example of the tie reads as a halt.

## Acceptance criteria

- [ ] The source states the tie's unattended outcome where it describes the tie, so a regenerated scenario carries it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ranking keys themselves

## Human test plan

N/A — wording only; fix-next's tie path is unchanged.

## Implementation plan

_Populated by `/tasks plan TASK-316` — leave empty until then._
