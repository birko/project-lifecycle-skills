---
id: TASK-170
parent: STORY-020
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-24
depends-on: []
blocks: []
findings: [VI-F002-3]
pr: null
github-issue: null
jira-key: null
---

# An only-copy that belongs in the project's guide has no relocation target

## Context

Found by `/feature review FEATURE-002` Gate A (fidelity, a note on D9), 2026-09-24. D15 added a sixth
destination — **the project's own guide** — and the only-copy *search* table in
`skills/review-comments/SKILL.md` § *The only copy* carries it. But the list that chooses **where to
relocate** an only copy — *"Choose the destination by the content's kind"* — offers a task, a decision
record and a docs page, never the guide. So a comment stating a standing rule, found to be the only copy,
has no filing option matching the row that describes it. D15's ripple reached the search and stopped
short of the move.

## Acceptance criteria

- [ ] § *The only copy*'s relocation list offers the project's guide for content that is a standing rule, with the same ask-first discipline as the other targets.
- [ ] It says how a standing rule differs from a decision record's content (*what we do now* vs. *why we chose it*), so a reader can route between the two — pointing at the project's own records table rather than restating it.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The destination table itself — the project's guide owns it (D1/D2); this skill never carries a copy.

## Human test plan

- [ ] A cold runner on a fixture whose only-copy comment states a standing rule (no guide section holds it) runs `/review-comments <file>`. Expected: it proposes the guide as the relocation target and asks before writing.

## Implementation plan

_Populated by `/tasks plan TASK-170` — leave empty until then._
