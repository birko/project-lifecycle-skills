---
id: TASK-317
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-013]
pr: null
github-issue: null
jira-key: null
---

# `move` and `new` never report an unlanded `record/<ID>` branch, though TASK-306 says every trigger does

## Context

Found by TASK-306's close review (2026-10-14). TASK-306 put the unlanded-record check into [[tasks]] SKILL.md § *Roll status up to parents*, and its Outcome says every trigger of the reopening rule now reports it: a `decide` revert, `close` reopening, `move`, `new`, and a review park. Only `skills/feature/verbs/review.md`'s park confirmation was told to relay the line.

- `skills/tasks/verbs/move.md` step 8 lists exactly what the report carries, and the `record/<ID> is unlanded …` line is not in it.
- `skills/tasks/verbs/new.md` step 10 reopens only when the parent reads `done` (or `cancelled` and chosen). Inside the unlanded-record window the parent reads `in-progress`, so step 10 never reaches the SKILL.md rule and never runs the check.

A verb file must be readable standalone, so a run that follows one of these verbs drops the line or skips the check.

## Acceptance criteria

- [x] `move.md` step 8 and `new.md` step 13 report each `record/<ID> is unlanded …` line (and `not checked`) the reopening rule produces
- [x] `new.md` runs the check whenever the default branch has an upstream, whatever the parent reads
- [ ] `decide.md`'s revert and `close`'s reopen relay the line too, or the task records that they already do — ⚠ NOT MET for `close` — split to TASK-324 (`decide` is met: step 7 now relays both)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The check itself, and the review park (TASK-306)

## Human test plan

- [x] On an upstream fixture with `record/STORY-001` pushed and unlanded, `/tasks move` an open task into STORY-001 and `/tasks new task` under it. Expected: each report names the unlanded branch.
  - Passed 2026-10-14 as a cold drill (`skills/populate-tests/SKILL.md` § *The cold drill*). Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)"`, brief on stdin. The cwd was a scratchpad fixture, `d317-fixed`: a clone whose `main` tracks a local bare remote, which holds `record/STORY-001` reading `done`, and copies of `SKILL.md`, `move.md` and `new.md`. The brief withheld the record branch and the expected lines. Coldness: the runner reported "none" when asked to list its skills. Result: both the move report and the creation confirmation printed `record/STORY-001 is unlanded and closes STORY-001, which now has an open child … — do not land it as is`. The same brief over the HEAD copies printed it too (step 6).

## Implementation plan

Written by `/fix-next` after step 3, before the edits (it runs no `/tasks plan`):

