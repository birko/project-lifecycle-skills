---
area: specs-from-code
generated-at: 1cdf452fbb2594ffe3016cf359b041815fdd8957
generated-on: 2026-10-03
sources:
  - skills/specs/SKILL.md
  - skills/specs/templates/map.yml
  - skills/specs/templates/spec.md
  - skills/specs/verbs/help.md
  - skills/specs/verbs/init.md
  - skills/specs/verbs/regen.md
  - skills/specs/verbs/show.md
  - skills/specs/verbs/verify.md
shaped-by: [FEATURE-003]
shaped-by-derived: true
shaped-by-unresolved: 7
---

# Specifications generated from the code itself, so they cannot silently go stale

## Purpose

This capability keeps a project's behavioural specifications honest by deriving them from the code rather than writing them by hand. A project declares its capability areas in a hand-editable area map; each area's spec is harvested from that area's source files, and every regeneration is presented as a diff to be judged as an intended or unintended behaviour change. Each spec carries a machine-checkable stamp (the commit it was harvested at, its resolved sources, and the features that shaped it) so that a read-only check can tell which specs have fallen behind their code, and so that feature review and the cross-tree drift audit can rely on the provenance it records.

## Requirements

### Requirement: Verb routing and the bare command

The system SHALL accept `init`, `regen`, `verify`, `show` and `help` as verbs, read only the instructions for the verb requested, and treat the bare command with no verb as `verify` in summary mode.

#### Scenario: Bare command gives the compact staleness answer

- **Given** a project with a usable area map of four areas
- **When** the user runs the specs command with no verb
- **Then** the staleness check runs in summary mode, rendering only the counts block and adding per-area detail only if something is stale

#### Scenario: Help prints the verb table and exits

- **Given** any project
- **When** the user runs the help verb
- **Then** a fixed listing of every verb and the regen flags (`--all`, `--story`, `--feature`) is printed and nothing else happens

### Requirement: No usable map stops every verb except init

The system SHALL, when the project has no area map or has one whose `areas:` list is empty, print `No usable spec map — run /specs init to bootstrap.` and exit, except for `init`, which treats an empty-areas map as a fresh discovery.

#### Scenario: Scaffolded empty map

- **Given** a project whose area map exists with `areas: []`
- **When** the user runs `regen --all`
- **Then** the no-usable-map message is printed and no spec is written

#### Scenario: Init over an empty map

- **Given** the same empty-areas map
- **When** the user runs `init`
- **Then** init proceeds with a fresh discovery instead of refusing

### Requirement: The area map declares capabilities, not classes

The system SHALL keep a hand-editable area map in which each area has a kebab-case `name` (which names its spec file), a `title`, and a list of `sources` globs relative to the project root, alongside an optional `ignore` list, and SHALL treat that map as the only human-owned file among the specs; spec bodies are generated and are not hand-edited.

#### Scenario: Area name becomes the spec file

- **Given** an area named `order-pricing` with title "Order pricing" and two source globs
- **When** that area is harvested
- **Then** its spec is written to a file named `order-pricing.md` beside the map

#### Scenario: Granularity guidance

- **Given** a discovery pass proposing areas for a codebase
- **When** the areas are drafted
- **Then** each one is a capability a stakeholder would recognise, aiming at roughly five to twenty areas, never one per class

### Requirement: Coverage keys record whether the map was checked

The system SHALL carry three coverage keys in the map — `coverage` (one of `verified`, `not-applicable`, `unverified`), `tracked-files-at-scan` (the number of files git tracked when the scan ran, never a coverage numerator), and `coverage-drift` (a list of paths, never a count) — and SHALL read an absent `coverage` as `unverified` and absent companions as not computed rather than as zero or empty.

#### Scenario: Map predating the keys

- **Given** a populated map with no `coverage` key
- **When** any verb reads it
- **Then** it is treated as `unverified`, and its missing `coverage-drift` is read as not computed

#### Scenario: Empty drift list is a finding

- **Given** a map carrying `coverage-drift: []`
- **When** a reader interprets it
- **Then** it means the run looked and found no drifted paths, distinct from the key being absent

#### Scenario: Freshly rendered template

