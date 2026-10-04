---
id: TASK-251
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
findings: [SH-80, SH-81]
pr: null
github-issue: null
jira-key: null
---

# `review-comments` miscounts its PATH rules and offers a range it has no syntax for

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. Both are in `skills/review-comments/SKILL.md`.

- **SH-81 — count.** Step 2's PATH paragraph says "Four rules, and each one is a question…", and five bullets follow.
  The section's stated purpose is that two readers behave identically, which a wrong count works against.
- **SH-80 — a range with no form (partly).** Step 2 says "use a branch or PR range only if the user names one".
  - § Invocation offers the default, `PATH …`, `--all` and `--batch`, and every positional token is a PATH. So
    `/review-comments main..HEAD` is read as a path.
  - The report's "three scopes" header has no rendering for a range run.
  - A range can still be named in plain language.

## Acceptance criteria

- [ ] The rule count matches the bullets, or is dropped
- [ ] A range has a defined form (a flag, or a stated conversational-only rule) and a Scope-line rendering, and `a..b` is not read as a PATH
- [ ] `bash .github/workflows/skills-lint.sh` passes, including check 4 if a flag is added

## Out of scope

- Ranges in `verify-conventions` and `verify-intent`, which have no PATH positional for a range to collide with

## Human test plan

N/A — invocation text, checked by parsing `/review-comments main..HEAD` and `/review-comments src/` by hand against § Invocation.

## Implementation plan

_Populated by `/tasks plan TASK-251` — leave empty until then._
