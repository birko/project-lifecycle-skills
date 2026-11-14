---
id: TASK-377
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
picked-by: fix-next
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-375-6]
pr: null
github-issue: null
jira-key: null
---

# No verb moves a `planned` story or epic to `in-progress` when its first child starts

## Context

Found 2026-11-14 while fixing TASK-375. `SKILL.md` § *Roll status up to parents* rolls a parent up when its children
finish and reopens it when one leaves `done`, but nothing moves a `planned` container to `in-progress` when a child
starts: `pick` sets the task alone, and no other verb touches the parent. So a story can read `planned` with most of
its tasks done. This repo's STORY-024 reads `planned` at 17 of 21.

Two cold `triage` runners flagged STORY-024 on their own (`%LOCALAPPDATA%/Temp/d368` `report-run1.md` point 3 and
`report-run2.md` point 2), and TASK-375's step 4b now reports the case with no verb to fix it. Hand-editing the
status is the defect `AGENTS.md` § Working rules forbids, so the report can only be cleared by a verb that does not
exist yet.

## Acceptance criteria

- [x] The verb that moves a task out of `todo` (`pick`, and any other that does) moves its `planned` parent story to
      `in-progress`, and the epic above it the same way, reporting each move in one line
- [x] `SKILL.md` § *Roll status up to parents* states the starting direction beside the other two
- [x] `triage.md` step 4b's `planned` row names that verb as its fix
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Backfilling this repo's `planned` containers that already have started children: run the fixed verb's rule once,
  through whatever the fix provides

## Human test plan

- [x] On a fixture with a `planned` story and a `todo` task under it, run `/tasks pick` on that task with a cold
      runner. Expected: the story and its epic read `in-progress`, and the run says so
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d377` (`claude -p --disable-slash-commands`, the runner
    listing no skills). Fixture `notebox`: `EPIC-001` and `STORY-001` `planned`, `TASK-001` `todo`, `single-branch`,
    no remote. The brief did not mention parents. After `/tasks pick TASK-001` all three read `in-progress`, the run
    printed `STORY-001 started: TASK-001 is in progress` and `EPIC-001 started: …`, and nothing was committed (an
    in-place pick commits nothing). The runner's one point on the change: the report line was written for a story
    only, so it adapted it for the epic; the rule now reads `<STORY-NNN | EPIC-NNN> started`.

## Outcome

**The fix.** `SKILL.md` § *Roll status up to parents* gains the starting direction beside finishing and reopening: a
task leaving `todo` for `in-progress` moves a `planned` parent story to `in-progress`, then its epic, in the same
checkout and commit as the task's own flip, and the run reports each move. `pick` step 7 applies it, step 6b's
upstream pick commit names the parent files (the no-upstream one already did), `fix-next`'s flip points at it, and
`triage` step 4b's `planned` row now names `/tasks pick` as its fix.

**Judgement call: a parent already `in-progress` is left alone**, and nothing else moves a container forward. The
backfill of this repo's `planned` containers with started children (STORY-024) is out of scope: the next pick under
it rolls it up, and until then `triage` reports it.

**Also corrected:** the work-tracking spec still said `triage` and `audit` flag a parent; TASK-375 made it `triage`
alone, and its respec missed that sentence.

**Step-6 split.** Text: the starting direction is absent at HEAD and present at the fix. Behavioural: d377.

**Close gate (inline, four skill files plus two specs):**
- **Standards:** the rule lives once in `SKILL.md`; the verbs point at it.
- **Intent:** all four criteria met.
- **Correctness:** checked by the drill; one wording point fixed.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

## Progress log

- step 2 — picked on the user's go-ahead after TASK-375, whose callout reports this case with no fixing verb; a silent wrong state (STORY-024 `planned` at 17/21) and fixable in the rollup rule plus the verbs that start a task
- step 3 — verified: `SKILL.md` § *Roll status up to parents* has the finishing and reopening directions only; `pick` step 7 flips the task alone; `fix-next`'s flip follows `pick`
- step 3b — planned inline: a third direction in the rollup rule (starting), applied by `pick` step 7 in the flip's own checkout and named in 6b's upstream pick commit; `fix-next` and `triage` 4b point at it
- step 4 — layer: local (tasks, fix-next)
- step 5 — fix in skills/tasks/SKILL.md, skills/tasks/verbs/pick.md (step 7, step 6b's upstream commit), skills/fix-next/SKILL.md, skills/tasks/verbs/triage.md (4b's planned row)
- step 6 — behavioural: d377 (story and epic rolled to in-progress, both reported). Text: starting direction 0 → 1
- step 7 — respecced work-tracking (the rollup requirement states starting, with a scenario; `audit` removed) and defect-draining (the pick rolls a planned parent up), restamped
- step 8 — closed inline; commit in git log
