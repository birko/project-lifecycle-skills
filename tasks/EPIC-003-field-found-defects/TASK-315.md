---
id: TASK-315
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-WT-3]
pr: null
github-issue: null
jira-key: null
---

# move.md never states the reopen it performs

## Context

Raised by the spec harvest of work-tracking (2026-10-13). `skills/tasks/SKILL.md` names `move` as a reopen trigger that does not ask (an open task moved in reopens a `done` or `cancelled` parent). `skills/tasks/verbs/move.md` step 6 only points at SKILL.md § *Roll status up to parents*, so a reader of the verb file alone cannot see that moving a task can reopen its new parent, or that it does so without asking. AGENTS.md: a verb file must be readable standalone.

## Acceptance criteria

- [x] move.md states, in its own words, that an open task moved under a `done` or `cancelled` container reopens it without asking, and why (the person named the target)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing what move does

## Human test plan

N/A — wording only; behaviour unchanged.

## Outcome

**What was fixed.** `move.md` step 6 rolled parents up by pointing at `SKILL.md` § *Roll status up to parents*, then referred to "the reopen above", a reopen the file never stated. A reader of the verb file alone could not tell that moving an open task under a `done` or `cancelled` container reopens it, or that it does so without asking. Step 6 now states it in its own words: the reopen, its dated `> Reopened … (move)` line, the epic re-check above a story target, why a move does not ask while `new` does (the person named the target), and that a closed child moved in reopens nothing.

**Step-6 split: 0/0.** The change is wording only and the behaviour is unchanged. `skills-lint.sh` passes (20 skills): a contract pin, not evidence.

**Judgement calls.**
- **Restated the rule as one invariant, not as a copy of the section.** It is the move-specific half of a shared rule, which is the load-bearing invariant AGENTS.md § *Defer to a shared inventory* allows. The section's other triggers are not listed, so nothing here goes stale when the shared section gains a row.

**Respec.** `work-tracking` unchanged: its roll-up requirement already covers a moved-in open child reopening its parent.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-327 because move.md step 6 refers to "the reopen above", which the file never states, so a standalone reader cannot tell the move reopens a closed parent (a silent state change, key 3), while TASK-327 is a missing report case for an empty pool; key 6 inert — both sit under EPIC-003 with no theme
- step 3 — verified: held. move.md step 6 points at SKILL.md § Roll status up and then says "the reopen above" with no reopen stated; SKILL.md says move reopens without asking because the person named the target
- step 4 — layer: local (skills/tasks/verbs/move.md)
- step 5 — fix in skills/tasks/verbs/move.md (step 6); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — wording only; fix-dependent = none; contract pins = skills-lint.sh
- step 7 — respecced work-tracking: unchanged — the roll-up requirement already states the reopen on move
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
