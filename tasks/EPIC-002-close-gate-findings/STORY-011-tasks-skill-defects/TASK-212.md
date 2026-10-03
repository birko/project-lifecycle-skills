---
id: TASK-212
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [VC-055, CR-139, VC-056, CR-140, DRILL-214-1]
pr: null
github-issue: null
jira-key: null
---

# Five older gaps in `block`, `close` and `init` 3b, found at the TASK-209 and TASK-214 closes

## Context

Spawned at TASK-209's close (2026-10-03). Its review passes found these in text TASK-209 did not change, so
they are filed together rather than folded in: each is small, and all sit in `skills/tasks/verbs/block.md`
or `init.md` step 3b.

| Id | Where | Problem |
|---|---|---|
| VC-055 | `block.md` step 5, "Ask for one line if `--reason` omitted" | An ask-step with no question text and no answer-less path — the AGENTS.md § Output/prose rule. A run with nobody present has no defined outcome, and two runs ask different things |
| CR-139 | `block.md` § Edge cases, *Auto-unblock suggestion* | Says `audit` flags a blocked task "whose every `depends-on` is now `done`". `audit` and `init` 3b rung 2 both treat a `cancelled` dependency as satisfied too, so this sentence is the stale one |
| VC-056 | `block.md` steps 4 and unblock 4, "(FEATURE-003 D1)" / "(D2)" | Point at this repo's `docs/features/` records, which do not exist in a consumer's install — a reference a reader there cannot follow |
| CR-140 | `init.md` 3b, rung 3's pointer table | When the source is itself a heading (a `## DEFERRED <date> — …` line), "under a heading" is ambiguous: point at that heading, or at the one above it |
| DRILL-214-1 | `close.md` step 1, "**Find task root**." | Gives no method and no pointer. Both cold runners of TASK-214's drill flagged it (2026-10-03); the method is [[tasks]] § *Shape detection*, which `close` never names. Added before this task started |

## Acceptance criteria

- [ ] `block.md` step 5 states the exact question put when `--reason` is omitted, and what happens when no
      answer comes — written as a reported unresolved state, never as a reason that reads as decided
- [ ] `block.md`'s auto-unblock sentence counts `cancelled` dependencies as satisfied, consistent with `audit`
- [ ] No sentence in `block.md` relies on a record that exists only in this repo; the rationale either stands
      on its own or the reference is removed
- [ ] `init.md` 3b's pointer table says which heading a source that is itself a heading points to
- [ ] `close.md` step 1 points at [[tasks]] § *Shape detection* for finding the task root
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other skill files' references to this repo's records — a wider sweep belongs with TASK-210's classification
- Behaviour of `block`/`unblock` beyond these four lines

## Human test plan

- [ ] A cold run of `/tasks block TASK-X` with no `--reason` and nobody to answer, on an invented task: the
      run puts the stated question verbatim and ends in the stated no-answer state

## Implementation plan

_Populated by `/tasks plan TASK-212` — leave empty until then._
