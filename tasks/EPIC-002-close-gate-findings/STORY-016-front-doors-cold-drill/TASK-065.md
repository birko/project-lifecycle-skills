---
id: TASK-065
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-7, DRILL-053-8]
pr: null
github-issue: null
jira-key: null
---

# `adopt-project` assumes every run is a full run

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance). Two findings, deliberately one task — they
are the same assumption seen from two sides, and TASK-060's routing criteria called for considering them
together.

### DRILL-053-7 — no state for a present row whose owner verb has not run

Three rules combine into a hole:

- `adopt-project/SKILL.md:47-51` — *"From outside you cannot see a version… Where the artifact's row
  names a verb, **step 3's delegation is what answers, so leave the version question to it rather than
  guessing here**."*
- `SKILL.md:73-78` — a "complete" table ends the run *"only when no row names a verb to delegate to, or
  every such verb has already answered."*
- `LAYER.md:61-66` — *"'nothing to do' is not 'up to date' … Where that is the whole answer available,
  report the row **unknown** and name the init that could not answer."*

A survey scoped to § 1 (a pre-flight check, a read-only pass) is told not to guess the version, told the
answer comes from a step it is not running, and given no state for the result. The drill hit this on
**both** target repos — `tasks/` and `docs/specs/.map.yml` — and had to invent
*"present, currency unresolved"*, then state in both reports that its survey certified
*nothing-missing* rather than *complete*.

**Its reasoning for rejecting `unknown` is worth preserving:** `unknown` means "I could not determine
it" about **existence**, and `SKILL.md:139` scopes it to *"an `unknown` that came from a verb's
silence"* — a verb that ran and declined. Reusing it for a verb never invoked would print one word for
two different situations, which is the collapse the survey's own rules warn about elsewhere.

### DRILL-053-8 — § 4 owes output only § 2 produces

`SKILL.md:90-93` requires the inference round's skip to be stated *"in this step's own output, **and
again in step 4's report**… A silent skip is indistinguishable from a skill that forgot the step."*
`SKILL.md:274` similarly requires the `not applicable yet` bucket to say that glossary candidates travel
as a finding — and candidates are collected in § 2 (`INFER.md`).

So a run scoped to § 1 + § 4 owes a report the skill's own text calls defective if omitted. The drill
produced both anyway, labelled *"would have been step 2's own output"*, because staying silent would
have triggered the exact failure that passage names.

### The shared root

The skill is written as though it always runs start to finish. A **scoped run is a reasonable thing to
want** — a pre-flight before touching anything, a re-survey to see whether a blocker cleared, a
read-only audit of someone else's repo — and it currently cannot express its own central result. Decide
whether scoped runs are supported: if yes, they need a state and a report contract; if no, say so
plainly so nobody builds on it.

## Acceptance criteria

- [ ] Whether a scoped / read-only run is a supported mode is **stated**, either way
- [ ] If supported: a present row whose owner verb was not invoked has a named state, distinct from `unknown` (a verb that answered with silence) and from plain `present`
- [ ] If supported: the report contract says what § 4 owes when an earlier step did not run, so a scoped report is not defective by its own definition
- [ ] If not supported: the passages that imply a partial run is possible are corrected, and `adopt-project` says a run is all-or-nothing
- [ ] Either way, `SKILL.md:73-78`'s completeness rule still distinguishes *nothing missing* from *complete* — that distinction was right and the drill relied on it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Teaching the owner verbs to report a delta — **TASK-024**. This task is about the state a survey assigns when it has not asked them.
- The other drill findings — separate tasks under STORY-016.
- Adding a `--survey-only` flag as such. Whether the mode gets a flag is downstream of deciding it exists; if it does, the flag's every-step contract is `close`'s `--unattended` lesson to reapply.

## Human test plan

- [ ] Run a scoped survey (§ 1 + § 4 only) against a repo with a present `tasks/` tree and confirm the row's state and the report both read correctly without the delegation having run
- [ ] Confirm the report distinguishes *nothing is missing* from *the layer is complete* — the drill found that distinction load-bearing and it must survive
- [ ] Run a full pass on the same repo and confirm the scoped and full reports do not contradict each other

## Implementation plan

_Populated by `/tasks plan TASK-065` — leave empty until then._
