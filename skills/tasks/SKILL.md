---
name: tasks
description: Hierarchical task tracking with Epics → Stories → Tasks as markdown files in a project-local `tasks/` folder. Use when user says "/tasks new", "/tasks pick", "/tasks plan", "/tasks spawn", "/tasks close", "new task / epic / story", "novy task / epic / story", "task dashboard", "pick a task", "what's next", "what's planned", "that should be its own task", "import todo", "export to github", "migrate to jira", or any task-management slash command. `/tasks pick` offers to draft the implementation plan before work starts; `/tasks spawn` turns work discovered mid-flight into its own correctly-placed task instead of widening the one in hand. The bare-`/tasks` snapshot is feature-aware — it cross-checks `docs/features/` and flags drift via the [[roadmap]] engine, so "what's next/planned" spans both trees. Supports local mode (files only) and hybrid mode (files + GitHub Issues / Jira sync via gh CLI / Atlassian MCP).
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
| `pick` | Pick task, offer to plan it first, mark in-progress, start work | [verbs/pick.md](verbs/pick.md) |
| `spawn` | Work discovered mid-flight → its own task, placed under the right parent, wired into the origin's plan, reconciled with the feature ledger | [verbs/spawn.md](verbs/spawn.md) |
| `intake` | A review/audit/spec-harvest **pass** → a drainable backlog: one EPIC (`kind: review-intake`), STORYs by severity theme, one TASK per fix group | [verbs/intake.md](verbs/intake.md) |
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
3. **Read each file's frontmatter** (Read the whole file; parse the YAML head between `---` fences). Capture: `id`, `parent`, `feature` (tasks, optional — links to a `docs/features/FEATURE-NNN/`), `status`, `priority` (tasks), `assignee` (tasks), `findings` (tasks, optional), `affects` (epics, optional), `kind` (epics, optional), `created`, `depends-on`, `blocks`. Read the first `# Heading` line of the body for the human title.
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
`pick`→`in-progress`, `close`→`review`/`done`/`blocked` (the last when its merge is deferred),
`block`/`unblock`→`blocked`↔`todo`,
`cancel`→`cancelled`. (`cancel` and `block` mirror the [[feature]] ledger's `removed`/`deferred`
states — a deliberate, recorded non-completion, never a deletion.)

**Integration model — the task is the unit of work, the PR, *and* the merge gate.** For
git/PR projects the default is **PR-per-task**: `pick` cuts `task/TASK-NNN` from the default
branch, and `close` is the **merge gate** — it runs the convention + correctness checks
([[verify-conventions]] + [[code-review]] on the working tree, [[security-review]] when the diff
touches a security surface, [[review]] on the PR diff), settles the merge decision, writes the
status that decision makes true, and merges. So **`done` means *merged*** — a single precise
state, not "reviewed somewhere."
- The status is written *before* the commit, not after: the tracking file has to ride in the
  same commit as the work, or merged history says `in-progress` forever. That's only sound
  because the merge is decided first — `close` asks "merge now?" ahead of the frontmatter write
  (its step 5c), so the committed status is already true.
- **Declining the merge means the task isn't `done`** — it ends at `blocked`, with the reason and
  any `depends-on` recorded, and re-closes after `/tasks unblock` once the blocker clears. A
  finished-but-unmerged task is real work in a real holding state, not a `done` with an asterisk;
  keeping it out of `done` is what stops the invariant above from decaying into a slogan.

**Declare the integration model, don't infer it.** `.config.yml`'s `integration:` field is
`pr-per-task` (default) or `single-branch`. Reading it beats reading `git log`, which cannot tell a
commit-to-main repo from a squash-merge one. On `single-branch`, `pick` offers no branch and `close`
skips step 8 — `done` still means *on the default branch*, only the mechanism changes.

