# /tasks close — the merge gate (→ `done`, or `review`)

Flip a TASK to `done` — or to `review` when its Human test plan hasn't been run yet (step 5). In hybrid mode, also close the linked remote issue.

## Steps

1. **Find task root**.

2. **Parse args**:
   - `<ID>` — required. Can be `TASK-001` or just `001` if unambiguous across all task IDs in the project.
   - `--no-pr` — skip the PR/commit prompt.
   - `--story <STORY-NNN>` — close a STORY instead.
   - `--epic <EPIC-NNN>` — close an EPIC instead.
   - `--force` — with `--story`/`--epic`, close even when open children remain (see Edge cases).

3. **Locate the file** — Grep `^id: TASK-NNN$` (or STORY/EPIC variant) across `tasks/`. If not found, suggest `/tasks triage` to refresh dashboard.

4. **Read current status**:
   - Already `done` → warn, ask "reopen and re-close?" or abort.
   - `cancelled` → warn similarly.

5. **Verify the Human test plan** (tasks only):
   - Read the `## Human test plan` section. If it still holds the template placeholder text (un-filled), warn: "Human test plan was never filled — confirm it's genuinely `N/A` or fill it before closing." Let the user proceed or pause.
   - If it has real steps with unchecked `[ ]` boxes, **don't close to `done`** — the manual/visual sign-off hasn't happened. Either (a) the user confirms they just ran it → check the boxes and proceed to `done`, or (b) it's not verified yet → set **`status: review`** (code complete, awaiting sign-off), then **park the work properly before skipping ahead**:
     - **Commit the finished work on the task branch** (same staging discipline as step 7) with a message noting the parked state (`TASK-NNN: … (review — human test plan pending)`), and on a PR project **offer to push and open the PR marked "awaiting sign-off"** — `review` is exactly the moment a PR should exist; finished code must never float uncommitted while a human schedules the test.
     - Optionally run the 5b checks now (recommended) so the human tests *reviewed* code; otherwise they run at the eventual re-close.
     - Then **skip to step 9** — the dashboard regen and rollup hints must still run, or `tasks/README.md` keeps claiming `in-progress` while the file says `review`; only the close-to-`done` path (steps 6–8) is skipped. Never mark `done` over an unrun checklist, and never write "done (pending)" — that's what `review` is for. A genuinely `N/A — covered by tests` plan closes straight to `done`.
   - This is the same check `/feature review` runs; closing a task is the per-task enforcement point. (To later move `review → done`, re-run `close` once the human step is checked off.)

5b. **Convention + correctness check — the merge gate** (non-trivial tasks only; skip for docs/renames/one-liners):
   - Run [[verify-conventions]] on the task's diff — does it follow the project's documented rules in `CLAUDE.md § Conventions` (framework/stack, UI/UX, structure, naming, testing)? Address 🛑 blockers before `done`, or note in the task why any are deferred.
   - If the work **introduced a new cross-cutting pattern** (new framework/dependency, UI pattern, layer, naming/testing convention), the register-on-introduce rule applies: confirm `CLAUDE.md § Conventions` (and `## Architecture` if structure changed) was updated in the same change — closing without recording it leaves the rulebook lying. `verify-conventions` flags this.
   - Run [[code-review]] on the working diff for correctness (the existing CLAUDE.md rule). The two are complementary: adherence vs. bugs. `code-review` is runtime-provided (a Claude Code built-in); **if this runtime has no such skill, do the pass inline** — read the diff and check for logic errors, unhandled edge cases, regressions, and security-sensitive changes; address blockers before `done`. Never skip the gate because the skill name didn't resolve.
   - **If a PR exists** (the PR-per-task default — `pick` cuts a `task/TASK-NNN` branch, `close` is the merge gate), run [[review]] on the PR diff before merging (runtime-provided; no such skill → read `gh pr diff <n>` and run the same correctness pass at PR altitude). **This per-task pass is where code correctness is reviewed, once, at the right altitude** — `/feature review` then only *confirms completeness*, it does **not** re-review the code wholesale.

6. **Edit frontmatter FIRST — the state you commit must be the truth** (tasks only):
   - `status: ... → status: done` (and check any acceptance boxes the user just confirmed).
   - `pr:` — fill now when the reference already exists (a PR number, or the SHA of an earlier commit). When the reference will be the commit step 7 creates, leave it null here and backfill inside step 7 — never after the merge.
   - Ordering rationale: flipping status *after* the commit means the merged history says `in-progress` forever and the `done` flip floats uncommitted — the tracking files must ride in the same commit as the work.

