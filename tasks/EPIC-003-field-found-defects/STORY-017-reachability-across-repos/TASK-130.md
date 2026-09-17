---
id: TASK-130
parent: STORY-017
feature: null
status: done
priority: P1
assignee: agent
picked-by: fix-next
created: 2026-09-16
depends-on: []
blocks: []
related: [TASK-131]
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/tasks` prescribes a polyrepo split it cannot then collect — sub-repo tasks are invisible from the aggregator

## Context

Found 2026-09-16 while filing a defect against one sub-project of the Birko polyrepo family
(178 sibling repos under one aggregator).

The skill **documents** the split — SKILL.md §&nbsp;Shape detection, `verbs/new.md`:

> A project's own `CLAUDE.md` may override placement — e.g. an aggregator repo that hosts
> **cross-cutting epics for a polyrepo family** … single-sub-project work lands in that sub-repo's
> own `tasks/` via the default walk-up.

And Birko's `CLAUDE.md` takes that up explicitly:

> **Single-sub-project work** stays in that sub-repo's own `tasks/` (the default walk-up-to-`.git`
> rule already lands there) — don't track it here.

**But every collection verb resolves exactly one task root by walking up from cwd.** There is no
roll-up across sibling repos. So a task filed where the convention says to file it is visible only
when cwd happens to be inside that one sub-repo — and nobody runs the dashboard from there.

### Measured

| | |
|---|---|
| Sub-projects in the family | **178** |
| That have a `tasks/` folder | **1** (the aggregator itself) |

So the prescribed placement has been followed **zero** times in a family that has filed 449 tasks. That
is not people ignoring the rule — it is the rule being unusable, and everyone silently routing around it.

### Why it matters

A task filed correctly per the convention is **filed and scheduled by nothing**: invisible to the
dashboard, to `pick`, to `status`, and to [[fix-next]]. That is precisely the defect the Birko family's
own STORY-051 exists to record — *"a checklist line is filed, not scheduled"* — arriving through the
tracking tool rather than through a review pass.

### Re-measured 2026-09-17 on the real family — the premise above is scoped wrong

**The table above measured `Framework\` and stated its conclusion about "the family".** Re-run over the
whole of `C:\Source\Birko`, which is four groups, not one:

| Group | Git repos | With a `tasks/` tree | Tasks filed |
|---|---|---|---|
| `Framework\` | 178 | **1** (`Birko.Framework`) | 314 |
| `Framework.Tests\` | 167 | 0 | 0 |
| `Consumers\` | 16 | **6** | 1,038 |
| `Web\` | 4 | 0 | 0 |
| **total** | **365** | **7** | **1,352** |

**So "the prescribed placement has been followed zero times" is false at family scope — it has been
followed six times, by exactly the population the polyrepo argument is about.** BardStudio, DraCode,
Latent, Presenter, Symbio and WorkoutTracker each carry their own `tasks/` with their own `.config.yml`.
Symbio alone holds 720 tasks.

**And in `Framework\`, the aggregator pattern is working as documented, not being routed around.**
`Birko.Framework/tasks/` holds cross-cutting epics that name their affected modules in frontmatter —
`affects: [Birko.Web.Components]`, `affects: [Birko.Data.Redis]`, `affects: [Birko.Storage.Aws,
Birko.Storage.Google, Birko.Storage.Minio]`. That is the documented rule executing correctly. The 178
modules are **MSBuild shared projects, source-only, that always travel together** (the workspace's own
structure note: splitting them "buys nothing"), so per-module task trees were never the right shape for
them and their absence is not evidence of a broken convention.

**What survives, and it is still a real defect:** there is no roll-up across the **7** trees that do
exist, so no view spans them. That is a missing *view*, not an unusable rule — a materially smaller and
better-shaped problem than the one filed.

### The measurements AC3 and AC5 asked for, now taken

- **Id collisions are pervasive, so AC3's second option is not viable.** **343 distinct TASK ids are
  minted in more than one of the 7 trees**; `TASK-003`, `-006`, `-007`, `-008` and `-009` each exist in
  **all seven**. AC3 offered "repo-qualified ids **or** detect-and-report a collision" — detect-and-report
  would emit 343 findings on every run, which is a muted check by the second run. **Repo-qualification is
  the only surviving option**; that arm of the decision is settled by measurement rather than taste.
- **Scan cost is not the obstacle the task assumed.** Over all 365 repos: a full `find -maxdepth 3` for
  `tasks/` averages **330-370 ms**; a targeted `test -d` probe over the known group dirs averages
  **~200 ms**. AC5 asked for a bound so it is not "discovered as a slowdown" — it is sub-second, and the
  7 trees are discoverable without walking any repo's contents.

### What this does to AC1 — the decision is still yours, but it is a different decision

The choice is no longer *roll up 178 sub-repos* vs *centralise*. The family has **two populations with
different right answers**, and the filed framing collapses them:

- **The framework group** already has its answer, in use: one aggregator tree, `affects:` naming the
  modules. Nothing to decide.
- **The consumer products** are independent, already each carry their own tree, and *should* — this is
  the repo-is-self-contained property the polyrepo exists for.

So the live question is narrower: **should a roll-up view exist over the 7 real trees, and where does it
live** — in the aggregator's tree, or as a `--across` flag on the collection verbs that takes a declared
sibling list from `.config.yml` rather than probing? That is a question about a *view*, and neither answer
threatens the self-containment the original ⚠ was defending.

**Fixture note for whatever lands:** this task is justified by naming the Birko family, so per
`populate-tests` § *The cold drill* **Birko is disqualified as the drill fixture** for the fix. It is the
right place to *measure* — as here — and the wrong place to *drill*.

## The two candidate fixes, and why the second is probably wrong

1. **Roll up.** In an aggregator repo, collection verbs (`status`, dashboard, `pick`, `audit`) also scan
   sibling repos' `tasks/` folders and merge. The documented convention then works as written.
2. **Abandon the split** — everything in the aggregator, and delete the rule.

⚠ **(2) is the tempting one and it loses something real.** This is a *polyrepo*: someone cloning only
`Birko.Random` should get that project's tasks with it. Centralising makes the aggregator a single point
of failure for 178 repos' planning and breaks the repo-is-self-contained property that motivates a
polyrepo at all.

So (1) unless measurement says otherwise — but the cost is real and belongs in the estimate: the scan is
178 directory probes, needs a bound on how far it looks, and needs id-collision handling (two sub-repos
can both mint `TASK-007` with no shared counter).

## Decision — 2026-09-17

**An opt-in combined view. The lists stay where they are.**

Chosen: collection verbs gain an **explicit across-projects switch**. Nothing changes about where a task
is filed or how a single project behaves; asking for the combined view is the only thing that reaches
other repos, and not asking is the default.

**The polyrepo trade, named** (AC1 requires the counter-argument, not just the choice): centralising —
moving all seven trees into the aggregator — was rejected because someone cloning `Symbio` alone must get
Symbio's 720 tasks with it. Centralising makes one repo a single point of failure for every other repo's
planning and destroys the repo-is-self-contained property that motivates a polyrepo at all. The measured
data reinforced it: six consumer products **already** keep their own trees and are already doing the right
thing, so centralising would be undoing working practice to fix a missing view.

**Also rejected: rolling up implicitly, with no switch.** Tempting because it needs no flag and "just
works". Rejected because it makes every ordinary `/tasks` run in a consumer repo reach outside that repo —
changing what the default view means for the six projects that are currently correct and self-contained,
to serve a question only occasionally asked. An opt-in costs one flag; an implicit roll-up costs every
project its independence from the others.

**Scope is declared; membership is recomputed.** Which directory the siblings live under is *not*
determined by anything in the repo — a walk could stop at `../`, `../../`, or the drive root — so it is a
**declaration** in `.config.yml`, per § *Read the declaration, never infer it*. Whether a given sibling
*has* a `tasks/` tree **is** determined by the filesystem and must be **recomputed every run**, per
§ *A derived state must never be cached as a decision* — a project that gains a task tree tomorrow must
appear without anyone re-declaring anything. Measured cost makes this affordable: ~200 ms over 365 repos.

**Ids are repo-qualified, and that arm was settled by measurement, not preference** — 343 colliding ids
across the seven trees make detect-and-report useless (343 findings every run, muted by the second).

## Acceptance criteria

- [x] 1. Decide between roll-up and centralisation, **in writing, with the polyrepo trade named**. A
      decision recorded as "we chose roll-up" without the counter-argument is not a decision.
      **Settled 2026-09-17 — see `## Decision` above: opt-in switch, both rejected options recorded.**
