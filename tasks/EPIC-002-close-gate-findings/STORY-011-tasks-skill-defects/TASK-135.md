---
id: TASK-135
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
picked-by: fix-next
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

- [x] `/fix-next` step 2 (rescoped 2026-11-04 before any edit: a new step 3b, right after re-verification — a plan drafted at step 2 plans against a finding step 3 may rescope or reject) either drafts the plan or states, per task, why the task is small enough not to
      need one — matching what `/tasks pick` already does rather than inventing a second policy
- [x] The decision is **recorded in the `## Progress log`**, so a reset session can tell "planned" from
      "nobody looked"
- [x] Unattended behaviour is defined, per `AGENTS.md` § *An ask-step carries the question it puts and the
      answer-less path* — `fix-next` runs with nobody present by construction, so "offer it" is not an
      available answer here and the skill must say what it does instead
- [x] Whether `/tasks intake` should auto-run `plan` the way `/tasks new` does is **answered either way**,
      in writing — it is the upstream half of the same gap and leaving it unstated just moves the question
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-083:*

- [x] The paragraph states the growth count **once**, or not at all, consistent with its own rule against writing a number into the sentence
- [x] The `--unattended` shipping history survives as the worked example — it is the evidence for the rule and must not be lost with the duplicate count
- [x] *"Read the table"* is instructed once
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing what a plan contains, or `/tasks plan` itself — only who invokes it and when.
- [[TASK-127]]'s own missing plan; it is recorded there as a gap rather than backfilled, deliberately.

*From TASK-083:*

- The `--unattended` contract table in `close.md` itself. It is correct; this is only about `fix-next`'s prose *about* it.
- Re-deciding whether step 8 should name a count at all — the paragraph already decided that, and this task makes the text match the decision.

## Human test plan

AC1 resolved as prose in `fix-next` (step 3b) and `intake` still generates the same tasks, so per the line this replaces, this is a reviewer check against the two quoted rules: run as `/tasks close`'s standards and fidelity passes on 2026-11-04, recorded in § Outcome.

*From TASK-083:*

N/A — the defect and its fix are both visible in one paragraph read against itself, and the lint covers
structure. A drill would add nothing a careful read does not.

## Outcome

**What was fixed.** `/fix-next` picks its own work instead of going through `/tasks pick`, so it never reached the plan-first check. `/tasks intake` files every pool task with `--no-plan`, so every drained defect was implemented without a plan, against the rulebook's unconditional *plan before implementing*. **Measured 2026-11-04: 54 of 58 `todo` tasks carry the unfilled plan placeholder**, and this session's own seven earlier runs each closed with a "not drafted" note in its place.

- **New `fix-next` step 3b**, after re-verification: it applies `/tasks pick` step 6's own triggers (more than one file, three or more criteria, a `feature:` link, unknowns in Context). An existing plan is used as the brief. A task meeting any trigger is planned with `/tasks plan --no-grill`. A task meeting none goes unplanned, and the log says why. All three outcomes have a log line, so a reset session can tell "planned" from "nobody looked".
- **`intake` step 5 now states that `--no-plan` is deliberate.** That answers criterion 4: a pass files many tasks, and planning before re-verification plans against findings step 3 may rescope or reject.
- **The merged TASK-083 fix:** step 8's paragraph says "read the table" and "do not restate its count" once each, with no count, and keeps the `--unattended` shipping history as its example.

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills): a contract pin, not evidence.

**Judgement calls.**
- **Step 3b, not step 2.** Criterion 1 named step 2, and I rescoped it before any edit (annotated on the criterion). A plan written before re-verification plans against a target this skill's own step 3 changes in a real share of cases. Today's runs rescoped two of eight.
- **Plan on a trigger, rather than always.** "Always" is stricter, but it is a second policy, and the criterion asks for `pick`'s. A one-file wording fix gains nothing from a plan-agent spawn.
- **Unattended means plan, not skip.** `pick`'s offer defaults to yes, so with nobody to answer, skipping would turn silence into a decline.
- **`intake` stays `--no-plan`.** Auto-planning there was the alternative. I rejected it for the re-verification reason above and for cost: one planner spawn per filed task, most of them for tasks that turn out to be one-liners.

**Gap, recorded rather than backfilled.** This run reached step 4 before step 3b existed. TASK-135 meets the triggers (several files, nine criteria) and was implemented without a plan. A plan written now would only be a transcript of the work. The same holds for this session's earlier runs (TASK-325, -100, -318, -182, -321, -316, -314, -315, -327, -320).

**Respec.** `defect-draining`: a new requirement, *Plan after re-verifying, or record why not*, with two scenarios. `work-tracking`, the intake requirement: one sentence saying intake files without plans. The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** None beyond the gap above.

## Implementation plan

_Not drafted — the gap § Outcome records: this run reached step 4 before step 3b existed._

## Progress log

- step 2 — picked; ranked above TASK-212 because every fix-next run implements without a plan — measured on this session's own seven runs, each of which replaced the placeholder with a "not drafted" note — so it is reached on every drain (key 2) and silently skips a gate the rulebook calls unconditional (key 3); key 6 inert — both are correctness-invariants
- step 3 — verified: held, and rescoped: fix-next names /tasks plan nowhere; intake chains new with --no-plan, so every pool task arrives unplanned. The plan step is placed after step 3, not in step 2, since re-verification can rescope or reject the target (criterion 1 annotated). The merged TASK-083 holds: step 8 says "grown twice" and "grew once", and "Read the table" twice
- step 4 — layer: local (skills/fix-next/SKILL.md, skills/tasks/verbs/intake.md)
- step 5 — fix in skills/fix-next/SKILL.md (new step 3b; step 8 paragraph), skills/tasks/verbs/intake.md (step 5 --no-plan rationale); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh
- step 7 — respecced defect-draining, work-tracking; requirements changed: new Plan after re-verifying, or record why not (+2 scenarios), intake requirement (+1 sentence); intended anyway — TASK-135's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
