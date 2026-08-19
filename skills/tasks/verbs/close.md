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
   - **A section that is ABSENT is not the same as one that says `N/A`, and must never default to
     `review`.** When the task has no `## Human test plan` heading at all, stop and resolve it: either
     write the manual steps, or write `N/A — fully covered by automated tests` **with the reason a human
     adds nothing**. Only then decide `done` vs `review`.
     - Rationale, from a real occurrence: three tasks with every acceptance criterion ticked and full
       automated evidence were closed to `review` because the closer found no plan and treated the
       absence as "sign-off pending". They sat for weeks on a step that did not exist. An explicit `N/A`
       closes straight to `done`; a missing section is indistinguishable from an unrun one to the next
       reader *and* to this gate, so it silently becomes debt.
     - Write the reason, not just the verdict. "N/A" alone is re-litigated by the next person who reads
       the task; "N/A — the tick maths is exported and asserted numerically, so eyeballing the chart adds
       nothing" is not.
   - **Automate before you accept a manual step.** Before *any* step is treated as human-only, prove a
     tool can't assert it — ask of each remaining step: *"can a machine check this instead of a
     person?"* Most can, and parking a mechanically-verifiable step as `[manual]` is how a task closes
     to `review` and then sits there. Pick the right instrument:
     - **Protocol / API / service-layer behaviour** (a handshake, request binding, a round-trip) → a
       script or integration test against the project's test environment.
     - **Anything that only manifests in a rendered UI** (a duplicated event handler firing N times, a
       column bound to the wrong key, a display transform) → a **browser-level** test. A pure-HTTP
       check *cannot* catch these; the defect lives in the rendered output, not the response.
     - Authoring belongs to [[populate-tests]] — chain it. This step is the gate, not the how.
     A step stays `[manual]` **only** when it needs genuine human judgement (visual layout and feel,
     whether copy reads naturally, UX polish) or **physical hardware**. Both are legitimate; "I didn't
     get round to automating it" is not.
     - Wrote the check, ran it green, and **proved it can fail** ([[populate-tests]] § *Prove the guard
       can fail*) → tick the box; it counts toward `done`.
     - Genuine human-judgement / hardware step still unrun → the task closes to `review`, below.
   - If it has real steps with unchecked `[ ]` boxes, **don't close to `done`** — the manual/visual sign-off hasn't happened. Either (a) the user confirms they just ran it → check the boxes and proceed to `done`, or (b) it's not verified yet → set **`status: review`** (code complete, awaiting sign-off), then **park the work properly before skipping ahead**:
     - **Commit the finished work on the task branch** (same staging discipline as step 7) with a message noting the parked state (`TASK-NNN: … (review — human test plan pending)`), and on a PR project **offer to push and open the PR marked "awaiting sign-off"** — `review` is exactly the moment a PR should exist; finished code must never float uncommitted while a human schedules the test.
     - Optionally run the 5b checks now (recommended) so the human tests *reviewed* code; otherwise they run at the eventual re-close.
     - Then **skip to step 10** — the dashboard regen and rollup hints must still run, or `tasks/README.md` keeps claiming `in-progress` while the file says `review`; the whole close-to-`done` path (steps 6–9) is skipped. **Step 9 in particular must not run**: closing the GitHub issue / transitioning the Jira ticket for work whose sign-off hasn't happened tells the remote tracker a lie the local file doesn't. Never mark `done` over an unrun checklist, and never write "done (pending)" — that's what `review` is for. A genuinely `N/A — covered by tests` plan closes straight to `done`.
   - This is the same check `/feature review` runs; closing a task is the per-task enforcement point. (To later move `review → done`, re-run `close` once the human step is checked off.)

