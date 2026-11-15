# /tasks triage — regenerate the dashboard

Rebuild `tasks/README.md` from the current state of every file in `tasks/`.

This verb is also chained automatically by every verb that changes the tree: a task's status, its placement, or the set of task files. Each such verb's own steps say where it chains this one, so no list of them is kept here to go stale ([[feature]] `review` and `decide`, outside this skill, chain it too). When called directly, it just refreshes the dashboard and prints a one-line summary.

**Never inside a task's linked worktree** (`git rev-parse --path-format=absolute --git-dir` differs from the same command's `--git-common-dir`, both absolute, as [pick.md](pick.md) step 6b explains),
whichever verb chained it — `spawn` and `block` run there mid-task. Skip it and say so in one line. Every
task branch committing its own copy of this timestamped file is a merge conflict per parallel task; the
dashboard is regenerated on the default branch when `close` merges.

## Args

- `--across` — **refused here, and the refusal is the feature.** This verb writes `tasks/README.md`, a
  **per-repo generated file**; no repo owns a dashboard of seven, and rendering one repo's file from
  another's contents is exactly the drift the generated-file ownership rule prevents. Say so in one line
  and point at the bare `/tasks --across` snapshot, which renders the same view to stdout and writes
  nothing. Declared rather than ignored so a caller gets an answer instead of a dashboard that quietly
  covers one repo while claiming to cover the family.

## Steps