Code is reviewed **once per task, here, at the right altitude**;
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
  **An absent section is not an `N/A` one** — resolve it (write the steps, or write `N/A` with the
  reason a human adds nothing) *before* choosing the status. Defaulting a missing plan to `review`
  parks the task on a step that may not exist, and it is indistinguishable from an unrun one
  afterwards, so it becomes debt nobody can clear. `close` step 5 enforces this.
- `review` → `done` only after the human step is checked off (the `close` verb enforces this).
- **A change landing on a closed feature reopens the implementing task.** This is the
  *down-the-tree* counterpart to the roll-up rule below: when a post-sign-off change
  with a human-verifiable surface lands on a `done` feature (the [[feature]] skill's
  surface-dependent-revert rule), the TASK(s) that implement the changed surface go
  `done → review` and their `## Human test plan` is re-run before re-closing. A
  tests-only change (nothing for a human to check) stays `done`. Don't reopen a task
  without also recording the matching `changed` decision in its feature's ledger —
  the two move together.

**Plan before you implement.** A TASK's `## Implementation plan` is drafted before work starts —
`new` auto-runs [plan](verbs/plan.md) for tasks, and `pick` offers it for any task that reached
work without one (default **yes**; decline only for genuine one-liners). Picking an unplanned
non-trivial task and improvising is how scope quietly grows past the acceptance criteria.

**Scope discovered mid-work gets its own task — never an extra criterion on the one in hand.**
When something surfaces that isn't covered by the current task's acceptance criteria (a refactor
the change exposed, a bug found in passing, a follow-up the plan deferred), **offer
[`/tasks spawn`](verbs/spawn.md) unprompted** rather than widening the task, silently doing the
work, or dropping it. Spawn places the new task under the origin's parent, inherits its
`feature:`, rewrites the displaced plan step to point at the new ID, and reconciles the feature's
decision ledger (a new `proposed` row when no decision covers the discovery, so it returns through
`/feature decide`). Widening an in-flight task destroys its acceptance list as an independent
target — the same failure the "create the task before implementing" rule guards against, arriving
from the other direction.

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

**Findings become tasks, or they evaporate.** [[code-review]], [[security-review]] and
[[verify-conventions]] report to stdout or a PR comment and write no files — so a finding that isn't
turned into tracked work is gone when the conversation ends. Two entry points, by size: a single
adjacent finding surfaced while working → [`spawn`](verbs/spawn.md); a whole review **pass** →
[`intake`](verbs/intake.md), which files it as EPIC → STORY → TASK for [[fix-next]] to drain. Two
non-obvious rules travel with this:
- ***A checklist line is filed, not scheduled.*** Only `status: todo` **tasks** are ranked by `pick`,
  by the `Next up` snapshot, or by `fix-next`. A finding parked as a bullet under a STORY is invisible
  to all three and will never be worked. If it's worth doing, it's a task.
  - **This is about the CONTAINER, not the container's name — and `## Out of scope` is the one that
    catches people.** That section has two legitimate jobs and only one of them is prose. Recording a
    **boundary** ("this task does not cover X; Y owns it") is exactly what it is for. Recording **work**
    ("Z is also broken, but not here") is the checklist-line failure wearing a different heading: the
    sentence describes something someone should later do, nothing ranks it, and it is discoverable only
    by whoever re-reads a closed task. Same for a `## Notes` aside, a `> ⚠` callout, and a code comment
    that says "should be fixed properly one day".
  - **The test is the sentence's kind, not its size.** "Small", "latent", "nobody hits this yet" and
    "found in passing" are all reasons it feels unworthy of an id — and none of them is a reason it will
    get picked up. Genuinely torn → spawn: a spare task is cheap noise you can `cancel`, an untracked
    paragraph is work that silently disappears. `close` step 5d enforces this mechanically, because
    intentions do not survive a long session — measured instance: one thread produced six such
    paragraphs across five closed tasks while the same session was quoting this very rule.
