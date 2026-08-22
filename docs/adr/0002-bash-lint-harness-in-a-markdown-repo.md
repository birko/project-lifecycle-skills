# Decision record: a Bash lint harness in a repo whose stack rule says markdown only

- **Date:** 2026-08-18 — the day the harness and the stack rule landed together (`1886df7`)
- **Decided by:** reconstructed 2026-08-22 from the repo's own evidence (TASK-054). No contemporaneous discussion survives; the reasoning below is inferred from what the commit did and from the rule it had to satisfy. Read it as a reconstruction, not as minutes.
- **Status:** accepted
- **Filed:** 2026-08-22 (retroactively — see *Decided by*)
- **Rule it produced:** `AGENTS.md § Conventions › Framework / stack` — *"Don't introduce a language, package manager, or generator without an ADR."* This record is the ADR that clause anticipated.

## Context

The stack rule states the repo's whole premise: *"Markdown + YAML frontmatter only. A skill is prose an
agent reads; it has no runtime, no build step, and no dependencies."* Taken literally that forbids
executable code, and the same commit that wrote it added `.github/workflows/skills-lint.sh` — a Bash
script — plus a CI workflow to run it.

That is not an oversight, it is the rule working: the clause exists precisely to force a record when a
language arrives. What forced it here is that **the load-bearing invariants of a prose skill set are
mechanically checkable, and nothing else was going to check them.** A `[[wikilink]]` that resolves to no
folder, a `SKILL.md` with no `name:`, a file a router references that does not exist — each silently
breaks a skill at the moment a consumer's agent tries to follow it, and each is exactly the kind of thing
a human reviewer skims past.

## Decision

**The lint harness and its own test suite, in Bash, run by CI — and no executable code in the *product*.** The harness is treated as
*test tooling*, not as part of the product: skills stay pure markdown, and the only thing that ever
executes is the gate that checks them. The stack rule's spirit is "a skill has no runtime", not "the
repository contains no scripts".

## Rejected alternatives

**No automated gate at all — rely on review.** The purest reading of the stack rule, and rejected because
the invariants are precisely the ones review is worst at. Every subsequent finding in this repo about a
dangling reference or an unregistered pattern is evidence for that; the gate has caught things no reader
did.

**A Node or Python linter.** More expressive, and it loses the property that matters: it needs a package
manager, a lockfile, a version, and a `node_modules`/venv in a repo that otherwise has no dependency
surface at all. Bash plus the tools a CI runner already has keeps the dependency count at zero, which is
what makes "no dependencies" still substantially true.

**Pure GitHub Actions YAML with inline `run:` steps.** Avoids a script file, and was rejected because the
checks then cannot be run locally. `bash .github/workflows/skills-lint.sh` before a commit is the whole
point; a gate that only exists inside CI is discovered after the fact.

## Consequences

**Easier.** The repo's only real invariants are enforced, cheaply, on every push and locally on demand.
Consumers get a skill set where the cross-references actually resolve.

**Harder.** The stack rule now has an exception, and an exception invites a second one — which is why the
rule demands an ADR rather than a judgement call. It also created a second-order obligation the repo did
not initially meet: the harness is the only gate, so a silent regression in *it* disables checking with no
signal, which is why `skills-lint-test.sh` exists and why `AGENTS.md § Testing` requires a failing case
before a lint change is done.

**Not affected.** Skills themselves remain markdown with no runtime; nothing a consumer installs executes.
The Bash lives in `.github/`, on the CI side of the line, and the installers (`install.sh`, `install.ps1`)
are a separate matter — they long predate this and are delivery, not product.