- [x] 2. The combined view shows every declared sibling's tasks, labelled with their owning repo, and is
      reachable from the collection verbs. **It is opt-in**: without the switch, behaviour in any single
      repo is byte-for-byte what it is today — that is the arm that protects the six already-correct trees.
- [x] 2b. **Scope is declared, membership recomputed.** The sibling root is a `.config.yml` field; whether
      each sibling has a `tasks/` tree is probed every run, never cached.
- [x] 3. **Ids are repo-qualified for display.** Settled by measurement (343 collisions) rather than left
      as a choice: detect-and-report was the other option and is not viable at that volume.
- [x] 4. ⚠ **A test with more than one sub-repo, at least one of which has no `tasks/` folder at all.**
      The 177-of-178 case *is* the common case, so a fixture where every repo has tasks measures the
      rare shape and would pass over the real bug.
- [x] 5. Bound the scan. 178 sibling probes on every `/tasks` invocation is not free; state the limit
      (depth, or a declared sibling list in `.config.yml`) rather than discovering it as a slowdown.
- [x] 6. Whichever way it goes, the **prose and the tooling agree afterwards.** Leaving a documented rule
      the tool cannot execute is the defect being fixed, not a style issue.

## Out of scope

- Cross-cutting epic placement in the aggregator — that half works and is not in question.
- [[TASK-131]] — `fix-next`'s pool gating is a separate mechanism with a separate fix.

