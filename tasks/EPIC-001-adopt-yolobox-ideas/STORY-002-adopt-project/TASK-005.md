---
id: TASK-005
parent: STORY-002
feature: null
status: done
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

- [x] The universal-layer definition is stated **once** and consumed by both skills, rather than copied into each — a second copy is the drift this rule exists to prevent
- [x] The adopted-repo `BRIEF.md` rule lives with the skills, not only in STORY-001
- [x] `new-project` states, per artifact, what "merge" means when the file already exists: append a section, write a sibling, or leave it and report
- [x] Verified 2026-08-18: no "until `adopt-project` exists" clause survives anywhere in `AGENTS.md`, and the parity rule at § Conventions reads as the permanent hard rule
- [x] Both skills cross-link, and `README.md` presents them as the greenfield/brownfield pair

## Out of scope

- New layer artifacts — this task moves rules, it does not add any.

## Human test plan

- [x] Change the universal layer in one place and confirm both skills reflect it without a second edit
- [x] Drilled 2026-08-18 in three parts, because the documented behaviour has three branches. **(a) Rich README, no project yet** — a 7-section README about a design-phase product: the How-we-work pointer was **strictly appended** and every original line verified byte-identical by diff, matching `LAYER.md`'s *leave it; offer to append* rather than the seed template winning. **(b) Directory that already holds a project** (source + git history): `new-project` **bounced to [[adopt-project]]** and wrote nothing — no `CLAUDE.md`, no `tasks/`, no `docs/` — which is the step-1 guard, and the branch that matters most since it is the one that would clobber a real repo. **(c) Guide merge-by-section**: a guide carrying only `## Architecture` and `## Commands` gained `## Conventions` while both existing bodies stayed untouched. Run as fixtures rather than on a consumer repo: the check is whether the documented merge is what happens, and a fixture makes a wrong result obvious instead of destructive

## Implementation plan

1. `LAYER.md` moved to `skills/new-project/` — the skill that *creates* the layer owns its
   definition; `adopt-project` consumes it at `../new-project/LAYER.md`. The lint verifies that
   cross-skill path resolves, so a move cannot silently break it.
2. Split the two axes explicitly rather than merging them: `LAYER.md` is the **inventory** (which
   artifacts, who owns each, what to do if present); `new-project` SKILL.md step 3 keeps the
   **creation detail**. Add an artifact in the first, describe how to fill it in the second.
3. Routing fixed at the description level too — `new-project` now says outright to use
   `adopt-project` when the directory already holds code, so the wrong front door is less likely
   to be invoked in the first place.
