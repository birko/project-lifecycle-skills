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
   - `--from-field [--source <ref>]` — this task records a defect found by **using** the product, with no
     review pass behind it. Where `--from-review` receives ids a pass already minted, this one **mints**
     the id, because no pass ran to do it. When present:
     - Mint the next `FIELD-NNN` — take the current max `FIELD-NNN` over every `findings:` list in **every copy
       of the task tree** ([SKILL.md § ID generation](../SKILL.md#id-generation) names the copies), increment,
       zero-pad to three digits — and set `{{FINDINGS}}` to `[FIELD-NNN]`. **When no copy holds any
       `FIELD-NNN`, the first is `FIELD-001`**: never `FIELD-000`, and never unpadded. The
       counter is **tree-wide, not per-epic**; [intake.md](intake.md)'s prefix table owns the prefix and
       the reason the scope differs from every other one.
     - Write the **field evidence** into `## Context`: what was being done, what happened instead, and the
       repo, version or invocation it happened in. `--source` carries a reference if there is one (an issue,
       a transcript, a sibling repo's path). The same standing rule as `--from-review` applies and matters
       more here: **the task must stand alone**, because a field report's context is a conversation that
       will be gone.
     - Draft `## Acceptance criteria` from *what must hold once fixed*. A field report describes a symptom;
       the criteria are the independent target, and [[fix-next]] step 3 re-verifies the mechanism before
       anything is written.
     - **Report the minted id in step 13's summary.** The whole point of the flag is that the task is now
       in [[fix-next]]'s pool, and a caller who is not told the id cannot tell that from a task that merely
       looks like a defect.
     - Composes with `--from-review` only in the odd case where a review *later* confirmed a field report;
       then both ids ride in `findings:`. Do not mint a `FIELD-NNN` for a finding a pass already numbered.
     - **An already-filed task joins the pool through the mint alone.** A defect filed earlier without an
       id, by hand or by `spawn`, is not created again. Only three things run for it, named here so no
       reader has to scope a general sentence:
       - **Runs:** the mint above; adding the id to that task's existing `findings:` list (append it, and
         keep any ids already there); and reporting the id and its consequence as step 13 does.
       - **Does not run:** steps 1–10b, which create a file. The `## Context` and `## Acceptance criteria`
         drafting above also stays out: the task already has both, and someone else wrote them. Step 11 does
         not run either, because no status or placement changed, so the dashboard is still true. Nor does
         step 12, because drafting a plan onto a task somebody filed is not what was asked.

1. **Find task root** — walk up from cwd: a directory containing `tasks/.config.yml` wins; else the project root (`*.slnx`/`*.sln`, then `.git`) → `<root>/tasks/`. A project's CLAUDE.md may override placement (aggregator repos hosting cross-cutting epics for a polyrepo family).
   - If `tasks/.config.yml` is **missing** → run the [mode detection flow](#mode-detection-flow) first. Write `.config.yml` before creating any task files.

2. **Determine level** (skip prompt if user passed it as arg: `/tasks new epic|story|task`):
   - `epic` — area of concern
   - `story` — user behaviour under an epic
   - `task` — single implementable unit

   **Decision test** — when the user is unsure (or their ask doesn't match the level they picked), walk down:
   - Is it a **lasting area** that will keep accumulating behaviours over time (auth, imports, performance, a migration programme)? → `epic`. Epics are rarely "finished" — only one-shot epics (e.g. a migration) have a concrete done-when.
   - Is it **one observable user behaviour** — can you phrase it as "As a [persona], I want [capability] so that [value]"? → `story`. If you can't fill that sentence, it isn't a story.
   - Is it a **single implementable unit** — completable in one sitting/PR, with acceptance criteria you could check off? → `task`; how to cut one is [slicing.md](../slicing.md). Tasks are the only level that gets *done*; epics and stories mostly stay open.
   - Rules of thumb: too big for one PR but still one behaviour → keep it a `story` and split into tasks; several distinct behaviours → `epic` with stories under it (mirrors [[feature]] decompose: "a feature usually maps to one STORY or a small EPIC"). When genuinely torn between story and task, pick `task` — promoting a task to a story later is cheap; a hollow story is noise.

   Put this question:

   > **Is this an epic, a story or a task?**
   > · **epic** — a lasting area that keeps gaining work. · **story** — one user behaviour. · **task** — one implementable unit.

   **Unless a caller set it.** **No answer, or nobody to ask:** apply the decision test above to the request, and mark `level`
   (§ *Unanswered questions*, below).

3. **Ask the title** — short noun phrase. Generate slug: lowercase, hyphens, ASCII only, max 50 chars. Strip stop words only if title would exceed length.
   Put this question:

   > **What should this <level> be called?** A short noun phrase, such as `Password reset email sent twice`.

   **Unless a caller set it.** **No answer, or nobody to ask:** write a short noun phrase from the request itself, and mark `title`.

4. **Ask for parent** (story/task only):
   - **story** → list existing epics with their IDs + titles, user picks one (epic must exist; if none, propose `/tasks new epic` first).
   - **task** → list epics and stories under each. User picks story ID, **or** epic ID for a direct-child task, **or** "none" to place in `_loose/`.
   - **List every candidate whatever its status, and mark the closed ones.** Placement follows ownership,
     not status:

     | Candidate reads | Show it as | When chosen |
     |---|---|---|
     | `planned` / `in-progress` | plain | file under it |
     | `done` | `EPIC-009 <title> (done — choosing it reopens it)` | file under it; step 10 reopens it |
     | `cancelled` | `STORY-014 <title> (cancelled — won't-do)` | put the question below |

     Put this question, listing the candidates as the table shows them:

     > **Where does "<title>" belong?**
     > · `1. STORY-001 Password login (done — choosing it reopens it)` · `2. EPIC-002 Reporting` · …
     > · **none** — `_loose/`, for work no epic or story owns (task only).

     **Unless a caller set it.** **No answer, or nobody to ask:** choose the candidate whose title and body own the subject, and mark
     `parent`. When none clearly does, a task goes to `_loose/` (a finding gets its `FIELD-NNN` there, as
     the cancelled path below says), and a story is **not created**: report
     `not created: no epic owns "<title>" — /tasks new story again and choose one.`

     **`done` is not a reason to pick `none`.** A done container that owns the work takes it and reopens
     ([SKILL.md](../SKILL.md) § *Roll status up to parents*). `_loose/` would lose the placement and leave
     the task unranked.

     **A `cancelled` candidate** — chosen, or inherited from a caller such as [spawn](spawn.md). Put this question:

     > **STORY-NNN "<title>" is cancelled (won't-do). File the new item under it and reopen it, or file it elsewhere?**
     > · **Reopen and file here** — it goes back to `in-progress`.
     > · **File under <nearest ancestor that is not cancelled, or `_loose/`>** — the cancel stands.

     **No answer, or nobody to ask:** do not reopen. File under the nearest ancestor that is not cancelled
     (the epic above a cancelled story; a `done` one takes it and reopens, as above), else `_loose/`, and report
     `STORY-NNN is cancelled — <new id> filed under <where>; nothing chose to reopen it. /tasks move <new id> --to STORY-NNN reopens it if the cancel no longer holds.`
     - **A task that is a finding and would land in `_loose/`** gets its id here: mint a `FIELD-NNN` exactly
       as `--from-field` does, unless it already carries one. Loose and id-less, it is outside [[fix-next]]'s
       pool ([spawn.md](spawn.md) step 4).
     - **A story has no such fallback**, since it needs an epic and cannot be loose. A story under a cancelled
       epic with no answer is **not created**: report
       `not created: EPIC-NNN is cancelled and nothing chose to reopen it — /tasks new story again and choose it, or another epic.`

5. **Ask priority and assignee** (task only):
   - Priority: P0 / **P1** (default) / P2 / P3. These are the common values, not the only ones: write any `P<n>`
     the user gives exactly as given. The Collection pass buckets whatever priorities are present and `export`
     sends any value, so a value this step refused could still be read and exported but never created.
   - Assignee: human / **ai** (default) / `<specific-agent-name>`

   Put this question:

   > **Priority and assignee?** Priority `P0`–`P3` (default `P1`); assignee `human`, `ai` (default) or an agent's name.

   **Unless a caller set them.** **No answer, or nobody to ask:** `P1` and `ai`, and mark `priority, assignee`.

6. **Generate ID**:
   - Take the max for the requested type over **every copy of the tree**, as
     [SKILL.md § ID generation](../SKILL.md#id-generation) names them; then increment and zero-pad to 3 digits.
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
   - `{{STATUS}}` — `planned` for epic/story, `todo` for task; `done` for an epic [intake](intake.md) files as a record of a pass that dropped every finding
   - `{{PRIORITY}}` — `P<n>`, the value step 5 settled (task only)
   - `{{ASSIGNEE}}` — human/ai/agent-name (task only)
   - `{{FEATURE}}` — `FEATURE-NNN` from `--from-feature`, else `null` (task only)
   - `{{FINDINGS}}` — the id list from `--from-review`, or the single `FIELD-NNN` minted by
     `--from-field`, else `[]` (task only)
   - `{{KIND}}` — `review-intake` when [intake](intake.md) is scaffolding a review pass's epic, else omit the line entirely (epic only)
   - `{{SOURCE}}` — provenance for a `review-intake` epic; [intake](intake.md) step 5 owns what it carries, and it always names the pass. Omit the line for a normal epic (epic only)
   - `{{THEME}}` — the subject-ladder **slug** from [intake](intake.md)'s table when it is scaffolding
     a review-intake theme story, else **omit the field and its two comment lines entirely** (story
     only). Same rule as `{{KIND}}`/`{{SOURCE}}`: an ordinary story has no ladder position, and a
     rendered-but-empty `theme:` would read as a declared value rather than an absent one
   - `{{OWNER}}` — human/ai/both (epic only; default `human`)
   - `{{AFFECTS}}` — `[]` unless the EPIC is cross-cutting in an aggregator repo of a polyrepo family (see SKILL.md § Shape detection); then ask the user which sub-projects it affects and write the list. Put this question:

     > **Which sub-projects does "<title>" affect?** Give their folder names, or `none`.

     **Unless a caller set it.** **No answer, or nobody to ask:** write `[]` and mark `affects` (§ *Unanswered questions*). The template
     always renders the line, and a bare `[]` reads as "affects nothing". An answer of `none` writes `[]`, unmarked.
   - `{{TITLE}}` — the title from step 3

9. **For task: offer to draft body sections** (Context / Acceptance / Out-of-scope / **Human test plan**) using any context already in the conversation. User reviews/edits before writing. If you can't draft confidently, leave the templates' placeholder copy and tell the user to fill it in.
   Put this question:

   > **Shall I draft the Context, Acceptance criteria, Out of scope and Human test plan from what we have discussed?** You review them before I write the file.

   **No answer, or nobody to ask:** draft them when the request gives enough to do so confidently, and mark
   `body sections`; otherwise leave the placeholder copy and report the sections as unfilled. Sections a
   step-0 flag already drafts are not offered, so they are never marked.
   - **Human test plan** — draft concrete manual steps only for behaviour automated tests can't cover (UI/UX, edge cases, external integrations). If the task is plainly unit-testable, write `N/A — fully covered by automated tests` rather than inventing filler steps. When `--from-feature` is set, mine the feature's prototype + decisions for the UI/UX flows worth manual-testing.

10. **Write the file** with the Write tool, with the mark line under its heading when any field was
    inferred (§ *Unanswered questions*).
    - **The new item is open** (anything but `done` or `cancelled`) **and its parent reads `done`, or
      `cancelled` and step 4 chose to reopen it** → set the parent to `in-progress` in the same change, with
      its dated `> Reopened` line ([SKILL.md](../SKILL.md) § *Roll status up to parents*). Writing the child
      and leaving the parent for later leaves a `done` container over an open child if the run stops in between.
    - **Then check the epic above a parent story, whether or not the story was reopened.** A `planned` story
      can sit under a `done` epic (left by `close --epic --force`), and an open task in it makes that epic's
      `done` false too. Reopen a `done` epic the same way. A `cancelled` one asks first, as step 4 does.
    - **A new item that is itself `done` or `cancelled`** ([import](import.md) brings in closed issues this
      way) reopens nothing. A closed child does not falsify a closed parent, as [move](move.md) already says.

10b. **Backfill the feature ledger** — runs whenever the new task carries a non-null `feature: FEATURE-NNN`, **whatever set it**: the `--from-feature` flag, a value inherited from its parent, or one written by hand. Write this `TASK-NNN` into the `→ Tasks` column of the owning decision row(s) in `docs/features/FEATURE-NNN/decisions.md` (idempotent — skip IDs already listed), and append the History line `{{DATE}} — D<n> decomposed → TASK-NNN`. Via `/feature decompose`, leave the batch History line to its step 4 instead.

     **Gate on the link, not on the flag.** That column means *"the tasks realizing this decision"*, so a task carrying a feature link belongs in it regardless of which path minted it. Gating on `--from-feature` left a hole exactly where tasks are filed fastest: work discovered mid-fix is created under an existing parent and **inherits** the feature, so no flag is passed — and it wasn't a `/tasks spawn` either, so [spawn.md](spawn.md) step 6 doesn't fire. Three writers of one column, all keyed on *how the task was created* rather than on *whether it has a feature*, and the busiest path matched none of them. Measured on a real tree: 15 tasks over 5 days, one per fix that uncovered its successor, none of them visible to the feature that owned them until [[roadmap]]'s DV9 caught the lot.

     **Resolving the row when no decision originated the task** (the inherited case — there is no "originating" row to write to): match the task's parent STORY against the decision rows, which name their story (`Spec-harvest — high findings ([[STORY-051]])` → that row); an epic-direct task goes to the row covering work tracked outside any story. If no `approved`/`changed` row covers it, do **not** invent the link — this is new scope arriving through the back door, so follow [spawn.md](spawn.md) step 6's routing (append a new `proposed` row, tell the user it needs `/feature decide`).

     This closes the **creation** path only. A task whose `feature:` is filled in later still slips past it, so DV9 remains the backstop — it is a periodic audit, not a redundant one.

11. **Regenerate dashboard** — chain to [verbs/triage.md](triage.md) logic. Update `tasks/README.md`.

12. **Auto-plan (task only)** — if level is `task` AND user did **not** pass `--no-plan`, chain into [verbs/plan.md](plan.md) for the freshly-created TASK ID. Skip for epic/story (they don't get plans). Skip silently if `--no-plan` was passed (use case: batch-creating tasks without grilling on each one).

13. **Confirm** — print:
    - File path created
    - **The mark line**, when the file carries one, and any body section left unfilled (step 9)
    - **Each container step 10 reopened**, as `STORY-NNN reopened: <new id> is now <its status>`, and any
      cancelled parent step 4 declined to reopen, with its report line
    - Next-step hint depending on level:
      - epic → "Add stories with `/tasks new story`"
      - story → "Add tasks with `/tasks new task`"
      - task → "Start work with `/tasks pick`" (or "Plan was skipped — run `/tasks plan {{ID}}` later" if `--no-plan`)
    - **Any copy of the task tree the id scan could not read** (step 6 — [SKILL.md § ID generation](../SKILL.md#id-generation)),
      by path: the id may still collide there, and nobody else will say so.
    - **The minted `FIELD-NNN`, when `--from-field` was passed**, and what it bought: *"minted FIELD-003 — this
      task is now in `/fix-next`'s pool."* Say the consequence, not just the id. A task that entered the pool
      and one that merely reads like a defect are indistinguishable from the outside, and that ambiguity is the
      whole reason the flag exists.

## Unanswered questions

Every field a question in this verb asks for must exist in the file, so an unanswered one cannot be left
out. It gets the fallback its step names and is **marked as inferred**, or the next reader takes a guess for
a decision.

- **The mark** is one line directly under the new file's `# Heading`, written only when something was
  inferred, naming every such field:
  `> Filed with nobody to answer — inferred, not chosen: <fields>.`
  Step 13 repeats it, and [pick](pick.md) step 9 prints it again when the task is picked with `/tasks pick`. Whoever
  confirms the values deletes the line.
- **A field a calling verb sets is not asked for here and never marked.** That covers a value passed as an
  argument, one the caller pre-fills or derives by its own rules, one of its stated defaults, and the body
  sections a step-0 flag drafts. A rule chose it, not a guess. Each question below runs only for a field
  still unset. A caller that wants its values confirmed asks that itself ([spawn](spawn.md) step 4).
- **An inferred parent that reopens a container says so there too.** Its `> Reopened` line ends
  `(placement inferred — see <new id>)`, since the reopen is a side effect of that guess on another record.

## Mode detection flow

Runs once per project, when `.config.yml` is missing.

1. **Scan signals**:
   - `Test-Path .github/ISSUE_TEMPLATE` → suggest `hybrid (github)`
   - Grep CLAUDE.md + README for `*.atlassian.net/browse/` or another Jira-shaped URL → suggest `hybrid (jira)`
   - Neither → suggest `local`
2. **Ask the user**, via AskUserQuestion, with the scan's suggestion pre-selected. Put this question:

   > **How should this project track tasks?**
   > · **local** — markdown files in `tasks/` only.
   > · **hybrid (github)** — files plus synced GitHub Issues.
   > · **hybrid (jira)** — files plus synced Jira issues.

   **No answer, or nobody to ask:** fall back to **`local`** and write it **annotated**, as

   ```yaml
   mode: local                    # defaulted — nobody was asked; change with /tasks migrate
   ```

   then say in the confirmation that the mode was defaulted rather than chosen. `local` is the only
   option that needs no external credential and no remote, so it is the one value a run can pick without
   asserting something about the world. Unlike `integration:`, **omitting `mode:` is not available** —
   every other verb reads it — so this is the write-and-mark case rather than the leave-absent one, and
   the annotation is what stops a later reader taking a fallback for a decision. **`/tasks migrate` is what
   clears it**, not a later run of this flow — mode detection runs only when `.config.yml` is missing, so
   once the annotated line exists nothing here revisits it.

3. **For hybrid (github)**: ask for the repo, defaulting to `git remote get-url origin` parsed to `owner/name`:

   > **Which GitHub repository should issues sync to?** (`owner/name` — `<parsed default>`)

   Optionally, and only after that resolves: *"Any default labels to put on every synced issue? (blank for none)"*.
   **No answer:** take the parsed default when there is one; with no remote **and** no answer, fall back to
   `local` and say why (§ Edge cases already owns that fallback).

4. **For hybrid (jira)**: ask for the project key:

   > **Which Jira project key should issues be created under?** (e.g. `SUP`)

   **No answer:** there is no defensible default — a wrong key files work into someone else's project — so
   fall back to `local`, leave `project:` unwritten, and report the key as unresolved.

5. **Write `tasks/.config.yml`** from [templates/config.yml](../templates/config.yml).

## Edge cases

- **Slug collision** — if the slugged folder/file already exists, append `-2`, `-3`, etc. (not `-002` — keep it short).
- **No epics yet, user wants story/task** — prompt "no epics — create one first?" and chain into `/tasks new epic` if confirmed.
- **Cross-cutting EPIC in an aggregator repo** — when the project's CLAUDE.md designates this repo as the polyrepo family's aggregator (see SKILL.md § Shape detection), a new EPIC here is cross-cutting: step 8's `{{AFFECTS}}` question.
- **Existing `tasks/` but no `.config.yml`** — skill was previously used in a different version. Run mode detection to backfill.
- **Parent is `done` or `cancelled`** — step 4's table: a `done` one takes the child and reopens, a `cancelled` one asks.
- **`_loose/` doesn't exist yet** — create it when first loose task is added; never create it eagerly.
