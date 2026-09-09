---
id: TASK-125
parent: STORY-006
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-09
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# A prototype-derived snippet may enter a decision — the one exception to "no code in decisions"

## Context

`decisions.md` keeps decisions **free of file paths and code**, because both go stale fast and a stale
decision record is worse than none. The story carves one narrow exception:

> Where a prototype produced a snippet that **encodes a decision more precisely than prose can** — a
> state machine, a reducer, a schema, a type shape — that snippet may be inlined into the decision,
> **trimmed to the decision-rich part**, and **noted as prototype-derived**.

Both qualifiers are load-bearing. *Trimmed* keeps it from becoming an implementation excerpt that rots;
*noted as prototype-derived* tells a later reader it was never the shipped code, so nobody diffs it
against the repo and files a bug.

### Why this is its own task and not part of TASK-124

It changes **`decisions.md`**, not the prototype verb — a different artifact, owned by a different verb,
with an existing rule this must carve an exception into rather than contradict. It also applies to all
four prototype forms, including the three that exist today, so it does not depend on the fourth
shipping.

**The risk to manage:** an exception to "no code in decisions" is exactly the kind of rule that widens
in practice. The test for what qualifies has to be sharp enough that "this snippet is clearer than my
prose" does not become the general case.

## Acceptance criteria

- [ ] The exception is written **into the rule it modifies**, not stated separately where a reader of
      the original rule would miss it
- [ ] A sharp test says what qualifies — the snippet encodes the decision *more precisely than prose
      can*, not merely *more conveniently*
- [ ] Both qualifiers are mandatory and stated as such: trimmed to the decision-rich part, and marked
      prototype-derived
- [ ] What a later reader does with such a snippet is stated — it is not the shipped code and is not
      expected to match it
- [ ] The base rule still reads correctly on its own: a reader who never hits the exception is not
      misled about paths and code in decisions
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **The fourth prototype form** — TASK-124. This applies to all four and ships independently.
- Any other change to `decisions.md`'s shape or states.

## Human test plan

- [ ] Take a real prototype-derived state machine and a real snippet that is merely convenient, and
      apply the test to both. Expected: it admits the first and rejects the second. If it admits both,
      the test is not sharp enough and has not been built.
