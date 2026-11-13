---
id: TASK-364
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-363-1, DRILL-363-2]
pr: null
github-issue: null
jira-key: null
---

# Two rules set today meet at the `## Commands` offer and at a runner's `.gitignore` line

## Context

Filed 2026-11-13 at TASK-363's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d363`, `report.md`, § 7)
against the session's other drills. Both readings sit where two rules made today meet, and both now meet FEATURE-002
D10's two-runner bar.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-363-1 | TASK-102 puts every foreseeable offer in step 2's round, and TASK-354 renders `## Commands` after every fill. So the round offers a section whose content cannot exist yet. Runners gave it its own letter rendered from step-1 evidence, folded it into the guide-section offer, or noted the conflict. Related: whether a runner config (`pytest.ini`) counts as a source for the `## Commands` token, which names CI and manifests only | d357, d362, d363 |
| DRILL-363-2 | a test runner's output directory (`.pytest_cache/`) is arguably foreseeable at step 1, since step 1 already knows the stack and that the harness is missing. Adopt's exception still names `populate-tests`' `.gitignore` lines as found after the round. Both runners followed the named example and said it read oddly | d361, d363 |

## Acceptance criteria

- [ ] The guide-section offer states how `## Commands` is offered when its content is rendered after the round:
      offered by name only, with content rendered later; or offered with the content step 1 can see, marked as a
      preview; or another stated form. The `## Commands` token's source column says whether a runner config counts
- [ ] Whether a runner's ignore lines are foreseeable at step 1 is stated, and adopt's "found after the round" example
      agrees with it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where fill offers go in general: TASK-102 (done)

## Human test plan

- [ ] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      neither DRILL-363-1 nor 2 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-364` — leave empty until then._
