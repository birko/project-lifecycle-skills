---
name: fix-next
description: Drain a defect backlog — pick the highest-blast-radius outstanding fix, re-verify the finding, fix the root cause, prove the regression test can fail, respec, and close it through the merge gate — then stop where resetting the session loses nothing. Use when the user says "/fix-next", "fix the next thing", "what should I fix", "pick a bug and fix it", "drain the review backlog", "continue the remediation", "implement the review findings", "oprav dalsiu chybu", "pokracuj v opravach", or wants autonomous progress through a review/audit backlog without holding context across sessions. RESUMES an interrupted run before picking new work — all state lives in the task file and git, never in the conversation. It drains what [[tasks]] `intake` files from a review pass. Distinct from [[tasks]] `pick` (any task, interactive): this narrows to defects, ranks by blast radius not `priority:`, and owns the verify→fix→prove→respec→close loop unattended.
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
  pending. Higher throughput, at the cost of the clean boundary.
- `--epic EPIC-NNN` — restrict the pool to one epic.

## Step 0 — Resume before you pick (ALWAYS FIRST)

Never select new work before establishing that no run is already in flight. A reset session is
indistinguishable from a fresh one except by what's on disk, so look there: find the task root
([[tasks]] § Shape detection), then grep `tasks/` for `^status: in-progress` in `TASK-*.md`.

For each hit, read the file. **Only resume tasks this skill owns** — they carry `picked-by: fix-next`
in frontmatter and a `## Progress log` section. Anything else that is `in-progress` is a human's work
in flight: leave it alone, don't count it, don't report it as blocking you.

If you find a skill-owned in-progress task:

1. Read its `## Progress log` — the last line says which step below was completed.
2. Reconcile with git: `git status --short` and `git log --oneline -3` in each repo the log names.
3. If the log and git disagree, **git wins.** The log may have been written just before an
   interruption, or the step may have half-landed. Correct the log to match reality, then continue
   from the first genuinely incomplete step.
4. Resume there. Do **not** restart from step 1, and do **not** pick a second task.

Only when nothing is in flight do you proceed.

## Step 1 — Build the pool

A `status: todo` TASK is in the pool when **either** holds:

- its frontmatter carries a non-empty `findings:` list; **or**
- it sits under an EPIC stamped `kind: review-intake`.

Both are written by [`/tasks intake`](../tasks/verbs/intake.md). Nothing here infers a defect from an
epic's title or a task's prose — **the pool is explicit or it doesn't exist.** (A field-found bug filed
by hand joins the pool the moment someone puts its finding id in `findings:`; that's the whole
onboarding cost.)

Exclude: unmet `depends-on`, `status: blocked`, and anything whose acceptance is *"decide X"* — a
decision task needs the user and can't run unattended. Surface those in the closing report instead.

**Check the pool is complete before ranking it — findings can be filed and never scheduled.** You are
already walking every `kind: review-intake` epic to build the pool, so evaluate [[roadmap]]'s **DV12** over
the same epics while you are there: *a STORY with unticked checklist lines in its body but no open TASK*.
Those lines are findings nobody can pick — only `status: todo` **tasks** are ranked here, by `pick`, or by
the `Next up` snapshot. Report them in the closing report and offer
[`/tasks intake --epic`](../tasks/intake) or `/tasks new`; **don't silently work them**, since an
unscheduled bullet has not been through the filing discipline the pool depends on.

This costs one extra read per epic and closes a real hole: DV12 is correct and was *invoked by nothing*.
A whole review-intake epic sat with three stories, one unticked line and zero tasks — so it contributed
nothing to this pool and rendered as `0/0 tasks done`, indistinguishable from an epic nobody had started.
Every ranking drew from the other epics and never noticed. The check belongs here because this is the verb
that runs most often **and** the one that would act on the answer; leaving it to a human remembering to
run `/roadmap` is what let that epic sit for three weeks.

**Verification debt comes first.** Tasks at `status: review` are not in the pool — they're not `todo` —
but they are debt, and the house rule is that debt surfaces before new scope. Offer to clear them first
by running their `## Human test plan` and closing `review → done`.

