---
id: TASK-280
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
findings: [SH-120, SH-121, SH-122]
pr: null
github-issue: null
jira-key: null
---

# `improve-architecture`: the item 4 gate maps no result, and a held move whose ADR is gone has no outcome

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-120 (partly confirmed):** `Item 4: <n> implementation(s) — <result>` maps to neither candidate nor rejected. interface-design item 4 implies the mapping (one implementation: collapse it; two or more, including a test double at a boundary: a real seam), but the skill never states it.
- **SH-121:** Step 1 skips superseded and retired records, but Step 6 recomputes every `held by ADR` entry. A held entry whose ADR has since been superseded or retired has no defined outcome.
- **SH-122 (partly confirmed):** class 5 maps to the `docs-i18n-coverage` theme with no stated reason, while interface-design calls its signal an interface defect. Arguable, not wrong, but fix-next ranks that theme last.

## Acceptance criteria

- [ ] Step 5 maps each item 4 result to candidate or rejected, as the deletion test's table does
- [ ] Step 6 states what happens to a held entry whose ADR is superseded or retired
- [ ] Step 7 states why class 5 takes its theme, or moves it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The records line (TASK-279)

## Human test plan

N/A: mapping tables, checked by reading against `skills/tdd/interface-design.md` item 4.

## Implementation plan

_Populated by `/tasks plan TASK-280` — leave empty until then._
