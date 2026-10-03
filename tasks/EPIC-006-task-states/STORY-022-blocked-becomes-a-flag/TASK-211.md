---
id: TASK-211
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate Presenter's task tree once its local work reaches origin

## Context

Spawned at TASK-205's close (2026-10-03) by the out-of-scope sweep: TASK-205's migration record skipped
Presenter with a follow-up that no task owned.

Presenter (`C:\Source\Birko\Consumers\Presenter`) has one old-form task, `TASK-012`
(`tasks/EPIC-004-landing-saved-decks/TASK-012-landing-clear-inside-field.md`, `status: blocked`). It exists only
on Presenter's local `main`, which is 14 commits ahead of `origin/main` (re-measured 2026-10-03; `origin/main`
has no old-form file). A migration PR cut from `origin/main` cannot contain it, and one cut from local `main`
would push somebody else's unpushed work — the reason TASK-205 skipped it.

The prior-state question is already answered, at the owner's request, on TASK-205: Birko.Framework TASK-484,
which TASK-012 waits on, is still `todo`, and TASK-012 has only its filing commit, so its state is **todo**.
Run `/tasks init` with the fixed step 3b (TASK-208), so its reason is read by the current ladder.

## Acceptance criteria

- [x] Presenter's local work has reached `origin/main` (checked, not assumed), and only then is anything done
- [x] `/tasks init` step 3b runs on Presenter; TASK-012 becomes `status: todo` plus a `blocked:` field, using
      the recorded answer, and its report line names the reason rung
- [x] The change lands through Presenter's own integration policy, and only task files change
- [x] TASK-205's migration record row for Presenter is updated to point here with the outcome

## Out of scope

- Pushing Presenter's 14 local commits — that work belongs to whoever made it

## Human test plan

- [x] `/tasks` in Presenter shows TASK-012 as blocked in `todo` with a readable reason, and no old-form status

## Implementation plan

_Populated by `/tasks plan TASK-211` — leave empty until then._

> Blocked 2026-10-03 — waiting on Presenter's unpushed local main — its only old-form task exists nowhere else

> Unblocked 2026-10-03 — Presenter's local `main` was pushed (0 commits ahead of `origin/main`); TASK-012 is now on `origin/main`, still `status: blocked`.
- 2026-10-03 — Picked (in place; this repo is single-branch). One-file task with its steps already in Context, so no separate plan. Presenter checked pushed (`main` 0 ahead of `origin/main` `84ff70e`). Worktree `%TEMP%\d211` on new branch `tasks/status-migration` from `origin/main`; Presenter's main copy (1 uncommitted change, not ours) untouched. Step 3b on TASK-012: prior state — history has only the filing commit `5c86ec8` (created blocked), so the recorded owner answer applies: `todo`. Reason — rung `note`: `> Blocked 2026-09-24 — waits on **Birko.Framework TASK-484** (…). Cross-repo, …`; label dropped, emphasis read through, cut at the first sentence end (113 chars), pointer appended. No old-form status left. Committed `239e75c` (2+/1−), no trailer per Presenter's CLAUDE.md. **Not pushed — waiting on the owner.**
- 2026-10-03 — Owner approved push and merge. PR birko/Presenter#1 opened, checked (only TASK-012's file, CLEAN, no CI, `origin/main` unmoved, no unpushed local commits) and merged as `ab4c98bc`, locked to `239e75c`. Branch deleted locally (`-d`) and on origin; worktree removed. Human test plan run by the agent on the owner's instruction, reading `origin/main`: TASK-012 `todo` + its reason; 13 tasks (10 todo, 3 done), no old-form status. Presenter's local `main` is 2 behind and carries 1 uncommitted change that is not ours — left alone. Review passes: not run — the change is one status line pair written by `init` step 3b, already reviewed under TASK-208. Out-of-scope sweep: 1 boundary. Closed `done`.
