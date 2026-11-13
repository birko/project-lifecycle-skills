---
id: TASK-366
parent: STORY-011
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
findings: [DRILL-358-1, DRILL-358-2]
pr: null
github-issue: null
jira-key: null
---

# The dashboard template leaves its column padding and its timestamp's time zone to the reader

## Context

Filed 2026-11-13 at TASK-358's close. Two cold runners rendered `tasks/README.md` through `/tasks block` → `triage`
on fresh copies of `d212/repo`: `%LOCALAPPDATA%/Temp/d348b` and `d358`, with reports kept there. Both raised these,
which meets FEATURE-002 D10's bar. Each was recorded as one-runner on TASK-348 before the second report existed.

- **DRILL-358-1 — column padding.** `templates/README.md.tmpl` pads its counts table for the width of the placeholder
  names (`| planned      | {{EP_PLANNED}}     |`). Nothing says whether to re-pad once the values are filled, so both
  runners left the columns ragged. (The bare `/tasks` snapshot settled the same question for itself in TASK-355:
  fields are never padded into columns.)
- **DRILL-358-2 — the timestamp's time zone.** `{{TIMESTAMP}}` is "current date/time, e.g. `2026-05-28 14:32`", with
  no zone. Both runners used local time from `date`, and neither could say whether that was intended.

## Acceptance criteria

- [ ] `triage` states whether the counts table is re-padded after filling, consistent with or explicitly different
      from the snapshot's TASK-355 rule
- [ ] `triage` states the timestamp's time zone (local, UTC, or with an offset), and `/feature status`'s index, which
      reuses the format, agrees
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Blank lines and tree-row fields: TASK-358 (done)

## Human test plan

- [ ] Re-run TASK-212's brief on a fresh copy of `d212/repo` with `skills/` at the fix, using a cold runner. Expected:
      neither DRILL-358-1 nor 2 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-366` — leave empty until then._
