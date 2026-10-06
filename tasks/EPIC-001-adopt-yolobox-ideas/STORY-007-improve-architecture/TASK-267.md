---
id: TASK-267
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

# Whether a candidate "concerns one member" is a judgement, so two runs key one finding differently

## Context

Found while doing **TASK-266**, by its second two-run drill on one unchanged `ClientApi.CSharp` clone
(2026-10-06). Both cold readers raised the same class 2 candidate on
`Tester/DesktopFinstatApiTester/ViewModel/ResponseItem.cs`. One keyed it
`2:…/ResponseItem.cs#BasicResponse` and the other `2:…/ResponseItem.cs`.

`skills/improve-architecture/SKILL.md` Step 4 appends `#<member>` "whenever the candidate concerns one member
rather than the whole file". TASK-263 made that independent of what else a run finds in the file, but whether a
candidate concerns one member is still the reader's call. The key is what Step 1 and Step 5 match on, so the same
finding filed by one run reads as new to the next.

## Acceptance criteria

- [ ] Step 4 states a test for the member suffix that two readers apply the same way, using what the candidate's signal names (the member the gate judged, the event or dependency item 4 counted), not a reading of intent
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Reader recall: a candidate one reader finds and another misses
- Classes 1 and 4's set rule (TASK-266)

## Human test plan

- [ ] Two cold runs on one unchanged scratch clone key every candidate they both raise identically, including `ResponseItem.cs`'s

## Implementation plan

_Populated by `/tasks plan TASK-267` — leave empty until then._
