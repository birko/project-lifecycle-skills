---
id: TASK-107
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-106]
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# The acquisition-line rule will have no enforcement point, so a drill record can omit it silently

## Context

**Spawned from TASK-106 while planning it, 2026-09-08.** That task adds a rule to
`skills/populate-tests/SKILL.md` § *The cold drill*: a drill record must name **how the runner was
obtained** — the command, the cwd, and the result of the coldness check — so *"was this reader cold"*
is answerable afterwards instead of assumed.

TASK-106 states that rule **once, in the method owner, and deliberately adds no second copy.** That was
the right call for that task and it leaves this gap: nothing consumes the record, so a drill written
without an acquisition line passes every gate it meets.

### Why this is a real gap and not a tidiness complaint

The rule exists because a record already failed this way. TASK-079's progress log describes its two
readers as *"given only the names and titles — no repo, no files"* — a sentence about **the brief**,
silent about the channel that actually decides. Those two readers can no longer be classified, and
nothing can reconstruct it. A rule that permits exactly the sentence that caused the problem, and
checks nothing, will permit the next one.

This repo has a name for the shape: a documented rule with nothing that can pin it is what **TASK-084**
files as a defect in a different corner of the same skill set.

### Where it would land, and why TASK-106 declined to put it there

Two consumers already point at § *The cold drill* and would be the enforcement points:

| File | Role |
|---|---|
| `skills/tasks/verbs/close.md` step 5 | accepts a `## Human test plan` result and decides `done` vs `review` |
| `skills/tasks/templates/TASK.md` | where the record is written in the first place — the plan section's own note about cold readers already lives here |

TASK-106's argument for declining: written in the same change, they become a **third copy** of a rule
the owner had just gained, and collapsing three copies into one was TASK-068's whole point. That
argument is about *timing and shape*, not about whether the enforcement should exist — which is what
this task settles.

**The open design question this task must answer first, before any editing:** whether the template
gains a *slot* (a prompt the writer fills, which cannot verify anything) or `close` gains a *check* (a
gate that can refuse) — or both. They fail differently: a slot left blank is invisible, a check over
prose is trivially satisfied by any keyword. TASK-106 already measured that a **lint** check is not
viable here (drill records live in `tasks/`, which the lint never reads; the false-positive and
false-negative rates both make it mutable noise). Do not re-derive that.

## Decision (2026-11-15, the user)

**Both: a template reminder and a `close` check, each with its limit stated beside it.**
- **The template note** (`templates/TASK.md`, the Human test plan hint): a drill step's `Passed` line records how
  its runner was obtained. It prompts at the moment of writing; **it verifies nothing.**
- **The `close` check** (step 5): a drill step ticked passed without the command, the working directory and the
  coldness check's result is asked about; unanswered or unattended, it is unticked with a dated `Incomplete` line,
  reads *not run*, and the task parks at `verify`. **It tells a missing record from a present one, never a true one
  from a false one**; only the record's reader can judge that.
- **The moment it matters** is the close: after it the task is `done` and no gate reads the record again.
- **The rule stays in one place**, `populate-tests` § *The cold drill*; both additions point at it, and that section
  now names where it is checked.

## Acceptance criteria

- [x] A decision is recorded — template slot, `close` check, or both — with the reason, and with what — the Decision above
      each does *not* catch stated alongside it
- [x] Whatever is chosen is implemented in the file that owns it, as a **pointer to § *The cold drill***, — `close.md` step 5 and `templates/TASK.md`, each pointing at § *The cold drill*
      never a second statement of the rule
- [x] A drill record with no acquisition line is distinguishable from one that has it, at the moment it — at the close; d107 shows the two records ending `done` and `verify`
      matters — state which moment that is
- [x] The rule and its enforcement half do not disagree: § *The cold drill* is amended in the same change — the rule's requirement is unchanged; § *The cold drill* gained one line naming where it is checked
      if the enforcement point changes what the rule requires
- [x] `bash .github/workflows/skills-lint.sh` passes, and `skills-lint-test.sh` gains a case **only if** — OK (20 skills); no lint case, as the mechanism is not lint-visible (TASK-106's conclusion stands)
      the chosen mechanism is actually lint-visible — TASK-106 concluded it is not, so a change here
      means that conclusion moved and the task says why

## Out of scope

- **Stating the rule itself** — TASK-106 owns § *The cold drill* and its wording. This task adds the
  point that consumes it, and `depends-on` names it because enforcing a rule that does not exist yet is
  not possible.
- **Re-opening whether a lint check is viable.** Measured in TASK-106; treat it as settled unless the
  chosen mechanism changes what is visible to the lint.
- **Auditing existing drill records for missing acquisition lines.** A backfill sweep is its own task if
  anyone wants one; TASK-106 annotates the single record it measured.

## Human test plan

- [x] Write a drill record that omits the acquisition line and take it through the chosen mechanism.
  - **Passed 2026-11-15**, cold runner: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d107`, the cwd holding only `brief.txt`, a copy of `skills/tasks` and an invented repo with
    two loose tasks, each with one ticked drill step: TASK-001's record names the command, the directory and the
    probe, TASK-002's does not. The coldness probe listed no skills. Both closed `--unattended`: TASK-001 → `done`;
    TASK-002 → `verify`, unticked with *Incomplete 2026-11-15: drill record names no command, working directory or
    coldness-check result*. Its other readings concern the fixture (an empty out-of-scope bullet, a duplicate
    title) or behaviour this change did not touch.
      Expected: it is refused, or the gap is visible at the moment the criteria name — not merely
      "documented somewhere". If the mechanism cannot tell the two records apart, it has not been built.

## Implementation plan

Inline, from the decision above.

## Outcome

- **`skills/tasks/verbs/close.md` step 5:** the check, its question, its answer-less path and what it does not
  catch; step 2's `--unattended` table gains the row for it (a new ask must have one).
- **`skills/tasks/templates/TASK.md`:** the reminder in the Human test plan hint.
- **`skills/populate-tests/SKILL.md` § *The cold drill*:** one line naming where the record is checked.

**Close gate (inline; three skill files, two specs):**
- **Standards:** the rule stays in its owner, both additions point at it; the new ask carries its question and
  answer-less path, and its `--unattended` row.
- **Intent:** all criteria met.
- **Correctness:** d107.
- **Layer parity, security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** work-tracking (the check, one scenario), test-authoring (a close counts a drill pass only with it).

## Progress log

- step 2 — picked; a decision task, in the user's order (after TASK-084)
- step 4 — decided by the user 2026-11-15: both
- step 5 — close step 5 and its unattended row, the TASK template, the cold drill section
- step 6 — behavioural: d107; lint green
- step 7 — respecced work-tracking, test-authoring
- step 8 — closed inline; commit in git log
