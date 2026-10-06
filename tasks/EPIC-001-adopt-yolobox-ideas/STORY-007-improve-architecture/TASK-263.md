---
id: TASK-263
parent: STORY-007
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-06
depends-on: []
blocks: [TASK-078]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `improve-architecture`'s candidate key is unstable, and most rejections can never be re-checked

## Context

Found while doing **TASK-077**, by its cold drill (2026-10-06, a `ClientApi.CSharp` clone) and its correctness
review. These are defects in the scan and the gate (Steps 1, 4 and 5 of `skills/improve-architecture/SKILL.md`),
which TASK-076 built. TASK-077 owns only the report, so they are filed here rather than widening it.

- **The key is unstable across runs.** A key is `<n>:<path>`. The drill had two candidates on one main file and
  class, which collided, and it improvised a member suffix. A suffix added only "when two share a file" depends on
  what one run happened to find. Run A files `2:src/Client.cs`; run B finds two members in that file, keys them
  `#OnError` and `#Send`, and Step 1 matches neither to A's task. So no `recurs after`, no `already filed`, and a
  duplicate is filed.
- **Rejections carry no key.** The dropped-entry line (stated on both sides: `intake.md` step 3 and this skill's
  Step 5) begins with a bare `<path>`. Two rejected members of one file, or two classes, collide in the durable
  record, and Step 5's re-check keys on the path alone. The same holds for "Previously rejected".
- **Only deletion-test rejections are re-checked.** Step 5's re-check covers "each deletion-test rejection", and an
  item-4 rejection by implication. A rejection from classes 1, 3, 4 or 5 (the drill hit one: a co-change pair whose
  cause a later rewrite removed) is recorded but never re-checked. Its `callers:` slot is undefined, so the next
  run either raises it again or suppresses it forever.
- **Classes 1 and 4 have no rejection path** for a signal that fails on a closer look. The drill had to invent one.

## Acceptance criteria

- [ ] The key is stable across runs: `#<member>` is part of it whenever the candidate concerns one member rather than the whole file, never only when another candidate shares the file
- [ ] Every rejection entry begins with the candidate's key, in this skill's Step 5 and in `skills/tasks/verbs/intake.md` step 3 alike (both sides of the contract change together), and "Previously rejected" carries the key too
- [ ] Every rejection except `held by ADR` is re-checked by Step 5, and the `callers:` slot is defined for each gate: the paths the verdict turned on (callers, implementations, co-change partners, the callers of the function or interface)
- [ ] Classes 1, 3, 4 and 5 have a rejection path for a signal that does not hold on a closer look
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The report's shape (TASK-077) and the intake handoff that writes the key onto filed tasks (TASK-078)

## Human test plan

- [ ] Run the pass twice on the same scratch clone (a cold runner, as in TASK-076 and TASK-077), with the first run's rejections pasted in as an earlier intake epic's dropped list. Confirm the second run reports every unchanged rejection as `previously rejected, unchanged`, including one from a class other than 2. Then change one rejected file and confirm only that one is re-tested

## Implementation plan

_Populated by `/tasks plan TASK-263` — leave empty until then._
