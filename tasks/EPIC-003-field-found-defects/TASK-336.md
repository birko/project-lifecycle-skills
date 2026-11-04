---
id: TASK-336
parent: EPIC-003
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
findings: [DRILL-321-1, DRILL-321-2]
pr: null
github-issue: null
jira-key: null
---

# `/feature pick` has no rule for an idea.md with no open-questions section, and words gate D's question twice

## Context

Found by the TASK-321 and TASK-323 drills (2026-11-04). Both runners hit both findings independently.

- **DRILL-321-1:** `skills/feature/questions.md` and `verbs/pick.md` step 3b cover a current table, a pre-table section and a section kept by choice. They do not cover an `idea.md` with **no** `## Open questions` section, which every feature created before the table existed has. Both runners passed gate Q as "no open rows" and made up their own step-6 open-questions line.
- **DRILL-321-2:** gate D's question is worded twice: the gate table's "N approved or changed decision(s) have no tasks. Decompose now? [Y/n]" and step 4's list ending "Decompose these 2 decisions into tasks now? [Y/n]". Step 4's form renders "these 1 decisions".

## Acceptance criteria

- [ ] An `idea.md` with no open-questions section has a stated reading at gate Q and a stated step-6 line
- [ ] Gate D's question is worded once, and reads correctly for one row
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [ ] Re-run TASK-321's drill brief (on its Progress log) on a fresh fixture with a cold runner. Expected: neither finding appears in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-336` — leave empty until then._
