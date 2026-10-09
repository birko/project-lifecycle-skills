---
id: TASK-294
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
created: 2026-10-09
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-161-2]
pr: null
github-issue: null
jira-key: null
---

# `/feature review` writes its result into `decisions.md` and leaves it uncommitted

## Context

Seen while running TASK-161's human test plan (2026-10-09). A real `/feature review FEATURE-001` on a
throwaway `single-branch` fixture (`%TEMP%\d161r`, no remote) failed Gates A and B, appended a History line
to `docs/features/FEATURE-001-csv-export/decisions.md`, and ended with ` M …/decisions.md` and the report
"I didn't commit it".

That matches `skills/feature/verbs/review.md`: Gate B says "note it in the feature's `decisions.md` History
log", Gate C records sign-off as a History line, and step 5 writes `idea.md`'s `status:` and runs
`/feature status` (which writes `status.md` and the features index). No step commits any of it. The next
`/tasks close` clean-tree check and [[fix-next]]'s *Verify the reset really is safe* then meet a dirty tree
that no step owns.

The same defect TASK-292 fixed in `/tasks close`, in a second verb. TASK-292's answer — every file a step
writes is committed by a named step, or the confirmation names it as uncommitted — is the shape to match.

Not yet established: whether `/feature decide`, `/feature status` and `/feature decompose` leave the same
residue when run alone. Check them before fixing, and file what you find rather than widening this task.

## Acceptance criteria

- [ ] `review.md` states which commit carries the History line, `idea.md`'s status change and the
      `/feature status` rollup, or that they are left uncommitted and named in step 6's confirmation
- [ ] A `/feature review` on a `single-branch` fixture ends with `git status --short` clean (or with the
      residue named in its report, if that is the chosen shape), on both a failing and a passing review
- [ ] The other `/feature` verbs are checked for the same residue, and any found are filed
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Projects with an upstream — whether a review's writes travel through a PR there is the same open question
  TASK-292's Outcome flagged for a container close
- Gate A's handling of `verify` tasks — TASK-235

## Human test plan

- [ ] On a `single-branch` fixture, run `/feature review` on a feature that fails Gate B, then on one that
      passes every gate. Expected: `git status --short` is empty after each, or the report names every file
      it left uncommitted.

## Implementation plan

_Populated by `/tasks plan TASK-294` — leave empty until then._
