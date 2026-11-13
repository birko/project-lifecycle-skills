---
id: TASK-348
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-332-1, DRILL-332-2, DRILL-332-3, DRILL-332-4, DRILL-332-5, DRILL-332-6]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/tasks block`'s confirmation and the dashboard it chains leave six readings open

## Context

Spawned 2026-11-12 from TASK-332's Human test plan drill. One cold run of TASK-212's brief (`/tasks block TASK-002`,
no flags) was made on a fresh fixture, `%LOCALAPPDATA%/Temp/d332` (report kept there as `report.md`). **Raised by one
runner only**, so each is a candidate to confirm, not a measured defect (FEATURE-002 D10's bar is two). It is a group:
the readings are small and share one drill.

In `skills/tasks/verbs/block.md`:
- **DRILL-332-1:** step 3b's fallback says "say so in step 7: `blocked: reason unknown added (no reason given, nobody chose one) …`", while step 7 prints `blocked: <reason> added — status stays <state>`. Replace or add is unstated. The runner replaced.
- **DRILL-332-2:** step 7's "any `depends-on` added" does not say whether to print that none was.
- **DRILL-332-3:** `block` says nothing about committing. `cancel` and `block` do not commit (as `/fix-next` § *A run that ends without a fix* states), but `block` itself never says so.

In `skills/tasks/verbs/triage.md`, reached through the chained dashboard:
- **DRILL-332-4:** the `blocked` row's overlap note ("1 also counted in their own state") has no slot in the template's `{{TK_BLOCKED}}` cell. The runner put it inside the cell.
- **DRILL-332-5:** whether a blocked `todo` task counts in the "`todo` by priority" line. Taken tasks are excluded explicitly; blocked ones are not mentioned.
- **DRILL-332-6:** step 2 gives `—` for pairs that don't apply, but no value for an applicable pair with no items (`0` or blank).

## Acceptance criteria

- [x] Each of DRILL-332-1 … 6 is either confirmed by a second cold runner and then answered in the verb that owns it, or recorded here as not reproduced
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where `blocked:` and its note go, and the reason's order — TASK-332

## Human test plan

- [x] Re-run TASK-212's brief on a fresh fixture of its shape (recipe on TASK-212, fixture source `%LOCALAPPDATA%/Temp/d212/repo`) with a cold runner. Expected: none of the confirmed findings in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d348b`: a fresh copy of `d212/repo`, `skills/` at this fix, and
    TASK-212's brief, run with TASK-212's runner command plus `Write` and `Edit`.
    - **Coldness:** no skills listed and no Skill tool.
    - **Output:** it printed the 3b fallback line alone, and wrote `1 (1 also counted in its own state)` with every
      empty pair as `0`.
    - **Settled for the runner:** the note's wording, "that it replaces the usual note", and the blocked count.
    - **Not left undecided:** none of 332-1, 332-4 or 332-6.
    - **332-3 raised again** ("block.md never says whether to commit"). That makes two runners of three, so it met
      the bar and was answered at the close. It was not re-drilled.

## Implementation plan

Drafted 2026-11-13 by `/fix-next`, as `/tasks plan --no-grill` would write it (trigger: two files). It covers only the
readings a second cold runner confirmed (`%LOCALAPPDATA%/Temp/d348`, `report.md`):

| Reading | Second runner | Answer | Where |
|---|---|---|---|
| 332-1 | confirmed. It also asked which **note** the fallback writes, step 5's or 3b's | 3b's fallback line and note are step 7's and step 5's shapes with a stated suffix, and **replace** them | `block.md` 3b, 7 |
| 332-2 | not raised. It printed no `depends-on` line without `--on` and said why | — | — |
| 332-3 | not raised. It committed nothing and said so | — | — |
| 332-4 | confirmed, plus "their" for a count of one | the note goes inside the `blocked` cell, after the count; `its` for 1 | `triage.md` step 2 |
| 332-5 | not raised. It counted the blocked `todo` task in both rows from the stated rule | — | — |
| 332-6 | reproduced as an inference: it wrote `0` without a rule | an applicable pair with no items is `0` | `triage.md` step 2 |

