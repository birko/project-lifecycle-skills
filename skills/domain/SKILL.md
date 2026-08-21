---
name: domain
description: Keep a project's vocabulary and its settled trade-offs honest — fix what each term means in docs/glossary.md, challenge a word used against its definition, sharpen two names for one concept into one, surface where the code contradicts the glossary, and record a hard-to-reverse choice as a decision record under docs/adr/ so nobody re-litigates it. A discipline applied DURING a grill or a design, not a one-shot command. Use when the user says "/domain", "glossary", "domain glossary", "what does this term mean here", "are these the same thing", "define this concept", "unify the terminology", "why did we choose this", "should this be an ADR", "decision record", "slovnik pojmov", "co znamena tento pojem", "zjednot terminologiu", "je to to iste", "preco sme to zvolili", or when two words seem to name one thing. Tech-agnostic.
---

# domain

The project's **vocabulary**, kept honest. A bare noun, alongside [[tdd]], because it is a discipline
rather than an action: you apply it *while* grilling an idea, naming a type, or reading unfamiliar code —
not by running it and reading a report.

**Two artifacts.** `docs/glossary.md` — terms and what they mean, in this project's own words. And
`docs/adr/NNNN-slug.md` — **why** a choice was made, so nobody re-litigates a settled trade-off.

> **Written lazily. There is no scaffold.** The file appears when there is a term worth recording and not
> before. An empty glossary is worse than none — it reads as *"the vocabulary is settled, and thin"*,
> which is a claim, and a false one. Same for a glossary padded with obvious terms to look complete.

## What a glossary is not

Three boundaries, and each is a real failure this file has to prevent:

| Not | Why it rots |
|---|---|
| **Implementation detail** | a definition naming a file, class or interface goes stale on the next refactor, and takes the term's meaning down with it |
| **A spec** | *what the code does* is [[specs]]' job, harvested and regenerable. A hand-written behavioural claim here is a second source of truth that nothing checks |
| **A scratch pad** | open questions, TODOs and "we should decide this" belong in a feature's `idea.md`. A term you cannot yet state precisely is not a glossary entry — it is a question, and it stays one |

A good entry survives a rewrite of the code it describes. If it wouldn't, it is one of the three above.

## Invoked cold (`/domain`)

The four behaviours below are keyed on signals that occur mid-conversation, so a cold invocation has no
signal to react to. It gets one job — **behaviour 4 over what already exists**: read `docs/glossary.md`,
cross-reference every entry against the code's type, table and module names, and report the
contradictions. No glossary yet? Say so, and offer to start one from the terms that are *actually*
ambiguous in this repo — never from a list of obvious nouns.

That is the whole of the cold path. It is deliberately narrow: the value of this skill is in the other
three behaviours, and those need a conversation to be applied to.

## The four live behaviours

Each has a **signal** — the thing you notice that makes it fire. Without the signal you are producing a
vocabulary list, which nobody reads.

| Behaviour | Signal |
|---|---|
| **Challenge a term** | someone uses a defined word to mean something else — in conversation, a commit message, a type name. Say so at the moment it happens; a glossary nobody is held to is decoration |
| **Sharpen a fuzzy or overloaded term** | two names appear to mean one concept (`Tenant`/`Organization`, `User`/`Account`), or one name covers two (`status` as lifecycle *and* as health). Ask *"same thing, or genuinely different?"* — a "yes, same" is a real defect, and it is nearly invisible from inside the project |
| **Stress-test a relationship** | a definition asserts structure — *"a Tenant has Users"*. Test it with a concrete case: can a User belong to two Tenants? Can a Tenant exist with none? The answers usually reveal that the term meant something narrower |
| **Cross-reference against the code** | the glossary says one thing and the type names, table names or module boundaries say another. Surface the contradiction; don't quietly reconcile it — which one is wrong is the project's call, not yours |

**Adoption is the cheapest moment for all four.** [[adopt-project]]'s § *Glossary candidates* already
collects recurring domain nouns and **suspected synonyms** from a repo's own type and module names — that
list is this skill's best input, and the synonyms are the valuable half.

## Conventions

- **The project's words win.** If the team says *tenant* and the literature says *organization*, the
  glossary says tenant. This skill records vocabulary; it does not import a better one.
