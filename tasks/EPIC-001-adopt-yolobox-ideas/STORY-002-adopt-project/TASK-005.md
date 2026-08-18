---
id: TASK-005
parent: STORY-002
feature: null
status: todo
priority: P2
assignee: unassigned
created: 2026-08-18
depends-on: [TASK-003]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Layer parity: backport the brownfield rules into new-project

## Context

STORY-001 ran `new-project` against a repo with 36 commits and found it has no brownfield path.
Two gaps were recorded there rather than fixed, because `adopt-project` did not yet exist to
share the rules with:

1. **`docs/BRIEF.md` cannot be stored verbatim** when no original ask survives. The rule settled
   in STORY-001 — stamp the adoption date, state that no original ask survives, log forward — is
   currently written only in a story file.
2. **"Merge, don't clobber" gives no guidance** on *how* to merge. This repo's `README.md` was
   richer than the seed template and the sections were appended by hand, with the skill silent
   on whether that was right.

The layer-parity rule in `AGENTS.md § Conventions` exists to stop exactly this divergence, and it
currently carries a temporary clause saying a layer change may satisfy it by booking itself onto
STORY-002. **This task is what discharges that clause** — remove it once both skills share the rules.

## Acceptance criteria

- [ ] The universal-layer definition is stated **once** and consumed by both skills, rather than copied into each — a second copy is the drift this rule exists to prevent
- [ ] The adopted-repo `BRIEF.md` rule lives with the skills, not only in STORY-001
- [ ] `new-project` states, per artifact, what "merge" means when the file already exists: append a section, write a sibling, or leave it and report
- [ ] The temporary clause in `AGENTS.md § Conventions` (layer parity "until `adopt-project` exists") is removed, and the rule reads as the permanent one
- [ ] Both skills cross-link, and `README.md` presents them as the greenfield/brownfield pair

## Out of scope

- New layer artifacts — this task moves rules, it does not add any.

## Human test plan

- [ ] Change the universal layer in one place and confirm both skills reflect it without a second edit
- [ ] Re-run `new-project` on a repo with an existing README and confirm the documented merge behaviour is what actually happens

## Implementation plan

_Draft after TASK-003 — where the shared layer definition lives depends on the shape TASK-003
gives the survey checklist._
