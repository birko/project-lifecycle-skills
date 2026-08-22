# Decision record: adopt the yolobox *ideas*, reimplement the prose

- **Date:** 2026-08-18 — recorded in `EPIC-001`'s § Provenance the day the epic was charted (`1886df7`)
- **Decided by:** the maintainer. Unlike records 0002–0004 this one is **not** reconstructed guesswork — the reasoning was written into `EPIC-001` at the time and this record consolidates it. Retroactively *filed*, not retroactively invented.
- **Status:** accepted
- **Rule it produced:** none standing. It is the trade-off that defines EPIC-001's shape.

## Context

The in-house `yolobox` sandbox carries a 16-skill set built on a different bet: **decision-first and
tracker-pluggable**, where the durable artifacts are a domain glossary, ADRs, and issues on a configured
tracker. This repo's bet is **artifact-first and file-based** — `docs/features/`, `tasks/`, `docs/specs/` —
chosen because it survives a session reset by construction.

Two of yolobox's ideas were plainly better than what existed here, and EPIC-001 exists to take them: a
record for *what a word means* and *why we chose it* (now [[domain]]), and a durable question ledger so a
grill can span sessions.

So the question was not *whether* to adopt but *how*: copy the files that already work, or rebuild the
same ideas against a different artifact model.

## Decision

**Adopt the ideas; reimplement the prose.** Every ported concept is rewritten against this repo's
artifact model, and `README.md` credits yolobox for the ideas.

## Rejected alternatives

**Copy the skill files and adjust.** The obvious move, and it fails on a detail that is easy to miss until
you try it: yolobox's files reference `CONTEXT.md`, `.scratch/` and `docs/agents/issue-tracker.md` — an
artifact model this repo does not share. **Every ported file would need a rewrite pass regardless**, so
"copy and adjust" is not actually cheaper than reimplementing; it is reimplementing while carrying someone
else's structure. There is also a licensing reason: yolobox is an in-house repo with no LICENSE at time of
writing, and this repo is public. Copying prose out of an unlicensed repo into a public one is a question
nobody needs to have.

**Adopt yolobox's model wholesale — become decision-first and tracker-pluggable.** Coherent, and rejected
because tracker-pluggability is a layer this repo deliberately does not want: `AGENTS.md` records
`to-tickets`/`setup-skills` as out of scope for exactly that reason. A tracker abstraction is the kind of
indirection that has to be maintained forever and earns its keep only for teams that switch trackers.

**Take only the glossary and skip the rest.** The cheapest adoption, and it drops the one idea whose
absence is structural rather than cosmetic: the question ledger. `decisions.md` is a durable stateful
ledger of *resolved* decisions while open questions are a prose bullet list, and that asymmetry is why
`/feature new` cannot span sessions. Skipping it leaves the known defect in place.

## Consequences

**Easier.** The skill set stays internally consistent — one artifact model, one vocabulary, no imported
concepts that half-fit. Every adopted idea arrives already speaking `tasks/`/`docs/features/`.

**Harder.** It is slower, and the cost is per-idea rather than one-off: STORY-003 through STORY-007 are
each a reimplementation rather than a copy. It also means **divergence is invisible** — if yolobox improves
one of these skills, nothing here notices, because there is no shared file to diff. That is an accepted
cost of not vendoring.

**Not affected.** yolobox itself. This is a one-way adoption; nothing flows back, and no dependency exists
in either direction.
