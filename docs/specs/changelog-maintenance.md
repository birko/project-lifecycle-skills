---
area: changelog-maintenance
generated-at: 20c038b36b869ce21fee8cdd7d30bd0a8bcdfae9
generated-on: 2026-10-06
sources:
  - skills/roll-changelog/SKILL.md
shaped-by: []
shaped-by-derived: true
shaped-by-unresolved: 5
---

# Turning shipped work into a changelog a human would want to read

## Purpose

Changelog maintenance keeps a project's `CHANGELOG.md` current in the Keep a Changelog format. It does two jobs. A roll gathers work finished since the last release and folds it into the `## [Unreleased]` section as a few plain-language bullets, not a list of commits. A release turns that section into a dated, versioned one. It records *what* shipped, for users and future maintainers. *Why* a choice was made belongs to the per-feature decision ledger instead. Projects scaffolded or adopted by the lifecycle get a seeded `CHANGELOG.md` for this skill to maintain.

## Requirements

### Requirement: Three invocations — roll, release with a version, release without one

The system SHALL treat `/roll-changelog` with no arguments as a roll into `## [Unreleased]`, `/roll-changelog release <version>` as a release cut at that version, and `/roll-changelog release` with no version as a release whose version is inferred from the Unreleased buckets and confirmed before anything is cut.

#### Scenario: Bare invocation rolls

- **Given** a project with a `CHANGELOG.md`
- **When** the user runs `/roll-changelog`
- **Then** recent work is gathered and folded into `## [Unreleased]`, sorted into change-type buckets, and no release section is created

#### Scenario: Release with an explicit version

- **Given** an `## [Unreleased]` section with entries
- **When** the user runs `/roll-changelog release 1.4.0`
- **Then** the cut uses version `1.4.0` without inferring one

#### Scenario: Release without a version

- **Given** an `## [Unreleased]` section with entries
- **When** the user runs `/roll-changelog release`
- **Then** a version is suggested from the buckets and the cut waits for the user to confirm it

### Requirement: Offer to seed a missing changelog before rolling

The system SHALL, when `CHANGELOG.md` does not exist, offer to seed a Keep a Changelog skeleton (described as the same stub the project scaffolder writes) before rolling. It SHALL NOT create the file unasked. The skill itself does not spell out the skeleton's contents: the reference to its file shape points at a section the skill does not have.

#### Scenario: No changelog yet

- **Given** a repository with no `CHANGELOG.md`
- **When** the user runs `/roll-changelog`
- **Then** the skill offers to seed the skeleton first, and rolls only after that

### Requirement: Only the six Keep a Changelog buckets, never an empty one

The system SHALL file every entry under exactly one of `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed` or `Security`, use no other headings, and leave out any heading that has no entries.

#### Scenario: Only fixes shipped

- **Given** the gathered work contains two bug fixes and nothing else
- **When** they are written into `## [Unreleased]`
- **Then** the section contains a `### Fixed` heading with two bullets and no empty `### Added` or other headings

#### Scenario: A vulnerability fix

- **Given** a gathered change closes a security vulnerability
- **When** it is bucketed
- **Then** it goes under `Security`, because users look there for such fixes

### Requirement: Find the boundary of new work by a fixed preference order

The system SHALL decide what counts as new work in this order: the most recent `## [x.y.z]` release section in `CHANGELOG.md`; in a git repository, `git log <last-tag>..HEAD --no-merges` (or commits since the date of the top release section), reading commit subjects and bodies for intent; and, when the repository is not tracked in git or its history is thin, asking the user what shipped or reading tasks that moved to `done` under `tasks/` and features that reached `done` under `docs/features/` since the last release. Where the boundary falls is stated two ways: the roll is described as gathering work "since the last recorded entry", while this preference order names only release sections, tags and dates, and no rule de-duplicates against bullets already in `## [Unreleased]`.

#### Scenario: Git repository with a previous release

- **Given** `CHANGELOG.md` has a `## [0.1.0] - …` section, the repo has tag `v0.1.0`, and twelve non-merge commits follow it
- **When** a roll runs
- **Then** those twelve commits are the candidate work, read for intent rather than copied

#### Scenario: No git history to read

- **Given** a project that is not a git repository
- **When** a roll runs
- **Then** the skill asks the user what shipped, or reads `done` tasks and `done` features since the last release

#### Scenario: Rolling twice before a release

- **Given** a roll already wrote bullets into `## [Unreleased]` and no release has been cut since
- **When** a second roll runs
- **Then** whether it re-gathers the commits behind those bullets is not settled: the preference order points at the last release, and "since the last recorded entry" points at the bullets

### Requirement: Human-facing bullets, not a commit dump

The system SHALL write one terse, plain-language bullet per change a user would notice, not one per commit. It SHALL rewrite implementation language as what a user or future maintainer would see, and SHALL drop internal-only churn (lint, formatting, test-only refactors) unless that churn changed observable behaviour.

#### Scenario: A refactor that changed behaviour

- **Given** a commit "Refactored `StoreResolver` to a strategy map" that made the storage backend selectable per provider
- **When** it is rolled
- **Then** the entry reads as a `Changed` bullet about storage backends now being pluggable per provider, not about `StoreResolver`

#### Scenario: Formatting-only commits

- **Given** three commits that only reformat code and fix lint warnings
- **When** a roll runs
- **Then** none of them produces a bullet

### Requirement: Record one shipped capability once across both trackers

