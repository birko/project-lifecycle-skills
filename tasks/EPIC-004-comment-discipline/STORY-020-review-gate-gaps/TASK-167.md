---
id: TASK-167
parent: STORY-020
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-24
depends-on: []
blocks: []
findings: [VI-F002-1]
pr: null
github-issue: null
jira-key: null
---

# The close gate's own text still counts three axes after the fourth shipped

## Context

Found by `/feature review FEATURE-002` Gate A (fidelity), 2026-09-24: **D8 is partly built.** The
comments axis runs — `skills/tasks/verbs/close.md` step 5b invokes [[review-comments]] — but the text that
*names and counts* the axes was never updated:

| Site | Says |
|---|---|
| `skills/tasks/verbs/close.md:100` (step 5b heading) | *"Standards + fidelity + correctness — the merge gate"* |
| `close.md:117-118` | *"Three run unconditionally — standards, fidelity, correctness — and [[security-review]] makes a fourth when…"* — the comments axis, also conditional, is missing |
| `AGENTS.md` § *Independent review axes are reported side by side* | *"today `close` step 5b's standards, fidelity and correctness"* |
| `AGENTS.md` § Working rules, and `skills/new-project/templates/CONVENTIONS-universal.md:42` | the close checks named as `/verify-conventions` and `/code-review` only — `verify-intent` was already missing before this feature; `review-comments` now is too |

`close.md:121-123` itself warns that a hard-coded count rots when an axis arrives. This is that rot,
arriving through a later axis.

## Acceptance criteria

- [x] `close.md` step 5b's heading and its unconditional/conditional sentence name the comments axis, as a conditional pass (it runs when the diff carries a comment) — and do not introduce a new hard count.
- [x] `AGENTS.md` § *Independent review axes* names every axis `close` step 5b runs, or stops enumerating and points at step 5b — whichever keeps it from rotting on the next axis.
- [x] The Working-rules line in `AGENTS.md` and in `CONVENTIONS-universal.md` names the close checks correctly, or points at `/tasks close` step 5b instead of listing them. The universal file ships to every consumer, so its wording stays project-neutral.
- [x] `skills/tasks/verbs/intake.md`'s prefix table — *"the only list of prefixes"* — gains a `VI-*` row for [[verify-intent]]. The fidelity axis shipped without one, so this task's own `findings:` id was minted against a row that did not exist yet: the same arity rot, in the list findings are filed by. (Added at filing, before pick — FEATURE-002's review found it while choosing these tasks' ids.)
- [x] `bash .github/workflows/skills-lint.sh` passes; check 5 unaffected (the Working rules sit outside the marker block — confirm).

## Out of scope

- The comments axis's behaviour — built and drilled (TASK-144).

## Human test plan

- [x] A cold reader given `close.md` alone is asked which passes step 5b runs and when each is conditional. Expected: all five named — standards, fidelity, correctness, comments, security — with comments and security conditional.

## Implementation plan

Name no count anywhere: the heading names the step, the sentence names each pass with its condition, and `AGENTS.md` points at step 5b instead of listing. Working-rule lines point at step 5b too. `VI-*` row added to intake; its prose's "four review passes" count dropped in the same pass.

**Outcome (2026-09-24).** `close.md` step 5b is headed *"The review axes — the merge gate"*, and its
counting sentence names standards, fidelity and correctness as unconditional, [[security-review]] when the
diff touches a security surface and [[review-comments]] when it carries a comment — no number. `AGENTS.md`
§ *Independent review axes* now points at step 5b's own text as the list. Both Working-rules lines point at
step 5b. `intake.md` gains `VI-*`, and its *"none of the four review passes above"* lost the count.

**Human test, run:** a cold reader (`claude -p --disable-slash-commands --permission-mode plan`, `close.md`
alone in a scratch directory, listed no skills) named all five passes, comments and security conditional,
and counted verdicts off the passes that ran. It also raised the PR-diff `review` pass, which the counting
sentence does not mention — whether it is its own verdict or part of correctness. **Pre-existing, one
reader, recorded here, not filed**; it bites only PR-per-task projects.

**Gate, inline:** standards ✅ (no count reintroduced; check 5 agrees — the Working rules sit outside the
markers) · fidelity ✅ criteria 1-5 · correctness ✅ lint OK · comments: n/a. Security: n/a.
