---
id: TASK-147
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: unassigned
created: 2026-09-18
depends-on: []
blocks: [TASK-145]
findings: [DRILL-145-1]
pr: null
github-issue: null
jira-key: null
---

# The scaffolder does not render the seed — every universal rule is dropped

## Context

Found by TASK-145's human test plan on 2026-09-18. **Measured, not suspected.**

A cold scaffold run (`claude -p`, empty scratch directory, brief naming only the project — a
TypeScript CLI called `tagsweep` — and never mentioning the agent guide's contents) produced a
143-line `CLAUDE.md` whose `## Conventions` holds five subsections: Framework/stack, Code structure
& patterns, Naming, Output/UX rules, Testing.

**All three static subsections of the seed are absent**, and with them every universal working rule:

| Seed content | In the generated guide |
|---|---|
| `### Comments` (TASK-140) | absent |
| `### Keeping conventions current (register-on-introduce)` | absent |
| `### Working rules` | absent |
| Task-first gate | absent |
| Plan before implementing | absent |
| Generated files are owned by their verbs | absent |
| Status changes go through their verbs | absent |
| No `Co-Authored-By:` trailers | absent |

**The defect is not the preserve-list's wording.** TASK-145 was filed on the premise that
`SKILL.md`'s *"leave the register-on-introduce + working-rules sub-blocks as-is"* names two
sub-blocks and would go one short now a third exists. That reasoning is sound and the reworded
sentence is already in. It changes nothing: the instruction is **not being followed at all**. Both
sub-blocks it named by name were dropped too, so the list was never the problem — the scaffolder
treats `CLAUDE.seed.md` as inspiration and writes a guide from scratch rather than rendering the
template and filling its tokens.

**Why this matters more than the comment rule it was found through.** These are the rules that make
the lifecycle work in a consuming repo: the task-first gate, the close gate, the rule that generated
files are regenerated rather than hand-edited. A scaffolded project is handed an agent guide that
**looks** complete — it has a `## Conventions` section with real, stack-appropriate content — while
carrying none of the enforcement. Nothing downstream detects it: `/verify-conventions` lints against
whatever the guide happens to say, so a guide missing the task-first gate simply never enforces one.

**Every project scaffolded by this skill to date is affected.** Check the consumer repos before
assuming the blast radius is theoretical, and note that [[adopt-project]] does not fix it — it
reconciles which artifacts exist, not the prose inside a hand-written document (FEATURE-002 D5).

**One thing the run got right, worth not breaking while fixing this**: told *"don't ask me
questions, pick sensible answers"*, the runner still refused to default `integration:` and reported
it unresolved instead. That is TASK-127's fix working under exactly the pressure it was built for.

## Acceptance criteria

- [ ] A scaffold run produces a `CLAUDE.md` whose `## Conventions` contains every static subsection of `CLAUDE.seed.md`, with its text intact.
- [ ] The three token-bearing subsections are still filled with real, stack-appropriate content — the fix must not turn a rendered guide back into a template full of `{{…}}`.
- [ ] The mechanism is stated in `SKILL.md` in a way that cannot be satisfied by writing a fresh guide that happens to cover similar ground: rendering the template is the instruction, not a suggested starting point.
- [ ] `docs/BRIEF.md`, `README.md` and the other seeded artifacts are checked for the same defect — the template-vs-freehand question is not specific to `CLAUDE.md`, and assuming it is would leave the same bug in three more files.
- [ ] Blast radius recorded: how many consumer repos carry a scaffolded guide missing the working rules, and whether a remediation pass is needed for them (a separate task if so).
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The preserve-list's wording — TASK-145, already done and correct; it stays.
- Backfilling already-scaffolded consumer repos. Record the count here; the remediation is its own task if the number warrants one.
- [[adopt-project]] — it reconciles artifact shape, not document prose (D5).

## Human test plan

- [ ] Re-run TASK-145's drill: a cold `claude -p` scaffold into an empty directory, brief naming only the project. Expected: the generated `CLAUDE.md` carries `### Comments`, `### Keeping conventions current` and `### Working rules` with their text intact, **and** Framework/stack, Naming and Testing filled with real TypeScript content.
- [ ] Repeat for a second, very different stack (a Python library, say). Expected: the same three static subsections survive byte-for-byte while the token-bearing ones differ completely. A fix that preserves them only for the stack it was tested on has not been tested.
- [ ] Grep the generated guide for the six rules listed in § Context. Expected: all six present. This is the assertion that actually fails today — write it before the fix and watch it fail, per [[populate-tests]] § *Prove the guard can fail*.

## Implementation plan

_Populated by `/tasks plan TASK-147` — leave empty until then._