7. **Commit progress / record reference** (tasks only, skip if `--no-pr`):
   - **Is it git-tracked?** Run `git rev-parse --is-inside-work-tree` from the task root. If it's not a git repo (or the command errors), skip this whole step and leave `pr:` as-is.
   - **Anything to commit?** Run `git status --porcelain`. If the tree is clean, don't offer a commit — just optionally ask for an existing PR number / commit SHA (accept empty as skip) and continue.
   - **If there are uncommitted changes, ask the user** (AskUserQuestion) what to do:
     - **Commit the progress now** → stage the work plus the updated task file (already flipped to `done` in step 6) and create one commit.
       - Message: `{{ID}}: {{task title}}`, mirroring the repo's existing style if there is one (e.g. a `@ <area>:` prefix — check `git log --oneline -5`). Show the message and the file list before committing.
       - **No `Co-Authored-By:` trailer** (skill convention — see SKILL.md › Conventions).
       - Stage explicitly (the task file + the change set the user confirms) — never blanket `git add -A`, so ignored/stray files don't slip in. Sanity-check `git diff --cached --name-only` before committing.
       - **SHA backfill:** if `pr:` should reference this very commit, write the short SHA into the task file now and stage that one-line edit so it rides in the *merge* (PR-per-task) — or, on a plain single-branch flow, fold it into the commit by amending before anything else references it. Don't leave the backfill dangling uncommitted.
       - Commit to the current branch. **On a `task/TASK-NNN` branch (the PR-per-task default), offer to push and open/merge the PR** after the merge-gate checks in 5b pass — this is the integration moment that gives `done` its meaning (*merged*). Never auto-branch, push, or merge without the user's go-ahead; a non-git or local-only project skips all of this and just records the reference.
     - **Reference an existing commit / PR instead** → prompt for a PR number or commit SHA and write it to `pr:` (stage/commit that edit with the close).
     - **Skip** → leave `pr:` null. Accept empty input as skip.

8. **Hybrid mode remote close** (check `mode: hybrid` in `.config.yml`):
   - `github-issue: <N>` set → run `gh issue close <N> --comment "Closed by {{ID}}"`.
   - `jira-key: <KEY>` set → use the Atlassian MCP to transition the issue to Done (search for the transition tool via ToolSearch first; if MCP isn't authenticated, prompt user). Alternatively, if a `jira-task` skill is installed (an optional, environment-specific skill), hand off to it for that environment's full closure workflow.

9. **Regenerate dashboard**.

10. **Rollup hint** (informational; never auto-close parents):
    - If this task was the last open task in its STORY → suggest `/tasks close <STORY-ID>`.
    - If closing a STORY leaves an EPIC with no open stories → suggest `/tasks close <EPIC-ID>`.
    - But default behaviour for STORY/EPIC is to stay open — areas of concern keep gaining work.
    - **Feature rollup** — any task with `feature: FEATURE-NNN` that changed status here (`done` *or* parked at `review`) → chain `/feature status FEATURE-NNN` (single-feature mode) so `status.md` and the index row reflect the new task state; the rollup must never lag a close. If it was the last open task for that feature, also suggest `/feature review FEATURE-NNN`.
    - **Spec regen offer** (STORY close only; when the project has real code but no `docs/specs/.map.yml` **or the map's `areas:` list is empty** — the [[new-project]] scaffold seeds exactly such an empty anchor — print one line — *"no usable spec map — run `/specs init` to bootstrap the spec layer"* — instead of skipping silently): map the story's merged work to spec areas — resolve its tasks' `pr:` commits/PRs to changed files (`git show --name-only <sha>` / `gh pr diff <n> --name-only`) and match them against the `.map.yml` globs; if references are missing, ask which areas. Then **offer** — don't auto-run — `/specs regen <areas> --story STORY-NNN`. The regen's diff review is the "was this behavioral change intended?" check (the [[specs]] skill); an unexpected spec diff at story close is a finding, not churn.
    - **Changelog nudge** (don't auto-run; avoid double-nudging) — only for **task-only work that `/feature review` won't cover**: if the closed item has **no `feature:` link** (a `_loose` task or a feature-less EPIC/STORY) and represents a user-facing change, and the project has a `CHANGELOG.md`, print one line — *"consider `/roll-changelog` to record this for users."* Skip when the task has a `feature:` link (the feature's `/feature review` carries the nudge) or there's no `CHANGELOG.md`. The changelog is human-curated, so suggest, never auto-run.

11. **Confirm** — print:
    - Which file was updated
    - What changed (`status: todo → done`, `pr: null → 123`)
    - Remote close result if hybrid

## Closing a STORY / EPIC (`--story` / `--epic`)

Container closes are simpler than task closes — no human-test plan, no merge gate (each child task already passed both at its own close). The procedure:

1. **Children-done check** — every child TASK (and, for an epic, every STORY) must be `done`/`cancelled`; otherwise block by default, listing the open children ("STORY-001 has 2 open tasks; close them first or pass `--force`").
2. **Flip `status:` → `done`** in the STORY.md/EPIC.md frontmatter.
3. **Parent rollup** — re-evaluate the parent: a story close may leave its EPIC with no open stories (suggest closing it, per step 10); an epic close ends the chain. Update parent files, not just the leaf.
4. **Regenerate the dashboard** (step 9) and run step 10's hints — for a STORY, that's where the **spec regen offer** fires; the changelog nudge applies only to feature-less containers.
5. **Confirm** (step 11 format).

## Edge cases

- **PR-only close, no GH issue link** — that's fine. `pr:` is just a backreference.
- **GH issue close fails** (e.g. already closed remotely) — log warning, still mark local done.
- **Jira MCP not authenticated** — prompt user to run authentication; pause the verb until they confirm.
- **Closing EPIC with open children** — block by default ("EPIC-001 has 3 open tasks; close them first or pass `--force`").
