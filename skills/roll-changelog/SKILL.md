---
name: roll-changelog
description: Maintain a project's CHANGELOG.md (Keep a Changelog format) — roll recent commits / merged work into the `## [Unreleased]` section, and cut a dated release section when a version ships. Use when the user says "/roll-changelog", "update the changelog", "roll the changelog", "what changed", "aktualizuj changelog", "zapíš zmeny do changelogu", "cut a release", "bump version", "prepare release notes", or after a batch of work that should be recorded for humans. This is the *code* changelog (what shipped, for users/maintainers) — distinct from the per-feature *decision* ledger (`docs/features/FEATURE-NNN/decisions.md`, owned by [[feature]]) which records *why* choices were made. [[new-project]] seeds the CHANGELOG.md this skill maintains.
---

# roll-changelog

Keeps `CHANGELOG.md` honest and current in the [Keep a Changelog](https://keepachangelog.com) format. It rolls finished work into the `## [Unreleased]` section and, on request, cuts that section into a dated, versioned release.

> **Generic, cross-project skill.** This is the *general* changelog maintainer for any stack. A repo may ship its own project-local `roll-changelog` variant that does something repo-specific (a different source block, a house format); inside that repo the project-local skill **shadows this one** — correct, and the same scope-layering as project-local variants of [[verify-conventions]]. This generic skill is what runs everywhere else.

> **This is the code changelog — not the decision ledger.** It answers *"what changed in the software"* for users and maintainers. *Why* a choice was made lives in the per-feature `decisions.md` ([[feature]] skill). A single piece of work often touches both: the decision is logged in `decisions.md`, the user-visible result is logged here. Don't duplicate rationale into the changelog, and don't bury shipped changes only in a decision ledger no user reads.

## Verbs / args

Invoked as `/roll-changelog [args]`:

- `/roll-changelog` — **roll** (default): gather work since the last recorded entry and fold it into `## [Unreleased]`, bucketed by change type.
- `/roll-changelog release <version>` — **cut a release**: rename `## [Unreleased]` to `## [<version>] - <date>`, add a fresh empty `## [Unreleased]` on top, and update the compare links at the bottom.
- `/roll-changelog release` — infer the next version from the Unreleased buckets (see [Version inference](#version-inference)) and confirm before cutting.

If `CHANGELOG.md` doesn't exist, offer to seed one (the [Keep a Changelog](#file-shape) skeleton — the same stub [[new-project]] writes) before rolling.

## Change-type buckets (Keep a Changelog)

Every entry goes under exactly one heading. Use these and only these:

| Heading | For |
|---|---|
| `Added` | new features / capabilities |
| `Changed` | changes to existing behavior |
| `Deprecated` | soon-to-be-removed features |
| `Removed` | features removed in this release |
| `Fixed` | bug fixes |
| `Security` | vulnerability fixes (call these out — users scan for them) |

Omit a heading entirely if it has no entries — never leave an empty `### Added`.

## Roll — gathering what changed

The goal is **human-facing, not a commit dump**. One bullet per user-meaningful change, in plain language, not one per commit.

1. **Find the boundary** — what's already recorded vs. new. In order of preference:
   - The most recent `## [x.y.z]` release tag/date in `CHANGELOG.md` → gather work since then.
   - If the repo is git-tracked: `git log <last-tag>..HEAD --no-merges` (or since the date of the top release section). Read commit subjects/bodies for intent.
   - If not git-tracked or history is thin: ask the user what shipped, or read `tasks/` for TASKs that moved to `done` and `docs/features/` for features that reached `done` since the last release.
2. **Translate to user language.** "Refactored `StoreResolver` to a strategy map" → *Changed: store backend resolution is now pluggable per-provider.* A reader of the changelog is a user or a future maintainer, not the author of the diff. Drop pure-internal churn (lint, formatting, test-only refactors) unless it changed observable behavior.
3. **Bucket** each change into Added / Changed / Fixed / etc.
4. **Cross-check the trackers** (don't double-count, don't miss): a feature that reached `done` in `docs/features/` and the TASKs under it are the *same* shipped work — record it once, as the user-facing capability. A `Security`/`Fixed` item that came from a Jira ticket can cite the key (`Fixed: … (SUP-1234)`) if the project links them.
5. **Write into `## [Unreleased]`** — merge with what's already there (don't clobber existing Unreleased bullets); keep bullets terse and imperative.

## Version inference

When the user runs `release` without a version, suggest one by semver from the Unreleased buckets — and **confirm before writing** (never auto-bump):
- any `Removed` or a breaking `Changed` → **major** bump
- any `Added` (and no breaks) → **minor** bump
- only `Fixed` / `Security` / `Deprecated` → **patch** bump

Respect a project that pins its own scheme (CalVer, 0.x where minor = breaking) — read the existing version history first and match it; ask if ambiguous.

## Cut a release

1. Confirm the version + today's date (the date is passed in — this skill has no clock; ask or accept a `--date`).
2. Rename `## [Unreleased]` → `## [<version>] - <YYYY-MM-DD>`.
3. Insert a new empty `## [Unreleased]` above it.
4. Update the reference links at the bottom (`[Unreleased]: …/compare/v<version>...HEAD` and add `[<version>]: …/compare/v<prev>...v<version>`) — only if the project uses git-host compare links.
5. **Offer** (don't auto-run — these are outward-facing): a git tag `v<version>` and, in hybrid task mode, closing the milestone. Don't tag or push unless the user asks.

## File shape

```markdown
# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- …

### Fixed
- …

## [0.1.0] - 2026-06-22

### Added
- Initial release.

[Unreleased]: https://github.com/<owner>/<repo>/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/<owner>/<repo>/releases/tag/v0.1.0
```

## Conventions

- **No `Co-Authored-By:` trailers** in any commit this skill might create (user preference).
- PowerShell-compatible (no `2>/dev/null`, no inline `VAR=x cmd`).
- **No clock.** Take the date from the user or a `--date` arg / the conversation context; never invent one.
- **Don't invent changes.** Every bullet must trace to a real commit, closed task, or shipped feature. If you can't substantiate it, leave it out and say so.
- **Keep it human.** A changelog the user can't read at a glance has failed its purpose — terse, plain-language, one bullet per meaningful change.

## Related skills

- [[new-project]] — seeds the initial `CHANGELOG.md` skeleton this skill maintains.
- [[feature]] — owns the *decision* ledger (`decisions.md`); the *why*. This skill owns the *what-shipped*. A change is often recorded in both at different altitudes.
- [[tasks]] — `done` TASKs and `/tasks close` are a source for the roll; cite ticket/issue keys where the project links them.
- [[verify-conventions]] — the other generic "keep the project honest" skill; lints code against `CLAUDE.md` rules the way this one keeps the changelog current.
- [[roadmap]] — read-only cross-tree view; a release cut is a good moment to confirm the two trees agree before recording what shipped.
