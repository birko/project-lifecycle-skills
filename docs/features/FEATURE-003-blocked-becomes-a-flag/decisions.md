---
id: FEATURE-003
created: 2026-09-30
---

# Task states follow common practice — "blocked" becomes a flag — Decisions

> The decision ledger for stakeholders. Every idea-branch is a row with exactly one **state**. Rows are never deleted — `removed` is a state, not a deletion — so the ledger stays auditable.

## Decisions

| ID | Decision | State | Rationale | Date | By | → Tasks |
|----|----------|-------|-----------|------|----|---------|
| D1 | A task has five states: to do, in progress, awaiting verification, done, cancelled. "Blocked" is a **flag with a reason**, recorded on the task, which any open task can carry | proposed | Matches Kanban and Jira, where blocked is a marker on a card, not a column. It separates where the work is from whether it can move now. Chosen by the owner in the playground | — | — | — |
| D2 | Unblocking removes the flag and leaves the task in the state it had | proposed | Today an unblocked in-progress task falls back to "to do". Owner: "keďže niečo na nej už bolo spravené" (since work was already done on it) | — | — | — |
| D3 | "Finished, but the merge must wait" is an in-progress task with a "merge deferred" flag; "done" still means merged | proposed | Today it becomes "blocked", which reads as if work stopped. Chosen by the owner in the playground (walkthrough 1) | — | — | — |
| D4 | "Awaiting check" is renamed "awaiting verification", **including the stored value** (`review` → `verify`); readers keep accepting `review` for files the migration cannot reach | proposed | "Review" means code review everywhere else. The owner chose renaming the value, not only the prose. A copy in a repo nobody migrates must still read correctly | — | — | — |
| D5 | Existing `blocked` tasks are **rewritten once** by a migration. The state before blocking is read from the task file's git history; the migration asks only where the history cannot tell | proposed | The owner chose rewriting over reading old files as "to do + flag". The history holds evidence that settles the prior state, so it is read, not guessed | — | — | — |
| D6 | A blocked task **stays in** the work `pick` and `fix-next` offer, marked blocked with its reason | proposed | The owner's choice: a hidden task gets forgotten. It conflicts with D7, which D7 resolves | — | — | — |
| D7 | A blocked task cannot be started or finished while it carries the flag. Choosing one from `pick` asks *"Unblock and start?"* | proposed | From the playground, where the flag stops "start" and "finish" and says why. Offering it (D6) and then silently refusing it would contradict each other | — | — | — |
| D8 | For projects that sync with GitHub Issues or Jira, the flag maps to that tracker's own marker (a label on GitHub, the "Flagged" field on Jira) | proposed | Open. Needs checking against each tracker before it is decided | — | — | — |
| D9 | `fix-next`, which runs with nobody to ask, ranks a blocked task but never starts it; it reports the block and takes the next unblocked task | proposed | Open. D6 puts blocked tasks in its list and D7's question cannot be asked unattended, so this needs its own answer | — | — | — |

_`Date` and `By` stay `—` until `/feature decide` stamps a verdict — they record **when/who decided**, not when the row was created (creation is in the History log)._

**States:** `proposed` (fresh from grill, awaiting decision) · `approved` (build it) · `deferred` (not now — note unblock condition) · `changed` (approved but altered — record the delta) · `removed` (rejected / out of scope).

Only `approved` and `changed` rows generate tasks at `/feature decompose`. No row is terminal: a `deferred`/`removed` decision overturned by later evidence (incl. production feedback) is **reopened** by adding a *new* `proposed` row that links the superseded one — the old row is never deleted.

## History log

> Append-only. Every state change gets a dated line with the reason — this is the "why it changed", not just the current value.

- 2026-09-30 — feature created from the owner's reaction to the TASK-124 state-model playground (`docs/BRIEF.md`, 2026-09-30). D1–D3 come from the playground comparison. D4–D6 come from a three-question round, in which the owner chose against the agent's recommendation each time (rename the value, rewrite old files, keep blocked tasks on offer). D7 comes from the playground. D8 and D9 are open questions surfaced while writing the rows. All rows are seeded `proposed`.
