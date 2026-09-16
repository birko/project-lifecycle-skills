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

## Acceptance criteria

- [ ] 1. Decide between roll-up and centralisation, **in writing, with the polyrepo trade named**. A
      decision recorded as "we chose roll-up" without the counter-argument is not a decision.
- [ ] 2. If roll-up: the aggregator's dashboard shows sub-repo tasks, labelled with their owning repo, and
      `pick`/`status` can reach them.
- [ ] 3. **Id collision is answered explicitly.** Sibling repos have no shared counter. Either ids become
      repo-qualified for display, or the roll-up detects and reports a collision rather than silently
      showing one of two tasks.
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
