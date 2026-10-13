---
id: TASK-296
parent: EPIC-003
feature: FEATURE-001
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-11
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-294-2]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# With an upstream, two gates leave their record uncommitted and nothing has measured where it goes next

## Context

Spawned by TASK-294's out-of-scope sweep (2026-10-11). It groups two instances of one open question, because
answering it once answers both.

On a project whose default branch tracks a remote, two gates write a record and deliberately commit nothing:
- a container close (`skills/tasks/verbs/close.md` § *Closing a STORY / EPIC*, step 5) names its flipped
  `STORY.md`/`EPIC.md` as uncommitted "for a person to land through an ordinary PR" — TASK-292's Outcome flagged
  this as unmeasured;
- `/feature review` (`skills/feature/verbs/review.md` step 5b, TASK-294) names its History lines, status change
  and rollup the same way.

Neither has been run on a repo with an upstream. Nothing says who opens that PR, or what keeps a later
close or review from finding the files and committing them by accident.

### Measured 2026-10-13 — what happens to the named files

Fixture: a scaffolded repo at `%TEMP%\d296\work` whose `main` tracks a bare local remote, with `integration: pr-per-task`, no `workspace:`, STORY-001 (TASK-001 `done`, `feature: FEATURE-001`) and STORY-002 (TASK-002 `todo`). One `claude -p` runner, with the installed skills and git allowlisted, ran: `/tasks close --story STORY-001` → `/feature review FEATURE-001` (no sign-off available) → `/tasks pick TASK-002` → implement → `/tasks close TASK-002 --unattended`, with `git status` after each. This is a behaviour drill, so the runner was not cold to the skills by design.

| File | Written by | Afterwards |
|---|---|---|
| `STORY-001/STORY.md` | container close | never committed |
| `FEATURE-001/decisions.md`, `idea.md`, new `status.md` | `/feature review` | never committed |
| `TASK-001.md` (parked `done → verify`) | `/feature review` | never committed |
| `tasks/README.md` (new) | `pick` step 8 | never committed, and stale once TASK-002 merged |

- **Nothing was committed by accident.** `close` step 7's explicit staging left every foreign file out of `839bea0` and the merge `5818b9d`.
- **Nothing landed them either, and no later verb mentioned them.** `pick` cut `task/TASK-002` over the dirty tree, so the files rode onto the task branch. `close` merged and switched back with them still floating. None of the four reports named them after the step that wrote them. "For a person to land through an ordinary PR" is told once, and the files then sit there with no owner, and grow: a second gate adds to the same pile.

Side findings, filed separately: `/feature review` parks a `done` task at `verify` under a STORY already closed `done`, which leaves the tree contradicting itself; and `pick` step 8 regenerates `tasks/README.md` on the default branch under an upstream, which `close` step 10 forbids. `pick` step 7's branch offer having no answer-less path is TASK-182's.

## Acceptance criteria

- [x] Both gates are run on a fixture whose default branch tracks a bare local remote, and what happens to
      the named files afterwards is recorded
- [x] Either the current "name them for a PR" rule is confirmed with that evidence, or both verbs gain one
      shared rule for where the record goes, stated once and pointed at from the other
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-upstream path, which commits the record — TASK-292 and TASK-294

## Human test plan

- [x] On an upstream fixture, close a STORY and run `/feature review`, then run `/tasks pick` on another task.
      Expected: the report from each gate names its files, and the next verb neither commits them silently nor
      stops on them without saying why.
  Passed 2026-10-13, under D31's rule that superseded this expectation: on a fresh copy of the fixture, both gates pushed their record (`record/STORY-001` at `8a46a66`, `record/FEATURE-001` at `ed0949b`), each report named its branch, and the main copy was clean before `pick` ran, so `pick` carried nothing. Run by a `claude -p` runner with the installed skills (a behaviour drill, so not cold to them by design).

## Implementation plan

Not drafted: `/fix-next` picked this task and offers no plan step (TASK-135 owns that gap). The work followed the Progress log below, step by step.

## Outcome

**The fix.** On a project whose default branch tracks a remote, closing a story or epic and running `/feature review` now commit their record on a branch of its own. The commit is made in a temporary worktree at the upstream and pushed as `record/<ID>`. A person lands it through a PR, and the gate's files are restored in the main copy, leaving it clean. Before this, both gates left their files uncommitted "for a person to land". A fixture drill showed those files riding silently onto the next task branch and back, never committed and never mentioned again. The rule is stated once (`close.md` § *Closing a STORY / EPIC* step 5), pointed at from `review.md` step 5b, registered in AGENTS.md § Conventions, and recorded as FEATURE-001 D31.