## Implementation plan

**One chokepoint.** `triage`, `audit`, the bare-`/tasks` snapshot and [[roadmap]] all delegate to
§ *Collection pass*. The roll-up goes there and the rest inherit it — anything else is four copies of a
walk, which is the restated-list defect this repo lints for.

1. **`skills/tasks/templates/config.yml` — declare the scope.** Add a `siblings:` block, shipped
   **commented out**: absence means "not a polyrepo", which is true of almost every consumer, and a live
   default would mint a declaration nobody made (§ *A template ships nothing a render cannot make true*).
   The commented example carries a placeholder, never a plausible concrete path.
2. **`skills/tasks/SKILL.md` § Collection pass — add across-mode.** Default is byte-for-byte today's
   behaviour. With the switch: read `siblings:`; **absent → say so and run single-repo**, never guess a
   root. Probe each immediate child of the declared root for `tasks/.config.yml`. Membership is
   **recomputed every run** (§ *A derived state must never be cached*); scope is **declared**
   (§ *Read the declaration, never infer it*). That split is the whole of AC2b.
3. **Bound the scan (AC5) — one level, no recursion.** Children of the declared root only. Measured on
   the real family: ~200 ms over 365 repos, so the bound is about *predictability*, not speed — an
   unbounded walk from a wrongly-declared root is what turns a view into a disk crawl.
4. **Qualify ids for display (AC3).** `<repo>/TASK-NNN` in every across-mode render. Never rewrite an id
   in a file — this is a display concern; the files keep their own numbering, which is the point.
5. **Wire the switch into the verbs that read, and only those.** Bare `/tasks`, `audit`, `roadmap`.
   **`triage` declines it, with the reason stated**: it owns `tasks/README.md`, a per-repo generated
   file, and no repo owns a view of seven. **`pick` declines it too** — a view is a view; picking across
   repos would cut a branch and edit files in a repo the user did not invoke from. Across-mode names the
   owning repo so a human can go there.
