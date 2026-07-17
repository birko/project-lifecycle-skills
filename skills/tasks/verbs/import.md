# /tasks import — pull existing work into the task system

Three modes:

| Invocation | Purpose |
|---|---|
| `/tasks import <path>` | Decompose a local TODO/ROADMAP/NOTES file into epics/stories/tasks |
| `/tasks import --github <issue#>` | Pull a GitHub issue into a local TASK file (hybrid mode only) |
| `/tasks import --jira <KEY>` | Pull a Jira ticket into a local TASK file (hybrid mode only) |

## File mode — `/tasks import <path>`

1. **Find task root**. Run mode detection if `.config.yml` is missing.

2. **Read the source file** (TODO.md, ROADMAP.md, NOTES.md — whatever the user points at).

3. **Decompose**:
   - Identify high-level themes / areas of concern → propose as **EPICs**.
   - Identify user-facing behaviours under each theme → propose as **STORIES**.
   - Identify concrete deliverables / line items → propose as **TASKS**.
   - If the file already has explicit hierarchy (nested headings, indented lists), respect it.
   - If it's a flat list, propose a grouping.
   - If the file mixes done/todo items (e.g. checked checkboxes), preserve status — done items become `status: done` tasks.

4. **Present the proposal as a tree** for user review. Use AskUserQuestion to let them confirm or rework. For complex files, do this in batches (one epic at a time).

5. **For each approved item**, run the `/tasks new` flow internally (generate ID, render template, write file). Use defaults (P1 priority, ai assignee, today as created date). Don't re-prompt the user for every field.

6. **Regenerate dashboard**.

7. **Confirm**: print summary — `Imported X epics, Y stories, Z tasks from <path>`.

8. **Don't touch the source file.** Leave TODO.md alone. The user migrates manually if they want; we want a reversible import.

## --github mode (hybrid only)

1. **Require** `mode: hybrid` and `provider: github` in `.config.yml`. Error otherwise with a hint: "switch mode via `/tasks migrate --to github`".

2. **Fetch the issue**:
   ```powershell
   gh issue view <num> --json number,title,body,labels,assignees,state,url,milestone
   ```

3. **Map fields**:
   - Title → file title + slug
   - Body → attempt to split into Context / Acceptance / Out-of-scope. If the body has no recognizable structure, place it all under Context with a TODO marker for the user.
   - Labels → derive priority (label `priority/P0` → P0), assignee (label `agent/CSharpCodingAgent` → assignee), and parent guess (label `epic/<slug>` → look up local EPIC with that slug; if not found, ask user).
   - State `closed` → `status: done`; `open` → `status: todo`.
   - Milestone → can map to EPIC if migration used milestones.
   - Write `github-issue: <num>` in frontmatter.

4. **Create the local TASK file** via the `/tasks new` flow (skip prompts where data is known).

5. **Regenerate dashboard**.

## --jira mode (hybrid only)

1. **Require** `mode: hybrid` and `provider: jira`.

2. **Fetch the issue** via the Atlassian MCP. Search for the read/get-issue tool via ToolSearch (the deferred tool list includes `mcp__claude_ai_Atlassian__*`). Authenticate via `mcp__claude_ai_Atlassian__authenticate` if not yet authed.

3. **Map fields** like `--github` but with Jira semantics:
   - Summary → title
   - Description → split into sections, fallback to Context dump
   - Priority field → P0/P1/P2
   - Assignee → human if a real account, ai if it's a bot
   - Status → todo/in-progress/done mapping
   - Issue type Epic → create local EPIC instead of TASK
   - Issue type Story → create local STORY
   - Issue type Task/Sub-task → create local TASK
   - Write `jira-key: <KEY>` in frontmatter.

4. **Create the local file**.

5. **Consider chaining** to a `jira-task` skill, if one is installed, when the user wants the full ticket workflow (intake → triage → fix → close-out).

6. **Regenerate dashboard**.

## Edge cases

- **Source file already imported** — detect via content hash or by checking if any task references its path; warn before re-importing.
- **GH issue already linked** in another local task — refuse to import a duplicate; show the existing path.
- **No parent epic exists** — for `--github`/`--jira` mode, ask user whether to create a parent or place in `_loose/`.
- **Very long file (>1000 lines)** — read in chunks; propose epics first, drill into each.
