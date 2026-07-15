# /tasks cancel — mark a task (or story/epic) cancelled

Set `status: cancelled` — work that will **not** be done. This is the task-tree mirror of a
`removed` decision in [[feature]]'s ledger: a cancelled item is a *recorded choice*, never a
deletion. The file stays for the audit trail.

> **Cancel vs. close vs. delete.** `close` = done (the work happened). `cancel` = won't happen
> (deliberately dropped). **Never delete a task file** — a vanished task is an untracked
> decision; `cancelled` keeps *why we're not doing it* legible, exactly like `removed` rows in
> `decisions.md`.

## Steps

1. **Find task root.**

2. **Parse args**:
   - `<ID>` — required. `TASK-001` or just `001` if unambiguous. Also accepts STORY/EPIC IDs.
   - `--reason "<text>"` — recommended. The why; captured in the body + History so the choice is auditable.

3. **Locate the file** — Grep `^id: (TASK|STORY|EPIC)-NNN$`. If not found, suggest `/tasks triage`.

4. **Read current status**:
   - Already `cancelled` → warn; nothing to do.
   - `done` → warn ("this is already done — cancel anyway?"); cancelling done work is unusual but allowed (e.g. shipped then pulled). Confirm before proceeding.
   - `in-progress` → confirm intent ("work is in progress on this — cancel it?").

5. **Edit frontmatter** — `status: … → status: cancelled`.

6. **Record the reason (don't lose the why)** — append to the body, under a trailing note:
   `> Cancelled {{today}} — <reason>` (use the conversation/runtime date; this skill has no clock of its own). If `--reason` wasn't given, ask for one line; accept "no reason" but prefer a real one.

7. **Feature back-link (if `feature: FEATURE-NNN` is set)** — cancelling a task that came from a
   feature decision means that decision is no longer being built as planned. **Don't silently
   diverge the two trees**: tell the user the owning decision in
   `docs/features/FEATURE-NNN/decisions.md` likely needs a matching change (e.g. `approved →
   removed`, or a `changed` delta) and suggest `/feature decide FEATURE-NNN`. Don't edit the
   feature ledger from here — that's [[feature]]'s job — just surface the link so it doesn't rot.
   (`/roadmap --check` will flag the drift if it's left.)

8. **Hybrid mode remote close** (check `mode: hybrid`):
   - `github-issue: <N>` → `gh issue close <N> --reason "not planned" --comment "Cancelled by {{ID}}: <reason>"`.
   - `jira-key: <KEY>` → transition to a closed/won't-do status via the Atlassian MCP (search the transition tool via ToolSearch; prompt if not authenticated). Don't reopen-loop if it's already closed.

9. **Roll status up to parents** (same rule as `close` — parents must not lie):
   - After cancelling, re-evaluate the parent STORY then its EPIC. If **every** child of a STORY is now `done`/`cancelled`, that STORY should not still read `in-progress` — reconcile it (a story with all children cancelled is itself `cancelled`; a mix of done+cancelled is `done`). Update the parent files, not just the leaf.
   - Cancelling a STORY/EPIC directly → confirm it has no work you mean to keep; its open children don't auto-cancel — list them and ask whether to cancel them too.

10. **Regenerate dashboard** ([triage](triage.md)). Cancelled items render struck-through and fold into the Completed section.

11. **Confirm** — print the file updated, `status: … → cancelled`, the reason recorded, any remote close result, and any feature-decision follow-up suggested.

## Edge cases

- **Cancelling a task other tasks `depend-on`** — warn: list the dependents; their `depends-on`
  now points at a cancelled task (a satisfied-by-cancellation, not by-completion). Suggest
  `/tasks audit` (broken-links/unblock check) to reconcile, or unblock them via `/tasks unblock`.
- **Reviving a cancelled task** — there's no "uncancel"; create afresh with `/tasks new` (and
  reference the cancelled ID in Context) so the revival is itself tracked, or `/tasks pick`
  after manually flipping it back if it was cancelled by mistake moments ago.
- **Cancelling the last open task of a feature** — combine step 7's decision-follow-up with a
  note that `/feature status` / `/feature review` should be re-run so the rollup reflects the drop.