1. **Run the [Collection pass](../SKILL.md#collection-pass)** — gives you the file list, parsed frontmatter, status buckets, `inProgressTasks[]`, `byParent` map, and mode/provider info. Don't duplicate the enumeration here. **Always single-repo** — see § Args.

2. **Build the counts table** from the buckets (the `blocked` row counts blocked tasks across states, as the Collection pass buckets them) — epics × statuses, stories × statuses, tasks × statuses. Use `—` for status/level pairs that don't apply (e.g. epics have no `todo` or `blocked`), and `0` for a pair that applies and has no items, never a blank. **The `blocked` cell carries its overlap note inside the cell, after the count**, since the template has no other slot for it: `1 (1 also counted in its own state)`, `3 (2 also counted in their own state)`, with `its` for one task and `their` for more. A count with no overlap is the bare number.

3. **Build "In progress now"** from `inProgressTasks[]`. One bullet per task; a blocked one ends with `⚠ blocked: <reason>`, so stalled work does not read as active, and a taken one ([SKILL.md](../SKILL.md) § *Collection pass*) ends with `taken: <branch>`, because its file still reads `todo`:
   ```
   - [TASK-014](EPIC-001-auth/STORY-001-login/TASK-014-jwt.md) — JWT issuance on login (P1, ai)
   ```

3b. **Build "Awaiting verification"** from `inReviewTasks[]`, under the heading `## Awaiting verification`, same bullet shape, a blocked one ending `⚠ blocked: <reason>` as in step 3. These are verification debt — the persisted dashboard must surface them, exactly like the stdout snapshot does. Omit the whole section when no task awaits verification (`verify`, or the older `review`).

4. **Build the tree view** — group tasks under their parent story under their parent epic (use the `byParent` map from the collection pass). Skip epics that are `done` or `cancelled` (those go in the Completed section). For each story, show `done/total` task counts.

   **Three things the tree fixes, so two runs over one tree print the same file:**
   - **Order.** Epics by id, and each epic's stories by id. The tasks under a story, and under the epic-level line
     below, follow [SKILL.md](../SKILL.md) § *Collection pass*'s task order, the one every list of tasks uses.
   - **Tasks parented straight to an epic** go under one line, `(epic level) — <d>/<t> done`, after that epic's
     stories, at a story's indent. An epic with no such task has no such line. Every child of an epic line is then
     a story-shaped line, so a reader never has to tell a story's tasks from the epic's by indent alone.
   - **One story-line form for every state:** `STORY-NNN <title> — <state> (<d>/<t> done)`, where `<state>` is the
     story's status, `todo` printed as `planned`. A done story reads `— done (3/3 done)`; that is step 6's `(done)`.
     **`<d>/<t>` leaves cancelled tasks out of both numbers**, and the epic line's count takes the same rule: a
     cancelled task stays in the tree, struck through, but a story whose other tasks are all done reads `n/n`, not
     `5/8`, which would look unfinished.

   Example shape:
   ```
   - EPIC-001 Authentication — in-progress (5/8 tasks done)
     - STORY-001 Password login — in-progress (2/3 done)
       - [ ] TASK-001 JWT issuance ← in-progress
       - [x] TASK-002 Password hashing
       - [ ] TASK-003 Rate limit
     - STORY-002 OAuth login — planned (0/2 done)
     - STORY-004 Session expiry — done (2/2 done)
     - (epic level) — 1/1 done
       - [x] TASK-009 Audit the login copy
   ```

   **A tree row carries the id, the title and the markers below, nothing else.** Priority and assignee are printed
   in "In progress now", "Awaiting verification" and the Loose section, where each task is listed with `(P1, agent)`.
   The tree is a structure view, and repeating them there doubles every row's width for no new fact.

   Markers:
   - Task status `done` → `[x]`
   - Task status `in-progress` → `[ ] ... ← in-progress`
   - Task taken (its file reads `todo`, its branch exists) → `[ ] ... ← in-progress, taken: <branch>`
   - Task status `verify` or `review` → `[ ] ... 🔍 verify` (code done, sign-off pending — verification debt)
   - Task blocked by either form ([SKILL.md](../SKILL.md) § *Lifecycle*) → `[ ] ... ⚠ blocked: <reason>` after
     its own state's marker; an old-form `status: blocked` has no other state to show, so it renders
     `[ ] ... ⚠ blocked`
   - Task status `cancelled` → render struck-through, with no checkbox: `- ~~TASK-NNN ...~~`. Anything that follows
     the title, such as the feature tag below, goes after the closing `~~`
   - Otherwise → `[ ]`
   - **Feature link** — if a task has `feature: FEATURE-NNN`, append a trailing tag `· FEATURE-NNN` so devs can jump to its stakeholder context in `docs/features/`.

4b. **Check every parent against its children.** A container's status is derived from its children ([SKILL.md](../SKILL.md)
   § *Roll status up to parents*), so one that disagrees with them is reported. This step **reports and names the
   verb; it never changes a status**, because a status changes only through its verb, and `close` alone carries the
   gates a container close needs. So it asks nothing. Four cases, over every epic and story, Completed ones included.
   A story's children are its tasks; an epic's are its stories and any task parented to it directly, each read by its
   own status:

   | The parent | Its children | Line | Fix (the callout prints everything before the ` — `, whole: for the first row, `` `/tasks close <ID>`, or keep it open ``) |
   |---|---|---|---|
   | reads `planned` or `in-progress` | at least one, and every one `done` or `cancelled` | `<ID> <status>, every child closed` | `/tasks close <ID>`, or keep it open — `close` step 11 lets an area of concern stay open on purpose |
   | reads `planned` | at least one `in-progress`, `verify` or `done` | `<ID> planned, <n> of <t> children started` | `/tasks pick` of one of its open tasks — starting a task moves its `planned` parents to `in-progress` |
   | reads `done` or `cancelled` | at least one open | `<ID> <status>, open child <child id>` | file it with `/tasks new` — a verb skipped the reopen § *Roll status up to parents* requires |
   | an epic whose body names a `STORY-NNN` | that story has no file | `<ID> names <STORY-NNN>, which does not exist` | edit the epic body — it is hand-owned |

   Write them as one callout directly under `## Tree`, above the tree, ordered by id:
   `> Parents out of step (<n>): <line> → <fix>; <line> → <fix>.` Omit it, and its blank line, when there are none.
   A container with no children is not a case, and child counts leave cancelled tasks out, as step 4's do.

5. **Build the Loose section** if `_loose/` has any tasks. It lists **every** loose task, closed ones included, in
   [SKILL.md](../SKILL.md) § *Collection pass*'s task order, with step 4's markers and `(priority, assignee)`. A loose
   task has no epic whose Completed entry could hold it, so hiding a closed one would drop it from the file entirely:
   ```
   ## Loose tasks
   - [ ] TASK-007 Bump .NET 9 (P1, human)
   ```

6. **Build the Completed section**: no heading of its own, one `<details>` block whose summary is
   `<summary>Completed (<n> epics)</summary>`, holding the done and cancelled epics in step 4's tree form, each with
   its stories and their tasks. Stories that are done within an active epic stay in the tree **with their tasks**;
   only their line changes, to step 4's story-line form (`— done (<n>/<n> done)`).

