---
id: TASK-378
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-269-1]
pr: null
github-issue: null
jira-key: null
---

# `/specs init`'s blessing question and unblessed confirmation print "1 areas"

## Context

Filed 2026-11-14 at TASK-269's close, from its drill (`%LOCALAPPDATA%/Temp/d269`, `report.md` § 7) compared with
d365 (TASK-365's drill, `report.md` line 80). Both runners met `/specs init` through `/adopt-project` on a one-area map.

- **DRILL-269-1.** `skills/specs/verbs/init.md`'s blessing question reads "`<N>` areas over `<M>` tracked files", and
  its unblessed confirmation reads "wrote `<N>` areas **unblessed**". With one area both print `1 areas`. TASK-349 made
  every `/specs` *count line* singular for one (`verify.md` step 4), but these two are a question and a confirmation,
  and neither runner read the rule as covering them. d269 raised it as undecided; d365 printed `` `1` areas `` without
  comment, which is the same output.

## Acceptance criteria

- [ ] The blessing question and the unblessed confirmation in `init.md` take the count rule `verify.md` step 4 states
      (singular for exactly 1), by pointing at it rather than restating it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Any other `/specs` output: TASK-349

## Human test plan

- [ ] Re-run TASK-269's brief (`%LOCALAPPDATA%/Temp/d269/brief.txt`, on a fresh copy of `d065/adopted` and `skills/` at
      the fix) with a cold runner. Expected: the blessing question reads `1 area`

## Implementation plan

_Populated by `/tasks plan TASK-378` — leave empty until then._
