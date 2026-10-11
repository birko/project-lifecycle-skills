---
id: TASK-297
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
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

- [x] Every branch of `review.md` step 5 that changes `idea.md`'s status or parks a task chains `/feature status
      FEATURE-NNN`, not only the all-pass branch
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Step 5's suggestion to close still-open tasks after Gate A — TASK-235

## Human test plan

- [x] On a fixture whose feature has a `status.md` reading `building`, run `/feature review` where Gate B fails.
      Expected: `status.md` is regenerated to the `review` phase and is part of the `chore: review` commit.
  - **Passed 2026-10-11:** two fresh `claude -p` runs of `/feature review FEATURE-001` on `%TEMP%\d297` (Gate B
    unmet: one step not run; `status.md` reading `building`) both regenerated it to `review (awaiting sign-off)`
    and committed it in `chore: review FEATURE-001`. Two more runs with no `status.md` both created it. The brief
    was the bare command. The runner holds the installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-297` — leave empty until then._

## Outcome

**The fix.** When `/feature review` set a feature to `review`, the text did not say to regenerate its
`status.md` and index row; only the all-pass branch did. So the stakeholder page could keep saying `building`,
or not exist at all, while the feature was waiting for sign-off. Step 5 now states once, above its branches, that
any branch that changes `idea.md`'s status or parks a task chains `/feature status FEATURE-NNN`. The all-pass
branch now points to that rule instead of carrying its own copy.

**Step 6 split, stated exactly because it is weak.** Before the fix, runners refreshed the rollup anyway in
**4 of 5** runs (TASK-294's FEATURE-001 run, TASK-295's run A, and two here). The one miss was TASK-295's run B,
on a feature with no `status.md` yet: *"I haven't created `status.md`; run `/feature status` if you want that
summary page."* After the fix, **4 of 4** runs refreshed it: two with a stale `status.md` reading `building`, and
two with none at all (`%TEMP%\d297`). **At this sample size the drill cannot show the guard can fail**, so every
run is a **contract pin, not evidence**. One of the pre-fix hits was also contaminated: the runner saw the
fixture commit that deleted `status.md` and restored it. The fix rests on the text, which had no instruction
for this branch. A behaviour that only happens out of habit is the defect this repo files.

**Judgement calls.**
- *State the chain once, above the branches, not on each branch.* A rule copied onto each branch is missing
  from the next branch someone adds. Stated once at the head, it covers that branch too.
- *Gate A stopping writes nothing and chains nothing.* The rule fires only on a status change or a parked task,
  which a Gate A stop never makes.

**Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-235 because every review that does not fully pass leaves the stakeholder rollup stale with nothing reporting it (keys 1, 3: a plausible wrong page, the defect `status.md` names), reached on every such review (key 2), observed in a real run (key 5); TASK-235 is an unreachable suggestion. Key 6 inert: no story
- step 3 — verified: held as written — step 5's all-pass branch runs `/feature status`, the `review` branch (which also parks tasks) does not, and `status.md`'s own notes call that state a lying rollup
- step 4 — layer: local (`skills/feature/verbs/review.md`)
- step 5 — fix in `skills/feature/verbs/review.md`: step 5 chains `/feature status FEATURE-NNN` after any branch that changes `idea.md`'s status or parks a task, stated once above the branches; the all-pass branch drops its own copy. Lint green; drill 4/4 runs refreshed the rollup and committed it (2 with a stale `status.md`, 2 with none)
- step 6 — reverted: 2 runs here both refreshed the rollup anyway, one contaminated by the fixture's deleting commit; with the earlier pre-fix runs, the pre-fix text refreshed it in 4 of 5. The drill cannot discriminate at this n: every run is a contract pin, not evidence. The fix rests on the text (see Outcome)
- step 7 — respecced feature-lifecycle ("Review sets the coarse status honestly": the rollup is regenerated on every branch that changes status or parks a task; the stakeholder-unavailable scenario now expects the rollup to read `review`); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
