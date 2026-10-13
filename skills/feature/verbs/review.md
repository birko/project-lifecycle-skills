# /feature review — the completeness gate

Three checks before a feature is called done: it's **complete** (every decision built and every task merged — code correctness was already reviewed per task at each `/tasks close` merge gate), the manual tests were actually run, and the stakeholder signs off. This is a *completeness* gate, **not** a wholesale code re-review — reuses existing skills rather than reinventing review.

## Steps

1. **Locate the feature**; read `decisions.md` and collect its tasks (Grep `tasks/` for `feature: FEATURE-NNN`).

2. **Gate A — Completeness** (code correctness was already reviewed per task at each `/tasks close` merge gate — don't re-review wholesale):
   - **Every `approved`/`changed` decision is decomposed**, and **every linked task is merged** — Grep `tasks/` for `feature: FEATURE-NNN`; any still-open task means the feature isn't done (list them and stop).
     - **Merged means `done`, or awaiting verification with its work on the default branch.** Read each
       status by [[tasks]] § *Lifecycle* → *Reading a task's status*. A `verify` task (or `review`, the older
       form) is built and is waiting only for its Human test plan, which is Gate B's question, not this one.
       Stopping on it here would loop: [pick.md](pick.md) sends a feature whose tasks are all `done` or
       `verify` to this verb, and step 5 below parks tasks at `verify` for the next review to pick up.
     - **Open is everything else**: `todo`, `in-progress`, blocked in either form, and a `verify` task whose
       work is still on an unmerged branch. That is a `close` that parked on a task branch, in place or in a
       worktree, leaving the code on `task/TASK-NNN` (on a PR project, with a PR awaiting sign-off):
       `git branch -a --no-merged <default> --list "*task/TASK-NNN"` names the branch. Without git, or with no such branch, a `verify` task's work is on the default branch.
   - **Register-on-introduce confirmed:** if the feature introduced a new cross-cutting pattern, confirm it was recorded in `CLAUDE.md § Conventions` (and `## Architecture` if structure changed) — run [[verify-conventions]] to flag an unrecorded one. (Per-task `verify-conventions` + `code-review` already ran at each `/tasks close`; this is the feature-wide *confirmation*, not a re-run.)
   - **Fidelity confirmed:** run [[verify-intent]] over the feature's cumulative diff against its
     **approved and `changed` decisions** — the feature-level statement of what was asked, where each
     task's `close` checked only its own acceptance criteria. This is the *confirmation*, not a re-run: a
     decision that no task's criteria ever covered is the gap it exists to catch, and it is invisible
     per-task by construction. Keep its verdict **separate** from the completeness findings above; the two
     axes are never merged or reranked (see [[tasks]] `close` step 5b).
   - **Spec landing check** — only when the project has a **usable** spec map (`docs/specs/.map.yml` with a non-empty `areas:` list; if the map is missing **or still the empty scaffold seed**, the check cannot run: say so and require `/specs init` + a regen before sign-off — or the explicit `no spec surface` carve-out below — rather than skipping silently). The feature's behavioral change should have landed in the specs: Grep `docs/specs/*.md` frontmatter for `shaped-by:` containing FEATURE-NNN — **and read each spec's `shaped-by-derived:` alongside it**, because "not listed" means two opposite things:
     - **Provenance was never derived** (`shaped-by-derived:` is `false` or absent — the [[roadmap]] DV11 condition) → the answer is **unknown, not a miss.** An un-derived `shaped-by: []` says nothing about this feature, and failing the gate on it reports a *generator* gap as a *feature* gap — sending someone to re-spec behavior that may already be specced. Run `/specs regen` over the candidate areas first (regen derives `shaped-by` from task-commit evidence on **every** run — [[specs]] regen step 5a), then re-read and judge the derived answer. DV8 suppresses itself on these areas; **this gate must not be stricter than the audit it mirrors.**
     - **Provenance was derived and the feature still isn't listed** → now it's a real finding. Run `/specs regen --feature FEATURE-NNN` and review the diff (the [[specs]] harvest-with-diff-review pass). Its **expected-but-missing** outcome is a failed completeness check: an `approved` decision whose behavioral change doesn't show up in any spec diff means the feature isn't done — route it back to a task. **Check `shaped-by-unresolved:` before you call it:** a non-zero count means the derivation saw only part of the trail (tasks with no `pr:` and no commit naming them), so "not listed" is weaker than it looks. The `--feature` regen resolves this feature explicitly and settles it either way — so run it *before* routing work back, and say the count out loud if you route anyway.
     - **Genuinely docs-only/internal** — such a feature may legitimately land nowhere. Record a History line containing the literal phrase **`no spec surface`** (e.g. `{{DATE}} — no spec surface (docs-only), confirmed at review`) — [[roadmap]]'s DV8 greps for exactly that phrase to suppress the flag. Use it only once provenance *was* derived; before that there's nothing to carve out of.
   - **Optional cumulative passes** — for a large or cross-cutting feature, run [[code-review]] on the *cumulative* diff to catch cross-task **integration** issues a per-task review can't see, and [[security-review]] if the feature warrants it (pass `--comment` for inline PR comments). **Both are cross-task-seam passes, not backstops** — each task's own `close` already ran `code-review`, and ran `security-review` if its diff touched a security surface. If you find a task that merged a security surface without that pass, that's the finding: route it back to a task, don't quietly cover for it here. These are runtime-provided skills (Claude Code built-ins); **if this runtime lacks them, do the pass inline** — read the cumulative diff for cross-task seams (conflicting assumptions, duplicated logic, merge artifacts) and, when security-relevant, for auth/input-handling/secret-exposure issues. Route any blocker back to a `/tasks` (new or reopened task) — never a silent fix here.