**Empty pool → say so and stop. Don't invent scope.** Inventing defects to look busy is the failure
mode this branch exists to prevent. Two causes, two different offers:

- **No review has been filed** → *"nothing to drain — run a review pass and `/tasks intake` first."*
- **A review backlog exists but predates the stamp** — you can see epics that are obviously
  remediation (`todo` tasks whose bodies cite findings) but none carries `kind: review-intake`. Say
  exactly that and offer [`/tasks intake --adopt <EPIC-NNN>`](../tasks/verbs/intake.md), which stamps
  it. **Don't just start working those tasks** because they look like defects — that's the
  theme-guessing this pool definition exists to eliminate, and guessing wrong means picking a new
  capability and "fixing" it.

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

Ties break on the intake theme ladder (security & tenancy → correctness → data integrity → contract
drift → performance → reuse → docs), then `priority:`, then oldest `created`.

State the ranking in one short paragraph — the top pick and *why it beat the runner-up* — then start.
**Don't ask which to take;** that's the decision this skill exists to make. Do stop and ask only if the
top two are genuinely inseparable on every key above.

**Write the pick to disk immediately, before any code is read:**

- `status: todo` → `in-progress` (and cut the task branch, per [[tasks]] `pick`, on a PR-per-task project)
- add `picked-by: fix-next` to frontmatter
- append a `## Progress log` section whose first line is
  `- step 2 — picked; ranked above <runner-up> because <reason>`

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
  it, and return to step 1 for the next candidate. **A correct "no" is a deliverable.**

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
  side blocked on it.
- **Root cause is this repo's *usage* of the dependency** (wrong call, missing registration,
  misconfiguration) → fix locally; the dependency is fine.
- **"The same defect probably repeats in other consumers"** is a strong upstream signal even when a
  local patch would be smaller.

Log: `- step 4 — layer: <local / upstream: <where>>`

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
in it you did not intend is a finding, and gets a [`/tasks spawn`](../tasks/verbs/spawn.md).

If the project has no `docs/specs/.map.yml`, or its `areas:` list is empty, print one line — *"no
usable spec map — run `/specs init` to bootstrap the spec layer"* — and continue. Don't skip silently.

Log: `- step 7 — respecced <area>; requirements changed: <list>`

## Step 8 — Close through the merge gate

Run [`/tasks close`](../tasks/verbs/close.md). **Do not re-implement any of it** — `close` already owns
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

Log: `- step 8 — closed <status>; <sha>`

## Step 9 — Stop clean

**Bare invocation: stop here. One defect per invocation.** Don't roll into the next one — the clean
boundary is the deliverable, and a second fix in the same session is exactly what makes a reset unsafe.

`--loop`: continue to step 1 unless context is nearly exhausted, the pool is empty, or a
scope-escalation ask is pending ([spawn.md](../tasks/verbs/spawn.md) § *Scope escalation*) — wait for
that answer rather than taking new scope. Either way, **name the next pick** so a reset resumes there.

Final report, short:

1. What was broken, in one sentence a reader with no context understands.
2. The step-6 split, as numbers.
3. Anything flagged and not fixed, or any new task filed.
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
  evidence, close it out per step 3, move on.
- **A decision only the user can make** (a breaking API change, a secret rotation, a convention that
  isn't settled) → implement everything non-controversial, then stop and ask with a concrete
  recommendation. Don't guess and don't stall the parts that were never in doubt.
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
  A project needing more than that should ship a project-local skill that shadows this one.

## Related skills

- [[tasks]] — owns the backlog. `intake` fills the pool, `pick`/`close` semantics are borrowed, `spawn`
  takes everything this loop surfaces but doesn't own, `cancel` retires a false positive.
- [[populate-tests]] — owns *Prove the guard can fail* (step 6) and authors the regression test (step 5).
- [[specs]] — the step-7 regen; `docs/specs/.map.yml` maps changed files to areas.
- [[verify-conventions]] · [[code-review]] · [[security-review]] — the merge gate, run by `close`, not here.
- [[roadmap]] — DV12 flags a review-intake epic whose findings were filed but never scheduled as tasks.
