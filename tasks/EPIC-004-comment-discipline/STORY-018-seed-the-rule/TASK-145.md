---
id: TASK-145
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: cancelled
priority: P1
assignee: unassigned
created: 2026-09-18
depends-on: [TASK-140, TASK-147]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Stop the scaffolder's "leave as-is" list going one short

> **Cancelled 2026-09-19 — the work shipped, the remaining criterion became unmeetable.** The fix is
> in `5b8c216` and survives at `skills/new-project/SKILL.md:93` (reworded by TASK-147, same derived
> rule): the enumeration of which sub-blocks to preserve is gone, replaced by *"leave every subsection
> carrying no `{{…}}` token exactly as written"*, which cannot go one short.
>
> **Why cancelled rather than closed `done`:** criterion 3 asked that the new `### Comments` subsection
> be preserved by that rule without being named in it. It cannot be — TASK-147 moved all three static
> subsections out of `CLAUDE.seed.md` into `templates/CONVENTIONS-universal.md`, so the seed now has
> **zero** token-free subsections and the preserve rule protects nothing. Measured 2026-09-19. Writing
> new criteria to fit what shipped is the move `close` forbids, so the honest state is cancelled with
> the work recorded, not `done` over a criterion nobody can meet.
>
> **The sentence stays in `SKILL.md` regardless.** It costs one line and it is the correct instruction
> the moment anyone adds a static subsection back to the seed — which is exactly the situation that
> produced this defect. Do not delete it as dead prose.
>
> Superseded premise retained below for the trail. The wording fix is written and correct, but its own drill proved the
> instruction is not followed at all: a cold scaffold run dropped **all three** static subsections,
> including the two the old sentence named by name. The list was never the defect. TASK-147 owns the
> real one; re-run this task's drill once it clears. Acceptance criteria 1–4 are met and ticked.

## Context

Discovered while drafting the implementation plan for **TASK-140**, not by a review pass.

`skills/new-project/SKILL.md:89` tells the scaffolding agent which parts of `CLAUDE.seed.md` are
universal and must survive rendering untouched. It names them: *"Leave the register-on-introduce +
working-rules sub-blocks as-is."* TASK-140 adds a **third** static sub-block (`### Comments`), and
that sentence will not mention it.

**This is the restated-list defect this repo lints for, arriving in its own house.** AGENTS.md
§ *Defer to a shared inventory* gives the test in one question — *would this sentence become wrong
if the file gained a row tomorrow?* Here the answer is yes, and the row is being added by the very
task that exposed it. The failure mode is the quiet one the rule describes: nothing signals it, the
scaffolder is simply licensed to paraphrase, reorder or drop a block it was never told to preserve,
and the loss shows up per-project, in consumer repos, with no diff here to notice.

The fix is to make the sentence unable to go stale rather than to add a third name to it — an
enumeration with three names goes one short exactly as readily as one with two. The proposed form
is *"Leave every subsection that carries no `{{…}}` token as-is"*, which is derived from the file
rather than remembered about it.

Also re-read `skills/new-project/SKILL.md:90` while in there — it already says every subsection
either carries a real rule or is removed, never a dangling `{{…}}`. The new subsection satisfies it
as written; confirm that rather than assume it, and change nothing if so.

## Acceptance criteria

- [x] `skills/new-project/SKILL.md:89` no longer enumerates which static sub-blocks to preserve.
- [x] Its replacement is **derived** — a reader can apply it to a subsection added tomorrow without this file being edited again.
- [ ] The new `### Comments` subsection is preserved by that rule without being named in it.
- [x] Line 90 re-read and confirmed correct as written; any change to it is in this diff with a reason.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The rule's own wording — TASK-140.
- `skills/adopt-project/INFER.md`'s per-subsection inference list. Adding a Comments row there would make the adopter infer a prose rule from code, which is the precedent FEATURE-002 D5 exists to prevent.

## Human test plan

- [ ] Scaffold a throwaway project with `/new-project` after TASK-140 has landed. Expected: the generated `CLAUDE.md` carries the `### Comments` subsection with its wording intact — not paraphrased, not reordered, not dropped.
- [ ] Repeat with a stack that produces a lot of `{{CODE_STRUCTURE_RULES}}` content, so the renderer has real work to do in the neighbouring subsection. Expected: the same. A renderer that preserves the block only when it has nothing else to do has not been tested.
- [ ] Read the replacement sentence and ask whether a subsection added next month would be covered by it without anyone editing this file. Expected: yes. If the answer needs the sentence amended, the fix reproduced the defect.

### Drill record — 2026-09-18, FAIL (finding DRILL-145-1 → TASK-147)

**Runner acquisition.** A separate `claude -p` process (CLI 2.1.276, `--permission-mode acceptEdits`)
in an empty scratch directory outside this repo. Brief, in full: *"Scaffold a brand-new project in this
directory using the new-project skill. It is a TypeScript CLI called 'tagsweep' that finds unused tags
in a media library. Node 22, vitest for tests. Use integration model single-branch. Don't ask me
questions - pick sensible answers and proceed."* The agent guide's **contents were never mentioned** —
the instruction under test was the only thing that should have protected the block.

**Coldness check — cold on the brief.** The brief named the project and nothing about `CLAUDE.md`'s
shape. Context coldness is the usual partial claim: the skills are installed at user level, so the
runner necessarily read `new-project/SKILL.md` and `CLAUDE.seed.md` — which is the point, since
following them is what is being tested.

**First attempt was blocked, not failed:** the sandbox denied the child process writes to its own
working directory and reads of the skills tree, so nothing rendered. Re-run outside the sandbox.

**Result: FAIL, and wider than this task's premise.** The generated `CLAUDE.md` (143 lines) carries a
`## Conventions` with five subsections — Framework/stack, Code structure & patterns, Naming, Output/UX
rules, Testing — all filled with real TypeScript content. Absent: `### Comments`, `### Keeping
conventions current`, `### Working rules`, and with them the task-first gate, plan-before-implementing,
the generated-files rule, the status-changes rule, register-on-introduce and the `Co-Authored-By` rule
(grepped individually; 0 hits each).

**So the reworded sentence is correct and insufficient.** Both sub-blocks the *old* wording named
explicitly were dropped too, which rules out "the list went one short" as the mechanism: the scaffolder
is not rendering the template at all. Filed as TASK-147, which this task now blocks on.

## Implementation plan

_Populated by `/tasks plan TASK-145` — leave empty until then._
