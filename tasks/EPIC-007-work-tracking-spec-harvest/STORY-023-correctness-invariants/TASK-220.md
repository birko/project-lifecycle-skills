---
id: TASK-220
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
findings: [SH-4, SH-5]
picked-by: fix-next
pr: null
github-issue: null
jira-key: null
---

# Two verbs leave a `blocked:` field behind that `audit` then reports

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). Both findings leave the same leftover: a
`blocked:` field nobody removes.

- **SH-4 — `cancel` keeps the field.** `skills/tasks/verbs/cancel.md` never mentions `blocked:`, so cancelling
  a blocked task writes `status: cancelled` beside its `blocked:` line — the contradiction
  `tasks/SKILL.md` § *Reading a task's status* says `audit` reports.
- **SH-5 — `audit --fix`'s "Unblock" does not unblock.** Its fix removes the satisfied id from `depends-on` and
  never clears the `blocked:` field, while `block.md`'s edge case says audit flags these as unblock candidates
  and the loop continues with `/tasks unblock`. One word, two meanings.

## Acceptance criteria

- [x] Cancelling a blocked task removes its `blocked:` field (the reason survives in the body note), and says so
      in the confirmation
- [x] `audit --fix`'s action either runs `unblock` — removing the field — or is renamed so it no longer claims to
      unblock; `block.md`'s edge case agrees with whichever it is
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `close`'s own blocked refusal — already built (TASK-214)

## Human test plan

- [x] On an invented tree, cancel a blocked task and run `audit`: no `contradiction` row for it
  - **Passed 2026-10-09:** fixture `%TEMP%\d220` (`single-branch`; TASK-002 `todo` with `blocked: waiting on TASK-001`), `echo '/tasks cancel TASK-002 --reason "…"' | claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" … --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills`, then `/tasks audit` the same way. Cancel removed the field, kept the `> Blocked` note and said so; audit reported 0 findings and named the contradiction check as clean. Not a cold runner and need not be: this step tests behaviour

## Outcome

**What was fixed:** `cancel` now removes a `blocked:` field when it cancels a task (step 5), and says so in
its confirmation. The block's reason survives in the body's `> Blocked` note. `audit --fix`'s merge
cancels the task it absorbs, so it clears the field the same way. `audit --fix`'s "Unblock" action is
renamed **Prune a satisfied dependency**, because all it ever did was edit `depends-on`. It now states
that it never removes `blocked:`. When a still-blocked task's dependencies are all satisfied, it prints
`TASK-NNN is still blocked: <reason> — every dependency is satisfied; run /tasks unblock TASK-NNN if that
was the reason`. `block.md`'s loop and the spec say the same.

**Step 6 split — 2/3 fix-dependent.** Cold A/B: one reader each on the HEAD and post-fix `cancel.md`,
`audit.md` and `block.md`, `cd C:/Source/WebChecker && claude -p --disable-slash-commands --add-dir
<scratchpad> < brief`; coldness not separately confirmed.
- *cancel a blocked task*: old → `blocked:` kept beside `status: cancelled`; new → removed.
- *audit's line for a still-blocked task*: old → `→ unblock TASK-011`, which `--fix` then does not do;
  new → the still-blocked line pointing at `/tasks unblock`.
- Contract pin: *TASK-011 after `audit --fix`* — both texts give `depends-on` pruned, `blocked:` kept,
  still blocked. The edit never changed; only its name and report did.

**Judgement calls:**
- *Rename rather than make `--fix` run `unblock`.* A block's reason can be more than the dependency
  ("waiting on TASK-009 and the vendor's answer"), and clearing someone's block is a decision about their
  reason, the same reason [[fix-next]] never unblocks. The task allowed either.
- *Cancel removes the field rather than refusing a blocked task.* Cancelling held work is legitimate; the
  reason is already recorded in the body, so nothing is lost.
- Left alone: `audit`'s prune contradicts `unblock`'s default of keeping `depends-on` as history. That is
  older and wider than this task. Noted here, not filed.

**Flagged, not fixed:** in hybrid mode `block` mirrors a label to the remote issue, and `cancel` closes the
issue without removing it. The closed issue keeps a stale "blocked" label. This is cosmetic and was not
measured.

## Implementation plan

_Populated by `/tasks plan TASK-220` — leave empty until then._

## Progress log

- step 2 — picked by the user (2026-10-09, "pick 220"); it was the runner-up named in TASK-292's ranking
- step 3 — verified, both hold: `cancel.md` steps 5/11 never mention `blocked:`; `audit.md` step 4 "Unblock" only removes a done id from `depends-on`, while `block.md` § unblock step 3 keeps `depends-on` as history unless `--clear-deps` — so the one word names two different edits
- step 4 — layer: local (`skills/tasks/verbs/cancel.md`, `audit.md`, `block.md`)
- step 5 — fix in `skills/tasks/verbs/cancel.md` (step 5 removes `blocked:`, step 11 reports it), `audit.md` (merge clears the field; "Unblock" → "Prune a satisfied dependency", still-blocked line), `block.md` (edge-case loop); spec `docs/specs/work-tracking.md` cancelling and audit requirements; lint OK
- step 6 — cold A/B: 2/3 fix-dependent (cancel of a blocked task; audit's line for a still-blocked task); contract pin: TASK-011's fields after `--fix`. Real fixture `%TEMP%\d220`: cancel then audit, no contradiction
- step 7 — `docs/specs/work-tracking.md` regen: cancel removes `blocked:`; audit's prune never does and names an unblock candidate; stamped `c366167`
- step 8 — Outcome written; closing to `done` (every manual step passed)
