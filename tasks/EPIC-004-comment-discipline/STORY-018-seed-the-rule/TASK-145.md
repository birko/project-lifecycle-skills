---
id: TASK-145
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: unassigned
created: 2026-09-18
depends-on: [TASK-140]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Stop the scaffolder's "leave as-is" list going one short

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

- [ ] `skills/new-project/SKILL.md:89` no longer enumerates which static sub-blocks to preserve.
- [ ] Its replacement is **derived** — a reader can apply it to a subsection added tomorrow without this file being edited again.
- [ ] The new `### Comments` subsection is preserved by that rule without being named in it.
- [ ] Line 90 re-read and confirmed correct as written; any change to it is in this diff with a reason.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The rule's own wording — TASK-140.
- `skills/adopt-project/INFER.md`'s per-subsection inference list. Adding a Comments row there would make the adopter infer a prose rule from code, which is the precedent FEATURE-002 D5 exists to prevent.

## Human test plan

- [ ] Scaffold a throwaway project with `/new-project` after TASK-140 has landed. Expected: the generated `CLAUDE.md` carries the `### Comments` subsection with its wording intact — not paraphrased, not reordered, not dropped.
- [ ] Repeat with a stack that produces a lot of `{{CODE_STRUCTURE_RULES}}` content, so the renderer has real work to do in the neighbouring subsection. Expected: the same. A renderer that preserves the block only when it has nothing else to do has not been tested.
- [ ] Read the replacement sentence and ask whether a subsection added next month would be covered by it without anyone editing this file. Expected: yes. If the answer needs the sentence amended, the fix reproduced the defect.

## Implementation plan

_Populated by `/tasks plan TASK-145` — leave empty until then._
