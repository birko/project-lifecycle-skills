# /tasks new — create EPIC / STORY / TASK

Interactive scaffold of a new task tree node.

## Steps

0. **Parse flags** the caller may have passed:
   - `--no-plan` — skip the auto-plan step (see step 12).
   - `--from-feature FEATURE-NNN` — this task is being decomposed from a feature (the [[feature]] skill passes this). When present:
     - Set `{{FEATURE}}` frontmatter to `FEATURE-NNN` (otherwise `{{FEATURE}}` is `null`).
     - Skip re-asking for Context — pull it from the feature's `docs/features/FEATURE-NNN/decisions.md` row(s) and `idea.md` that triggered this task.
     - The caller usually also passes `--no-plan` for batch decomposition; respect it.
   - `--from-review <finding-ids> [--source <ref>]` — this task remediates findings from a review /
     audit / spec-harvest pass ([verbs/intake.md](intake.md) passes this, once per task, exactly as
     `/feature decompose` passes `--from-feature`). When present:
     - Set `{{FINDINGS}}` frontmatter to the id list (`[CR-7, CR-9]`); otherwise `[]`.
     - Skip re-asking for Context — write the findings' own evidence into `## Context`: the
       `file:line` each was raised against, the mechanism, and `--source` if the pass left a
       reference. **The task must stand alone** — a reader must not need the review output to work
       it, because that output is transient (stdout / a PR comment) and will be gone.
     - Draft `## Acceptance criteria` from *what must hold once fixed*, not from "apply the
       suggestion" — the criteria are an independent target, and a review's proposed fix is a
       hypothesis until step 3 of [[fix-next]] re-verifies it.
     - The caller passes `--no-plan` for batch intake; respect it.
     - `--from-feature` and `--from-review` compose: a finding inside a feature's surface carries both.

