---
id: TASK-125
parent: STORY-006
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] The exception is written **into the rule it modifies**, not stated separately where a reader of
      the original rule would miss it
- [x] A sharp test says what qualifies — the snippet encodes the decision *more precisely than prose
      can*, not merely *more conveniently*
- [x] Both qualifiers are mandatory and stated as such: trimmed to the decision-rich part, and marked
      prototype-derived
- [x] What a later reader does with such a snippet is stated — it is not the shipped code and is not
      expected to match it
- [x] The base rule still reads correctly on its own: a reader who never hits the exception is not
      misled about paths and code in decisions
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **The fourth prototype form** — TASK-124. This applies to all four and ships independently.
- Any other change to `decisions.md`'s shape or states.

## Human test plan

- [ ] Take a real prototype-derived state machine and a real snippet that is merely convenient, and
      apply the test to both. Expected: it admits the first and rejects the second. If it admits both,
      the test is not sharp enough and has not been built.
  - **Run 2026-09-29, passed.** Cold runner: `cd C:/Source/WebChecker && claude -p --disable-slash-commands < brief.txt`. It reported no skills loaded. The brief held the rule text and two candidates, **both prototype-derived**, so only the precision test could separate them. A was the state-model playground's move table plus its `apply()` handler. B was an HTML mockup's `LOCKOUT = { maxFailedAttempts: 5, lockMinutes: 15 }` plus a banner call, for the decision "Lock the account for 15 minutes after five failed password tries". The brief did not say which should pass. Result: **A admitted**, with `apply()` cut as wiring, the rationale fields dropped, and the marker added. The runner listed six edges a sentence would drop. **B rejected on the precision test** ("rewrite the remaining line in words and you get the decision's own title"). Four wording gaps it raised were fixed in place: the precision test compares with the row's own sentence, not with a lossless transcript; the row keeps its one-line summary; the marker's date is the prototype's build date; trimming keeps what tells cases apart and drops rationale. **Bonus evidence for the rule:** from the table, the runner noticed that `review` could not be blocked. `/tasks block` refuses only `done`/`cancelled`, so the playground was wrong. The table exposed an edge that prose had hidden, and the playground was fixed (version 2).

## Implementation plan

Planned inline at pick (2026-09-29). The base rule was thinner than this task's Context assumed. `feature/SKILL.md` said only that stakeholder files "avoid code jargon"; "no file paths and no code" existed only in STORY-006. So the rule and its exception are written together in the verb that owns what a row may carry (`decide.md` § *Deciding rules*). The router line states both in one sentence and points there.

## Progress log

- 2026-09-29 — Picked; planned inline.
- 2026-09-29 — `decide.md` § *Deciding rules*: "Decisions carry no file paths and no code — with one exception". A four-test table (from a prototype; encodes the decision itself; prose would lose precision; trimmed and marked), where the snippet goes, and how a later reader treats it. `feature/SKILL.md` convention line states both halves and points there. `prototype.md`'s *What remains* names admitted snippets. Lint OK.
- 2026-09-29 — Drill passed; four wording gaps fixed in place (record above).
- 2026-09-29 — Close review. **Standards:** pass. The exception sits inside the rule it modifies, as a table, with its rationale inline. **Intent:** pass, all 6 criteria met. The base rule reads correctly on its own, since its first sentence and rationale come before the exception. **Correctness:** pass. The links to `prototype.md` and `decide.md` resolve (lint check 3), and the rule does not conflict with *Track by impact* (implementation detail still stays out). **Security:** not applicable. **Comments:** not applicable.