5b. **Convention + correctness check — the merge gate** (non-trivial tasks only; skip for docs/renames/one-liners):
   - Run [[verify-conventions]] on the task's diff — does it follow the project's documented rules in `CLAUDE.md § Conventions` (framework/stack, UI/UX, structure, naming, testing)? Address 🛑 blockers before `done`, or note in the task why any are deferred.
   - If the work **introduced a new cross-cutting pattern** (new framework/dependency, UI pattern, layer, naming/testing convention), the register-on-introduce rule applies: confirm `CLAUDE.md § Conventions` (and `## Architecture` if structure changed) was updated in the same change — closing without recording it leaves the rulebook lying. `verify-conventions` flags this.
   - Run [[code-review]] on the working diff for correctness (the existing CLAUDE.md rule). The two are complementary: adherence vs. bugs. `code-review` is runtime-provided (a Claude Code built-in); **if this runtime has no such skill, do the pass inline** — read the diff and check for logic errors, unhandled edge cases, regressions, and security-sensitive changes; address blockers before `done`. Never skip the gate because the skill name didn't resolve.
   - **If the diff touches a security surface, run [[security-review]] on it too** — auth/session
     flows, data access queries, user-input or file/path handling, crypto, secrets/config, a new
     dependency, or a newly exposed endpoint/header. This is *conditional*, not every task: most
     diffs have no security surface and say so in one line. But a task that touches one must not
     reach `done` on a correctness pass alone — `/feature review`'s security pass is optional and
     feature-scoped, so it is not a safety net for this. Same runtime-provided/inline-fallback rule
     as `code-review`; exploitable findings are 🛑 blockers and hold the merge.
   - **Findings outside this task's scope don't block the close and don't get folded in** — the
     review surfacing an adjacent bug or a wanted refactor is a [`/tasks spawn`](spawn.md), not an
     extra commit on this branch. Spawn it, note it in `## Out of scope`, then close on this task's
     own criteria. (Blockers *inside* scope still block.)
   - **If a PR exists** (the PR-per-task default — `pick` cuts a `task/TASK-NNN` branch, `close` is the merge gate), run [[review]] on the PR diff before merging (runtime-provided; no such skill → read `gh pr diff <n>` and run the same correctness pass at PR altitude). **This per-task pass is where code correctness is reviewed, once, at the right altitude** — `/feature review` then only *confirms completeness*, it does **not** re-review the code wholesale.

5c. **Merge decision — settle it BEFORE writing frontmatter** (PR-per-task projects; skip entirely
   when step 8's skip conditions apply — `--no-pr`, non-git, `integration: single-branch`, or not on a
   `task/TASK-NNN` branch):
   - Ask (AskUserQuestion): *"Merge `task/TASK-NNN` into the default branch as part of this close?"*
     Default: **Yes, merge now.** Step 8 executes whichever answer you get; this step only decides,
     so that step 6 knows which status is true.
   - **Why here and not at step 8:** `done` means *merged*. If the frontmatter flips to `done` and
     the merge is then declined, the file claims a state the repo doesn't have, and the commit made
     in step 7 bakes that claim into history. Deferral is known at close time (a stacked PR, an
     external reviewer, a batch-merge policy) — so ask before the write, and the committed status is
     accurate either way.
   - **Deferring is a `blocked` task, not a `done` one.** On *no*, the work is finished but held out
     of the ready pool until the merge can happen — exactly what `blocked` means. Capture the reason
     and, for a stacked PR, the task it waits on; step 6 writes `blocked` instead of `done`.

5d. **Out-of-scope sweep — classify every bullet as a boundary or as work** (tasks only, before the
   status flip). Read the closing task's `## Out of scope` (and any `## Notes`-style aside it grew during
   the work). For each bullet, one of exactly three outcomes:
   - **A boundary** — names another task/epic/feature that owns it, or states a deliberate limit of this
     task. Leave as prose; it is doing its job.
   - **Work** — describes something that should later be done and names no owner. It gets an id **now**:
     offer [`spawn`](spawn.md) (or, for several in one family, one grouped task — see below). Do not close
     with it unowned.
   - **Decided not to do** — rewrite the bullet to say so *and why*, so the next reader finds a decision
     instead of rediscovering the gap.

   **Group rather than fragment.** Several bullets from the same thread that are individually small and
   share a theme belong in **one** task, because splitting them buries the connection that makes them
   cheap to do together; say in that task's body that it is a group and why.

   Why this is a step and not a habit: `## Out of scope` looks like documentation, so an unowned "X is
   also broken" reads as recorded when nothing ranks it — the same defect as a checklist bullet under a
   STORY (SKILL.md § *Findings become tasks*). It surfaces at close because that is when the section is
   complete and when the judgement is cheapest: the work is fresh, and one grouped task costs a minute.
   **A close that adds an unowned work bullet is not done.**

