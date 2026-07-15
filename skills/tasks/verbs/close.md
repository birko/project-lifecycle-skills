# /tasks close — mark a task done

Flip a TASK to `done`. In hybrid mode, also close the linked remote issue.

## Steps

1. **Find task root**.

2. **Parse args**:
   - `<ID>` — required. Can be `TASK-001` or just `001` if unambiguous across all task IDs in the project.
   - `--no-pr` — skip the PR/commit prompt.
   - `--story <STORY-NNN>` — close a STORY instead.
   - `--epic <EPIC-NNN>` — close an EPIC instead.

3. **Locate the file** — Grep `^id: TASK-NNN$` (or STORY/EPIC variant) across `tasks/`. If not found, suggest `/tasks triage` to refresh dashboard.

4. **Read current status**:
   - Already `done` → warn, ask "reopen and re-close?" or abort.
   - `cancelled` → warn similarly.

5. **Verify the Human test plan** (tasks only):
   - Read the `## Human test plan` section. If it still holds the template placeholder text (un-filled), warn: "Human test plan was never filled — confirm it's genuinely `N/A` or fill it before closing." Let the user proceed or pause.
   - If it has real steps with unchecked `[ ]` boxes, **don't close to `done`** — the manual/visual sign-off hasn't happened. Either (a) the user confirms they just ran it → check the boxes and proceed to `done`, or (b) it's not verified yet → set **`status: review`** (code complete, awaiting sign-off) and stop. Never mark `done` over an unrun checklist, and never write "done (pending)" — that's what `review` is for. A genuinely `N/A — covered by tests` plan closes straight to `done`.
   - This is the same check `/feature review` runs; closing a task is the per-task enforcement point. (To later move `review → done`, re-run `close` once the human step is checked off.)

5b. **Convention + correctness check — the merge gate** (non-trivial tasks only; skip for docs/renames/one-liners):
   - Run [[verify-conventions]] on the task's diff — does it follow the project's documented rules in `CLAUDE.md § Conventions` (framework/stack, UI/UX, structure, naming, testing)? Address 🛑 blockers before `done`, or note in the task why any are deferred.
   - If the work **introduced a new cross-cutting pattern** (new framework/dependency, UI pattern, layer, naming/testing convention), the register-on-introduce rule applies: confirm `CLAUDE.md § Conventions` (and `## Architecture` if structure changed) was updated in the same change — closing without recording it leaves the rulebook lying. `verify-conventions` flags this.
   - Run [[code-review]] on the working diff for correctness (the existing CLAUDE.md rule). The two are complementary: adherence vs. bugs.
   - **If a PR exists** (the PR-per-task default — see [SKILL.md → Lifecycle → Integration model](../SKILL.md#lifecycle)), run [[review]] on the PR diff before merging. **This per-task pass is where code correctness is reviewed, once, at the right altitude** — `/feature review` then only *confirms completeness*, it does **not** re-review the code wholesale.

6. **Commit progress / record reference** (tasks only, skip if `--no-pr`):
   - **Is it git-tracked?** Run `git rev-parse --is-inside-work-tree` from the task root. If it's not a git repo (or the command errors), skip this whole step and leave `pr:` as-is.
   - **Anything to commit?** Run `git status --porcelain`. If the tree is clean, don't offer a commit — just optionally ask for an existing PR number / commit SHA (accept empty as skip) and continue.
   - **If there are uncommitted changes, ask the user** (AskUserQuestion) what to do:
     - **Commit the progress now** → stage the work plus the updated task file and create one commit; use its short SHA for `pr:`.
       - Message: `{{ID}}: {{task title}}`, mirroring the repo's existing style if there is one (e.g. a `@ <area>:` prefix — check `git log --oneline -5`). Show the message and the file list before committing.
       - **No `Co-Authored-By:` trailer** (skill convention — see SKILL.md › Conventions).
       - Stage explicitly (the task file + the change set the user confirms) — never blanket `git add -A`, so ignored/stray files don't slip in. Sanity-check `git diff --cached --name-only` before committing.
       - Commit to the current branch. **On a `task/TASK-NNN` branch (the PR-per-task default), offer to push and open/merge the PR** after the merge-gate checks in 5b pass — this is the integration moment that gives `done` its meaning (*merged*). Never auto-branch, push, or merge without the user's go-ahead; a non-git or local-only project skips all of this and just records the reference.
     - **Reference an existing commit / PR instead** → prompt for a PR number or commit SHA and write it to `pr:`.
     - **Skip** → leave `pr:` null. Accept empty input as skip.

7. **Edit frontmatter**:
   - `status: ... → status: done`
   - `pr: null → pr: <value>` (if provided)

8. **Hybrid mode remote close** (check `mode: hybrid` in `.config.yml`):
   - `github-issue: <N>` set → run `gh issue close <N> --comment "Closed by {{ID}}"`.
   - `jira-key: <KEY>` set → use the Atlassian MCP to transition the issue to Done (search for the transition tool via ToolSearch first; if MCP isn't authenticated, prompt user). Alternatively hand off to the [[jira-task]] skill for the proper closure workflow (Slovak PM comment, disaster log entry).

9. **Regenerate dashboard**.

10. **Rollup hint** (informational; never auto-close parents):
    - If this task was the last open task in its STORY → suggest `/tasks close <STORY-ID>`.
    - If closing a STORY leaves an EPIC with no open stories → suggest `/tasks close <EPIC-ID>`.
    - But default behaviour for STORY/EPIC is to stay open — areas of concern keep gaining work.
    - **Feature rollup** — if the closed task has `feature: FEATURE-NNN` and it was the last open task for that feature, suggest `/feature review FEATURE-NNN`.
    - **Spec regen offer** (STORY close only; skip silently when the project has no `docs/specs/.map.yml`): map the story's merged work to spec areas — resolve its tasks' `pr:` commits/PRs to changed files (`git show --name-only <sha>` / `gh pr diff <n> --name-only`) and match them against the `.map.yml` globs; if references are missing, ask which areas. Then **offer** — don't auto-run — `/specs regen <areas> --story STORY-NNN`. The regen's diff review is the "was this behavioral change intended?" check (the [[specs]] skill); an unexpected spec diff at story close is a finding, not churn.
    - **Changelog nudge** (don't auto-run; avoid double-nudging) — only for **task-only work that `/feature review` won't cover**: if the closed item has **no `feature:` link** (a `_loose` task or a feature-less EPIC/STORY) and represents a user-facing change, and the project has a `CHANGELOG.md`, print one line — *"consider `/roll-changelog` to record this for users."* Skip when the task has a `feature:` link (the feature's `/feature review` carries the nudge) or there's no `CHANGELOG.md`. The changelog is human-curated, so suggest, never auto-run.

11. **Confirm** — print:
    - Which file was updated
    - What changed (`status: todo → done`, `pr: null → 123`)
    - Remote close result if hybrid

## Edge cases

- **PR-only close, no GH issue link** — that's fine. `pr:` is just a backreference.
- **GH issue close fails** (e.g. already closed remotely) — log warning, still mark local done.
- **Jira MCP not authenticated** — prompt user to run authentication; pause the verb until they confirm.
- **Closing EPIC with open children** — block by default ("EPIC-001 has 3 open tasks; close them first or pass `--force`").
