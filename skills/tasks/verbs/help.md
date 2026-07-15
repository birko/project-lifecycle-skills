# /tasks help — print the verb table

Print the verb table from [SKILL.md](../SKILL.md) and exit. No file I/O, no collection pass — instant.

This is the explicit-help verb. Bare `/tasks` (no arg) renders the [status snapshot](../SKILL.md#status-snapshot-bare-tasks) instead, which is more useful day-to-day; users who want the menu type `/tasks help`.

## Steps

1. Print the verb table (the one in `SKILL.md` under `## Verbs (router)`).
2. Print a one-line hint: "Bare `/tasks` shows the status snapshot."
3. Exit.