- **Four optional frontmatter fields are owned by this pair and are not stray keys** — `triage` and
  `audit` must not flag them: `findings:` (task — the ids it remediates, `CR-*`/`SEC-*`/`SH-*`/`VC-*`),
  `kind: review-intake` + `source:` (epic — the stamp `fix-next` reads to find the pool, so no epic
  id is ever hard-coded, plus where the findings came from), `picked-by:` (task — which autonomous
  skill owns an in-progress run), and a
  `## Progress log` body section (task — one line per completed step, written *as it happens*, so an
  interrupted run resumes from disk rather than from conversation memory; on a disagreement with git,
  git wins).

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
- **The merge is part of "done".** Closing a task without merging `task/TASK-NNN` into the default branch leaves `done` meaning "committed somewhere, not integrated" — `tasks/README.md` and `docs/features/*/status.md` will reflect `done` while `main` doesn't carry the work. The close verb's step 8 enforces this as a hard stop; do not advance past it without the user's explicit go-ahead (or a captured deferral reason in `## Out of scope`).

## Related skills

- [[feature]] — Per-feature lifecycle (prototype → decisions → decompose → stakeholder docs → review). It calls `/tasks new --from-feature FEATURE-NNN` to decompose approved decisions into tasks, and `/tasks close` / `/feature review` enforce the per-task `## Human test plan`. Tasks born from a feature carry `feature: FEATURE-NNN` frontmatter. `/feature pick` is the feature-side front door — it offers `decompose` when approved decisions have no tasks, then hands off to `/tasks pick --feature FEATURE-NNN`; `/tasks spawn` pushes back the other way, reconciling mid-work discoveries into that feature's decision ledger.
- [[roadmap]] — Unified cross-tree view + drift audit. The bare-`/tasks` snapshot delegates to its Cross-tree pass for the compact `features/ …` slice; `/roadmap` renders the full epic→feature→task tree. The divergence rules live there, not duplicated here.
- [[new-project]] — Generic project scaffolder; creates the `tasks/` folder (this skill) and `docs/features/` (the [[feature]] skill) at project birth, and seeds CLAUDE.md with the lifecycle convention.
- `jira-task` — Jira ticket end-to-end workflow (optional, environment-specific — not part of this skill set). `/tasks pick` on a task with `jira-key:` set hands off here when installed.
- [[verify-conventions]] — adherence lint against `CLAUDE.md § Conventions`; `/tasks close` runs it (with [[code-review]]) before flipping a non-trivial task to `done`.
- [[code-review]] — correctness review; the complement to `verify-conventions` at the close gate. Runtime-provided (a Claude Code built-in); `close` carries an inline fallback for runtimes without it.
- [[security-review]] — the security third of the close gate, run **conditionally**: `close` step 5b invokes it when the task's diff touches auth, data access, user input, crypto, secrets, a new dependency, or an exposed endpoint. Same runtime-provided + inline-fallback rule. `/feature review`'s security pass is optional and feature-wide — it does not backstop this one.
- [[review]] — reviews the **PR diff** at the `/tasks close` merge gate (the PR-per-task default). Runtime-provided, same fallback rule.
- [[fix-next]] — drains the defect backlog `intake` files. It reads the `kind: review-intake` stamp and `findings:` lists to build its pool, ranks by blast radius rather than `priority:`, and delegates the merge gate straight back to `close`. Where `pick` is interactive and picks *any* task, `fix-next` runs unattended and only ever picks defects.
- [[populate-tests]] — turns each task/surface into standing coverage; a field-found bug routes back as a task that ships with a regression spec (the loop). Owns *Prove the guard can fail*, which `close` step 5 requires before an automated check can retire a `[manual]` step.
- [[specs]] — harvested capability specs (`docs/specs/`). `close` on a STORY offers a scoped `/specs regen --story` so the spec diff confirms the story's behavioral change was intended; the snapshot's `specs: N stale` line comes from [[roadmap]]'s slice of its `verify`.
- [[handoff]] — Same agent-pickable-context principle applied at a different scope.
