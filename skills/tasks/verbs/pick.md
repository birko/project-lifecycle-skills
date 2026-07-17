# /tasks pick — choose a task and start work

Filter open tasks, present them, mark the chosen one in-progress, present its body for work.

## Steps

1. **Find task root**.

2. **Parse args**:
   - `--status` — default `todo` (don't include blocked unless asked)
   - `--priority` — filter (default: all)
   - `--assignee` — filter (default: all)
   - `--epic <ID>` — limit to tasks under one epic
   - `--story <ID>` — limit to tasks under one story
   - Bare ID arg (`/tasks pick TASK-014`) → skip the picker, jump to step 5

3. **Collect candidates** — every TASK file whose frontmatter matches the filters. For each, capture: id, title (from first `# Heading`), parent IDs (story + epic), priority, assignee, file path.

4. **Present numbered list** ordered by priority (P0 first), then created date:
   ```
   1. TASK-001 JWT issuance on login (P1, ai)
      EPIC-001 Authentication → STORY-001 Password login
   2. TASK-003 Rate limit (P1, ai)
      EPIC-001 Authentication → STORY-001 Password login
   3. TASK-007 Bump .NET 9 (P1, human)
      [loose]
   ```
   Ask user to pick by number (or accept a TASK-NNN ID directly).

5. **Read the chosen TASK file** in full.

6. **Soft plan check** — if the file has no `## Implementation plan` section, OR the section exists but its body is empty/placeholder-only, prompt:
   > "This task has no implementation plan. Run `/tasks plan {{ID}}` first? [y/N]"
   - `y` → hand off to [verbs/plan.md](plan.md) for this TASK ID, then resume `pick` from step 7 once it's done.
   - `N` → proceed without a plan (some tasks are genuinely one-liners; don't block).

7. **Flip status to in-progress**:
   - Use Edit to change `status: todo` (or whatever current) → `status: in-progress`.
   - **Cut the task branch (git/PR projects).** The default integration model is PR-per-task —
     `pick` cuts the branch, `close` is the merge gate. If the project is
     a git repo on its default branch, offer to cut `task/TASK-NNN` so the work is isolated and
     `/tasks close` can open one PR for it. Skip silently for non-git/local-only projects, or if
     the user is already on a suitable branch.
   - **Unborn HEAD** (freshly-initialized repo, no commits — `git rev-parse HEAD` fails): there is
     no base to branch from or diff against. Offer to make the initial commit first
     (`chore: initial scaffold`, staging the current tree), then cut the task branch. Don't start
     work on an unborn branch — `close`'s diff/merge gate would have nothing to compare.
   - If user knows the branch/PR, ask whether to fill `pr:` now. Otherwise leave null — `/tasks close` will prompt for it later.

8. **Regenerate dashboard** — chain to triage logic.

9. **Hand off to work**:
   - If `assignee:` is a specific agent name (e.g. `CSharpCodingAgent`) → suggest spawning that agent via the Agent tool with the task body as the brief.
   - If `assignee: ai` (generic) → present the task body as the work brief; this conversation can begin work directly.
   - If `assignee: human` → print the task body and wait.
   - **If `jira-key:` is set in frontmatter** → suggest invoking the `jira-task` skill, if one is installed, so the user gets the full ticket workflow (intake → triage → fix → close-out).
   - **If `github-issue:` is set** → fetch comments via `gh issue view <num> --comments` so the AI agent picks up any clarifications added in GH.

## Edge cases

- **No candidates match filters** — print empty result, suggest broadening (`--status todo,blocked` or drop filters).
- **Multiple in-progress by same assignee** — warn ("you already have N tasks in-progress; consider closing one first") but don't block.
- **Task is `blocked`** — confirm intent before flipping to `in-progress` (was it unblocked?).
- **Task is `done` or `cancelled`** — error; suggest `/tasks new` if user wants to redo work.
- **Dependencies not met** — if `depends-on:` lists tasks that aren't `done`, warn but don't block. Print which dependencies are still open.
