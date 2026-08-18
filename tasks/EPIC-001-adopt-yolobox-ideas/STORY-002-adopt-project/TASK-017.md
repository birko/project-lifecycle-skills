---
id: TASK-017
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
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

## Acceptance criteria

- [ ] `INFER.md` gains a second degradation path beside § *When nothing can be inferred*: **the rulebook already covers the layer's subsections** → skip, and say which subsections were found covered and on what evidence
- [ ] Inference is **scoped per subsection**, not all-or-nothing: propose only for the subsections the rulebook lacks. A guide covering four of five gets a one-subsection round
- [ ] `SKILL.md` step 2 states that skipping is legitimate and **points** at the rule in `INFER.md` rather than restating the conditions — the router stays small and the condition list has one home
- [ ] The skip is **reported, never silent**: the report says which subsections were skipped and why, so a user can disagree and ask for the round anyway
- [ ] Decide explicitly — and record the decision — whether the skip also skips the two outputs that are valuable even against a complete rulebook: **glossary candidates** and the **20–80% split-pattern finding** (`INFER.md` § *Convention or accident?*). A repo with a perfect rulebook can still have two names for one concept
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- The prevalence thresholds themselves (80% / 20–80% / below) — they were not what failed here.
- The `domain` skill that will eventually consume glossary candidates → STORY-003.
- TASK-004's remaining drill lines; this task makes the WorkoutTracker one *runnable*, it does not run it.

## Human test plan

- [ ] Re-drill the installed skill on **WorkoutTracker**: step 2 is skipped **by rule**, the covered subsections are named, and no proposals are written
- [ ] Drill a repo whose guide covers **some but not all** subsections (Symbio's guide has ten rule-named sections; confirm which subsections it lacks first) — only the missing subsections are proposed, and the covered ones are reported as skipped
- [ ] Drill **Presenter** (no agent guide at all): the full round still fires, unchanged — the skip must not swallow the case the step exists for
- [ ] Confirm declining a proposal still leaves it unwritten, and that TASK-004's WorkoutTracker line is only ticked once a real inference round has run there

## Implementation plan

_Populated by `/tasks plan TASK-017` — leave empty until then._
