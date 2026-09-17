---
id: TASK-139
parent: STORY-017
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-130]
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-130-5]
pr: null
github-issue: null
jira-key: null
---

# `nextUpTasks[]` sorts on two keys that routinely tie, and says nothing about the third

## Context

**From TASK-130's cold drill, 2026-09-17** — found while drilling something else, and **pre-existing**:
it is a defect in the Collection pass's long-standing sort, not in the `--across` change that exposed it.
Spawned rather than folded in for exactly that reason.

§ *Collection pass* step 5:

> `nextUpTasks[]` — TASKs with `status: todo` (NOT blocked), sorted P0→P1→P2 then created asc

The runner hit a four-task fixture where **every task was `P2` and every `created` was the same date**,
and had to invent an order for the "Next up (top 3)" list — which then decides which task a human is shown
and which is cut. Its own words: the tie-break *"is undecided, and the top-3 cut makes it visible."*

**This is the same defect [[fix-next]] § Step 2 already names for its own ladder** — *"`created` is a date
with no time, and `/tasks intake` files an entire pass in one of them, so it ties routinely: twelve tasks
in this repo share `2026-08-20`."* That skill responded by declaring key 8 the last resort **and requiring
a run to say when the keys were exhausted**. The Collection pass's sort never got the same treatment, so
where `fix-next` announces a degenerate ranking, the snapshot silently picks three.

**Why it matters more with `--across` than without**, though it is not caused by it: merging several
projects multiplies ties, because two projects that each filed a batch on one day now interleave with no
key that can separate them. The drill's fixture was 4 tasks and already fully degenerate.

## Acceptance criteria

- [ ] The sort states a **total order** — a final tie-break that cannot itself tie (id, or repo-qualified
      id in across-mode), so two runs over one tree produce the same three
- [ ] A degenerate ranking is **announced**, not silent, matching the rule [[fix-next]] § Step 2 already
      applies to its own ladder — *"a ranking key that cannot discriminate must say so, not pass quietly"*
      (`AGENTS.md` § Conventions)
- [ ] The rule lives in § *Collection pass*, so `triage`, `audit`, the snapshot and [[roadmap]] all
      inherit it rather than each re-deciding
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- [[fix-next]]'s own eight-key ladder — already correct, and the model this should follow.
- Changing *which* keys sort the list. This is about what happens when the declared keys run out.

## Human test plan

- [ ] Cold-drill the snapshot against a fixture where every todo task shares one priority and one
      `created` date, and more tasks exist than the top-3 cut shows. **Pass** = the run produces a stable
      order and says the keys were exhausted. The brief must not mention ties or ordering.
