# Decision record: `AGENTS.md` is canonical, `CLAUDE.md` is a one-line bridge

- **Date:** 2026-08-18 — both files landed in `1886df7`
- **Decided by:** reconstructed 2026-08-22 from the repo's own evidence (TASK-054). The `new-project` intake offers this shape as an option, so the choice was made deliberately at scaffold time; no discussion survives. A reconstruction.
- **Status:** accepted
- **Filed:** 2026-08-22 (retroactively — see *Decided by*)
- **Rule it produced:** none standing. The shape is enforced mechanically instead — `.github/workflows/ci.yml` asserts `CLAUDE.md` is exactly `@AGENTS.md`.

## Context

Claude Code auto-loads `CLAUDE.md`. Other agent tools — Codex, Cursor, and the `pi` runtime this repo also
installs into — look for `AGENTS.md`. A repo touched by more than one tool therefore has to answer where
the guide actually lives, and the answer is load-bearing here because **the guide is auto-loaded into
every task's context, which is what makes "the next task follows the same pattern" true rather than
aspirational.** A guide that half the tooling cannot find is a rulebook that applies half the time.

This repo is read by both Claude Code and pi by construction: it ships skills into `~/.claude/skills` and
`~/.pi/agent/skills`, and it eats its own cooking.

## Decision

**`AGENTS.md` holds the content; `CLAUDE.md` contains exactly one line, `@AGENTS.md`.** One source of
truth, both toolchains satisfied — Claude Code follows the import, everything else reads the canonical file
directly.

## Rejected alternatives

**`CLAUDE.md` only.** The default, and correct for a Claude-Code-only repo. Rejected because this repo is
demonstrably not one: it has a pi installer, and a rule invisible to pi is a rule that does not apply
where half the skills run.

**Duplicate the content into both files.** Immediately obvious and immediately wrong for the same reason
every other rule in this repo rejects a second copy: two rulebooks disagree the first time one is edited,
and nothing signals which is stale. The failure would be especially quiet here, since each tool reads only
its own copy and would never see the divergence.

**`AGENTS.md` alone, no `CLAUDE.md`.** Cleanest on disk, and it silently drops the guide for Claude Code —
the primary runtime. The bridge line is the cheapest thing that keeps the auto-load working.

## Consequences

**Easier.** One file to edit, and every tool that reads either name gets the same rules. `/verify-conventions`
finds the rulebook by following the bridge, which is a path its own ladder documents.

**Harder.** The bridge is a load-bearing single line, and *"someone will add content to `CLAUDE.md`"* is a
completely natural mistake — at which point the repo has the duplicate this record rejected, with no
signal. That is why CI asserts the file's exact content rather than trusting the convention, and the
assertion is the real enforcement; this record only explains it.

It also means **every reader meets the wrong file first.** Anyone opening `CLAUDE.md` sees one cryptic line,
which is surprising enough that it is half of why this record exists.

**Not affected.** Consumers are free to choose either shape — `new-project` still offers `CLAUDE.md`-only as
the default and reserves this form for repos that are plausibly multi-tool. This record is about *this*
repo, not a recommendation imposed on scaffolded ones.
