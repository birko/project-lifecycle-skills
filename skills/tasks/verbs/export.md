# /tasks export — push a local task to GH or Jira

Hybrid mode only. Pushes one local TASK (or STORY/EPIC) to the configured remote tracker and writes the returned ID back to frontmatter.

## Steps

1. **Find task root**. Verify `mode: hybrid` in `.config.yml`. Otherwise error: "Run `/tasks migrate --to github|jira` first, or edit `.config.yml` manually."
   This check guards a direct call only. [migrate.md](migrate.md) step 6 runs steps 3–7 here itself, with its
   own provider and repo/project, while the config still reads `local`, because it switches the mode only
   after every push succeeded.

2. **Parse args**:
   - `<ID>` — required (TASK-NNN, STORY-NNN, or EPIC-NNN).
   - `--to github` or `--to jira` — required. Must match `provider:` in config unless `--force-other` is passed.
   - `--dry-run` — render the payload but don't push.

3. **Locate the file** by ID via Grep.

4. **Check link state**:
   - Target is `--to github` and `github-issue:` is already set → ask "already linked to #N — re-export creates a duplicate. Continue?". Default = abort.
   - Same for Jira.

5. **Build the remote payload**:
   - **Title** — TASK title: the first `# Heading` **after the closing `---` of the frontmatter**. The template's
     frontmatter carries `# status — …`, `# blocked: …`, `# findings: …` and `# labels: …` comment lines, and a first-`#`-line
     match takes one of those instead — measured: 14 issues exported as `status — one of: todo, …`
     (FlowerFurStudio #67–#82, 2026-09-26). Check the title before `gh issue create`; one starting with
     `status`, `blocked`, `findings` or `labels` is the comment, not the heading.
   - **Body** — full Context / Acceptance criteria / Out of scope sections. Append a footer linking back to the local file path:
     ```
     ---
     Tracked locally: `tasks/EPIC-001-auth/STORY-001-login/TASK-014-jwt.md` (ID: TASK-014)
     ```
   - **Labels** —
     - `priority/<the task's priority value>`, whatever value it is; never a fixed set of priorities. Send it on
       Jira too, even when the priority field is set below: [import.md](import.md) keeps the label's value unless
       the field was changed in Jira after the label was set, so the label is what carries the value back
     - `assignee/{human|ai}` or `agent/{AgentName}`
     - `epic/{epic-slug}` (the parent epic's slug)
     - `story/{story-slug}` (the parent story's slug, if any)
     - All `default-labels` from `.config.yml`
     - **Blocked** (either form, [SKILL.md](../SKILL.md) § *Lifecycle*) → the tracker's own marker: the label `blocked` on GitHub, the **Flagged** field on Jira. The issue's open/closed state is **never** changed because of it, since a blocked task is still open work. After the
       issue exists, add one comment `Blocked: <reason>`, because a label carries no reason — keep the
       `Blocked:` prefix, since [import.md](import.md) reads the reason back from it. The reason is the
       `blocked:` field's parsed value — without its YAML quotes ([SKILL.md](../SKILL.md) § *Writing a
       `blocked:` value*) — else the text of the task's newest `> Blocked <date> — <reason>` note, else
       `reason unknown`. On Jira, set Flagged instead of a label.
   - **Priority field** (Jira only, a TASK only: a STORY or EPIC has no `priority:`, so leave its field alone
     and print no line for it) — a person reading the ticket sees the field, not the label, so a P0 left at a
     project default of Medium reads as Medium. Read the priorities the project offers for this issue type from
     the Atlassian MCP's create metadata, then set the field by the inverse of [import.md](import.md)'s Jira
     table, first row that matches:

     | When | Set the field to |
     |---|---|
     | the task's value is `P<n>` and the project offers a priority with exactly that name | that priority |
     | the project offers all five of Highest, High, Medium, Low and Lowest, whatever else it offers, and the task's value is P0–P4 | Highest, High, Medium, Low, Lowest in that order |
     | anything else, or the metadata cannot be read, or it has no priority field | nothing: leave the field as the project sets it, and name the task in step 9's confirmation |

     Never pick the nearest name for a value with no row: a guessed field disagrees with the label and reads as
     decided. The label still holds the value, so nothing is lost, and the confirmation says the field does not.
     A value that is not `P<n>` (`priority: High`) never sets the field, even where a priority of that name
     exists: import reads only a `priority/P<n>` label, so it would read the field back and the round trip would
     change the value. `--dry-run` reads the metadata too and shows the field it would set.
   - **Assignee** (GH only) — if `assignee:` is `human` and a GH username is known, set it; otherwise skip.
   - **Milestone** (GH only, a TASK only) — look for the parent epic's milestone in the repo by its title (the
     format § *Exporting STORY or EPIC* gives) and pass that title as `--milestone`. When the repo has none,
     pass nothing and name the task in step 9: `TASK-NNN: no milestone for EPIC-NNN — not linked`. Never
     create a milestone from here: a task export does not create epic-level objects. [import.md](import.md)
     maps a milestone back to its EPIC, so an unlinked task loses its epic on the round trip, and that is why
     the line is printed.

6. **Push**:
   - **GitHub**: the repo is `external.repo` from `.config.yml`. Pass it as `--repo` every time, because a clone
     need not have a remote that names it.
     - **Make sure every label exists first.** `gh issue create` refuses the whole issue when any one label is
       missing, and a repo has none of this skill's labels until something creates them. Measured: on a repo
       with only GitHub's default labels, the create failed on `priority/P3` and no issue was made. So list the
       repo's labels (`gh label list --repo <repo> --limit 1000`), create each missing one
       (`gh label create <name> --repo <repo>`), and name every label created in step 9's confirmation, since
       it is a change to someone's repo.
     ```powershell
     gh issue create --repo <repo> --title "<title>" --body-file <file> --label "<labels-csv>" [--assignee <user>] [--milestone "<title>"]
     ```
     Write the body to a temporary file and pass `--body-file`; a multi-line `--body` does not survive every
     shell. Delete the file afterwards.
     Capture the returned issue URL/number (parse with `--json` or stdout).
   - **Jira**: use the Atlassian MCP `createIssue` (or equivalent) — search via ToolSearch first. Authenticate if needed. Capture the returned key.

7. **Write link back to frontmatter**:
   - GH: `github-issue: <num>`
   - Jira: `jira-key: <KEY>`

8. **Regenerate dashboard**.

9. **Confirm** — print:
   - Local path
   - Remote URL
   - Labels applied, and any label this run created
   - The milestone linked, or the `no milestone … not linked` line from step 5
   - On Jira, `Jira priority field: <the priority set>`, or, when step 5 left it unset,
     `TASK-NNN: Jira priority field left at the project default (<no matching priority | metadata unreadable | no priority field>); the label priority/<value> carries it`

## Exporting STORY or EPIC

- **GitHub**:
  - STORY → create a parent issue with `kind/story` label, OR just a `story/<slug>` label that tasks reference. Default = label-only.
  - EPIC → create a Milestone (recommended) OR a parent issue with sub-issues. Default = Milestone; ask if user prefers parent-issue.
    **A milestone is titled `<EPIC-ID> <epic title>`** (`EPIC-001 Authentication`). Step 5 and
    [migrate.md](migrate.md) step 6 find it by this title, since a milestone epic carries no id in its
    frontmatter.
- **Jira**:
  - STORY → Story issue type
  - EPIC → Epic issue type, with `Epic Link` set on child stories/tasks when they export

## Edge cases

- **No `gh` CLI installed / not authenticated** — print install hint, abort.
- **GH issue creation fails (network, permissions)** — leave frontmatter untouched, surface error to user.
- **Provider mismatch** (config says github but `--to jira`) — error unless `--force-other`; then ask user if they want to flip config.
- **Body too large** — GH has body length limits; truncate body with a "(continued in local file)" note before pushing.
