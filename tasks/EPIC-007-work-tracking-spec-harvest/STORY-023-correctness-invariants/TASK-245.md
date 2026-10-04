---
id: TASK-245
parent: STORY-023
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
findings: [SH-72, SH-73, SH-74]
pr: null
github-issue: null
jira-key: null
---

# `verify-conventions` contradicts itself on the empty rulebook, drift severity, and where to register a pattern

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. All three are in `skills/verify-conventions/SKILL.md`.

- **SH-72 — the empty case.** § *What this skill does NOT do* says "No conventions written down → nothing to verify
  (and that's the finding)." But § *Finding the rulebook* says to "then run the smell baseline below", and the
  description promises "A project with no rulebook still gets a code-smell baseline".
- **SH-74 — register-on-introduce hard-codes one location.** Step 4's message is "…not recorded in CLAUDE.md §
  Conventions — add it…".
  - The rulebook ladder accepts `AGENTS.md`, `## Key Conventions`, a non-English heading, or rules woven through the
    guide.
  - The skill also says "Never suggest restructuring a guide to match the seed".
  - So in a repo whose rulebook lives elsewhere, the message points at a section that does not exist.
- **SH-73 — drift severity (partly).** Step 5 says "a stale architecture doc is a real defect, not
  stale-but-harmless". § Output format files architecture-doc drift under 💡 Suggestions. This is not a hard
  contradiction, since the skill never defines 💡 as "nice to have", but the two lines pull in opposite directions.

## Acceptance criteria

- [ ] The "does NOT do" list says a project with no conventions gets the none-recorded finding plus the smell baseline
- [ ] Step 4's message names the rulebook location step 2 found, not `CLAUDE.md` by default
- [ ] Step 5 and § Output format agree on architecture-doc drift's severity, or step 5 no longer calls it a real defect
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ask-steps without a question (TASK-247)

## Human test plan

N/A — rule text, checked by reading step 4's message against a guide whose rules live under `## Key Conventions`.

## Implementation plan

_Populated by `/tasks plan TASK-245` — leave empty until then._
