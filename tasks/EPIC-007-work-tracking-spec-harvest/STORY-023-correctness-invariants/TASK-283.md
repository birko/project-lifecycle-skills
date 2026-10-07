---
id: TASK-283
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
created: 2026-10-07
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-272-1]
pr: null
github-issue: null
jira-key: null
---

# `/populate-tests verify` and `ledger` never say what they do when there is no harness

## Context

Spawned from TASK-272's correctness review (2026-10-07). TASK-272 made `survey` read-only in every case and named
`populate` as the only mode that chains `adopt` (`skills/populate-tests/SKILL.md`, the adopt and survey bullets).
`verify` and `ledger` say nothing about a repo with no harness, and they never did. Now that one mode is named
as falling back to `adopt`, a reader can take the silence either way: that `verify` scaffolds a harness too, or
that it runs nothing and reports success.

## Acceptance criteria

- [ ] `verify` states what it does with no harness found (using the test REFERENCE.md § Adopt uses), and never reports a pass over a suite that does not exist
- [ ] `ledger` states the same
- [ ] `docs/specs/test-authoring.md` is regenerated for the change
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `survey` and `populate` (TASK-272)

## Human test plan

- [ ] From a cold runner, run `/populate-tests verify` in a scratch repo with no harness, and confirm the files it writes and the result it reports match what the skill now says

## Implementation plan

_Populated by `/tasks plan TASK-283` — leave empty until then._
