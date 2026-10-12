---
id: TASK-222
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-6]
pr: null
github-issue: null
jira-key: null
---

# `new` and Jira import offer only P0–P2

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). `skills/tasks/verbs/new.md` step 5 asks for
"P0 / P1 / P2", and `import.md`'s Jira mapping maps the priority field to P0/P1/P2. Elsewhere the skill says the
opposite on purpose: the Collection pass buckets "one bucket per priority actually present" and warns that a
fixed set "silently drops any other value in use" (measured on this repo, which has P3 tasks), and `export`
handles `priority/<any value>`. So a P3 can be read and exported but never created or imported.

## Acceptance criteria

- [x] `new` accepts any `P<n>` priority, offering the common ones without limiting to them
- [x] Jira import maps priorities without collapsing anything below P2 into P2, and says what it does with a
      priority it cannot map
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Renumbering existing priorities
- Deferred to TASK-299 — `export --to jira` never says how a task's priority reaches the ticket

## Human test plan

N/A — a prompt's option list and a mapping table, checked by reading against the Collection pass and `export`.

## Implementation plan

_Populated by `/tasks plan TASK-222` — leave empty until then._

## Outcome

**What changed.** A new task could only be created as P0, P1 or P2, and a Jira import mapped the priority field
onto those three, so a P3 (or any lower level) was either refused or silently filed as P2, more urgent than it
is. The rest of the skill already reads and exports any priority. Now:
- `tasks/verbs/new.md` step 5 offers P0–P3 as the common values and writes any `P<n>` the user gives as given;
  `{{PRIORITY}}` says `P<n>`.
- `tasks/verbs/import.md` `--jira` step 3 maps through a table: a name already `P<n>` as given; Jira's default
  scheme Highest, High, Medium, Low, Lowest to P0–P4; anything else, or no priority, to `P1` with a `## Context`
  line saying nobody chose it. A new step 7 confirms the import and names every unmapped priority.
- Respecced `work-tracking`: the clause on creating tasks, the import requirement, and a new scenario
  *Unmapped Jira priority*.

**Step-6 split.** Both runs were cold drills (`claude -p --disable-slash-commands < brief`, run from
`C:/Source/WebChecker`, which has no agent guide; both answered `SKILLS-SEEN: none`) on one brief: create a task
where the user types P3, then import four Jira tickets with priorities Low, Lowest, Blocker and P3. The brief
carried the two verb files from `HEAD` (before) or the working tree (after), and did not say what was expected.
**Before the fix: 0 of 5 cases followed a rule. Four were written as P2 (the user's P3, Low, Lowest and the
ticket named P3), and Blocker was guessed as P0. After the fix: 5 of 5 followed the rule (P3, P3, P4, P1 with
its Context line, P3).** All five cases depend on the fix. The lint passes either way, so it is a contract pin,
not evidence.

**Judgement calls.**
- **Jira's default scheme maps by position, so `Medium` becomes P2 while `new`'s default is P1.** I did not shift
  the scale to make the defaults meet. A shift would either merge two Jira levels or leave a gap, and either one
  breaks the order the scheme itself defines.
- **An unmapped name gets the P1 fallback plus a written record, never a guess.** The old-text runner mapped
  Blocker to P0, which is plausible, but it is a reading of a name nobody declared, and a different scheme can
  use the same word differently. The field cannot be left absent because every ranking reads it, so this is
  the fallback shape that § *Output / prose rules* requires.
- **Added Jira step 7** after the new-text runner said nothing defined where the unmapped name is reported.
  Without it, the fallback's "name it" would point at no step.

**Flagged, not fixed.** `export --to jira` never says how a task's priority reaches the ticket, so an
export-then-import round trip has no defined route. Spawned as TASK-299 (FIELD-010) under STORY-023.

**Merge gate (close step 5b, run inline, each verdict on its own):**
- *Standards*: pass. The fallback writes the safest value and records beside it that nobody chose it, as the
  ask-step rule requires for a field every verb reads. The step-7 example key is invented. No new cross-cutting
  pattern.
- *Fidelity*: pass. Criterion 1 is `new.md` step 5, criterion 2 is the mapping table and its unmapped row, and
  criterion 3 is lint OK. Out of scope (renumbering) was left untouched.
- *Correctness*: one finding, fixed before commit, which is the missing Jira report step above.
- *Security* and *Comments*: not applicable, because the diff touches no security surface and carries no code
  comment.

## Progress log

- step 2 — picked; ranked above TASK-273 because a Jira import silently writes a wrong priority into the tree (P3 collapsed to P2, keys 1 and 3) where TASK-273 makes runs unreproducible without writing a wrong value, and both are self-contained correctness-invariants; TASK-298 sits below on key 4 (open design question)
- step 3 — verified: held — new.md step 5 and its {{PRIORITY}} line list P0/P1/P2 only; import.md --jira maps "Priority field → P0/P1/P2" with no rule for a fourth level or an unrecognised name, while the Collection pass and export take any value. Related gap found: export never says how priority reaches Jira (it defines labels for GitHub only) — out of scope, for the close sweep
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/new.md (step 5 and {{PRIORITY}}: any P<n> as given) and skills/tasks/verbs/import.md (--jira step 3 mapping table with a recorded P1 fallback; new step 7 confirmation naming every unmapped priority); no test harness — prose; lint green
- step 6 — cold pair on one brief (new task with "P3"; Jira import of Low, Lowest, Blocker, P3), both SKILLS-SEEN: none. Old text: 4/5 written as P2 (P3, Low, Lowest, P3 clamped), Blocker guessed as P0, 0/5 by rule. New text: 5/5 by rule (P3, P3, P4, P1 + Context line, P3). Fix-dependent = all five cases; contract pin = the lint (passes either way). The new runner found Jira mode had no report step for the unmapped name; step 7 added
- step 7 — respecced work-tracking; requirements changed: Creating epics, stories and tasks (any P<n> as given); Importing work (Jira priority mapping and fallback; new scenario: Unmapped Jira priority)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
