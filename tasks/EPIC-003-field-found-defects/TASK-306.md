---
id: TASK-306
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-303-1]
pr: null
github-issue: null
jira-key: null
---

# With an upstream, a park can miss a story whose `done` waits on an unlanded `record/` branch

## Context

Found by the correctness pass at TASK-303's close (2026-10-13). With an upstream, a container close commits `done` on `record/STORY-NNN` and restores the main copy (TASK-296, `skills/tasks/verbs/close.md` § *Closing a STORY / EPIC* step 5). Until that branch lands, the main copy's `STORY.md` still reads `in-progress`. A `/feature review` that parks one of its tasks at `verify` meanwhile reopens nothing, because nothing reads `done` yet ([[tasks]] § *Roll status up to parents*, the reopening direction). When the record branch lands, the story reads `done` over a `verify` child, the contradiction TASK-303 removed.

## Acceptance criteria

- [x] The reopening rule, or the record-branch rule, states what happens when a task's container has an unlanded `record/<ID>` branch: the park reports it by name, so a person reopens or re-records before landing
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-upstream path, where the close is committed on the default branch and the reopen sees it

## Human test plan

- [x] On an upstream fixture, close a STORY (leaving `record/STORY-NNN` unlanded), then run `/feature review` so it parks one of that story's tasks. Expected: the report names the unlanded record branch.
  Passed 2026-10-14: fixture `%TEMP%\d306` (local bare remote, `record/STORY-001` pushed and unlanded, STORY-001 `in-progress` on `main`). `/feature review FEATURE-001` parked TASK-001 `done → verify`, reopened nothing, and printed `record/STORY-001 is unlanded and closes STORY-001, which now has an open child TASK-001 — do not land it as is`. Runner: cold `claude -p --disable-slash-commands` in the fixture dir, skills granted by `--add-dir` on `~/.claude/skills` and `skills/`; probe listed no skills or slash commands. Its own record commit stopped at step 4 (the runner's sandbox refused writes to the temp worktree); that is the harness, not this rule.

## Outcome

**The fix.** [[tasks]] SKILL.md § *Roll status up to parents* gains one bullet under the reopening direction.
Whenever a child stops being `done` or `cancelled` and the default branch has an upstream, the rule checks each
container it would reopen for a `record/<ID>` branch on the upstream's remote (`git ls-remote --heads`). For each
one found it reports `record/<ID> is unlanded and closes <ID>, which now has an open child <child id> — do not
land it as is` and writes nothing for it. An unreachable remote is reported `not checked`. `/feature review`'s
park confirmation now carries those lines. Specs `work-tracking` (rollup requirement + scenario) and
`feature-lifecycle` (park scenario) respecced.

**Step-6 split: 0/0.** No automated test reads a rule's prose. The lint run (OK, 20 skills) is a contract pin,
not evidence. The guard is the human test plan's upstream-fixture drill, not run here, so the task parks at
`verify`.

**Judgement calls.**
- *Fixed in the reopening rule, not the review verb.* Every trigger of that rule hits the same window: a
  `decide` revert, `close` reopening, `move`, and `new` creating an open child, not only a review park. Fixing
  only `review` would have left the other four silent.
- *Report, never act on the branch.* Rejected: deleting the record branch or committing a reopen onto it. The
  branch is unlanded work a person owns, this run did not create it, and the repo's rule is never to delete what
  a run did not create. A person decides whether to discard it, re-record, or land it and reopen.
- *Read the remote every time, never remember it.* The branch lands or is deleted outside this skill's view,
  so the result is computed from the remote on each run, not stored.

**Flagged, not fixed.** Nothing.

**Close review (2026-10-14, `verify → done`).** Standards pass with notes, intent pass, correctness pass with notes, reported separately. The review found that the Outcome above overclaims: only the review park relays the new line, and `move` and `new` do not (`new` never reaches the check while the parent reads `in-progress`). This task's criterion was the park, which is built, so the gap went to TASK-317 rather than holding this close.

## Implementation plan

_Populated by `/tasks plan TASK-306` — leave empty until then._

## Progress log

- step 2 — picked; ranked above TASK-313 because key 1 (severity): a story landing `done` over a `verify` child is a silently wrong status, while TASK-313 leaves open work under a cancelled epic that `audit` can still see. TASK-307 (last run's pick) is now parked at `verify`. Key 6 inert: both are parented straight to EPIC-003, so neither declares a theme
- step 3 — verified: held, and wider than filed. `close.md` § *Closing a STORY / EPIC* step 5 restores the main copy after pushing `record/<ID>`, so the reopening rule ([[tasks]] SKILL.md § *Roll status up to parents*) sees `in-progress` and does nothing. Every trigger of that rule hits the same window, not only a `/feature review` park: a `decide` revert, `close` reopening, `move`, and `new` creating an open child. Fixed once, in the rule all of them apply
- step 4 — layer: local
- step 5 — fix in skills/tasks/SKILL.md (reopening rule), skills/feature/verbs/review.md (park confirmation); no automated test applies — prose rule; lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed; fix-dependent = none (the lint does not read rule prose); contract pins = skills-lint.sh run; evidence is the human test plan's drill, not run
- step 7 — respecced work-tracking, feature-lifecycle; requirements changed: "Parents rolled up after child changes" (+ unlanded-record scenario); feature-lifecycle park scenario added
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
