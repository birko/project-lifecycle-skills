# /tasks migrate — bulk export + switch mode

One-time bulk push of all open work to a remote tracker, then flip `.config.yml` from `local` to `hybrid`.

## Steps

1. **Find task root**. Verify current mode is `local`. If already `hybrid`, abort with hint: "use `/tasks export <ID>` for individual exports".

2. **Parse args**:
   - `--to github` or `--to jira` — required.
   - `--repo owner/name` (GH) or `--project KEY` (Jira) — overrides interactive prompt.
   - `--dry-run` — run steps 1–5 (inventory, plan, the read-only pre-flight) and print, for every item,
     the payload [export.md](export.md) step 5 builds, the Jira priority field included. **Skip steps 6–8**:
     no push, no label or milestone created, no frontmatter written back, no `.config.yml` change, no
     dashboard regeneration. Step 4 puts no question. End with
     `Dry run — nothing pushed; task files and tasks/.config.yml unchanged.` A flag that promises no push
     must leave the tree as it found it, or the next real run starts from a config claiming `hybrid`.
   - `--epic-as=milestone|parent-issue` (GH only) — default `milestone`.

3. **Inventory open work**:
   - All EPICs where status ∈ {`planned`, `in-progress`}
   - All STORIES under them with status ∈ {`planned`, `in-progress`}
   - Every TASK that is not `done` or `cancelled`, reading each status in both forms per [SKILL.md](../SKILL.md) § *Reading a task's status* — a task awaiting verification is open work, and a blocked one keeps its state. A task blocked by either form is exported with its marker (see [export.md](export.md) step 5)
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
     TASK-001 JWT issuance → issue (labels: priority/P1, assignee/agent, epic/auth, story/password-login)
     ...
   Total API calls: ~51
   ```
   Then put this question (never under `--dry-run`, which ends after printing the plan and payloads):

   > **Push these <N> items to <GitHub repo owner/name | Jira project KEY> and switch tasks/.config.yml to `mode: hybrid`? (yes/no)**

   Only `yes` proceeds. **Any other answer, no answer, or nobody to ask:** stop before step 5, push nothing,
   write nothing, and print
   `Not migrated — the confirmation was not answered yes; nothing pushed, tasks/.config.yml still mode: local.`
   A migration creates issues in someone's tracker, so it never runs on a default.

5. **Pre-flight checks**:
   - GH: `gh auth status` passes; `gh repo view <repo>` succeeds.
   - Jira: MCP authenticated; project key resolves.
   - Abort with actionable error if any fail.

6. **Run push in order**, writing IDs back to frontmatter as we go (so the operation is resumable):
   - For each EPIC → create milestone (or parent issue); write `github-issue:` in the parent-issue case.
     **In the milestone case, look the milestone up by its title first** (the format
     [export.md](export.md) § *Exporting STORY or EPIC* gives) with `gh api repos/<repo>/milestones --paginate`,
     and create it only if it is missing. A milestone epic carries no id in its frontmatter, so without the
     lookup a resumed run creates a duplicate.
   - For each STORY → create label or Story (Jira) or just track the slug.
   - For each TASK not yet linked (`github-issue:`/`jira-key:` empty) → run [export.md](export.md) **steps 3–7**
     for that ID, with this run's `--to` and `--repo`/`--project`. Skip export's step 1: its `mode: hybrid`
     check guards a direct call, and the config still reads `local` until step 7 here. Skip step 2: the
     provider and repo/project come from this run's args. Skip step 8: step 8 here regenerates the dashboard
     once. Skip step 9: step 9 here prints its lines for every task. Export step 5 links a task to its epic's
     milestone by title, so the milestones must exist before the tasks go.
   - On any failure: stop, leave already-pushed items linked, print resume hint.

7. **Update `.config.yml`** — flip `mode: local` to `mode: hybrid`, write the chosen provider + repo/project.
   **Only after every step-6 push succeeded.** A failed run leaves `mode: local`, so a re-run passes step 1
   and resumes. Written earlier, a failed run would read `hybrid`, and the re-run would abort at step 1 with
   half the work pushed.

8. **Regenerate dashboard**.

9. **Confirm** — print:
   - Counts (X epics pushed, Y stories, Z tasks), and `<N> tasks linked to milestones`
   - Every line export step 9 would have printed per task, collected across the run: the labels created,
     each task left without a milestone, and each Jira priority-field line
   - URL to the GH project or Jira board
   - "Use `/tasks export <ID>` for new tasks after migration."

## Resumability

If migration fails partway, frontmatter already holds the remote IDs that succeeded. Re-running `/tasks migrate --to <provider>` skips items where `github-issue:`/`jira-key:` is already set — only un-linked items get pushed. A milestone
epic has no such field and is resumed by its milestone's title (step 6). Step 7 never ran on a failed run, so
the config still reads `local` and step 1 lets the re-run through.

## Edge cases

- **Repo/project doesn't exist** — abort with hint to create it first or use `--repo`/`--project` override.
- **Mixed providers desired** (some tasks to GH, some to Jira) — not supported. Run two passes: migrate to one provider, then `/tasks export <ID> --to <other>` individually.
- **Migration of one repo in a polyrepo family** — only migrates that repo's `tasks/`, not the aggregator's. Run separately at the aggregator for cross-cutting epics if needed.
- **Cancel mid-flight** — interrupting after partial push is safe; the next run resumes from where it stopped.
- **`--epic-as=parent-issue`** — the epic becomes an issue, but its tasks are not linked to it as sub-issues.
  This is a known gap; only the milestone case links tasks to their epic.
