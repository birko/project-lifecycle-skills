# /tasks triage — regenerate the dashboard

Rebuild `tasks/README.md` from the current state of every file in `tasks/`.

This verb is also chained automatically by `new`, `pick`, `close`, `import`, `export`, and `migrate` after they touch files. When called directly, it just refreshes the dashboard and prints a one-line summary.

## Args

- `--across` — **refused here, and the refusal is the feature.** This verb writes `tasks/README.md`, a
  **per-repo generated file**; no repo owns a dashboard of seven, and rendering one repo's file from
  another's contents is exactly the drift the generated-file ownership rule prevents. Say so in one line
  and point at the bare `/tasks --across` snapshot, which renders the same view to stdout and writes
  nothing. Declared rather than ignored so a caller gets an answer instead of a dashboard that quietly
  covers one repo while claiming to cover the family.

## Steps

1. **Run the [Collection pass](../SKILL.md#collection-pass)** — gives you the file list, parsed frontmatter, status buckets, `inProgressTasks[]`, `byParent` map, and mode/provider info. Don't duplicate the enumeration here. **Always single-repo** — see § Args.

2. **Build the counts table** from the buckets — epics × statuses, stories × statuses, tasks × statuses. Use `—` for status/level pairs that don't apply (e.g. epics have no `todo` or `blocked`).

3. **Build "In progress now"** from `inProgressTasks[]`. One bullet per task:
   ```
   - [TASK-014](EPIC-001-auth/STORY-001-login/TASK-014-jwt.md) — JWT issuance on login (P1, ai)
   ```

3b. **Build "In review (awaiting sign-off)"** from `inReviewTasks[]`, same bullet shape. These are verification debt — the persisted dashboard must surface them, exactly like the stdout snapshot does. Omit the whole section when no task is in `review`.

4. **Build the tree view** — group tasks under their parent story under their parent epic (use the `byParent` map from the collection pass). Skip epics that are `done` or `cancelled` (those go in the Completed section). For each story, show `done/total` task counts.

   Example shape:
   ```
   - EPIC-001 Authentication — in-progress (5/8 tasks done)
     - STORY-001 Password login — in-progress (2/3 done)
       - [x] TASK-002 Password hashing
       - [ ] TASK-001 JWT issuance ← in-progress
       - [ ] TASK-003 Rate limit
     - STORY-002 OAuth login — planned (0/2)
   ```

   Markers:
   - Task status `done` → `[x]`
   - Task status `in-progress` → `[ ] ... ← in-progress`
   - Task status `review` → `[ ] ... 🔍 review` (code done, sign-off pending — verification debt)
   - Task status `blocked` → `[ ] ... ⚠ blocked`
   - Task status `cancelled` → render struck-through `~~TASK-NNN ...~~`
   - Otherwise → `[ ]`
   - **Feature link** — if a task has `feature: FEATURE-NNN`, append a trailing tag `· FEATURE-NNN` so devs can jump to its stakeholder context in `docs/features/`.

5. **Build the Loose section** if `_loose/` has any tasks:
   ```
   ## Loose tasks
   - [ ] TASK-007 Bump .NET 9 (P1, human)
   ```

6. **Build the Completed section** (collapsed via `<details><summary>...</summary>...</details>`). Include done/cancelled epics with their frozen task list. Stories that are done within an active epic stay in the tree but with `(done)` suffix.

7. **Render** [templates/README.md.tmpl](../templates/README.md.tmpl):
   - `{{PROJECT_NAME}}` — name of the directory containing `tasks/`
   - `{{TIMESTAMP}}` — current date/time, e.g. `2026-05-28 14:32`
   - counts placeholders — including `{{TK_REVIEW}}` (the `review` row is verification debt; never drop it from the table)
   - `{{TODO_BY_PRIORITY}}` — the `todo` breakdown, as `` `todo` by priority: 4× P1 · 17× P2 · 1× P3. ``
     **One term per priority actually present**, in order, never a fixed set (see the Collection pass note).
     **Suppress zeros** — a priority with no tasks is omitted, not shown as `0×`, matching the stdout snapshot.
     **Omit the whole line** when there are no `todo` tasks, rather than rendering an empty tail.
   - `{{INPROGRESS_LIST}}` (or "_None_" if empty)
   - `{{INREVIEW_SECTION}}` (entire section omitted if no `review` tasks)
   - `{{TREE_VIEW}}`
   - `{{LOOSE_SECTION}}` (entire section omitted if no loose tasks)
   - `{{COMPLETED_SECTION}}` (omitted if no completed epics)

8. **Write** the rendered output to `tasks/README.md` (overwrite existing).

8b. **Feature drift check** — if `docs/features/` exists, apply the divergence rules from [[roadmap]] (§ *Cross-tree pass (shared engine)*) to the just-collected tasks + features. Reuse those rules; don't reinvent them. If any divergence is found, prepend a callout to `tasks/README.md` directly under the title:
   `> ⚠ **Feature drift (<n>):** <FEATURE-NNN DV<x> short reason>, … — run \`/roadmap --check\`.`
   Skip silently when the trees agree.

9. **If invoked directly** (not chained), print one summary line: `Dashboard refreshed: <E> epics, <S> stories, <T> tasks (<N> in progress).` Append `; <n> feature divergence(s) — see /roadmap` when step 8b found any.

## When NOT to chain triage

Skip the dashboard refresh if a chained verb already succeeded but hit an error before file write (avoid stale state). The verb file owns deciding when to chain.
