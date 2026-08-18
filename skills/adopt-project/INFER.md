# Reading conventions out of a codebase

[[new-project]] **asks** for conventions because there is no code to read. An existing repo has
already answered most of those questions in its source — this is how to read the answers out,
propose them, and let the user confirm or correct.

This is the part of adoption worth the most. An adopted repo whose `## Conventions` block is empty
gets nothing from [[verify-conventions]], which is the single biggest payoff of adopting at all.

## The two rules

**Propose, never assert.** Every inferred rule is shown to the user and confirmed before it is
written. An inference the user does not confirm is **dropped, not written as a guess** — a
plausible-but-wrong rule is worse than an absent one, because the next task follows it and
`verify-conventions` enforces it. You are proposing a rulebook the project will be held to.

**Show the evidence.** Every proposal carries the count and two or three representative paths that
suggested it. Without evidence the user can only rubber-stamp; with it they can disagree
specifically — *"that's 12 old files we're migrating away from"* is the answer you need and will
never get from a bare assertion.

```
Handlers return a Result type rather than throwing     [24/26 files]
  src/Orders/CreateOrderHandler.cs, src/Billing/ChargeHandler.cs
  → record as a Code structure rule?
```

## Convention or accident?

The distinguishing question is **prevalence among files the rule could apply to** — not raw count.

| Share of applicable files | Treat as |
|---|---|
| ~80%+ **and** at least 5 files | propose as a rule |
| roughly 20–80% | **ask**, don't assert — "these two shapes both appear; which is the intent?" |
| under 20%, or fewer than 3 files | stay silent, unless it is structural or security-relevant |

A split codebase is a **finding, not a failure**: mixed shapes usually mean a migration in flight,
and the useful output is "you have two patterns here — which one wins?" That question is often
worth more to the user than the rule itself.

## What to read, per subsection

Mirror the agent guide's `## Conventions` subsections, so proposals land where they belong.

- **Framework / stack** — manifests are authoritative: `package.json`, `*.csproj`, `pyproject.toml`, `go.mod`, `Cargo.toml`. Separate *direct* dependencies from transitive ones, and rank by import frequency: a dependency nothing imports is a leftover, not a convention. Note anything that looks deliberately absent (no ORM, no DI container) only if the code shows a consistent hand-rolled alternative.
- **Code structure & patterns** — the folder layout itself; dependency direction (does the domain import the web layer, or only the reverse?); error handling (a result type, exceptions, error returns); how boundaries are crossed (repository, direct queries, a mix).
- **Naming** — file naming (kebab, Pascal, snake), symbol casing per kind, test file naming, and any suffix convention (`*Handler`, `*Service`, `*Repository`) worth stating.
- **Testing** — the runner actually present, where tests live relative to source, the file naming, and whether integration tests are separated. **What the repo runs beats what its docs claim.**
- **UI / UX** — only when a human-facing surface exists. The component library actually imported, a design-token source, and whether accessibility attributes appear consistently. For a headless library, drop the subsection rather than filling it emptily.

## Glossary candidates

Recurring domain nouns in type and module names are the project's vocabulary, and adoption is the
cheapest moment to capture them. Collect two kinds:

- **Recurring nouns** — the entities the code is organised around.
- **Suspected synonyms** — two names that appear to mean one concept (`Tenant`/`Organization`, `User`/`Account`, `Customer`/`Client`). These are the valuable ones: ask *"same thing, or genuinely different?"*. A "yes, same" is a real defect surfaced, and it is nearly invisible from inside the project.

Hand these to the `domain` skill **once it exists** — it is not installed yet, so this is
deliberately not a `[[link]]`: a wikilink to an absent skill resolves to nothing at runtime and
the reference degrades silently. Until then, record the candidates in the agent guide under the
domain vocabulary heading and **say plainly that no glossary skill is present**, so they are not
quietly dropped.

## Asking

Use the frontier-round shape from [[grill-me]]: ask every question whose prerequisites are settled
in **one numbered round**, each with your recommended answer, then recompute from the replies.
One-at-a-time turns a 15-rule proposal into a 15-round interrogation, and the user stops answering
honestly around round six.

Facts are yours to find, decisions are the user's: never ask what reading the code would answer.

## When nothing can be inferred

A repo too small, too new, or too inconsistent to read rules from is a legitimate outcome. Say so,
leave the subsections empty, and record that they are empty **pending a real decision** — do not
invent rules the project never agreed to. An empty subsection is honest; a fabricated one is a
trap that `verify-conventions` will enforce against every future change.
