---
id: TASK-260
parent: STORY-024
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
findings: [SH-86]
pr: null
github-issue: null
jira-key: null
---

# `grill-me`'s description has no Slovak triggers and predates the skill it describes

## Context

Found by the `idea-interrogation` spec harvest (2026-10-06, TASK-080, EPIC-007 fourth pass) at `07de657`.

- **SH-86.** `skills/grill-me/SKILL.md`'s `description:` is the upstream one-liner:
  - It carries **no Slovak trigger phrases**, against AGENTS.md § *Framework / stack*: the description carries "the
    trigger phrases users actually type, including the Slovak ones this team uses". The descriptions of 12 other
    skills do.
  - It names no skill it should not be confused with. Here that is [[feature]] `new`, which invokes the grill but
    is not the grill.
  - It still describes the pre-TASK-117 skill: one question at a time, with no lookups.

## Acceptance criteria

- [ ] The description carries the Slovak trigger phrases the team uses for a grill, and says how the skill differs from `/feature new`
- [ ] It stays one line, uses no unquoted `: ` or ` #`, and stays within budget (AGENTS.md's pi frontmatter table)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The body's behaviour (TASK-258, TASK-259)

## Human test plan

N/A: a frontmatter wording change. The lint's check 1 covers whether it loads in pi, and the trigger phrases are checked by reading.

## Implementation plan

_Populated by `/tasks plan TASK-260` — leave empty until then._
