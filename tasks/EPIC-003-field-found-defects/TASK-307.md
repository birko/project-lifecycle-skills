---
id: TASK-307
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: verify
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-305-1]
pr: null
github-issue: null
jira-key: null
---

# `/feature decide` commits nothing, so a revert's task files and rollups stay uncommitted

## Context

Found by the correctness pass at TASK-305's close (2026-10-13). `skills/feature/verbs/decide.md` changes `decisions.md`, and for a surface-dependent revert (step 4) also `idea.md`, the reverted task files, their reopened parents, `status.md`, the index and now `tasks/README.md`. It never says to commit any of them. Line 44 mentions only reconciling "before committing". `/feature review` step 5b gained a commit step for the same reason (TASK-294), and an upstream record branch (TASK-296). `decide` has neither, so its record floats uncommitted in the working tree. With an upstream, it sits on the default branch, which must mirror the remote.

## Acceptance criteria

- [x] `decide` commits exactly the files it wrote, under a subject that does not lead with a task id, with no upstream; and by the record-branch rule (`close.md` § *Closing a STORY / EPIC* step 5) with one
- [x] Its confirmation names the commit, the pushed branch, or every file left uncommitted
- [x] AGENTS.md's list of commit subjects that do not lead with a task id gains the new one
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- What a revert changes (TASK-303, TASK-305)

## Human test plan

- [ ] On a fixture with no upstream, record a `changed` decision on a `done` feature with a human-verifiable surface. Expected: one commit carries the ledger, the reverted task, its reopened story, the rollups and the dashboard, and the tree is clean.

## Outcome

**The fix.** `/feature decide` now commits what it wrote. A new step 6 counts the files off the steps that ran (the
ledger, `idea.md` on a status change, and for a revert the reverted tasks, reopened containers, ripple edits,
dashboard, rollup and index) and commits exactly those as `chore: decide FEATURE-NNN` with no upstream, or on
`record/FEATURE-NNN` by the record-branch rule with one. The confirmation (now step 7) names the commit, the pushed
branch, or every file left uncommitted. The revert paragraph no longer tells an upstream run to leave the
dashboard for a person; it rides on the record branch, as a review's does. `close.md`'s record-branch rule and
AGENTS.md's two lists (record-branch users, commit subjects that do not lead with a task id) name `decide`. Spec
`feature-lifecycle` gains *Decide commits its own record* and its revert requirement's upstream clause changed.

**Step-6 split: 0/0.** The repo's only automated gate is the lint, which pins frontmatter, links and flags,
never a verb's steps, so no test fails with the fix reverted and none is claimed as evidence. The lint run
(OK, 20 skills) is a contract pin, not evidence. The real guard is the human test plan's fixture drill, which
this unattended run did not run, so the task parks at `verify`.

**Judgement calls.**
- *Same branch name as `review`, `record/FEATURE-NNN`.* Rejected: a distinct `record/decide-FEATURE-NNN`. Both
  verbs append to the same `decisions.md` History, so two unlanded record branches of one feature would conflict
  on landing; sharing the name makes the record-branch rule's existing step 3 stop the second run with
  `land it first`, which is the stricter, already-tested behaviour.
- *Commit with the subject `chore: decide …`, not the reverted task's id.* A verdict changes no code; the
  reverted task's behaviour is attributed when it closes again.
- *Step order changed (5 refresh, 6 commit, 7 confirm)* so the commit carries the rollup the old step 5 chained
  after confirming. Nothing outside `decide.md` cited its step numbers.

**Flagged, not fixed.** A `decide` run from inside a task worktree with an upstream stops at the record-branch
rule's main-copy check and leaves its files uncommitted, named in the report. That is the rule's existing,
reported behaviour, not a new gap, so nothing was filed.

## Implementation plan

_Populated by `/tasks plan TASK-307` — leave empty until then._

## Progress log

- step 2 — picked; ranked above TASK-306 because key 2 (reachability): every `/feature decide` run leaves its record uncommitted, and with an upstream on the default branch, while TASK-306 needs an unlanded `record/` branch and a park inside that window. Key 1 tied (silent corruption of the record: an uncommitted ledger rides onto the next task branch, the shape TASK-296 measured). Key 6 inert: both are parented straight to EPIC-003, so neither declares a theme
- step 3 — verified: held. `skills/feature/verbs/decide.md` has no commit step anywhere; step 4's revert even says "`decide` has no record branch yet (TASK-307)". Pulled in from the same root cause: that sentence's upstream branch ("write no dashboard … name `/tasks triage` for a person") becomes "the dashboard rides on `record/FEATURE-NNN`", as `review` step 5b already does; and the record-branch rule's two naming sites (`close.md` § *Closing a STORY / EPIC* step 5, AGENTS.md § Conventions) name `decide` beside `review`
- step 4 — layer: local
- step 5 — fix in skills/feature/verbs/decide.md (steps 5–7, revert step 4), skills/tasks/verbs/close.md (record-branch rule names decide), AGENTS.md (two lists); no automated test applies — prose verb; lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed; fix-dependent = none (the lint does not read verb steps); contract pins = skills-lint.sh run; evidence is the human test plan's drill, not run
- step 7 — respecced feature-lifecycle; requirements changed: added "Decide commits its own record"; "Changing a signed-off feature reverts it by surface" (upstream dashboard clause)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