**Step-6 split.** The same fixture sequence was run before and after, with a `claude -p` runner and the installed skills (a behaviour drill, so not cold to them). Before: 6 files from the two gates floated uncommitted through a pick and a merge, 0 landed. After: 0 floated, 2 record branches pushed, and the main copy clean before `pick`. Fix-dependent: where each gate's files ended up, and what each gate's report named. Contract pins, not evidence: no gate file was ever committed into a task's commit (explicit staging held both times), and the commit subjects `chore: close STORY-NNN` and `chore: review FEATURE-NNN` are unchanged.

**Judgement calls.**
- *The stakeholder chose "own branch"* (asked 2026-10-13). Rejected: keeping the old rule and having later verbs report the files, which keeps them visible but lets them pile up; and leaving the task blocked.
- *A temporary worktree, not a branch switch.* The first version switched the main copy to a detached head. The correctness pass at close tested it, and it broke in three ways. From a linked worktree, `git switch <default>` fails. On an in-place task branch, it carried that task's work along. And `commit --only` refuses a new file, which left the copy detached. A detached worktree at the upstream never moves the tree the gate ran in, and `git add` takes new files. No local branch is made, because `git branch -d` refuses an unmerged one, and this repo never uses `-D`.
- *Every guard stops before anything is written.* The gate must run in the main copy, on the default branch, with nothing ahead of the upstream. A branch that is only behind is fast-forwarded first, because a file edited on an older base would overwrite newer upstream lines. `record/<ID>` must not exist yet, and the stop still names the files. A refused push keeps the temporary worktree and prints its path and sha, since the commit exists nowhere else.
- *No PR is opened.* Whether a record lands is a person's call, and the pushed branch keeps it safe until then.

**Flagged, not fixed.**
- TASK-303 (DRILL-296-1): `/feature review` parks a `done` task at `verify` under a STORY already closed `done`.
- TASK-304 (DRILL-296-2): `pick` writes `tasks/README.md` on the default branch under an upstream. It showed again in the re-drill.
- `pick` step 7's branch offer has no path for when nobody answers. TASK-182 already owns that.
- Until a record branch lands, the default branch still shows the old state (STORY-001 `in-progress`, TASK-001 `done`). That is inherent to landing through a PR, and the report names the branch.

## Progress log

- step 2 — picked; ranked above TASK-298 because both are about records a gate leaves uncommitted (key 1 equal), but this one is reachable from two ordinary gates on any project with an upstream, where TASK-298 needs a `/fix-next` run that cancels or blocks on a task branch (key 2); key 6 inert (both `correctness-invariants`)
- step 3 — verified (reading, before the drill): held as an open question — both gates name their files as uncommitted under an upstream (`close.md` container step 5, `review.md` 5b); `pick` step 7 cuts a task branch in place with no clean-tree check, so the prediction is that the files ride onto the next task branch and `close` step 7 may stage them. Criterion 1 requires measuring it, so a fixture drill follows
- step 4 — layer: local
- step 5 — fix in `skills/tasks/verbs/close.md` (container close step 5: the record-branch rule) and `skills/feature/verbs/review.md` (5b points at it; step 6 names the branch); AGENTS.md § Conventions entry; FEATURE-001 D31 approved by the stakeholder; spawned TASK-303, TASK-304; lint OK (20 skills)
- step 6 — before/after on the upstream fixture: before 6 gate files floating and 0 landed; after 0 floating and 2 `record/` branches pushed (`8a46a66`, `ed0949b`), main clean before `pick`; fix-dependent = where the files ended up and what the reports named; contract pins = explicit staging kept gate files out of task commits both times, and the commit subjects are unchanged
- step 7 — respecced work-tracking (*Closing a story or epic*: the upstream record branch; new scenario) and feature-lifecycle (*Review commits its own record*: record branch with an upstream; the upstream scenario rewritten)
- step 6 (addendum, close gate) — the correctness pass tested the detached-head mechanics in a throwaway repo and found two blockers (a linked worktree cannot switch back; `commit --only` refuses an untracked file and leaves the copy detached). Rewritten around a temporary worktree; the remote is now `branch.<default>.remote`, a behind-only branch fast-forwards, and an existing `record/<ID>` stop names the files. Re-drilled on a third fresh fixture: `record/STORY-001` (`9f28efe`) and `record/FEATURE-001` (`2c08fb6`, carrying the new `status.md`) pushed, the temporary worktrees removed, the main copy clean before `pick`, so the final mechanism holds
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