6. **Register-on-introduce** — `siblings:` is a new declared field other skills read, so AGENTS.md
   § Conventions gets its entry in this same change, and `skills/tasks/verbs/init.md` learns to reconcile
   an older config that predates the field.
7. **Flag contract** — the receiving verbs must *declare* the flag, or `skills-lint.sh` check 4 fails any
   skill that passes it.
8. **Prose/tooling agreement (AC6)** — re-read § Shape detection's polyrepo paragraph and make it point at
   the new switch, so the documented rule and the executable one are the same sentence.

## Human test plan

**Written as part of this task — the section was absent, which is not the same as `N/A`.**

**Fixture — not Birko.** This task is justified by naming the Birko family, so per
`populate-tests` § *The cold drill* that family is disqualified as the fixture. Build a throwaway root
with **four sibling projects**: two with a `tasks/` tree that both mint `TASK-001` and `TASK-002`
(forcing the collision case), one with a `tasks/` folder but no `.config.yml`, and **one with no `tasks/`
at all** — that last is AC4, and it is the common shape, not the edge case.

- [x] **Cold drill, across-mode.** Hand a cold runner the `tasks` skill and the fixture, and ask only:
      *"Show me what is outstanding across all the projects here, then say which project each item lives
      in."* Do not say `--across`, `siblings:`, or that ids collide. **Pass** = it finds the switch,
      reports the declared root, lists both task trees with repo-qualified ids, and reports the
      no-`tasks/` sibling as simply not participating rather than as an error or a gap.
- [x] **Cold drill, the default path — the arm that protects the six correct repos.** Same fixture, same
      runner, ask only *"what's outstanding here?"* from inside one sibling. **Pass** = output identical
      to today's single-repo snapshot, with no mention of any other project. A run that volunteers the
      others has broken the opt-in promise, and that is the failure that matters most.
- [x] **Undeclared root.** Remove `siblings:` and re-run across-mode. **Pass** = it says the field is
      undeclared and runs single-repo; **fail** = it guesses a root from the directory layout.

