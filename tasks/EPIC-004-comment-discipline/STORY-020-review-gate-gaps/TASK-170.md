---
id: TASK-170
parent: STORY-020
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] § *The only copy*'s relocation list offers the project's guide for content that is a standing rule, with the same ask-first discipline as the other targets.
- [x] It says how a standing rule differs from a decision record's content (*what we do now* vs. *why we chose it*), so a reader can route between the two — pointing at the project's own records table rather than restating it.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The destination table itself — the project's guide owns it (D1/D2); this skill never carries a copy.

## Human test plan

- [x] A cold runner on a fixture whose only-copy comment states a standing rule (no guide section holds it) runs `/review-comments <file>`. Expected: it proposes the guide as the relocation target and asks before writing.

## Implementation plan

One more route in the relocation list, one more option in the verbatim question.

**Outcome (2026-09-24).** § *The only copy*'s relocation list gains **a standing rule → the project's own
guide**, in the section that covers it (the file Step 1 found the comment rule in), with the line against a
rationale stated once — *what we do* against *why we chose it* — and deference to the guide's own routing
table where it has one. The verbatim question's options now read `task | decision record | guide rule | docs page`.

**Drill:** `scratchpad/drill-170` (copies `a`, `b`) — TASK-155's rebuilt repo plus a committed
`src/money.ts` whose only comment is a repo-wide house rule (integer cents in every public signature) that
no guide section, ADR, task or commit carries. TASK-152's acquisition; brief *"Use the review-comments
skill on `src/money.ts` in this repo and give me its report."* Both runners: **held — only copy**,
destination *the project's own guide* (row 5), every other destination checked and empty, the question put
with the guide as the proposed target, and `unresolved` stated as the no-answer outcome. Runner b classified
it in the new sentence's own terms: *"a standing rule ('what we do'), not a rationale. It should go in the
guide, not an ADR."* Nothing edited in either copy.

**Gate, inline:** standards ✅ points at the guide's routing table rather than restating it · fidelity ✅
criteria 1-3 · correctness ✅ lint OK. Security: n/a.
