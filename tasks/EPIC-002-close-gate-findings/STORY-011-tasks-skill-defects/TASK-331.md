---
id: TASK-331
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-318-1, DRILL-318-2, DRILL-318-3]
pr: null
github-issue: null
jira-key: null
---

# `/tasks new` marks a parent the user named as inferred, and `plan` can cut its own section short

## Context

Found by TASK-318's cold drill (2026-11-04, recorded on TASK-318). Three findings in `skills/tasks/verbs/new.md` and `plan.md`:

- **DRILL-318-1:** the request said "under STORY-001", in words, not as an argument. `new` steps 3 and 4 skip their question only when a caller set the value, so the runner put the parent question, took the no-answer path and wrote "inferred, not chosen: … parent" about a parent the user gave. The record now misstates who chose it.
- **DRILL-318-2:** `plan` step 6 replaces the `## Implementation plan` body with the plan agent's output. That output had `##` headings, which end the section early. The runner demoted them, which nothing licensed.
- **DRILL-318-3:** `new` step 13 and `plan` step 8 each print a confirmation ending "Start work with `/tasks pick`", with no stated order or merge.

## Acceptance criteria

- [ ] `new` says whether a value the user stated in the request counts as answered, and the inferred-values line names only fields nobody stated
- [ ] `plan` step 6 says what happens to headings in the agent's output at or above the section's level
- [ ] When `new` chains `plan`, one confirmation is printed, or the order of the two is stated
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [ ] Re-run the originating drill's brief (recorded on that task's Progress log) on a freshly built fixture with a cold runner. Expected: its "left undecided" section no longer lists these findings

## Implementation plan

_Populated by `/tasks plan TASK-331` — leave empty until then._
