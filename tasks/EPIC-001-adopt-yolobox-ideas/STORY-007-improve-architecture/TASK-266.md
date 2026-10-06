---
id: TASK-266
parent: STORY-007
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Classes 1 and 4 both fire on co-change across modules, so one finding gets two different keys

## Context

Found while doing **TASK-265**, by its two parallel cold runs on one unchanged `ClientApi.CSharp` clone
(2026-10-06). The same co-changing files, the CLI testers' project files that share one build block, were raised
as **class 4** (leaky seam) by one run and **class 1** (concept scatter) by the other. The class is the first part of
the key (`<n>:<path>`), so the two runs' keys differ, and a later run cannot match the finding to an earlier one.

It is the third reader to hit this. TASK-076's drill reader and TASK-263's run 1 both listed it among their
guesses ("Class 1 versus class 4": raised class 1, rejected the class 4 versions as `signal fails`).

The overlap is in `skills/improve-architecture/SKILL.md` Step 4's table:
- **class 1** is "following one use case touches four or more files, each adding a few lines, and those files
  form co-change pairs";
- **class 4** is "a co-change pair that crosses a module boundary, or one module reading another's internals".

A set of four or more co-changing files across projects satisfies both, and nothing says which wins.

## Acceptance criteria

- [ ] Step 4 states which class a candidate takes when both signals hold, so one set of files always gets one class
- [ ] The rule is decidable from what Step 2 and Step 4 already collect, not a fresh judgement per run
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Reader recall: a candidate one cold reader finds and another misses. That is judgement, not a definition gap
- Rung 2's scope (TASK-265)

## Human test plan

- [ ] The re-drill TASK-265 is parked on (two cold runs, one unchanged clone) gives the testers' shared build files the same key in both runs

## Implementation plan

_Populated by `/tasks plan TASK-266` — leave empty until then._
