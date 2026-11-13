# /tasks pick — choose a task and start work

Filter open tasks, present them, mark the chosen one in-progress, present its body for work.

## Steps

1. **Find task root**.

2. **Parse args**:
   - `--across` — **refused here, and say why rather than ignoring it.** Picking marks a task
     `in-progress`, may cut `task/TASK-NNN`, and starts editing — all **writes**, in a repo the user did
     not invoke from. `--across` is a read-only view by construction (see the router and
     [Collection pass](../SKILL.md#collection-pass) step 1b). Answer with the combined view's own
     remedy: *"`--across` is read-only; run `/tasks --across` to see every project, then pick from inside
     the repo that owns the task."* Ids there are printed `<repo>/TASK-NNN`, so the owning repo is
     already named.
   - `--status` — default `todo`. A **blocked** `todo` task is listed too, marked `⚠ blocked: <reason>`, so it
     is never forgotten (FEATURE-003 D6); an old-form `status: blocked` task is listed the same way, with
     `prior state unknown`. Either form is defined in [SKILL.md](../SKILL.md) § *Lifecycle*.
   - `--priority` — filter (default: all)
   - `--assignee` — filter (default: all)
   - `--epic <ID>` — limit to tasks under one epic
   - `--story <ID>` — limit to tasks under one story
   - `--feature <FEATURE-NNN>` — limit to tasks carrying that `feature:` frontmatter (how
     [[feature]]'s `/feature pick` hands off once a feature is decomposed)
   - Bare ID arg (`/tasks pick TASK-014`) → skip the picker, jump to step 5 — **after step 3's taken check
     on that one task, then step 2b.** The taken check runs first, since a refusal writes nothing and needs no
     nudge; 2b then runs exactly as for a listed pick, because naming a task skips the list, not the rule that
     verification debt comes before new scope. Count the named task in 2b only if it is not the one being
     picked. With 3 or more in debt, a yes to 2b's question stops here before step 5: that is the debt being
     cleared first, not a refusal. Skipping the picker must not skip the check, or naming a task is the way to pick one
     another session or clone already holds. Read it as step 3 does:

     | `task/TASK-NNN` | Do |
     |---|---|
     | exists nowhere | go to step 5 |
     | is the current checkout | go to step 5: this session's own in-place pick, which step 7 treats as already on its branch |
     | exists locally, under `workspace: worktree` | go to step 5. Step 6b owns every local case: its resume row (with a worktree or without), and its prunable, not-resumed and leftover lines. Refusing here would pre-empt the resume it promises |
     | exists in any other way: locally in an in-place project, or only on a remote (`git branch --list`, `git branch -r --list "*/task/TASK-NNN"`) | print the **taken** line, write nothing, and stop |

     taken: `pick: TASK-NNN is taken — task/TASK-NNN exists <locally | on <remote>>, and this session is not on it. Nothing was changed. If it is yours, switch to it (or enter its worktree) and pick again.`

     The check reads the remote branches as the fetch below left them.
     Without git there are no branches to read, and the check is skipped, as the Collection pass skips it.

   **With an upstream, every pick fetches first** (`git fetch --prune <remote>`), once, before any taken check
   reads a branch: the bare ID's check above and step 3's list and `taken (hidden)` line alike. *Upstream*
   is step 6b's test (`<default-branch>@{upstream}` resolves). A stale remote list hides another clone's newer
   branch and keeps showing one deleted since, in the list as much as for a named task. A failed fetch prints
   6b's **fetch-failed** line, and the pick continues on what is known locally. 6b does not fetch again after
   this one.

2b. **Surface verification debt before offering anything.** Collect TASKs at `status: review` or `status: verify`, as the [Collection pass](../SKILL.md#collection-pass)'s `inReviewTasks[]` defines them (a worktree park's `verify` lives on its task branch) — code
   complete, sign-off pending — and report them **before** the candidate list. They are deliberately
   **not** candidates (the `--status todo` default is right: a task awaiting sign-off is not work to
   start), so the job here is to *surface* the debt, never to offer unfinished work as new work.

   | Debt | Do |
   |---|---|
   | none | say nothing; go to step 3 |
   | 1–2 | one line — `⚠ verification debt: <n> at verify awaiting sign-off: <ids, comma-separated>` (`… 1 at verify awaiting sign-off: TASK-046`, `… 2 at verify awaiting sign-off: TASK-046, TASK-048`) — then continue |
   | 3 or more | the same line, then **ask**: *"Clear verification debt first?"* Default **yes**. The user may decline and pick anyway |

   The line names the state `verify` even for a task whose file still reads the older `review`; both are the one
   state ([SKILL.md](../SKILL.md) § *Lifecycle* → *Reading a task's status*).

   Count plus ids, not a full listing — the bare `/tasks` snapshot owns the readable version, and this
   is a nudge, not a second dashboard. Use its words: a `verify` task is **verification debt**, and it
   *"should be closed (run the test → `done`) before new scope"* (SKILL.md § Lifecycle).

   **Why this is here and not left to the snapshot.** `pick` is the natural way to resume a session, and
   it was the one place the verification-debt rule was never stated — so a session opening with `/tasks
   pick` got handed fresh work while code-complete tasks sat unverified, and never learned they existed.
   Picking new work over unverified work is exactly what the rule exists to prevent.

   **The threshold is a nudge, not a gate.** 3 is a starting point, tuned with use. Never block the pick:
   debt is a judgement call — a user may have a good reason to push on — and a gate that cannot be
   overridden gets worked around, which costs more than the reminder is worth. ([[fix-next]] already does
   its own version of this at step 1, so a defect drain needs nothing added here.)

3. **Collect candidates** — every TASK file whose frontmatter matches the filters, **less any task the
   [Collection pass](../SKILL.md#collection-pass) counts as taken** (its branch exists locally or on a
   remote — another session or clone has it). Print them on one line **under** the list —
   `taken (hidden): TASK-NNN (<local | remote/<name>>), …`, where `<name>` is the remote's name as `git remote`
   prints it (`remote/origin`), not the ref, and a branch both local and on a remote prints `local` — because a
   stale branch hides a task silently otherwise. **A local branch that a worktree here holds, and whose own copy reads `in-progress`**
   (`git show task/TASK-NNN:<task file>`), is work in progress on this machine, not another clone's. Print
   it on its own line **before** the candidate list, after 2b's debt line if any (work already started here is
   offered before new work, as debt is): `in progress on this machine: TASK-NNN at <worktree path> — resume with /tasks pick TASK-NNN
   (check no other session is working in it)`. Picking it by id takes step 6b's resume row. A worktree here
   may belong to another session, so the line invites a resume and never assumes one. A branch copy reading
   `review` (or `verify`) is reported by 2b as verification debt instead, and not on the in-progress line.
   **Neither is also listed under `taken (hidden)`** — not a task on the in-progress line, and not a task 2b
   reports as debt. Listed there too, this machine's own work would read as another clone's. With an upstream this matters most: the
   default branch's copy still reads `todo`, so the task looks free and would otherwise be listed as taken. For each, capture: id, title (first `# Heading` after the frontmatter — never a `# …` comment inside it), parent IDs (story + epic), priority, assignee, `created`, file path.

4. **Present numbered list** in **task order** ([SKILL.md](../SKILL.md) § *Collection pass* step 5), so the
   numbering is the same on every run. When that section's tie line applies, print it under the list. The
   list's shape:
   ```
   1. TASK-001 JWT issuance on login (P1, agent)
      EPIC-001 Authentication → STORY-001 Password login
   2. TASK-003 Rate limit (P1, agent)
      EPIC-001 Authentication → STORY-001 Password login
   3. TASK-007 Bump .NET 9 (P1, human)
      [loose]
   ```
   Put this question:

   > **Which task? Give its number from the list, or a TASK-NNN id.**

   **No answer, or nobody to ask:** start nothing. Write nothing, and print
   `pick: no task chosen — nothing was changed`. A pick writes a status and may cut a branch, so taking the
   top of the list would start work nobody chose.

5. **Read the chosen TASK file** in full.

6. **Plan-first check — offer the plan before any work begins.** If the file has no
   `## Implementation plan` section, OR the section exists but its body is empty/placeholder-only,
   prompt with the **default set to yes**:
   > "TASK-NNN has no implementation plan. Draft one with `/tasks plan {{ID}}` first? [Y/n]"
   - `Y` → hand off to [verbs/plan.md](plan.md) for this TASK ID (which itself offers the
     `grill-me` pass), then resume `pick` from step 6b once it's done.
   - `n` → proceed unplanned. Legitimate for genuine one-liners; don't block, and don't nag twice.
   - **No answer, or nobody to ask:** take the default. Hand off to [verbs/plan.md](plan.md) as `/tasks plan
     TASK-NNN --no-grill`, since the grill is a conversation, and say in the hand-off
     `plan drafted — the default; nobody chose it`. A missing answer is not a `n`: proceeding unplanned would
     turn silence into a decline the prompt's default says nobody made.
   - **Recommend planning** whenever the task touches more than one file, has ≥3 acceptance
     criteria, carries a `feature:` link, or its Context names unknowns. Say which of those
     triggered the recommendation — a concrete reason beats a generic prompt.
   - If a plan already exists, **read it as the work brief** and note its age. **The age is recomputed every
     run and never written down**: it is derived from git evidence the repo still holds. Read the copy of the
     task file step 5 read (on a worktree resume, the task branch's):

     | Case | Reading |
     |---|---|
     | no git, or `HEAD` not yet born | do not check; print `plan age not checked — no git history`, ask nothing |
     | the task file is untracked, or `git diff HEAD -- <task file>` touches a line inside the plan section | the plan is uncommitted, so newer than every commit: do not flag, ask nothing |
     | committed | find the section's lines in `HEAD`'s copy (`git show HEAD:<task file>`): from its heading to the line before the next `## ` heading, **or to the file's last line**, since the template ends with this section. The plan's commit and `<date>` are the first line of `git log -1 -s --format='%H %cs' -L <start>,<end>:<task file>`; take only the first line, since older gits print the diff anyway. A regex range ending at `/^## /` fails with "No match" when the plan is last, which is the usual case |

     The paths are every repo-relative path the plan names in backticks. One **changed since** when
     `git diff --name-status <plan sha> HEAD -- <paths>` or `git status --porcelain -- <paths>` lists it. A path
     absent now counts only when that diff shows it deleted or renamed, rendered `<path> (deleted)` or
     `<path> (renamed → <new>)`. A path absent now that the diff does not show deleted or renamed is one the
     plan means to create, not evidence of staleness, so leave it out; that includes every path when the plan's
     commit is `HEAD`, since the diff is then empty. When none changed, do not flag and do not ask, and print
     nothing about the age.
     When the plan predates changes to the code it references, flag it and offer `/tasks plan {{ID}} --replan`
     rather than silently working from a stale plan. Put this question:

     > **TASK-NNN's plan dates from <date>, and <paths> changed since. Replan it with `/tasks plan TASK-NNN --replan` first? [y/N]**

     **No answer, or nobody to ask:** keep the plan and work from it, and say so in the hand-off:
     `plan kept: it predates changes to <paths> — may be stale`. Replanning overwrites the plan, so it is
     never done unasked.
   - A plan whose steps turn out to be separately-completable units of work is a **split signal**,
     not a bigger task — see step 9's spawn rule.

6b. **Decide where the work happens** (git repos with a born HEAD; anything else goes straight to step 7
   and nothing here changes). Read `integration:`, `workspace:` and `worktree-root:` from `.config.yml` —
   **never decide from `git worktree list`**, where a worktree that exists may be anyone's checkout.
   Recompute this every run; cache nothing.

   | Declared | Do |
   |---|---|
   | `workspace:` absent or `in-place` | step 7, print nothing |
   | any other value but `worktree` | print the **invalid-value** line; step 7 as in-place |
   | `worktree` + `integration: single-branch` | print the **no-effect** line, every run; step 7 |
   | `worktree`, and a local `task/TASK-NNN` exists whose own copy of the task file reads `in-progress` (`git show task/TASK-NNN:<task file>`) — or the default branch's copy does | **resume** — below; no question, no pick commit. Run the **wrong-tree** check (below) first. Read the status off the **task branch**: with an upstream the default branch's copy still reads `todo` while the task is in progress |
   | `worktree` + `worktree-root:` absent | ask the question below |
   | `worktree` + root declared | check, commit the pick, create, enter, prove — below |

   **Resume — re-enter the worktree that already holds the branch.** A new session always starts in the
   main copy, and a branch a worktree holds cannot be checked out there, so an in-progress task's work can
   only continue where it already is. Locate it from evidence, recomputed every run:
   `git worktree list --porcelain`, any entry but the first whose `branch` line is
   `refs/heads/task/TASK-NNN`. That is not the inference this step forbids above. `workspace:` is still
   read from the config; this only finds a branch the verbs themselves made.
   - **The entry is `prunable`** (its folder is gone) → print the **prunable** line and **stop**. Git
     refuses to check the branch out anywhere while that registration holds it, so there is no in-place
     fallback, and pruning is the person's call, never this verb's.
   - **Otherwise enter and prove it** exactly as **Enter, then prove** below describes. Then the caller
     continues at its own next step; `pick` continues at step 9, because steps 7–8 already ran at the
     original pick. **Never create a second worktree** for a task
     that has one. A mismatch here removes nothing, because this worktree holds real work: print the
     **not-resumed** line and stop.
   - **No worktree holds the branch** (a person pruned it, or it was never made) → nothing to resume into.
     Print the **no-worktree** line and continue in place: switch the main copy to `task/TASK-NNN` if the
     main copy is clean, then go to step 9 (the task branch's copy already reads `in-progress`). A dirty main copy →
     report that and stop. Never re-create the worktree unasked. The branch may carry work a person moved
     on purpose.

   **This step is the one owner of entering and proving a worktree.** Other verbs resume through it
   rather than restating it.

   From here on `workspace: worktree` has asked for isolation, so **whenever this step falls back, step 7
   cuts `task/TASK-NNN` in place without offering** — the declaration already answered that offer.

   **The root question.** Put exactly this:

   > **Where should task worktrees live?** Each task gets its own folder there, outside this repository.
   > Suggested: `../wt` (next to this repository). Your answer is saved as `worktree-root:` in
   > `tasks/.config.yml` and committed with this task's pick. Give a path, or leave it blank to work in
   > place this time.

   - **An answer is held, not written, until every check below has passed.** It is then the declared
     root those checks test — so a root inside the repository is refused before it is ever written, and a
     refused answer cannot be committed and then refused by every later pick. Only once all checks pass is
     it written as a live `worktree-root: <answer>` — replacing the commented `# worktree-root:` line when
     there is one (its comment block stays), appended otherwise — and it rides in the pick commit below:
     on the default branch with no upstream, on the task branch with an upstream (it then reaches the default
     branch with the task's PR, and a pick made before that merge asks again).
     No second confirmation: the question already said where the answer goes.
   - **Blank, or nobody to ask** — the answer-less path, and also the unattended outcome, since no flag
     reaches this verb: write nothing, print the **fell-back** line with `worktree-root undeclared`, and
     continue at step 7. The suggestion never becomes the declaration.

   **Check — every condition before anything is written or created.** Each failure prints its line and
   **stops** unless it says otherwise. None is worked around, and nothing is ever pruned, forced or
   deleted that this run did not just create.
   - **Run from the main copy.** `git rev-parse --path-format=absolute --git-dir` differing from
     `git rev-parse --path-format=absolute --git-common-dir` means this
     session is inside a linked worktree — perhaps another task's. Stop with the **wrong-tree** line:
     every path below would be computed from the wrong tree, and the pick would land on another task's
     branch.
     **Both sides absolute, always.** Without `--path-format=absolute`, git prints one path absolute and
     the other relative when run from a subfolder (`C:/…/.git` against `../.git`), so the plain comparison
     reports a linked worktree in the main copy.
   - **Upstream or no upstream.** `<default-branch>` is [SKILL.md](../SKILL.md) § *The default branch is derived*.
     `git rev-parse --abbrev-ref <default-branch>@{upstream}` decides; recompute
     it every run, never remember it. It fails → **no upstream**, everything below as written. It names an
     upstream → **upstream**. Nothing may be committed on the local default branch there, because nobody
     pushes it, and a local commit there diverges from the remote the moment a PR merges, and a protected
     branch refuses it anyway. So an upstream changes the steps below that are marked **upstream**.
     It begins with step 2's fetch (`git fetch --prune <remote>`): skip it only when this run already ran it
     there. A caller that enters this step without passing through step 2, such as [[fix-next]], has not, so
     it fetches here. The fetch shows other clones' task branches, and drops the refs of branches deleted
     there, which would otherwise hide a task forever. A failed fetch (offline) prints the **fetch-failed**
     line, and the run continues on what is known locally.
     **An upstream also needs a local default branch with nothing the remote lacks.**
     `git rev-list --count <upstream>..<default-branch>` above 0 means local commits nobody pushed →
     print the **local-ahead** line and stop, since those commits must reach the remote through a PR
     first. A branch that is only **behind** is brought level at the end of these checks (below).
   - **The main copy is on the default branch** (the one step 7 branches from), and **clean apart from
     the task tree's own files for this task** — its task file (modified or not yet tracked), its parent
     STORY/EPIC files, and `tasks/README.md`: exactly what `/tasks new` leaves behind. **With an upstream they
     are carried, not committed here.** After the proof below, the task file and its parent files are
     copied into the worktree and ride in the task-branch pick commit, so a new task reaches the default
     branch with its PR. The main copy's copies are then restored to the upstream state
     (`git restore -- <tracked>`, delete untracked), and `tasks/README.md` is restored too: it is
     generated, so nothing is lost. That keeps the main copy a clean mirror. Otherwise fall back
     with that reason — and when the main copy is **not on the default branch**, step 7 cuts nothing,
     since a branch cut there would silently stack this task on whatever is checked out. The pick commit
     below must hold only this task's pick.
   - **The root lies outside the repository.** Resolve it — absolute as written, relative against the
     repo root (the parent of `tasks/`), exactly as `siblings.root` resolves. Equal to
     `git rev-parse --show-toplevel` or beneath it → the **refusal** line, and continue at step 7.
   - **Not taken elsewhere (upstream).** `task/TASK-NNN` present on the remote
     (`git branch -r --list "*/task/TASK-NNN"`) with **no local `task/TASK-NNN`** means another clone has
     the task → the **taken-elsewhere** line, and stop. A local branch means this clone's own pick, which
     the resume row above already took.
   - **Nothing is left from an earlier pick.** The path is `<root>/<repo-name>-TASK-NNN`, `<repo-name>`
     being the basename of the main copy's top-level folder. If a local `task/TASK-NNN` already exists, or
     the path already exists, or `git worktree list` registers that path (a folder deleted by hand shows as
     *prunable*) → the **leftover** line naming what was found, and stop. Resuming such a task is a
     separate path; this step never guesses whose it is.
   - **Upstream: bring the default branch level — last, once everything above has passed.** The
     main copy is now known to be on the default branch. If it is behind `<upstream>`, fast-forward it:
     `git merge --ff-only <upstream>`. Local and upstream are then the same commit, which makes the carry
     safe. A stale local parent file carried over a newer upstream one would silently drop another task's
     entry. It also lets a fallback's `git branch -d` pass. A fast-forward git refuses (this task's
     uncommitted edits collide with incoming ones) prints the **ff-refused** line and stops: merge them by
     hand, then pick again.

   **Commit the pick on the default branch — before the worktree exists** (no upstream; with an **upstream**
   this is skipped, and the pick is committed on the task branch after the proof below). The status flip happens here,
   not in the worktree, and that is the point: written only on the task branch, the task would still read
   `todo` from the main copy — `/tasks`, `/fix-next` and a second `pick` would all see it as free — and a
   task file never committed would not exist in the worktree at all.
   - Flip `status:` to `in-progress` (step 7's edit, done here), regenerate the dashboard (step 8), and
     commit exactly those files and nothing else from the index:
     `git add -- <task file> <its changed parent files> tasks/README.md [tasks/.config.yml]`, then
     `git commit --only -m "TASK-NNN: pick" -- <the same paths>`. `.config.yml` is included only when this
     run wrote the answered root. **A caller that writes more of the task file at pick time** — [[fix-next]]'s
     `picked-by:` and first `## Progress log` line — writes it **before** this commit, so it rides here
     rather than landing on the task branch only, invisible from the main copy. A plan step 6 wrote is in the task file and rides along. The subject
     leads with the id on purpose, so [[specs]] attributes the commit to this task; that is harmless,
     since it touches only the task tree, which no spec area maps.
   - **The commit fails** → stop, and report which files are changed but uncommitted; committing them and
     re-running continues from here. Going on would build the worktree without the pick in it, or leave
     the main copy dirty for `close`.

   **Create.** `git worktree add "<path>" -b task/TASK-NNN <default-branch>` — quote the path; **with an
   upstream cut it from `<upstream>` instead**, the remote's tip, so a stale local default branch
   cannot put an old base under the task. It fails → the **fell-back** line quoting git's message, and
   step 7, which now only cuts the branch in place (the pick is already committed when there is no upstream).
   **Every fallback with an upstream pushes, not only this one** — this failure, the proof mismatch below,
   `worktree-root undeclared`, the refused root and the unclean main copy all end in step 7's in-place pick.
   With an upstream, that pick is the same pick as the worktree's, so it is guarded the same way:
   - **Run the upstream checks first, if this fallback left before them.** The undeclared root, the
     unclean main copy and the refused root leave before the **Check** block's upstream items. So, before
     step 7, run the main-copy check (*Run from the main copy*) and then those items in their order: the
     fetch, the local-ahead check, the taken-elsewhere check, and the fast-forward. Each failure prints its own line and stops, as it says there. A fallback that
     skips them would cut a stale branch over a task another clone already holds. The fast-forward refuses
     on an unclean main copy whose edits collide with incoming ones; that is its **ff-refused** stop.
   - **Then step 7 cuts the branch from `<upstream>`** (`git switch -c task/TASK-NNN <upstream>`), the
     remote's tip, as *Create* does, carrying this task's uncommitted files along. Then run
     `git push -u <remote> task/TASK-NNN`, so other clones see the task as taken even though it is
     worked in place.
   - **Report both outcomes.** The fallback's own line (**fell-back**, or **refusal** for the refused root)
     comes first, printed once those checks pass; a check that stops prints only its own line, since the
     run never reaches step 7. A push that lands then prints the **upstream** line, and a failed one the **not-pushed**
     line. When step 7 cuts no branch (the main copy was not on the default branch), there is nothing to
     push. Print the **no-branch** line: an unpushed in-place pick with an upstream is invisible to every
     other clone, so it is never left unreported. **The status flip is not committed here**: it stays
   an uncommitted edit in the task branch's checkout until `close` commits it with the work. Nothing is
   committed on the local default branch when there is an upstream, and the pushed branch, not the file, is
   the taken signal (FEATURE-001 D25), so the push needs no commit to carry it. So this pick makes no
   `TASK-NNN: pick` commit, unlike the no-upstream fallback, whose pick was committed on the default branch
   before the worktree was tried.

   **Enter, then prove — before anything is written in the worktree.** A worktree nobody enters is a
   trap, not a spare folder: its branch cannot be checked out in the main copy, so the work would land on
   the default branch under a policy promising isolation.
   - **Enter** with the runtime's own worktree-entry tool when it has one (Claude Code: `EnterWorktree`
     with `path` — it accepts a worktree `git worktree list` shows for this repository); otherwise change
     directory. Never ask the agent whether it *can* move; try, and let the proof decide.
   - **Prove** with `git rev-parse --show-toplevel` run as a **separate, later command** — never chained
     after the move on one line, where it passes whatever happened. Compare it with
     `git -C "<path>" rev-parse --show-toplevel`, so git renders both, **in every shell the session has**
     (Claude Code's Bash and PowerShell tools each keep their own working directory), after normalising
     each: `/c/` →
     `C:/`, `\` → `/`, no trailing separator — and on Windows, whose paths are case-insensitive, compare
     without regard to case.
   - **Mismatch** → `git worktree remove "<path>"` and `git branch -d task/TASK-NNN` (the branch holds
     nothing beyond the pick it shares with the default branch, so never force), print the **fell-back**
     line naming both paths, and continue at step 7, which cuts the branch in place (and, with an upstream,
     pushes it, as the *Create* paragraph above says for every fallback). A removal that fails
     → report what is left and stop. Expect a mismatch from an agent whose working directory was pinned
     at launch (a subagent): falling back there is correct.
   - **Match** → print the **in-a-worktree** line, put step 7's `pr:` question (its last bullet, with its
     answer-less path), and go to step 9. Steps 7 and 8 otherwise already ran inside the pick commit; running
     them again in the worktree would only dirty it. The `pr:` question is the one part of step 7 the pick
     commit could not ask. With an upstream, put it after the pick commit and push below, so an answer stays out
     of that commit. Either way an answer is written to the worktree's copy of the task file, uncommitted, and
     rides to `close` with the work.
     **With an upstream**, the pick instead happens here, in the worktree. Bring in the carried files (above) and
     an answered root. Flip `status:` to `in-progress`, together with any caller's pick-time lines such as
     [[fix-next]]'s. Commit exactly those files as `TASK-NNN: pick` on the task branch, then run
     `git push -u <remote> task/TASK-NNN`. **The pushed branch is how every other session
     and clone knows the task is taken** — the default branch's copy still reads `todo` until the merge —
     so a failed push is reported by name: *in progress here, unseen elsewhere until pushed*. The
     dashboard is not regenerated in the worktree.

   **Report lines** — fixed, one per outcome, never a shared line for two. A run that meets two outcomes prints
   both lines, in the order the run reaches them: a worktree pick with an upstream prints *in a worktree*, then
   *upstream*.
   - in a worktree: `workspace: in a worktree at <path> on task/TASK-NNN — proved: git rev-parse --show-toplevel = <path>`
   - fell back: `workspace: fell back to in-place — <reason>; continuing in the main copy at step 7`, the reason being `worktree-root undeclared`, `the main copy is not clean on <default-branch>`, `the move did not stick: expected <path>, got <toplevel>; worktree and branch removed`, or `git worktree add failed: <git message>`
   - no effect: `workspace: worktree has no effect under integration: single-branch — there is no task branch to put in a worktree; working in place. Neither setting was changed.`
   - invalid value: `workspace: '<value>' is neither in-place nor worktree — treated as in-place for this run; correct it in tasks/.config.yml.`
   - refusal: `worktree-root '<value>' resolves inside this repository (<absolute path>) — refused; worktrees live outside the repository. Working in place.`
   - upstream: `workspace: upstream (<default-branch> → <upstream>) — task/TASK-NNN pushed to <remote>; the default branch is left untouched`
   - ff refused: `workspace: upstream — git merge --ff-only <upstream> refused (<git message>); merge the incoming changes by hand, then pick again. Nothing else was changed.`
   - fetch failed: `workspace: upstream — git fetch <remote> failed (<git message>); tasks other clones have taken may not be visible.`
   - local ahead: `workspace: upstream — <default-branch> has <n> commits <upstream> lacks; get them onto <upstream> through a PR, then pick again. Nothing was changed.`
   - not pushed: `workspace: upstream — task/TASK-NNN could not be pushed (<git message>); in progress here, unseen elsewhere until it is.`
   - no branch: `workspace: upstream — no task branch was cut (the main copy is on <branch>, not <default-branch>); TASK-NNN is in progress here and unseen by every other clone.`
   - taken elsewhere: `workspace: task/TASK-NNN already exists on <remote> — another clone has this task; nothing was changed.`
   - wrong tree: `workspace: this session is inside a linked worktree (<toplevel>) — pick from the main copy (<main copy>); nothing was changed.`
   - resumed: `workspace: resumed in the worktree at <path> on task/TASK-NNN — proved: git rev-parse --show-toplevel = <path>`
   - prunable: `workspace: task/TASK-NNN is held by a worktree whose folder is gone (<path>) — not pruned; run git worktree prune if that folder is truly gone, then pick again.`
   - not resumed: `workspace: could not enter the worktree at <path> (got <toplevel>) — nothing was removed; enter it yourself, or run this from a session that can.`
   - no worktree: `workspace: no worktree holds task/TASK-NNN — continuing in place.`
   - leftover: `workspace: TASK-NNN already has <what was found> from an earlier pick — nothing was changed; resume it rather than pick it again.`

7. **Cut the task branch, then flip status to in-progress**:
   - **Cut the task branch (git/PR projects).** The default integration model is PR-per-task —
     `pick` cuts the branch, `close` is the merge gate. If the project is
     a git repo on its default branch, offer to cut `task/TASK-NNN` so the work is isolated and
     `/tasks close` can open one PR for it. Put this question:

     > **Cut `task/TASK-NNN` from `<default branch>` for this work, so `/tasks close` can merge it as one unit? [Y/n]**

     **No answer, or nobody to ask:** cut the branch, and report
     `cut task/TASK-NNN — the documented default for integration: <value>; nobody chose it`. The default is
     read off `integration:`, the declaration, never off the git log. Under a policy that merges through task
     branches, working on the default branch is the one outcome the policy rules out, so a run that skipped
     the cut would be choosing against the declaration. A cut nobody wanted costs one `git switch` back; a
     task committed on the default branch costs a rewrite. An absent `integration:` line reads as the
     template's documented default, `pr-per-task`, and the report names it as absent too.
     Skip silently for non-git/local-only projects, or if
     the user is already on a suitable branch. **Under `workspace: worktree` the declaration has answered
     this offer**: a step 6b that fell back reaches here and **cuts the branch in place without
     asking**, and a step 6b that entered its worktree never reaches here at all.
     - **`integration: single-branch` in `.config.yml` → don't offer a branch at all.** Some repos
       commit straight to the default branch; asking every time is noise, and inferring the policy
       from `git log` guesses wrong on a squash-merge history (which looks identical to
       commit-to-main). The config field is the answer; read it rather than reading the log.
   - **Unborn HEAD** (freshly-initialized repo, no commits — `git rev-parse HEAD` fails): there is
     no base to branch from or diff against. Offer to make the initial commit first
     (`chore: initial scaffold`, staging the current tree), then cut the task branch. Don't start
     work on an unborn branch — `close`'s diff/merge gate would have nothing to compare.
   - **Then flip the status.** Use Edit to change `status: todo` (or whatever current) → `status: in-progress`,
     in whatever checkout the cut left. Cut first so the flip is made where it stays: on the task branch,
     uncommitted, until `close` commits it with the work. An edit made on the default branch and carried by
     `git switch -c` lands in the same place but reads as if the default branch had been written. After step
     6b's no-upstream fallback, 6b's pick commit already carries the flip, so this edit changes nothing.
   - **Offer to record a PR or commit that already exists.** Put this question:

     > **Is there already a PR or commit for TASK-NNN? Give its number or SHA to record in `pr:`, or leave it empty.**

     An empty answer, no answer, or nobody to ask: leave `pr:` null and report nothing about it.
     `/tasks close` step 7 fills it when it commits the work, so a null here is the normal state, not a gap.

8. **Regenerate dashboard — only where the status flip landed on a default branch with no upstream.** The
   rule is [close.md](close.md) step 10's, for the same reasons; read it off where step 7 left the flip:

   | Where step 7 left the checkout | Do |
   |---|---|
   | the default branch (no cut: `single-branch`, cut declined, not a git repo), with no upstream | chain to triage logic |
   | a branch that is not, or may not be, the default branch (no cut because of that, or the default branch not determined, [SKILL.md](../SKILL.md) § *The default branch is derived*) | **write nothing**: a dashboard written there would land on the wrong branch |
   | a task branch cut in place, the flip uncommitted there or committed by 6b's fallback pick commit | **write nothing**: that checkout is the task branch, and a dashboard written there rides into its close commit, the per-task conflict step 6b's worktree avoids |
   | anywhere, with an upstream (`git rev-parse --abbrev-ref <default-branch>@{upstream}` succeeds) | **write nothing on the default branch**, which must stay a mirror of the remote. Print `TASK-NNN is now in-progress — dashboard not refreshed; run /tasks triage through a PR` |
   | in a worktree (step 6b entered one) | never reached here: with no upstream 6b runs the first row itself, on the default branch before the worktree exists; with one it writes no dashboard |

9. **Hand off to work**:
   - **If the task file carries the inferred-values line** (`> Filed with nobody to answer — inferred, not
     chosen: <fields>.`, written by [new.md](new.md) § *Unanswered questions*) → print it first, as
     `⚠ TASK-NNN was filed with nobody to answer — <fields> inferred, not chosen. Check them before relying
     on them, and delete the line once they are confirmed.` A parent or priority nobody chose has already
     placed and ranked this task, so the person starting it is the first who can catch a wrong guess.
   - **Dispatch on `assignee:`.** The values are the ones the template's `# assignee —` comment names
     ([templates/TASK.md](../templates/TASK.md)); a value something writes with no row here is a defect in
     this table, because a value that matches nothing falls through to whatever the reader guesses.

     | `assignee:` | Do |
     |---|---|
     | `agent`, `unassigned`, or the older `ai` (read as `agent`) | present the task body as the work brief, then put step 9b's detached offer. `unassigned` dispatches the same way: picking it in a conversation is the claim. `pick` never rewrites the field |
     | an installed agent type's name (`CSharpCodingAgent`) | offer to spawn that agent type, under step 9b's brief, report and contract table, since a spawn with no contract has the same unattended gaps |
     | `human` | print the task body and wait. No detached offer: running a person's task in a subagent would override their assignment |
     | anything else (`jana`) | treat it as a person: print the task body, print `assignee: <value> is not an agent type here — treated as a person`, and wait |

   - **A task this skill already started detached** (`picked-by: tasks-pick` with a `## Progress log`) is
     resumed, not re-offered. Put this question:

     > **TASK-NNN was started in a subagent and its log ends at "<last log line>". Resume it detached? [Y/n]**

     **No answer, or nobody to ask:** this conversation resumes it from the log. Reconcile the log with git
     first, as [[fix-next]] step 0 does: where they disagree, git wins.
   - **If `jira-key:` is set in frontmatter** → suggest invoking the `jira-task` skill, if one is installed, so the user gets the full ticket workflow (intake → triage → fix → close-out).
   - **If `github-issue:` is set and `.config.yml` declares `mode: hybrid` with `external.provider: github`** → fetch comments via `gh issue view <num> --comments` so the AI agent picks up any clarifications added in GH. **Under any other mode the field is a leftover** (a repo that went from `hybrid` back to `local` keeps its `github-issue:` values): fetch nothing and print `github-issue: #<num> not fetched — mode: <mode>`. A repo that declared it does not sync must not be called.
   - **State the boundary before starting.** The task's `## Acceptance criteria` are the target and
     its `## Out of scope` is the fence. Anything surfacing outside them during the work — a
     refactor the change exposes, a bug found in passing, a plan step that's really its own unit —
     goes to [`/tasks spawn`](spawn.md): **offer it unprompted**, don't append a criterion to this
     task, don't silently do the extra work, don't drop it. Spawn inherits this task's parent and
     `feature:`, rewrites the displaced plan step to `→ deferred to TASK-NNN`, reconciles the
     feature ledger, and returns here so the thread isn't lost.

9b. **Detached run — offer to run the task in a subagent.** A subagent starts with a clean context: no
   conversation, but this project's guide and installed skills load for it, which is what running a task
   needs (it is *not* a cold reader). Steps 1–8 have already run here, with the user present, so the branch,
   the checkout and the plan exist before it starts.

   **The test** decides the offer's default. It is read off the task file alone, so two readers reach the
   same answer:

   | # | Passes when | Fails on |
   |---|---|---|
   | T1 | `## Acceptance criteria` has at least one item, and every item names what decides it: a command, test or lint whose result decides it, or a named file, section or field whose presence, absence or value decides it | the first item that does neither, quoted |
   | T2 | none of these is present: an `Open decision` in Context, a `⚠ Acceptance criteria question:` in the plan, a `⚠ split signal — not spawned` mark, a `blocked:` field | the marker, quoted |
   | T3 | announced, never fails: a Human test plan with real steps means the run ends at `verify` | — |

   Passing: *"`bash .github/workflows/skills-lint.sh` passes"* (a command decides it). Failing: *"the offer
   says when detached is the wrong choice"* (nothing named decides it; a reader must judge).

   Put this question, with `[Y/n]` when the test passes and `[y/N]` when it fails:

   > **Run TASK-NNN in a subagent? It starts with a clean context, loads this project's guide and skills, and works from the task file alone; this conversation waits for its report. Detached test: <passed | failed: T<n> — "<the quoted item>"; a detached run stops there>.<" Ends at verify: 1 manual test step." or " Ends at verify: N manual test steps." when T3 announces> [Y/n]**

   An empty reply takes the default. **No reply, or nobody to ask:** this conversation does the work. A
   detached run reports back to a person, and with nobody present a second unattended layer adds nothing.

   **The brief** is the task file's absolute path, the checkout path and branch from steps 6b–7, and this
   instruction: *the task file is your brief: its Acceptance criteria are the target, Out of scope is the
   fence, the Implementation plan is the plan. Detached test: <passed | failed: T<n> — "<the quoted item>">. If it
   failed, do no work: take the decision stop at that item, with the question `what decides "<the quoted item>"?`
   for T1, or the marker's own question for T2. Spawn nothing: list any work you find outside the criteria in
   your report as `found, not filed:`, and add no bullet to `## Out of scope`. Write tree changes only through the `tasks` verbs. Answer
   every ask from the table in `pick.md` step 9b. Set `picked-by: tasks-pick` and append one `## Progress
   log` line per step as it happens. End with `/tasks close TASK-NNN --unattended`.* **The conversation is
   not handed over**, so anything this conversation knows that matters goes into the task file before the
   spawn, or it is lost.

   **The report** starts with one of these lines, then lists every inferred field, every unmet criterion,
   and one line per piece of work found and not filed, `found, not filed: <what> — <where it was seen>`, with
   `; no feature decision covers it` added when that applies:
   `closed: done — <pr or sha>` · `parked: verify — <n> manual step(s)` (`1 manual step` for one) ·
   `stopped: decision pending: <the question> — kept on task/TASK-NNN` · `stopped: <the verb's own line>`.
   This conversation prints it, re-reads the task's `status:` and last log line, and says so when they
   disagree with the report. The file wins. A `found, not filed` line is the person's to file with
   `/tasks spawn`, or to drop; the run's last log line repeats them, so the file keeps them too.

   **When the detached test failed, the failing item is the run's first decision**: the run stops before any
   work, at the first criterion that failed T1 (or at T2's marker), and does no work beyond steps 1–8. A
   failing test is the signal that the task needs a person, so judgement spent before the stop is spent on a
   guess. **A decision only a person can take stops the run**, by [[fix-next]]'s decision-pending pattern (its
   § *Guardrails* and § *A run that ends without a fix* own it): the question goes into Context under
   `Open decision`, `/tasks block TASK-NNN --reason "decision pending: <the question>"`, the record and any non-controversial work are committed as
   that pattern says (on the task branch, which is kept, or on the default branch when no task branch was cut, as
   `TASK-NNN: blocked — decision pending`), and the log ends
   `step <n> — blocked: decision pending: <the question>`. Never guess.

   **The detached contract table.** Every point that would ask the user has a row. An ask reachable in a
   detached run and missing here is a defect in this table, not a judgement call, the same rule `close`'s
   `--unattended` table states.

   | Point | Interactive | Detached |
   |---|---|---|
   | step 2b debt, step 4 choice, blocked edge case, step 6 plan / replan, step 6b root, step 7 branch / `pr:` (on 6b's worktree path, `pr:` is put at its **Match**) | asked | asked here, before the offer; never re-asked |
   | step 9 inferred-values line | printed with ⚠ | recorded as `inferred, not chosen: <fields>` in the first log line and in the report; the line is never deleted |
   | step 9 `jira-key:` → `jira-task` | suggested | not invoked; named in the report |
   | step 9 `github-issue:` comments | fetched per mode | fetched by the subagent under the same rule |
   | entering the checkout | step 6b's proof | prove `git rev-parse --show-toplevel` is the brief's path; a mismatch stops and reports, never falls back, because the worktree holds the branch |
   | [plan.md](plan.md) 5b split offer, step 7 grill | asked | their own answer-less paths: not spawned and marked; grill not run |
   | the detached test failed | — | the decision stop above, before any work |
   | adjacent work found mid-task → [spawn](spawn.md) | offered | **not spawned**: listed in the report as `found, not filed:` and kept out of `## Out of scope`, so the close does not spawn it |
   | scope escalation, shapes 1–2 ([spawn.md](spawn.md) § *Scope escalation*) | no ask | the same |
   | scope escalation, shape 3 | steps 1–4, then ask | steps 1, 2 and 4, the residue listed as `found, not filed:` in place of step 3 and the criterion marked `⚠ NOT MET — residue found, not filed`, then the decision stop above in place of step 5 |
   | a decision only a person can take | asked | the decision stop above |
   | the close | the user runs `/tasks close` | `/tasks close --unattended`; its own table governs, so manual steps park at `verify`, and 5d spawns only the `## Out of scope` bullets the task's author wrote, since the run adds none |

## Edge cases

- **No candidates match filters** — print empty result, suggest broadening (`--status todo,in-progress` or drop filters). Blocked tasks are already listed, marked, so there is no `blocked` status to add.
- **Multiple in-progress by same assignee** — after the choice, count the other tasks with the chosen task's
  assignee that are in progress *here*: each whose own file reads `in-progress`, plus each on step 3's "in
  progress on this machine" line (assignee read from its branch copy, the read step 3 already made). `agent`,
  `unassigned` and the older `ai` count as one assignee, all three being work for this conversation (step 9).
  A task under `taken (hidden)` never counts, because another session or clone holds it, though the
  [Collection pass](../SKILL.md#collection-pass) shows it as in progress. A resume does not count the task it
  resumes. With one or more, warn ("you already have <n> task(s) in progress: <ids>; consider closing one first", `1 task` for one)
  but don't block.
- **Task is blocked** (either form) — a blocked task cannot be started (FEATURE-003 D7). Put this question:
  > **TASK-NNN is blocked: "<reason>". Unblock it and start?**
  > · **Yes** — run [`unblock`](block.md), then continue this pick. · **No** — leave it blocked; pick something else.

  **No answer, or nobody to ask:** do not start it and do not unblock it; report `not started: TASK-NNN is
  blocked: <reason>` and stop. Starting blocked work, or clearing someone's block unasked, overrides a
  decision a person made.
- **Task is `done` or `cancelled`** — error; suggest `/tasks new` if user wants to redo work.
- **Dependencies not met** — if `depends-on:` lists tasks that aren't `done`, warn but don't block. Print which dependencies are still open.