## Outcome

**The fix.**
- **The no-reason fallback replaces, never adds.** `/tasks block`'s fallback, used when nobody gives a reason, now
  says that its note and its confirmation line replace step 5's note and step 7's line. Steps 5 and 7 each point back
  at it.
- **Block and unblock now say they commit nothing**, and name the files they leave uncommitted.
- **The dashboard's counts table** now writes `0` for an empty cell that applies, never a blank. The `blocked` row's
  overlap note goes inside its own cell, as `1 (1 also counted in its own state)`, with `its` for one task.

**Per reading** (the criterion: confirmed by a second runner, then answered, or recorded as not reproduced):

| Reading | d332 | d348 (current text) | d348b (fixed text) | Outcome |
|---|---|---|---|---|
| 332-1 replace or add | raised | raised, plus which note | settled | answered |
| 332-2 print "no `depends-on`" | raised | not raised | not raised | **not reproduced** |
| 332-3 commit | raised | not raised | raised | answered at the close (2 of 3) |
| 332-4 overlap note's cell | raised | raised, plus "their" for one | settled | answered |
| 332-5 blocked `todo` in the priority line | raised | not raised (counted it in both) | not raised | **not reproduced** |
| 332-6 empty cell | raised | inferred `0`, no rule | settled | answered |

**Step-6 split.** 5 of 5 assertions fail on `HEAD`'s copies and pass on the fix, all fix-dependent: the fallback
line, the fallback note, the overlap cell, zero, and no commit. The script is `task348-check.sh` in the session
scratchpad. Contract pin, **not evidence**: skills-lint.

**Judgement calls.**
- **The bar was applied as the task set it.** A reading one runner raises is a candidate, so 332-2 and 332-5 were left
  alone. Both runners after d332 read them the same way from the existing text, which is evidence the text already
  settles them.
- **Block commits nothing, by statement, not by a new behaviour.** That is what it already did, and what
  [[fix-next]] already relies on (it commits blocks itself). A block that committed would land a lone status flip
  in the middle of a person's work.
- **`0`, not blank,** because a blank cell in a counts table reads as "not computed".

**Close gate (inline, about 15 lines of prose over two verb files):**
- **Standards:** each rule is in the verb that owns it, and the `fix-next` reference is a pointer.
- **Intent:** criteria 1–2 met.
- **Correctness:** this repo's own dashboard already renders `1 (1 also counted in its own state)`, consistent with
  the new rule.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged, not fixed.** The d348 and d348b runners raised four more single-runner readings. All predate this task,
and none is filed:
- column padding after a placeholder fills;
- blank lines around an omitted section;
- whether tree rows show priority;
- the time zone of the timestamp.

## Progress log

- step 2 — picked; ranked above TASK-099 and TASK-102 because it is a group of drill readings in one verb that writes status (`block`), with the readings two runners raised at the agreement bar (key 5) and no open design question (key 4), while TASK-099 and TASK-102 each ask for a rule to be designed. All correctness-invariants (key 6 inert)
- step 3 — verified by a second cold runner (d348, TASK-212's brief on a fresh copy of d212, current skills/): confirmed 332-1 (plus which note), 332-4, 332-6; not reproduced 332-2, 332-3, 332-5
- step 3b — planned: drafted inline as /tasks plan --no-grill (two files)
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/block.md (3b fallback replaces step 5 note and step 7 line; both steps say so) and skills/tasks/verbs/triage.md step 2 (`0` for an empty applicable pair; blocked overlap note inside its cell, its/their); assertions in scratchpad task348-check.sh
- step 6 — reverted fix (HEAD copies): 4/4 assertions failed; fix-dependent = C1 fallback line, C2 fallback note, C3 overlap cell, C4 zero; contract pins = skills-lint. Behaviour: the d348 runner (current text) raised 332-1, 332-4 and 332-6; re-drill on fixed text running (d348b)
- step 7 — respecced work-tracking (surgical); requirements changed: Generated dashboard owned by triage (empty pairs, overlap cell), Blocking (fallback replaces the usual note and line); intended — TASK-348 criterion 1
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
