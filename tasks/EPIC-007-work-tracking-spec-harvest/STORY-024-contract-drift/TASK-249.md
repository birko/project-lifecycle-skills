---
id: TASK-249
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-64, SH-68]
pr: null
github-issue: null
jira-key: null
---

# The adopter's files cite rules a consumer does not have, and miscount their own buckets

## Context

Found by the project-baseline spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second
reader against the files at `adc4c27`.

- **SH-64 — citations that dangle in a consumer install (partly).**
  - `adopt-project/INFER.md` cites "AGENTS.md § *The five records*".
  - `new-project/LAYER.md` cites "`AGENTS.md` § *A template ships nothing a render cannot make true*".
  - In four more places, LAYER.md points at a rule "in the consuming project's guide" (derived state never cached;
    read the declaration, never infer it).

  No seed template carries any of these, so for a scaffolded repo "the consuming project's guide" is false. Every
  citing site still states its operative instruction inline, so nobody needs the cited rule to act. This is a reader
  trap, not a broken instruction.
- **SH-68 — count.** `adopt-project/SKILL.md` § 4 says "Three buckets for what this run **did**" and "the three
  above". The table has four: created, amended, left alone, regenerated.

## Acceptance criteria

- [ ] No citation in `skills/adopt-project/` or `skills/new-project/LAYER.md` sends a consumer to a guide section their install does not carry. Each one either names this skill set as its source or carries the one-clause rationale inline
- [ ] § 4's bucket count matches its table, or the count is dropped
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- LAYER.md's survey-state list and its stale TASK-112 pointer (TASK-085)

## Human test plan

N/A — reference and count text, checked by grepping both skills for `AGENTS.md` and "consuming project's guide".

## Implementation plan

_Populated by `/tasks plan TASK-249` — leave empty until then._