## Progress log
- step 1 — picked; AC1 was settled first (see `## Decision`), which is what made this pickable rather than a decision task `/fix-next` must skip. Plan written before any editing, per § Working rules. **`## Human test plan` was absent** — written now, before the work, so it is a target rather than a transcript.
- step 2 — implemented at one chokepoint, per the plan. `Collection pass` gained step 1b (across-mode); the router declares `--across`; § Shape detection's polyrepo paragraph now points at it (AC6); `templates/config.yml` ships `siblings:` **commented out**; `audit` and `roadmap` declare the flag; `triage` and `pick` declare the **refusal**. **`init.md` needed no edit, and that was checked rather than assumed** — step 3 reconciles "every field the template declares and the file lacks … a field the template declares **commented out** is added **as its comment block**", deferring to the template as the only source of the field list. So an older config gains `siblings:` automatically; had `init` carried its own copy of the fields, this change would have needed an edit there and silently rotted without one.
- step 3 — register-on-introduce: `AGENTS.md` § Conventions gained *"A widening switch is opt-in, read-only, and refused by name where it cannot apply"* in the same change, since `siblings:` is a new declared field other skills read and `--across` is a new cross-skill protocol.
- step 4 — proved the guard can fail, **two assertions, and the mutations discriminate**:
  - **(a) prose sites**, `git stash` vs working tree: **0/9 → 9/9, exit 1 → 0.** Sites: collection-pass across-mode, collection-pass opt-in promise, router flag declaration, shape-detection pointer, template `siblings:`, audit, triage refusal, pick refusal, roadmap.
  - **(b) the written algorithm executed against the AC4 fixture** — four siblings: `alpha` (tasks + the declaration), `beta` (tasks, **same ids**), `gamma` (a `tasks/` folder but no `.config.yml`), `delta` (**no `tasks/` at all** — AC4's common shape). Result: declared root read, `alpha beta` participating, `gamma delta` skipped without error, **2 bare id collisions → 4 distinct qualified ids**, and `beta`'s missing `siblings.root` correctly forces the single-repo fallback.
  - **Mutation 1 — the one-level bound does work.** A nested repo planted at `delta/nested/tasks/` is invisible to the probe as written and **is** picked up by a recursive one (`alpha beta` vs `alpha beta delta/nested`). The bound is load-bearing, not decoration.
  - **Mutation 2 — membership really is recomputed.** Giving `gamma` a `.config.yml` made it participate **with no declaration edited**; the assertion then failed 1 (exit 1, 2 FAIL lines) and returned to 0 when the fixture was restored. So (b) is sensitive in both directions rather than trivially green.
  - **Two measurement errors of mine, found and fixed here:** `exit=$?` after a pipe reports `tail`'s status, not the script's — which made a genuinely failing assertion read as green; and mutation 1's first "recursive" probe used `-maxdepth 3`, too shallow to reach a depth-4 nested repo, so it showed no difference and looked like the bound was doing nothing. Both were the measurement, not the rule; recorded because a green assertion produced by a broken harness is exactly what this step exists to catch.

## Drill record — 2026-09-17

**Three cold runners, one fixture**, because the feature has three distinct behaviours and one of them is
a *negative*. `claude -p --disable-slash-commands` (Claude Code 2.1.274), cwd `…/across-164817/x1|x2|x3` —
throwaway dirs with no guide above them, each holding only its own brief, its own copy of the fixture and
its **own copy** of the `tasks`/`roadmap` skills.

**Coldness — confirmed.** Each runner's §1 reported no guide, no skills, no memory index. No brief said
`--across`, `siblings:`, that ids collide, or that any project lacked a task tree.

**Fixture — not Birko** (this task is justified by naming that family, so it is disqualified as the
fixture). Four projects: `alpha` (tasks + the declaration), `beta` (tasks, **same ids as alpha**),
`gamma` (a `tasks/` folder but no `.config.yml`), `delta` (no `tasks/` of its own, but a **nested** one at
`delta/nested/tasks/`, which also exercises the one-level bound).

**Result: all three PASS on their substantive bars.**

| Drill | Asked | Outcome |
|---|---|---|
| **x1** across | *"what's outstanding across all the projects here"* | Found `--across` unaided; read the declared root; included `alpha`+`beta`; printed **`alpha/TASK-001` and `beta/TASK-001` side by side**, the collision correctly separated; excluded `gamma` and `delta` as *not participating*, neither as errors nor gaps |
| **x2** default | *"what's outstanding here?"* | **Did not widen.** Printed bare `TASK-001`, not `alpha/TASK-001`. Its reasoning is the rule in its own words: *"A declared `siblings.root` is a **capability**, not a trigger."* |
| **x3** undeclared | same as x1, `siblings:` removed | Reported the field undeclared and ran single-repo. **Refused to infer the root** although it had already seen the sibling folders and knew `beta` had tasks |

**The two strongest signals were both refusals**, which is what a negative test is for. x3 declined to read
`BRIEF.md` at its own job root, quoting the rule against inferring a root from surrounding brief text — a
rule written for a different decision, holding under pressure. x2 named the boundary it declined to cross
rather than helpfully reaching past it.

**Four findings, all in prose written today, all fixed in this change** (same function, same root cause,
so pulled in rather than spawned):
1. **What a relative `siblings.root` resolves against was never stated** — repo root or `tasks/`? x1:
   *"the two readings give completely different reports."* Now stated: the repo root, the parent of `tasks/`.
2. **Whether the invoking repo is its own "sibling" was undefined** — x1 counted `alpha` in "4 siblings"
   and noted a repo is not usually its own sibling. Now: it participates like any other, and the header
   counts **projects**, which removes the contradiction.
3. **"Say so in one line" specified no line** — the § Output/prose-rules defect of describing output
   instead of stating it. x3 invented both wording and placement. The exact line is now written out.
4. **Nothing said what a *default* run does about a declared-but-unused root.** x2 invented a scope-hint
   line and flagged it as its own call; x3 printed a plain header. **Two runs, two outputs.** Settled in
   favour of silence — the byte-for-byte promise is what protects projects that are already correct, and
   one helpful line is a change to the default view of every project in the family.

**One pre-existing gap spawned, not folded in:** [[TASK-139]] — `nextUpTasks[]` sorts on priority then
`created`, both of which tied across all four fixture tasks, so the top-3 cut was decided by an order
nobody declared. [[fix-next]] § Step 2 already solved this for its own ladder; the Collection pass never
got the same treatment.

**Assertions re-run after the fixes: (a) prose sites 9/9, exit 0; (b) behaviour green, exit 0.**
- step 5 — cold drill, three runners (x1 across / x2 default / x3 undeclared), all PASS; 4 findings in today's prose fixed in place, 1 pre-existing spawned as TASK-139. Assertions re-run green after the fixes.
- step 6 — 5b gate, **three axes side by side, not merged**. **standards** ([[verify-conventions]]): rulebook = AGENTS.md § Conventions via the CLAUDE.md @import bridge, rung 1; project extension none found; 9 of 9 changed files linted. Register-on-introduce satisfied in-change; the shared-inventory rule is *strengthened* (one engine, four inheritors, `roadmap` told to read it rather than restate the walk). One ⚠ — the router grew; recorded rather than passed silently: § *Collection pass* is the shared engine with no verb that owns it, so moving it would put it behind one caller while four read it. **fidelity** ([[verify-intent]]): all 7 criteria built and evidenced by **execution** (x1/x2 for AC2/2b/3, the fixture's `delta`/`gamma` for AC4, mutation 1 for AC5, the shape-detection pointer for AC6); baseline unavailable and said so; nothing out of scope built. **correctness** ([[code-review]] medium): **ten findings, every one legitimate, all ten fixed — none spawned, because all ten are defects in the `--across` spec written in this same change.** Two were sharp enough to change the design: (2) participation was gated on `tasks/.config.yml` while § *Shape detection* explicitly resolves a root **without** one, so a real populated pre-skill backlog would have been excluded *and then counted as having no tasks* — **and my own fixture could not have caught it**, since `gamma` was that shape but empty, so the drill scored the exclusion correct; and (5) **the AGENTS.md convention I added in this very change caught the change** — `--across` was declared for five verbs and silently ignored by eleven, the exact *"caller reads the promise, not the scope"* failure. Also fixed: (1) `audit`'s checks resolving `depends-on`/`feature:`/duplicates **across** repo boundaries, which with 343 colliding ids would have *suppressed* real findings in the invoking repo — the worst of the ten; (3) the invoking repo dropped entirely for an aggregator declaring `root: .`; (4) `roadmap` hiding a features-only project though its contract is both trees; (6) one mode slot for projects that differ; (7) a mistyped root cited as the hazard and then unhandled; (8) unrenderable nested backticks in an output spec; (9) a measured figure that contradicted the claim it supported (7 of 365 → 358 of 365); (10) `--scope` + `--across` ambiguous by the same collision argument. **`skills-lint.sh` check 4 then caught my own fix for (5)** — the illustrative `/tasks show … --across` parsed as a real invocation to a verb that does not declare the flag. Resolved by keeping the blanket router rule (a per-verb list would miss the twelfth verb added tomorrow) and rewording the example. **security-review** not applicable — markdown prose about which directories a read-only view enumerates; no auth, data-access, input-handling, crypto, secrets, dependency or endpoint surface. 5c skipped — `integration: single-branch`. 5d sweep: both `## Out of scope` bullets are **boundaries** with named owners, 0 spawned from the sweep; 1 spawned earlier in the run — TASK-139.
- step 7 — assertions re-run after all ten fixes: prose sites **9/9, exit 1 → 0** across the stash boundary (the guard flagged its own stale pattern when `audit.md`'s wording changed, and was corrected rather than loosened); behaviour assertion green.
