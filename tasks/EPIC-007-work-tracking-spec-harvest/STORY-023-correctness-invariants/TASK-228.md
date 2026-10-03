---
id: TASK-228
parent: STORY-023
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
findings: [SH-26, SH-27, SH-29]
pr: null
github-issue: null
jira-key: null
---

# `fix-next` does not say where a run goes after an outcome that is not a fix

## Context

Found by the defect-draining spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). Three places in
`skills/fix-next/SKILL.md` end a step without a fix and leave the next move unstated. One root cause: the loop
defines only the path on which the defect is fixed in this repo.

- **SH-26 — step 4, upstream fix.** "Symptom here, defect upstream" records the decision, flags the user and marks
  the local task blocked, and stops there. It does not say whether the run then stops, closes anything, or returns to
  step 1. Step 0 then reports this skill's own blocked task as `not resumed` on every later run, and nothing says
  that is the expected end state.
- **SH-27 — every task blocked.** Step 2 says an all-blocked pool "is an empty pool for step 1's purposes: report the
  blocked tasks and stop". Step 1's empty-pool branch lists exactly two causes with two messages (no review filed; a
  backlog that predates the stamp). Neither fits, so a reader of step 1 alone has no message for this case.
- **SH-29 — step 3, not a defect.** A rejected finding is cancelled and the run "returns to step 1 for the next
  candidate", on a bare run too. A bare run's contract (step 9, *What this skill does NOT do*) is one defect per
  invocation. Nothing says whether a rejected false positive counts as that one defect.

## Acceptance criteria

- [ ] Step 4's upstream path names what the run does next, in bare and `--loop` mode, and step 0 says a blocked run
      of this skill's own is the expected result of that path
- [ ] Step 1's empty-pool branch covers the all-blocked case or points at step 2's rule, so the two do not disagree
- [ ] Step 3 states whether a rejected finding uses up a bare run's one defect, with the reason
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ask-steps in the same skill — TASK-229
- Changing the ranking keys

## Human test plan

N/A — control-flow statements, checked by following each exit from step 0 to step 9 and confirming it names where
the run goes.

## Implementation plan

_Populated by `/tasks plan TASK-228` — leave empty until then._
