---
id: TASK-182
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: ai
created: 2026-09-24
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-174-1]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` step 7's two questions carry no wording and no answer-less path

## Context

Found by TASK-174's drill on 2026-09-24. Three `claude -p` runners ran `skills/tasks/verbs/pick.md`
unattended on `pr-per-task` fixtures. All three reached step 7 and met two ask-steps. Neither is quoted
verbatim, and neither says what happens when nobody answers. Both break AGENTS.md § Output/prose rules:
*an ask-step carries the question it puts and the answer-less path, or it is not a step*. The two are:

- *"offer to cut `task/TASK-NNN` so the work is isolated"*. One runner cut the branch and reported *"that
  was my decision, not the verb's"*. With no rule, another runner is equally entitled to skip the cut
  and work on the default branch, which on a `pr-per-task` project is exactly what that model forbids.
- *"ask whether to fill `pr:` now"*. All three left it null, but by inference, not instruction.

This predates FEATURE-001 and is unrelated to its change. Step 6b, which that feature added, is
compliant and was not touched.

## Acceptance criteria

- [ ] Both step-7 questions are quoted verbatim in `pick.md`.
- [ ] Each has a stated answer-less path. For the branch offer, the path is read off `integration:`. Under `pr-per-task`, with nobody to ask, the branch is cut and the report says the cut was the documented default and nobody chose it. A run that works on the default branch under a policy forbidding it is the one outcome ruled out. For `pr:`, it stays null and `close` asks later.
- [ ] A drill with two unattended runners gives the same outcome and the same report line from both.

## Out of scope

- Step 6b — FEATURE-001 (TASK-174/175).

## Human test plan

- [ ] Two cold runners each run `/tasks pick` unattended on a `pr-per-task` fixture with no `workspace:`. Expected: both cut `task/TASK-NNN`, leave `pr:` null, and print the same line saying the cut was the documented default. The brief withholds the expected outcome.

## Implementation plan

_Populated by `/tasks plan TASK-182` — leave empty until then._
