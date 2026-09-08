---
id: TASK-083
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-08-31
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-066-8]
pr: null
github-issue: null
jira-key: null
---

# `fix-next` step 8 states two different counts of the same event, one sentence apart

## Context

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

- [ ] The paragraph states the growth count **once**, or not at all, consistent with its own rule against writing a number into the sentence
- [ ] The `--unattended` shipping history survives as the worked example — it is the evidence for the rule and must not be lost with the duplicate count
- [ ] *"Read the table"* is instructed once
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `--unattended` contract table in `close.md` itself. It is correct; this is only about `fix-next`'s prose *about* it.
- Re-deciding whether step 8 should name a count at all — the paragraph already decided that, and this task makes the text match the decision.

## Human test plan

N/A — the defect and its fix are both visible in one paragraph read against itself, and the lint covers
structure. A drill would add nothing a careful read does not.

## Implementation plan

_Populated by `/tasks plan TASK-083` — leave empty until then._