3. **Gate B — Human test plan verification** (the part automated review can't do):
   - For every task with `feature: FEATURE-NNN`, read its `## Human test plan`.
   - Read every step as **passed**, **failed** or **not run**, by [[tasks]] § *Lifecycle*'s table: `[x]` is passed; `[ ]` whose last nested line starts `**Failed YYYY-MM-DD:**` is failed; any other `[ ]` is not run.
   - Each plan must be either: every step passed, or explicitly `N/A — fully covered by automated tests`.
   - **An `N/A` is a claim, so check it.** Look for the coverage it names: the test file, the test, or the
     assertion its reason describes. When the plan names nothing specific, look for any test of the code the
     task changed. **Coverage that is not there makes the `N/A` false**, and a false `N/A` is an unsatisfied
     plan, read exactly like a step not run. Gate B is unmet, the task is listed, and step 5 parks it at
     `verify`. Report it on its own line, so nobody reads it as an unrun step:
     `TASK-NNN — N/A claimed, coverage not found: <what was looked for>`. Two remedies clear it: write the
     test the plan claims, or replace the `N/A` with real steps and run them. Either way, the task is then
     closed again through `/tasks close`.
     - **Why this is not left to the reviewer's judgement:** two runs of this gate on the same task disagreed.
       One reopened it, and the other left it `done` because no step had been written to park it on. A gate
       whose outcome depends on which reading a runner chose cannot be re-run to the same result.
   - **Report the three states on separate lines, per task**: `TASK-NNN — N passed, N failed, N not run`, and under it each failed step with its date and the task ids its line names. Never fold a failed step into *not run*: a plan that was run, at real cost, must not read the same as one nobody touched.
   - Any failed step → Gate B fails. A failure is not resolved by running the step again unchanged; the work its line names has to land first. List those task ids as what blocks the feature.
   - Any step not run → list it and ask: *"These steps have not been run: <list>. Run them now, or confirm the plan is N/A, and tell me the result of each."* No answer → Gate B stays unmet and the feature is set to `review`, as step 5 describes. This is the same check `/tasks close` runs per-task; here it's enforced feature-wide so nothing slips through.
   - Capture the result (who tested, when) — note it in the feature's `decisions.md` History log.

4. **Gate C — Stakeholder sign-off:**
   - Summarize for the stakeholder (PM / product owner): what was approved, what shipped, what was deferred/removed and why (straight from `decisions.md`).
   - Ask for explicit sign-off. Record it as a History line: `{{DATE}} — FEATURE-012 signed off by <PM> after review`.
   - If the stakeholder rejects or requests changes → add/flip decisions (`/feature decide`), which feeds back into `decompose`. The loop reopens; the feature is not done.

5. **Set the coarse status honestly:**
   - **Whichever branch below runs, if it changes `idea.md`'s `status:` or parks a task, chain
     `/feature status FEATURE-NNN` (single-feature mode) after it.** The stakeholder rollup must never lag the
     review. If `status.md` and the index row still read `building` while `idea.md` says `review`, the rollup
     is wrong, which is the case [status.md](status.md) names. This is stated once, here, so a branch added
     later is covered too.
     **A park changes the task tree too, so also chain [[tasks]] `triage`** whenever step 5 parked a task or
     reopened a container. Otherwise the review's commit carries a `tasks/README.md` that contradicts the task
     files committed beside it. With an upstream the dashboard rides on `record/FEATURE-NNN` with the rest
     (step 5b), like `status.md` and the index. Left off, the parked task files would land beside a stale
     dashboard, and a conflict between two record branches' dashboards is fixed by re-running `triage`, while
     a stale one goes unnoticed. `triage`'s own rule skips it inside a task's linked worktree.
   - **All three gates pass** → `idea.md` frontmatter `status: done`, so the chained rollup shows phase `done`. Gate A let only `verify` tasks through without being `done`,
     and Gate B has now passed their plans, so name each one and suggest `/tasks close TASK-NNN` for it: that
     moves it `verify → done` through its own gate. Don't flip them here. With no `verify` task, suggest nothing.
   - **Changelog nudge** (don't auto-run): a feature reaching `done` is a genuine ship event, so if the project has a `CHANGELOG.md`, print one line — *"FEATURE-NNN shipped — consider `/roll-changelog` to record what changed for users."* The changelog is a human-curated summary, so leave the call to the user; just make sure they don't forget. Skip the nudge if there's no `CHANGELOG.md`.
   - **Gate A passes + code/tasks complete, but Gate B/C sign-off hasn't happened** (e.g. stakeholder unavailable, or you're parking it for a later playtest) → set `status: review`, **not** `done`. The feature is built but unsigned — verification debt. Park any client tasks awaiting sign-off at `status: verify` — the task status; `review` is this feature's own marker. **That means every linked task whose plan Gate B did not pass**: a step not run, a step failed, or a false `N/A`. Gate A has already required all of them to be `done`, so parking moves `done → verify`, the same move [decide.md](decide.md) makes for a surface-dependent revert. A task whose plan passed stays `done`. Never write "done (pending)". **Then roll the park up** by [[tasks]] § *Roll status up to parents* (the reopening direction), and name each container it reopened in the confirmation. Its files are among the ones step 5b commits.

5b. **Commit what this run wrote** — whichever way the gates went. A review that fails writes too: Gate B's
   result and a `pending` sign-off are History lines. Left uncommitted, the record of the review sits in a
   dirty tree that no step owns. It then rides into whatever unrelated commit comes next, or is lost with it.
   The next `/tasks close` meets it as somebody's uncommitted work. This is the rule `/tasks close` follows for
   a container close, and for the same reason: a gate's verdict belongs in a commit of its own.
   - **The files are the ones this run wrote**, counted off the steps that ran rather than from a list here:
     `decisions.md` when a History line was added, `idea.md` when step 5 changed its `status:`, each task
     file step 5 parked at `verify`, each `STORY.md` or `EPIC.md` the park reopened, `tasks/README.md` when `triage` ran, and `status.md` and `docs/features/README.md` when `/feature status` ran. A run that wrote nothing, such as
     Gate A stopping on open tasks, has nothing to commit.
   - **Git repo, no upstream** (`git rev-parse --abbrev-ref <default>@{upstream}` fails) → commit exactly
     those files and nothing else from the index:
     `git commit --only -m "chore: review FEATURE-NNN" -- <the files written>`. The subject does not lead
     with a task id, so [[specs]] attributes no behaviour to it: a review changes no code. No
     `Co-Authored-By:` trailer.
   - **With an upstream** → commit the same files on a branch of their own, `record/FEATURE-NNN`, by the
     record-branch rule in [[tasks]] `close` § *Closing a STORY / EPIC* step 5, with the subject above. A
     review's record must not be committed on a default branch that has to mirror its remote, and left in the
     main copy it is carried silently onto the next task branch and never landed. Step 6 names the pushed
     branch, or, when the rule stops, its line and every file left uncommitted.
   - **No git** → commit nothing. Step 6 names each file as uncommitted.
   - **Files another verb wrote stay that verb's to commit.** A `/specs regen` run from Gate A writes spec
     files whose diff the user accepts or rejects, so this step never commits them. Step 6 names them as
     uncommitted.

6. **Confirm** — print the gate results (✅/❌ per gate) and the final state, then the commit from step 5b, the
   `record/FEATURE-NNN` branch it pushed, or **every file left uncommitted, by path**. Never end without one of those: a clean report over a dirty
   tree is the defect step 5b exists to remove.

## Edge cases

- **Some tasks still open / unmerged** — Gate A fails by definition (completeness); list the open tasks and stop. There's nothing to sign off until the work is merged. A `verify` task whose work is on the default branch is not open (Gate A); its plan is Gate B's.
- **Optional cumulative pass finds a blocker** — a cross-task integration bug or security issue is real verification debt: open (or reopen) a `/tasks` for the fix and hold the feature at `review` until it's merged. Don't fix silently inside the review step.
- **Stakeholder unavailable** — set `status: review` (not `done`); record sign-off as `pending` in the History log. Close it later by re-running `/feature review` once signed off.
- **Review surfaces a contested decision** — re-grill *just that branch* with [[grill-me]], then `/feature decide` to re-stamp; don't re-grill the whole feature.
