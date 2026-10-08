---
id: FEATURE-004
created: 2026-10-08
---

# Specs learn from OpenSpec — Decisions

> The decision ledger for stakeholders. Every idea-branch is a row with exactly one **state**. Rows are never deleted — `removed` is a state, not a deletion — so the ledger stays auditable.

## Decisions

| ID | Decision | State | Rationale | Date | By | → Tasks |
|----|----------|-------|-----------|------|----|---------|
| D1 | Regeneration flags a requirement it writes or rewrites that runs past about 500 characters, and suggests a split. Requirements it leaves untouched are not flagged | approved | The owner chose "new and changed only" in the grill. Splitting all 131 at once would produce a spec diff nobody can review for behaviour change | 2026-10-08 | owner | TASK-287 |
| D2 | The regeneration review lists each requirement as added, removed, renamed (old name → new name) or changed, and shows only the lines that changed | approved | The owner chose this in the grill | 2026-10-08 | owner | TASK-285 |
| D3 | Regeneration compares the old and new spec and names every worked example that disappeared. Each one must be either explained as behaviour that is really gone, or restored | approved | The owner chose this in the grill | 2026-10-08 | owner | TASK-286 |
| D4 | The repo's CI check also checks the structure of the spec files: a real Purpose, examples that have steps, and no two requirements whose names differ only in capitals | approved | The owner chose the CI check over the shipped `/specs verify`, because a broken spec then fails the build here | 2026-10-08 | owner | TASK-290 |
| D5 | A full regeneration saves each area as soon as its review is accepted, so an interrupted run keeps the areas it finished | approved | The owner chose this in the grill | 2026-10-08 | owner | TASK-288 |
| D6 | Every spec rewrite keeps the line endings the file already has | approved | The owner chose this in the grill | 2026-10-08 | owner | TASK-289 |
| D7 | A weekly GitHub job checks OpenSpec's releases and opens one issue per new release, with its notes. It changes nothing in the repo by itself | approved | The owner asked for a GitHub watcher, and chose a plain issue over auto-assigning Copilot or a Claude routine | 2026-10-08 | owner | TASK-291 |
| D8 | `/specs verify` needs no change for OpenSpec's fix to checks that were skipped but reported as passing. It already reports a check it could not run as "unknown", never as fresh | removed | Found while reading `verify`: a baseline it cannot resolve is reported as unknown, not as fresh. | 2026-10-08 | owner | — |
| D9 | Adopt OpenSpec itself, or its proposal-first flow | removed | Our specs are harvested from the code by design. | 2026-10-08 | owner | — |
| D10 | Each watcher issue carries the label `upstream: openspec` and is assigned to nobody; whoever wants to look filters by the label | approved | The owner chose a label over assigning the owner or Copilot (grill Q9) | 2026-10-08 | owner | TASK-291 |

_`Date` and `By` stay `—` until `/feature decide` stamps a verdict — they record **when/who decided**, not when the row was created (creation is in the History log)._

**States:** `proposed` (fresh from grill, awaiting decision) · `approved` (build it) · `deferred` (not now — note unblock condition) · `changed` (approved but altered — record the delta) · `removed` (rejected / out of scope).

Only `approved` and `changed` rows generate tasks at `/feature decompose`. No row is terminal: a `deferred`/`removed` decision overturned by later evidence (incl. production feedback) is **reopened** by adding a *new* `proposed` row that links the superseded one — the old row is never deleted.

## History log

> Append-only. Every state change gets a dated line with the reason — this is the "why it changed", not just the current value.

- 2026-10-08 — feature created; decisions seeded as `proposed` from the grill-me interview (seven questions put to the owner, one fact checked in `verify`).
- 2026-10-08 — D1–D7 `approved` and D8, D9 `removed`, all as the owner chose in the grill. D8: `verify` already reports what it could not check as unknown. D9: specs stay harvested from the code. Q9 answered as D10 (`approved`): watcher issues carry the label `upstream: openspec`.
- 2026-10-08 — decomposed under EPIC-009: D1 → TASK-287, D2 → TASK-285, D3 → TASK-286, D4 → TASK-290, D5 → TASK-288, D6 → TASK-289, D7 and D10 → TASK-291.
