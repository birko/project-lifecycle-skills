---
id: TASK-253
parent: STORY-015
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-04
depends-on: [TASK-252]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/tasks close` trusts a local test run where the project's CI runs elsewhere

## Context

Spawned from TASK-252. CI on Linux was red for two weeks while every `/tasks close` here passed the lint under Git
Bash. TASK-252 fixed the cause (a CR byte that let CRLF into `skills-lint.sh`) and added lint check 8, so **that
cause** cannot recur unseen. **The class can:** any difference between the machine running `close` and the CI
runner (GNU vs BSD tools, a missing binary, a path or locale difference) still passes locally and fails only in CI,
where nobody looks.

This is a change to `close`'s gate behaviour for every consumer, not to this repo's lint, which is why it is not
part of TASK-252. The likely shape: where the project has CI and a CLI to read it (`gh run list`), `close` reports
the default branch's last CI result beside the local tests, and a red CI is surfaced, not silently outranked by a
green local run.

## Acceptance criteria

- [ ] `close` says whether the project's CI result for the default branch was read, and what it was. Where it cannot be read (no CI, no CLI, offline), it says so — never silence
- [ ] A red CI on the default branch is reported at the gate as its own line, distinct from the local test result
- [ ] Whether a red CI holds the merge or only warns is decided and recorded, and the flag rules (`--unattended`) cover it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- This repo's own lint (TASK-252)
- Waiting for a CI run triggered by the close's own push. Reading the last completed run is enough to catch a gate that has been red for days

## Human test plan

- [ ] On a fixture repo whose last CI run on the default branch failed, run `/tasks close` on a task whose local tests pass. Expected: the red CI is named at the gate

## Implementation plan

_Populated by `/tasks plan TASK-253` — leave empty until then._
