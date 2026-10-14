---
name: fix-next
description: Drain a defect backlog — pick the highest-blast-radius outstanding fix, re-verify the finding, fix the root cause, prove the regression test can fail, respec, and close it through the merge gate — then stop where resetting the session loses nothing. Use when the user says "/fix-next", "fix the next thing", "what should I fix", "pick a bug and fix it", "drain the review backlog", "continue the remediation", "implement the review findings", "oprav dalsiu chybu", "pokracuj v opravach", or wants autonomous progress through a review/audit backlog without holding context across sessions. RESUMES an interrupted run before picking new work — all state lives in the task file and git, never in the conversation. It drains what [[tasks]] `intake` files from a review pass. Distinct from [[tasks]] `pick` (any task, interactive) — this narrows to defects, ranks by blast radius not `priority:`, and owns the verify→fix→prove→respec→close loop unattended.
---

# fix-next

One invocation = **one defect**, taken from "which is worst" to committed-and-closed, ending at a
boundary where **resetting the session loses nothing**.

That last property is the whole point, and it drives every rule below: **the conversation is not the
state.** The task file and the git history are. Anything you know that isn't written to one of those
two places is gone the moment the user runs `/clear` — so write it down as you go, not at the end.

This is the **drain** half of a two-part pipeline. The **intake** half is
[`/tasks intake`](../tasks/verbs/intake.md), which files a review pass as EPIC → STORY → TASK. Neither
half guesses: intake stamps the epic `kind: review-intake`, and this skill reads that stamp.

```
/code-review · /security-review · /specs regen  ──▶  /tasks intake  ──▶  /fix-next
        (find)                                          (file)            (drain)
```

## Modes

`/fix-next [--loop] [--epic EPIC-NNN]`

- **bare** — one defect, then **stop**. The default, and the recommended way to run it.
- `--loop` — keep going to the next pick until the pool is empty, context runs short, or a question is
  pending (step 9 says which questions halt it). Higher throughput, at the cost of the clean boundary.
- `--epic EPIC-NNN` — restrict the pool to one epic.

## Step 0 — Resume before you pick (ALWAYS FIRST)

