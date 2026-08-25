---
id: TASK-064
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-4, DRILL-053-5]
pr: null
github-issue: null
jira-key: null
---

# What a minimal repo gets: step 3 and the templates disagree, and one token has no source

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance). Two findings, one root cause: **the seed
path was written for a real product and does not hold together for the smallest legitimate input** — a
throwaway docs-only library, which is a shape `new-project`'s own intake offers.

### DRILL-053-4 — the BRIEF row contradicts its own creation detail

`new-project/SKILL.md:64` says of `docs/BRIEF.md`: *"Skip only for a truly throwaway/docs-only repo with
no stated requirements."* The drill's input was **exactly** that. `LAYER.md:22` lists the row
unconditionally, and `LAYER.md:7-10` declares itself the inventory while `SKILL.md` carries only creation
detail — so the inventory says always and the detail says sometimes.

The drill created the file and flagged that **skipping was arguably the more correct reading**, since
`SKILL.md` names that exact repo shape. Either answer is defensible; the two files disagreeing is not.

### DRILL-053-5 — `ONE_LINE_PURPOSE` is required and never asked for

`templates/README.seed.md:3` and `templates/CLAUDE.seed.md:3` both require the one-line-purpose token.
Step 1's intake (`SKILL.md:44-52`) asks for name, location, kind, stack, scaffolder check, task mode,
license and agent-guide form — **never a purpose**.

Against this repo's own *"ship no unrendered placeholder tokens"* rule that leaves three options, and
every one is bad: leave the token (forbidden), invent a purpose (the fabrication `docs/BRIEF.md` exists
to prevent — and it would land in the two files a reader trusts most), or write a line saying none was
given. The drill chose the third and said so, which is the least-bad option and still not right.

**Probably one intake question.** Confirm that before assuming — the alternative is that both templates
should degrade gracefully when no purpose exists, which is a different fix.

### Why these are one task

Same file, same step, one review. Both are "the minimal path was never walked end to end", and fixing
either alone leaves a scaffold of that shape still wrong.

**Coordinate with TASK-056**, which edits `templates/CLAUDE.seed.md`'s record-routing table. Same file,
adjacent concern. Whichever runs second must not clobber the first; if they are picked together, say so
and do one edit pass.

## Acceptance criteria

- [ ] `docs/BRIEF.md`'s conditionality has **one** answer: either `LAYER.md` gains the condition, or `SKILL.md:64`'s skip clause goes. State which and why
- [ ] A scaffold of the smallest legitimate input (docs-only library, no stated requirements) produces **no unrendered token** and **no invented purpose**
- [ ] Whatever fills the one-line-purpose slot comes from the user or degrades to an honest stated absence — never a plausible guess
- [ ] If the fix is a new intake question, it is a question a user with a throwaway repo can answer without ceremony
- [ ] TASK-056 is cross-referenced, with a note on edit ordering for `CLAUDE.seed.md`
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The record-routing table in `CLAUDE.seed.md` — **TASK-056**.
- `## Conventions` content when the stack is "none", and empty-case rendering — **TASK-067**. Both were also invented during the same drill, but they are about generated *content*, not about intake and conditionality.
- The other drill findings — separate tasks under STORY-016.

## Human test plan

- [ ] Scaffold a throwaway docs-only library and grep the result for an unrendered token delimiter — must be clean
- [ ] Confirm the generated `README.md` and `CLAUDE.md` describe the project without asserting a purpose nobody stated
- [ ] Confirm `docs/BRIEF.md` is either present or absent per the single settled rule, and that the printed summary says which and why

## Implementation plan

_Populated by `/tasks plan TASK-064` — leave empty until then._
