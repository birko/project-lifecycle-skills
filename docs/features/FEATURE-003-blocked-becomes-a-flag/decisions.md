---
id: FEATURE-003
created: 2026-09-30
---

# Task states follow common practice — "blocked" becomes a flag — Decisions

> The decision ledger for stakeholders. Every idea-branch is a row with exactly one **state**. Rows are never deleted — `removed` is a state, not a deletion — so the ledger stays auditable.

## Decisions

| ID | Decision | State | Rationale | Date | By | → Tasks |
|----|----------|-------|-----------|------|----|---------|
| D1 | A task has five states: to do, in progress, awaiting verification, done, cancelled. "Blocked" is a **flag with a reason**, recorded on the task, which any open task can carry | approved | Matches Kanban and Jira, where blocked is a marker on a card, not a column. It separates where the work is from whether it can move now. Chosen by the owner in the playground | 2026-09-30 | František Bereň (owner) | TASK-196, TASK-197, TASK-198, TASK-204 |
| D2 | Unblocking removes the flag and leaves the task in the state it had | approved | Today an unblocked in-progress task falls back to "to do". Owner: "keďže niečo na nej už bolo spravené" (since work was already done on it) | 2026-09-30 | František Bereň (owner) | TASK-204 |
| D3 | "Finished, but the merge must wait" is an in-progress task with a "merge deferred" flag; "done" still means merged | approved | Today it becomes "blocked", which reads as if work stopped. Chosen by the owner in the playground (walkthrough 1) | 2026-09-30 | František Bereň (owner) | TASK-199, TASK-204 |
| D4 | "Awaiting check" is renamed "awaiting verification", **including the stored value** (`review` → `verify`); readers keep accepting `review` for files the migration cannot reach | approved | "Review" means code review everywhere else. The owner chose renaming the value, not only the prose. A copy in a repo nobody migrates must still read correctly | 2026-09-30 | František Bereň (owner) | TASK-196, TASK-197, TASK-198, TASK-200, TASK-201, TASK-204 |
| D5 | Existing `blocked` tasks are **rewritten once** by a migration. The state before blocking is read from the task file's git history; the migration asks only where the history cannot tell | approved | The owner chose rewriting over reading old files as "to do + flag". The history holds evidence that settles the prior state, so it is read, not guessed | 2026-09-30 | František Bereň (owner) | TASK-203, TASK-205, TASK-208, TASK-209 |
| D6 | A blocked task **stays in** the work `pick` and `fix-next` offer, marked blocked with its reason | approved | The owner's choice: a hidden task gets forgotten. It conflicts with D7, which D7 resolves | 2026-09-30 | František Bereň (owner) | TASK-196, TASK-204 |
| D7 | A blocked task cannot be started or finished while it carries the flag. Choosing one from `pick` asks *"Unblock and start?"* | approved | From the playground, where the flag stops "start" and "finish" and says why. Offering it (D6) and then silently refusing it would contradict each other | 2026-09-30 | František Bereň (owner) | TASK-204 |
| D8 | For projects that sync with GitHub Issues or Jira, the flag maps to that tracker's own marker: the label `blocked` on GitHub, the "Flagged" field on Jira. The flag's reason is added as a comment, and the issue's own open/closed state does not change | changed | Delta from the proposed row: the reason travels as a comment, and the remote state is left alone, because a blocked task is still open. Each tracker keeps its own familiar marker | 2026-09-30 | František Bereň (owner) | TASK-202 |
| D9 | `fix-next`, which runs with nobody to ask, ranks a blocked task but never starts it; it reports the block and takes the next unblocked task | approved | Open. D6 puts blocked tasks in its list and D7's question cannot be asked unattended, so this needs its own answer | 2026-09-30 | František Bereň (owner) | TASK-199 |

_`Date` and `By` stay `—` until `/feature decide` stamps a verdict — they record **when/who decided**, not when the row was created (creation is in the History log)._

**States:** `proposed` (fresh from grill, awaiting decision) · `approved` (build it) · `deferred` (not now — note unblock condition) · `changed` (approved but altered — record the delta) · `removed` (rejected / out of scope).

Only `approved` and `changed` rows generate tasks at `/feature decompose`. No row is terminal: a `deferred`/`removed` decision overturned by later evidence (incl. production feedback) is **reopened** by adding a *new* `proposed` row that links the superseded one — the old row is never deleted.

## History log

> Append-only. Every state change gets a dated line with the reason — this is the "why it changed", not just the current value.

- 2026-09-30 — feature created from the owner's reaction to the TASK-124 state-model playground (`docs/BRIEF.md`, 2026-09-30). D1–D3 come from the playground comparison. D4–D6 come from a three-question round, in which the owner chose against the agent's recommendation each time (rename the value, rewrite old files, keep blocked tasks on offer). D7 comes from the playground. D8 and D9 are open questions surfaced while writing the rows. All rows are seeded `proposed`.
- 2026-09-30 — D1, D2, D3, D4, D5, D6, D7, D9 proposed → approved; D8 proposed → changed (reason as a comment, remote state unchanged). Stamped by the owner in one round: D1–D3 had been chosen in the playground, D4–D6 in the earlier round, and D7 and D9 as recommended. **The prototype is kept for now, which departs from the throwaway rule, and the reason is recorded here:** it answered D1–D3, but it is also TASK-124's test instrument, and that test still needs a reader who does not know the codebase. Delete it when TASK-124 closes.
- 2026-09-30 — Decomposed under EPIC-006 / STORY-022 as a wide refactor (`skills/tasks/slicing.md`): expand TASK-196; migrate batches TASK-197 (feature), TASK-198 (roadmap), TASK-199 (fix-next), TASK-200 (specs), TASK-201 (both front doors), TASK-202 (tracker sync), TASK-203 (migration tool); contract TASK-204; rewrite TASK-205. D1 → TASK-196, TASK-197, TASK-198, TASK-204 · D2 → TASK-204 · D3 → TASK-199, TASK-204 · D4 → TASK-196, TASK-197, TASK-198, TASK-200, TASK-201, TASK-204 · D5 → TASK-203, TASK-205 · D6 → TASK-196, TASK-204 · D7 → TASK-204 · D8 → TASK-202 · D9 → TASK-199. Measured before slicing: `blocked` on 59 lines and `review` as a status on 89 lines in `skills/`; 40 `blocked` and 31 `review` tasks across the consumer repos.
- 2026-10-02 — D5 — TASK-208 spawned from TASK-205 (the reason ladder in `init` step 3b writes "reason unknown" over a reason stated in four real shapes; found by TASK-205's check on Symbio)
- 2026-10-03 — D5 — TASK-209 spawned from TASK-208's close (seven older edge cases in the blocked-field writers, CR-132–CR-138, found by its correctness pass)
