# Reading conventions out of a codebase

[[new-project]] **asks** for conventions because there is no code to read. An existing repo has
already answered most of those questions in its source — this is how to read the answers out,
propose them, and let the user confirm or correct.

This is the part of adoption worth the most **on a repo whose rulebook is thin or absent** — an
adopted repo whose `## Conventions` block is empty gets nothing from [[verify-conventions]], which is
the single biggest payoff of adopting at all. On a repo whose rulebook already answers what the layer
asks, the same step is worth the most by **declining**: see § *When the rulebook already answers it*.
Both readings are the same rule — fill what is missing, touch nothing else.

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

## When the rulebook already answers it

The opposite failure to the one below, and the more common one on a repo that has been running for a
while: proposing rules to a guide that already has better ones. **The unit of this step is the
subsection, not the round.**

- **Judge coverage per subsection** from § *What to read, per subsection* above, and propose only for
  the ones nothing answers.
- **"Covered" means the guide carries normative content answering that subsection — wherever it
  sits.** Use [[verify-conventions]]'s ladder rather than a heading match, so the two skills agree on
  what a rulebook is. A flat list of rules under one `## Conventions` heading can answer all five
  subsections; five tidy headings can answer none. (Measured: WorkoutTracker's rulebook is ~24 flat
  bold rules with no subsections at all, covering testing, code structure, framework and UI.)
- **All covered → skip the round.** Say so, name the subsections and the evidence that covered them,
  and write nothing. A guide denser than the layer asks for is a *finished* guide.
- **Some covered → run a round scoped to the rest.** Four of five covered is a one-subsection round —
  and it is worth more than a five-subsection one, because the user actually reads it.
- **Covered means *answered*, not exhausted — and a thinly answered subsection is offered, not run.**
  Where one rule answers a subsection the code could say much more about, name the thinness and
  **offer** that single-subsection round rather than launching it. (Measured on WorkoutTracker:
  testing, structure, framework and UI are answered by a dozen rules each; naming is answered by one
  file-naming rule, `one <Entity>Endpoints.cs per resource`. Skipping silently hides a real gap;
  proposing unasked contradicts *propose, never assert*.)
- **Never propose a rule beside an existing rule to strengthen it.** That is how a rulebook acquires
  two answers to one question, and the next task gets to pick.

**Two outputs still run even when every subsection is covered.** Recorded as a decision so it is not
re-litigated: **glossary candidates** and the **20–80% split finding**. Neither is a rule proposal.
Two names for one concept, and a migration caught in flight, are *findings about the code* — a
complete rulebook does not answer them, and the densest guide in a fleet can carry both.

On the skip path they are **reported, not asked.** § *Convention or accident?* turns a 20–80% split
into a question because a round is running and the answer shapes a proposal; when the round is
skipped there is no proposal to shape, so the split is stated as a finding and left with the user.
Announcing "skipping — your rulebook answers all five" and then opening a question round anyway is
the contradiction this paragraph exists to prevent.

## When nothing can be inferred

A repo too small, too new, or too inconsistent to read rules from is a legitimate outcome. Say so,
leave the subsections empty, and record that they are empty **pending a real decision** — do not
invent rules the project never agreed to. An empty subsection is honest; a fabricated one is a
trap that `verify-conventions` will enforce against every future change.
