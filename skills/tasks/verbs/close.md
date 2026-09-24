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
   - `--unattended` — **no user is present to answer anything.** Passed by [[fix-next]], which drives
     this verb as its merge gate. It is a **declared** flag and never inferred: whether a human is
     watching is not readable from the repo, and a close that guesses wrong either hangs on an offer
     nobody can take or silently drops work.
     **Every step below that can stop for input defines its unattended behaviour, and this list is the
     contract** — a flag that promises "nobody is present" while one step still asks is worse than no
     flag, because the run blocks in the one configuration nobody tested:

     | Step | Interactive | `--unattended` |
     |---|---|---|
     | 4 | already `done`/`cancelled` → ask "reopen and re-close?" | **refuse and report.** Never silently reopen a closed record |
     | 5 | unfilled plan → "confirm it's `N/A` or fill it", user proceeds or pauses | **resolve it**: write the steps, or `N/A` with the reason. Real unrun manual steps ⇒ `review`, never `done` |
     | 5 (`review` park) | offer to push and open the PR "awaiting sign-off" | **push and open it.** And run **5d before parking** |
     | 5c | ask "merge as part of this close?" | **merge.** See the note in 5c for why, and what was rejected |
     | 5d | work bullet → offer `spawn` | **spawn** it; *decided not to do* is unavailable |
     | 7 (dirty tree) | ask commit / reference / skip | **commit**, with step 7's explicit staging — never blanket `git add -A` |
     | 7 (clean tree) | optionally ask for an existing PR / SHA | **skip it**; leave `pr:` as-is |
     | 11 spec regen | if `pr:` references are missing, ask which areas | **skip the regen and say so.** Guessing an area writes a spec diff nobody asked for |
     | Jira not authenticated | prompt, and pause until confirmed | **skip the remote step and report it.** An unattended run cannot authenticate |
     | 5b [[review-comments]] | an only-copy finding asks whether to file its content and leave a pointer | **no answer is given, and that is already the right outcome** — the skill's own answer-less path leaves the comment untouched, creates nothing, and reports the finding `unresolved` with the unanswered question. So **no flag is passed and none is needed**: `review-comments` deliberately declares no `--unattended`, because a flag asserting an absent capability with no step of its own to govern is the defect § *A flag that declares an absent capability* names. What this row forbids is the tempting shortcut — deleting the comment because nobody was there to object, or dropping the finding so the report reads clean |
     | 4b, 8 (worktree close and its tail), 10b | nothing is asked — every failure prints its line and stops, and a landed merge that cannot be tidied prints its outstanding commands | **nothing is asked**; each failure prints its line and stops. Recorded rather than assumed, for the reason the next row gives |
     | 5b [[verify-intent]] | its no-task branch asks what the change was meant to do | **cannot fire here** — a close always supplies the closing task, so its intent source is resolved. Recorded rather than assumed: adding a pass that *can* ask into a step this flag governs is how the gap this table exists to close would come back |

     **Step 7 is the row that matters most, and the first version of this table omitted it.** Step 6 has
     just rewritten the task's frontmatter, so `git status --porcelain` is *never* clean when step 7
     runs — the ask fired on **every** unattended close, on every project shape, including the
     `single-branch` repos that never reach 5c. A flag whose contract table omits the one ask that always
     fires is worse than no flag. **An ask reachable under `--unattended` and absent from this table is a
     defect in the table, not a judgement call to improvise at runtime.**

3. **Locate the file** — Grep `^id: TASK-NNN$` (or STORY/EPIC variant) across `tasks/`. If not found, suggest `/tasks triage` to refresh dashboard.

4. **Read current status**:
   - **Except: `done` read in the task's own worktree while the default branch's copy of the file still
     reads otherwise** is an unmerged close — an earlier run committed `done` on the task branch and then
     failed at the merge. It is not a closed record: go straight to step 8's worktree merge, asking
     nothing, under `--unattended` too.
   - Already `done` → warn, ask "reopen and re-close?" or abort.
   - `cancelled` → warn similarly.
   - **`--unattended` → refuse and report; do not reopen.** Reaching here means something upstream is
     wrong — [[fix-next]]'s step 0 resume exists precisely so a drain never re-picks a closed task — and
     silently reopening a closed record to re-close it would erase the evidence of that.

