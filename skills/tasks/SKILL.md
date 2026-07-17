---
name: tasks
description: Hierarchical task tracking with Epics → Stories → Tasks as markdown files in a project-local `tasks/` folder. Use when user says "/tasks new", "/tasks triage", "/tasks pick", "/tasks close", "/tasks import", "/tasks export", "/tasks migrate", "new task", "new epic", "new story", "novy task", "novy epic", "novy story", "task dashboard", "pick a task", "what's next", "what's in todo", "what's planned", "import todo", "import roadmap", "export to github", "migrate tasks to github", "migrate to jira", or any task-management slash command. The bare-`/tasks` status snapshot is feature-aware — it cross-checks `docs/features/` and flags drift via the [[roadmap]] engine, so "what's next/planned" answers span both trees (use [[roadmap]] for the full hierarchical view). Supports local mode (files only) and hybrid mode (files + GitHub Issues / Jira sync via gh CLI / Atlassian MCP).
---

# tasks

Hierarchical task tracking: **Epics** → **Stories** → **Tasks** as markdown files under a project-local `tasks/` folder. Every TASK file is self-contained with Context / Acceptance / Out-of-scope so a human or AI agent can pick it without re-discovery.

## Verbs (router)

User invokes as `/tasks <verb> [args]`. Read **only** the verb file matching the request — don't preload all of them.

