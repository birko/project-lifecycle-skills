---
id: TASK-259
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-85]
pr: null
github-issue: null
jira-key: null
---

# `grill-me` has no answer-less path: with nobody to answer, it neither ends nor reports

## Context

Found by the `idea-interrogation` spec harvest (2026-10-06, TASK-080, EPIC-007 fourth pass) at `07de657`, and
checked against the files before intake.

- **SH-85.** `grill-me` is nothing but ask-steps, and it defines no outcome for a round nobody answers.
  - § *Ask in rounds*: "A question left unanswered is still on the frontier and comes back."
  - § *When the grill is done*: it ends only when every question is answered or deferred, "or the user calls it off".

  With no user present (an unattended caller, a drill runner, a reply that never comes), the frontier never shrinks
  and the user never calls it off. Nothing says the grill should stop, or what it emits when it does.

AGENTS.md § *Output / prose rules* requires every ask-step to carry its answer-less path. The unattended outcome
must be a **reported unresolved state**, never a value that reads as decided. Its measured instance (DRILL-109) is
a cold runner that wrote a blessing question itself and then proceeded as if it had been blessed. For a grill, the
equivalent failure is emitting a `## Resolved decisions` block in which the grill's own recommendations read as
the user's choices.

The callers already handle a partial grill on their side: `/feature new` step 4 writes `open` for every question
the grill did not reach. That makes the gap the grill's own, and it bites when the grill runs on its own.

## Acceptance criteria

- [ ] `grill-me` states what happens when a round gets no answer: the grill ends, and nothing it recommended is recorded as decided
- [ ] The closing block distinguishes decisions the user made from questions left open, so a caller cannot read a recommendation as a choice
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- How `/feature new` writes dropped and deferred questions (TASK-258)

## Human test plan

- [ ] Cold drill (`skills/populate-tests/SKILL.md` § *The cold drill*): give a cold runner a plan and the installed skill, tell it no user will answer, and confirm it ends the grill and reports the open questions, without writing any recommendation as a resolved decision

## Implementation plan

_Populated by `/tasks plan TASK-259` — leave empty until then._
