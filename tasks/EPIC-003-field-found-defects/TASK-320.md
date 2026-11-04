---
id: TASK-320
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: verify
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-016]
pr: null
github-issue: null
jira-key: null
---

# Two cold runners disagreed on whether `/feature status` creates the features index when it is absent

## Context

Found by the TASK-306 and TASK-307 drills (2026-10-14), run on the same fixture shape on the same day. Both reached `/feature status FEATURE-001` with no `docs/features/README.md`. The TASK-306 runner did not create it; the TASK-307 runner did. Both quoted the same sentence as the gap: *"Single-feature runs update only that feature's `status.md` and **its row** in the index, not the whole file."* Nothing says what a single-feature run does when there is no index to hold the row. Two runs of one verb produced different trees.

## Acceptance criteria

- [x] `skills/feature/verbs/status.md` states what a single-feature run does when the index does not exist
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The index's shape

## Human test plan

- [ ] Two cold runners each run `/feature status FEATURE-001` on a fixture with no `docs/features/README.md`. Expected: both leave the same tree.

## Outcome

**What was fixed.** `/feature status` step 7 told a single-feature run to update "its row in the index", and said nothing about an index that does not exist. Two cold runners on the same fixture shape split: one created the index, one did not. Step 7 now says it: with no index, a single-feature run renders all of it, as all-features mode does, and reports `created docs/features/README.md — it was absent`.

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills): a contract pin, not evidence. The Human test plan's two-runner drill is the evidence and has not been run.

**Judgement calls.**
- **Create, rather than skip.** This was settled from declarations, not taste. The verb owns the file. `skills/new-project/LAYER.md` requires the index to exist ("create the folder + index if absent"), so its absence is a gap, not a choice. Every line in it is derived, so rendering it decides nothing a person should have decided. Skipping would leave the gap for a run that may never come.
- **Render the whole file, not one row.** A one-row index would claim the feature tree holds one feature, which is wrong whenever it holds more.

**Respec.** `feature-lifecycle`, the `/feature status` requirement: states the absent-index case, plus one scenario. The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-323 because two runs of one verb already produced different trees (measured, key 5 verified), reached on every single-feature status run in a repo without an index (key 2); TASK-323 still loses on key 4; key 6 inert — both sit under EPIC-003 with no theme
- step 3 — verified: held. status.md step 7: single-feature runs update "its row in the index"; no rule covers an absent index. Settled from declarations, not a user decision: this verb owns the index, LAYER.md requires it to exist, and every row is derivable — so render it whole
- step 4 — layer: local (skills/feature/verbs/status.md)
- step 5 — fix in skills/feature/verbs/status.md (step 7); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan two-runner drill, not run
- step 7 — respecced feature-lifecycle; requirements changed: the /feature status requirement (+1 scenario); intended anyway — TASK-320's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
