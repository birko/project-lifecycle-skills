---
id: TASK-384
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-15
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-020]
pr: null
github-issue: null
jira-key: null
---

# A line opening with inline triple-backtick code fails the lint as an unbalanced fence

## Context

Found 2026-11-15 while reading OpenSpec v1.16.0's notes for FEATURE-004: OpenSpec fixed a parser that took a line
starting with inline triple-backtick code (```` ```npm test``` ````) for an opening code fence. Ours has the same
reading. `skills-lint.sh`'s `strip_noise` opens a fence on any line starting with three or more backticks or tildes,
so a fixture skill whose body line is ```` ```npm test``` runs the suite. ```` fails the run with *has an unbalanced
code fence — the rest of the file cannot be checked*. Verified 2026-11-15 on a throwaway fixture.

Ours fails loudly rather than hiding the rest of the file, as OpenSpec's did, so nothing passes that should fail. It
is a false alarm: a correct skill is refused, and the message sends the author looking for a fence that is not there.

## Acceptance criteria

- [ ] A line whose backtick run is closed by a matching run later on the same line is read as inline code, not a fence
- [ ] A real unbalanced fence still fails the run (the existing `[2] unbalanced code fence` case stays green)
- [ ] A new `skills-lint-test.sh` case, labelled with its check, fails without the change
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` pass

## Out of scope

- Fence handling in the spec-file check FEATURE-004's TASK-290 adds; it should reuse whatever this settles

## Human test plan

- N/A — fully covered by the lint test case: the behaviour is a parser's verdict on a fixture, which a machine
  checks exactly and a person adds nothing to

## Implementation plan

_Populated by `/tasks plan TASK-384` — leave empty until then._
