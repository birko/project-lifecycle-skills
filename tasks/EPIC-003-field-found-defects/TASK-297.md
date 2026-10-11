---
id: TASK-297
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-11
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-295-1]
pr: null
github-issue: null
jira-key: null
---

# `/feature review` sets a feature to `review` without regenerating its rollup

## Context

Found while drilling TASK-295's fix (2026-10-11, fixture `%TEMP%\d295`). One of two `/feature review` runs set
`idea.md` to `status: review`, moved a task to `verify` and updated the features index row, but did not create
or regenerate the feature's `status.md`. It said so: *"I haven't created `status.md`; run `/feature status` if
you want that summary page."*

That reading is what `skills/feature/verbs/review.md` step 5 says. The all-pass branch says "run `/feature
status`", and the `review` branch ("Gate A passes … but Gate B/C sign-off hasn't happened → set `status:
review`") does not. `skills/feature/verbs/status.md`'s notes name exactly this as a defect: *"Flipping
`idea.md`/tasks without re-running `status` leaves `status.md` reading `done` while everything else says
`review` — the stakeholder's rollup then lies."* Step 5b's commit list counts `status.md` only "when
`/feature status` ran", so it will not catch the omission either.

## Acceptance criteria

- [ ] Every branch of `review.md` step 5 that changes `idea.md`'s status or parks a task chains `/feature status
      FEATURE-NNN`, not only the all-pass branch
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Step 5's suggestion to close still-open tasks after Gate A — TASK-235

## Human test plan

- [ ] On a fixture whose feature has a `status.md` reading `building`, run `/feature review` where Gate B fails.
      Expected: `status.md` is regenerated to the `review` phase and is part of the `chore: review` commit.

## Implementation plan

_Populated by `/tasks plan TASK-297` — leave empty until then._
