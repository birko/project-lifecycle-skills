---
id: TASK-212
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: verify
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [VC-055, CR-139, VC-056, CR-140, DRILL-214-1, VC-061]
pr: null
github-issue: null
jira-key: null
---

# Six older gaps in `block`, `close`, `init` 3b and the task template, found at the TASK-209, -214 and -215 closes

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
| VC-061 | `skills/tasks/templates/TASK.md`, the `# blocked: <reason> — add this line while the task is blocked` comment | Tells a reader to hand-add the field, which skips `/tasks block` (its placement, quoting and note) and contradicts *status changes go through their verbs*. Raised by TASK-215's conventions pass (2026-10-03); added before this task started |

## Acceptance criteria

- [x] `block.md` step 5 states the exact question put when `--reason` is omitted, and what happens when no
      answer comes — written as a reported unresolved state, never as a reason that reads as decided
- [x] `block.md`'s auto-unblock sentence counts `cancelled` dependencies as satisfied, consistent with `audit`
- [x] No sentence in `block.md` relies on a record that exists only in this repo; the rationale either stands
      on its own or the reference is removed
- [x] `init.md` 3b's pointer table says which heading a source that is itself a heading points to
- [x] `close.md` step 1 points at [[tasks]] § *Shape detection* for finding the task root
- [x] The `TASK.md` template's `blocked:` comment points at `/tasks block` instead of inviting a hand edit
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other skill files' references to this repo's records — a wider sweep belongs with TASK-210's classification
- Behaviour of `block`/`unblock` beyond these four lines

## Human test plan

- [ ] A cold run of `/tasks block TASK-X` with no `--reason` and nobody to answer, on an invented task: the
      run puts the stated question verbatim and ends in the stated no-answer state

## Outcome

**What was fixed.** Six small gaps, all in the `tasks` skill:

- **VC-055, `block.md` step 5:** "ask for one line if `--reason` omitted" had no wording and no no-answer path. With `--on`, the reason is now `waiting on <ids>` and nothing is asked. Without it, an exact question is put. With no answer, the task is blocked anyway with `blocked: reason unknown`, a note saying nobody gave a reason, and a step-7 line saying nobody chose it.
- **CR-139, `block.md` § Edge cases:** already half-fixed (it no longer said `done` only). It now defines a satisfied dependency as `done` or `cancelled`, like `audit` and `init` 3b, and the loop reads "close or cancel the blocker".
- **VC-056, `block.md`:** the two `(FEATURE-003 D1/D2)` citations pointed at records a consumer install does not have. Each is replaced by a reason that stands on its own.
- **CR-140, `init.md` 3b rung 3:** a new row for a source that is itself a heading, pointing at `(full text in the heading)`. It sits above "under a heading" because the first match wins.
- **DRILL-214-1, `close.md` step 1:** now points at SKILL.md § *Shape detection*.
- **VC-061, `TASK.md` template:** the `blocked:` comment now says "set by /tasks block, never by hand".

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills): a contract pin, not evidence. It does not scan `templates/`, so the template edit is checked by eye. The Human test plan's cold no-reason block is the evidence and has not been run.

**Judgement calls** (plan drafted at step 3b, before any edit).
- **No answer still blocks.** The person asked for the block, and its reason cannot be empty, so the documented fallback is written and marked as nobody's choice. "Don't block" would make the run's own decision override an explicit request, and it would leave no trace in the file.
- **`--on` derives the reason (added during re-verification).** `spawn.md` blocks its origin with `--on` and no `--reason`. Under the question alone, every unattended spawn would block with `reason unknown`, although the dependency it named *is* the reason. This stays inside VC-055's ask-step: it decides when the question is put.
- **Existing task files keep the old comment line.** The template change affects new tasks only. A sweep belongs to `adopt-project`'s reconciliation, not to this task.

**Respec.** `work-tracking`, *Blocking and unblocking*: the reason fallback, plus two scenarios. The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** `pick.md` still cites `FEATURE-001 D25`, a repo-only record. This task's Out of scope defers the wider sweep to TASK-210, so nothing was spawned.

## Implementation plan

_Drafted 2026-11-04 by the Plan agent (`/fix-next` step 3b, `/tasks plan --no-grill`)._

1. **VC-055**, `block.md` step 5: put an exact question when `--reason` is omitted. With no answer, block anyway with `blocked: reason unknown` and a note saying nobody gave a reason. The invocation asked for the block, and a block's reason cannot be absent (SKILL.md § *Writing a `blocked:` value*), so this is the "fallback, recorded as unchosen" shape. "Don't block" would replace the user's explicit act with the run's own decision.
2. **CR-139**, `block.md` § Edge cases: the sentence no longer says `done` only, but it never defines a satisfied dependency. Define it as `done` or `cancelled`, and make the loop "close or cancel the blocker".
3. **VC-056**, `block.md` block step 4 and unblock step 4: replace the FEATURE-003 D1/D2 citations with reasons that stand on their own.
4. **CR-140**, `init.md` 3b rung 3: add a row "a heading itself → (full text in the heading)" above "under a heading", since the first match wins.
5. **DRILL-214-1**, `close.md` step 1: point at SKILL.md § *Shape detection*.
6. **VC-061**, the `TASK.md` template's `blocked:` comment: "set by /tasks block, never by hand".
7. Lint; grep `block.md` for `FEATURE-` and `docs/`; check that `fix-next` and `decide` pass `--reason`.

## Progress log

- step 2 — picked; ranked above TASK-255 because VC-055 is an unworded ask-step on `/tasks block`, which `close`, `fix-next` and `decide` all chain into unattended (key 2), and VC-061 invites the hand edit the rulebook forbids (key 3); key 6 inert — both are correctness-invariants
- step 3b — planned: /tasks plan --no-grill (more than one file, seven criteria)
- step 3 — verified: held for five; CR-139 half-fixed already (the sentence no longer says `done` only) but never defines a satisfied dependency, so it is kept in scope as written
- step 4 — layer: local (skills/tasks)
- step 5 — fix in skills/tasks/verbs/block.md (steps 4, 5, unblock 4, § Edge cases), skills/tasks/verbs/init.md (3b rung 3), skills/tasks/verbs/close.md (step 1), skills/tasks/templates/TASK.md; tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan cold run, not run
- step 7 — respecced work-tracking; requirements changed: Blocking and unblocking (+2 scenarios); intended anyway — TASK-212's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
