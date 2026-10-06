---
id: TASK-276
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
findings: [SH-103, SH-104]
pr: null
github-issue: null
jira-key: null
---

# `handoff` has no trigger phrases, and never says where its document went

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-103:** `skills/handoff/SKILL.md:3`'s description has no trigger phrases, no Slovak ones and no "not to be confused with", against AGENTS.md § *Framework / stack*. The same shape as TASK-260 for `grill-me`.
- **SH-104:** `:7` says to save the document to the OS temp directory, but gives no file name and never says to tell the user the saved path. A handoff whose path nobody is told cannot be handed to the next session.

## Acceptance criteria

- [ ] The description carries the trigger phrases users type, including Slovak ones, and names the skill it should not be confused with, within AGENTS.md's pi frontmatter rules
- [ ] The skill names its file and tells the user the saved path
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The refuted points about its suggested-skills section, its no-argument default and redaction markers (dropped at intake)

## Human test plan

N/A: frontmatter and one instruction, checked by the lint and by reading.

## Implementation plan

_Populated by `/tasks plan TASK-276` — leave empty until then._
