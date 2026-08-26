# Decision record: `skills-pi/` is frozen, and installed into pi only

- **Date:** 2026-08-18 — the tree landed with the initial scaffold (`1886df7`)
- **Decided by:** reconstructed 2026-08-26 from the repo's own evidence (TASK-070's § Architecture sweep). The reasoning is stated in § Architecture; this record consolidates it and names the alternatives. A reconstruction of the *choice*, not of the rationale, which survives.
- **Filed:** 2026-08-26 (retroactively — see *Decided by*)
- **Status:** accepted
- **Rule it produced:** `AGENTS.md § Conventions › Code structure & patterns` — *"New skills go in `skills/`. `skills-pi/` is frozen."*

## Context

The merge gate calls [[code-review]], [[review]] and [[security-review]]. **Claude Code ships all three as
built-ins; the pi runtime ships none of them.** So a gate that simply invokes them works in one runtime and
resolves to nothing in the other — and "resolves to nothing" on a *review* pass is the worst possible
failure mode, because the gate appears to run and reports no findings.

`skills-pi/` holds fallback definitions of exactly those three, and `pi-install.sh` links it while
`install.sh` does not.

## Decision

**Three fallback skills, in a separate tree, installed into pi only — and the tree is frozen.** No new
skill is added there; every new skill goes in `skills/`, which is the only tree linked into *both* roots.

## Rejected alternatives

**Put the fallbacks in `skills/` with everything else.** Simplest, one tree, and it is the one option that
actively makes things worse: `~/.claude/skills/code-review` would **shadow Claude Code's native pass** with a
strictly inferior markdown reimplementation. A user would silently get the fallback instead of the built-in,
on the pass whose job is finding defects. The per-folder linking in
[ADR 0009](0009-installers-link-rather-than-copy.md) is what makes excluding them from one root possible at
all.

**No fallbacks — let the gate skip when a skill does not resolve.** Rejected because a review that silently
does not run is indistinguishable from one that found nothing. The skill set instead states the opposite rule
in several places: *never skip the gate because a skill name did not resolve* — do the pass inline. The
fallbacks are the written-down version of that inline pass for the runtime that needs it.

**Detect the runtime and branch at call time.** More precise in principle, and rejected because a skill is
prose with no runtime and no way to interrogate its host. The install-time split is the only mechanism
available, and it puts the decision where it can actually be made.

## Consequences

**Easier.** The gate works in both runtimes without either one carrying dead weight. pi gets a review pass;
Claude Code keeps its natives.

**Harder.** Three things follow, and the third is the least obvious:

- **The tree is frozen, and that has to be enforced socially.** Adding a skill there makes it invisible to
  Claude Code users, which is why `AGENTS.md` says so twice.
- **`skills-lint.sh` needs a shadow check.** A `skills-pi/` link appearing in the Claude root is the failure
  this decision exists to prevent, so the advisory install-root check reports *"a junction into a tree that
  root was never meant to hold"* (TASK-037).
- **Two of these names resolve as folders in one runtime only**, which means a `[[review]]` or
  `[[code-review]]` link is correct in both runtimes and *resolvable* in only one. That surfaced as a real
  finding two months later (TASK-071) and is now documented in the wikilink convention.

**Not affected.** The generic skills in `skills/`, which both roots receive identically.
