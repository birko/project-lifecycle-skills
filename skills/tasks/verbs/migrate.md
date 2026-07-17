# /tasks migrate — bulk export + switch mode

One-time bulk push of all open work to a remote tracker, then flip `.config.yml` from `local` to `hybrid`.

## Steps

1. **Find task root**. Verify current mode is `local`. If already `hybrid`, abort with hint: "use `/tasks export <ID>` for individual exports".

2. **Parse args**:
   - `--to github` or `--to jira` — required.
   - `--repo owner/name` (GH) or `--project KEY` (Jira) — overrides interactive prompt.
   - `--dry-run` — show plan + payloads, push nothing.
   - `--epic-as=milestone|parent-issue` (GH only) — default `milestone`.

3. **Inventory open work**:
   - All EPICs where status ∈ {`planned`, `in-progress`}
   - All STORIES under them with status ∈ {`planned`, `in-progress`}
   - All TASKS with status ∈ {`todo`, `in-progress`, `blocked`}
   - `_loose/` tasks too.
   - Skip anything `done` / `cancelled` — history stays local.

4. **Show the plan** to the user before any push:
   ```
   Plan:
     5 EPICs → GitHub milestones
     12 STORIES → labels (story/<slug>)
     34 TASKs → issues
   First 3 examples:
     EPIC-001 Authentication → milestone "EPIC-001 Authentication"
     TASK-001 JWT issuance → issue (labels: priority/P1, assignee/ai, epic/auth, story/password-login)
     ...
   Total API calls: ~51
   Proceed? (y/n)
   ```
   Confirm before pushing anything.

5. **Pre-flight checks**:
   - GH: `gh auth status` passes; `gh repo view <repo>` succeeds.
   - Jira: MCP authenticated; project key resolves.
   - Abort with actionable error if any fail.

6. **Run push in order**, writing IDs back to frontmatter as we go (so the operation is resumable):
   - For each EPIC → create milestone (or parent issue); write `github-issue:` (parent-issue case) or just track the milestone number for child tasks.
   - For each STORY → create label or Story (Jira) or just track the slug.
   - For each TASK → run the `/tasks export` logic for that ID with the chosen provider.
   - On any failure: stop, leave already-pushed items linked, print resume hint.

7. **Update `.config.yml`** — flip `mode: local` to `mode: hybrid`, write the chosen provider + repo/project.

8. **Regenerate dashboard**.

9. **Confirm** — print:
   - Counts (X epics pushed, Y stories, Z tasks)
   - URL to the GH project or Jira board
   - "Use `/tasks export <ID>` for new tasks after migration."

## Resumability

If migration fails partway, frontmatter already holds the remote IDs that succeeded. Re-running `/tasks migrate --to <provider>` skips items where `github-issue:`/`jira-key:` is already set — only un-linked items get pushed.

## Edge cases

- **Repo/project doesn't exist** — abort with hint to create it first or use `--repo`/`--project` override.
- **Mixed providers desired** (some tasks to GH, some to Jira) — not supported. Run two passes: migrate to one provider, then `/tasks export <ID> --to <other>` individually.
- **Migration of one repo in a polyrepo family** — only migrates that repo's `tasks/`, not the aggregator's. Run separately at the aggregator for cross-cutting epics if needed.
- **Cancel mid-flight** — interrupting after partial push is safe; the next run resumes from where it stopped.
