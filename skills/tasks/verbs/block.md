# /tasks block / unblock — mark a task blocked or clear it

Set or clear the `blocked:` field — work that *can't proceed* until something else happens. One file,
two directions: `/tasks block <ID>` and `/tasks unblock <ID>`.

> **`blocked` ≠ `todo`.** A `todo` task is pick-able now; a `blocked` task is deliberately held
> and is **excluded from "Next up"** in the snapshot and from `/tasks pick` defaults. Blocking is
> how you take something out of the ready pool without cancelling it.

## block — `/tasks block <ID>`

1. **Find task root**; locate the TASK file by ID (Grep `^id: TASK-NNN[[:space:]]*$`).
2. **Parse args**:
   - `<ID>` — required (tasks only — EPIC/STORY don't carry `blocked`).
   - `--reason "<text>"` — recommended (why it's blocked).
   - `--on <TASK-NNN[,TASK-NNN…]>` — optional: the task(s) this is waiting on. Adds them to `depends-on` (deduped) so the block is *structural*, not just a status flag.
3. **Read current status**:
   - `done`/`cancelled` → refuse ("can't block finished work").
   - `in-progress` → confirm: **"TASK-NNN is in progress. Block it? Its status stays `in-progress`."**
     **No answer, or nobody to ask:** block it, since the invocation itself asked for this, and say in step 7
     that nobody confirmed. The question exists to catch a mistyped id, and the confirmation line is what
     lets someone notice one afterwards.
     - **Exception: invoked by [`close`](close.md) step 6 for a deferred merge.** The user already
       chose to defer at 5c, so don't re-ask — apply the block with the reason
       (`merge deferred: <reason>; code complete on task/TASK-NNN`) and any `--on` dependency. This
       is the one path where `blocked` means *finished but not integrated* rather than *not
       proceeding*; the reason note is what tells a reader which it is, so never write it bare.
4. **Edit frontmatter**:
   - Add `blocked: <reason>` on the line after `status:`, and **leave `status:` as it is**, so the task keeps the
     state its work is in (FEATURE-003 D1). Already blocked by either form → warn ("already blocked: <reason>")
     and stop.
   - If `--on` given, merge the IDs into `depends-on: [...]` (validate each exists; warn on a missing/cancelled target).
5. **Record the reason** — append a body note: `> Blocked {{today}} — <reason>` (runtime date). Ask for one line if `--reason` omitted.
5b. **Hybrid mode, linked task** (`github-issue:` or `jira-key:` set) → ensure the `blocked` label exists, as
   [export.md](export.md) step 6 does, then add the tracker's own marker: the label `blocked` on GitHub, the **Flagged** field on Jira. The issue's open/closed state is **never** changed because of it, since a blocked task is still open work, and a
   comment `Blocked: <reason>`. A failed remote call is reported by name and does not undo the local
   block, because the file is the record and the tracker mirrors it.
6. **Regenerate dashboard** ([triage](triage.md)) — blocked tasks render `⚠ blocked` and drop out of "Next up".
7. **Confirm** — print `status: … → blocked`, any `depends-on` added, the reason, and the remote outcome when step 5b ran.

## unblock — `/tasks unblock <ID>`

1. **Locate** the TASK file.
2. **Read current status** — if the task is not blocked by either form ([SKILL.md](../SKILL.md) § *Lifecycle*), warn ("not blocked — nothing to clear") and stop.
3. **Clear depends-on (optional)** — if `--clear-deps` is passed, drop now-satisfied (`done`) IDs from `depends-on`; otherwise leave `depends-on` as the historical record and only change status.
4. **Edit frontmatter** — remove the `blocked:` field and **leave `status:` alone**: the task goes back to the state it was in (FEATURE-003 D2). An old-form `status: blocked` has no state to return to, so read it from the file's history exactly as [init.md](init.md) step 3b does, and ask its question when history cannot tell. If the user says work resumes immediately, allow `→ in-progress` instead (or just run `/tasks pick <ID>` next).
5. **Append a body note** — `> Unblocked {{today}} — <reason / what resolved it>`.
5b. **Hybrid mode, linked task** → remove the `blocked` label (Jira: clear Flagged) and add a comment
   `Unblocked: <what resolved it>`. Never reopen or close the issue. A failed call is reported by name.
   **Hybrid mode, no link** → say `no remote issue linked — nothing synced`, so a local unblock is never
   mistaken for a synced one. The same line applies to `block`'s step 5b.
6. **Regenerate dashboard**.
7. **Confirm** — print `blocked: <reason> removed — status stays <state>` (or, for the old form, `status: blocked → <state> (from history | answered)`) and the note.

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
