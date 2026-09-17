---
id: TASK-130
parent: STORY-017
feature: null
status: todo
priority: P1
assignee: unassigned
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
- [ ] 2. The combined view shows every declared sibling's tasks, labelled with their owning repo, and is
      reachable from the collection verbs. **It is opt-in**: without the switch, behaviour in any single
      repo is byte-for-byte what it is today — that is the arm that protects the six already-correct trees.
- [ ] 2b. **Scope is declared, membership recomputed.** The sibling root is a `.config.yml` field; whether
      each sibling has a `tasks/` tree is probed every run, never cached.
- [ ] 3. **Ids are repo-qualified for display.** Settled by measurement (343 collisions) rather than left
      as a choice: detect-and-report was the other option and is not viable at that volume.
- [ ] 4. ⚠ **A test with more than one sub-repo, at least one of which has no `tasks/` folder at all.**
      The 177-of-178 case *is* the common case, so a fixture where every repo has tasks measures the
      rare shape and would pass over the real bug.
- [ ] 5. Bound the scan. 178 sibling probes on every `/tasks` invocation is not free; state the limit
      (depth, or a declared sibling list in `.config.yml`) rather than discovering it as a slowdown.
- [ ] 6. Whichever way it goes, the **prose and the tooling agree afterwards.** Leaving a documented rule
      the tool cannot execute is the defect being fixed, not a style issue.

## Out of scope

- Cross-cutting epic placement in the aggregator — that half works and is not in question.
- [[TASK-131]] — `fix-next`'s pool gating is a separate mechanism with a separate fix.
