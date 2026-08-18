# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This is the *code* changelog — what changed for people who install these skills. *Why* a choice
was made lives in `docs/adr/` (technical) and `docs/features/*/decisions.md` (per-feature).

## [Unreleased]

_Backfilled 2026-08-18 from the repository's first 36 commits (2026-07-15 → 2026-08-18); no
release has been cut yet, so the whole history to date sits here._

### Added

- **The lifecycle pipeline** — seven skills that carry an idea to shipped, reviewed, tested code: `new-project` (universal layer), `tasks` (Epic/Story/Task tracking), `feature` (idea → prototype → decisions → decompose → review), `roadmap` (cross-tree view + divergence audit), `populate-tests` (coverage backbone + `[auto]`/`[manual]` ledger), `specs` (capability specs harvested from code), `fix-next` (drains a defect backlog unattended).
- **Supporting skills** — `grill-me`, `tdd`, `verify-conventions`, `roll-changelog`, `handoff`.
- **`/tasks intake`** — file a review pass as tracked work, then drain it, so findings become fixed code instead of a report nobody actions. Paired with `fix-next`.
- **Lifecycle gates** — `/feature pick` (resolves what stage a feature is really at and offers the verb that unblocks it) and `/tasks spawn` (work discovered mid-flight becomes its own task instead of widening the one in hand).
- **The spec layer** — `docs/specs/` with a hand-edited `.map.yml` and generated capability specs, reviewed as a diff at story close as an intended-vs-unintended behavioural-change check.
- **Divergence checks** — `roadmap` grew a numbered DV1–DV12 audit for feature/task drift, including a ledger-backfill check and a flag for real code with no spec map.
- **Installers for both runtimes** — `install.sh` / `install.ps1` link `skills/` into Claude Code; `pi-install.sh` / `pi-install.ps1` link `skills/` + `skills-pi/` into the pi runtime.
- **`skills-pi/`** — pi-only fallback definitions of the review skills Claude Code ships natively (`code-review`, `review`, `security-review`), deliberately never installed into `~/.claude/skills` where they would shadow the native passes.
- MIT license; `.gitattributes` LF normalization.

### Changed

- **The skill set is now stack-agnostic.** Framework-specific references were removed and the stack-scaffolder dependency inverted: the generic front door knows only the *hook*, never a specific framework, so a team's wiring skill plugs in without either side hard-coding the other.
- **Verbs are standalone.** Rule sections moved out of router `SKILL.md` files and into the verb that owns them, so a verb file reads correctly on its own and the routers stay small.
- **Generated files are owned by their verbs** — dashboards, status rollups and specs must be regenerated, never hand-edited; a hand edit is a lie with a countdown.
- **The task-first gate hardened** — tests count as code, and work starts via `/tasks pick` rather than by editing.
- **`feature` delegates its collection pass to `roadmap`'s cross-tree engine**, so the two trees are read by one implementation instead of two that drift.
- **Runtime-skill references degrade gracefully** — a skill that names a runtime-provided pass now says what to do inline when that pass does not resolve, instead of silently skipping the gate.
- The seeded agent guide became filename-agnostic (renders to `CLAUDE.md` or `AGENTS.md`) and names the changelog leg.

### Fixed

- **`tasks close` no longer treats a missing Human test plan as an `N/A` one** — three tasks with every box ticked had been closed to `review` because the closer found no plan at all.
- **Spec staleness could never fire correctly** — the anchor was always earlier than the spec it stamps (measured: 25 of 25 stamps stale, reporting 15 false-positive areas against a true 6), and external sources were resolved against the wrong repo. Both corrected.
- **Spec provenance** — `shaped-by` is now derived on every regen, an unfilled field is no longer read as an empty answer, and the evidence resolver records how much of it was missing.
- **An empty-areas `.map.yml` is treated as absent** at every enforcement point, instead of passing checks it should have failed.
- **`fix-next` no longer nags (DV12) about a story that declares extraction-on-demand.**
- **`tasks` backfills the feature ledger on the link itself**, not on the `--from-feature` flag, so a link made any other way still reconciles.
- Workflow ordering hardened across the rollup/ledger chain; 16 gaps found by an end-to-end lifecycle drill closed; a skill-audit pass fixed cross-skill inconsistencies.
- The `code-review` stub records that Claude Code does not surface the built-in.

[Unreleased]: https://github.com/birko/project-lifecycle-skills/commits/main
