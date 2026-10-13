---
id: TASK-305
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-303-1]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/feature review` parks tasks at `verify` and never regenerates `tasks/README.md`

## Context

Found by TASK-303's drill (2026-10-13). On a fixture with no upstream, `/feature review` parked TASK-001 `done → verify` and reopened STORY-001. It then committed `chore: review FEATURE-001` with `tasks/README.md` still showing TASK-001 `done` and STORY-001 `done (1/1)`. `skills/feature/verbs/review.md` step 5 chains `/feature status` for the feature rollup but nothing for the tasks dashboard, which `/tasks triage` owns. So every review that parks a task leaves the dashboard contradicting the task files it just committed.

## Acceptance criteria

- [x] When `/feature review` parks a task or reopens a container, it regenerates `tasks/README.md` through `/tasks triage`, and step 5b commits it with the rest. With an upstream it follows `close` step 10's rule (no generated file on the default branch), so the dashboard goes on the record branch or is named
- [x] `decide.md`'s surface-dependent revert does the same
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The reopening rule itself (TASK-303)
- Deferred to TASK-307 — `/feature decide` commits nothing, so a revert's files stay uncommitted

## Human test plan

- [x] On a fixture with no upstream, run `/feature review` on a feature whose only task has an unbacked `N/A` plan. Expected: the review commit carries a `tasks/README.md` showing the task at `verify`.
  Passed 2026-10-13: `0ac6f8b chore: review FEATURE-001` on TASK-296's fixture carries `tasks/README.md` with TASK-001 `🔍 verify` (step-6 drill, `claude -p` with the installed skills).

## Implementation plan

Not drafted: `/fix-next` picked this task and offers no plan step (TASK-135 owns that gap). The work followed the Progress log below, step by step.

## Outcome

**The fix.** `/feature review` now chains `/tasks triage` whenever it parks a task or reopens a container, and commits the regenerated `tasks/README.md` with the rest of its record. Before, the review's commit carried a dashboard that still showed the parked task `done`, contradicting the task file beside it. `/feature decide`'s revert chains it too, and `triage` names both feature verbs among its chainers. With an upstream, the review's dashboard rides on its `record/FEATURE-NNN` branch with the rest of its record. `decide`, which has no record branch yet (TASK-307), writes no dashboard there and names `/tasks triage` instead.

**Step-6 split.** The same fixture was run before and after (story closed, then feature reviewed with no sign-off). Before (TASK-303's drill): the review commit had no `tasks/README.md`, and the committed dashboard showed TASK-001 `done` and STORY-001 `done (1/1)`. After: `0ac6f8b chore: review FEATURE-001` carries `tasks/README.md` showing TASK-001 `🔍 verify` and STORY-001 `in-progress (0/1 done)`. Fix-dependent: the dashboard's presence in the review commit and its content. Contract pins, not evidence: the park, the story reopen (TASK-303) and the commit subject, the same in both runs.

**Judgement calls.**
- *Chained only when the task tree changed.* A review that parks nothing leaves the dashboard correct, and regenerating it anyway would only change its timestamp.
- *With an upstream the dashboard rides on the record branch.* My first version wrote no dashboard there, by `close` step 10's rule. The correctness pass at close showed why that was wrong: `review` already puts `status.md` and the index on `record/FEATURE-NNN`, and it never leaves the main copy dirty. Leaving only the dashboard out lands the parked tasks beside a stale one, the very contradiction this task removes. Two record branches may conflict on the timestamped file, but that is fixed by re-running `triage`, and a stale dashboard goes unnoticed.
- *`decide` was in the criteria from the start*, unlike TASK-303's pull-in.

**Flagged, not fixed.** TASK-307 (CR-305-1): `/feature decide` commits nothing at all, so a revert's task files, rollups and now dashboard stay uncommitted, and with an upstream they are written on the default branch. This predates this task.

## Progress log

- step 2 — picked; ranked above TASK-304 because every review that parks a task commits a dashboard contradicting the task files in the same commit (silent, key 3), where TASK-304 leaves an untracked file `git status` shows; above TASK-306 on reachability (every park, not a window before a record lands, key 2); key 6 inert
- step 3 — verified: held — `review.md` step 5 chains `/feature status` after a park or status change but nothing for `tasks/README.md`, and `triage.md` lists no feature verb among its chainers; `decide.md` step 4 (surface-dependent revert) has the same gap, as the task says. With an upstream the dashboard must not be written on the default branch (`close` step 10, FEATURE-001 D26), so the fix is conditional
- step 4 — layer: local
- step 5 — fix in `skills/feature/verbs/review.md` (step 5 chains `triage` after a park or reopen, except with an upstream; 5b counts the dashboard), `skills/feature/verbs/decide.md` (step 4 the same) and `skills/tasks/verbs/triage.md` (names both as chainers); lint OK (20 skills)
- step 6 — before/after on TASK-296's fixture, no upstream: before, the review commit had no dashboard and the committed one showed TASK-001 `done`; after, `0ac6f8b` carries a dashboard showing `🔍 verify` and the story `in-progress (0/1)`; fix-dependent = the dashboard in the commit and its content; contract pins = the park, the reopen and the subject
- step 7 — respecced feature-lifecycle (*Review commits its own record*: the dashboard after a park; new scenario; the decide revert requirement regenerates it too)
- step 6 (addendum, close gate) — the correctness pass showed the upstream exception left only the dashboard off the record branch that already carries `status.md` and the index; reversed, so the dashboard rides on it. Spec and the triage chainer sentence fixed; the intent pass found `decide` missing the upstream half of criterion 1, now added (it names `triage`, having no record branch yet); decide's missing commit spawned as TASK-307. The drilled no-upstream path is unchanged, so not re-drilled
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
