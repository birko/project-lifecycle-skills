---
id: TASK-342
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/feature pick` words gate B's question twice

## Context

Found while planning TASK-336 (2026-11-04, a split signal in its plan, left unspawned), in `skills/feature/verbs/pick.md`. Gate B's question appears in the step-3 gate table as "N decision(s) still awaiting a verdict. Decide them now? [Y/n]" and again in the gate A–C questions table as "FEATURE-NNN has N decision(s) still awaiting a verdict: <ids>. Decide them now? [Y/n]". TASK-336 fixed the same doubling for gate D by making the gate-table cell point at the one wording. AGENTS.md's ask-step rule wants the question actually put, once.

## Acceptance criteria

- [x] Gate B's question is worded once; the gate-table cell points at it, as gate D's now does
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

N/A — one ask-step's wording; the reviewer check against the AGENTS.md ask-step rule at close covers it

## Outcome

**What was fixed.** `/feature pick` worded gate B's question twice: a paraphrase in the gate table and the exact question in the gate A–C table. The gate-table cell now points at the A–C table, as gate D's cell points at step 4 since TASK-336, so the question is stated once, word for word, beside its no-answer path.

**Step-6 split:** 0/0, because this is one line of prose. Evidence is the reviewer check the test plan names. Against AGENTS.md's ask-step rule, `grep "Decide them now" pick.md` finds one occurrence (line 51) with its no-answer path in the same row. No spec requirement or scenario quoted either wording, so `feature-lifecycle` is unchanged.

**Judgement calls.** None. Gate D's fix is the precedent.

**Flagged, not fixed.** Nothing.

## Implementation plan

_Populated by `/tasks plan TASK-342` — leave empty until then._

## Progress log

- step 2 — picked; ranked above TASK-333 because keys 1–3 tie (wording, silent) and key 4: a one-line fix in one file with gate D's fix as its precedent, where TASK-333 changes fix-next's own empty-pool branch; key 6 ties (neither declares a theme), key 7 ties (P3)
- step 3 — verified: held. pick.md:39's gate B cell quotes "N decision(s) still awaiting a verdict. Decide them now? [Y/n]", and the gate A–C table (line 51) puts "FEATURE-NNN has N decision(s) still awaiting a verdict: <ids>. Decide them now? [Y/n]". No spec scenario quotes either
- step 3b — not planned: one file, one criterion besides the lint, no feature:, no unknowns
- step 4 — layer: local
- step 5 — fix in skills/feature/verbs/pick.md:39 (gate B's cell points at the A–C table); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — one line of prose; evidence = the reviewer check (one occurrence of the question, with its no-answer path)
- step 7 — feature-lifecycle not respecced: no requirement or scenario quotes gate B's wording, so nothing in it is contradicted
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
