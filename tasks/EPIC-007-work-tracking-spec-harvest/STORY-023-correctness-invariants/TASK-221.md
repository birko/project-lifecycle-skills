---
id: TASK-221
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-3, SH-12]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `cancel` and container close disagree about cancelled work

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). Both findings are about what cancelled work
means for its container and for a revival.

- **SH-12 — a story of only cancelled tasks closes `done`.** `close --story` (and `--epic`) checks every child is
  `done` or `cancelled` and then always flips the container to `done`. `skills/tasks/verbs/cancel.md` says a story
  whose children are all cancelled is itself `cancelled`. Two verbs, two answers for the same tree.
- **SH-3 — reviving cancelled work is a hand edit.** `cancel.md`'s revival edge case says to `/tasks pick` "after
  manually flipping it back", while `tasks/SKILL.md` § Lifecycle says every status has a verb and none requires
  hand-editing frontmatter.

## Acceptance criteria

- [x] A container whose children are all `cancelled` gets one answer from both `close` and `cancel`, stated in both
- [x] Reviving a cancelled task goes through a verb (an existing one, or a stated new path) — no hand edit of
      `status:`; `SKILL.md`'s "every status has a verb" stays true
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- What a mixed done/cancelled container is — already `done` in both

## Human test plan

- [x] On an invented tree, close a story whose only task is cancelled: the result matches what `cancel` says
  - **Passed 2026-10-09:** fixture `%TEMP%\d221` (`single-branch`, one epic, one story, one cancelled task), `echo "/tasks close --story STORY-001" | claude -p --permission-mode acceptEdits --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills`. The story ended `cancelled`, and the runner named the same rule for the epic. It also left the dashboard and the story uncommitted → evidence added to TASK-292

## Outcome

**The fix.** Closing a story or epic whose children were all cancelled now marks it `cancelled`, not `done`, the same answer `cancel`'s rollup gives. A mix of done and cancelled children is still `done`. For an epic, its stories and its directly parented tasks count together. The rule is stated in `close` § *Closing a STORY / EPIC*, in `cancel` step 9 and in `SKILL.md`'s rollup rule. Reviving cancelled work no longer has a hand-edit path: it goes through `/tasks new` citing the cancelled id, which `pick` already pointed at. A mistaken cancel that is not committed yet can be discarded with `git restore`, which undoes an unrecorded edit rather than rewriting a recorded status.

**Step-6 split.** 2/3 fix-dependent across two cold A/B rounds: closing an all-cancelled story (old text: `done`; new: `cancelled`) and undoing a mistaken, uncommitted cancel (old text: "edit the `status:` line by hand"; new: `git restore`, no hand edit). Contract pin, not evidence: reviving a week-old cancel, which both texts already route through `/tasks new`. The lint is a contract pin too.

**Judgement calls.**
- *`/tasks new` over a new `uncancel` verb.* An uncancel would have to restore a prior status nobody recorded. It would also erase a recorded decision, which `cancel`'s whole premise forbids. The revival is a new decision, so it gets a new task.
- *The `git restore` path is kept, but fenced.* Both cold readers raised the same edges, so the text now requires reading `git diff` first and says that git cannot reopen a remote issue. The stricter option, `/tasks new` even for a cancel made a minute ago, was rejected: it leaves a cancelled record of a typo.
- *An empty container keeps closing `done`.* "Every child is cancelled" is vacuously true with no children, so the rule says "has children and every one is cancelled". Found by the close's own correctness pass; the stricter reading (empty ⇒ `cancelled`) was rejected as a silent change nobody asked for — `move.md` already tells the user to `cancel` an emptied story.
- *`--force` with open children still writes `done`.* Forcing sets the remaining work aside; it does not say the work was dropped. Reporting the open children is what keeps that honest.

**Flagged, not fixed.** TASK-292 gained a second instance: a container close also leaves the dashboard uncommitted.

## Implementation plan

_Populated by `/tasks plan TASK-221` — leave empty until then._

## Progress log

- step 2 — picked; ranked above TASK-292 because key 1/3: two verbs give a container of only-cancelled tasks opposite terminal statuses, so `close --story` silently records `done` for work nobody did, while TASK-292's leftover dashboard is self-reporting in `git status` (and P3). Key 6: STORY-023 declares `correctness-invariants`; TASK-292 is EPIC-parented, so no theme — key 6 would also have ordered them this way, but keys 1/3 settled it first
- step 3 — verified: held. `close.md` § *Closing a STORY / EPIC* step 2 flips the container to `done` unconditionally, after step 1 accepts `done`/`cancelled` children; `cancel.md` step 9 says all-cancelled ⇒ `cancelled`. `cancel.md`'s revival edge case still says "after manually flipping it back", while `pick.md`'s edge cases already refuse a cancelled task and point at `/tasks new`
- step 4 — layer: local
- step 5 — fix in `skills/tasks/verbs/close.md` (§ *Closing a STORY / EPIC* step 2), `skills/tasks/verbs/cancel.md` (step 9; the revival edge case), `skills/tasks/SKILL.md` (§ Lifecycle rollup rule); lint green
- step 6 — cold A/B, two rounds, pre-fix (HEAD) vs post-fix text: 2/3 fix-dependent — all-cancelled story close (`done` → `cancelled`), mistaken uncommitted cancel (hand edit of `status:` → `git restore`); contract pin: week-old revival (both texts → `/tasks new`). Runner `cd C:/Source/WebChecker && claude -p --disable-slash-commands < <brief>`; coldness not separately confirmed. Both new-text readers raised the restore path's edges (other uncommitted work in the same files; a hybrid remote close), now stated in `cancel.md`
- step 7 — respecced work-tracking: *Closing stories and epics* (all-cancelled ⇒ `cancelled`; new scenario *Every child cancelled*) and *Cancelling work* (no uncancel; revival via `/tasks new`; the uncommitted-restore path). Diff reviewed: nothing unintended. Stamped `0050c43`
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