6. **Edit frontmatter FIRST — the state you commit must be the truth** (tasks only):
   - **Merging now (or no merge step applies)** → `status: ... → status: done` (and check any
     acceptance boxes the user just confirmed).
   - **Merge deferred at 5c** → run [`/tasks block`](block.md) instead of flipping to `done`:
     `status: → blocked`, with the reason note (`> Blocked {{today}} — merge deferred: <reason>;
     code complete on task/TASK-NNN`) and `--on <TASK-NNN>` when it's waiting on another task's
     merge. Check the acceptance boxes that are genuinely met — the work *is* done; only the
     integration isn't. Blocking from `in-progress` is why 5c runs before this step: `block`
     refuses to act on a task already flipped to `done`.
     Then continue through steps 7 → 8 → 10 (step 9 is skipped — see its guard).
   - **Never tick a criterion you didn't meet, soften its wording to fit what you did, or delete it.**
     A criterion quietly rewritten to match the outcome is how a task "passes" without doing its job —
     the acceptance list stops being an independent target and becomes a transcript, which is the exact
     failure the "create the task before implementing" rule exists to prevent. An unmet criterion stays
     **visibly unticked**, annotated in place:
     `- [ ] <criterion> — ⚠ NOT MET — split to TASK-NNN`
     Getting there is [spawn.md](spawn.md) § *Scope escalation*: measure it, record the numbers, file
     the residue as its own task, then close on the scope this task genuinely delivered — or don't
     close it. (Rescoping a criterion *before* the work, when the target itself was wrong, is a
     different and legitimate act — correct it and say so; it's rewriting it *afterwards* to fit the
     result that's forbidden.)
   - `pr:` — fill now when the reference already exists (a PR number, or the SHA of an earlier commit). When the reference will be the commit step 7 creates, leave it null here and backfill inside step 7 — never after the merge.
   - Ordering rationale: flipping status *after* the commit means the merged history says `in-progress` forever and the `done` flip floats uncommitted — the tracking files must ride in the same commit as the work. Writing the status *before* the merge is only honest because 5c already settled whether that merge happens; without 5c this step would be committing a guess.

7. **Commit progress / record reference** (tasks only, skip if `--no-pr`):
   - **Is it git-tracked?** Run `git rev-parse --is-inside-work-tree` from the task root. If it's not a git repo (or the command errors), skip this whole step and leave `pr:` as-is.
   - **Anything to commit?** Run `git status --porcelain`. If the tree is clean, don't offer a commit — just optionally ask for an existing PR number / commit SHA (accept empty as skip) and continue.
   - **If there are uncommitted changes, ask the user** (AskUserQuestion) what to do:
     - **Commit the progress now** → stage the work plus the updated task file (already flipped in step 6 — to `done`, or to `blocked` when the merge was deferred at 5c) and create one commit.
       - Message: `{{ID}}: {{task title}}`, mirroring the repo's existing style if there is one (e.g. a `@ <area>:` prefix — check `git log --oneline -5`). **Keep the id in the *subject*, ahead of any other task id it mentions** — a prefix before it is fine. [[specs]] provenance attributes a commit to the task whose id leads its subject and treats an id in the body as a cross-reference, so a subject that buries the id makes this task's work invisible to `shaped-by`. Show the message and the file list before committing.
       - **No `Co-Authored-By:` trailer** (skill convention — see SKILL.md › Conventions).
       - Stage explicitly (the task file + the change set the user confirms) — never blanket `git add -A`, so ignored/stray files don't slip in. Sanity-check `git diff --cached --name-only` before committing.
       - **SHA backfill:** if `pr:` should reference this very commit, write the short SHA into the task file now and stage that one-line edit so it rides in the *merge* (PR-per-task) — or, on a plain single-branch flow, fold it into the commit by amending before anything else references it. Don't leave the backfill dangling uncommitted.
       - Commit to the current branch. The **merge** itself is a separate hard step (step 8, executing the 5c decision) — don't fold it into the commit. A non-git or local-only project skips step 8 and just records the reference.
     - **Reference an existing commit / PR instead** → prompt for a PR number or commit SHA and write it to `pr:` (stage/commit that edit with the close).
     - **Skip** → leave `pr:` null. Accept empty input as skip.

8. **Merge gate — the integration moment** (executes the step 5c decision; runs only when the close commit landed on a `task/TASK-NNN` branch and `--no-pr` not passed):
   - **STOP HERE.** Do not silently advance to step 9 — the close commit is on the task branch, the work is not yet on the default branch, and continuing on the task branch bakes a stale branch-state into the chore refreshes that follow. This step is what makes `done` mean *merged* (a precise state, not "committed somewhere").
   - **5c said merge now:** push if needed, open the PR if one doesn't exist, merge with the project's preferred strategy (default: `--no-ff` so the branch identity is preserved in history; check the project's commit log to confirm), and `git branch -d task/TASK-NNN`. Check out the default branch. Subsequent steps (hybrid remote close, dashboard regen, rollup hints) now run on the default branch — chore refreshes land on `main`, not on a task branch.
     - **The merge failing is a failed close**, not a footnote: on conflict or a rejected push, stop, report it, and leave the task at its pre-close status — don't leave a file reading `done` over a merge that never landed.
   - **5c said defer:** don't merge. The task is already `blocked` (step 6) with the reason recorded, so no state here claims otherwise. Push the branch and open/update the PR if the project uses one — parked work belongs on the remote, not only on a local branch. Then note the resume path: `/tasks unblock {{ID}}` + re-run `close` once the blocker clears; it re-enters here and merges.
   - **Skip silently when:** `--no-pr` was passed, the repo isn't a git repo, the project sets `integration: single-branch` in `.config.yml` (or otherwise has no PR-per-task flow), or the current branch isn't `task/TASK-NNN`. In all these cases, "merge" has no meaningful action, 5c never ran, and step 8 is a no-op. On a `single-branch` project `done` means **committed to the default branch** — the invariant is unchanged, only the mechanism is.

9. **Hybrid mode remote close** — **only when the task actually reached `done`.** Skip for a task
   parked at `review` (step 5) or `blocked` (step 6, merge deferred): the remote tracker must not
   read "closed" for work that isn't signed off or isn't merged. Then check `mode: hybrid` in
   `.config.yml`:
   - `github-issue: <N>` set → run `gh issue close <N> --comment "Closed by {{ID}}"`.
   - `jira-key: <KEY>` set → use the Atlassian MCP to transition the issue to Done (search for the transition tool via ToolSearch first; if MCP isn't authenticated, prompt user). Alternatively, if a `jira-task` skill is installed (an optional, environment-specific skill), hand off to it for that environment's full closure workflow.

10. **Regenerate dashboard**.

11. **Rollup hint** (informational; never auto-close parents):
    - **Ship-moment hints fire on `done` only.** A task parked at `review` or `blocked` (merge
      deferred) still gets the dashboard regen (step 10) and the feature-status refresh below —
      the trees must show its real state — but the *last-open-task* suggestions, the
      `/feature review` prompt, and the changelog nudge stay silent. Nothing has shipped yet;
      suggesting otherwise is how a story gets closed over an unmerged branch.
    - If this task was the last open task in its STORY → suggest `/tasks close <STORY-ID>`.
    - If closing a STORY leaves an EPIC with no open stories → suggest `/tasks close <EPIC-ID>`.
    - But default behaviour for STORY/EPIC is to stay open — areas of concern keep gaining work.
    - **Feature rollup** — any task with `feature: FEATURE-NNN` that changed status here (`done`, parked at `review`, *or* `blocked` on a deferred merge) → chain `/feature status FEATURE-NNN` (single-feature mode) so `status.md` and the index row reflect the new task state; the rollup must never lag a close. If it was the last open task for that feature, also suggest `/feature review FEATURE-NNN`.
    - **Spec regen offer** (STORY close only; when the project has real code but no `docs/specs/.map.yml` **or the map's `areas:` list is empty** — the [[new-project]] scaffold seeds exactly such an empty anchor — print one line — *"no usable spec map — run `/specs init` to bootstrap the spec layer"* — instead of skipping silently): map the story's merged work to spec areas — resolve its tasks' `pr:` commits/PRs to changed files (`git show --name-only <sha>` / `gh pr diff <n> --name-only`) and match them against the `.map.yml` globs; if references are missing, ask which areas. Then **offer** — don't auto-run — `/specs regen <areas> --story STORY-NNN`. The regen's diff review is the "was this behavioral change intended?" check (the [[specs]] skill); an unexpected spec diff at story close is a finding, not churn.
    - **Changelog nudge** (don't auto-run; avoid double-nudging) — only for **task-only work that `/feature review` won't cover**: if the closed item has **no `feature:` link** (a `_loose` task or a feature-less EPIC/STORY) and represents a user-facing change, and the project has a `CHANGELOG.md`, print one line — *"consider `/roll-changelog` to record this for users."* Skip when the task has a `feature:` link (the feature's `/feature review` carries the nudge) or there's no `CHANGELOG.md`. The changelog is human-curated, so suggest, never auto-run.

12. **Confirm** — print (include the step 5d outcome: `out-of-scope: N boundary, M spawned, K declined`,
   so the sweep is visibly accounted for rather than assumed — a gate whose output is invisible when it
   passes is indistinguishable from one that never ran):
    - Which file was updated
    - What changed (`status: todo → done`, `pr: null → 123`)
    - Remote close result if hybrid

## Closing a STORY / EPIC (`--story` / `--epic`)

Container closes are simpler than task closes — no human-test plan, no merge gate (each child task already passed both at its own close). The procedure:

1. **Children-done check** — every child TASK (and, for an epic, every STORY) must be `done`/`cancelled`; otherwise block by default, listing the open children ("STORY-001 has 2 open tasks; close them first or pass `--force`").
2. **Flip `status:` → `done`** in the STORY.md/EPIC.md frontmatter.
3. **Parent rollup** — re-evaluate the parent: a story close may leave its EPIC with no open stories (suggest closing it, per step 11); an epic close ends the chain. Update parent files, not just the leaf.
4. **Regenerate the dashboard** (step 10) and run step 11's hints — for a STORY, that's where the **spec regen offer** fires; the changelog nudge applies only to feature-less containers.
5. **Confirm** (step 12 format).

## Edge cases

- **PR-only close, no GH issue link** — that's fine. `pr:` is just a backreference.
- **GH issue close fails** (e.g. already closed remotely) — log warning, still mark local done.
- **Jira MCP not authenticated** — prompt user to run authentication; pause the verb until they confirm.
- **Closing EPIC with open children** — block by default ("EPIC-001 has 3 open tasks; close them first or pass `--force`").
- **Merge deferred at 5c** — the task ends the close at `blocked`, not `done`, with the reason recorded. It stays out of "Next up", the remote issue stays open, and the ship-moment hints don't fire. Resume with `/tasks unblock {{ID}}` then re-run `close` — it re-enters at step 8 and merges. This is the merge-side mirror of parking at `review` for an unrun Human test plan: both are honest non-completion, neither is `done`.
- **Merge conflict / rejected push at step 8** — the close failed. Report it, leave the task at its pre-close status, and don't let the frontmatter claim `done` over work that never landed on the default branch.
