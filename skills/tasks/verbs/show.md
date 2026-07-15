# /tasks show — view a task/story/epic without picking it

Read-only inspection. Does **not** change status, does **not** regenerate the dashboard, does **not** spawn agents. Use to peek at a task while deciding whether to pick it, or to glance at a sibling/parent during work.

## Args

- Bare ID (`/tasks show TASK-014`, `/tasks show EPIC-001`, `/tasks show STORY-003`) — required.
- `--tree` — for EPIC/STORY only: also print one-line summary of every descendant.

## Steps

1. **Find task root**.

2. **Resolve the ID** — grep for `^id: <ID>$` in the task root. Error if not found, printing the resolved task root so the user can verify they're in the right place.

3. **Read the file** in full.

4. **Render the view** by level:

   **TASK** — print:
   - Header: `TASK-NNN — <title>` and the parent chain (`EPIC-NNN <epic title> → STORY-NNN <story title>` or `[loose]`)
   - One-line metadata row: status · priority · assignee · created · `pr:` / `github-issue:` / `jira-key:` if set · `depends-on:` / `blocks:` if non-empty
   - `## Context`, `## Acceptance criteria`, `## Out of scope`, `## Implementation plan` (verbatim from the file)
   - If `## Implementation plan` is empty/placeholder → footer hint: "No plan yet — run `/tasks plan TASK-NNN`."

   **STORY** — print:
   - Header: `STORY-NNN — <title>` and parent (`EPIC-NNN <epic title>`)
   - Status, created, owner
   - The STORY body (`## Goal`, `## Out of scope`, whatever the template carries)
   - List of child TASKs: `TASK-NNN <title> (status, priority, assignee)`

   **EPIC** — print:
   - Header: `EPIC-NNN — <title>`
   - Status, created, owner, `affects:` list (if non-empty)
   - The EPIC body
   - List of child STORYs (one line each) and loose tasks directly under this epic
   - If `--tree` → also recurse into each STORY and print its TASKs indented under it

5. **Footer hint** — depending on level/status:
   - TASK `status: todo` → "Pick with `/tasks pick TASK-NNN`"
   - TASK `status: in-progress` → "Resume with `/tasks pick TASK-NNN`"
   - TASK `status: done` / `cancelled` → no action hint
   - STORY → "Add tasks with `/tasks new task`"
   - EPIC → "Add stories with `/tasks new story`"

## Edge cases

- **ID not found** — error with the resolved task root path.
- **Multiple matches** (shouldn't happen but defend) — list all paths, ask user to disambiguate.
- **Malformed file** (missing frontmatter or required sections) — print what you can, flag what's missing, don't error out.
- **`--tree` on a TASK** — ignored with a note ("TASKs have no descendants").
