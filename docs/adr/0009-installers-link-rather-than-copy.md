# Decision record: the installers link rather than copy

- **Date:** 2026-08-18 — both installers landed with the initial scaffold (`1886df7`)
- **Decided by:** reconstructed 2026-08-26 from the repo's own evidence (TASK-070). No contemporaneous discussion survives; the reasoning is inferred from what the installers do and from the corollary § Architecture already documents. A reconstruction.
- **Filed:** 2026-08-26 (retroactively — see *Decided by*)
- **Status:** accepted
- **Rule it produced:** none standing. The consequence is documented in `AGENTS.md § Architecture` and in the § Commands note that a **new skill folder needs an installer re-run**.

## Context

Four installers exist — `install.sh` / `install.ps1` into `~/.claude/skills`, `pi-install.sh` /
`pi-install.ps1` into `~/.pi/agent/skills` — and all four create a **link** (a symlink on POSIX, a junction
on Windows) per skill folder rather than copying the files.

The repo is a **single source of truth** for skills installed into two runtimes and consumed by every
project on the machine. The question a distribution mechanism has to answer is what happens to a consumer
when a skill changes here, and the two answers are very different: with links, an edit is live everywhere
immediately; with copies, every consumer is a stale snapshot until something re-runs.

## Decision

**Link, one per skill folder, at install time.** An edit in this repo is immediately live in every
consuming project and in both runtimes.

## Rejected alternatives

**Copy the folders.** The obvious alternative, and it inverts the property the repo exists for: the whole
point of one source of truth is that a fix reaches consumers without a distribution step. With copies,
every skill edit needs a re-install everywhere or consumers silently run old prose — and *prose is the
product*, so "old prose" means the rules an agent follows are wrong, not merely dated. It also makes the two
runtimes drift independently, since nothing would keep the Claude and pi copies in step.

**Link the whole tree once** — a single link at `skills/` rather than one per folder. Simpler, and rejected
because the two roots deliberately hold **different sets**: `~/.pi/agent/skills` gets `skills/` *and*
`skills-pi/`, while `~/.claude/skills` must not receive `skills-pi/` at all (see
[ADR 0010](0010-skills-pi-is-frozen-and-pi-only.md)). A per-folder link is what makes those sets expressible.

**Publish as a package and install by version.** The conventional answer for shared code, and wrong for
this shape twice over: it reintroduces the staleness links exist to remove, and it needs a package manager
in a repo whose stack rule is *markdown only* ([ADR 0002](0002-bash-lint-harness-in-a-markdown-repo.md)
already spends that budget on the lint harness).

## Consequences

**Easier.** A fix is live everywhere the moment it is committed. The repo genuinely is one source of truth
rather than an upstream that consumers periodically sync from.

**Harder, and this is the corollary that bites.** A link is created **per folder, at install time**, so:

- **A new skill folder needs an installer re-run** before either runtime can resolve it. Editing an existing
  skill never does. This is the single most common way a new skill appears not to exist, and it is why
  `AGENTS.md § Commands` says to re-run *both* installers after adding a folder.
- **The installers only ever add.** Renaming or deleting a skill leaves its old link behind, pointing at
  nothing, and nothing prunes it — so a rename needs a manual sweep of both roots. `skills-lint.sh`'s
  advisory install-root check exists because of this: it reports a folder with no link, a link whose source
  is gone, and a link into a tree that root was never meant to hold.
- **Every consumer is exposed to work in progress.** There is no released version to pin to; a half-finished
  edit is live. That is an accepted cost of a single-maintainer repo and it stops being acceptable the moment
  someone else depends on stability here.

**Not affected.** The skills themselves — nothing about a skill's content depends on how it is delivered.
