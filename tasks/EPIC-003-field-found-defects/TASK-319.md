---
id: TASK-319
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-015]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# A `decide` revert sends a task back to `verify` with its old test step still ticked, so a re-close can count the old pass

## Context

Found by TASK-307's drill (2026-10-14). `skills/feature/verbs/decide.md`'s surface-dependent revert sends the implementing task `done → verify` and says to re-run its Human test plan before re-closing. It leaves the plan as it was. The step stays `[x]` with its old pass line, and [[tasks]] § *Lifecycle* reads `[x]` as **passed**, so `close` can take the task to `done` on a pass recorded against behaviour that no longer exists.

It is worse when the changed decision has not been built yet: the drill's runner reverted a task to `verify` ("code complete, awaiting a check") while the code still did the old thing, and noted that nothing says whether a `changed` row with an existing task should reopen that task or wait for a new one at decompose.

## Acceptance criteria

- [x] A revert leaves the reverted task's plan reading **not run** for every step the change affects, keeping the old pass lines as history
- [x] `decide.md` states whether a `changed` row whose change is not built yet reverts its task to `verify` or leaves it for decompose, and why
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Committing the revert (TASK-307)

## Human test plan

- [x] Built case: on a no-upstream fixture with a `done` feature whose task's plan is ticked and whose code already has the changed shape, record a `changed` decision, then `/tasks close` the task. Expected: the task reads `verify` with the affected step unticked and a `Reopened` line, and the close does not reach `done` without a new pass.
  Passed 2026-10-14: fixture `%TEMP%\d319a` (code already semicolon-separated, commit `b27b2df`). Decide reverted FEATURE-001 to `review` and TASK-001 to `verify`, unticked its step and appended `**Reopened 2026-10-14:** D1 changed — re-run before re-closing`; `/tasks close TASK-001` then stayed at `verify`. The runner flagged that step 7 still offered decompose unconditionally; it followed the table, and step 7 was then aligned. Runner: cold `claude -p --disable-slash-commands` in the fixture dir, skills granted by `--add-dir` on `~/.claude/skills` and `skills/`, same channel as the TASK-306/307/313 drills whose probe listed no skills.
- [x] Unbuilt case: the same fixture with the code still in the old shape. Expected: the feature reads `review`, the task stays `done`, and decompose is offered for the change.
  Passed 2026-10-14: fixture `%TEMP%\d319b` (code still comma-separated). FEATURE-001 went to `review`, TASK-001 and its story stayed `done`, and the confirmation offered `/feature decompose FEATURE-001`. Its commit was refused by the runner's harness (git through an un-allowlisted shell); the run named every uncommitted file, as step 7 requires. Runner: cold `claude -p --disable-slash-commands` in the fixture dir, skills granted by `--add-dir` on `~/.claude/skills` and `skills/`, same channel as the TASK-306/307/313 drills whose probe listed no skills.
- [x] Unbuilt case after the close review's fix (the row's task column is emptied): the same unbuilt fixture, record the `changed` decision, then `/feature pick FEATURE-001`. Expected: the D1 row no longer lists TASK-001 in its task column, a History line names it, and pick offers decompose for D1.
  Passed 2026-10-14: fixture `%TEMP%\d319c`. Decide committed `dd95fef chore: decide FEATURE-001`, the D1 row's task column reads `—`, the History line names TASK-001 as having built the prior shape, and `/feature pick FEATURE-001` stopped at gate D offering to decompose D1. Same cold runner channel, with git also allowlisted for PowerShell. The run surfaced TASK-321 and TASK-322.

## Outcome

**The fix.** A `/feature decide` revert no longer leaves a reverted task's old pass looking current. When the changed shape is already in the code, the task goes `done → verify` and every plan step the change affects is reset to *not run*: unticked, with `**Reopened YYYY-MM-DD:** D<n> changed — re-run before re-closing` appended and the old pass kept as history ([[tasks]] SKILL.md § *Lifecycle* owns the rule; `decide.md` points at it). When the change is not built yet, or that is unclear, the task stays `done`, its id moves from the row's `→ Tasks` cell into a History line, and the change arrives as a new task through `decompose`, because an empty cell is what `pick` gate D, `decompose` and `review` Gate A all read. Step 7 offers decompose only for unbuilt rows and points a built one at its task's re-run. `pick.md`'s "Feature is `done`" note follows the split. Spec `feature-lifecycle` respecced.

**Step-6 split: 0/0.** No automated test reads rule prose; the lint (OK, 20 skills) is a contract pin, not evidence. The evidence is three cold drills, all passed: built case (`verify`, step reset, `close` held at `verify`), unbuilt case (feature `review`, task `done`, decompose offered), and the unbuilt case after the cell fix (cell emptied, `pick` offered decompose).

**Judgement calls.**
- *Revert only if built* is the user's decision (2026-10-14). Rejected: always reverting and making the old task wait on the new one (two tasks tracking one change), and reopening the old task to `in-progress` (reworks finished work, and decompose must then skip the row).
- *Unsure counts as not built.* A task filed for work that turns out to exist closes quickly; a `verify` over unbuilt work claims code is complete when it is not.
- *Empty the cell rather than add a marker.* The close review found that leaving the old id in the cell let the row read as built to gate D, decompose and Gate A, so a feature could reach `done` with the change never built. Emptying it uses the condition all three already test; a new marker would need all three taught.

**Flagged, not fixed.** TASK-321: `pick` gate D's offer has no answer-less path. TASK-322: a feature with an unbuilt change still derives phase `review`, so `pick` meets gates D and E at once. Both came from the third drill. The missing-index gap the drills hit again is TASK-320.

## Implementation plan

_Populated by `/tasks plan TASK-319` — leave empty until then._

## Progress log

- step 2 — picked; ranked above TASK-298 because key 1/3 (silence): a reverted task keeps a ticked pass, so `close` can reach `done` on a test of behaviour that has since changed, with nothing reported, on every `decide` revert; TASK-298's run now names its uncommitted files and stops, so it self-reports. Key 6 inert: TASK-319 is parented straight to EPIC-003 and declares no theme
- step 3 — verified: held. `skills/feature/verbs/decide.md` § *Changing a closed feature* step 4 and [[tasks]] SKILL.md § *Lifecycle* ("A change landing on a closed feature…") send the task `done → verify` and say to re-run its plan, but neither touches the plan, so `[x]` steps keep reading **passed** and `close` step 5 reaches `done` on them. The unbuilt-change half is real too: `decompose`'s edge cases create a delta task for a `changed` row, so the reverted task sits at `verify` ("code complete") beside the task that will build the change
- step 4 — layer: local
- step 3 (decision, 2026-10-14) — the user chose "revert only if built": an unbuilt change leaves the task `done` and arrives through decompose. Human test plan split into the built and unbuilt cases to match, before any run
- step 5 — fix in skills/tasks/SKILL.md (§ Lifecycle: reopening resets the affected plan steps; an unbuilt change reopens nothing), skills/feature/verbs/decide.md (§ Changing a closed feature step 4: built/unbuilt table, unsure counts as not built); no automated test applies — prose rule; lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed; fix-dependent = none (the lint does not read rule prose); contract pins = skills-lint.sh run; evidence is the two cold drills of the Human test plan
- step 7 — respecced feature-lifecycle; requirements changed: "Changing a signed-off feature reverts it by surface" (built/unbuilt split, plan reset), scenario "Visual tweak reopens sign-off" (code already changed, steps unticked), added "An unbuilt change files new work instead of reopening the task"
- step 8 — handed to /tasks close; outcome in status:, commit in git log