The system SHALL treat a feature that reached `done` under `docs/features/` and the tasks under it as the same shipped work, and record it once, as the capability a user sees. A `Fixed` or `Security` entry that came from a Jira ticket MAY cite the ticket key, if the project links them.

#### Scenario: A feature and its four tasks

- **Given** FEATURE-012 reached `done` and its four tasks are `done` in the same period
- **When** a roll runs
- **Then** one bullet records the capability, not five

#### Scenario: A fix from a ticket

- **Given** a fix came from Jira ticket SUP-1234 in a project that links tickets
- **When** it is written
- **Then** the bullet may read `… (SUP-1234)` under `Fixed`

### Requirement: Merge into Unreleased without clobbering

The system SHALL write new bullets into `## [Unreleased]` and keep the bullets already there. The skill states no rule for spotting a new bullet that repeats one already present.

#### Scenario: Unreleased already has entries

- **Given** `## [Unreleased]` already holds two `Added` bullets written by hand
- **When** a roll adds one more `Added` bullet
- **Then** the section holds all three

### Requirement: Never invent a change

The system SHALL trace every bullet to a real commit, closed task or shipped feature. Anything it cannot back up it SHALL leave out, and SHALL tell the user it left it out.

#### Scenario: An unsupported claim

- **Given** the user remembers a speed-up but no commit, task or feature records it
- **When** a roll runs
- **Then** no bullet is written for it and the skill reports that it was left out because nothing backs it up

### Requirement: Suggest a semver bump from the buckets, never apply it unconfirmed

The system SHALL, for `release` without a version, suggest a major bump when Unreleased has any `Removed` entry or a breaking `Changed` entry, a minor bump when it has any `Added` entry and nothing breaking, and a patch bump when it has only `Fixed`, `Security` or `Deprecated` entries. It SHALL confirm the suggestion before writing. Where the project's version history follows its own scheme (CalVer, or 0.x where a minor bump means breaking), the system SHALL match that scheme, and ask when it is unclear.

#### Scenario: New features, nothing breaking

- **Given** the previous release is `1.3.2` and Unreleased holds `Added` and `Fixed` entries
- **When** `release` runs without a version
- **Then** `1.4.0` is suggested and nothing is written until the user confirms

#### Scenario: A removal

- **Given** the previous release is `1.3.2` and Unreleased holds a `Removed` entry
- **When** `release` runs without a version
- **Then** `2.0.0` is suggested

#### Scenario: A project on 0.x where minor means breaking

- **Given** the history shows `0.x` releases where breaking changes bumped the minor version, and Unreleased holds a `Removed` entry
- **When** `release` runs without a version
- **Then** the suggestion follows the project's scheme rather than jumping to `1.0.0`

### Requirement: Cut a release section with a supplied date

The system SHALL cut a release by confirming the version and date, renaming `## [Unreleased]` to `## [<version>] - <YYYY-MM-DD>`, inserting a new empty `## [Unreleased]` above it, and — only when the project uses git-host compare links — pointing the `[Unreleased]` link at `v<version>...HEAD` and adding a `[<version>]` link comparing `v<prev>...v<version>`. The date SHALL come from the user, a `--date` argument or the conversation context; the skill has no clock and SHALL NOT invent one. No rule covers cutting a release from an empty `## [Unreleased]`.

#### Scenario: Cutting 1.4.0

- **Given** `## [Unreleased]` holds entries, the previous release is `1.3.2`, the file ends in compare links, and the user gives the date 2026-10-06
- **When** `release 1.4.0` is confirmed
- **Then** the section becomes `## [1.4.0] - 2026-10-06`, a new empty `## [Unreleased]` sits above it, `[Unreleased]` compares `v1.4.0...HEAD`, and a new `[1.4.0]` link compares `v1.3.2...v1.4.0`

#### Scenario: No date available

- **Given** neither the user nor the context supplies today's date
- **When** a release is cut
- **Then** the skill asks for the date instead of making one up

#### Scenario: No compare links in the file

- **Given** the changelog has no reference links at the bottom
- **When** a release is cut
- **Then** no links are added

### Requirement: Outward-facing release steps are offered, never run

The system SHALL offer, and not run, a git tag `v<version>` and, in hybrid task mode, closing the milestone. It SHALL NOT tag or push unless the user asks.

#### Scenario: Release cut, no instruction to tag

- **Given** a release section was just cut
- **When** the skill finishes
- **Then** it offers the `v<version>` tag (and the milestone close in hybrid mode) and creates neither unless the user asks

### Requirement: Commit and shell hygiene

The system SHALL add no `Co-Authored-By:` trailer to any commit it creates, and SHALL use shell commands that also work in PowerShell (no `2>/dev/null`, no inline `VAR=x cmd`).

#### Scenario: Committing the changelog

- **Given** the user asks for the rolled changelog to be committed
- **When** the commit is made
- **Then** its message carries no `Co-Authored-By:` trailer

### Requirement: Code changelog, not the decision ledger

The system SHALL record only what shipped and leave *why* it was chosen to the per-feature `decisions.md`. It also says a repository may ship a project-local `roll-changelog` that shadows this one, the same way project-local `verify-conventions` variants work.

#### Scenario: A rationale in the source commit

- **Given** a commit body explains at length why one approach beat another
- **When** it is rolled
- **Then** the bullet states the user-visible change and the rationale is not copied into the changelog