1. `move.md`: step 6 runs the unlanded-record check for an open task moved in, whatever the parent reads; step 8 reports reopens and record lines.
2. `new.md`: a step-10 bullet runs the check with an upstream whatever the parent reads; step 13 reports the lines.
3. `decide.md` step 7 and `close.md` step 12 relay them (close's part reverted at review, see Outcome).
4. Lint, a cold revert-and-split drill, respec `work-tracking` and `feature-lifecycle`.

## Outcome

- **The fix.** A gate record pushed to a `record/<ID>` branch can close a story that nobody has landed yet. In the main copy that story still reads `in-progress`. When new or moved work goes under it, the record must not be landed as is, and the rule in `skills/tasks/SKILL.md` says to report that. Now `move` and `new` run that check whatever the parent reads, and they report it. `spawn`, which prints in `new`'s place, relays it, and so does `decide`'s revert confirmation. Files: `skills/tasks/verbs/move.md` (steps 6, 8), `new.md` (steps 10, 13), `spawn.md` (step 8), `skills/feature/verbs/decide.md` (step 7), and specs `work-tracking` and `feature-lifecycle`.
- **Step-6 split (cold drill, original vs fixed files, upstream fixture):** 0 of 2 report outcomes flip. Both runners printed the line for the move and for the new task, because each read SKILL.md whole and applied its rule. Contract pins: both report lines, the `ls-remote` check, and no write to the record branch. Nothing proves the fix on this fixture. What differs is the reading: the original runner listed the check as an ambiguity it had to resolve ("Read literally, nothing reopens STORY-001"), while the fixed runner listed it as settled. So this fix closes a gap that a careful reader already bridges. It does not repair a demonstrated drop of the line. The drill did not cover a reader holding only the verb file, which is the case the task's standalone-readability argument names.
- **Judgement calls.**
  - The check runs only for an **open** child, moved in or created. A closed child reopens nothing, by SKILL.md's own rule, so checking for one would only add noise.
  - Each site points at SKILL.md and names its lines, rather than restating the check. The format strings are an invariant, which § *Defer to a shared inventory* allows.
  - **`close` was reverted, the stricter option rejected for a reason the review found.** Running the rollup in step 4's reopen writes before step 4b settles where the close runs. It sits above the `--unattended` refusal. And it is undone in the same run whenever the re-close ends `done`, which would make step 12 print a false "now has an open child". The task only truly leaves `done` at a step-5 park, and that park has no reopening rollup at all. That is a separate defect, so criterion 3 is annotated NOT MET for `close` and split to TASK-324, not bent to fit.
  - `spawn` was fixed in place, not filed: its print replaces `new`'s confirmation, and it sits on the drain's own path (`close` 5d spawns unattended).
- **Specs.** Respecced by `/fix-next` step 7 as targeted edits under the stable-wording rule, `generated-at` restamped to HEAD, `shaped-by` carried (`feature: null`). Changes are *intended anyway — TASK-317's criteria, answered by /fix-next*. The spawn sentence and the new scenario are the same criteria applied to `spawn`.
- **Review gate.** Standards: pass. One suggestion (a long line, plus a step-8 reference made ambiguous by the longer list), fixed. Fidelity: all criteria met, read before the `close` revert, which is what makes criterion 3 partial now. Correctness: 5 findings. Findings 1–3 (the `close` step-4 rollup) are why it was reverted, and the residue went to TASK-324. Finding 4 is fixed for `spawn`; `intake`, `import` and `decompose` went to TASK-325, grouped with finding 5 (duplicate lines and a `not checked` flood). Security and review-comments: not applicable.
- **Flagged, not fixed.** TASK-324 (P2): `close`'s re-close park never rolls parents up. TASK-325 (P3): batch creators drop the lines and repeat them.

## Progress log

- step 2 — picked; ranked above TASK-254 because key 3 (silence): a `move` or `new` that follows its own verb file drops the unlanded `record/<ID>` line, so a gate record can sit unlanded while every report reads clean; TASK-254 is a phrasing gap whose drill runner still derived the right answer. Both drill-found (key 5); TASK-323 left out of the pool as a decision task
- step 3 — verified: held. `move.md` step 8 lists the report's contents without the unlanded line; `new.md` step 10 runs the rule only when the parent reads `done` (or a chosen `cancelled`), and inside the window the parent reads `in-progress`, so the check never runs. Criterion 3: neither relays it today — `decide.md` step 7 names no reopened container at all, and `close.md` step 12 names neither, though SKILL.md lists both as triggers
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/move.md (step 6 runs the check whatever the parent reads; step 8 reports it), new.md (step 10 bullet; step 13 report), close.md (step 4's reopen runs the rollup; step 12 reports it), skills/feature/verbs/decide.md step 7 (reopened containers and the record lines); test = lint OK + cold drill (step 6)
- step 6 — reverted fix (cold runners, original vs fixed `SKILL.md`/`move.md`/`new.md`, upstream fixture with `record/STORY-001` pushed and unlanded): 0/2 report outcomes flip — both runners printed the unlanded line for the move and for the new task, because each read SKILL.md whole and applied its rule. fix-dependent = none proven on this fixture; contract pins = both report lines, the `ls-remote` command, no write to the record branch. What did differ: the original runner listed as undecided "Read literally, nothing reopens STORY-001 … so I ran the check", and the fixed runner listed "whatever they read" as settled ("I would otherwise have skipped it"). The fix removes an ambiguity a careful reader resolved correctly; the drill does not show a reader dropping the line
- step 7 — respecced work-tracking, feature-lifecycle; requirements changed: "Parents rolled up after child changes" (moved-in or created open child checked whatever the parent reads; every triggering verb relays the lines), "Changing a signed-off feature reverts it by surface" (confirmation names reopened containers and record lines); scenario added: new or moved work under a story closed on an unlanded record branch
- step 7 (amended after review) — `close.md` changes reverted (TASK-324); spawn.md step 8 relays new's lines; work-tracking requirement names move, creation (spawn included), decide revert and review park
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
