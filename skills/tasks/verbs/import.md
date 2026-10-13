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
   - Label `blocked` → a `blocked:` field, never a status. Its reason is the text of the newest comment
     starting `Blocked:`, or `reason unknown`, written as [SKILL.md](../SKILL.md) § *Writing a `blocked:`
     value* says. The status comes from the state line above, as for any issue.
   - Milestone → can map to EPIC if migration used milestones.
   - Write `github-issue: <num>` in frontmatter.

4. **Create the local TASK file** via the `/tasks new` flow (skip prompts where data is known).

5. **Regenerate dashboard**.

## --jira mode (hybrid only)

1. **Require** `mode: hybrid` and `provider: jira`.

2. **Fetch the issue** via the Atlassian MCP, **with its changelog** (the REST `expand=changelog`, or the tool's equivalent), which step 3 reads for priority. Search for the read/get-issue tool via ToolSearch (the deferred tool list includes `mcp__claude_ai_Atlassian__*`). Authenticate via `mcp__claude_ai_Atlassian__authenticate` if not yet authed.

3. **Map fields** like `--github` but with Jira semantics:
   - Summary → title
   - Description → split into sections, fallback to Context dump
   - Priority → a `P<n>` value, never a fixed set. Collapsing every lower level into P2 files a P3
     as more urgent than it is, and nothing in the result shows that it happened. **With no `priority/P<n>`
     label, map the field** by the table below. **With one**, map the field too, and compare, first row that
     matches. Several `priority/P<n>` labels with different values count as no label, and step 7 reports
     `ABC-3: several priority labels (priority/P1, priority/P3); read the field`.

     | Label and field | Write | Report in step 7 |
     |---|---|---|
     | the field is empty, or has no mapping (third row of the next table) | the label's value, without that row's Context line | `ABC-3: field "Blocker" has no mapping; wrote P3 from the label priority/P3` (`field empty` for an empty one) |
     | the field maps to the label's value | that value | nothing |
     | they differ, and the changelog's last priority change is later than the change that added the label (the issue's creation, when the label was there from the start) | the field's mapped value: someone, or an automation, set it in Jira after the label | `ABC-3: priority changed in Jira after the label was set (label priority/P3, field "Highest"); wrote P0` |
     | they differ otherwise: no priority change after the label, or the changelog cannot be read | the label's value | `ABC-3: label priority/P3 and field "Medium" disagree; wrote P3 from the label` (add `, changelog unreadable` when it was) |

     Why the changelog and not the field: [export.md](export.md) sets the field only when the project has a
     matching priority, and exports from before it did never set it, so a field that disagrees with its label
     is normal on a ticket nobody touched. Only a priority change made after the label was set shows that
     someone chose the field over it. The changelog records label changes as well as priority changes, so
     the comparison does not depend on how the ticket was created. Neither value is ever dropped silently: a
     disagreement is always reported, whichever side was written.

     The field's mapping:

     | The Jira priority | Write |
     |---|---|
     | already named `P<n>` (a scheme renamed to P0, P1, …) | that value as given |
     | a name from Jira's default scheme: Highest, High, Medium, Low, Lowest | P0, P1, P2, P3, P4 in that order |
     | any other name, or no priority and no label | `P1`, `new`'s default, and a line in the task's `## Context`: `Jira priority "<name>" has no mapping; P1 is the default, nobody chose it`. Name the task in step 7's confirmation |

     The field cannot be left absent, because every ranking reads it, so an unmapped value gets the fallback
     and the record that nobody chose it, never a guess at what the name means.
   - Assignee → human if a real account, ai if it's a bot
   - Status → todo/in-progress/done mapping
   - Flagged → a `blocked:` field with the reason from the newest `Blocked:` comment, or `reason unknown`, written as the GitHub row above says; never a status
   - Issue type Epic → create local EPIC instead of TASK
   - Issue type Story → create local STORY
   - Issue type Task/Sub-task → create local TASK
   - Write `jira-key: <KEY>` in frontmatter.

4. **Create the local file**.

5. **Consider chaining** to a `jira-task` skill, if one is installed, when the user wants the full ticket workflow (intake → triage → fix → close-out).

6. **Regenerate dashboard**.

7. **Confirm**: print the created file's path and its `jira-key:`, and under it every ticket that got step 3's P1
   fallback, as `ABC-3: Jira priority "Blocker" has no mapping; wrote P1, nobody chose it`, and every
   label and field that disagreed, in the line step 3's comparison table gives. A ticket with a label never gets the
   fallback line: the label's value was written.

## Edge cases

- **Source file already imported** — detect via content hash or by checking if any task references its path; warn before re-importing.
- **GH issue already linked** in another local task — refuse to import a duplicate; show the existing path.
- **No parent epic exists** — for `--github`/`--jira` mode, ask user whether to create a parent or place in `_loose/`.
- **Very long file (>1000 lines)** — read in chunks; propose epics first, drill into each.
