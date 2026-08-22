---
id: TASK-055
parent: STORY-003
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `tdd` still says nothing creates `docs/adr/`

## Context

**Found while planning TASK-053** (the layer-parity change that teaches both front doors about
`docs/glossary.md` and `docs/adr/`).

`skills/tdd/SKILL.md:79`, in § *Workflow → 1. Planning*, reads:

> When exploring the codebase, use the project's domain glossary ([[domain]]) so that test names and
> interface vocabulary match the project's language, and respect the decision records (ADRs,
> `docs/adr/`) in the area you're touching — where the project keeps them; **no skill creates that
> directory yet**.

The trailing clause stopped being true at **TASK-052**, which gave `domain` the decision-record half
and wrote this repo's first record. `domain` owns `docs/adr/` now, and once TASK-053 lands, `LAYER.md`
names it as part of the universal layer.

**Why this is its own task and not TASK-053 cleanup.** STORY-003 line 27 claimed this line, and the
claim had two halves: convert the dangling plain-text reference to a proper `[[domain]]` link, and stop
telling agents the directory has no owner. **The first half landed** — the wikilink is there. The
second is leftover, and it is a *statement of fact about the skill set* rather than anything TASK-053's
acceptance criteria cover. Six words, but they point a reader of `tdd` at the wrong conclusion: that
ADRs are something other projects might happen to keep, rather than an artifact this skill set owns and
scaffolds.

Check the neighbouring glossary clause in the same sentence while here — it says "use the project's
domain glossary", which stays correct under TASK-053's **lazy** rule (the file may legitimately not
exist yet), so it likely needs nothing. Confirm rather than assume.

## Acceptance criteria

- [ ] The `no skill creates that directory yet` clause is gone from `skills/tdd/SKILL.md:79`
- [ ] What replaces it (if anything) does **not** restate `LAYER.md`'s row content — `tdd` is a
      consumer of the vocabulary, not a second home for the layer inventory
- [ ] The sentence still reads correctly for a project that has **no** `docs/adr/` yet — absence is
      legitimate under the lazy rule, so `tdd` must not imply every project has one
- [ ] The glossary half of the same sentence is checked and either left alone (with the reason) or
      corrected
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `LAYER.md` rows and both front doors — **TASK-053** owns those.
- Backfilling this repo's owed ADRs — **TASK-054**.
- Any other stale cross-reference in `tdd`. If one turns up, spawn it; this task is the ADR clause.

## Human test plan

N/A — fully covered by reading the changed sentence plus the lint. This is a prose-accuracy fix in a
skill's planning guidance with no runtime surface and no install-path change; there is nothing a human
can exercise that reading the diff does not already settle.

## Implementation plan

_Populated by `/tasks plan TASK-055` — leave empty until then._
