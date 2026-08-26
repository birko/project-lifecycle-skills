---
id: TASK-080
parent: STORY-008
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-26
depends-on: [TASK-079]
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen` — generate the specs, and review the diff as the deliverable

## Context

The second half of STORY-008, and **the half that genuinely runs last.**

### The ordering constraint is real, and it is not expressible in frontmatter

`depends-on: [TASK-079]` covers the map. What it cannot express is the story-level rule:

> **Runs last, and stays last.** STORY-002 through STORY-007 all change skill behaviour and STORY-003 changes
> the vocabulary the specs would be written in. Regenerating before the set stabilises means regenerating
> twice and reviewing a diff that is pure churn.

**Outstanding when this task was filed: STORY-004, STORY-006, STORY-007.** (STORY-002, 003 and 005 are done.)
STORY-007 in particular *adds a skill*, which adds an area — so a regen before it lands produces a spec set
that is incomplete by construction. `STORY.md` has no `blocked-by` field, which is why EPIC-001 keeps its
dependency edges in a Sequence table; this paragraph is that edge, written where whoever picks the task will
read it.

**Do not start this while those three are open.** If they slip, this slips — the story says so outright:
*"It is the natural stopping point, not a nice-to-have."*

### The diff review is the deliverable, not the files

*"The regen **diff** is reviewed as an intended-versus-unintended behavioural-change check — that review is
the point, not the file."* On a first generation there is no diff to review, which is worth saying plainly:
the **first** run's deliverable is the baseline plus a read of whether each spec describes what the skill
actually does. The diff-as-check property starts with the *second* run.

### The self-check STORY-008 flags

> *This repo is a polyrepo-free, markdown-only project — the exact shape where the staleness anchor bugs
> fixed in the 2026-08 commits were found. A regen here is also a live test of those fixes.*

Two of those fixes are now testable here for the first time, and both were touched this month:

- **`shaped-by` provenance via the subject rule.** TASK-030 settled that `single-branch` repos leave `pr:`
  null permanently and resolve through the commit subject instead — and verified on three real closes that
  the leading id in each subject is that task's own. This regen is the first run that actually exercises it,
  so `shaped-by-unresolved` is a **measurement**, not a nuisance: a high count here would mean that fix is
  wrong.
- **The anchored status read.** TASK-036 fixed `regen` step 5a's state gate, which had been able to read the
  frontmatter's enum comment instead of the field. TASK-073 then removed the comment's trap shape repo-wide.
  A run here confirms both.

## Acceptance criteria

- [ ] **STORY-004, 006 and 007 are `done` before this starts** — or the reason for proceeding anyway is recorded on this task, naming what churn is accepted
- [ ] Every area in `.map.yml` has a generated spec, each stamped with `generated-at`, `sources`, and `shaped-by` provenance
- [ ] Each spec is read against the skill it describes, and any place the spec is right while the **skill** is wrong becomes a spawned task — a harvest that only produces documents wastes its best output
- [ ] `shaped-by-unresolved` is **reported as a number with an interpretation**, not left as a field: this repo's commits lead their subjects with task ids, so a high count contradicts TASK-030's fix and is a finding against it
- [ ] `shaped-by-derived:` is `true` on every area — an unfilled field makes [[roadmap]] DV11 read a generator gap as a project gap
- [ ] `/roadmap --check` afterwards reports DV7 fresh for every area, with no unknown baselines
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The area map — **TASK-079**, which this depends on.
- Fixing anything the diff review surfaces. Findings get spawned; fixing them inside a harvest task would make the diff unreviewable, which is the one thing this task must not do.
- Re-running after STORY-004/006/007 land, if this is somehow run early. That would be a second task with a stated reason.

## Human test plan

- [ ] Read two generated specs against the skills they describe and confirm they state what the prose **actually says**, not what it ought to say
- [ ] Confirm `shaped-by` is non-empty where a task genuinely shaped an area, and that the `unresolved` count is explained rather than merely printed
- [ ] Re-run `/specs regen` immediately and confirm the diff is **empty** — a generator that is not idempotent makes every future diff review worthless
- [ ] Change one skill's prose deliberately, re-run, and confirm the diff shows exactly that change and nothing else — the property the whole story is for

## Implementation plan

_Populated by `/tasks plan TASK-080` — leave empty until then._
