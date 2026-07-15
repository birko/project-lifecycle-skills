# /tasks audit — scan the backlog for quality problems

Analyze every task and report duplicates, mergeable/splittable items, stale work, broken links, and incomplete tasks. **Read-only by default** — it proposes, it does not mutate. `triage` *renders* the backlog; `audit` *critiques* it.

## Args

- `--fix` — after showing findings, walk through applying the **safe** ones interactively (one confirmation each). Without it, the verb is report-only.
- `--scope <EPIC-NNN|STORY-NNN>` — restrict the audit to one subtree (default: whole backlog).
- `--checks <a,b,...>` — run only named checks (default: all). Names below.

## Steps

1. **Run the [Collection pass](../SKILL.md#collection-pass)** — reuse it; don't re-enumerate. You get every task's frontmatter (`id`, `parent`, `feature`, `status`, `priority`, `depends-on`, `blocks`, `created`), title, and the `byParent` map. Also read each task's body (Context / Acceptance criteria / Human test plan) — needed for the content checks.

2. **Run the checks** and collect findings, each tagged with a severity (🔴 act now / 🟡 consider / ⚪ FYI):

   | Check (name) | Detects | Method | Severity |
   |---|---|---|---|
   | `duplicates` | near-identical tasks | heuristic **surfaces candidates**, your reading **decides**. Normalize title + acceptance + Context to lowercase token sets, score Jaccard. Cast a WIDE net: surface any pair above ~0.4 **acceptance/Context** overlap (titles are unreliable — real dups use synonyms like "login"/"sign-in", "issue"/"issuance", so a low title score does NOT clear a pair). False positives are cheap in a report; misses are not. For every surfaced pair, **read both and judge by meaning** — the score is a candidate generator, not the verdict. Report both the score and your semantic judgment. No embeddings/LLM scoring needed — you have both texts. | 🔴 |
   | `mergeable` | distinct but should be one task | same `parent`, high acceptance overlap. **Crucial disambiguation:** when acceptance overlaps heavily but the titles differ by a *qualifier* (client/server, sync/async, create/update, read/write, frontend/backend, v1/v2), it is **mergeable-or-distinct, NOT a kill-one duplicate** — never propose cancelling one. Either fold into a single task or keep both; let the human decide. | 🟡 |
   | `splittable` | one task hiding several | ≥6 acceptance items, or title with multiple "and"/"+" clauses, or Context spanning unrelated areas | 🟡 |
   | `stale` | abandoned work | `status: todo`/`in-progress`, `created` far in the past (>~60 days as a default heuristic — compare to today's date), no `pr`/movement | 🟡 |
   | `broken-links` | dangling references | `depends-on`/`blocks`/`parent`/`feature:` pointing at an ID that doesn't exist, or `depends-on` a task already `done`/`cancelled` (→ unblock candidate) | 🔴 |
   | `cycles` | circular deps | walk `depends-on` graph; report any A→…→A cycle | 🔴 |
   | `incomplete` | not pick-ready | empty/placeholder Acceptance criteria, or `## Human test plan` still holding the template placeholder text (neither real steps nor an explicit `N/A`) | 🟡 |
   | `orphans` | structural gaps | task in `_loose/` that clearly belongs under an existing epic/story; `feature:` set but no such `docs/features/FEATURE-NNN/` | ⚪ |

   > **Cross-tree drift is out of scope here.** `audit` critiques the `tasks/` tree *internally* (the row above catches a `feature:` pointing at a missing folder). Drift *between* the two trees — a feature whose phase contradicts its tasks, or a task missing its `feature:` back-link though its feature is decided — is owned by [[roadmap]]; run `/roadmap --check`. Don't reimplement those divergence rules in audit.

3. **Render the report** to stdout, grouped by check, severity-sorted. For each finding give the task IDs, the evidence (e.g. the overlapping acceptance lines, the confidence %), and a concrete **suggested action**. Example:

   ```
   /tasks audit — 34 tasks scanned

   🔴 Duplicates (1)
     TASK-012 "JWT issuance on login" ↔ TASK-031 "Issue JWT at sign-in"
       title overlap only 13%, but acceptance criteria are semantically identical
       → merge TASK-031 into TASK-012  (high confidence by meaning; run `/tasks audit --fix`)

   🔴 Broken links (1)
     TASK-019 depends-on TASK-004, which is done
       → unblock TASK-019

   🟡 Splittable (1)
     TASK-027 has 7 acceptance items spanning auth + logging + UI
       → split into 2–3 tasks

   🟡 Incomplete (3)
     TASK-022, TASK-028, TASK-040 — Human test plan still has placeholder text

   ⚪ Orphans (1)
     TASK-007 in _loose/ overlaps EPIC-002 (Caching)
       → reparent under EPIC-002

   Run with --fix to apply the 3 safe findings (1 merge, 1 unblock, 1 reparent).
   ```

4. **If `--fix`** — walk the **safe** findings only, one at a time, each gated by an explicit confirm. Safe = reversible/non-destructive:
   - **Merge** → set the absorbed task `status: cancelled`, append a body line `> Merged into TASK-NNN on <today>` (and copy any unique acceptance items into the survivor). **Never delete the file** — keeps the audit trail, mirrors how `decisions.md` never deletes rows.
   - **Unblock** → remove the satisfied (done) ID from the dependent's `depends-on`.
   - **Reparent** → move the file under the suggested epic/story folder, fix `parent:`.
   - **NOT auto-fixed** (judgment/destructive): splits, dependency cycles, staleness verdicts, ambiguous dedup pairs below high confidence — these are reported for the human/agent to resolve manually.
   - After fixes, **regenerate the dashboard** ([triage](triage.md)).

5. **Hybrid mode note** — if a merged/cancelled task has a `github-issue:`/`jira-key:`, remind the user the remote issue should be closed too (offer to run the close, don't do it silently).

6. **Confirm** — print the counts (findings by severity, fixes applied if `--fix`).

## Notes

- **Suggest-only is the default for a reason** — merging tasks loses work context if done carelessly. The report gives the agent enough to judge; `--fix` only touches the reversible operations.
- **Dedup: heuristic surfaces, you decide.** Token overlap is a candidate generator, not the verdict — it misses synonym dups (low title score ≠ not a dup) and over-flags qualifier-distinct pairs (identical acceptance with client/server titles ≠ dup). So: cast a wide net on acceptance/Context overlap, then read every surfaced pair and classify by *meaning* into duplicate (kill one) vs mergeable vs keep-separate. Always show the score AND your judgment so the reader can dismiss false positives. Never propose cancelling a task whose only overlap is acceptance text while its title carries a distinguishing qualifier.
- **Date math** — "today" comes from the runtime/system date; staleness threshold is a heuristic default (~60 days), mention it in the report so it's not mistaken for a hard rule.
- Pairs well with [[feature]] `decompose` — that's where duplicate tasks are most often born (a decision overlapping an existing task). Running `/tasks audit --scope EPIC-NNN` after decomposing a feature is a good habit.

## Edge cases

- **Empty/tiny backlog** — `< 2` tasks → "nothing to audit yet." Skip silently.
- **No findings** — print "✅ backlog is clean — no duplicates, broken links, or incomplete tasks found." Don't invent findings to look useful.
- **`--fix` with zero safe findings** — report the unsafe findings and note there's nothing to auto-apply.
- **Cancelled tasks** — exclude from duplicate/stale/incomplete checks (they're already resolved), but still honor them as valid `depends-on` *satisfied* targets in broken-links.
