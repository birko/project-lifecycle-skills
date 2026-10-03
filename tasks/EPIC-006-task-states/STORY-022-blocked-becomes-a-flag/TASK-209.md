---
id: TASK-209
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: [TASK-208]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-132, CR-133, CR-134, CR-135, CR-136, CR-137, CR-138]
pr: null
github-issue: null
jira-key: null
---

# Edge cases in the blocked-field writers that predate the reason ladder

## Context

Spawned from TASK-208's close (2026-10-03). Its correctness pass reviewed `skills/tasks/verbs/init.md` step 3b
after the reason ladder was rewritten and raised ten findings. The ones about the text TASK-208 wrote were fixed
there. These seven are older than that change, or sit in a neighbouring writer, so they are filed here as **one
group**: each is small, and all of them are about how a `blocked:` field is written or what it is written from.

| Id | Where | Failure scenario |
|---|---|---|
| CR-132 | `init.md` 3b, reason rung 1 | A file with `> Blocked <d1> — X` and a later `> Unblocked <d2> — …`, hand-set back to `status: blocked` with no new note, gets `blocked: X` — a reason the file itself says is resolved, reported as the reliable-sounding `note` rung. Rung 3 already excludes resolved blocks; rung 1 does not |
| CR-133 | `init.md` 3b, reason rung 2 | A `cancelled` dependency counts as "not done", so the field says `waiting on` a task that will never finish (`block.md`'s own edge case calls that a cancel or re-scope). A `depends-on` id that does not exist in the tree has no defined handling. The **order** of rung 2 before rung 3 is the owner's grill decision on TASK-208 and is not in question |
| CR-134 | `init.md` 3b, prior state | Prior state is "the most recent `status:` other than `blocked`". A task closed `done` and later hand-set to `status: blocked` becomes `status: done` plus `blocked:` — the contradiction `SKILL.md` § *Reading a task's status* says `audit` reports, and the task drops out of every active view. Same for `cancelled` |
| CR-135 | `skills/tasks/verbs/block.md` step 4 | `block` still writes `blocked:` "on the line after `status:`". On a file whose status comment continues on indented `#` lines that splits the comment — the defect TASK-208 fixed in `init`. Two writers, two placements |
| CR-136 | `init.md` 3b | A file carrying both `status: blocked` and a `blocked:` field (a hand edit or an interrupted run) is not in the new form, so 3b runs and adds a second `blocked:` key — a duplicate key strict YAML rejects |
| CR-137 | `init.md` 3b, the history-cannot-tell fallback | "Write `status: todo`, and add the body note" never says the `blocked:` field is written too. Read literally, the task loses its block and enters "Next up" with nobody choosing that |
| CR-138 | `init.md` 3b, rung 3 tie-break and pointers | Two candidates with the same date have no rule beyond "first in the file"; rung 1's "newest note" does not say by date or by position when they disagree. The pointer forms do not cover a body line with no heading above it, or an undated `>` note |

## Acceptance criteria

- [x] Rung 1 answers only when no later `> Unblocked … —` note follows the matched note; otherwise the next rung
- [x] Rung 2 lists only dependencies that are neither `done` nor `cancelled`, and says what happens to an id not
      found in the tree
- [x] A prior state found as `done` or `cancelled` is treated as "history cannot tell" (ask, or the `todo`
      fallback with its note)
- [x] `block.md` places `blocked:` after the `status:` line and its indented `#` continuation lines, in the same
      words `init.md` uses
- [x] A file with both `status: blocked` and a `blocked:` field keeps its existing field, has only `status:`
      rewritten, and the report names the reason kept
- [x] The history-cannot-tell fallback states that the `blocked:` field is written too
- [x] The tie-break states position versus date for equal dates and for rung 1, and the pointer forms cover a
      source with no heading above it and an undated note
- [x] `block.md` step 5 says that `init` step 3b's reason rung 1 reads the note it writes (both sides of a
      format contract state it — raised as a note by TASK-208's conventions pass)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ladder's order (note → `depends-on` → judgement), decided by the owner on TASK-208
- The reason-shaping rules TASK-208 wrote and fixed at its close (example, quoting, label-only sources,
  continuation joining, sentence ends, symbol drop)
- Deferred to TASK-212 — four older gaps in `block` and `init` 3b found by this close's review (block's reason question, its stale auto-unblock sentence, its references to this repo's records, the pointer for a heading source)

## Human test plan

- [x] A cold drill of step 3b on an invented fixture covering each row above (no real repo: the cases are
      constructed, so none is contaminated): a resolved note, a cancelled and a missing dependency, a
      `done` prior state, a block on a multi-line status comment through `/tasks block`, a mixed-form file, an
      unanswered history question. Expected outcome per row is the criterion above; withhold it from the runner

## Implementation plan

_Drafted at pick, 2026-10-03, by the agent that wrote TASK-208's ladder; grill skipped — every row is a
named defect with its fix already chosen by its criterion. Two files: `skills/tasks/verbs/init.md` step 3b
and `skills/tasks/verbs/block.md` steps 4–5._

1. **CR-132 — rung 1 skips a resolved note.** Row 1 of the reason table gains: *"and no later
   `> Unblocked <date> —` note follows it"* (later by date, else by position). Otherwise the next rung.
2. **CR-133 — rung 2's set.** "not `done`" becomes "neither `done` nor `cancelled`". An id not found in the
   tree is kept in the list as written (it is still what the file says the task waits for) and named in
   the report as unresolved — dropping it would lose the only stated reason.
3. **CR-134 — a `done`/`cancelled` prior state.** Add it to the *history cannot tell* conditions, with its
   own question text, since "blocked before its history begins" would be false:
   > **TASK-NNN was `<done|cancelled>` before it was blocked: "<reason>". Had work on it started again?**
   Same two answers, same no-answer fallback.
4. **CR-137 — the fallback writes the field.** "write `status: todo` **and the `blocked:` field as above**,
   and add the body note".
5. **CR-136 — mixed form.** Before the `status: blocked` branch: a file that already carries a `blocked:`
   field keeps it unchanged; only `status:` is rewritten (prior state as usual), and the report says
   *kept existing reason*. Prevents a duplicate key.
6. **CR-138 — tie-break and pointers.** Equal dates → first in the file. Rung 1's "newest note" → the
   latest date written in it, else the last in the file. Pointer forms gain ` (full text in the body)` for
   a source under no heading and ` (full text in the note)` for an undated note.
7. **CR-135 — `block.md` step 4 placement**, in the same words as `init` 3b: after the `status:` line and
   every indented `#` line continuing its comment.
8. **`block.md` step 5 contract line:** its note is what `init` 3b reason rung 1 reads, so keep the shape
   `> Blocked <date> — <reason>`.
9. Lint, then the drill (human test plan): an invented git fixture with one task per row, history included
   (a task that went `done → blocked`, one with a resolved note, a cancelled and a missing dependency, a
   mixed-form file, one created blocked with nobody to answer), and one `/tasks block` on a task with a
   multi-line status comment. Two cold runners, `claude -p --disable-slash-commands`, outside any
   project; the brief withholds the expected outcomes. Constructed cases, so none is contaminated.

## Progress log

- 2026-10-03 — Picked (in place; single-branch). Plan drafted at pick, grill skipped (each row a named defect with its fix fixed by its criterion). Edited `init.md` 3b (rung 1 skips a note a later Unblocked note resolves; rung 2 excludes cancelled deps and keeps a missing id, reported unresolved; mixed-form files keep their field; a done/cancelled prior state asks its own question; the fallback writes the field; tie-break and pointer forms) and `block.md` (placement after continuation lines; step 5 states that `init` reads its note). Lint OK.
- 2026-10-03 — Drill: invented git fixture `%TEMP%\d209base` (7 commits; TASK-001…006, -010, -011), oracle written before the runs at `%TEMP%\d209-oracle.txt`. Two cold runners, same command as TASK-208's, sandboxes `d209a`/`d209b`, run concurrently. Discovered while reading: `block.md` step 5's "Ask for one line" has no question text and no answer-less path — outside this task's criteria, to be spawned at close.
- 2026-10-03 — Drill result: **both runners match the oracle on every file and agree with each other** (cold: no skills listed, no prior exposure). Raised by both, settled in the prose: where the Migrated note goes (end of body), which pointer an undated note under a heading takes (the note), whether the question shows the pointer (no). Raised by one and fixed because the text was plainly wrong: the Migrated note said "not found in history" when history found `done` (now a second wording — this changes TASK-003's note text from what the runners wrote); rung 1's tie-break mentioned undated notes it can never match. Reports and oracle at `%TEMP%\d209reports`; sandboxes removed. Close review passes running.
- 2026-10-03 — Close, step 5b, first round. **Standards:** fail — 1 blocker (unblock's note, now read by init, had no shape contract) and 3 warnings; all fixed (contract line on unblock step 5; mixed-form `<reason>` and fallback; done-case rationale; pointer forms as a table). **Intent:** 8/9 — criterion 5 partial (report did not print the kept reason) → fixed; four drill-driven additions recorded here (question reason without pointer, fallback note placement and date, the done-case note wording, the unblock contract line) plus one from the correctness pass (a third answer, *still done*, so a task wrongly set to blocked is not forced to reopen). **Correctness:** 8 findings introduced by the diff — fixed: unblock gets its own no-answer path (never init's, which writes `blocked:`), mixed-form fallback, Unblocked ordering by date and through emphasis, unblock note contract, last-note pointer, third answer; declined: a missing id stays in the reason as written (the plan's choice; the report names it). Pre-existing ones go to the task spawned at close. **Security / comments:** not applicable — skill prose only, no code comments. The prose changed after the drill, so re-drilled on the final text (fixture rebuilt, plus TASK-007 for the mixed-form fallback; oracle `%TEMP%\d209-oracle2.txt` written first).
- 2026-10-03 — Re-drill on the final text (sandboxes rebuilt, TASK-007 added): **both runners match oracle2 on all 9 files and agree with each other** (cold: no skills listed, no prior exposure). TASK-007: one `blocked:` line kept, quoted in the question, reported *fallback, unchosen; kept existing reason*. Raised by one reader only, recorded: the blank line before an appended note; whether dropping a trailing full stop counts as a cut for the pointer. Out-of-scope sweep: 3 boundaries (ladder order; TASK-208's shaping rules; TASK-212), 1 spawned — TASK-212 (VC-055, CR-139, VC-056, CR-140). Closed `done` (single-branch: done = on main).
