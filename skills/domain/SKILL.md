---
name: domain
description: Keep a project's vocabulary honest — fix what each term means in docs/glossary.md, challenge a word used against its definition, sharpen two names for one concept into one, and surface where the code contradicts the glossary. A discipline applied DURING a grill or a design, not a one-shot command. Use when the user says "/domain", "glossary", "domain glossary", "what does this term mean here", "are these the same thing", "define this concept", "unify the terminology", "slovnik pojmov", "co znamena tento pojem", "zjednot terminologiu", "je to to iste", or when two words seem to name one thing. Tech-agnostic.
---

# domain

The project's **vocabulary**, kept honest. A bare noun, alongside [[tdd]], because it is a discipline
rather than an action: you apply it *while* grilling an idea, naming a type, or reading unfamiliar code —
not by running it and reading a report.

**One artifact: `docs/glossary.md`.** Terms and what they mean, in this project's own words.

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

## What this skill does NOT do

- **Decide anything.** Where a term is contested, it surfaces the conflict and the user resolves it.
- **Produce a vocabulary list on request.** A glossary of terms nobody was confused about is the padded
  file the lazy rule exists to prevent.
- **Rename code.** A synonym confirmed as one concept is a finding; unifying it is a [[tasks]] `spawn`.
- **Record *why* a choice was made.** That is a decision record, and it is not part of this skill yet.

## Related skills

- [[adopt-project]] — its § *Glossary candidates* pass is where the input comes from on an existing repo.
- [[grill-me]] — the interrogation this discipline is applied during; a fuzzy term is a branch to resolve.
- [[tdd]] — test names and interface vocabulary come from here, so the words have to be right first.
- [[specs]] — behaviour, harvested from code. The glossary defines the nouns those specs are written in.
- [[feature]] — a feature's `decisions.md` records what was agreed; the glossary records what the words mean.
