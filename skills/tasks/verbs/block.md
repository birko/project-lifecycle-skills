# /tasks block / unblock — mark a task blocked or clear it

Set or clear `status: blocked` — work that *can't proceed* until something else happens. One file,
two directions: `/tasks block <ID>` and `/tasks unblock <ID>`.

> **`blocked` ≠ `todo`.** A `todo` task is pick-able now; a `blocked` task is deliberately held
> and is **excluded from "Next up"** in the snapshot and from `/tasks pick` defaults. Blocking is
> how you take something out of the ready pool without cancelling it.

## block — `/tasks block <ID>`

1. **Find task root**; locate the TASK file by ID (Grep `^id: TASK-NNN$`).
2. **Parse args**:
   - `<ID>` — required (tasks only — EPIC/STORY don't carry `blocked`).
   - `--reason "<text>"` — recommended (why it's blocked).
   - `--on <TASK-NNN[,TASK-NNN…]>` — optional: the task(s) this is waiting on. Adds them to `depends-on` (deduped) so the block is *structural*, not just a status flag.
3. **Read current status**:
   - `done`/`cancelled` → refuse ("can't block finished work").
   - `in-progress` → confirm ("work is in progress — park it as blocked?").
4. **Edit frontmatter**:
   - `status: … → status: blocked`.
   - If `--on` given, merge the IDs into `depends-on: [...]` (validate each exists; warn on a missing/cancelled target).
5. **Record the reason** — append a body note: `> Blocked {{today}} — <reason>` (runtime date). Ask for one line if `--reason` omitted.
6. **Regenerate dashboard** ([triage](triage.md)) — blocked tasks render `⚠ blocked` and drop out of "Next up".
7. **Confirm** — print `status: … → blocked`, any `depends-on` added, the reason.

## unblock — `/tasks unblock <ID>`

1. **Locate** the TASK file.
2. **Read current status** — if it isn't `blocked`, warn ("not blocked — nothing to clear") and stop.
3. **Clear depends-on (optional)** — if `--clear-deps` is passed, drop now-satisfied (`done`) IDs from `depends-on`; otherwise leave `depends-on` as the historical record and only change status.
4. **Edit frontmatter** — `status: blocked → status: todo` (back into the ready pool). If the user says work resumes immediately, allow `→ in-progress` instead (or just run `/tasks pick <ID>` next).
5. **Append a body note** — `> Unblocked {{today}} — <reason / what resolved it>`.
6. **Regenerate dashboard**.
7. **Confirm** — print `status: blocked → todo` (or `in-progress`) and the note.

## Edge cases

- **Auto-unblock suggestion** — `/tasks close`/`cancel` doesn't auto-unblock dependents (status
  changes stay explicit), but `/tasks audit` flags a `blocked` task whose every `depends-on` is now
  `done` as an unblock candidate. So the loop is: close the blocker → `audit` surfaces it → `unblock`.
- **Block with no `--on`** — fine; not every block is a task dependency (waiting on a stakeholder,
  an external service, a decision). The reason note carries the why; `depends-on` stays empty.
- **Blocking on a cancelled task** — warn: the blocker will never complete, so this is really a
  cancel or a re-scope, not a block. Confirm intent.
- **A whole STORY/EPIC is stuck** — there's no `blocked` status for containers; block the
  individual tasks, or note it in the EPIC body. Don't invent a container-level blocked state.