- **A term the project doesn't use doesn't get an entry**, however standard it is elsewhere.
- **Not every language is English.** A Slovak-speaking team's glossary is in Slovak, and a term that
  exists only in Slovak stays that way — see [[verify-conventions]] on reading a guide in its own language.
- **Define, then link.** Where a term is already defined in a `docs/adr/` record or a feature's
  `decisions.md`, the glossary entry states the meaning and points there rather than restating the
  reasoning.

## Decision records

A record of *why*, written so the reasoning outlives the conversation that produced it.

**The path is `docs/adr/`, and that is a decision rather than a default.** `docs/decisions/` reads better
in isolation and is wrong here: it collides with `docs/features/*/decisions.md`, which means something
else entirely — a per-feature ledger of what stakeholders agreed. External ADR tooling also expects
`docs/adr/`. Records are *titled* "Decision record: …" in prose, so the human-facing wording stays plain
while the path stays conventional. **Don't tidy the path later**; the collision is the reason.

**Which record is which** is settled by `AGENTS.md § The five records` — read it there. The short version:
an ADR answers *why we chose it* (technical, repo-wide), a feature's `decisions.md` answers *what was
agreed* (per feature, append-logged). Neither supersedes the other and one is not a draft of the other.

### The bar is a conjunction — all three, or no record

Offer one only when the decision is **hard to reverse**, **surprising without context**, *and* **the
result of a real trade-off**. Miss any one and skip it.

| Test | Fails when | Example of a fail |
|---|---|---|
| Hard to reverse | changing your mind later costs a line | a prose rule in one skill file |
| Surprising without context | the next reader would have done the same | following a convention the guide already states |
| The result of a real trade-off | there was no rejected alternative | the only option that worked |

**Name the test that failed when you decline**, and decline out loud. A skipped record and an unnoticed
one are indistinguishable afterwards, and the second is how the bar quietly stops applying.

**Why the bar is strict:** loosen it and every skill starts minting records. A `docs/adr/` nobody reads
is worse than none, because the next reader learns the directory is noise and stops opening it — at which
point the records that *did* matter are lost too.

### Shape

```
docs/adr/0001-slug.md      # NNNN, zero-padded, allocated in order and never reused
```

Four parts, and the third is the one people drop:

- **Context** — what was true that forced a choice.
- **Decision** — what was chosen, in one sentence.
- **Rejected alternatives** — each with *why not*. A record without this is a note, not a decision
  record: it cannot stop the re-litigation it exists to prevent, because the next reader's first idea is
  the alternative you already considered.
- **Consequences** — what this makes easy, and what it makes hard. Both.

**Written lazily**, like the glossary: no `docs/adr/` directory until there is a record to put in it.

### When a record hardens into a standing rule

It gets a **one-line entry in `AGENTS.md § Conventions` pointing back at the record**. The split is
load-bearing and easy to get backwards:

| Half | Carries |
|---|---|
| the ADR | the trade-off, the rejected alternatives, the context that made it a real choice |
| the § Conventions line | the enforceable one-liner, and a pointer |

A convention carrying its own trade-off inline is the inverse of this, and it is what happens when there
is nowhere to put the reasoning: the rule list becomes an essay collection and `/verify-conventions` has
to lint prose. Where you find one, the fix is to write the record and trim the line.

## What this skill does NOT do

- **Decide anything.** Where a term is contested, it surfaces the conflict and the user resolves it.
- **Produce a vocabulary list on request.** A glossary of terms nobody was confused about is the padded
  file the lazy rule exists to prevent.
- **Rename code.** A synonym confirmed as one concept is a finding; unifying it is a [[tasks]] `spawn`.
- **Decide what to record.** It offers; the user's call is what makes a decision a decision.

## Related skills

- [[adopt-project]] — its § *Glossary candidates* pass is where the input comes from on an existing repo.
- [[grill-me]] — the interrogation this discipline is applied during; a fuzzy term is a branch to resolve.
- [[tdd]] — test names and interface vocabulary come from here, so the words have to be right first.
- [[specs]] — behaviour, harvested from code. The glossary defines the nouns those specs are written in.
- [[feature]] — a feature's `decisions.md` records what was agreed; the glossary records what the words mean.
