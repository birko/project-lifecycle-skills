---
id: TASK-234
parent: STORY-023
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
findings: [SH-43, SH-44]
pr: null
github-issue: null
jira-key: null
---

# `/feature status` re-collects what it was told to consume, and its phase rules leave ledgers with no phase

## Context

Found by the feature-lifecycle spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). Both findings are in
`skills/feature/verbs/status.md`, steps 1–3, and would be fixed in one pass over the derivation.

- **SH-43 — two collections.** Step 1 says to run [[roadmap]]'s Cross-tree pass and consume its output model, "don't
  re-enumerate", and buckets the tasks from the model. Step 3 then greps `tasks/` for `feature: FEATURE-NNN` itself and
  buckets again. Two collections of one fact can disagree, for example on a task that is taken on a branch.
- **SH-44 — the phase rules do not cover every ledger.** Step 2's rules:
  - `idea` needs no decisions stamped and no prototype; `prototyping` needs a prototype artifact; `deciding` needs the
    prototype done; `building` needs an `approved`/`changed` decision.
  - A ledger with no prototype and some rows stamped `deferred`/`removed` but none approved matches none of them. Nor
    does a ledger with only `deferred`/`removed` rows that is not `dropped`.
  - Whether a recorded `Skipped — <reason>` counts as "prototype done" is not said.
  - Where both `prototyping` and `deciding` hold, no precedence is given.

## Acceptance criteria

- [ ] Step 3 reads the tasks from step 1's model and does not grep again, or step 1 stops claiming it
- [ ] Step 2's rules assign exactly one phase to every combination of prototype line (Built / Skipped / Pending / N/A)
      and decision counts, with an evaluation order stated
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- DV1 reading the phase when `status.md` is absent — TASK-207
- Who writes the prototype line — TASK-240

## Human test plan

- [ ] On an invented `docs/features/` with three ledgers (no prototype + one `deferred` row; only `deferred` rows;
      `Skipped` + mostly `proposed`), run `/feature status`. Each gets one phase, and a second run agrees

## Implementation plan

_Populated by `/tasks plan TASK-234` — leave empty until then._
