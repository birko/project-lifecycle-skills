---
id: STORY-003
parent: EPIC-001
# status: planned | in-progress | done | cancelled
status: planned
created: 2026-08-18
---

# `domain` — glossary and decision records

## User story

As an agent working in an unfamiliar repo, I want a glossary that fixes the project's vocabulary and
decision records that explain why things are the way they are, so that I use the team's words and
stop re-litigating settled trade-offs.

## Behaviour

- Creates `docs/glossary.md` and `docs/adr/NNNN-slug.md` **lazily** — only when there is something to write. No empty scaffolds.
- Named `domain` (bare noun, the discipline camp alongside `tdd`) because it is applied *during* a grill or a design, not as a one-shot action.
- Records are titled "Decision record: …" in prose; the path stays `docs/adr/` because `docs/decisions/` would collide with `docs/features/*/decisions.md`, which means something different — and external ADR tooling expects that path.
- **Four live behaviours during a session**, not a passive reference: challenge a term that conflicts with the glossary; sharpen a fuzzy or overloaded term into a canonical one; stress-test relationships with concrete edge-case scenarios; cross-reference against the code and surface contradictions.
- The glossary is a glossary — **no implementation detail, no spec, no scratch pad**.
- **ADRs are offered sparingly**: only when *hard to reverse* and *surprising without context* and *the result of a real trade-off*. Miss any one and skip it, or every skill starts minting ADRs.
- An ADR that hardens into a standing rule gets a one-line `AGENTS.md § Conventions` entry pointing back at it — the ADR carries the alternatives, the convention carries the enforceable one-liner.
- `new-project` **and** `adopt-project` both learn to seed it (layer parity).
- Fixes the dangling reference at `tdd/SKILL.md:79`, which has always told agents to use a glossary and respect ADRs that no skill created — as a proper `[[domain]]` link.
- **Backfills the ADRs already owed.** Decisions were made before `docs/adr/` existed and have no record: introducing Bash + a CI harness into a repo whose stack rule says "markdown only, no new language without an ADR"; making `AGENTS.md` canonical with a `CLAUDE.md` bridge; choosing `integration: single-branch`; reimplementing the yolobox ideas rather than porting them. Each is hard to reverse, surprising without context, and the result of a real trade-off — the skill's own three-part bar. Write them retroactively, dated honestly.
- **Promotes the deferred references.** `adopt-project/INFER.md` names `domain` in plain text because a wikilink to an absent skill resolves to nothing at runtime — the lint blocks it. Convert it to `[[domain]]` here, together with the `tdd/SKILL.md:79` fix, so both land in the same change as the skill itself.
- Ships `wait-what` alongside it: a five-line skill that says the last message did not land, re-pitch it in Simplified Technical English using the glossary's vocabulary. It is dead weight until the glossary exists, which is why it rides here.
