---
id: TASK-017
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Step 2's inference round has no skip condition, so the skill improvises one

## Context

Found by drilling `adopt-project` on `C:\Sources\Birko\Consumers\WorkoutTracker` (Reps) on
2026-08-18 — the first drill run through the **installed** skill rather than the repo copy.

The repo is already adopted: 283 commits, every owned artifact present, and a `CLAUDE.md`
`## Conventions` block of ~240 lines — denser than the layer asks for. The run opened with *"no
convention-inference round is warranted"* and skipped step 2 entirely.

**The judgement was right; nothing in the skill sanctions it.** `SKILL.md` step 2 is unconditional
and calls itself *"the step that makes adoption worth doing"*. `INFER.md`'s only degradation path is
§ *When nothing can be inferred* — a repo too small, too new, or too inconsistent to read rules
from. Neither covers the opposite case: a repo whose rulebook **already exceeds** the layer. That
case is not an edge; it is the normal state of the upgrade path this skill advertises as its second
entry case.

Three consequences:

- **The behaviour is model-dependent.** This run reasoned its way to silence. The next one obeys the
  text and puts fifteen redundant proposals to a user with a 240-line rulebook — noise that dilutes
  the block it is proposing into.
- **The wanted behaviour is narrower than "skip".** Inference should run **per subsection**, for
  the subsections the guide actually lacks. A guide with four of five covered deserves a
  one-subsection round, and nothing in either file asks for that.
- **It cost the epic its highest-value check.** TASK-004's human test plan names WorkoutTracker as
  one of the two repos where a plausible-but-wrong inferred rule is *catchable* by the owner. The
  drill ran and produced no evidence, so that line stays unticked.

**What the drills turned up about the fleet.** Every one of the six drilled repos now answers all
five subsections — WorkoutTracker, Symbio, Presenter, BardStudio, Latent, flappy-dragon — because our
own adoption passes filled the thin ones. So the *scoped* case had to be built as a fixture, and more
importantly TASK-004's remaining drill has no valid subject left in the fleet: with this rule in
place, the round correctly skips on all six. That task closes on Presenter's evidence instead, where
the owner did catch two proposals (see its record).

## Acceptance criteria

- [x] `INFER.md` § *When the rulebook already answers it* — the mirror of § *When nothing can be inferred*: all covered means skip, say so, name the subsections and the evidence, write nothing
- [x] The unit is the subsection, not the round: coverage is judged per subsection and only uncovered ones are proposed. **Covered means answered, not exhausted** — and a thinly answered subsection is *offered*, not run, which came out of the WorkoutTracker drill rather than the plan
- [x] `SKILL.md` step 2 sanctions the skip in two sentences and points at `INFER.md` for the conditions; the router carries no copy of them
- [x] Required in both the survey and the report, with the reason stated inline: a silent skip is indistinguishable from a skill that forgot the step, and the user cannot ask for a round they never knew was declined
- [x] **Decided and recorded in `INFER.md`: both still run.** Glossary candidates and the 20–80% split finding are not rule proposals — two names for one concept, and a migration caught in flight, are *findings about the code*, and the densest guide in a fleet can carry both. Written as a decision so the next reader does not re-litigate it
- [x] `skills-lint` OK (16 skills); `skills-lint-test` green

## Out of scope

- The prevalence thresholds themselves (80% / 20–80% / below) — they were not what failed here.
- The `domain` skill that will eventually consume glossary candidates → STORY-003.
- TASK-004's remaining drill lines; this task makes the WorkoutTracker one *runnable*, it does not run it.

## Human test plan

- [x] WorkoutTracker (2026-08-18): **skipped by rule.** Its `## Conventions` is ~24 flat bold rules with no subsections at all, and content probes show testing (24 hits), UI (32), structure (26) and framework (13) richly answered — so coverage had to be judged by content, not by heading match, which is now what the rule says. Naming is answered by exactly one rule (`one <Entity>Endpoints.cs per resource`), so it was reported as thinly answered and the single-subsection round **offered** rather than run. No proposals written
- [x] Ran as a fixture, because **the fleet no longer contains this case** — see the note below. A repo whose guide answers framework, structure, testing and UI but says nothing about naming: the round proposed **naming only** (`*Handler` suffix 9/9, `Async` suffix 9/9, with paths), named the other four as answered, and wrote zero files. Symbio was the plan's target and turned out to answer all five — its naming rules are in the permissions convention (`{module}:{resource}:{action}`, lowercase kebab-case), which a heading-based check would have missed
- [x] Premise moved — Presenter *acquired* a guide on 2026-08-18, so it can no longer test this — and the case ran as a fixture instead: nine handlers across three feature folders, xUnit in the manifest, no guide of any kind. The full round fired: six proposals with counts and representative paths, `UI / UX` **dropped** because there is no human-facing surface, and the one-file testing signal **asked rather than asserted** (below `INFER.md`'s 3-file floor). Glossary candidates collected (Order, Billing, Shipping, Command, Dto)
- [x] Zero files were written by any of the three rounds — verified by `git status` on each fixture — so nothing proposed and unconfirmed reached disk. TASK-004's WorkoutTracker line is now moot rather than pending: with the skip sanctioned, that repo correctly produces no inference round at all, which is why that task closes on Presenter's evidence instead

## Implementation plan

_Drafted in-conversation; the harness rules out spawning a Plan agent unasked._

1. **`INFER.md` gains a second degradation path** beside § *When nothing can be inferred*. That
   section covers a repo too small or too inconsistent to read rules from; this one covers the
   opposite — a guide whose rulebook already answers what the layer asks. Same shape: say so, say
   what the evidence was, write nothing.
2. **Make the unit the subsection, not the round.** The existing § *What to read, per subsection*
   already enumerates them, so scoping is a matter of stating that coverage is judged per subsection
   and only uncovered ones are proposed. A guide covering four of five gets a one-subsection round.
3. **Define "covered" so it is not a vibe.** A subsection is covered when the guide carries
   normative content answering it — the same ladder [[verify-conventions]] uses to find a rulebook at
   all, which keeps the two skills agreeing rather than each inventing a threshold.
4. **`SKILL.md` step 2** states the skip is legitimate and **points** at the rule; the router does
   not restate the conditions.
5. **Report the skip.** It goes in the survey/report output with the covered subsections named, so a
   user can disagree and ask for the round anyway. A silent skip is indistinguishable from a skill
   that forgot.
6. **Settle criterion 5 explicitly** — my read, to be argued with in review: glossary candidates and
   the 20–80% split finding **still run**. Neither is a rule proposal, so a complete rulebook does not
   answer them: two names for one concept and a migration in flight are *findings*, and the densest
   rulebook in the fleet can carry both. Record the decision in `INFER.md` so the next reader does
   not re-litigate it.
7. **Drills.** WorkoutTracker for the skip; Symbio for the scoped case (check first which subsections
   its twelve `KRITICKE` sections actually leave uncovered); a **fixture** for the no-guide case,
   because the plan's named target — Presenter — acquired a guide on 2026-08-18 and can no longer
   test it.
8. Gates, then close. Layer parity: no `LAYER.md` change expected, since this is adoption-side
   inference discipline rather than the inventory.
