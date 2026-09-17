---
id: TASK-133
parent: STORY-017
feature: null
status: todo
priority: P2
assignee: unassigned
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-131]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-131-1]
pr: null
github-issue: null
jira-key: null
---

# `spawn`'s pool rescue fires only for a review finding, so a field-shaped discovery still lands loose

## Context

Spawned by the `/code-review` pass at [[TASK-131]]'s close gate, 2026-09-17. `CR-131-1`.

`skills/tasks/verbs/spawn.md` step 4 tells the caller, when the parent fallback bottoms out at `_loose`:

> **If you reach `_loose` and the discovery is a review finding, stop and place it in a pool instead** —
> `_loose` with no `findings:` id and no `kind: review-intake` ancestor is outside [[fix-next]]'s pool
> entirely, so the task is filed and unranked.

That rescue is **conditioned on the discovery being a review finding**, and when it was written that
condition was doing no harm: a discovery with no pass behind it had no id it could have been given, so
naming it would have pointed at nothing. TASK-131 removed that constraint — `/tasks new task --from-field`
now mints a `FIELD-NNN` for exactly the pass-less case — and the condition became a live gap instead of a
tautology.

### The mechanism

A `/fix-next` run is the common origin. Its step 5 discovers something adjacent that is a genuine defect
but was **not** raised by any review pass — nobody code-reviewed it, it came out of doing the work. Spawn
parents it to the origin's STORY, else EPIC, else `_loose`. If the origin is itself loose, the discovery
lands loose, the rescue does not fire because the discovery is not a *review* finding, and the task is
filed with `findings: []` under no `review-intake` ancestor — outside the pool, ranked by `priority:`
alone. This is the identical end state TASK-131 fixed at the front door, reached through a side one.

**Why it is small but not nil:** the rescue's own precondition (a loose origin) is uncommon, and this
repo's `_loose/` holds one task. But the rule exists precisely for the case nobody chooses — the
SKILL.md text says so: *"a finding spawned from a task that is itself loose lands loose by inheritance,
with nobody choosing that."*

## Acceptance criteria

- [ ] 1. `spawn.md`'s `_loose` rescue covers a discovery with **no pass behind it**, not only a review
      finding, and names `--from-field` as the route that gives it an id.
- [ ] 2. The rescue does **not** widen into "anything spawned into `_loose` joins the pool". Tree hygiene
      and meta-work about the tree legitimately stay loose and unranked — [[tasks]] SKILL.md § *A task
      outside a pool* calls that arm explicitly not a loophole, and this must not quietly overturn it.
      Whatever wording lands has to keep the two distinguishable.
- [ ] 3. Whatever `spawn.md` ends up asserting about `--from-field` is pinned by `skills-lint.sh`
      check 4 — i.e. if it names the flag in an invocation, the receiving verb must still declare it.

## Out of scope

- The `--from-field` mechanism itself — built and closed under [[TASK-131]]; this task only routes to it.
- [[TASK-130]] — cross-repo collection, a separate mechanism, and still undecided.

## Human test plan

N/A — fully covered by the lint. AC1 and AC2 are prose judgements a reader checks at review, and AC3 is
`skills-lint.sh` check 4, which already fails on an undeclared flag (proven by TASK-131 step 6). A cold
drill would add nothing here: this task changes the *condition* on a rescue whose behaviour TASK-131's
own drill already exercises, so a second runner would be re-reading the same paragraph.

## Implementation plan

_Populated by `/tasks plan TASK-133` — leave empty until then._
