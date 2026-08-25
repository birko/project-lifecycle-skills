---
id: TASK-055
parent: STORY-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] The `no skill creates that directory yet` clause is gone from `skills/tdd/SKILL.md:79`
- [x] What replaces it (if anything) does **not** restate `LAYER.md`'s row content — `tdd` is a
      consumer of the vocabulary, not a second home for the layer inventory
- [x] The sentence still reads correctly for a project that has **no** `docs/adr/` yet — absence is
      legitimate under the lazy rule, so `tdd` must not imply every project has one
- [x] The glossary half of the same sentence is checked and either left alone (with the reason) or
      corrected
- [x] `bash .github/workflows/skills-lint.sh` passes

**Closed 2026-08-22.** The clause is gone — `grep 'no skill creates' skills/` returns nothing.

**The glossary half needed correcting too, not just checking (AC 4).** The old sentence opened *"use the
project's domain glossary ([[domain]])"*, which presumes one exists; under the lazy rule a project may
legitimately have neither artifact. The absence clause now covers **both**, so the sentence is honest for
a repo that has done no `/domain` work at all.

**No row content was copied (AC 2).** The sentence says who owns them and that either may be absent — the
consequence `tdd` actually needs. It does not mention the `(lazy)` marker, the `not applicable yet` state,
or the create-nothing rule; those stay in `LAYER.md`.

**One addition beyond the criteria, recorded rather than hidden:** *"don't start one mid-cycle — a glossary
entry or decision record written to unblock a refactor records the refactor's view, not the project's."*
It serves AC 3 by saying what to do on absence, and it enforces TASK-053's rule at the point of use, since
a TDD agent seeding a lazy artifact outside its owner is what that change exists to prevent.

**Out-of-scope sweep ran and found nothing to spawn.** The third bullet below is conditional on another
stale cross-reference turning up in `tdd`; `grep -rn -i 'glossary|docs/adr|\[\[domain\]\]' skills/tdd/`
returns this one line and nothing else, so the condition did not fire.

**Gate:** step 5b skipped under its own one-liner clause; the three axes were checked inline instead —
standards pass, intent pass, correctness pass. Lint `OK (18 skills)`.

**Sibling instance: TASK-057** (closed 2026-08-23) fixed four more of the same shape — a summary, count or
pointer that restates something maintained elsewhere and has since drifted from it. This task was the fifth
instance and was filed first. A reader of either should find the pattern: `fix-next` stating a count of a
table that had grown, two `verify-intent` *Related skills* lines contradicting their own page, and
`docs/architecture.md` describing an artifact as still arriving. **No lint was owed** — TASK-057 swept nine
stated counts in shipped prose and found the rest accurate, so this is a review concern, not a mechanical one.

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
