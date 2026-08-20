---
id: TASK-044
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# EPIC-002 groups by subject, so `fix-next`'s theme tie-breaker has nothing to read

## Context

Filed by `/code-review` at TASK-040's close gate.

`/tasks intake` step 5 (`skills/tasks/verbs/intake.md:92-98`) mandates a **fixed seven-theme ladder**
for the stories it creates:

> security & tenancy → correctness & invariants → data integrity → contract drift → performance →
> reuse & dead code → docs, i18n & coverage

and says to keep that order because **it doubles as [[fix-next]]'s tie-breaker**. `fix-next` confirms
it from the other side (`skills/fix-next/SKILL.md:124-125`): *"Ties break on the intake theme ladder …
then `priority:`, then oldest `created`."* It is ranking key 6 of 6.

EPIC-002 groups its six stories by **the skill each defect lands in** instead — `verify-conventions`,
`tasks`, the universal layer, `roadmap`, `specs`, CI. That grouping is genuinely useful here: it keeps a
drain session inside one skill's surface instead of ping-ponging across the set, and these findings
arrived from many passes over three days rather than from one pass with a shared severity scale.

**But it silently disables a ranking key.** No story under EPIC-002 maps to a ladder theme, so when
`fix-next` reaches key 6 it has nothing to match and falls through to `priority:` then `created`. All
20 tasks are P2/P3 prose defects with broadly similar blast radius, which is exactly the tie condition
key 6 exists to break — so the degradation is likely, not hypothetical. Worse, it is **silent**: nothing
reports that a ranking key was inert, so the ordering looks deliberate.

A related question the fix must not dodge: `skills/tasks/SKILL.md`'s router row describes `intake` as
producing *"STORYs by severity theme"*, which is **not** what the verb does — the ladder is a subject
ladder and severity maps to `priority:` instead. That one-liner is what led to this grouping being
justified against a rule that does not exist. Under *a verb owns its rules* the verb file wins, so the
router line is wrong and should be corrected whichever way this decision goes.

## Acceptance criteria

- [ ] The choice is made and recorded with its rationale: **regroup** EPIC-002's stories onto the
      ladder, or **let a story declare its ladder theme** so subject grouping and the tie-breaker can
      coexist, or **accept the deviation** and say plainly that key 6 is inert for this epic
- [ ] Whichever is chosen, `fix-next`'s ranking is never left silently short a key — if a key cannot
      apply, the ranking paragraph it prints says so
- [ ] If the "declare a theme" route wins, the declaration is machine-readable rather than prose —
      `fix-next` already carries a note that a prose marker beat it once (its DV12 carve-out) and that
      a machine-readable marker would have been better
- [ ] `skills/tasks/SKILL.md`'s router row for `intake` no longer says "by severity theme"
- [ ] If the ladder itself should admit subject grouping for adopted backlogs, that change lands in
      `intake.md` step 5 — not as a local exception in this epic

## Out of scope

- **Re-homing tasks again.** TASK-040 placed them; if regrouping wins, that is this task's own work,
  but no task's body changes and no id is reassigned.
- Changing `fix-next`'s other five ranking keys.
- **This is a decision task.** [[fix-next]] excludes anything whose acceptance is *"decide X"* from its
  pool, so it will surface this rather than pick it — that is correct, and it is why the acceptance
  above puts the decision first and the edits second.

## Human test plan

- [ ] After the change, run `/fix-next` against EPIC-002 and read its ranking paragraph: confirm it
      either names the ladder theme that broke the tie, or states that the key did not apply
- [ ] Confirm two tasks from different stories that tie on every other key resolve in a defensible,
      explainable order — and that a reader can tell *why* from the printed paragraph alone

## Implementation plan

_Populated by `/tasks plan TASK-044` — leave empty until then._