- **Given** the map template rendered with no scan having run
- **When** it is written
- **Then** it carries `coverage: unverified`, `areas: []`, no scan companions, and its `ignore:` examples commented out

### Requirement: The scan universe is every file git tracks

The system SHALL take the set of files to cover as every file git tracks, with `ignore` removing what does not belong; untracked files are out of scope.

#### Scenario: Untracked build artefact

- **Given** a tracked tree of 120 files and an untracked generated file in the working tree
- **When** the scan set is resolved
- **Then** the scan examines the 120 tracked files and does not count the untracked one

#### Scenario: Documentation is in scope unless ignored

- **Given** a tracked `notes/design.md` matched by no area and no ignore entry
- **When** coverage is checked
- **Then** it is reported as unmapped

### Requirement: Globs are matched as glob pathspecs

The system SHALL match every glob — area sources and ignore entries, in every verb that resolves one — as a git pathspec with the `:(glob)` prefix, so that a `**` pattern also matches files sitting directly at its root.

#### Scenario: Top-level file under a recursive glob

- **Given** an area source glob `lib/**/*.py` and a changed file `lib/core.py`
- **When** staleness is computed
- **Then** the change is seen, because the glob is passed as `:(glob)lib/**/*.py`

### Requirement: Dot-prefixed paths are ordinary members of the scan

The system SHALL treat dot-prefixed paths as ordinary scan members, skipping only `.gitignore`, `.gitattributes` and `.editorconfig` without an explicit `ignore` entry.

#### Scenario: Committed files under a dot-directory

- **Given** three tracked files under `.tooling/prompts/` and no ignore entry for them
- **When** coverage is checked
- **Then** all three are reported as unmapped

#### Scenario: The three implicit skips

- **Given** a tracked `.gitattributes` with no ignore entry
- **When** coverage is checked
- **Then** it is not reported as unmapped

### Requirement: Init discovers a capability map

The system SHALL, on `init`, find the project root by the same walk the task tracker uses, read the project's agent guide and readme first and prefer their vocabulary, survey the source structure (fanning out one explorer per top-level source folder for a large codebase), and propose areas with source globs plus an `ignore` list of build output, tests, generated code and vendored dependencies.

#### Scenario: Polyrepo meta-root

- **Given** the working directory is the meta-root of a polyrepo family
- **When** init runs
- **Then** it asks whether to create cross-cutting specs at the meta level or for a specific subproject

#### Scenario: Inside a subproject

- **Given** the working directory is inside one subproject of a polyrepo
- **When** init runs
- **Then** it initialises that subproject's own specs folder

### Requirement: Init presents the map and reconciles coverage

The system SHALL present the proposed map as a table of area, title, globs and rough file count, always report how many files the scan examined including zero, list every file matching neither an area nor `ignore` as unmapped, and either extend an area or add one; where reconciliation needs the user it SHALL ask once over the whole unmapped list whether each file is behaviour belonging in an area or not project source, and with no answer leave those files unmapped rather than sweeping them into `ignore`.

#### Scenario: Unanswered unmapped question

- **Given** five files unmapped after discovery and no user available to answer
- **When** init reconciles coverage
- **Then** the five files stay unmapped, none is added to `ignore`, and the verdict becomes `unverified`

#### Scenario: Unmapped file folded into an area

- **Given** `src/Billing/Refund.cs` was unmapped at first scan and is folded into the `billing` area
- **When** init records the result
- **Then** that path appears in `coverage-drift`

#### Scenario: Unmapped file sent to ignore

- **Given** `deploy/run.sh` was unmapped at first scan and is added to `ignore` as housekeeping
- **When** init records the result
- **Then** that path does not appear in `coverage-drift`

### Requirement: Init ends with exactly one coverage verdict

The system SHALL end init's coverage step with exactly one verdict describing the map about to be written: `verified` when the scan set is non-empty, nothing is unmapped after reconciliation, and the map was blessed; `not-applicable` when the scan set is empty and the repository genuinely has no behavioural code; and `unverified` in every other case, stated with a one-line reason.

#### Scenario: Gap closed during the run

- **Given** two files unmapped at first scan, both folded into areas, and the map blessed
- **When** the verdict is computed
- **Then** it is `verified`, and the two paths are listed in `coverage-drift`