4b. **Where this close runs** (tasks in a git repo). Settle it **before anything is written**: steps
   5–7 commit on the task branch, and a close that fails must leave that branch untouched. Work from
   evidence, recomputed every run — never from memory of where `pick` put things:
   - **In a linked worktree** means `git rev-parse --path-format=absolute --git-dir` differs from
     `--git-common-dir`. **The main copy** is the first `worktree` entry of `git worktree list --porcelain` —
     git always lists it first, whereas the parent of the common dir is wrong under `--separate-git-dir`.

   | Where | Do |
   |---|---|
   | main copy, and no **linked** worktree holds `task/TASK-NNN` (the main copy's own entry in the list does not count — on an in-place close it is the one on that branch) | today's flow — nothing below applies |
   | a linked worktree on `task/TASK-NNN` | the **worktree close**: check the main copy now, then steps 5–7 here, and step 8's worktree branch |
   | a linked worktree on any other branch | the **wrong-tree** line; stop, nothing written |
   | main copy, while a `git worktree list --porcelain` entry **other than the first** shows `branch refs/heads/task/TASK-NNN` | the **held-elsewhere** line; stop, nothing written. Closing from a new session means re-entering that worktree, which is the resume path's business, not something to improvise here |

   **Worktree close — check the main copy before writing.** `git -C "<main>" status --porcelain` must be
   empty, `git -C "<main>" symbolic-ref --short HEAD` must be the default branch, and that branch must
   track **no remote** — the rule and reason `pick` step 6b gives; a tracked default branch gets the
   **unsupported** line and a stop, nothing written. The merge happens there. Either fails → the **failed-close** line: nothing written, status unchanged, worktree and
   branch untouched. Steps 5–7 then edit and commit **in the worktree, on the task branch**, and the
   merge carries `done` to the default branch — the branch forks from `pick`'s own commit, and the
   default branch never touches this task file after it, so the status line merges cleanly. **Never
   regenerate `tasks/README.md` in the worktree**: every task branch rewriting one generated file is a
   conflict per parallel task. Steps 10–11 regenerate it on the default branch after the merge instead.

5. **Verify the Human test plan** (tasks only):
   - Read the `## Human test plan` section. If it still holds the template placeholder text (un-filled), warn: "Human test plan was never filled — confirm it's genuinely `N/A` or fill it before closing." Let the user proceed or pause.
     - **`--unattended` → resolve it rather than proceeding past it**, exactly as the absent-section rule
       below requires: write the manual steps the task actually needs, or write `N/A` with the reason a
       human adds nothing. If real manual steps exist and have not been run, the close lands at
       `review`. "Proceed anyway" is not an unattended option — it is how a task reaches `done` with its
       verification neither run nor recorded.
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
     **A step that stays manual because the product *is* prose has its own instrument** — a cold drill,
     [[populate-tests]] § *The cold drill*: the instructions executed by a reader denied the expected
     answer, because an author cannot un-know their own intent. That section owns the brief's shape,
     the fixture-contamination rule and the warranted-when test; this step only requires that a manual
     step which qualifies actually gets it rather than a re-read by the author.
     A step stays `[manual]` **only** when it needs genuine human judgement (visual layout and feel,
     whether copy reads naturally, UX polish) or **physical hardware**. Both are legitimate; "I didn't
     get round to automating it" is not.
     - Wrote the check, ran it green, and **proved it can fail** ([[populate-tests]] § *Prove the guard
       can fail*) → tick the box; it counts toward `done`.
     - Genuine human-judgement / hardware step still unrun → the task closes to `review`, below.
   - If it has real steps with unchecked `[ ]` boxes, **don't close to `done`** — the manual/visual sign-off hasn't happened. Either (a) the user confirms they just ran it → check the boxes and proceed to `done`, or (b) it's not verified yet → set **`status: review`** (code complete, awaiting sign-off), then **park the work properly before skipping ahead**:
     - **Commit the finished work on the task branch** (same staging discipline as step 7) with a message noting the parked state (`TASK-NNN: … (review — human test plan pending)`), and on a PR project **offer to push and open the PR marked "awaiting sign-off"** — `review` is exactly the moment a PR should exist; finished code must never float uncommitted while a human schedules the test. **`--unattended` → do it rather than offer it**; the reason the offer exists is that finished code must not float, and that is not weaker when nobody is watching.
     - Optionally run the 5b checks now (recommended) so the human tests *reviewed* code; otherwise they run at the eventual re-close.
     - **Run step 5d before parking.** The out-of-scope sweep is not part of the close-to-`done` path and must not be skipped with it — parking at `review` with unowned work bullets is the evaporation 5d exists to stop, and it is worse here than at a `done` close, because nobody returns to a `review` task's Out of scope section. This was ambiguous before: "skip to step 10" reads as skipping 5d too, since 5d sits between 5c and 6, while the same sentence said only steps 6-9 were skipped.
     - **A worktree close (step 4b) first runs step 8's kept bullet** — commit in the worktree, keep it, name it. Then **skip to step 10** — the dashboard regen and rollup hints must still run, or `tasks/README.md` keeps claiming `in-progress` while the file says `review`; the whole close-to-`done` path (steps 6–9) is skipped. **Step 9 in particular must not run**: closing the GitHub issue / transitioning the Jira ticket for work whose sign-off hasn't happened tells the remote tracker a lie the local file doesn't. Never mark `done` over an unrun checklist, and never write "done (pending)" — that's what `review` is for. A genuinely `N/A — covered by tests` plan closes straight to `done`.
   - This is the same check `/feature review` runs; closing a task is the per-task enforcement point. (To later move `review → done`, re-run `close` once the human step is checked off.)

5b. **The review axes — the merge gate** (non-trivial tasks only; skip for docs/renames/one-liners):
   - Run [[verify-conventions]] on the task's diff — does it follow the project's documented rules in `CLAUDE.md § Conventions` (framework/stack, UI/UX, structure, naming, testing)? Address 🛑 blockers before `done`, or note in the task why any are deferred.
   - If the work **introduced a new cross-cutting pattern** (new framework/dependency, UI pattern, layer, naming/testing convention), the register-on-introduce rule applies: confirm `CLAUDE.md § Conventions` (and `## Architecture` if structure changed) was updated in the same change — closing without recording it leaves the rulebook lying. `verify-conventions` flags this.
   - Run [[verify-intent]] on the diff against this task's `## Acceptance criteria` — did it build what
     was asked? **Unconditional** for every task reaching this step, and that is the deliberate contrast
     with [[security-review]] below: security is conditional because most diffs have no security surface
     to test for, whereas *every* task has acceptance criteria, so there is no condition to evaluate — a
     task with nothing to check against is a task whose criteria need writing, which is a finding in
     itself. Repo-shipped rather than runtime-provided, so **if the name doesn't resolve, do the pass
     inline** (read the criteria, judge each against the diff, never against its checkbox) — same rule as
     `code-review`: never skip the gate because a skill didn't resolve. A consumer who added the skill
     folder without re-running an installer is the common cause.
   - **Every axis is reported side by side and never merged or reranked into one list.** A change can
     follow every documented standard while implementing the wrong thing, or do exactly what was asked
     while breaking the rulebook. One ordered list lets a convention warning sit above an unbuilt
     requirement and read as the larger problem — so: **one verdict per pass that ran**, each with its own
     findings and its own severity ordering, and nothing sorted across them.
     - **Count the verdicts off the passes that ran, never off a number written here.** Standards,
       fidelity and correctness run unconditionally; [[security-review]] runs **when the diff touches a
       security surface**, and [[review-comments]] **when the diff carries a comment**. A conditional pass still gets its own verdict when it runs,
       and when it does not, the report says *not applicable* and why in one line: silence cannot be told
       apart from a pass that was skipped.
     - Why this is phrased as a rule rather than a count: an earlier version of this step hard-coded the
       number, [[verify-intent]] later arrived as an additional axis, and the arity prose was never updated —
       so the step's own heading listed more passes than its rule demanded verdicts, and a closer following
       the text had documented permission to drop one. A hard-coded count is a fact that rots; the number of
       passes that actually ran is not.
   - Run [[code-review]] on the working diff for correctness (the existing CLAUDE.md rule). The two are complementary: adherence vs. bugs. `code-review` is runtime-provided (a Claude Code built-in); **if this runtime has no such skill, do the pass inline** — read the diff and check for logic errors, unhandled edge cases, regressions, and security-sensitive changes; address blockers before `done`. Never skip the gate because the skill name didn't resolve.
   - **If the diff touches a security surface, run [[security-review]] on it too** — auth/session
     flows, data access queries, user-input or file/path handling, crypto, secrets/config, a new
     dependency, or a newly exposed endpoint/header. This is *conditional*, not every task: most
     diffs have no security surface and say so in one line. But a task that touches one must not
     reach `done` on a correctness pass alone — `/feature review`'s security pass is optional and
     feature-scoped, so it is not a safety net for this. Same runtime-provided/inline-fallback rule
     as `code-review`; exploitable findings are 🛑 blockers and hold the merge.
   - **Run [[review-comments]] on the task's diff — its own axis, whenever the diff carries a comment.**
     One question the other passes do not ask: does a comment this change added or touched carry content
     that already lives somewhere else? `verify-conventions` lints the diff against the whole rulebook and
     will report a comment rule like any other line, but it reads the diff's *lines*; this pass reads the
     comment *blocks* the diff attaches to, including a comment the change just made false without
     editing. **Pass no flag.** The diff is its default scope; `--all` would sweep code this task never
     touched, and a flag this verb does not pass is a contract it cannot break.
     - **Skip conditions, stated because silence cannot be told from a pass.** The step-5b skip applies
       first (docs, renames, one-liners). Beyond that: a diff carrying **no comment in range** gets
       *not applicable — no comment in range* in one line, exactly as a conditional pass does above.
     - **🛑 findings hold the merge; `held` findings do not.** A comment whose content demonstrably lives
       at the destination is an ordinary blocker — address it or record why it is deferred. A comment whose
       content lives **nowhere else** is reported `held`, and relocating it is a decision about where that
       content belongs. That is not the merge gate's question, and forcing it here would make every close
       a filing session. Note it in `## Out of scope` with an id if it is work, per step 5d.
   - **Findings outside this task's scope don't block the close and don't get folded in** — the
     review surfacing an adjacent bug or a wanted refactor is a [`/tasks spawn`](spawn.md), not an
     extra commit on this branch. Spawn it, note it in `## Out of scope`, then close on this task's
     own criteria. (Blockers *inside* scope still block.)
   - **If a PR exists** (the PR-per-task default — `pick` cuts a `task/TASK-NNN` branch, `close` is the merge gate), run [[review]] on the PR diff before merging (runtime-provided; no such skill → read `gh pr diff <n>` and run the same correctness pass at PR altitude). **This per-task pass is where code correctness is reviewed, once, at the right altitude** — `/feature review` then only *confirms completeness*, it does **not** re-review the code wholesale.

5c. **Merge decision — settle it BEFORE writing frontmatter** (PR-per-task projects; skip entirely
   when step 8's skip conditions apply — `--no-pr`, non-git, `integration: single-branch`, or not on a
   `task/TASK-NNN` branch):
   - **State every gate verdict in the question**, not one blended summary — *standards pass, intent
     fail* is a different situation from *all pass*, and a merge decision taken from a single merged verdict
     cannot tell them apart. That means each pass 5b actually ran, including [[security-review]] when the
     diff reached it.
   - Ask (AskUserQuestion): *"Merge `task/TASK-NNN` into the default branch as part of this close?"*
     Default: **Yes, merge now.** Step 8 executes whichever answer you get; this step only decides,
     so that step 6 knows which status is true.
   - **`--unattended` → merge, without asking.** Every gate has already run and passed by this point,
     `done` already means *merged* in this skill set, and [[fix-next]] states that `close` "settles the
     merge decision … and merges". **Rejected: ending at `blocked` instead.** It is the safer-looking
     option and it makes the drain pointless — every run would leave a finished-but-unmerged task for
     someone to sweep, and `blocked` would come to mean both "waiting on a dependency" and "waiting on
     a human", which is the kind of overloaded state this vocabulary exists to avoid. **Also rejected:
     a per-repo `unattended-merge:` field** — it needs a default anyway, and the default would be this.
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

   **Under `--unattended`, spawn instead of offering.** The three outcomes and the grouping rule are
   unchanged; only the *work* branch differs, because there is nobody to take an offer:
   - **Work** → [`spawn`](spawn.md) it outright, no prompt. Record every id created.
   - **A bullet you cannot confidently classify** → treat it as work and spawn it. The repo's standing
     preference settles the tie: a spare task is cheap noise anyone can `cancel`, an untracked paragraph
     is work that silently disappears.
   - **"Decided not to do" is unavailable unattended.** Interactively it is a legitimate outcome, because
     a human is affirming the decision. Unattended it is a decision nobody sanctioned that *destroys the
     finding* — the bullet gets rewritten and no id is left behind. Spawning is cheap and reversible;
     discarding is neither. A bullet that genuinely reads as a settled non-goal still gets spawned, and
     the task can be `cancel`led by whoever knows.
   - **Never close with the bullet unowned**, and never stop the run to ask. Both readings defeat the
     step — stopping strands a half-closed task in an unwatched session, and closing anyway is the exact
     evaporation this step exists to prevent, now with a rule quoted over the top of it.

   The ids go to step 12 **by id, not only as a count**: a run nobody watched is read later from the
   report alone, and `spawned: 3` tells that reader nothing they can act on.

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
   - **Anything to commit?** Run `git status --porcelain`. If the tree is clean, don't offer a commit — just optionally ask for an existing PR number / commit SHA (accept empty as skip) and continue. **`--unattended` → skip that prompt** and continue with `pr:` as-is.
   - **`--unattended` → commit, without asking.** Take the "commit the progress now" branch below with its staging discipline intact: stage the task file plus the change set explicitly, never blanket `git add -A`, and sanity-check `git diff --cached --name-only` first. Step 6 has already written the frontmatter, so this is *always* the branch taken — the tree cannot be clean here.
   - **If there are uncommitted changes, ask the user** (AskUserQuestion) what to do:
     - **Commit the progress now** → stage the work plus the updated task file (already flipped in step 6 — to `done`, or to `blocked` when the merge was deferred at 5c) and create one commit.
       - Message: `{{ID}}: {{task title}}`, mirroring the repo's existing style if there is one (e.g. a `@ <area>:` prefix — check `git log --oneline -5`). **Keep the id in the *subject*, ahead of any other task id it mentions** — a prefix before it is fine. [[specs]] provenance attributes a commit to the task whose id leads its subject and treats an id in the body as a cross-reference, so a subject that buries the id makes this task's work invisible to `shaped-by`. Show the message and the file list before committing.
       - **No `Co-Authored-By:` trailer** (skill convention — see SKILL.md › Conventions).
       - Stage explicitly (the task file + the change set the user confirms) — never blanket `git add -A`, so ignored/stray files don't slip in. Sanity-check `git diff --cached --name-only` before committing.
       - **SHA backfill — PR-per-task only.** **A worktree close skips it here**: step 8 writes it into the main copy's pending merge instead, and a staged edit left in the worktree would make its removal fail. Otherwise: if `pr:` should reference this very commit, write the short SHA into the task file and stage that one-line edit so it rides in the **merge** commit. That works because the merge is a *second* object: the work commit's SHA is fixed before the edit naming it is committed. Don't leave the backfill dangling uncommitted.
       - **On `integration: single-branch`, leave `pr:` null. Do not attempt the backfill.** There is no second commit to carry it, and **a commit cannot contain its own hash**: writing the SHA then amending produces a *different* SHA, so `pr:` would name an object that is now unreachable. The amend has no fixed point, so the instruction cannot terminate — and an instruction that cannot be followed gets silently skipped, which is how `pr: null` became the norm on 390 of 392 tasks in the first place.
         - **Provenance is not lost, and this is why the previous bullet is load-bearing.** [[specs]] `regen` falls back to attributing a commit to the task whose id **leads its subject** — precisely the convention the message bullet above mandates. So a single-branch repo resolves through the subject rule by construction, and that rule is *not* optional here: it is the only provenance path this flow has. Anyone tightening or removing it must fix this first.
         - **Rejected: a follow-up commit that records the SHA.** It terminates, and it was how this was worked around by hand. Rejected on two costs: it doubles the commit count on every close, and — worse — the follow-up names the task in its own subject, so `regen` attributes it too and `shaped-by`'s file list gains the task file for a commit containing nothing but one frontmatter line.
       - Commit to the current branch. The **merge** itself is a separate hard step (step 8, executing the 5c decision) — don't fold it into the commit. A non-git or local-only project skips step 8 and just records the reference.
     - **Reference an existing commit / PR instead** → prompt for a PR number or commit SHA and write it to `pr:` (stage/commit that edit with the close).
     - **Skip** → leave `pr:` null. Accept empty input as skip.

8. **Merge gate — the integration moment** (executes the step 5c decision; runs only when the close commit landed on a `task/TASK-NNN` branch and `--no-pr` not passed):
   - **STOP HERE.** Do not silently advance to step 9 — the close commit is on the task branch, the work is not yet on the default branch, and continuing on the task branch bakes a stale branch-state into the chore refreshes that follow. This step is what makes `done` mean *merged* (a precise state, not "committed somewhere").
   - **5c said merge now:** push if needed, open the PR if one doesn't exist, merge with the project's preferred strategy (default: `--no-ff` so the branch identity is preserved in history; check the project's commit log to confirm), and `git branch -d task/TASK-NNN`. Check out the default branch. Subsequent steps (hybrid remote close, dashboard regen, rollup hints) now run on the default branch — chore refreshes land on `main`, not on a task branch.
     - **The merge failing is a failed close**, not a footnote: on conflict or a rejected push, stop, report it, and leave the task at its pre-close status — don't leave a file reading `done` over a merge that never landed.
   - **5c said defer:** don't merge. The task is already `blocked` (step 6) with the reason recorded, so no state here claims otherwise. Push the branch and open/update the PR if the project uses one — parked work belongs on the remote, not only on a local branch. Then note the resume path: `/tasks unblock {{ID}}` + re-run `close` once the blocker clears; it re-enters here and merges.
   - **A worktree close (step 4b)** replaces the "check out the default branch" mechanics above — that
     branch is checked out in the main copy and cannot be checked out twice. Print the **closing-from**
     line, then:
     - **Re-check the main copy** exactly as step 4b did; a parallel session may have dirtied it since.
       Failing now is still a failed close — but step 7 has already committed `done` on the task branch,
       so print the **merge-failed** line, not the failed-close one, and say which commit is left there.
     - **Merge now, locally:** `git -C "<main>" merge --no-ff --no-commit task/TASK-NNN`. While that merge
       is pending, write the `pr:` backfill (step 7's SHA of the work commit) into the **main copy's**
       task file, stage it there, and `git -C "<main>" commit --no-edit` — so the backfill still rides in
       the merge commit. The in-place trick of carrying a staged edit into the merge cannot work here:
       that index belongs to the worktree. A conflict → `git -C "<main>" merge --abort` and the
       **merge-failed** line. **Re-closing resumes here**: step 4 finding `done` on the task branch in the
       task's own worktree while the default branch still reads otherwise is an unmerged close, not a
       closed record — it neither asks to reopen nor refuses under `--unattended`, and goes straight to
       this merge.
     - **Then the tail, in this order, stopping at the first step that fails.** Each failure prints its
       line with the **exact outstanding commands**, and nothing is ever forced. The task is `done`
       either way: `done` means merged, and it is — the rest is housekeeping.
       1. **Leave** — `ExitWorktree` with `action: keep` when the session entered by `EnterWorktree`,
          otherwise change directory to the main copy. Prove it as `pick` step 6b does: a **separate,
          later** `git rev-parse --show-toplevel`, normalised, must equal the main copy. You cannot remove
          the folder you are standing in. **Leave and prove in every shell the session has** — Claude
          Code's Bash and PowerShell tools each keep their own working directory, and one left behind
          still holds the folder: measured, a close that left and proved in one shell had its removal
          refused by Windows because the other was still inside, and git then deleted the files and the
          registration but not the locked folder.
       2. **Remove** — only a worktree this skill made: `workspace: worktree` declared, and the path
          exactly `<worktree-root>/<repo-name>-TASK-NNN`. Anything else holding the branch is merged,
          left in place and named, never deleted. Name any dirty paths first
          (`git -C "<path>" status --porcelain`), then `git -C "<main>" worktree remove "<path>"` —
          **never `--force`**: forcing here destroys uncommitted work at the one step meant to be safe.
          **A refused removal can still be a partial one**, so re-read `git worktree list` before
          printing the outstanding commands: registration gone but the folder left → the outstanding
          step is deleting that (now empty) folder by hand once nothing holds it, then the branch
          delete, not a `git worktree remove` that would now fail.
       3. **Delete the branch** — `git -C "<main>" branch -d task/TASK-NNN`, **never `-D`**. It refuses
          after a squash merge; report it and stop.
     - **5c said defer, or step 5 parked the task at `review`** (a park reaches this bullet from step 5,
       which skips steps 6–9 but not this): commit in the worktree, run **no tail**, and print the
       **kept** line naming the path — the re-close starts from there, and so does `/tasks unblock`, since
       the parked status exists only on the task branch. The default branch still reads `in-progress` for such a task, because the parked status
       lives on the task branch; that is not free work, so nothing misreads it as available.
   - **Skip silently when:** `--no-pr` was passed, the repo isn't a git repo, the project sets `integration: single-branch` in `.config.yml` (or otherwise has no PR-per-task flow), or the current branch isn't `task/TASK-NNN`. In all these cases, "merge" has no meaningful action, 5c never ran, and step 8 is a no-op. On a `single-branch` project `done` means **committed to the default branch** — the invariant is unchanged, only the mechanism is.

9. **Hybrid mode remote close** — **only when the task actually reached `done`.** Skip for a task
   parked at `review` (step 5) or `blocked` (step 6, merge deferred): the remote tracker must not
   read "closed" for work that isn't signed off or isn't merged. Then check `mode: hybrid` in
   `.config.yml`:
   - `github-issue: <N>` set → run `gh issue close <N> --comment "Closed by {{ID}}"`.
   - `jira-key: <KEY>` set → use the Atlassian MCP to transition the issue to Done (search for the transition tool via ToolSearch first; if MCP isn't authenticated, prompt user). Alternatively, if a `jira-task` skill is installed (an optional, environment-specific skill), hand off to it for that environment's full closure workflow.

10. **Regenerate dashboard**. After a worktree close, regenerate it in the **main copy** — by absolute
    path, if the tail could not leave the worktree.

10b. **Commit what steps 10–11 regenerated — worktree closes only; run it after step 11.** The dashboard and the feature
    rollups are written into the main copy after the merge; left uncommitted, they dirty it, and the next
    `pick` falls back while the next `close` fails its clean check. Commit exactly those files and nothing
    else from the index — `git -C "<main>" commit --only -m "chore: dashboard and rollups after TASK-NNN" --
    <the files written>`. The subject deliberately does not **lead** with the id, so [[specs]] attributes
    no behaviour to this commit. In-place projects keep today's behaviour.

    **Report lines for a worktree close** — fixed, one per outcome:
    - closing from: `workspace: closing from the worktree at <path> on task/TASK-NNN — merging in the main copy at <main>`
    - merge failed: `close failed at the merge: <reason> — task/TASK-NNN carries the close commit <sha> (status done) but <default> does not; worktree kept; fix it and re-close from <path>.`
    - unsupported: `workspace: worktree close does not yet support a default branch that tracks a remote (<default> → <upstream>) — nothing was changed.`
    - failed close: `close failed: the main copy at <main> is <not clean (<n> paths) | on <branch>, not <default>> — nothing was written; TASK-NNN stays <status>; worktree and branch untouched.`
    - wrong tree: `close: this session is in the worktree for <branch> (<toplevel>), not task/TASK-NNN — nothing was changed.`
    - held elsewhere: `close: task/TASK-NNN is checked out in the worktree at <path> — close it from there; nothing was changed.`
    - clean tail: `workspace: merged task/TASK-NNN into <default>; left the worktree — proved: git rev-parse --show-toplevel = <main>; removed <path>; deleted task/TASK-NNN`
    - could not leave: `workspace: merged; could not leave the worktree (expected <main>, got <toplevel>) — outstanding: cd "<main>" && git worktree remove "<path>" && git branch -d task/TASK-NNN`
    - not removed: `workspace: merged; <path> not removed — <git message | uncommitted: <paths> | not a worktree this skill made>; task/TASK-NNN kept — outstanding: git worktree remove "<path>" && git branch -d task/TASK-NNN`
    - branch kept: `workspace: merged; removed <path>; task/TASK-NNN not deleted — <git message>; never forced`
    - kept: `workspace: worktree kept at <path> on task/TASK-NNN — <review | blocked>; re-close from there`

11. **Rollup hint** (informational; never auto-close parents):
    - **Ship-moment hints fire on `done` only.** A task parked at `review` or `blocked` (merge
      deferred) still gets the dashboard regen (step 10) and the feature-status refresh below —
      the trees must show its real state — but the *last-open-task* suggestions, the
      `/feature review` prompt, and the changelog nudge stay silent. Nothing has shipped yet;
      suggesting otherwise is how a story gets closed over an unmerged branch.
    - If this task was the last open task in its STORY → suggest `/tasks close <STORY-ID>`.
    - If closing a STORY leaves an EPIC with no open stories → suggest `/tasks close <EPIC-ID>`.
    - But default behaviour for STORY/EPIC is to stay open — areas of concern keep gaining work.
    - **After a worktree close, every file this step writes goes into the main copy** — change directory
      there, or address it by absolute path when the tail could not leave — so step 10b finds it there
      to commit. Written in the worktree, it would be left behind on a branch about to be deleted.
    - **Feature rollup** — any task with `feature: FEATURE-NNN` that changed status here (`done`, parked at `review`, *or* `blocked` on a deferred merge) → chain `/feature status FEATURE-NNN` (single-feature mode) so `status.md` and the index row reflect the new task state; the rollup must never lag a close. If it was the last open task for that feature, also suggest `/feature review FEATURE-NNN`.
    - **Spec regen offer** (STORY close only; when the project has real code but no `docs/specs/.map.yml` **or the map's `areas:` list is empty** — the [[new-project]] scaffold seeds exactly such an empty anchor — print one line — *"no usable spec map — run `/specs init` to bootstrap the spec layer"* — instead of skipping silently): map the story's merged work to spec areas — resolve its tasks' `pr:` commits/PRs to changed files (`git show --name-only <sha>` / `gh pr diff <n> --name-only`) and match them against the `.map.yml` globs; if references are missing, ask which areas — **`--unattended` → skip the regen and report that references were missing**, because guessing an area writes a spec diff nobody asked for. Then **offer** — don't auto-run — `/specs regen <areas> --story STORY-NNN`. The regen's diff review is the "was this behavioral change intended?" check (the [[specs]] skill); an unexpected spec diff at story close is a finding, not churn.
    - **Changelog nudge** (don't auto-run; avoid double-nudging) — only for **task-only work that `/feature review` won't cover**: if the closed item has **no `feature:` link** (a `_loose` task or a feature-less EPIC/STORY) and represents a user-facing change, and the project has a `CHANGELOG.md`, print one line — *"consider `/roll-changelog` to record this for users."* Skip when the task has a `feature:` link (the feature's `/feature review` carries the nudge) or there's no `CHANGELOG.md`. The changelog is human-curated, so suggest, never auto-run.

12. **Confirm** — print (include the step 5d outcome: `out-of-scope: N boundary, M spawned, K declined`,
   naming each spawned id — under `--unattended` the report is the only place anyone will see them,
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
- **Jira MCP not authenticated** — prompt user to run authentication; pause the verb until they confirm. **`--unattended` → skip the remote step and report it**; an unattended run cannot authenticate, and pausing forever is the failure the flag exists to prevent.
- **Closing EPIC with open children** — block by default ("EPIC-001 has 3 open tasks; close them first or pass `--force`").
- **Merge deferred at 5c** — the task ends the close at `blocked`, not `done`, with the reason recorded. It stays out of "Next up", the remote issue stays open, and the ship-moment hints don't fire. Resume with `/tasks unblock {{ID}}` then re-run `close` — it re-enters at step 8 and merges. This is the merge-side mirror of parking at `review` for an unrun Human test plan: both are honest non-completion, neither is `done`.
- **Worktree close, merge landed, tail stopped** — could not leave, removal refused (a dirty worktree, or on Windows another process whose working directory is that folder), or the branch would not delete: the task is `done`. Print the outstanding commands verbatim and **never** `--force`, `-D` or `git worktree prune`; a half-deleted folder is reported by path, not cleaned up by guesswork.
- **Merge conflict / rejected push at step 8** — the close failed. Report it, leave the task at its pre-close status, and don't let the frontmatter claim `done` over work that never landed on the default branch.
