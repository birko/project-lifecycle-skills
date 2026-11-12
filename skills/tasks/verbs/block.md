# /tasks block / unblock — mark a task blocked or clear it

Set or clear the `blocked:` field — work that *can't proceed* until something else happens. One file,
two directions: `/tasks block <ID>` and `/tasks unblock <ID>`.

> **Blocked is a flag, not a state.** A blocked task keeps the state its work is in — `todo`,
> `in-progress` or `verify` — and carries the reason beside it. It drops out of the snapshot's
> "Next up", but stays **on offer**, marked with its reason, in `/tasks pick` and [[fix-next]],
> so it is never forgotten; it cannot be started or finished until it is unblocked. Blocking is
> how you hold work without cancelling it.

## block — `/tasks block <ID>`

1. **Find task root**; locate the TASK file by ID (Grep `^id: TASK-NNN[[:space:]]*$`).
2. **Parse args**:
   - `<ID>` — required (tasks only — EPIC/STORY don't carry `blocked`).
   - `--reason "<text>"` — recommended (why it's blocked).
   - `--on <TASK-NNN[,TASK-NNN…]>` — optional: the task(s) this is waiting on. Adds them to `depends-on` (deduped) so the block is *structural*, not just a status flag.
3. **Read current status**:
   - `done`/`cancelled` → refuse ("can't block finished work").
   - Already blocked by either form → warn ("already blocked: <reason>") and stop, before step 3b asks anything.
   - `in-progress` → confirm: **"TASK-NNN is in progress. Block it? Its status stays `in-progress`."**
     **No answer, or nobody to ask:** block it, since the invocation itself asked for this, and say in step 7
     that nobody confirmed. The question exists to catch a mistyped id, and the confirmation line is what
     lets someone notice one afterwards.
     - **Exception: invoked by [`close`](close.md) step 6 for a deferred merge.** The user already
       chose to defer at 5c, so don't re-ask — apply the block with the reason
       (`merge deferred: <reason>; code complete on task/TASK-NNN`) and any `--on` dependency. This
       is the one path where `blocked` means *finished but not integrated* rather than *not
       proceeding*; the reason note is what tells a reader which it is, so never write it bare.
3b. **Settle the reason, before anything is written.** Steps 4 and 5 both write it, so it is fixed here.
   With `--reason` given and not empty, it is that text.
   **When `--reason` is omitted or empty:**
   - **With `--on`**, the reason is `waiting on <TASK-NNN>[, <TASK-NNN>…]`, and nothing is asked. The caller
     named what the task waits on, which is the reason. [spawn](spawn.md) blocks its origin this way.
   - **Without `--on`**, put this question:

     > **Why is TASK-NNN blocked? One line: it becomes the `blocked:` value and the body note.**

     **No answer, or nobody to ask:** block it anyway, with `blocked: reason unknown` and the note
     `> Blocked {{today}} — reason unknown; nobody gave one when it was blocked.` (step 5), and say so in step 7:
     `blocked: reason unknown added (no reason given, nobody chose one) — status stays <state>`. The
     invocation itself asked for the block, as in step 3. A block's reason is never empty (SKILL.md
     § *Writing a `blocked:` value*), so the fallback is written and marked as nobody's choice. Not
     blocking would replace the person's explicit act with the run's own decision. The `;` keeps every
     reader that cuts the note at its first `;` reading exactly `reason unknown`.
4. **Edit frontmatter**:
   - Add `blocked: <reason>`, the reason step 3b settled, written as [SKILL.md](../SKILL.md) § *Writing a `blocked:` value* says.
     **Where:** directly below the template's own `# blocked: <reason> — …` comment line when the file has one
     (it documents the field, as the `# status` comment above `status:` documents that one); otherwise directly
     after the `status:` line **and every indented `#` line continuing its comment** — never between them, which
     splits one comment in two. Then **leave `status:` as it is**, so the task keeps
     the state its work is in — blocked is a flag beside the state, never a state of its own.
   - If `--on` given, merge the IDs into `depends-on: [...]` (validate each exists; warn on a missing/cancelled target).
5. **Record the reason** — write a body note: `> Blocked {{today}} — <reason>` (runtime date), the reason step 3b
   settled, never in its YAML quotes — quoting belongs to the frontmatter value alone. **Where:** directly under the
   task's `# Heading` line, above any earlier `>` note there, with a blank line on each side. That keeps it outside
   every `##` section (a note after the last section reads as part of it, usually the plan), and puts the newest
   note first.
   **Keep that shape — other verbs read it:** [init.md](init.md) step 3b takes it as its first reason rung,
   matching `Blocked <date> —` through emphasis and in any case; [export.md](export.md) takes the reason from
   it when the `blocked:` field is missing; [[fix-next]] takes it for an old-form `status: blocked` task's
   reason. A changed wording here silently drops every later migration to a weaker rung and every such
   export or skip line to `reason unknown`.
5b. **Hybrid mode, linked task** (`github-issue:` or `jira-key:` set) → ensure the `blocked` label exists, as
   [export.md](export.md) step 6 does, then add the tracker's own marker: the label `blocked` on GitHub, the **Flagged** field on Jira. The issue's open/closed state is **never** changed because of it, since a blocked task is still open work, and a
   comment `Blocked: <reason>`. **Keep the `Blocked:` prefix:** [import.md](import.md) reads the reason back
   from the newest comment starting with it. A failed remote call is reported by name and does not undo the
   local block, because the file is the record and the tracker mirrors it.
6. **Regenerate dashboard** ([triage](triage.md)) — blocked tasks render `⚠ blocked` and drop out of "Next up".
7. **Confirm** — print `blocked: <reason> added — status stays <state>`, any `depends-on` added, and the remote outcome when step 5b ran.

## unblock — `/tasks unblock <ID>`

1. **Locate** the TASK file.
2. **Read current status** — if the task is not blocked by either form ([SKILL.md](../SKILL.md) § *Lifecycle*), warn ("not blocked — nothing to clear") and stop.
3. **Clear depends-on (optional)** — if `--clear-deps` is passed, drop now-satisfied (`done`) IDs from `depends-on`; otherwise leave `depends-on` as the historical record and only change status.
4. **Edit frontmatter** — remove the `blocked:` field and **leave `status:` alone**: the task goes back to the state it was in — the flag never replaced it, so there is nothing to restore. An old-form `status: blocked` has no state to return to, so read it from the file's history exactly as [init.md](init.md) step 3b does, and ask its question when history cannot tell — but **never take init's no-answer fallback here**, which writes a `blocked:` field: an unblock must end unblocked. **No answer, or nobody to ask:** write `status: todo` with no `blocked:` field, add the note `> Unblocked {{today}} — state before blocking unknown; set to todo, nobody chose it.`, and print the fallback form in step 7. If the user says work resumes immediately, allow `→ in-progress` instead (or just run `/tasks pick <ID>` next).
5. **Write a body note** — `> Unblocked {{today}} — <reason / what resolved it>`, placed as `block`'s step 5 places its note.
   **Keep that shape** too: [init.md](init.md) step 3b reads it to tell that an earlier `Blocked` note is
   over, so a reworded note would make every resolved block read as current again.
5b. **Hybrid mode, linked task** → remove the `blocked` label (Jira: clear Flagged) and add a comment
   `Unblocked: <what resolved it>`. Never reopen or close the issue. A failed call is reported by name.
   **Hybrid mode, no link** → say `no remote issue linked — nothing synced`, so a local unblock is never
   mistaken for a synced one. The same line applies to `block`'s step 5b.
6. **Regenerate dashboard**.
7. **Confirm** — print `blocked: <reason> removed — status stays <state>` (or, for the old form, `status: blocked → <state> (from history | answered | fallback, unchosen)`) and the note.

## Edge cases

- **Auto-unblock suggestion** — `/tasks close`/`cancel` doesn't auto-unblock dependents (status
  changes stay explicit), but `/tasks audit` reports a satisfied dependency (one that is `done` or
  `cancelled`, since a cancelled task will never finish and so is nothing to wait on) and names a blocked
  task carrying one as an unblock candidate. Its `--fix` only prunes `depends-on`; it never removes the
  `blocked:` field. So the loop is: close or cancel the blocker → `audit` surfaces it → `/tasks unblock`.
- **Block with no `--on`** — fine; not every block is a task dependency (waiting on a stakeholder,
  an external service, a decision). The reason note carries the why; `depends-on` stays empty.
- **Blocking on a cancelled task** — warn: the blocker will never complete, so this is really a
  cancel or a re-scope, not a block. Confirm intent.
- **A whole STORY/EPIC is stuck** — there's no `blocked` status for containers; block the
  individual tasks, or note it in the EPIC body. Don't invent a container-level blocked state.