#### Scenario: Discovery finds nothing while sources exist

- **Given** a repository with source files that the scan failed to discover
- **When** the verdict is computed
- **Then** it is `unverified` with a one-line reason, and fixing the discovery is preferred over writing the map

#### Scenario: Docs-only repository

- **Given** a repository containing only documentation and no behavioural code
- **When** the verdict is computed
- **Then** it is `not-applicable`, and a minimal map (or none) is written without invented areas

### Requirement: Blessing gates writing a verified map

The system SHALL, after an optional grill of area boundaries, ask "Here is the proposed capability map for `<project>` — `<N>` areas over `<M>` tracked files, coverage `<verdict>`. Shall I write it to `docs/specs/.map.yml`?" with the options bless, change, or don't write; SHALL re-ask after any change to the presented map; and, when no answer comes, SHALL write the map stamped `unverified` with the reason "areas proposed but never blessed" and say in the confirmation that the areas were written unblessed.

#### Scenario: Unattended init

- **Given** init run with nobody present to answer
- **When** it reaches the blessing question
- **Then** it writes the map with `coverage: unverified` and reports that it wrote the areas unblessed and nobody confirmed the boundaries

#### Scenario: Change after a yes

- **Given** the user blessed a map and then renamed one area
- **When** the map is about to be written
- **Then** the amended table is presented and blessing is asked again

### Requirement: Re-discovery edits the existing map in place

The system SHALL, when a map file already exists (including one with an empty `areas:` list), treat init as an edit: show a delta rather than a fresh map, apply only the blessed changes, added ignore entries and the three coverage keys, and preserve every other line including comments and ordering; it SHALL render the template only when no map file exists, writing the proposed ignore list as a live key.

#### Scenario: Seeded map with comments

- **Given** an existing map with a header comment explaining its origin, `areas: []`, and a commented ignore list
- **When** init writes the discovered areas
- **Then** the header comment and the commented lines survive, and only the areas, any reconciliation ignore entries and the coverage keys change

#### Scenario: Map previously written unverified

- **Given** an existing map stamped `coverage: unverified` with three areas
- **When** init re-runs
- **Then** it says the map was never verified and treats the three areas as proposals to re-confirm, not as a blessed baseline

### Requirement: Init never drops an area without asking

The system SHALL ask once per area proposed for removal, giving the reason, with the options keep or drop, and SHALL keep the area when no answer comes.

#### Scenario: Unanswered removal

- **Given** a re-discovery proposing to drop area `legacy-export` because nothing matches its globs
- **When** nobody answers the removal question
- **Then** `legacy-export` remains in the written map

### Requirement: Init offers but does not run the first harvest

The system SHALL end init by suggesting a full regeneration of every area without running it.

#### Scenario: After writing the map

- **Given** init has written a map of six areas
- **When** it finishes
- **Then** it suggests `regen --all` and does not start a harvest

### Requirement: Regen resolves which areas to harvest

