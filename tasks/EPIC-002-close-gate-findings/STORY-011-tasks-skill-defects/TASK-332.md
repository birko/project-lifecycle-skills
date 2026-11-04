---
id: TASK-332
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-212-1, DRILL-212-2]
pr: null
github-issue: null
jira-key: null
---

# `/tasks block` leaves where its two writes go, and their order, to the reader

## Context

Found by TASK-212's cold drill (2026-11-04, recorded on TASK-212), in `skills/tasks/verbs/block.md`:

- **DRILL-212-1:** `blocked:` goes "after the `status:` line and every indented `#` line continuing its comment". But the template's next line is the unindented `# blocked: <reason> — set by /tasks block …` comment, so above or below it reads both ways. "Append a body note" names no place; the runner put it after `## Implementation plan`, where it reads as part of the plan.
- **DRILL-212-2:** step 4 writes `blocked: <reason>`, but step 5 is where the reason is settled when `--reason` is absent.

## Acceptance criteria

- [ ] `block` states where `blocked:` goes relative to the template's `# blocked:` comment line
- [ ] It states where in the body the `> Blocked …` note goes
- [ ] The reason is settled before the step that writes it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [ ] Re-run the originating drill's brief (recorded on that task's Progress log) on a freshly built fixture with a cold runner. Expected: its "left undecided" section no longer lists these findings

## Implementation plan

_Populated by `/tasks plan TASK-332` — leave empty until then._