| Verb | What it does | File |
|---|---|---|
| `init` | Bootstrap `tasks/` — write `.config.yml` (mode passable as arg) + initial dashboard; chained by [[new-project]] | [verbs/init.md](verbs/init.md) |
| `new` | Create EPIC, STORY, or TASK (auto-runs `plan` for TASK) | [verbs/new.md](verbs/new.md) |
| `triage` | Regenerate `tasks/README.md` dashboard | [verbs/triage.md](verbs/triage.md) |
| `audit` | Scan the backlog for duplicates, mergeable/splittable, stale, broken-link, and incomplete tasks (suggest-only; `--fix` to apply safe ones) | [verbs/audit.md](verbs/audit.md) |
| `show` | Read-only view of an EPIC/STORY/TASK by ID | [verbs/show.md](verbs/show.md) |
| `plan` | Draft `## Implementation plan` for a TASK (optional grill) | [verbs/plan.md](verbs/plan.md) |
| `pick` | Pick task, mark in-progress, start work | [verbs/pick.md](verbs/pick.md) |
| `close` | Merge gate — task → `done`, or `review` if sign-off pending (+ close remote in hybrid) | [verbs/close.md](verbs/close.md) |
| `cancel` | Mark task/story/epic cancelled (won't-do; never deletes — mirrors a `removed` decision) | [verbs/cancel.md](verbs/cancel.md) |
| `block` / `unblock` | Hold a task out of the ready pool (or release it); optionally wires `depends-on` | [verbs/block.md](verbs/block.md) |
| `import` | Import from file / GH issue / Jira ticket | [verbs/import.md](verbs/import.md) |
| `export` | Push local task to GH/Jira (hybrid only) | [verbs/export.md](verbs/export.md) |
| `migrate` | Bulk export + switch to hybrid mode | [verbs/migrate.md](verbs/migrate.md) |
| `help` | Print the verb table | [verbs/help.md](verbs/help.md) |

If user types `/tasks` with no verb → render the **status snapshot** (see below).
If user types `/tasks help` → print the verb table above and exit.

## Status snapshot (bare `/tasks`)

Compact terminal view — counts, what's active, what's next. Renders to stdout only; does not touch `tasks/README.md` (that's `triage`'s job).

1. Run the [Collection pass](#collection-pass) to enumerate everything and bucket by status.
2. Render:
   ```
   tasks/  (<mode>[: <provider details>])

   <E> epics · <S> stories · <T> tasks
     ├─ todo:        <n>   (<p0>× P0, <p1>× P1, <p2>× P2)
     ├─ in-progress: <n>
     ├─ review:      <n>
     ├─ blocked:     <n>
     └─ done:        <n>

   In progress: <list or "(none)">
   In review:   <list or "(none)">

   Next up (top 3 by priority, blocked excluded):
     TASK-NNN  <title>  <priority>  <assignee>
     ...
   ```
3. Append the `features/` slice — its shape and divergence rules are owned by [[roadmap]] (§ *Render — compact slice*); render that slice, don't re-derive the join here. In-review tasks are verification debt — surface them, don't bury them. Omit the `review:` line and "In review" section when no task is in review; omit the whole `features/` block when `docs/features/` doesn't exist. Suppress trailing zeros in the priority breakdown.

## Collection pass

Shared by `triage` and the bare-`/tasks` status snapshot. Single-pass enumerate + read + bucket — keep it cache-friendly.

1. **Find task root** via shape detection.
2. **Glob** in one pass:
   - `tasks/EPIC-*/EPIC.md`
   - `tasks/EPIC-*/STORY-*/STORY.md`
   - `tasks/EPIC-*/STORY-*/TASK-*.md`
   - `tasks/EPIC-*/TASK-*.md`
   - `tasks/_loose/TASK-*.md`
3. **Read each file's frontmatter** (Read the whole file; parse the YAML head between `---` fences). Capture: `id`, `parent`, `feature` (tasks, optional — links to a `docs/features/FEATURE-NNN/`), `status`, `priority` (tasks), `assignee` (tasks), `affects` (epics, optional), `created`, `depends-on`, `blocks`. Read the first `# Heading` line of the body for the human title.
4. **Bucket** by level + status:
   - Counts: `{epics: {planned, in-progress, done, cancelled}, stories: {...}, tasks: {todo, in-progress, review, blocked, done, cancelled}}`
   - Priority sub-breakdown for `tasks.todo`: `{P0, P1, P2}`
5. **Build indexes** other steps need:
   - `inProgressTasks[]` — TASKs with `status: in-progress`, sorted by priority then created
   - `inReviewTasks[]` — TASKs with `status: review` (code done, awaiting sign-off)
   - `nextUpTasks[]` — TASKs with `status: todo` (NOT blocked), sorted P0→P1→P2 then created asc
   - `byParent` map — for building tree views
6. **Read `.config.yml`** if present, expose `mode` + provider details so the snapshot header can render `(local)` / `(hybrid: github owner/name)` / `(hybrid: jira PROJ)`.

Performance: at hundreds of files, batch the Reads. Don't grep frontmatter line-by-line in separate calls.

## File layout

```
tasks/
  README.md                              ← auto-generated dashboard (owned by triage — never hand-edit; re-run it)
  .config.yml                            ← mode + provider settings
  EPIC-NNN-slug/
    EPIC.md
    STORY-NNN-slug/
      STORY.md
      TASK-NNN-slug.md
  _loose/                                ← orphan tasks (no parent epic)
    TASK-NNN-slug.md
```

See [templates/](templates/) for exact file shapes. Every TASK must have `## Context`, `## Acceptance criteria` (checklist), `## Out of scope`.

## Shape detection — where `tasks/` lives

Walk up from cwd in this order:

1. Directory containing `tasks/.config.yml` → use as task root. **Done.**
2. Otherwise find project root: `*.slnx`/`*.sln` first, then `.git`.
3. Task root is `<project-root>/tasks/`.
4. Ambiguous → ask the user once and write `.config.yml` so the choice sticks.

A project's own `CLAUDE.md` may override placement — e.g. an aggregator repo that hosts
**cross-cutting epics for a polyrepo family** documents that rule locally (its epics list the
affected sub-projects in `affects:` frontmatter); each sub-repo's own work stays in its own
`tasks/` via the default walk-up. The auto-loaded project guide wins over this default.

## Mode (local | hybrid)

Configured in `tasks/.config.yml` (see [templates/config.yml](templates/config.yml)).

`/tasks init` creates it explicitly (a caller like [[new-project]] passes the mode as an arg so nothing is re-asked). If `.config.yml` is missing when any other verb runs first, fall back to the same flow: ask the user, suggesting based on signals:
- `.github/ISSUE_TEMPLATE/` present → `hybrid` (github)
- CLAUDE.md / README mentions a `*.atlassian.net` or other Jira-shaped URL → `hybrid` (jira)
- Neither → `local`

External mode (API-only, no local files) is **deferred to v2** — don't offer it.

## ID generation

Global counters per type — `EPIC-001`, `STORY-001`, `TASK-001` are each unique project-wide.

To find next ID, Grep across `tasks/` with pattern `^id: (EPIC|STORY|TASK)-(\d+)$`, take max per type, increment, zero-pad to 3 digits.

## Lifecycle

**Status vocabularies (normative):** TASKs use `todo` · `in-progress` · `review` · `blocked` · `done` · `cancelled`; STORYs and EPICs use `planned` · `in-progress` · `done` · `cancelled` (containers have no `todo`/`review`/`blocked` — those are leaf-task states).
Every status has a verb that sets it — none requires hand-editing frontmatter: `new`→`todo`,
`pick`→`in-progress`, `close`→`review`/`done`, `block`/`unblock`→`blocked`↔`todo`,
`cancel`→`cancelled`. (`cancel` and `block` mirror the [[feature]] ledger's `removed`/`deferred`
states — a deliberate, recorded non-completion, never a deletion.)

**Integration model — the task is the unit of work, the PR, *and* the merge gate.** For
git/PR projects the default is **PR-per-task**: `pick` cuts `task/TASK-NNN` from the default
branch, and `close` is the **merge gate** — it runs the convention + correctness checks
([[verify-conventions]] + [[code-review]] on the working tree, [[review]] on the PR diff),
merges, and only then flips to `done`. So **`done` means *merged*** — a single precise state,
not "reviewed somewhere." Code is reviewed **once per task, here, at the right altitude**;
[[feature]]'s `review` gate is then a *completeness* check, not a wholesale code re-review.
(Non-git or local-only projects keep `close`'s flexible commit/reference step — see
[verbs/close.md](verbs/close.md); a tightly-coupled cluster *may* share a feature branch and
defer the single merge to `/feature review`. PR-per-task is the default.)

**Create the task before implementing.** For non-trivial work, write the TASK
(`status: todo`) with its acceptance criteria *first*, then implement, then tick boxes /
advance status as criteria are genuinely met. Don't author a task after the code is done
and drop it straight into `review` with pre-checked boxes — that turns the acceptance list
into a transcript of what you already did instead of an independent target to verify
against, and skips the `todo → in-progress → review` lifecycle entirely. Small
conversational fixes can skip the per-change task and track at the parent EPIC level.

**`review` = code complete, awaiting human/visual sign-off — NOT done.** When a task's
code is finished and its automated tests pass but it has a `## Human test plan` with a
real (non-`N/A`) manual/visual step that hasn't been run yet, set `status: review`, not
`done`. This is the task-level mirror of the [[feature]] skill's `review` phase and its
hard rule: **never mark something `done` with the sign-off still pending, and never write
the hybrid "done (pending)".** A `review` task is *verification debt* — the snapshot lists
it under "In review" and it should be closed (run the test → `done`) before new scope.
- A task whose `## Human test plan` is genuinely `N/A — covered by automated tests` skips
  `review` and goes straight to `done` when the code + tests land (nothing for a human to verify).
- `review` → `done` only after the human step is checked off (the `close` verb enforces this).
- **A change landing on a closed feature reopens the implementing task.** This is the
  *down-the-tree* counterpart to the roll-up rule below: when a post-sign-off change
  with a human-verifiable surface lands on a `done` feature (the [[feature]] skill's
  surface-dependent-revert rule), the TASK(s) that implement the changed surface go
  `done → review` and their `## Human test plan` is re-run before re-closing. A
  tests-only change (nothing for a human to check) stays `done`. Don't reopen a task
  without also recording the matching `changed` decision in its feature's ledger —
  the two move together.

**Field feedback re-enters as tracked work — the pipeline is a loop, not a line.** A signal
from the field (a user report, an incident, a monitoring alert) gets the same right to
re-enter as a test-found bug does. Triage it into the right lane: a **regression** in shipped
behavior → a `task` (`_loose` or under its epic); a **missing capability** the field exposed →
a [[feature]] (it has open questions again); evidence that a `deferred`/`removed` **decision**
was wrong → reopen it via `/feature decide`. Two standing rules:
- **A fix for shipped behavior isn't `done` until it carries a regression test** — the same
  "quarantine becomes a permanent spec" discipline [[populate-tests]] applies to test-found
  bugs, applied to field-found ones, so the defect can't recur.
- Route a field-found bug through the normal `todo → in-progress → review/done` lifecycle; don't
  hot-patch and backfill the task — the acceptance list must stay an independent target.

**No archiving.** Status-only. Epics and stories are often open-ended areas of concern that gain new work over time; only TASKs are atomic completable units. The dashboard hides done items by default and shows them in a collapsed "Completed" section.

**Roll status up to parents — don't leave them stale.** A child changing status is not done until its parents reflect reality:
- `close` (and any status change): after updating a TASK, re-evaluate its parent STORY, then that STORY's EPIC. A STORY whose every TASK is done should not still read `in-progress`; an EPIC's body/status and any requirement→feature table it carries must match its children. Update the parent files, not just the leaf + the dashboard. (Real failure this guards: leaves and the dashboard were kept current but `EPIC.md` sat at `in-progress` with a stale prose story list and an obsolete roadmap line.)
- `triage` / `audit`: flag any parent whose status contradicts its children (e.g. all-children-done under an `in-progress` story, or a story listed in an EPIC body that no longer exists), and offer to reconcile.

## Conventions

- **No `Co-Authored-By:` trailers** in any commit messages this skill produces — including the optional progress commit offered by `/tasks close` step 6.
- Use `gh` CLI for GitHub (cross-platform, already authenticated on user's machine).
- For Jira, use the Atlassian MCP (`mcp__claude_ai_Atlassian__*` — search via ToolSearch before calling), or hand off to a `jira-task` skill, if one is installed, for the full ticket workflow.
- PowerShell-compatible (no `2>/dev/null`, no inline `VAR=x cmd`).
- **Parent files are part of "done".** Closing a task without rolling its STORY/EPIC status forward leaves the tree lying about itself — treat the parent rollup as a required step, not optional cleanup.

## Related skills

- [[feature]] — Per-feature lifecycle (prototype → decisions → decompose → stakeholder docs → review). It calls `/tasks new --from-feature FEATURE-NNN` to decompose approved decisions into tasks, and `/tasks close` / `/feature review` enforce the per-task `## Human test plan`. Tasks born from a feature carry `feature: FEATURE-NNN` frontmatter.
- [[roadmap]] — Unified cross-tree view + drift audit. The bare-`/tasks` snapshot delegates to its Cross-tree pass for the compact `features/ …` slice; `/roadmap` renders the full epic→feature→task tree. The divergence rules live there, not duplicated here.
- [[new-project]] — Generic project scaffolder; creates the `tasks/` folder (this skill) and `docs/features/` (the [[feature]] skill) at project birth, and seeds CLAUDE.md with the lifecycle convention.
- `jira-task` — Jira ticket end-to-end workflow (optional, environment-specific — not part of this skill set). `/tasks pick` on a task with `jira-key:` set hands off here when installed.
- [[verify-conventions]] — adherence lint against `CLAUDE.md § Conventions`; `/tasks close` runs it (with [[code-review]]) before flipping a non-trivial task to `done`.
- [[code-review]] — correctness review; the complement to `verify-conventions` at the close gate. Runtime-provided (a Claude Code built-in); `close` carries an inline fallback for runtimes without it.
- [[review]] — reviews the **PR diff** at the `/tasks close` merge gate (the PR-per-task default). Runtime-provided, same fallback rule.
- [[populate-tests]] — turns each task/surface into standing coverage; a field-found bug routes back as a task that ships with a regression spec (the loop).
- [[specs]] — harvested capability specs (`docs/specs/`). `close` on a STORY offers a scoped `/specs regen --story` so the spec diff confirms the story's behavioral change was intended; the snapshot's `specs: N stale` line comes from [[roadmap]]'s slice of its `verify`.
- [[handoff]] — Same agent-pickable-context principle applied at a different scope.