The system SHALL accept named areas, `--all`, `--story STORY-NNN` (areas resolved from the story's tasks' recorded references matched against map globs, asking which areas when references are missing), and `--feature FEATURE-NNN` (the same resolution over all the feature's tasks), and SHALL list the valid areas and stop when a named area is unknown.

#### Scenario: Unknown area name

- **Given** a map with areas `alpha-sync` and `beta-report`
- **When** the user regenerates `gamma`
- **Then** the two valid area names are listed and nothing is harvested

#### Scenario: Story-scoped regen

- **Given** a story whose two tasks record commits touching files under the `alpha-sync` globs
- **When** regen runs with `--story STORY-042`
- **Then** `alpha-sync` is harvested and the tasks' feature links are carried into its provenance

### Requirement: Harvest grounds the spec in the code as it is

The system SHALL resolve an area's globs to a concrete file list, read any existing spec before the sources, and write a Purpose paragraph followed by requirement blocks stated as "The system SHALL …", each with at least one Given/When/Then scenario, describing behaviour as the code actually has it including behaviour that looks like a bug.

#### Scenario: Apparent bug in the source

- **Given** an area whose code rounds totals down where callers expect rounding to nearest
- **When** the area is harvested
- **Then** the spec states the round-down behaviour, and the bug is raised in the diff review with an offer to file a task

#### Scenario: Globs resolve to nothing

- **Given** an area whose globs match zero files
- **When** regen reaches it
- **Then** it reports the map as stale for that area and suggests a map fix instead of writing an empty spec

### Requirement: Regeneration keeps stable wording

The system SHALL, when an existing spec is regenerated, change only what the code contradicts and keep requirements the code still satisfies verbatim; a first-ever harvest of an area SHALL write the full spec and present it for a skim with no diff review.

#### Scenario: Unchanged behaviour

- **Given** an existing spec whose requirement on retry limits still matches the code
- **When** the area is regenerated
- **Then** that requirement's wording is unchanged and does not appear in the diff

#### Scenario: First harvest

- **Given** a mapped area with no spec file
- **When** it is regenerated
- **Then** the full spec is written and shown for a skim without a diff classification

### Requirement: Fan-out harvests in parallel and reviews serially

The system SHALL, under `--all`, harvest areas in parallel with one agent per area and then run the diff reviews one at a time.

#### Scenario: Many areas

- **Given** a map of twelve areas
- **When** `regen --all` runs
- **Then** the twelve harvests run in parallel and their diff reviews are presented sequentially

### Requirement: Every behavioural change in a spec diff is classified

The system SHALL show each changed area's spec diff and classify every behavioural change as matching an approved decision (checked against the approved and changed rows of features resolved from story or feature context), intended anyway (confirmed by the user), or unexplained — a finding for which it offers a new task or reopening a deferred or removed decision; in feature context it SHALL report an approved decision absent from the diff as an incomplete feature, and when the user rejects the regeneration it SHALL write nothing.

#### Scenario: Unexplained change

- **Given** a regen diff in which a timeout changed from 30 to 10 seconds and no decision covers it
- **When** the diff is reviewed
- **Then** the change is recorded as a finding and a new task is offered

#### Scenario: Expected change missing

- **Given** a feature-scoped regen where approved decision D3 should change the export format
- **When** the diff shows no such change
- **Then** the feature is reported back as not done

#### Scenario: Rejected regen

- **Given** a reviewed diff the user rejects
- **When** the review ends
- **Then** the new body is discarded and the spec file is left as it was

### Requirement: Accepted specs are written with a provenance stamp

The system SHALL write each accepted area's spec with frontmatter naming the area, `generated-at` as the HEAD commit at harvest time (omitted in a non-git project), `generated-on` as today's date, the resolved `sources`, `shaped-by`, `shaped-by-derived`, `shaped-by-unresolved`, and `source-commits` where applicable; `generated-at` SHALL be treated as a floor and never re-stamped after the spec is committed.

#### Scenario: Dirty working tree

- **Given** uncommitted source edits when the harvest runs at commit `a1b2c3d`
- **When** the spec is written
- **Then** `generated-at` is `a1b2c3d`, the dirty tree is noted in the confirmation, and no re-stamp follows the later commit

### Requirement: External source repositories get their own baseline

The system SHALL, for every source glob resolving outside the project's repository, find that repository's root as the nearest ancestor containing `.git` and record its HEAD under `source-commits` keyed by the path prefix as written in `sources`; it SHALL omit the key when every source is in-repo, and write no entry for a sibling whose HEAD cannot be read, saying so in the confirmation.

#### Scenario: Aggregator area spanning a sibling

- **Given** an area with a source glob `../shared-lib/**/*.go` whose repository HEAD is `9f8e7d6`
- **When** the spec is stamped
- **Then** `source-commits` contains `../shared-lib: 9f8e7d6`

#### Scenario: Sibling not checked out

- **Given** an area globbing `../missing-lib/**` where that directory is absent
- **When** the spec is stamped
- **Then** no `source-commits` entry is written for it and the confirmation says so

### Requirement: Shaped-by is derived from authorship evidence on every regen

The system SHALL, on every regen, compute `shaped-by` as the union of the existing list, any feature resolved from `--story` or `--feature`, and every feature whose tasks' evidenced changed files intersect the area's resolved sources, building the task-to-files map once per invocation; evidence SHALL be resolved from a recorded PR number via the PR's file list, from a recorded commit via its first-parent changed files, or, when no reference is recorded, from commits whose subject's first task id is that task, matched with word boundaries; and it SHALL never infer provenance from names, folders or dates.

#### Scenario: Flagless full regen still derives

- **Given** `regen --all` with no story or feature flag and a task linked to FEATURE-007 whose commit touched a file in area `alpha-sync`
- **When** provenance is derived
- **Then** FEATURE-007 is added to `alpha-sync`'s `shaped-by`

#### Scenario: Mention in a body is not authorship

- **Given** a task TASK-031 with no recorded reference, and the only commit naming it reads `TASK-030: fix parser` with TASK-031 in its body
- **When** evidence is resolved
- **Then** TASK-031 contributes no evidence

#### Scenario: Leading id after a prefix

- **Given** a commit subject `fix(sync): TASK-031 — retry once, see TASK-029`
- **When** evidence is resolved
- **Then** the commit is attributed to TASK-031 and not to TASK-029

#### Scenario: Merge commit reference

- **Given** a task whose recorded reference is a no-fast-forward merge commit touching seven files
- **When** its files are resolved
- **Then** the seven files are found by reading the merge against its first parent

### Requirement: Only landed work counts as evidence

The system SHALL accept a commit or PR as evidence only if it is reachable from the harvested commit, treating an unmerged PR as no evidence; for evidence inferred from commit subjects it SHALL additionally reject tasks whose state says the work never landed (today `todo` and `cancelled`), read from the frontmatter `status:` field with an anchored match and any trailing comment stripped, accept both current and older status forms, and count a missing or unreadable status as unresolved; a recorded reference that landed SHALL outrank a contradicting state, which is reported rather than discarded.

#### Scenario: Open pull request

- **Given** a task in `review` whose recorded PR has not merged
- **When** evidence is resolved
- **Then** the task contributes no evidence

#### Scenario: Cancelled task leading a subject

- **Given** a cancelled task with no recorded reference whose id leads a commit subject in history
- **When** evidence is resolved
- **Then** the task contributes nothing, is counted unresolved, and is reported as a trail contradiction

#### Scenario: Status line with a trailing comment

- **Given** a task whose frontmatter reads `status: done  # merged abc123` beneath a comment listing every legal status
- **When** its state is read
- **Then** the state is `done`, not the first value listed in the comment

#### Scenario: Blocked work in progress

- **Given** a task `in-progress` with a `blocked:` field and a reachable commit leading its subject
- **When** evidence is resolved
- **Then** the task's files count as evidence

### Requirement: Shaped-by is append-only

The system SHALL never drop a feature already recorded in `shaped-by` during a routine regen, even when a stricter evidence rule would no longer attribute it.

#### Scenario: Previously recorded feature without current evidence

- **Given** a spec whose `shaped-by` lists FEATURE-003 and no task of FEATURE-003 now yields evidence for the area
- **When** the area is regenerated
- **Then** FEATURE-003 remains in `shaped-by`

### Requirement: Derivation and its completeness are stamped

The system SHALL write `shaped-by-derived: true` when the evidence pass ran and `false` when it could not (no task tree or no history), treat a missing key as `false`, and write `shaped-by-unresolved` as the number of feature-linked tasks that contributed no evidence under the evidence rules, omitting it only when derivation did not run; both values, and the number of tasks rejected by the state gate while leading a commit subject, SHALL be reported in regen's confirmation.

#### Scenario: Thin trail

- **Given** forty feature-linked tasks of which thirty-four leave no evidence
- **When** an area is stamped
- **Then** it carries `shaped-by-derived: true` and `shaped-by-unresolved: 34`, and the confirmation shows both

#### Scenario: No task tree

- **Given** a project with no task tree
- **When** an area is stamped
- **Then** it carries `shaped-by-derived: false` and no `shaped-by-unresolved`

### Requirement: Regen reports unmapped files under every tree the map reaches

The system SHALL, after writing, find files under the roots that the map's own source globs reach (not only the project root) that match no area and no ignore entry, list them with suggested map additions without editing the map, report the count in the confirmation even when it is zero, and end by suggesting the spec changes be committed with the related work without committing them.

#### Scenario: New sibling file in a mapped project

- **Given** an area listing `../shared-lib/conn/base.go` and a later-added `../shared-lib/conn/pool.go` matched by no glob
- **When** the unmapped check runs
- **Then** `pool.go` is reported as unmapped and a map addition is suggested

#### Scenario: Nothing unmapped

- **Given** every reachable file is matched by an area or ignore entry
- **When** the confirmation is printed
- **Then** it states an unmapped count of zero

### Requirement: Staleness anchors on the later of stamp and spec commit

The system SHALL, in `verify`, anchor each spec on the later by committer date of `generated-at` and the spec file's own last commit, considering the spec commit only when `generated-at` is its ancestor; it SHALL report the spec stale with a changed-file count when any in-repo source glob changed between that anchor and HEAD, stale with an unknown baseline when neither commit resolves, and never generated when the spec file is missing or its frontmatter unparseable.

#### Scenario: Spec committed with its sources

- **Given** a spec stamped at `c0` and committed together with its changed source at `c1`, with no later source change
- **When** verify runs
- **Then** the spec is fresh

#### Scenario: Regenerated but not committed

- **Given** a spec on disk stamped at a commit later than the spec's last commit
- **When** verify runs
- **Then** the anchor is the stamp

#### Scenario: Unrelated history

- **Given** a stamp that is not an ancestor of the spec's last commit
- **When** verify resolves the anchor
- **Then** it uses the stamp

#### Scenario: Neither resolves

- **Given** a spec whose stamp and own commit both fail to resolve
- **When** verify runs
- **Then** the spec is reported stale with an unknown baseline

#### Scenario: Non-git project

- **Given** a project without git
- **When** verify runs
- **Then** it compares source modification times against `generated-on` and says the result is best-effort

### Requirement: External sources are checked against their own baselines

The system SHALL check each external source glob against its own repository from the `source-commits` entry for its prefix, report a missing entry as unknown baseline for that repository without falling back to `generated-at`, report external staleness per repository, and add in-repo and external counts.

#### Scenario: Missing external baseline

- **Given** an area with an external glob under `../shared-lib` and no `source-commits` entry for it
- **When** verify runs
- **Then** the area is reported with an unknown baseline naming `../shared-lib`

#### Scenario: Changes in two siblings

- **Given** three changed files in `../lib-a` and one in `../lib-b` since their recorded commits
- **When** verify reports
- **Then** the counts are shown separately per repository

### Requirement: Verify renders a read-only summary

The system SHALL, in `verify`, never write any file, also count files matching no area and no ignore entry, and render counts of fresh, stale, unknown-baseline, never-generated and unmapped with zero-count lines suppressed, collapsing to a single all-fresh line when everything is fresh and nothing is unmapped; when no map file exists it SHALL print `No docs/specs/.map.yml — run /specs init to bootstrap.` and exit.

#### Scenario: Everything fresh

- **Given** five areas, all fresh, and no unmapped files
- **When** verify runs
- **Then** one line reports five areas, all fresh

#### Scenario: Mixed state

- **Given** one stale area with two changed sources and one area never generated
- **When** verify runs
- **Then** the stale and never-generated lines are shown with their areas, and the zero-count lines are omitted

### Requirement: Show prints one spec with honest provenance and freshness

The system SHALL, in `show`, resolve the area by exact name then by unambiguous prefix or substring (listing the areas and stopping when ambiguous or unknown), print the spec body under a one-line header of area, generation date and `shaped-by`, render provenance as `shaped-by: (never derived)` when `shaped-by-derived` is false or absent, append the number of tasks that left no evidence when it is non-zero, append a one-line freshness footer from the staleness check, and say so with a regen suggestion when the area has no spec file.

#### Scenario: Never-derived provenance

- **Given** a spec with `shaped-by: []` and no `shaped-by-derived` key
- **When** it is shown
- **Then** the header reads `shaped-by: (never derived)` and a regen is suggested

#### Scenario: Partial derivation

- **Given** a spec with `shaped-by-derived: true` and `shaped-by-unresolved: 5`
- **When** it is shown
- **Then** the provenance is followed by "(5 tasks left no evidence)"

#### Scenario: Ambiguous prefix

- **Given** areas `report-daily` and `report-weekly`
- **When** the user shows `report`
- **Then** the map's areas are listed and nothing is printed
