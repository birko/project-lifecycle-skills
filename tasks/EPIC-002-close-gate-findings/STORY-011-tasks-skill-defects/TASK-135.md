---
id: TASK-135
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-127]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-066-8]
pr: null
github-issue: null
jira-key: null
---

# `/fix-next` picks a task without ever offering the plan `/tasks pick` would have offered

## Context

Found 2026-09-17 by the `/verify-conventions` pass at [[TASK-127]]'s close gate, against this repo's own
rulebook.

`AGENTS.md` § Working rules is unconditional:

> **Plan before implementing.** A non-trivial task gets its `## Implementation plan` before work starts.

[[tasks]] SKILL.md § Lifecycle says who enforces that:

> `new` auto-runs [plan](verbs/plan.md) for tasks, and `pick` offers it for any task that reached work
> without one (default **yes**; decline only for genuine one-liners).

**`/fix-next` does its own picking and inherits neither.** Its step 2 writes `status: in-progress`,
`picked-by:` and the first `## Progress log` line directly, then goes to step 3 (re-verify) and step 5
(fix). No step drafts or offers a plan, and `/tasks plan` is named nowhere in the skill. So every
`fix-next` run on a task filed by `/tasks intake` — which does **not** auto-run `plan` the way
`/tasks new` does — implements a non-trivial task with the placeholder still in the file.

### Observed

TASK-127 closed with `## Implementation plan` reading *"Populated by `/tasks plan TASK-127` — leave empty
until then."* after a full nine-site change across five files. The gate caught it at close, which is the
wrong end: by then a plan can only be a transcript of the work, and backfilling one is the
"acceptance list becomes a transcript" defect arriving through a different section.

**Measured**: of the 33 `todo` tasks in the pool at that run, **spot-check how many carry an unpopulated
plan placeholder** — the answer is the size of this defect, and it should be in the fix's record.

### Merged in 2026-09-26: TASK-083 — `fix-next` step 8 states two different counts of the same event, one sentence apart

_Merged because both edit skills/fix-next/SKILL.md. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-083.md`._

**Spawned from TASK-066's close gate on 2026-08-31** (`/code-review`).

`skills/fix-next/SKILL.md` § *Step 8* now reads, within one paragraph:

> **Read the table for the count; do not restate it here** — it has grown **twice**, and a number written
> into this sentence is wrong the next time it grows. Read that table rather than assuming this step knows:
> it grew **once** already, because the flag first shipped covering only the out-of-scope sweep while 5c
> still asked a mandatory question…

Two counts of the same event, and the instruction *"Read the table"* appears twice in as many sentences.

**Why a wording slip is a real defect here.** The prose *is* the product — an agent reading this cannot tell
which count is current, and the paragraph's own argument is that a hard-coded number rots. Stating the number
twice, differently, while arguing against stating it at all, is the strongest possible demonstration of the
point and the weakest possible instruction.

The likely cause is an edit that added the newer general warning without removing the older specific one. The
fix is to keep **one** — almost certainly the general "read the table, don't restate the count" form, with the
concrete `--unattended` history kept as the *example* and its count dropped.

- **Linked from a [[code-review]] pass 2026-09-08 (CR-8), same sentence-region, one edit:** `skills/fix-next/SKILL.md:258` also carries a stutter — *"**Read the table for the count; do not restate it here** — it has grown twice… Read that table rather than assuming this step knows"*. The second clause is pre-edit residue duplicating the first.

## Acceptance criteria

- [ ] `/fix-next` step 2 either drafts the plan or states, per task, why the task is small enough not to
      need one — matching what `/tasks pick` already does rather than inventing a second policy
- [ ] The decision is **recorded in the `## Progress log`**, so a reset session can tell "planned" from
      "nobody looked"
- [ ] Unattended behaviour is defined, per `AGENTS.md` § *An ask-step carries the question it puts and the
      answer-less path* — `fix-next` runs with nobody present by construction, so "offer it" is not an
      available answer here and the skill must say what it does instead
- [ ] Whether `/tasks intake` should auto-run `plan` the way `/tasks new` does is **answered either way**,
      in writing — it is the upstream half of the same gap and leaving it unstated just moves the question
- [ ] `bash .github/workflows/skills-lint.sh` passes

*From TASK-083:*

- [ ] The paragraph states the growth count **once**, or not at all, consistent with its own rule against writing a number into the sentence
- [ ] The `--unattended` shipping history survives as the worked example — it is the evidence for the rule and must not be lost with the duplicate count
- [ ] *"Read the table"* is instructed once
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing what a plan contains, or `/tasks plan` itself — only who invokes it and when.
- [[TASK-127]]'s own missing plan; it is recorded there as a gap rather than backfilled, deliberately.

*From TASK-083:*

- The `--unattended` contract table in `close.md` itself. It is correct; this is only about `fix-next`'s prose *about* it.
- Re-deciding whether step 8 should name a count at all — the paragraph already decided that, and this task makes the text match the decision.

## Human test plan

N/A pending AC1's shape — if the fix is prose in `fix-next` step 2, this is a reviewer check against the
two quoted rules. If it changes what `intake` generates, that is a drill-worthy change and this line is
replaced with one per `AGENTS.md` § Testing.

*From TASK-083:*

N/A — the defect and its fix are both visible in one paragraph read against itself, and the lint covers
structure. A drill would add nothing a careful read does not.

## Implementation plan

_Populated by `/tasks plan TASK-135` — leave empty until then._