7. **Render** [templates/README.md.tmpl](../templates/README.md.tmpl):
   - `{{PROJECT_NAME}}` — name of the directory containing `tasks/`, even where a README or guide titles the project
     differently. The folder name is the one every run derives the same way. A title read from a file can be
     missing, or change wording, and the dashboard's heading would then move with it.
   - `{{TIMESTAMP}}` — current date/time in the machine's **local time, with no zone or offset**, e.g. `2026-05-28 14:32`.
     It records when the file was written for a person reading it, and nothing compares it, so a zone would add
     width and no information.
   - **Counts-table cells:** fill each placeholder in place and pad the cell to the template's column width, so
     unchanged rows keep their alignment and a diff shows only the cells that moved. A value longer than its column
     runs past it, and no other row is realigned. Markdown renders the table the same either way. (The stdout
     snapshot never pads, [SKILL.md](../SKILL.md) § *Status snapshot*: that is a plain-text view, and this is a file
     people diff.)
   - counts placeholders — including `{{TK_REVIEW}}`, which fills the `verify` row from the Collection pass's `review` bucket (that row is verification debt; never drop it from the table)
   - `{{TODO_BY_PRIORITY}}` — the `todo` breakdown, as `` `todo` by priority: 4× P1 · 17× P2 · 1× P3. ``
     **One term per priority actually present**, in order, never a fixed set (see the Collection pass note).
     **Suppress zeros** — a priority with no tasks is omitted, not shown as `0×`, matching the stdout snapshot.
     **Omit the whole line** when there are no `todo` tasks, rather than rendering an empty tail.
   - `{{INPROGRESS_LIST}}` (or "_None_" if empty)
   - `{{INREVIEW_SECTION}}` (entire section omitted if no `verify` tasks, old-form `review` included)
   - `{{TREE_VIEW}}` (`_None_` when there are no epics, stories or tasks: the same form "In progress now" uses; step 4b's callout, when there is one, comes first)
   - `{{LOOSE_SECTION}}` (entire section omitted if no loose tasks)
   - `{{COMPLETED_SECTION}}` (omitted if no completed epics)

   **An omitted section takes the blank line before it with it.** Sections stay separated by exactly one blank line,
   the file never carries two blank lines in a row where a section was left out, and it ends with a single newline.
8. **Write** the rendered output to `tasks/README.md` (overwrite existing).

8b. **Feature drift check** — if `docs/features/` exists, apply the divergence rules from [[roadmap]] (§ *Cross-tree pass (shared engine)*) to the just-collected tasks + features. Reuse those rules; don't reinvent them. If any divergence is found, prepend a callout to `tasks/README.md` directly under the title, **above the template's
   `_Generated …_` line**, with one blank line on each side (the quiet `Feature drift: none open` line below takes the
   same place):
   `> ⚠ **Feature drift (<n>):** <target> DV<x> short reason, … — run \`/roadmap --check\`.`
   Each `<target>` is the finding's target as [[roadmap]]'s compact slice prints it (a feature, story, epic or task id,
   `specs/<area>`, or `specs/.map.yml`), so a finding whose target is not a feature is never dropped.
   **An accepted finding is not in the callout** ([[roadmap]] § *Accepted divergences*). When every finding is
   accepted, write one quiet line in its place instead, so the file shows the check ran:
   `> Feature drift: none open · <a> accepted (<target> DV<x>, …) — see \`/roadmap --check\`.`
   Skip silently only when the trees agree and nothing is accepted.

9. **If invoked directly** (not chained), print one summary line: `Dashboard refreshed: <E> epics, <S> stories, <T> tasks (<N> in progress)<suffixes>.`, each suffix
   below going before the closing period. Append `; <n> feature divergences — see /roadmap` when step 8b found an **open** one; an accepted finding is not counted here, since the file's quiet line already shows it. Append `; <n> parents out of step` when step 4b found any. Every count noun takes the singular for a count of exactly 1 (`1 epic`, `1 story`, `1 feature divergence`), the rule the `/tasks` snapshot uses. DV10's *could not decide* ([[roadmap]] § *DV10: what counts as code*) is not a finding, so it is in neither the callout nor this line.

## When NOT to chain triage

Skip the dashboard refresh if a chained verb already succeeded but hit an error before file write (avoid stale state). The verb file owns deciding when to chain.
