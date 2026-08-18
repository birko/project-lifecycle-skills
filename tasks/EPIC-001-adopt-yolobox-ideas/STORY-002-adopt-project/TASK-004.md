---
id: TASK-004
parent: STORY-002
feature: null
status: review
priority: P1
assignee: unassigned
created: 2026-08-18
depends-on: [TASK-003]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# adopt-project: infer conventions from the code, then grill

## Context

This is what makes `adopt-project` more than skip-if-exists. `new-project` *asks* for conventions
up front because there is no code to read. An existing repo has already answered most of those
questions in its source — the job is to read the answers out, propose them, and have the user
confirm or correct.

Reading rules **out** of a codebase is a different discipline from collecting them, and it is
most of this skill's value: an adopted repo whose `§ Conventions` block is empty gets nothing
from [[verify-conventions]], which is the single biggest payoff of adopting at all.

## Acceptance criteria

- [x] Surveys the codebase for recurring patterns and proposes them as `§ Conventions` entries, each shown **with the evidence that suggested it** (file count + representative paths) so the user can judge rather than rubber-stamp
- [x] Covers the seed's subsections: framework/stack (from manifests + imports), code structure & patterns, naming, testing (from the test runner actually present), and UI/UX only when a human-facing surface exists
- [x] **Proposes, never asserts.** Every inferred rule is confirmed by the user before it is written; an unconfirmed inference is dropped, not written as a guess
- [x] Distinguishes *convention* from *accident*: a pattern in 3 of 30 files is offered as a question, not a rule
- [x] Surfaces candidate glossary terms — recurring domain nouns, and pairs that look like synonyms for one concept — for [[domain]] once STORY-003 lands; until then it records them in the guide and says so
- [x] Uses the frontier-round grill shape from [[grill-me]], not one question at a time
- [x] A repo where nothing can be inferred degrades gracefully: say so and leave the subsections empty rather than inventing rules the project never agreed to

## Out of scope

- The survey/fill mechanics → TASK-003.
- Writing the glossary/ADR files themselves → STORY-003 owns `domain`; this task only feeds it candidates.

## Human test plan

- [x] Drilled on **BardStudio** (70 files): four rules proposed with evidence, all four judged and recorded — run from the repo copy, pre-junction
- [ ] Drill on **Symbio** and **WorkoutTracker** — the two where the owner knows which patterns are legacy, so a wrong proposal is *catchable*. **This is the highest-value unrun check in the epic.** The failure mode is not a crash: it is a plausible-but-wrong rule that reads fine, gets confirmed, and is then enforced by `verify-conventions` against every future change. BardStudio could not test that — it had too few conventions to get wrong
- [ ] **WorkoutTracker attempted 2026-08-18 — no evidence produced.** The run (installed skill) skipped step 2 entirely: "no convention-inference round is warranted", because the guide's `## Conventions` block already exceeds the layer. The judgement was right and unsanctioned by the skill → TASK-017. This line stays unticked until a real inference round runs there
- [ ] Confirm every proposal shows its evidence and that declining one leaves it unwritten
- [ ] Run against a repo with a deliberately mixed codebase and confirm weak patterns are offered as questions rather than asserted

## Implementation plan

1. Written as `INFER.md` rather than inline: the router stays small per the prose rules, and the
   inference discipline is long enough to be its own reference.
2. Prevalence thresholds chosen over raw counts — 80%+ of *applicable* files proposes a rule,
   20-80% asks a question, below that stays silent. A split codebase is a finding worth surfacing,
   not a failure to classify.
3. Glossary candidates collected but not written: `domain` does not exist yet, and the reference
   is deliberately plain text because a wikilink to an absent skill degrades silently at runtime.
   STORY-003 promotes it.
