---
id: FEATURE-005
created: 2026-11-13
---

# UX baseline for UI review and prototypes — Decisions

> The decision ledger for stakeholders. Every idea-branch is a row with exactly one **state**. Rows are never deleted — `removed` is a state, not a deletion — so the ledger stays auditable.

## Decisions

| ID | Decision | State | Rationale | Date | By | → Tasks |
|----|----------|-------|-----------|------|----|---------|
| D1 | The UX baseline is one owned list, `skills/verify-conventions/ux-baseline.md`: each row an interaction heuristic with a signal you can see in a change and a suggested move | approved | One owner, read by every skill that applies it, so the list cannot drift into copies. It sits beside the existing code-smell inventory and follows its shape | 2026-11-13 | František Bereň (owner) | TASK-293 |
| D2 | `/verify-conventions` checks user-interface changes against it, as labelled, non-blocking findings, and a rule the project recorded always wins | approved | A baseline is a judgement call, not the project's rule, so it may question a change but never fail one | 2026-11-13 | František Bereň (owner) | TASK-293 |
| D3 | `/feature prototype` points mockups and wireframes at it, and a prototype choice the baseline questions becomes a decision row, not a silent default | approved | Prototypes are where interaction choices are first made, so that is where the question is cheapest | 2026-11-13 | František Bereň (owner) | TASK-293 |
| D4 | No `new-project` intake question about a project's confirm-versus-undo policy | removed | Decided not to do on 2026-10-11 (TASK-293's Out of scope): a project that cares writes the rule in one line and the baseline yields to it, so asking every new project costs more than it saves | 2026-11-13 | František Bereň (owner) | — |

_`Date` and `By` stay `—` until `/feature decide` stamps a verdict — they record **when/who decided**, not when the row was created (creation is in the History log)._

**States:** `proposed` (fresh from grill, awaiting decision) · `approved` (build it) · `deferred` (not now — note unblock condition) · `changed` (approved but altered — record the delta) · `removed` (rejected / out of scope).

Only `approved` and `changed` rows generate tasks at `/feature decompose`. No row is terminal: a `deferred`/`removed` decision overturned by later evidence (incl. production feedback) is **reopened** by adding a *new* `proposed` row that links the superseded one — the old row is never deleted.

## History log

> Append-only. Every state change gets a dated line with the reason — this is the "why it changed", not just the current value.

- 2026-11-13 — feature created as a backfill for work shipped under EPIC-010 (TASK-293, done 2026-10-11), so EPIC-010's work traces to a feature; decisions D1–D4 seeded from TASK-293's acceptance criteria and Out of scope, no grill.
- 2026-11-13 — D1–D3 approved (already built by TASK-293), D4 removed (decided against on 2026-10-11), by the owner.
- 2026-11-13 — signed off at review: every approved decision is built (TASK-293, done) and TASK-293's Human test plan was run at its close; feature marked done.
