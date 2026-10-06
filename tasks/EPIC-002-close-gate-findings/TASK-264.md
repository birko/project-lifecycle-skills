---
id: TASK-264
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [VC-062]
pr: null
github-issue: null
jira-key: null
---

# `feature prototype` decides whether it can publish from "the runtime", not from the session's tools

## Context

Found by `/verify-conventions` at TASK-077's close gate (2026-10-06), while it checked the instances of AGENTS.md's
new rule *A runtime-provided capability degrades the means or the delivery, never the pass*.

- **VC-062.** `skills/feature/verbs/prototype.md` (state-model playground bullet) says *"When the runtime can
  publish a file as a private shareable page, publish it and send the link."* `skills/improve-architecture/SKILL.md`
  § *Delivery* states the same capability and decides it from **the tools this session actually has, never from
  the runtime's name**, and treats a surface that cannot publish privately, or a publish that fails, as absent.
  Two skills phrasing one capability check two ways is how the weaker phrasing gets copied: "the runtime can" invites a
  guess from what a runtime usually offers.

## Acceptance criteria

- [ ] `prototype.md` decides publishing from the session's tool list, keeps it private, and says what happens when a publish fails (the file in the feature folder is still the output)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Anything else in `prototype.md`

## Human test plan

N/A: a one-sentence wording alignment. Its behaviour, the file being written either way, is unchanged; the lint and a read of the diff cover it.

## Implementation plan

_Populated by `/tasks plan TASK-264` — leave empty until then._
