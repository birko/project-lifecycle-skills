---
id: TASK-334
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
findings: [DRILL-320-1]
pr: null
github-issue: null
jira-key: null
---

# `/feature status` templates leave a skipped prototype, the project name and the run mode undefined

## Context

Found by TASK-320's two-runner drill (2026-11-04, recorded on TASK-320), in `skills/feature/`. Both runners settled these the same way, but by guessing:

- `templates/status.md`'s `{{PROTOTYPE_LINK}}` covers a link, "none yet" and a deleted prototype, not an `idea.md` line reading `Skipped — …`.
- `templates/README.md.tmpl`'s `{{PROJECT_NAME}}` has no stated source (both used `README.md`'s H1).
- The index banner says "(all-features mode)" when a single-feature run renders it because it was absent.

## Acceptance criteria

- [ ] `{{PROTOTYPE_LINK}}` states how a Skipped (and N/A) prototype line renders, in `status.md` and in the index column
- [ ] `{{PROJECT_NAME}}`'s source is stated
- [ ] The banner is true for a single-feature run that renders the whole index
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [ ] Re-run the originating drill's brief (recorded on that task's Progress log) on a freshly built fixture with a cold runner. Expected: its "left undecided" section no longer lists these findings

## Implementation plan

_Populated by `/tasks plan TASK-334` — leave empty until then._