1. **Find task root** — walk up from cwd: a directory containing `tasks/.config.yml` wins; else the project root (`*.slnx`/`*.sln`, then `.git`) → `<root>/tasks/`. A project's CLAUDE.md may override placement (aggregator repos hosting cross-cutting epics for a polyrepo family).
   - If `tasks/.config.yml` is **missing** → run the [mode detection flow](#mode-detection-flow) first. Write `.config.yml` before creating any task files.

2. **Determine level** (skip prompt if user passed it as arg: `/tasks new epic|story|task`):
   - `epic` — area of concern
   - `story` — user behaviour under an epic
   - `task` — single implementable unit

   **Decision test** — when the user is unsure (or their ask doesn't match the level they picked), walk down:
   - Is it a **lasting area** that will keep accumulating behaviours over time (auth, imports, performance, a migration programme)? → `epic`. Epics are rarely "finished" — only one-shot epics (e.g. a migration) have a concrete done-when.
   - Is it **one observable user behaviour** — can you phrase it as "As a [persona], I want [capability] so that [value]"? → `story`. If you can't fill that sentence, it isn't a story.
   - Is it a **single implementable unit** — completable in one sitting/PR, with acceptance criteria you could check off? → `task`. Tasks are the only level that gets *done*; epics and stories mostly stay open.
   - Rules of thumb: too big for one PR but still one behaviour → keep it a `story` and split into tasks; several distinct behaviours → `epic` with stories under it (mirrors [[feature]] decompose: "a feature usually maps to one STORY or a small EPIC"). When genuinely torn between story and task, pick `task` — promoting a task to a story later is cheap; a hollow story is noise.

3. **Ask the title** — short noun phrase. Generate slug: lowercase, hyphens, ASCII only, max 50 chars. Strip stop words only if title would exceed length.

4. **Ask for parent** (story/task only):
   - **story** → list existing epics with their IDs + titles, user picks one (epic must exist; if none, propose `/tasks new epic` first).
   - **task** → list epics and stories under each. User picks story ID, **or** epic ID for a direct-child task, **or** "none" to place in `_loose/`.

5. **Ask priority and assignee** (task only):
   - Priority: P0 / **P1** (default) / P2
   - Assignee: human / **ai** (default) / `<specific-agent-name>`

6. **Generate ID**:
   - Grep `^id: (EPIC|STORY|TASK)-(\d+)$` recursively in `tasks/`.
   - For the requested type, take max, increment, zero-pad to 3 digits.
   - First of a type: `EPIC-001` / `STORY-001` / `TASK-001`.

7. **Compute file path**:
   - epic: `tasks/EPIC-NNN-slug/EPIC.md`
   - story: `tasks/EPIC-PPP-pslug/STORY-NNN-slug/STORY.md`
   - task with parent story: `tasks/EPIC-PPP-pslug/STORY-PPP-pslug/TASK-NNN-slug.md`
   - task with parent epic (direct child): `tasks/EPIC-PPP-pslug/TASK-NNN-slug.md`
   - task without parent: `tasks/_loose/TASK-NNN-slug.md`

8. **Render the template** from `templates/{EPIC|STORY|TASK}.md`, substituting placeholders:
   - `{{ID}}` — generated ID
   - `{{PARENT}}` — parent ID (or `null` for orphan task / epic)
   - `{{CREATED}}` — today (`YYYY-MM-DD`)
   - `{{STATUS}}` — `planned` for epic/story, `todo` for task
   - `{{PRIORITY}}` — P0/P1/P2 (task only)
   - `{{ASSIGNEE}}` — human/ai/agent-name (task only)
   - `{{FEATURE}}` — `FEATURE-NNN` from `--from-feature`, else `null` (task only)
   - `{{FINDINGS}}` — the id list from `--from-review`, else `[]` (task only)
   - `{{KIND}}` — `review-intake` when [intake](intake.md) is scaffolding a review pass's epic, else omit the line entirely (epic only)
   - `{{SOURCE}}` — provenance for a `review-intake` epic: the report path(s), PR, or `<pass> <date>` when the findings arrived in-conversation. Omit the line for a normal epic (epic only)
   - `{{OWNER}}` — human/ai/both (epic only; default `human`)
   - `{{AFFECTS}}` — `[]` unless the EPIC is cross-cutting in an aggregator repo of a polyrepo family (see SKILL.md § Shape detection); then ask the user which sub-projects it affects and write the list
   - `{{TITLE}}` — the title from step 3

9. **For task: offer to draft body sections** (Context / Acceptance / Out-of-scope / **Human test plan**) using any context already in the conversation. User reviews/edits before writing. If you can't draft confidently, leave the templates' placeholder copy and tell the user to fill it in.
   - **Human test plan** — draft concrete manual steps only for behaviour automated tests can't cover (UI/UX, edge cases, external integrations). If the task is plainly unit-testable, write `N/A — fully covered by automated tests` rather than inventing filler steps. When `--from-feature` is set, mine the feature's prototype + decisions for the UI/UX flows worth manual-testing.

10. **Write the file** with the Write tool.

10b. **Backfill the feature ledger** (`--from-feature` only) — write this `TASK-NNN` into the `→ Tasks` column of the originating decision row(s) in `docs/features/FEATURE-NNN/decisions.md` (idempotent — skip IDs already listed). This runs whether the caller is `/feature decompose` or a direct invocation, so the ledger can never miss a task. When invoked directly (not via decompose), also append the History line yourself: `{{DATE}} — D<n> decomposed → TASK-NNN`; via decompose, leave the batch History line to its step 4.

11. **Regenerate dashboard** — chain to [verbs/triage.md](triage.md) logic. Update `tasks/README.md`.

12. **Auto-plan (task only)** — if level is `task` AND user did **not** pass `--no-plan`, chain into [verbs/plan.md](plan.md) for the freshly-created TASK ID. Skip for epic/story (they don't get plans). Skip silently if `--no-plan` was passed (use case: batch-creating tasks without grilling on each one).

13. **Confirm** — print:
    - File path created
    - Next-step hint depending on level:
      - epic → "Add stories with `/tasks new story`"
      - story → "Add tasks with `/tasks new task`"
      - task → "Start work with `/tasks pick`" (or "Plan was skipped — run `/tasks plan {{ID}}` later" if `--no-plan`)

## Mode detection flow

Runs once per project, when `.config.yml` is missing.

1. **Scan signals**:
   - `Test-Path .github/ISSUE_TEMPLATE` → suggest `hybrid (github)`
   - Grep CLAUDE.md + README for `*.atlassian.net/browse/` or another Jira-shaped URL → suggest `hybrid (jira)`
   - Neither → suggest `local`
2. **Ask user** via AskUserQuestion with three options: local / hybrid (github) / hybrid (jira). Pre-select the suggested one.
3. **For hybrid (github)**: ask for the repo. Default = `git remote get-url origin` parsed to `owner/name`. Optionally ask for `default-labels`.
4. **For hybrid (jira)**: ask for the project key (e.g. `SUP`).
5. **Write `tasks/.config.yml`** from [templates/config.yml](../templates/config.yml).

## Edge cases

- **Slug collision** — if the slugged folder/file already exists, append `-2`, `-3`, etc. (not `-002` — keep it short).
- **No epics yet, user wants story/task** — prompt "no epics — create one first?" and chain into `/tasks new epic` if confirmed.
- **Cross-cutting EPIC in an aggregator repo** — when the project's CLAUDE.md designates this repo as the polyrepo family's aggregator (see SKILL.md § Shape detection), a new EPIC here is cross-cutting. Ask which sub-projects it affects; write the list to `affects:`.
- **Existing `tasks/` but no `.config.yml`** — skill was previously used in a different version. Run mode detection to backfill.
- **`_loose/` doesn't exist yet** — create it when first loose task is added; never create it eagerly.
