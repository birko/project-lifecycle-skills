---
id: TASK-047
parent: STORY-005
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-20
depends-on: [TASK-046]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `verify-intent` reads the feature ledger and the specs, not just the task

## Context

TASK-046 ships the fidelity axis grounded in one source: the closing task's `## Acceptance criteria`.
That is the narrowest complete slice, and it is not the whole of "what was asked". Two more records in
this repo state intent, and the story names both:

- **The feature's approved decisions** (`docs/features/FEATURE-NNN/decisions.md`) — what was agreed,
  which a task's criteria may implement only partially or may have drifted from.
- **`docs/specs/` for the touched area** — what the code is supposed to do, harvested rather than
  hand-written. The story argues this beats a tracker lookup precisely because **it is in the repo**,
  so it cannot be stale relative to a ticket nobody updated.

The ordering matters and needs stating: these sources can **disagree**. A task criterion that
contradicts an approved decision is itself a finding, not a tiebreak to resolve silently — the
[[feature]] ledger is the record of what was agreed, so a diff matching the task but contradicting the
decision is exactly the "clean code implementing the wrong thing" this axis exists to catch.

**This repo cannot fully drill it yet.** `docs/features/` holds no features and `docs/specs/.map.yml`
is still `areas: []` (STORY-008). So the spec and decision paths need either a fixture or a consumer
repo to exercise — say which was used rather than marking the plan run on the task path alone.

## Acceptance criteria

- [ ] Given a task carrying `feature: FEATURE-NNN`, the approved and `changed` decisions in that
      feature's ledger are read as intent alongside the task's criteria
- [ ] Given a diff touching files a `docs/specs/` area covers, that area's spec is read as intent
- [ ] The precedence between disagreeing sources is **stated**, and a contradiction between them is
      reported as its own finding rather than silently resolved
- [ ] Absent sources degrade cleanly and **say so** — no features, no spec map, or a task with
      `feature: null` must report which sources it actually read, not fall silently back to one
- [ ] Reuses [[roadmap]]'s collection pass and [[specs]]' area mapping rather than re-deriving either
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Generating or repairing specs — [[specs]] owns that; this only reads them.
- The empty spec map and empty feature tree in this repo — STORY-008 and a future feature own those.
  This task works against whatever exists and reports what it read.
- Changing the decision ledger's shape.

## Human test plan

- [ ] On a repo or fixture with a real feature ledger, run against a diff that satisfies the task's
      criteria but contradicts an approved decision, and confirm the contradiction is reported
- [ ] Run against a diff touching a spec-covered area and confirm the spec is named among the sources read
- [ ] Run in this repo — no features, empty spec map — and confirm it reports reading only the task's
      criteria, explicitly, rather than appearing to have checked all three
- [ ] Record which repo or fixture was used for the first two steps; they are not drillable here

## Implementation plan

_Populated by `/tasks plan TASK-047` — leave empty until then._
