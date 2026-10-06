---
id: TASK-265
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

# Rung 2 does not say whether a candidate outside the hot spots is raised, so two runs of one repo differ

## Context

Found while doing **TASK-263**, by its two cold runs on one `ClientApi.CSharp` clone (2026-10-06). Step 3's rung 2
scopes a run to "the hot spots from Step 2, examined first". Three cold readers read that three ways:

- **TASK-077's reader** read "first" as not exclusive, followed the co-change pairs outward, and found a class 1
  candidate (the CLI tester project files' shared build block) outside every hot spot.
- **TASK-263's run 1** did the same ("then repo-wide co-change pairs and fix landings") and raised that candidate.
- **TASK-263's run 2**, on the same repo with no change to those files, examined only the five hot spots, and did
  not raise it.

So one repo, scanned twice, produces different candidate lists, and the difference has nothing to do with the
code. Step 2 measures co-change pairs and fix landings over the whole repo whatever the rung, which makes the
"examined first" reading plausible; the word "first" implies a second, which the step never names.

## Acceptance criteria

- [ ] Rung 2 states whether candidates outside the hot spots are raised, and if they are, in what order they are reported relative to those inside
- [ ] The rung's header line in the report says which reading applied, so a reader can tell a hot-spot-only run from a wider one
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Rungs 1 and 3, which are unambiguous
- The candidate key and the re-check (TASK-263)

## Human test plan

- [ ] Two cold runs on one unchanged scratch clone produce the same candidate keys, including any candidate outside the hot spots

## Implementation plan

_Populated by `/tasks plan TASK-265` — leave empty until then._
