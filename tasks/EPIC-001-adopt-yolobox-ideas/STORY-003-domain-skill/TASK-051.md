---
id: TASK-051
parent: STORY-003
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-21
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `domain` — the skill and its glossary half

## Context

STORY-003's foundation, and the slice that unblocks everything else in it.

`domain` is a **discipline**, not an action — hence the bare noun, alongside [[tdd]]. It is applied
*during* a grill or a design, not run as a one-shot verb, and that shapes the whole file: its content is
four things to do while a conversation is happening, not a numbered procedure to execute.

**This slice ships the glossary only.** `docs/glossary.md` is useful on its own — it fixes the project's
vocabulary so an agent uses the team's words instead of inventing synonyms — and the ADR half (TASK-052)
is additive. Splitting them keeps each landable and each independently valuable.

**Two dangling references must land in this same change, and one of them is why.**
`skills/tdd/SKILL.md:79` already tells agents to *"use the project's domain glossary … and respect ADRs
in the area you're touching"* — pointing at artifacts no skill creates. And
`skills/adopt-project/INFER.md` names `domain` in **plain text** rather than as `[[domain]]`, because a
wikilink to an absent skill fails the lint. So the promotion cannot land before the skill folder exists,
and leaving it after means the repo keeps a deliberate lint-driven workaround for a skill that is now
present. Same change, both files.

## Acceptance criteria

- [ ] `skills/domain/` exists, frontmatter `name: domain` matching the folder, `description` carrying the
      trigger phrases including the Slovak ones this team uses
- [ ] The **four live behaviours** are the body of the skill, each with the signal that triggers it:
      challenge a term that conflicts with the glossary; sharpen a fuzzy or overloaded term into a
      canonical one; stress-test relationships with concrete edge-case scenarios; cross-reference against
      the code and surface contradictions
- [ ] **Lazy creation** is stated: `docs/glossary.md` is written only when there is something to write.
      No empty scaffold — an empty glossary is worse than none, because it reads as "the vocabulary is
      settled and thin"
- [ ] The glossary's boundaries are stated: **no implementation detail, no spec, no scratch pad**. A term
      and what it means; where a definition wants a file path or an interface, that belongs elsewhere
- [ ] `skills/tdd/SKILL.md:79` becomes a proper `[[domain]]` link
- [ ] `skills/adopt-project/INFER.md`'s plain-text `domain` becomes `[[domain]]`
- [ ] `bash .github/workflows/skills-lint.sh` passes, and **both installers are re-run** — a new skill
      folder gets no junction until then, so neither runtime can resolve `[[domain]]` (the TASK-011
      defect, and check 4 now reports it)

## Out of scope

- **The ADR half** — TASK-052. This slice must be worth having without it, and the skill's own text
  should not promise ADR behaviour it does not yet carry.
- **Seeding from `new-project` / `adopt-project`** — TASK-053, which owns layer parity and `LAYER.md`.
- **Backfilling the ADRs already owed** — TASK-054.
- Teaching any other skill to *read* the glossary beyond the `tdd` reference that already exists.

## Human test plan

- [ ] Run it during a real grill in this repo and confirm it challenges at least one term that is used
      loosely here, rather than producing a generic vocabulary list
- [ ] Confirm no `docs/glossary.md` is created when there is nothing worth recording — the lazy rule is
      the one most likely to be quietly ignored
- [ ] Drill on a consumer repo with established vocabulary (Symbio's Slovak `KRITICKE` sections define
      many terms in prose) and confirm the cross-reference behaviour surfaces a real contradiction
- [ ] After re-running the installers, confirm `[[domain]]` resolves from both roots

## Implementation plan

_Populated by `/tasks plan TASK-051` — leave empty until then._
