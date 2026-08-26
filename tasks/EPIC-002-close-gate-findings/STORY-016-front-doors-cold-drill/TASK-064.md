---
id: TASK-064
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] `docs/BRIEF.md`'s conditionality has **one** answer: either `LAYER.md` gains the condition, or `SKILL.md:64`'s skip clause goes. State which and why
- [x] A scaffold of the smallest legitimate input (docs-only library, no stated requirements) produces **no unrendered token** and **no invented purpose**
- [x] Whatever fills the one-line-purpose slot comes from the user or degrades to an honest stated absence — never a plausible guess
- [x] If the fix is a new intake question, it is a question a user with a throwaway repo can answer without ceremony
- [x] TASK-056 is cross-referenced, with a note on edit ordering for `CLAUDE.seed.md`
- [x] `bash .github/workflows/skills-lint.sh` passes

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

## Outcome

**Done as one pass with TASK-056**, since both edit `CLAUDE.seed.md`. That was the coordination note on both
files, and it held: the seed took one edit and one review.

### DRILL-053-4 — the BRIEF contradiction, settled as *always create*

`SKILL.md` said *"Skip only for a truly throwaway/docs-only repo with no stated requirements"*; `LAYER.md`
listed the row unconditionally. **`LAYER.md` was right and the skip clause is gone.**

Why that way round rather than adding the condition to the inventory:

- **There is always *an* ask.** Even "scaffold me a throwaway library" is a request, and for a bare scaffold
  the verbatim record is the intake answers themselves — which is what the cold drill actually wrote when it
  hit this, and it was the right call.
- **The failure mode is asymmetric.** A near-empty BRIEF costs a few lines. A skipped one means the single
  **immutable** record never exists — and nobody retrofits ground truth, which is precisely the hole
  § *The adopted-repo brief* has to work around for repos that arrive without one. Creating the problem
  deliberately, in a repo we control from line one, would be perverse.
- The skip clause also targeted the *smallest* input, which is the shape most likely to grow into something
  real without anyone going back to write down what was originally asked for.

### DRILL-053-5 — the purpose token now has a source

`README.seed.md` and `CLAUDE.seed.md` both require `{{ONE_LINE_PURPOSE}}`; **nothing asked for it.** Added as
**intake question 2**, placed before *Kind* because it is the cheapest question in the batch and the one two
files depend on. The intake list was renumbered; nothing else references those numbers (checked).

**The wording carries the prohibition, not just the question:** *never invent one* — a plausible-sounding
purpose sitting in the two files a reader trusts most is exactly the fabrication `docs/BRIEF.md` exists to
prevent. If the user genuinely has none, the guidance is to record that it was not stated and point at the
brief. **An honest absence, not a guess** — which is the option the cold drill picked unaided, and the only
one of its three that was defensible.

**Rejected: making the templates degrade when no purpose exists.** It removes the need to ask, and it removes
the chance to *get* one. A purpose is the single thing only the user knows; the fix that stops asking for it
is the wrong direction.

### Verification

| Check | Result | Role |
|---|---|---|
| every token in both seed templates has a named source | 16 checked; `ONE_LINE_PURPOSE` ← intake q2; the five `§ Conventions` tokens ← step 3, which forbids a dangling `{{…}}` | **fix-dependent** — this is AC 2 |
| the BRIEF rule has exactly one answer | `SKILL.md`'s skip clause removed; it now states agreement with `LAYER.md` and why | **fix-dependent** |
| the renumbered intake list breaks nothing | no file references intake items by number | contract pin |
| lint | OK (18 skills) | contract pin |

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped.

**Not done.** No throwaway scaffold was run end to end. The token audit is mechanical and complete, but the
drill that found this ran a real scaffold, and re-running one is the stronger check on whether a *bare* input
now produces an honest file rather than a hedged one.

## Progress log

- step 2 — picked as the batch partner for TASK-056 (both edit `CLAUDE.seed.md`), which was the coordination note recorded on both tasks when they were filed. Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: both halves held. The skip clause and the unconditional row still contradicted; the purpose token still had no asker.
- step 4 — layer: **local.**
- step 5 — `SKILL.md` intake gains question 2 (list renumbered) and the BRIEF skip clause is replaced by a statement of agreement with `LAYER.md`.
- step 6 — 16 tokens audited for a named source; renumbering checked for references; lint green.
- step 7 — no usable spec map; regen skipped and stated.
- step 8 — 5d sweep: Out of scope bullets are boundaries; TASK-056's cross-reference is satisfied by having done them together. Nothing spawned. Gate: standards pass, intent pass, correctness pass; security n/a.
