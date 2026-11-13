---
id: TASK-369
parent: STORY-013
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
findings: [DRILL-032-1, DRILL-032-2]
pr: null
github-issue: null
jira-key: null
---

# DV10's "could not decide" has no output line, and triage's summary has no singular

## Context

Filed 2026-11-13 at TASK-032's close. Two cold runners ran `/roadmap --check` and then `/tasks triage` on one
two-epic fixture (`%LOCALAPPDATA%/Temp/d032` and `d032b`, reports kept there). Both raised these two, which predate
TASK-032 and meet FEATURE-002 D10's bar.

- **DRILL-032-1 — DV10's undecided case.** [[roadmap]]'s DV10 says "Nothing answered ⇒ stay silent, and say the check
  could not decide." Both runners read "stay silent" and "say" as pulling against each other, and both invented a
  line (`DV10: could not decide — …`) and a place for it. Nothing gives its wording or says whether `triage`'s callout
  carries it.
- **DRILL-032-2 — triage's summary line.** `triage` step 9 prints `Dashboard refreshed: <E> epics, <S> stories, <T>
  tasks …` with no singular rule, so both runners printed "1 stories". The `/tasks` snapshot settled the same case for
  itself in TASK-355 (singular for exactly 1), and its `<n> feature divergence(s)` leaves the `(s)` unresolved too.

## Acceptance criteria

- [ ] DV10's undecided case has stated wording and a stated place in `--check` and the full render, and `triage`
      says whether its callout carries it
- [ ] `triage` step 9's summary states its singular forms, consistent with the snapshot's rule
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Accepted divergences: TASK-032 (done)

## Human test plan

- [ ] Re-run the `d032` brief on a fresh clone of `%LOCALAPPDATA%/Temp/d032/repo` with `skills/` at the fix, using a
      cold runner. Expected: neither reading in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-369` — leave empty until then._
