# /tasks export — push a local task to GH or Jira

Hybrid mode only. Pushes one local TASK (or STORY/EPIC) to the configured remote tracker and writes the returned ID back to frontmatter.

## Steps

1. **Find task root**. Verify `mode: hybrid` in `.config.yml`. Otherwise error: "Run `/tasks migrate --to github|jira` first, or edit `.config.yml` manually."

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
     frontmatter carries `# status — …`, `# findings: …` and `# labels: …` comment lines, and a first-`#`-line
     match takes one of those instead — measured: 14 issues exported as `status — one of: todo, …`
     (FlowerFurStudio #67–#82, 2026-09-26). Check the title before `gh issue create`; one starting with
     `status`, `findings` or `labels` is the comment, not the heading.
   - **Body** — full Context / Acceptance criteria / Out of scope sections. Append a footer linking back to the local file path:
     ```
     ---
     Tracked locally: `tasks/EPIC-001-auth/STORY-001-login/TASK-014-jwt.md` (ID: TASK-014)
     ```
   - **Labels** —
     - `priority/<the task's priority value>`, whatever value it is; never a fixed set of priorities
     - `assignee/{human|ai}` or `agent/{AgentName}`
     - `epic/{epic-slug}` (the parent epic's slug)
     - `story/{story-slug}` (the parent story's slug, if any)
     - All `default-labels` from `.config.yml`
     - **Blocked** (either form, [SKILL.md](../SKILL.md) § *Lifecycle*) → the tracker's own marker: the label `blocked` on GitHub, the **Flagged** field on Jira. The issue's open/closed state is **never** changed because of it, since a blocked task is still open work. After the
       issue exists, add one comment `Blocked: <reason>`, because a label carries no reason. The reason is the
       `blocked:` field, else the text of the task's newest `> Blocked <date> — <reason>` note, else
       `reason unknown`. On Jira, set Flagged instead of a label.
   - **Assignee** (GH only) — if `assignee:` is `human` and a GH username is known, set it; otherwise skip.

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
     gh issue create --repo <repo> --title "<title>" --body-file <file> --label "<labels-csv>" [--assignee <user>]
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

## Exporting STORY or EPIC

- **GitHub**:
  - STORY → create a parent issue with `kind/story` label, OR just a `story/<slug>` label that tasks reference. Default = label-only.
  - EPIC → create a Milestone (recommended) OR a parent issue with sub-issues. Default = Milestone; ask if user prefers parent-issue.
- **Jira**:
  - STORY → Story issue type
  - EPIC → Epic issue type, with `Epic Link` set on child stories/tasks when they export

## Edge cases

- **No `gh` CLI installed / not authenticated** — print install hint, abort.
- **GH issue creation fails (network, permissions)** — leave frontmatter untouched, surface error to user.
- **Provider mismatch** (config says github but `--to jira`) — error unless `--force-other`; then ask user if they want to flip config.
- **Body too large** — GH has body length limits; truncate body with a "(continued in local file)" note before pushing.
