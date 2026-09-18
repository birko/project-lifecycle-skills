---
id: EPIC-004
# status — one of: planned, in-progress, done, cancelled
status: in-progress
created: 2026-09-18
owner: František Bereň
affects: skills/, docs/, AGENTS.md
---

# Comment discipline in agent-written code

## Area of concern

Agents write too many comments, and the bad ones share a shape: they are **records kept in the
wrong place** — a changelog that version control already holds, a defect note that belongs on a
ticket, a rationale essay that belongs in a decision record, ten lines of prose above one constant.

Nothing in the skill set says anything about comments today. A scaffolded project receives a
rulebook covering stack, structure, naming and testing, and no guidance at all on what a comment is
for. Two skills already say fragments of the rule in narrow forms — [[tasks]] treats a comment
reading *"should be fixed properly one day"* as work that silently disappears, and [[fix-next]]
*requires* a short comment naming a finding id and its mechanism — but neither generalizes.

This epic ships the rule into the rulebooks and builds the command that enforces it on code that
already exists. Decisions and rationale: `docs/features/FEATURE-002-comment-discipline/`.

**Out of scope at the epic level:** comment *style* (formatting, doc-comment syntax, language);
making the check CI-enforced rather than agent-run; backfilling the rule into already-adopted
consumer repos (FEATURE-002 D5 — the command is what reaches them).

## Success criteria

- A newly scaffolded project arrives carrying the rule in its own `CLAUDE.md` § Conventions.
- This repo follows the rule it ships, and the measurement protecting `skills-lint.sh` from a
  later sweep is recorded rather than remembered.
- `review-comments` exists, runs over either the working diff or the whole repository, and is
  invoked by `/tasks close` as its own reported axis.
- A comment that is the only record of what it says is never destroyed by the command — it is
  relocated first, and the drill proves that on a file built to contain comments that must survive.

## Requirement → feature matrix

| Req | Brief quote (abridged, from docs/BRIEF.md) | Feature | Story |
|-----|--------------------------------------------|---------|-------|
| R1 | _"we need to add un our claude agents tempalte something like this **WRITE FEWER COMMENTS IN CODE.**"_ | FEATURE-002 | STORY-018 |
| R2 | _"sometimes a coomet can be longer but only if it has some necessary ingo and not unceccesry things"_ | FEATURE-002 | STORY-018 |
| R3 | _"and maybe add a command to review comments in code and fix them"_ | FEATURE-002 | STORY-019 |
| R4 | _"woudl liek to be able to scan the whole repo but also just the files it ctoudhed by wopork in the diff"_ | FEATURE-002 | STORY-019 |