Never select new work before establishing that no run is already in flight. A reset session is
indistinguishable from a fresh one except by what's on disk, so look there: find the task root
([[tasks]] § Shape detection), then look in **three places, independently**:
- grep `tasks/` for `^status: in-progress` in `TASK-*.md`;
- **the committed copy of every task file that `git status --porcelain -- tasks/` reports as modified.**
  `close` writes the new status (its step 6, or step 5's `verify` park) before committing it. A run interrupted
  between the two leaves the working copy reading `done` or `verify` while `HEAD`'s copy
  (`git show HEAD:<task file>`) reads something else, or does not exist yet. On an in-place project that is
  usually `todo`, because an in-place pick commits nothing. The grep above misses that file, and a reset drain
  would start a second task on top of the uncommitted work. Such a file counts when its working copy reads
  `done` or `verify`, `HEAD`'s does not, and the working copy carries `picked-by: fix-next`. **Resume it at
  step 8**: rerun `close`, which treats a `done` or `verify` it never committed as unwritten (its step 4) and
  so runs its gate again;
- **the task branches too, on any project whose `pick` cuts them** (every `integration:` but
  `single-branch`). List local `task/*` branches
  (`git branch --list "task/*"`) and read each one's task file with `git show task/TASK-NNN:<task file>`.
  With an upstream the default branch's copy of an in-progress task still reads `todo`, so the grep alone
  never finds it. Worse, the pool rule below hides it as taken, and a reset drain would start a second
  task and abandon the first. A branch copy counts only when it reads **`in-progress`** and is **not
  blocked**. Read the status in both forms ([[tasks]] § *Lifecycle* → *Reading a task's status*). A copy
  parked at `review` or `verify`, one blocked by either form, or one reading `done` after a failed merge is
  not an active run.
  **One exception: an unfinished landing.** A branch copy carrying `picked-by: fix-next` whose last log line
  is `step 9 — ended without a fix: …; recorded on task/TASK-NNN; landing` was committed and never landed,
  whatever status it reads. Resume it at that landing (§ *A run that ends without a fix*), and pick nothing
  else in this run. A branch the run deliberately kept ends `…; kept` instead, and is not resumed.

For each hit, read the file — **the branch copy (`git show task/TASK-NNN:<task file>`) for a hit found on a branch**, since with an upstream the default branch's copy carries none of this. **Only resume tasks this skill owns** — they carry `picked-by: fix-next`
in frontmatter and a `## Progress log` section. Anything else that is `in-progress` is a human's work
in flight: leave it alone, don't count it, don't report it as blocking you.

**A run of this skill's own that someone has since blocked is not resumed.** Report it as
`not resumed: TASK-NNN (this skill's run) is blocked: <reason>`, leave its log and branch untouched, and
go on to step 1. Unblocking is a person's decision, and resuming work somebody deliberately stopped would
override it. **This line is also the expected end state of step 4's upstream path**, which blocks the task on
the upstream fix. Expect it on every run until a person unblocks the task once that fix lands; it is not a
fault to investigate.

If you find a skill-owned in-progress task:

1. **A hit found on a branch in place is resumed on that branch**: `git switch task/TASK-NNN` first, after
   checking the tree is clean, since the next steps and the landing work from that checkout.
   **Under `workspace: worktree`, resume into the task's worktree first**, through [[tasks]] `pick` step 6b's
   resume (locate, enter, prove). Only the first log line rode in the pick commit, and every later line is on
   the task branch. **Any stop in that resume stops this run too**: report its line, and do not pick a
   second task. Run step 2's reconciliation below in the tree you are now in, not the main copy.
   Then read its `## Progress log` — the last line says which step below was completed.
2. Reconcile with git: `git status --short` and `git log --oneline -3` in each repo the log names.
3. If the log and git disagree, **git wins.** The log may have been written just before an
   interruption, or the step may have half-landed. Correct the log to match reality, then continue
   from the first genuinely incomplete step.
4. Resume there. Do **not** restart from step 1, and do **not** pick a second task.

Only when nothing is in flight do you proceed.

## Step 1 — Build the pool

A `status: todo` TASK, or an old-form `status: blocked` one (see the blocked paragraph below), is in the
pool when **either** holds:

- its frontmatter carries a non-empty `findings:` list; **or**
- it sits under an EPIC stamped `kind: review-intake`.

Both are written by [`/tasks intake`](../tasks/verbs/intake.md). Nothing here infers a defect from an
epic's title or a task's prose — **the pool is explicit or it doesn't exist.** A task the [[tasks]]
Collection pass counts as **taken** — its `task/TASK-NNN` branch already exists, locally or on a remote,
because another session or clone picked it — is out of the pool whatever its file says.

**A defect found by using the product, with no review pass behind it, gets in through
`/tasks new task --from-field`**, which mints a `FIELD-NNN` into `findings:`. Naming the verb matters more
than it looks: this used to read *"joins the pool the moment someone puts its finding id in `findings:`"*,
which assumed an id the reporter does not have — every prefix on [intake](../tasks/verbs/intake.md)'s table
named a **pass**, and a field report has none. So the opt-in named a door with no key cut, and the failure
was silent in the worst way: a real defect sat unranked while `--loop` reported the pool empty, *truthfully*.
An already-filed task joins through the same flag's **already-filed path** in
[`new`](../tasks/verbs/new.md), which names the steps that run for it: the mint, the write into its
existing `findings:`, and the report, and nothing that creates, drafts or plans.

A **blocked** task stays in the pool, in either form: a `todo` task carrying a `blocked:` field, or an
old-form `status: blocked` task (see [[tasks]] § *Lifecycle*). It is ranked with the rest so its place in the
order stays visible, but this skill **never starts one**: step 2 skips it. It never unblocks one either,
because that is a decision about someone else's reason.

Exclude: unmet `depends-on` — **except a blocked task**, which stays in the pool as above even when its block
is one of those dependencies (`/tasks block --on` writes it there), since excluding it would hide exactly the
task the rule above keeps visible — and anything whose acceptance is *"decide X"*. A decision task needs the user
and can't run unattended. Surface those in the closing report instead.

**Check the pool is complete before ranking it — findings can be filed and never scheduled.** You are
already walking every `kind: review-intake` epic to build the pool, so evaluate [[roadmap]]'s **DV12** over
the same epics while you are there: *a STORY with unticked checklist lines in its body but no open TASK*.
Those lines are findings nobody can pick — only `status: todo` **tasks** are ranked here, by `pick`, or by
the `Next up` snapshot. Report them in the closing report and offer
[`/tasks intake --epic`](../tasks/verbs/intake.md) or `/tasks new`; **don't silently work them**, since an
unscheduled bullet has not been through the filing discipline the pool depends on.

**Respect a story that declares its findings are extracted on demand.** Some STORYs deliberately hold a
findings list and are decomposed one task at a time as work is picked — they say so in the body ("Not
pre-created. Extract on demand, one task per `SH-Mxxx`"). DV12 cannot distinguish that from a backlog
nobody scheduled, so **check for the declaration before reporting**; a story that declares it is not a
finding. Measured on a real tree: of DV12's 4 hits, **3 were deliberate** and only 1 was a genuine gap.
A check that nags about a recorded decision gets muted, and a muted check is worth what an unrun one is.
(A machine-readable marker would beat prose here — that is a live question for whoever owns the rule.)

This costs one extra read per epic and closes a real hole: DV12 is correct and was *invoked by nothing*.
A whole review-intake epic sat with three stories, one unticked line and zero tasks — so it contributed
nothing to this pool and rendered as `0/0 tasks done`, indistinguishable from an epic nobody had started.
Every ranking drew from the other epics and never noticed. The check belongs here because this is the verb
that runs most often **and** the one that would act on the answer; leaving it to a human remembering to
run `/roadmap` is what let that epic sit for three weeks.

**Verification debt comes first.** Tasks at `status: verify` (or the older `review`) are not in the pool — they're not `todo` —
but they are debt, and the house rule is that debt surfaces before new scope. Put this question before ranking:

> **<n> task(s) are awaiting verification: <TASK-NNN — title, one per line>. Their test plans need a person to
> run them. Clear them first (run each plan, then `/tasks close` it `verify → done`), or go on to the next
> defect?**

**No answer, or nobody to ask:** go on to the next defect, and list every one of them in step 9's report as
`awaiting verification, not cleared: TASK-NNN`. Never tick a step nobody ran: a person's test cannot be done
unattended, so skipping the offer is the only outcome that claims nothing. Under `--loop`, put the question
once per invocation, not once per pick. It is not a pending question for step 9, because the run never
waits on it.

**Empty pool → say so and stop. Don't invent scope.** Inventing defects to look busy is the failure
mode this branch exists to prevent. Two causes, two different offers:

- **No review has been filed** → *"nothing to drain — run a review pass and `/tasks intake` first."*
- **A review backlog exists but predates the stamp** — you can see epics that are obviously
  remediation (`todo` tasks whose bodies cite findings) but none carries `kind: review-intake`. Say
  exactly that and offer [`/tasks intake --adopt <EPIC-NNN>`](../tasks/verbs/intake.md), which stamps
  it. **Don't just start working those tasks** because they look like defects — that's the
  theme-guessing this pool definition exists to eliminate, and guessing wrong means picking a new
  capability and "fixing" it.
- **Every task in the pool is blocked** — found in step 2, which treats it as an empty pool. List each blocked
  task with its reason and stop. Offer nothing: unblocking is a person's decision (step 0).

## Step 2 — Rank by blast radius, not by the `priority:` field

`priority:` is a coarse bucket assigned at filing time — a single review can file seven tied P0s, so it
settles nothing. Order the pool by these keys, in order:

1. **Severity of the failure mode.** Authentication / authorization bypass › cross-tenant or
   cross-account leakage › silent data loss or corruption › an unbounded destructive write › wrong
   results › an unhandled exception on a hot path.
2. **Reachability.** Reachable from untrusted input beats reachable only via already-corrupted stored
   data, which beats reachable only by internal API misuse.
3. **Silence.** A defect that returns a *plausible wrong answer* outranks one that throws. Throwing is
   self-reporting; silence is what ships and stays there.
4. **Self-containment.** Prefer a defect fixable in one place with no open design question — not
   because contained work matters more, but because this skill must finish what it starts inside one
   session, and a fix that stalls on a decision leaves the tree half-done.
5. **Verified over unverified.** A finding confirmed by hand is safer to start than one filed straight
   from a harvest.

6. **Subject theme**, ordered by [`intake`](../tasks/verbs/intake.md)'s ladder table — that table is
   the single source of the order; don't restate it here or anywhere else, read it. A candidate's
   theme is **not on the task**: it is the `theme:` slug on its parent STORY, so resolve the task's
   `parent:` to that `STORY.md` and read the field there. **Never infer a theme from a title** — an
   adopted backlog is often grouped some other way (by subject, by subsystem), and a title match
   silently resolves to nothing exactly there.
7. **`priority:`** — the coarse bucket, demoted to a tie-break for the reason at the top of this step.
8. **Oldest `created`** — the last resort. It is a **date with no time**, and `/tasks intake` files an
   entire pass in one of them, so it ties routinely: twelve tasks in this repo share `2026-08-20`. Keys
   1-8 therefore do **not** guarantee a total order, which is why the "genuinely inseparable" branch
   below is a reachable path rather than dead prose — reach it and *say* the keys were exhausted, per the
   rule that a key which cannot discriminate must announce itself.

**Two candidate shapes have no theme by construction**, and they are not defects: a task in
`tasks/_loose/`, and a task parented directly to an EPIC rather than a STORY. Treat them exactly like a
STORY that declares nothing.

**A slug that is not on the ladder counts as undeclared**, and is reported as such. `--adopt`
proposes slugs for a human to correct, and a hand-stamped story can carry a typo, so an
unrecognised value is reachable — and it is neither declared nor undeclared unless this says which,
leaving its position undefined and the ranking irreproducible.

**An undeclared theme sorts *after* every declared one**, never before and never interleaved. Without
that rule a partially-declared pool — the normal state once a second intake epic exists, or straight
after an adoption — has no defined order, and two runs over the same pool can rank it differently. That
non-reproducibility is the thing this key was added to remove, so don't reintroduce it at the boundary.

**Say which key broke the tie, and say when key 6 could not.** Three cases make it inert: no candidate
declares a theme, every candidate declares the *same* one, or the pool separated on keys 1-5 before
reaching it. A degenerate ladder is normal on a repo whose defects cluster in one theme — a codebase
whose product is prose rules yields almost only correctness defects — so a run that never mentions key
6 is indistinguishable from one where the key did the work.

**Skip a blocked task that ranks first.** Walk down the ranking to the first task that is not blocked,
and write one line per task skipped on the way: `skipped: TASK-NNN — blocked: <reason>` (`reason unknown`
for an old-form `status: blocked` with no note). Those lines go into the ranking paragraph below. Step 9's
report lists **every** blocked task in the pool, above or below the pick, so none of them drops out of sight.
The **runner-up** named in the pick's log line is the next task that could have been started, never a
blocked one; when there is none, the line says `ranked above none — every other pool task is blocked`. When every task in the pool is blocked, that is an empty pool for step 1's purposes:
report the blocked tasks and stop.

State the ranking in one short paragraph — the top pick and *why it beat the runner-up* — then start.
**Don't ask which to take;** that's the decision this skill exists to make. Ask only if the top two are
genuinely inseparable on every key above:

> **TASK-AAA and TASK-BBB tie on every ranking key (1–8). Which first? Without an answer I take TASK-AAA, the
> lower id.**

**No answer, or nobody to ask:** take the lower id, and write in the ranking paragraph and the pick's log line
`keys 1–8 exhausted; took the lower id — nobody chose`. The id is a fallback, not a judgement: it makes two runs
over the same pool agree, and the line says that is all it is. It is not a pending question for step 9.

**Write the pick to disk immediately, before any code is read:**

- add `picked-by: fix-next` to frontmatter
- append a `## Progress log` section whose first line is
  `- step 2 — picked; ranked above <runner-up> because <reason>`, ending — after any tie note —
  `; inferred, not chosen: <fields>` when the task file carries the inferred-values line
  ([[tasks]] `new.md` § *Unanswered questions*). A run with nobody present cannot confirm those values, so
  it records them, and step 9's report repeats them
- `status: todo` → `in-progress` (and cut the task branch, per [[tasks]] `pick`, on a PR-per-task project —
  including its step 6b when the project declares `workspace: worktree`. This skill never answers
  6b's root question: it takes the blank-answer branch every time). **Write the two lines above so they
  ride in 6b's pick commit**: with no upstream write them first, in the main copy, since 6b commits the pick
  on the default branch; with an upstream write them in the worktree, where 6b commits the pick on the task
  branch. Written anywhere else, a reset session would take this task for a human's)

Every step below appends one line. The log is how step 0 resumes; a step that ran without a line is a
step the next session will redo.

## Step 3 — Re-verify the finding before you fix it

**Do not trust the task's own description.** Findings are filed by a reviewer reading code out of
context, and a meaningful fraction are misscoped — one will name the wrong trigger entirely. A fix
aimed at a misdescribed defect is worse than no fix, because it closes the ticket.

Read the cited source and confirm the mechanism by hand. Then:

- **Holds as written** → note it in the log and continue.
- **Real but differently scoped** → correct the task's `## Context` **and** its acceptance criteria
  *before* writing code, and say so in the log. The acceptance list is the target; a wrong target
  silently redefines "done". (Correcting a criterion *before* the work is legitimate; rewriting one
  *afterwards* to fit the result is not — [close.md](../tasks/verbs/close.md) step 6.)
- **Not a defect** → don't fix it. Rewrite the Context with the evidence, `/tasks cancel` the task, log
  it, and end the run as [§ *A run that ends without a fix*](#a-run-that-ends-without-a-fix) says.
  **A correct "no" is a deliverable**, so it is this run's one defect.

Findings travel in packs. Pull in anything in the same function that shares the root cause; file the
rest via [`/tasks spawn`](../tasks/verbs/spawn.md) rather than widening scope silently.

Log: `- step 3 — verified: <held / rescoped: … / rejected: …>`

## Step 4 — Fix at the right layer

Before writing anything, ask where the root cause actually lives: in **this** repo, or in a dependency,
shared library, or upstream package this repo consumes?

- **Symptom here, defect upstream** → **the fix belongs upstream.** Don't paper over it locally with a
  copy-pasted override, a re-implemented helper, or a shadowing subclass — that multiplies the defect
  across every other consumer and buries the evidence. Record the decision in the task (root cause,
  the proposed upstream change, what unblocks once it lands), flag it to the user, and mark the local
  side blocked on it (`/tasks block TASK-NNN --reason "<the upstream change it waits on>"`). Then end the run as
  [§ *A run that ends without a fix*](#a-run-that-ends-without-a-fix) says.
- **Root cause is this repo's *usage* of the dependency** (wrong call, missing registration,
  misconfiguration) → fix locally; the dependency is fine.
- **"The same defect probably repeats in other consumers"** is a strong upstream signal even when a
  local patch would be smaller.

Log: `- step 4 — layer: <local / upstream: <where>>`

### A run that ends without a fix

Step 3's rejection, step 4's upstream block and an unanswered decision (§ *Guardrails*) end the run here,
with no fix, drill or close.

- **It counts as the bare run's one defect.** The run has already done the work a defect costs: it read the
  code, wrote evidence into the task and changed the task's status. Starting a second candidate in the same
  session is what makes a reset unsafe, whether or not the first one ended in a fix.
- **Commit the record**, because neither `/tasks cancel` nor `/tasks block` commits, and step 9's reset check
  needs a clean tree. When the task file is on the default branch (an in-place pick that cut no task branch),
  commit exactly the files the outcome wrote, the task file and any dashboard or rollup its verb regenerated:
  `git commit --only -m "TASK-NNN: cancelled — not a defect" -- <files>`, or
  `"TASK-NNN: blocked — fix belongs upstream"`, or `"TASK-NNN: blocked — decision pending"`. A pending decision
  also commits the non-controversial work already done, since that work belongs to this task. Both lead with the id because they touch only the task tree,
  like `pick`'s commit. No `Co-Authored-By:` trailer.
- **When step 2 cut a task branch, the record goes on that branch, and whether the branch lands depends on
  what it holds.** The branch is the [[tasks]] *taken* signal: while it exists, every pool hides the task,
  and the default branch's copy keeps reading what `pick` left (`todo` after an in-place pick or with an
  upstream, `in-progress` after a worktree pick without one). A record left only on the branch is never seen.

  | Outcome | Besides the record, the branch holds | Do |
  |---|---|---|
  | cancelled — not a defect | no work: step 3 stopped before any fix | commit the record on the branch, then **land the branch** |
  | blocked — fix belongs upstream | no work: step 4 stopped before any fix | commit the record on the branch, then **land the branch** |
  | blocked — decision pending | **the non-controversial work** | commit both on the branch and **keep it**. Landing it would merge half a fix onto the default branch |

  **The branch commit carries the task tree's own record, never the dashboard.** `cancel` and `block` also
  chain `triage`, and in place that writes `tasks/README.md` on the task-branch checkout. Commit only the task
  file and any container their rollup changed, with `git commit --only` and the same subject as the in-place
  commit above, so it leads with the id. Then discard this run's own dashboard write (`git restore --
  tasks/README.md`): a dashboard committed on a task branch is the per-task conflict `close` step 10's table
  forbids. Write the step-9 log line **before** that commit, so it rides in it, as step 8 does for `close`.

  **Land the branch** through [[tasks]] `close` step 8, by whichever of its paths applies (in place, from a
  worktree, or through the remote with an upstream), with its failure lines, and never forced. Skip every
  `pr:` write it makes, the backfill and the PR number alike: there is no work commit to reference, and the
  record's own commit is the trail. Then run `close` steps 10 and 10b on the default branch, which regenerate
  the dashboard and commit it as `chore: dashboard and rollups after TASK-NNN` (with an upstream they write
  nothing, as their table says). The merge carries the `cancelled` or blocked record to the default branch,
  and deleting the branch ends the taken signal. A landing that fails stops the run with `close`'s line for
  it; step 0 resumes it.

  **A kept branch** stays as the record of an open question. Push it when the default branch has an upstream,
  so other clones see the question rather than an anonymous taken branch. Then return to the default branch:
  in place `git switch <default>`, from a worktree leave it as `close` step 8 leaves one, keeping the
  worktree. A new pick must never start on top of a kept branch. Step 0 then finds it through the branch scan
  and reports `not resumed: TASK-NNN (this skill's run) is blocked: decision pending: …` on every run, until a
  person answers and unblocks it. Name the branch in step 9's report.
- **Then go to step 9.** A bare run stops there. `--loop` continues to step 1. A cancelled task is no
  longer `todo`. A blocked one keeps `in-progress` beside its `blocked:` field, so it is outside the pool, and
  step 0 reports it on every run. A pending decision halts `--loop` too: it is
  a question waiting on a person (step 9).

Log: `- step 3 — rejected: …`, `- step 4 — layer: upstream: <where>; blocked`, or
`- step <n> — blocked: decision pending: <the question>`, then
`- step 9 — ended without a fix: <cancelled | blocked>; commit <sha> | uncommitted: <files>`, or with a task
branch `- step 9 — ended without a fix: <cancelled | blocked>; recorded on task/TASK-NNN; <landing | kept>`.

## Step 5 — Fix the root cause, with the test that proves it

Read `CLAUDE.md` § Conventions for how this project builds and § Testing for the stack, toolkit and
where tests live; chain [[populate-tests]] to author. Two hard rules:

- **Fix the root cause, not the reported symptom.** A guard against the specific input in the report
  usually leaves the general case live.
- **Never weaken a check to make something pass** — no removing an authorization check, no widening an
  isolation boundary, no loosening an assertion.

Cover every acceptance row. Name the finding id in the test's own documentation and state the
mechanism — that comment is what a future reader gets instead of this conversation.

Log: `- step 5 — fix in <files>; tests in <file>; suite N/N green`

## Step 6 — Prove the guard can fail (do not skip)

A regression suite that passes is not evidence. Run one of the checks in [[populate-tests]] §
*Prove the guard can fail* — revert-and-split, reintroduce-and-confirm, or a bidirectional assertion —
and account for the result **exactly**.

What this step owes the task file: the split **as numbers**, the fix-dependent tests **by name**, and
every still-passing test named as a **contract pin, not evidence**. A pin recorded as if it were proof
is how the next reader concludes the fix was verified when it wasn't.

This step has repeatedly been the one that finds the real problem. Budget for it.

Log: `- step 6 — reverted fix: N/M failed; fix-dependent = <names>; contract pins = <names>`

## Step 7 — Regenerate the spec for the area

Hard ordering constraint: `docs/specs/` currently documents this defect **as shipped behaviour**. The
spec for the fixed area is now wrong, and the spec diff is the fix's evidence.

Find the area whose `.map.yml` globs cover the changed files and run `/specs regen <area>`, honouring
the stable-wording rule — change only what the code now contradicts, including requirement *titles*
when they assert the old behaviour. Reviewing that diff is part of the step, not a formality: anything
in it you did not intend is a finding, and gets a [`/tasks spawn`](../tasks/verbs/spawn.md). When regen asks
whether a change was intended, this run answers from the task's acceptance criteria, as regen step 4 allows
the verb that made the change; a change those criteria do not cover is not yours to call intended.

If the project has no `docs/specs/.map.yml`, or its `areas:` list is empty, print one line — *"no
usable spec map — run `/specs init` to bootstrap the spec layer"* — and continue. Don't skip silently.

Log: `- step 7 — respecced <area>; requirements changed: <list>`

## Step 8 — Close through the merge gate

Run [`/tasks close --unattended`](../tasks/verbs/close.md). **Pass the flag.** `close` § step 2 carries
the table of what it governs — **every** step that would otherwise stop for input, including the **merge
decision at 5c, which unattended resolves as *merge***. **Read the table for the count; do not restate it
here** — it has grown twice, and a number written into this sentence is wrong the next time it grows. Read that table rather than assuming this step
knows: it grew once already, because the flag first shipped covering only the out-of-scope sweep while
5c still asked a mandatory question on PR-per-task projects — the documented default, and exactly the
projects where this skill cuts a branch. Without the flag the sweep meets a work bullet with nobody to
answer, and the reading that keeps the loop moving is to close anyway, which is the evaporation the
sweep exists to stop. **Do not re-implement any of it** — `close` already owns
[[verify-conventions]] + [[code-review]] + conditional [[security-review]] on the diff, the merge
decision, the commit (with this repo's staging and trailer discipline), the remote close, the dashboard
regen and the STORY/EPIC rollup. Never skip the gate because a review skill's name didn't resolve;
`close` carries the inline fallback.

What this skill adds, before handing over: write an `## Outcome` section into the task file covering

- what the fix was, in a sentence someone with no context understands;
- the step-6 split, with names;
- the judgement calls you made and **why the stricter option was rejected**;
- anything **flagged but not fixed**, and where it went.

*That section replaces the conversation.* Write it before `close` runs, so it rides in the same commit
as the work.

**Write step 8's log line before `close` runs too, in the same copy of the task file as the Outcome**, so
`close`'s own commit carries it. Nothing gets written to the task file after `close` starts. A line written
afterwards cannot be committed: it would need the sha of the commit that carries it, and a commit cannot
contain its own hash. That leaves the task file dirty, which fails § *Verify the reset really is safe* on
every run. Under `workspace: worktree` there may be no file left to write: `close` removes the worktree
after merging.

| Project | Copy that gets the Outcome and the line | What carries them to the default branch |
|---|---|---|
| `single-branch` | the task file in the working tree | `close`'s commit |
| PR-per-task, in place | the task file on `task/TASK-NNN`, checked out | `close`'s commit, then its merge |
| `workspace: worktree` | the worktree's copy, where `pick` step 6b put the session | `close`'s commit there, then its merge into the main copy |

The line names neither the status nor the sha, because both are settled after it is written. **The task's
`status:` records how `close` ended, and the commit is the newest one whose subject's first task id is
this task's** (the rule [[specs]] `regen` attributes by). Step 9's report quotes both from there.

Log: `- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log`

**Step 0 tells whether step 8 completed from git, never from this line.** The line is the same whether
`close` finished or was interrupted, because it is written before `close` runs. A `close` that committed
wrote some status other than an unblocked `in-progress`, because setting it is what its step 6 is for. So
step 0 no longer resumes the task: it does not find it, or it reports it as blocked. A task that still reads
`in-progress`, not blocked, with this as the last line, has no close commit: rerun step 8 from the top.
**A status `close` wrote but never committed does not count as moving it.** Step 0's modified-file search
finds that task and sends it back here.

## Step 9 — Stop clean

**Bare invocation: stop here. One defect per invocation.** Don't roll into the next one — the clean
boundary is the deliverable, and a second fix in the same session is exactly what makes a reset unsafe.

`--loop`: continue to step 1 unless context is nearly exhausted, the pool is empty, or a question is
pending. **Two questions are pending in this sense:** a scope-escalation ask ([spawn.md](../tasks/verbs/spawn.md)
§ *Scope escalation*) and a decision only the user can make (§ *Guardrails*). Wait for that answer rather than
taking new scope. The verification-debt offer (step 1), the tie question (step 2) and the cancelled-parent question
a spawn can reach ([new.md](../tasks/verbs/new.md) step 4) never halt the loop, because each has an
unattended outcome that needs no one. Either way, **name the next pick** so a reset resumes there.

Final report, short:

1. What was broken, in one sentence a reader with no context understands. For a run that ended without a
   fix: what the finding claimed, and why it was rejected or where its fix belongs.
2. The step-6 split, as numbers (none for a run that ended without a fix).
3. Anything flagged and not fixed, including every blocked task in the pool with its reason, a red
   `ci:` line from the close (quoted), and **every task id `close` spawned from the out-of-scope sweep** —
   by id and one-line subject. Nobody watched the run; if the report doesn't name them, the only trace
   is a file in the tree nobody knows to look for.
   Also **the picked task's inferred fields**, when step 2 logged any: a parent or priority nobody chose
   placed and ranked the work this run did, and the reader of this report is the first who can check them.
4. **The next pick**, named.

## Verify the reset really is safe

Before reporting, confirm all three:

- `git status --short` is clean in every repo you touched.
- The task file alone tells the whole story — acceptance, outcome, judgement calls, flags.
- Nothing you learned this session lives only in the conversation.

If any fails, fix it before finishing. **That is this skill's actual contract.**

## Guardrails

- **One task in-progress at a time.** Finish it or hand it back before picking another.
- **A finding that turns out to be a false positive doesn't get forced into a change.** Record the
  evidence and end the run per step 3.
- **A decision only the user can make** (a breaking API change, a secret rotation, a convention that
  isn't settled) → implement everything non-controversial, then stop and ask with a concrete
  recommendation. Don't guess and don't stall the parts that were never in doubt. The question:

  > **TASK-NNN needs a decision: <the question>. Options: <a>, <b>[, <c>]. I recommend <x>, because <reason>.
  > Which?**

  **No answer, or nobody to ask:** write the question, the options and the recommendation into the task's
  `## Context` under `Open decision`, block the task with `/tasks block TASK-NNN --reason "decision pending:
  <the question>"`, and end the run as [§ *A run that ends without a fix*](#a-run-that-ends-without-a-fix)
  says. Never apply the recommendation: it would read as decided when nobody decided it.
- **Never commit a secret.** If the fix removes one, the old value must be treated as leaked — say so
  in the task, and rotate rather than just deleting.
- **Scope escalation is measured, not assumed** — [spawn.md](../tasks/verbs/spawn.md) § *Scope
  escalation* owns the three shapes and the ask/no-ask rule.

## What this skill does NOT do

- **Review code** — that's [[code-review]] / [[security-review]], run by `close`'s merge gate.
- **Create tasks from a review** — that's [`/tasks intake`](../tasks/verbs/intake.md).
- **Run the merge gate, commit, merge, or roll up parents** — all `close`.
- **Choose any task at all** — that's [[tasks]] `pick`. This skill only ever picks defects, and only
  ever from an explicitly filed pool.
- **Fix more than one defect per invocation** without `--loop`.

## Conventions

- **No `Co-Authored-By:` trailers** in commit messages (inherited from [[tasks]] § Conventions).
- PowerShell-compatible (no `2>/dev/null`, no inline `VAR=x cmd`).
- Stack specifics are never hard-coded here — read them from `CLAUDE.md` § Conventions / § Testing.
  A project needing more records it there, since this skill reads it. Do not ship a project-local
  `fix-next` to override this one: on Claude Code the user-level copy resolves first, so a same-named
  local copy never runs ([[verify-conventions]] § Scope layering has the measurement).

## Related skills

- [[tasks]] — owns the backlog. `intake` fills the pool, `pick`/`close` semantics are borrowed, `spawn`
  takes everything this loop surfaces but doesn't own, `cancel` retires a false positive.
- [[populate-tests]] — owns *Prove the guard can fail* (step 6) and authors the regression test (step 5).
- [[specs]] — the step-7 regen; `docs/specs/.map.yml` maps changed files to areas.
- [[verify-conventions]] · [[code-review]] · [[security-review]] — the merge gate, run by `close`, not here.
- [[roadmap]] — DV12 flags a review-intake epic whose findings were filed but never scheduled as tasks.
