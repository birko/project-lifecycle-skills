---
id: TASK-004
parent: STORY-002
feature: null
status: todo
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

- [ ] Surveys the codebase for recurring patterns and proposes them as `§ Conventions` entries, each shown **with the evidence that suggested it** (file count + representative paths) so the user can judge rather than rubber-stamp
- [ ] Covers the seed's subsections: framework/stack (from manifests + imports), code structure & patterns, naming, testing (from the test runner actually present), and UI/UX only when a human-facing surface exists
- [ ] **Proposes, never asserts.** Every inferred rule is confirmed by the user before it is written; an unconfirmed inference is dropped, not written as a guess
- [ ] Distinguishes *convention* from *accident*: a pattern in 3 of 30 files is offered as a question, not a rule
- [ ] Surfaces candidate glossary terms — recurring domain nouns, and pairs that look like synonyms for one concept — for [[domain]] once STORY-003 lands; until then it records them in the guide and says so
- [ ] Uses the frontier-round grill shape from [[grill-me]], not one question at a time
- [ ] A repo where nothing can be inferred degrades gracefully: say so and leave the subsections empty rather than inventing rules the project never agreed to

## Out of scope

- The survey/fill mechanics → TASK-003.
- Writing the glossary/ADR files themselves → STORY-003 owns `domain`; this task only feeds it candidates.

## Human test plan

- [ ] Run against a real codebase (a Birko or Symbio consumer) and judge whether the proposed conventions are ones a maintainer would actually endorse — the failure mode is plausible-but-wrong rules, which are worse than none
- [ ] Confirm every proposal shows its evidence and that declining one leaves it unwritten
- [ ] Run against a repo with a deliberately mixed codebase and confirm weak patterns are offered as questions rather than asserted

## Implementation plan

_Draft after TASK-003 lands — the inference pass hangs off the survey's file inventory, so its
shape depends on what the survey ends up collecting._
