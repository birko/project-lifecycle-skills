---
id: TASK-272
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
findings: [SH-87]
pr: null
github-issue: null
jira-key: null
---

# `/populate-tests survey` promises no edits, but chains `adopt`, which writes files

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-87:** `skills/populate-tests/SKILL.md:41-42` says **survey** makes "No edits". Lines 39-40 have survey and populate call `adopt` first when no harness is found, and `adopt` scaffolds a test directory, a runner config and a pinned dev dependency (`:34`). A bare `/populate-tests` defaults to survey (`:31`), so the read-only default can write files into a repo with no harness.

## Acceptance criteria

- [ ] `survey` either makes no edits in every case (it reports "no harness — run `/populate-tests adopt`" instead of chaining adopt), or its description says it may scaffold a harness first; the two lines no longer contradict
- [ ] A bare `/populate-tests` on a repo with no harness does what the chosen wording says
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Whether `adopt` reconciles an existing harness (TASK-024)

## Human test plan

- [ ] Run `/populate-tests` with no verb in a scratch repo that has no test harness, and confirm the files it writes, if any, match what `survey` promises

## Implementation plan

_Populated by `/tasks plan TASK-272` — leave empty until then._
