---
id: TASK-146
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-18
depends-on: [TASK-140, TASK-141]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Lint check: the rule's two copies must match

## Context

Discovered while grilling TASK-140's implementation plan, and recorded as FEATURE-002 **D13**.

The comment rule ends up written twice — in `skills/new-project/templates/CONVENTIONS-universal.md` (spliced into every scaffolded guide,
to consumers, D4) and in this repo's own `AGENTS.md` (D11) — and **no pointer between them is
possible**: a consumer's install cannot see this repository, so the seed has to carry the whole
text. The five destinations are a list that can grow, which is precisely the shape AGENTS.md
§ *Defer to a shared inventory* warns about: when one copy gains a row the other becomes wrong
silently, with nothing to signal it.

The plan's own mitigation was a convention — copy it verbatim, name the source. This repo's stated
position is that an unenforced convention is worth what an unrun check is. Unlike most prose rules
this one **is** machine-checkable, because both copies are one delimited block of text, so it
becomes a gate rather than an intention.

TASK-140 and TASK-141 write the markers; this task writes the check.

**A change to `skills-lint.sh` is not done until a case in `skills-lint-test.sh` fails without
it** — the repo's own testing rule, and it bites hard here: the lint is the only gate, so a silent
regression in it disables checking with no signal. The test count has moved six times (16 → 25 → 36
→ 40 → 43 → 47) and nothing records what any case pins, so add the case *and* say in the close
notes what it pins.

**Design caution.** Byte-identical is the strict reading and the easy one to implement. Before
committing to it, check whether the two copies can legitimately differ — the seed ships into repos
of any stack while `AGENTS.md` governs a markdown-and-shell repo. If they genuinely must diverge one
day, a check forcing byte-equality turns that into an arbitrary emergency. The counter-argument, and
the reason D13 chose a check anyway: that is exactly the moment somebody should be stopped and made
to decide, rather than the copies quietly parting. Whichever you conclude, state it.

## Acceptance criteria

- [x] `skills-lint.sh` gains a check asserting the delimited comment-rule block matches between `AGENTS.md` and **`templates/CONVENTIONS-universal.md`** — note the block moved there from `CLAUDE.seed.md` in TASK-147; a check written against the old path would compare nothing to nothing and pass.
- [x] A missing block on either side fails loudly and names which side is missing — not a silent pass, which is what a naive "compare what you find" check does when it finds nothing.
- [x] The check is **fatal**, not advisory: its remedy is a diff in this repo, unlike the install-root check whose remedy lives outside it.
- [x] At least one case in `skills-lint-test.sh` fails when the check is removed, and one fails when the two blocks are made to differ.
- [x] The marker convention is recorded in `AGENTS.md` § Conventions — register-on-introduce, and the rule *"a format one skill reads is a contract the writing skill must state too"*. **It is recorded here, never in the shipped template**: a comment in a consumer's rulebook explaining a lint in a repo they cannot see is content whose home is elsewhere, which is the exact violation the new section defines.
- [x] The close notes state what each added case pins, and whether byte-identical or something looser was chosen, with the reason.
- [x] `bash .github/workflows/skills-lint.sh` and `bash .github/workflows/skills-lint-test.sh` both pass.

## Out of scope

- The rule's wording — TASK-140.
- Adopting it into `AGENTS.md` — TASK-141.
- Any third copy inside the `review-comments` skill. D13 covers the two rulebook copies; STORY-019's command is built to **read** the project's own § Conventions rather than carry its own copy, so there should be no third block for this check to compare.

## Human test plan

- [x] Change one word in the `AGENTS.md` copy and run the lint. Expected: it fails, and says which two files disagree.
- [x] Delete the block from `templates/CONVENTIONS-universal.md` entirely and run the lint. Expected: it fails naming the missing side. Expected failure mode: it passes, because the check compared nothing to nothing.
- [x] Delete the check from `skills-lint.sh` and run `skills-lint-test.sh`. Expected: at least one case fails. A test suite that stays green without the thing it tests is not testing it.

### Close record — 2026-09-19

**Byte-identical was chosen, and the § Context caution is answered rather than ignored.** The two
copies serve one purpose — consumers and this repo running the *same words* — so a tolerance would
absorb exactly the drift the check exists to catch. The counter-case (the seed ships to any stack while
`AGENTS.md` governs a markdown-and-shell repo, so they might legitimately diverge one day) is real, and
is the argument *for* strictness: that day somebody should be stopped and made to decide, not have a
tolerance quietly decide for them. Recorded in `AGENTS.md` § Conventions as a corollary of the
splice rule rather than a second entry.

**What each case pins** — the repo's own complaint about `skills-lint-test.sh` is that nothing records
this, so:

| Case | Pins |
|---|---|
| identical rule blocks pass | the positive control — the check does not fire on a correct repo |
| one word of drift fails | the core assertion; exit code |
| template has the block, AGENTS.md does not | the asymmetric-missing branch, this repo shipping a rule it does not follow |
| AGENTS.md has the block, template does not | the mirror branch, consumers receiving nothing |
| missing AGENTS.md side is named | the *message*, not just the exit code — "they differ" would send a reader to diff an empty file |
| missing template side is named | same, mirror side |
| drift names both files | that a drift failure identifies both files |
| no pair present says so rather than passing in silence | the **vacuous-pass guard**: a repo with neither file must pass *visibly*. Asserting only the exit code would also pass with the whole check deleted |
| prose mentioning the marker is not mistaken for the block | the anchored match (see below) |

**Deletion assertion, per the repo's rule that a lint change is not done until a case fails without
it:** check 5 removed → **7 of 9 cases fail**, exit 1 → 0. The two that still pass are the positive
control and the frontmatter case, both correctly indifferent to it.

**The check caught its own defect, which is why the ninth case exists.** The first version matched the
marker as a substring. The moment this convention was written into `AGENTS.md`, that file mentioned
`<!-- comment-rule:start -->` in prose ~37 lines above the block it describes — so the extractor began
capturing at the prose and reported two byte-identical copies as differing. The lint failed on its own
documentation. Now the marker must be alone on its line, and a case pins it. This is the same shape
this repo has hit before: a detector that cannot tell a rule from prose discussing the rule.

**Human test plan run on the real repo, not only the fixture:** one word of drift in `AGENTS.md` →
fails naming both files; the block deleted from the template → fails naming the missing side; the check
deleted → 7 cases fail. Suite: **56 passed, 0 failed** (was 47 before this task).

## Implementation plan

**Skipped deliberately.** The shape was fixed by the acceptance criteria (a fatal check, both-sides-missing named, cases that fail without it) plus D13's byte-identical decision. The one open design question — strict versus loose comparison — is settled in the close record above, where its reasoning is durable rather than in a plan nobody re-reads.
