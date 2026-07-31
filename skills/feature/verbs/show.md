# /feature show — read-only view of a feature

Print a feature's current state without modifying anything.

## Steps

1. **Locate** `docs/features/FEATURE-NNN-slug/` (accept `FEATURE-012` or just `012` if unambiguous).
2. **Read** `idea.md`, `decisions.md`, and `status.md` (if present); note which prototype artifact exists.
3. **Cross-reference tasks** — Grep `tasks/` for `feature: FEATURE-NNN`; list them with status.
4. **Render to stdout:**
   - Title + phase + owner.
   - Decision table (ID · Decision · State · → Tasks).
   - Task progress (`done/total`) with per-task status.
   - Prototype: which form + path/branch, or "none".
   - **Phase honestly** — if all tasks are `done` but the human sign-off hasn't been
     recorded, the phase is `review` / "awaiting sign-off", **never "done"** and never a
     hybrid like "done (sign-off pending)". Code + tests green ≠ done.
   - Suggested next verb based on phase — the same gate order [pick](pick.md) uses (proposed rows
     remain → `/feature decide`; **approved/changed rows with an empty `→ Tasks` cell →
     `/feature decompose`**; phase `review` → `/feature review` to close the sign-off). Name the
     uncovered decision IDs when the gap is decomposition, and point at `/feature pick FEATURE-NNN`
     to act on it — `show` only reports.
5. **Never write** — this is read-only. For the saved stakeholder rollup, point at `/feature status`.
