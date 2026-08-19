---
id: TASK-032
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# A divergence cannot be recorded as accepted, so triage nags about a decision already made

## Context

Found while picking TASK-020 (2026-08-19) — the `pick` verb chains `triage`, whose step 8b prepends a
feature-drift callout to `tasks/README.md` whenever [[roadmap]]'s rules fire.

They fire on this repo. DV5 flags *"a story/epic with tasks but no feature folder"*, and all 30 tasks
here carry `feature: null` against zero `FEATURE-*` folders. But that is a **recorded stance**, not
drift: `docs/features/README.md` states *"the current work is deliberately task-only."* Writing the
callout would nag permanently about a decision already made, so the chained triage skipped it — which
is its own problem, because now a rule fired and nothing on disk says it was considered.

Both available behaviours are wrong:

- **Write the callout** — `tasks/README.md` carries a standing warning about an intended state. A
  warning that is always present is a warning nobody reads, which devalues the genuine ones beside it.
- **Skip it** (what happened) — indistinguishable from a `triage` that never ran the check. The next
  reader cannot tell "accepted" from "not looked at", the same collapse `unknown` vs `missing` exists
  to prevent one layer down.

The gap is that the divergence rules model only *detected / not detected*. There is no third state for
*detected and accepted*, and no place to write the acceptance — `docs/features/README.md` is a
generated file owned by `/feature status`, so the stance it currently states is not a durable record
either. Note the shape is general, not DV5's alone: any rule can fire on a deliberate arrangement.
DV8 already has a bespoke version of this (a `no spec surface` line in the ledger suppresses it), so
the pattern exists but is per-rule and undiscoverable.

## Acceptance criteria

- [ ] A divergence can be marked **accepted**, in a hand-editable file, with a reason and a date — never in a generated one
- [ ] An accepted divergence is suppressed from `triage`'s callout and from the compact `/tasks` slice, but still **listed as accepted** by `/roadmap`, so the audit stays complete
- [ ] `/roadmap --check` distinguishes three outcomes: in sync · accepted divergences only · real divergence
- [ ] Acceptance is scoped to a rule **and** a target, so accepting DV5 for this repo does not blanket-suppress DV5 elsewhere
- [ ] DV8's existing `no spec surface` carve-out is reconciled with the general mechanism rather than left as a second way to do the same thing
- [ ] This repo's own DV5 is recorded as accepted, so a `triage` run leaves evidence the check ran
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- The DV10 blind spot on prose-only repos — TASK-025 owns that.
- Adding or removing divergence rules. This is about what happens once one fires.
- Whether this repo *should* be task-only. It is, and that is not in question here.

## Human test plan

- [ ] Accept this repo's DV5, run `/tasks triage`, and confirm no callout appears **and** that the acceptance is visible somewhere a reader will find it
- [ ] Run `/roadmap` and confirm the accepted divergence is still reported, marked accepted
- [ ] Introduce a genuine second divergence and confirm it is *not* suppressed by the accepted one
- [ ] Confirm a DV8-suppressed feature behaves identically before and after the reconciliation
