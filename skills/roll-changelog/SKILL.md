---
name: roll-changelog
description: Maintain a project's CHANGELOG.md (Keep a Changelog format) — roll recent commits / merged work into the `## [Unreleased]` section, and cut a dated release section when a version ships. Use when the user says "/roll-changelog", "update the changelog", "roll the changelog", "what changed", "aktualizuj changelog", "zapíš zmeny do changelogu", "cut a release", "bump version", "prepare release notes", or after a batch of work that should be recorded for humans. This is the *code* changelog (what shipped, for users/maintainers) — distinct from the per-feature *decision* ledger (`docs/features/FEATURE-NNN/decisions.md`, owned by [[feature]]) which records *why* choices were made. [[new-project]] seeds the CHANGELOG.md this skill maintains.
---

# roll-changelog

Keeps `CHANGELOG.md` honest and current in the [Keep a Changelog](https://keepachangelog.com) format. It rolls finished work into the `## [Unreleased]` section and, on request, cuts that section into a dated, versioned release.

This is the *code* changelog (what shipped). *Why* a choice was made lives in the per-feature `decisions.md` ([[feature]] skill). A same-named project-local `roll-changelog` never runs on Claude Code, because the user-level copy resolves first ([[verify-conventions]] § Scope layering has the measurement). A repo that needs its own changelog process ships it under a distinct name and invokes that skill by its own name; this skill does not look for one.

## Verbs / args

Invoked as `/roll-changelog [args]`:

- `/roll-changelog` — **roll** (default): gather work since the last recorded entry and fold it into `## [Unreleased]`, bucketed by change type.
- `/roll-changelog release <version>` — **cut a release**: rename `## [Unreleased]` to `## [<version>] - <date>`, add a fresh empty `## [Unreleased]` on top, and update the compare links at the bottom.
- `/roll-changelog release` — infer the next version from the Unreleased buckets (see [Version inference](#version-inference)) and confirm before cutting.

If `CHANGELOG.md` doesn't exist, offer to seed one (the [Keep a Changelog](#file-shape) skeleton — the same stub [[new-project]] writes) before rolling:

> **This repo has no `CHANGELOG.md`. Shall I create one from the Keep a Changelog skeleton and roll into it?**

**No answer, or nobody to ask:** create nothing, roll nothing, and report `no CHANGELOG.md: not seeded, nothing rolled`.
Every answer-less path in this skill ends this way, in a reported state and no write: a changelog is published
text, and a line in it nobody confirmed reads as a statement of what shipped.

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
   - If not git-tracked or history is thin: read `tasks/` for TASKs that moved to `done` and `docs/features/` for features that reached `done` since the last release. Only when those show nothing either, ask:

     > **Neither git history nor the trackers show anything shipped since <the boundary>. What shipped?**

     **No answer, or nobody to ask:** write nothing into `## [Unreleased]`, and report `nothing rolled: no record of shipped work since <the boundary>`. Never compose entries from the conversation or from memory: § Conventions says *don't invent changes*, and a run with no source has nothing else to write from.
2. **Translate to user language.** "Refactored `StoreResolver` to a strategy map" → *Changed: store backend resolution is now pluggable per-provider.* A reader of the changelog is a user or a future maintainer, not the author of the diff. Drop pure-internal churn (lint, formatting, test-only refactors) unless it changed observable behavior.
3. **Bucket** each change into Added / Changed / Fixed / etc.
4. **Cross-check the trackers** (don't double-count, don't miss): a feature that reached `done` in `docs/features/` and the TASKs under it are the *same* shipped work — record it once, as the user-facing capability. A `Security`/`Fixed` item that came from a Jira ticket can cite the key (`Fixed: … (SUP-1234)`) if the project links them.
5. **Write into `## [Unreleased]`** — merge with what's already there (don't clobber existing Unreleased bullets); keep bullets terse and imperative.

## Version inference

When the user runs `release` without a version, suggest one by semver from the Unreleased buckets — and **confirm before writing** (never auto-bump), with the question:

> **`## [Unreleased]` holds <the non-empty buckets>, so I suggest <x.y.z>, a <major | minor | patch> bump from <previous>. Cut <x.y.z>?**

**No answer, or nobody to ask:** cut nothing, and report `release not cut: <x.y.z> suggested, nobody confirmed`. The suggestion follows:
- any `Removed` or a breaking `Changed` → **major** bump
- any `Added` (and no breaks) → **minor** bump
- only `Fixed` / `Security` / `Deprecated` → **patch** bump

Respect a project that pins its own scheme (CalVer, 0.x where minor = breaking) — read the existing version history first and match it. If it does not settle the scheme, ask:

> **The existing versions (<the last few>) fit both <scheme A> and <scheme B>. Which does this project use?**

**No answer, or nobody to ask:** suggest no version and cut nothing, and report `release not cut: version scheme undetermined (<A> or <B>)`.

## Cut a release

1. Settle the version and the date. The version is the one passed to `release`, or the one confirmed under § Version inference; a version the user passed is their statement and needs no second confirm. The date comes from `--date` or the conversation, because this skill has no clock. With neither, ask:

   > **Which date goes on <version>? (YYYY-MM-DD)**

   **No answer, or nobody to ask:** cut nothing, and report `release not cut: no date`. A guessed date is an invented one.
2. Rename `## [Unreleased]` → `## [<version>] - <YYYY-MM-DD>`.
3. Insert a new empty `## [Unreleased]` above it.
4. Update the reference links at the bottom (`[Unreleased]: …/compare/v<version>...HEAD` and add `[<version>]: …/compare/v<prev>...v<version>`) — only if the project uses git-host compare links.
5. **Offer** (don't auto-run — these are outward-facing): a git tag `v<version>` and, in hybrid task mode, closing the milestone. Don't tag or push unless the user asks. The offer:

   > **Release <version> is written. Shall I tag it `v<version>`[ and close the milestone <name>]? Nothing is pushed either way.**

   **No answer, or nobody to ask:** tag nothing, close nothing, and report `not tagged: v<version>`.

## Conventions

- **No `Co-Authored-By:` trailers** in any commit this skill might create (user preference).
- PowerShell-compatible (no `2>/dev/null`, no inline `VAR=x cmd`).
- **No clock.** Take the date from the user or a `--date` arg / the conversation context; never invent one.
- **Don't invent changes.** Every bullet must trace to a real commit, closed task, or shipped feature. If you can't substantiate it, leave it out and say so.
- **Keep it human.** A changelog the user can't read at a glance has failed its purpose — terse, plain-language, one bullet per meaningful change.

## Related skills

- [[new-project]] — seeds the initial `CHANGELOG.md` skeleton.
- [[feature]] — decision ledger (`decisions.md`); this skill records the shipped result.
- [[tasks]] — `done` TASKs are a source for the roll.
- [[verify-conventions]] — lints code; this skill keeps the changelog current.
- [[roadmap]] — confirm trees agree before recording what shipped.
