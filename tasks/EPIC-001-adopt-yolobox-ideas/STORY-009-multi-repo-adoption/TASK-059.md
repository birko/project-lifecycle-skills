---
id: TASK-059
parent: STORY-009
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-22
depends-on: [TASK-053]
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# Reconcile the already-adopted repos against the grown layer

## Context

**Surfaced by TASK-053's out-of-scope sweep.** That task's `## Out of scope` said retro-adopting the
consumer repos *"belongs to whoever runs `adopt-project` there next"* — which names a mechanism, not an
owner, so nothing scheduled it.

The layer gained two rows at TASK-053 (`docs/glossary.md` and `docs/adr/`, both `(lazy)`). `AGENTS.md`
states the consequence directly: extending the layer without reconciling the repos already on it
*"silently strands every project already using the skills."* TASK-053 satisfied layer **parity** — both
front doors learned the rows in the same change — but parity is about the two skills agreeing, not about
the repos already in the field. Those are still on the older layer.

**This is the first real exercise of the upgrade path**, which is what makes it worth a task rather than a
chore. `adopt-project` advertises itself as *"the UPGRADE path — re-run it whenever the universal layer
grows"*, and that claim has not been tested against a layer that actually grew. If a re-run produces
spurious findings, a fill it should not offer, or an `already current` it cannot distinguish from
`brought up to date`, the defect is in the adopter and belongs back in `tasks/` — not worked around here.

**Known starting state**, measured 2026-08-22: `Birko/Consumers/WorkoutTracker` has a live layer
(`CLAUDE.md`, `docs/BRIEF.md`, `docs/architecture.md`, `docs/features/`, `docs/specs/`, `tasks/`) and
**neither** `docs/glossary.md` nor `docs/adr/`. That is the interesting case, not a gap: both new rows are
lazy, so the correct report is `not applicable yet` with no fill offered. A run that reports them
`missing`, or offers to create either, has found a real defect in TASK-053's work.

**Enumerate the consumers before starting**; the count is not assumed here, because a stale list is
exactly the kind of thing this task exists to stop propagating. `Birko/Consumers/` is the known home.

## Acceptance criteria

- [ ] The set of already-adopted repos is enumerated from disk, not from memory or a doc, and recorded on this task
- [ ] `adopt-project` is re-run against each, and each run's outcome is recorded: brought up to date, already current, or a defect found
- [ ] Every absent lazy row reports **not applicable yet** with **no fill offered** — a `missing` or an offer is a defect filed back against the adopter, not patched locally
- [ ] Any repo that *does* have a glossary reports **already current**, distinctly from having been brought up to date
- [ ] No consumer repo is written to without the user's go-ahead — the survey is read-only; the fill is not
- [ ] Defects found in `adopt-project` itself are spawned as their own tasks, with the repo and evidence named

## Out of scope

- The `LAYER.md` rows and both front doors — **TASK-053**, which this depends on.
- Fixing `adopt-project` defects this surfaces. Finding and filing them is the job; fixing them is whatever task each becomes.
- Adopting a repo that was **never** adopted. This is the upgrade path for repos already on the layer; a greenfield adoption is an ordinary `adopt-project` run.
- Backfilling glossary terms or ADRs in a consumer repo. Both rows are lazy — an empty one is the defect, so creating content is `[[domain]]`'s job in that repo, on its own schedule.

## Human test plan

- [ ] Run the adopter against `Birko/Consumers/WorkoutTracker` (live layer, no glossary, no `docs/adr/`) and confirm the report names both rows as part of the layer, states **not applicable yet**, offers no fill, and counts neither toward what the repo is missing
- [ ] Run it a second time against the same repo and confirm the report is unchanged — the states are derived, so a re-run must not drift
- [ ] Run it against a repo that **does** have a glossary and confirm **already current** reads as distinct from **brought up to date**
- [ ] Read each report as someone who does not know this change landed, and confirm no line reads as a gap or an oversight

## Implementation plan

_Populated by `/tasks plan TASK-059` — leave empty until then._
