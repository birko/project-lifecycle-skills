---
id: TASK-209
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
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

- [ ] Rung 1 answers only when no later `> Unblocked … —` note follows the matched note; otherwise the next rung
- [ ] Rung 2 lists only dependencies that are neither `done` nor `cancelled`, and says what happens to an id not
      found in the tree
- [ ] A prior state found as `done` or `cancelled` is treated as "history cannot tell" (ask, or the `todo`
      fallback with its note)
- [ ] `block.md` places `blocked:` after the `status:` line and its indented `#` continuation lines, in the same
      words `init.md` uses
- [ ] A file with both `status: blocked` and a `blocked:` field keeps its existing field, has only `status:`
      rewritten, and the report names the reason kept
- [ ] The history-cannot-tell fallback states that the `blocked:` field is written too
- [ ] The tie-break states position versus date for equal dates and for rung 1, and the pointer forms cover a
      source with no heading above it and an undated note
- [ ] `block.md` step 5 says that `init` step 3b's reason rung 1 reads the note it writes (both sides of a
      format contract state it — raised as a note by TASK-208's conventions pass)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ladder's order (note → `depends-on` → judgement), decided by the owner on TASK-208
- The reason-shaping rules TASK-208 wrote and fixed at its close (example, quoting, label-only sources,
  continuation joining, sentence ends, symbol drop)

## Human test plan

- [ ] A cold drill of step 3b on an invented fixture covering each row above (no real repo: the cases are
      constructed, so none is contaminated): a resolved note, a cancelled and a missing dependency, a
      `done` prior state, a block on a multi-line status comment through `/tasks block`, a mixed-form file, an
      unanswered history question. Expected outcome per row is the criterion above; withhold it from the runner

## Implementation plan

_Populated by `/tasks plan TASK-209` — leave empty until then._
