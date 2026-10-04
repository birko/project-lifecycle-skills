---
id: TASK-246
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
findings: [SH-75, SH-77, SH-78]
pr: null
github-issue: null
jira-key: null
---

# `verify-intent` never maps its classes to severities, and leaves "which task" open

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. All three are in `skills/verify-intent/SKILL.md`.

- **SH-75 — no class-to-severity mapping.** § *The three classes* defines Missing, Wrong and Scope creep with no
  severity.
  - The only mapping is the sample in § Output format: 🛑 Missing, ⚠ Wrong, 💡 Scope creep.
  - § Intent calls implementing a `removed`/`deferred` decision "scope creep of the worst kind", which that mapping
    ranks lowest.
  - § Related skills says "same severities" as `verify-conventions`, but that skill grades by how hard the rule is,
    not by class.
- **SH-77 — several tasks in progress.** The intent table's row "Nothing, but a task is in progress → that task's
  criteria — name which task you picked" says nothing about several in-progress tasks, which is normal under
  parallel worktrees.
- **SH-78 — the sample breaks its own rule.** The class table requires "the `file:line` where the implementation
  *should* have gone". The sample Missing finding gives "expected at skills/verify-intent/SKILL.md § What it reads",
  which is a section, not a line.

## Acceptance criteria

- [ ] The class table states each class's severity, and a scope-creep finding that implements a removed or deferred decision is not 💡
- [ ] "Same severities" is either defined or dropped
- [ ] The intent table says how the task is chosen when more than one is in progress, including the answer-less outcome
- [ ] The sample Missing finding gives a `file:line`
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-task ask-step's question wording (TASK-247)

## Human test plan

N/A — rule text, checked by classifying an invented diff with one finding of each class.

## Implementation plan

_Populated by `/tasks plan TASK-246` — leave empty until then._
