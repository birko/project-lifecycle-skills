---
id: TASK-218
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-217-1, DRILL-217-2, DRILL-217-3, DRILL-217-4]
pr: null
github-issue: null
jira-key: null
---

# `/tasks migrate` leaves its dry run, its confirmation and its hand-off to `export` undefined

## Context

Found by the two cold runners of TASK-217's drill (2026-10-03), each running
`/tasks migrate --to github --repo example-org/shop --dry-run` on an invented tree. They are older than TASK-217,
which only changed which tasks `migrate` selects, so they are filed together here.

| Id | Raised by | Where | Problem |
|---|---|---|---|
| DRILL-217-1 | both runners | `migrate.md` step 2, `--dry-run — show plan + payloads, push nothing` | Does not say whether a dry run still flips `mode: local` to `hybrid` (step 7) or regenerates the dashboard (step 8). Both runners had to decide |
| DRILL-217-2 | both runners | `migrate.md` step 4, "Proceed? (y/n)" / "Confirm before pushing anything" | An ask-step with no answer-less path (AGENTS.md § Output/prose rules), and meaningless under `--dry-run` |
| DRILL-217-3 | one runner | `migrate.md` step 6 vs `export.md` | Step 6 says "track the milestone number for child tasks", but `export`'s `gh issue create` passes no `--milestone` and nothing consumes the number, so tasks are never linked to their epic's milestone |
| DRILL-217-4 | one runner | `migrate.md` step 6 vs `export.md` step 1 | `migrate` runs "the `/tasks export` logic", whose step 1 refuses unless `mode: hybrid`; `migrate` flips the mode only in step 7, after the push. Read literally, every export call errors |

Two of the four were raised by one reader only; they are filed because each is checkable by reading the two
files side by side, not a judgement call.

## Acceptance criteria

- [ ] `--dry-run` states exactly which steps it skips (no push, no mode flip, no dashboard regeneration) and what
      it prints
- [ ] The confirmation question carries its words and an answer-less path — nobody to answer means nothing is
      pushed and the run reports that; `--dry-run` does not ask it
- [ ] Tasks created under an epic are linked to that epic's milestone, or the instruction to track the number is
      removed with the reason — `migrate` and `export` agree
- [ ] `migrate`'s use of the `export` logic does not trip `export`'s mode check: the order or the check is stated
      so a literal run succeeds
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Which tasks `migrate` selects — TASK-217

## Human test plan

- [ ] A cold `--dry-run` on an invented tree with nobody to answer: it prints the plan, asks nothing, and changes
      no file, `.config.yml` included
- [ ] Reading `migrate` step 6 against `export` steps 1 and 5: a literal run creates linked issues without an error

## Implementation plan

_Populated by `/tasks plan TASK-218` — leave empty until then._
