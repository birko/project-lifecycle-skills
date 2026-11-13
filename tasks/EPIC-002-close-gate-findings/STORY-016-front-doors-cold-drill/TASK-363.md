---
id: TASK-363
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
findings: [DRILL-362-1, DRILL-362-2, DRILL-362-3]
pr: null
github-issue: null
jira-key: null
---

# Three more adoption readings that a second cold runner has now raised

## Context

Filed 2026-11-13 at TASK-362's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d362`, `report.md`, § 7)
against the session's other drills under `%LOCALAPPDATA%/Temp/`. Each was recorded as a one-runner reading on an
earlier task, and d362 raised it again, which meets FEATURE-002 D10's bar.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-362-1 | `adopt-project`'s re-run wording, "write each one as `missing — this repo was adopted <date>…`": whether it covers `missing, not offered` rows (the CI gate) too. Both runners applied it to plain `missing` only | d357, d362 |
| DRILL-362-2 | `populate-tests`' § Testing question says "with tests in `<path>`", but no tests exist yet: a repo with nothing testable (d072/b), or a harness about to be wired (d362). Runners wrote "none" or the directory adopt would create | d072/b, d362 |
| DRILL-362-3 | the features index's drift note: its template says "If `/roadmap --check` would flag **feature↔task** drift", while its hint lists `specs/.map.yml` and `specs/<area>` as targets. Whether spec-layer findings (DV7, DV10) belong in it is unstated | d357, d362 |

## Acceptance criteria

- [ ] DRILL-362-1 … 3 each have one stated answer, in the file that owns the rule (`adopt-project`,
      `populate-tests`, `feature`'s index template or `status` verb)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Everything TASK-356, TASK-357, TASK-361 and TASK-362 settled

## Human test plan

- [ ] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      none of DRILL-362-1 … 3 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-363` — leave empty until then._
