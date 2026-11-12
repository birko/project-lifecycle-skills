---
id: TASK-352
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-93]
pr: null
github-issue: null
jira-key: null
---

# Decide whether `domain` gains a pass that checks decision records against the code

## Context

Spawned 2026-11-12 from TASK-275. SH-93 found that `skills/new-project/LAYER.md`'s `docs/adr/` row assigned "ADR
drift" (a record that still has all four parts but cites a changed rule, or states a decision the code no longer
matches) to `/domain`'s cross-reference pass, which reads only the glossary against the code. TASK-275 took the
reversible half: LAYER.md now says no skill audits ADR drift. This task is the other half, and it is a **decision**,
which is why it was not folded in: adding a pass is new scope for `domain`.

**What argues for a pass.** LAYER.md's own measurement: a cold read of seven records found three such drifts
(2026-08-22), none of them a missing part, so nothing structural catches them.

**What argues against.** "Does this record still match the code" is a judgement over prose, with the false-positive
profile AGENTS.md § *Framework / stack* measured and rejected for an automatic wikilink check. A pass nobody trusts
gets muted. `domain` is applied during a grill or a design, not run as a sweep, so a periodic audit may not fit its
shape at all.

## Acceptance criteria

- [ ] Decide: `domain` gains a stated ADR-drift pass (with its trigger, its scope and what it reports), or ADR drift stays unowned with the reason recorded
- [ ] If a pass is added, LAYER.md's `docs/adr/` row names it as the owner, and `domain`'s § *The bar* or a new section carries it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The wording TASK-275 settled

## Human test plan

- [ ] If a pass is added: a cold runner, given a fixture with one record whose cited rule has since changed, runs it and reports that record. Otherwise N/A, with the reason

## Implementation plan

_Populated by `/tasks plan TASK-352` — leave empty until then._
