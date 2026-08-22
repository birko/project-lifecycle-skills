---
id: TASK-063
parent: STORY-016
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-3]
pr: null
github-issue: null
jira-key: null
---

# The upgrade path's headline case has no state and no remedy

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance).

`adopt-project`'s own description bills it as *"the UPGRADE path — re-run it whenever the universal layer
grows, to reconcile a repo that adopted an older version."* The artifact the layer grows fastest is the
**agent guide**. That case currently falls between two stools.

**Measured on `Birko/Consumers/WorkoutTracker`**, adopted 2026-08-18: its `CLAUDE.md` is 342 lines with
all four `##` sections present, and it is a demonstrably older vintage —

- its close gate names `/code-review` **only**; `/verify-conventions` is absent, which is the one skill
  adoption exists to feed;
- no **task-first gate**;
- no *generated files are owned by their verbs* and no *status changes go through their verbs* rules.

Neither available answer fits:

| Candidate | Why it does not apply |
|---|---|
| `present, outdated` | `LAYER.md:122` makes it claimable *"only where something can tell you — a row whose already present? column names a verb, whose delta then is the evidence."* No verb owns the guide's shape. Its parenthetical fallback is scoped to *"an agent guide missing a section"* — this guide is missing none; the staleness is **inside** a section. |
| The row's remedy, *"merge by section — add missing `##` sections"* | There are no missing sections to add. |

So the drill did what the rule told it to — reported `present` with the gap enumerated — and the flagship
upgrade scenario landed as a hand-written paragraph under a table, discoverable only by whoever reads
that one report.

**Why the honest answer might be "the rule is right and the advertising is wrong."** `LAYER.md`'s
distinction is real: reading a schema back from an owner and judging someone's prose are different acts,
and the second is a content audit the layer deliberately refuses. That is a legitimate resolution — but
then `adopt-project`'s description should not promise an upgrade path for the artifact it cannot
reconcile. Deciding which way to cut is this task; **do not assume a new state is the answer.**

**Adjacent, not duplicate: TASK-024** (*"the other owner verbs still cannot say whether an artifact is
current"*) is about verbs that exist and cannot answer. This is about a row where **no verb exists to
ask**. Cross-reference both ways; if the resolutions turn out to be one change, say so and merge them
explicitly rather than silently.

## Acceptance criteria

- [ ] The stale-vintage-guide case has **one** documented outcome: a state, an explicit content-audit hand-off, or a stated limitation — chosen deliberately, with the reason recorded
- [ ] If the resolution is a limitation, `adopt-project`'s **description** stops promising to reconcile what it cannot, so the advertising matches the behaviour
- [ ] Whatever is chosen holds for the measured WorkoutTracker case: every `##` section present, three working rules absent, `/verify-conventions` missing from the close gate
- [ ] `present, outdated`'s "claim it only where something can tell you" guard is left intact — this must not become a licence to judge prose
- [ ] TASK-024 is cross-referenced, with a line on whether the two are one change or two
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Actually amending WorkoutTracker's guide — that is **TASK-059**'s reconciliation run, and it is the consumer of whatever this task decides.
- Teaching the other owner verbs to reconcile — **TASK-024**.
- The other drill findings — separate tasks under STORY-016.

## Human test plan

- [ ] Run `adopt-project`'s survey against `Birko/Consumers/WorkoutTracker` and confirm the guide's staleness lands in a named outcome rather than as free prose under the table
- [ ] Confirm a *current* guide (this repo's `AGENTS.md`) does not trip the new outcome — the check must distinguish an older vintage from a guide that is simply dense
- [ ] Read `adopt-project`'s description against what the run actually did, and confirm they agree

## Implementation plan

_Populated by `/tasks plan TASK-063` — leave empty until then._
