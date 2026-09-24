---
id: FEATURE-001
created: 2026-09-18
---

# Task worktrees — run a task in its own checkout — Decisions

> The decision ledger for stakeholders. Every idea-branch is a row with exactly one **state**. Rows are never deleted — `removed` is a state, not a deletion — so the ledger stays auditable.

## Decisions

| ID | Decision | State | Rationale | Date | By | → Tasks |
|----|----------|-------|-----------|------|----|---------|
| D1 | Treat a worktree as a first-class workspace, serving all four motives — parallel tasks/agents, a permanently clean main copy, disposable drill checkouts, side-by-side branch review | approved | All four claimed; only parallelism is impossible with a branch, but the set is what makes this a workspace concept rather than a drill helper | 2026-09-18 | František Bereň | TASK-173, TASK-179 |
| D2 | Declare it in its own `workspace: in-place \| worktree` field, leaving `integration:` untouched | approved | `integration:` answers *how work lands*, this answers *where work happens*; one field carrying both would hand `close` a value it cannot act on, and `single-branch` + worktree is incoherent | 2026-09-18 | František Bereň | TASK-173 |
| D3 | When the running tool cannot enter a worktree: create nothing, cut `task/TASK-NNN` in place as today, and report the degradation | approved | A branch checked out in a worktree cannot be checked out in the main copy, so creating one nobody enters would silently land the work on the default branch — a trap, not a soft fallback | 2026-09-18 | František Bereň | TASK-175 |
| D4 | Prove the move from evidence (`git rev-parse --show-toplevel` equals the worktree path), never from the agent's own claim; on mismatch remove the worktree and fall back to D3 | approved | An agent asked "can you do X?" tends to answer yes — DRILL-109 measured two cold runners inventing a blessing nobody gave | 2026-09-18 | František Bereň | TASK-175 |
| D5 | Worktrees live **outside** the repository, under a declared `worktree-root:` | approved | Requester's call: an in-repo path risks polluting the repository by accident. Nothing in a repo determines where worktrees belong, so it is a declaration rather than a convention | 2026-09-18 | František Bereň | TASK-173, TASK-174 |
| D5a | Worktrees inside the repository at a fixed `<repo>/wt/` needing no declaration — **superseded by D5** | removed | Rejected on pollution risk. Kept as a row so the ledger records the choice rather than losing it | 2026-09-18 | František Bereň | — |
| D6 | `worktree-root:` absent → ask, suggesting `../wt`. No answer → write nothing, fall back to D3, report `worktree-root undeclared` | approved | Requester's words: "if no path is declared ask for one first or suggest one". The answer-less path is the rulebook's ask-step rule — a suggestion must never become a declaration nobody made | 2026-09-18 | František Bereň | TASK-174 |
| D7 | `close` merges by driving the main copy from the worktree (`git -C <main-tree> merge --no-ff task/TASK-NNN`); main copy dirty or off the default branch ⇒ failed close, task keeps its prior status | approved | Works offline and with no PR, and keeps `close` one continuous flow — the session moves once, at the end. The failure mode is already defined: "the merge failing is a failed close" | 2026-09-18 | František Bereň | TASK-176 |
| D8 | Fix the close tail ordering: merge → leave the worktree → `git worktree remove` → `git branch -d`; a dirty worktree at removal is reported, never force-removed | approved | Forced by git: you cannot delete the folder you are standing in, and a branch cannot be deleted while a worktree holds it. Force-removing would destroy uncommitted work at the one step that is supposed to be safe | 2026-09-18 | František Bereň | TASK-176 |
| D9 | Ship the new declaration through both front doors in the same change — [[new-project]] creates it, [[adopt-project]] backfills it — per the layer-parity rule | approved | The rulebook's hard rule; extending one door without the other strands every project already using the skills | 2026-09-18 | František Bereň | TASK-177 |
| D10 | Give drills a declared home under the same root, replacing the current "a clone or worktree" prose with a path and a cleanup rule | approved | The same declaration doing a second job for free, and the current prose is genuinely incomplete — it names no location and no owner for deleting the copy | 2026-09-18 | František Bereň | TASK-178 |

_`Date` and `By` stay `—` until `/feature decide` stamps a verdict — they record **when/who decided**, not when the row was created (creation is in the History log)._

**States:** `proposed` (fresh from grill, awaiting decision) · `approved` (build it) · `deferred` (not now — note unblock condition) · `changed` (approved but altered — record the delta) · `removed` (rejected / out of scope).

Only `approved` and `changed` rows generate tasks at `/feature decompose`. No row is terminal: a `deferred`/`removed` decision overturned by later evidence (incl. production feedback) is **reopened** by adding a *new* `proposed` row that links the superseded one — the old row is never deleted.

## History log

> Append-only. Every state change gets a dated line with the reason — this is the "why it changed", not just the current value.

- 2026-09-18 — feature created; decisions seeded as `proposed` from the grill-me interview. D5a is carried as a row rather than dropped: the requester considered the in-repo location and rejected it on pollution risk, so the ledger records the choice instead of losing it.
- 2026-09-18 — D1, D2, D3, D4, D5, D6, D7, D8, D9 proposed → approved; D5a proposed → removed (in-repo `wt/` rejected on pollution risk); D10 proposed → approved. Stamped as a batch, because each verdict was already given during the grill and re-asking a resolved question is the defect this rulebook lints for.
- 2026-09-18 — **Provenance note on the batch.** D2, D4 and D8 originated as the agent's derivation during the grill rather than the stakeholder's explicit pick — D2 from the observation that `single-branch` + worktree is incoherent, D4 from the DRILL-109 measurement, D8 from two git constraints with no alternative. They were shown before stamping and approved with the rest, but the distinction is recorded so a later reader can tell which rows carry the stakeholder's own reasoning. D10 was the one row nobody had answered; it was put separately and approved on its own.
- 2026-09-24 — Decomposed under EPIC-005 / STORY-021. D1 (approved) → TASK-173, TASK-179 · D2 → TASK-173 · D3 → TASK-175 · D4 → TASK-175 · D5 → TASK-173, TASK-174 · D6 → TASK-174 · D7 → TASK-176 · D8 → TASK-176 · D9 → TASK-177 · D10 → TASK-178. D5a (removed) generates nothing. Three choices were left open on purpose, each to come back through `/feature decide` when its task settles it: what happens when a project declares worktrees but commits straight to the main line (TASK-173), the folder layout under the worktree root (TASK-174), and whether an absent `workspace:` is a gap for the adopter to raise or simply means "work in place" (TASK-177).
- 2026-09-24 — Prototype settled as **Skipped**: there is nothing visual here, and the proof is the end-to-end drill (TASK-179). The wording of the one question this feature puts to a person is pinned verbatim in TASK-174 instead.
