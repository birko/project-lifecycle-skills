---
area: project-roadmap
generated-at: 1cdf452fbb2594ffe3016cf359b041815fdd8957
generated-on: 2026-10-03
sources:
  - skills/roadmap/SKILL.md
shaped-by: [FEATURE-003]
shaped-by-derived: true
shaped-by-unresolved: 7
---

# One place to see every feature and every task in your project, and where the two have drifted

## Purpose

A project plans its work in two trees: a developer-facing task tree (epics, stories, tasks) and a stakeholder-facing feature tree (ideas, decisions, phases). The roadmap joins the two by epic into one read-only view and audits where they have drifted apart — a feature still reading `idea` while its tasks shipped, a task that lost its link to its feature, a finding that was filed but never scheduled, a spec that no longer matches the code. It also owns the shared collection-and-divergence engine that the task snapshot and the feature listing delegate to, so the join and the drift rules exist in exactly one place.

## Requirements

### Requirement: Invocation modes

The system SHALL accept `/roadmap` with no arguments as a full render (every epic with its features and their sync state, then the divergence audit), `--check` as the divergence audit alone, `EPIC-NNN` as a render scoped to that one epic, and `--fix` as the audit followed by proposed reconciliation edits that are never applied.

#### Scenario: Bare invocation renders everything

- **Given** a project with a task tree and a feature tree
- **When** the user runs `/roadmap`
- **Then** every epic is rendered with its features and per-feature sync state, followed by the divergence audit

#### Scenario: Check-only answer

- **Given** a project with both trees
- **When** the user runs `/roadmap --check`
- **Then** only the divergence audit is printed and the epic tree is skipped

#### Scenario: Scoped to one epic

- **Given** a project with epics EPIC-004 and EPIC-009
- **When** the user runs `/roadmap EPIC-009`
- **Then** the render covers EPIC-009 only

#### Scenario: Fix proposes and applies nothing

- **Given** an audit that finds FEATURE-042 with DV4
- **When** the user runs `/roadmap --fix`
- **Then** a "Proposed reconciliation" block lists the concrete edits, no file is changed, and the edits are handed off to the task and feature skills to action

### Requirement: Nothing to show

The system SHALL print exactly `No tasks/ or docs/features/ in this project.` and stop when the project has neither a task tree nor a feature tree.

#### Scenario: Empty project

- **Given** a project with neither tree
- **When** the user runs `/roadmap`
- **Then** the single line `No tasks/ or docs/features/ in this project.` is printed and nothing else happens

### Requirement: Across a polyrepo

The system SHALL, under `--across`, render every sibling project by passing the flag through to the task skill's collection pass (which owns the sibling root, the one-level bound and the `<repo>/TASK-NNN` qualification), SHALL count a sibling as participating when it has a task tree **or** a feature tree, and SHALL join each sibling's features only to that same sibling's tasks, never across two repositories.

#### Scenario: Features-only sibling still appears

- **Given** sibling projects `alpha` with both trees and `beta` with a feature tree and no task tree
- **When** the user runs `/roadmap --across`
- **Then** both `alpha` and `beta` are rendered

#### Scenario: No cross-repo pairing

- **Given** `alpha` has FEATURE-007 and `beta` has a task carrying `feature: FEATURE-007`
- **When** the user runs `/roadmap --across`
- **Then** the task in `beta` is not joined to the feature in `alpha` and no divergence is raised from pairing them

### Requirement: Fix is refused across repositories

The system SHALL refuse `--fix` when it is combined with `--across`, because the proposals are edits and across-mode is read-only.

#### Scenario: Both flags passed

- **Given** a polyrepo with sibling projects
- **When** the user runs `/roadmap --across --fix`
- **Then** the run is refused, naming the read-only nature of across-mode as the reason

### Requirement: One engine for every renderer

The system SHALL own the cross-tree pass — collection, join and divergence rules — and SHALL expose its result as one output model (tasks collection; per-feature id, title, epic, coarse status, phase, decision counts by state, tasks done and total, back-link health and divergence ids; per-area spec freshness and provenance, or none; and a flat list of divergences with id, target, rule and detail) that every renderer consumes without re-deriving it.

#### Scenario: Task snapshot delegates

- **Given** the task skill renders its bare snapshot
- **When** it needs the feature-side picture
- **Then** it consumes this engine's output model rather than computing its own join or drift rules

#### Scenario: Feature listing delegates

- **Given** a user runs the bare feature listing
- **When** the listing collects feature state
- **Then** the collection comes from this engine

### Requirement: Collect tasks reading both status forms

The system SHALL collect tasks through the task skill's collection pass (counts, buckets, children by parent, and each task's parent, status, findings and feature link, plus each epic's optional kind), and SHALL read every task's status in both forms: `verify` is read as `review`, and a task with a `blocked:` field is judged by the state its `status:` names. A blocked flag alone SHALL never be a divergence.

#### Scenario: Verify read as review

- **Given** TASK-031 has `status: verify`
- **When** the cross-tree pass evaluates it
- **Then** every rule treats TASK-031 as `review`

#### Scenario: Blocked task keeps its state

- **Given** TASK-032 has `status: in-progress` and a `blocked:` field
- **When** the divergence rules run
- **Then** TASK-032 counts as `in-progress` and no finding is raised because of the block

### Requirement: Checklist lines counted only where needed

The system SHALL count unticked `- [ ]` lines in a story body only for stories under an epic whose `kind:` is `review-intake`, and SHALL not scan task or story bodies anywhere else.

#### Scenario: Review-intake story scanned

- **Given** STORY-020 sits under an epic with `kind: review-intake` and its body has three unticked lines
- **When** tasks are collected
- **Then** STORY-020 is recorded with three unticked lines

#### Scenario: Ordinary story not scanned

- **Given** STORY-021 sits under an epic with no `kind:` and its body has unticked lines
- **When** tasks are collected
- **Then** its body is not scanned for checklist lines

### Requirement: Collect features

The system SHALL, for every feature folder, read the coarse `status:` from the idea file's frontmatter (one of `idea | review | done | dropped | superseded`) and its heading title, count decision rows by state (`proposed | approved | changed | deferred | removed`), read the derived phase from the status file (one of `idea | prototyping | deciding | building | review | done`, or the terminal mirrors `dropped | superseded`), and read the recorded prototype line (Built / Skipped / N/A / Pending); it SHALL also read the feature index, when present, for each feature's source epic.

#### Scenario: Feature fully read

- **Given** FEATURE-014 with `status: review`, two `approved` and one `proposed` decision, phase `building` and prototype `Skipped`
- **When** features are collected
- **Then** FEATURE-014 is recorded with coarse status `review`, decisions approved 2 and proposed 1, phase `building`, and prototype `Skipped`

### Requirement: Collect specs only from a real map

The system SHALL collect spec areas only when the spec map exists with a non-empty `areas:` list, reading each area spec's area, baseline commit, sources, external source baselines (absent means none), provenance list, provenance-derived flag (absent means `false`) and unresolved count (absent means unknown), and SHALL compute staleness exactly as the specs skill's verify verb defines it — including resolving external sources against their own repository's baseline and treating an unknown commit, a missing spec file, or an external source with no baseline as stale rather than fresh. An absent map or an empty `areas: []` SHALL never be collected as a working spec layer with zero areas.

#### Scenario: Empty scaffold map is not a spec layer

- **Given** the spec map contains `areas: []`
- **When** the cross-tree pass runs
- **Then** no specs are collected and the spec section of the output model is empty rather than "zero areas, all fresh"

#### Scenario: External source with no baseline

- **Given** area `billing` lists a source in a sibling repository and has no external baseline for it
- **When** staleness is computed
- **Then** `billing` is reported stale with an unknown baseline, never fresh

### Requirement: Join features to tasks and epics

The system SHALL join a feature to the tasks carrying `feature: FEATURE-NNN` and compute tasks done over tasks total; when a feature has no back-linked tasks it SHALL fall back to matching the feature's slug against story and epic slugs; and it SHALL map each feature to its owning epic through its tasks' parent chain, else through the feature index's source epic.

#### Scenario: Primary join by back-link

- **Given** TASK-101 and TASK-102 carry `feature: FEATURE-020` and TASK-101 is `done`
- **When** the join runs
- **Then** FEATURE-020 shows 1 of 2 tasks done

#### Scenario: Slug fallback

- **Given** FEATURE-023-export-csv has no back-linked tasks and STORY-040-export-csv exists
- **When** the join runs
- **Then** FEATURE-023 is paired with STORY-040

#### Scenario: Epic from the index

- **Given** FEATURE-025 has no linked tasks and the feature index lists its source as EPIC-006
- **When** the epic mapping runs
- **Then** FEATURE-025 is placed under EPIC-006

### Requirement: DV1 — feature frozen while work moved

The system SHALL flag DV1 when a feature's phase is `idea` or all its decisions are `proposed`, yet at least one linked task is `in-progress` or `done`.

#### Scenario: Idea with shipped work

- **Given** FEATURE-030 is in phase `idea` and its task TASK-210 is `done`
- **When** the audit runs
- **Then** FEATURE-030 is flagged DV1

### Requirement: DV2 — shipped work never closed on the feature side

The system SHALL flag DV2 when at least one task is linked, every linked task is `done`, the feature's coarse status is not `done`, and its phase is neither `done` nor `review`.

#### Scenario: All done, feature still building

- **Given** FEATURE-031's two tasks are `done`, its coarse status is `idea` and its phase is `building`
- **When** the audit runs
- **Then** FEATURE-031 is flagged DV2

#### Scenario: Awaiting review is not drift

- **Given** FEATURE-032's tasks are all `done` and its phase is `review`
- **When** the audit runs
- **Then** DV2 is not raised for FEATURE-032

### Requirement: DV3 — broken back-link, only where work exists

The system SHALL flag DV3 when a task under a story or epic that slug-matches a feature has no `feature:` link, and SHALL not flag a fallback-only pairing whose matched story or epic has zero tasks, since that is the healthy state before decomposition.

#### Scenario: Matched story with unlinked tasks

- **Given** FEATURE-033-search slug-matches STORY-050-search, which holds TASK-300 with no `feature:` field
- **When** the audit runs
- **Then** DV3 is raised for the missing back-link

#### Scenario: Stub pairing before decomposition

- **Given** FEATURE-034-alerts is an `idea` stub and STORY-051-alerts is a `planned` story with no tasks
- **When** the audit runs
- **Then** no DV3 is raised

### Requirement: DV4 — tasks without an approving decision

The system SHALL flag DV4 when a feature has linked tasks but every one of its decisions is still `proposed`.

#### Scenario: Decomposed before deciding

- **Given** FEATURE-035 has decisions D1 and D2 both `proposed` and one linked task
- **When** the audit runs
- **Then** FEATURE-035 is flagged DV4

### Requirement: DV5 — tracked in one tree only

The system SHALL flag DV5 for a feature with no matching epic, story or tasks unless it is a shipped `done` backfill, and for a story or epic that has tasks but no feature folder.

#### Scenario: Orphan feature

- **Given** FEATURE-036 is in phase `deciding` and nothing in the task tree matches it
- **When** the audit runs
- **Then** FEATURE-036 is flagged DV5

#### Scenario: Orphan story

- **Given** STORY-060 has three tasks and no feature corresponds to it
- **When** the audit runs
- **Then** STORY-060 is flagged DV5

#### Scenario: Done backfill exempt

- **Given** FEATURE-037 is a shipped `done` backfill with no tasks
- **When** the audit runs
- **Then** DV5 is not raised for FEATURE-037

### Requirement: DV6 — invalid lifecycle marker

The system SHALL flag DV6 when a feature's coarse status is outside `idea | review | done | dropped | superseded`, or its phase is outside the derived set and its terminal mirrors.

#### Scenario: Unknown phase value

- **Given** FEATURE-038's phase line reads `in-progress`
- **When** the audit runs
- **Then** FEATURE-038 is flagged DV6

### Requirement: DV7 — stale spec, naming the repository that drifted

The system SHALL flag DV7 when a spec area's sources changed since its baseline (the area's own commit for in-repo sources, the matching external baseline for each sibling repository), when a mapped area was never generated, or when an external source has no baseline; each finding SHALL name which repository drifted and SHALL report a missing external baseline as unknown rather than fresh.

#### Scenario: Sibling repository moved

- **Given** area `ledger` has sources in this repo and in sibling `gamma`, and only `gamma` changed since its baseline
- **When** the audit runs
- **Then** DV7 is raised for `ledger` naming `gamma` as the repository that drifted

#### Scenario: Never generated

- **Given** area `reports` is listed in the map and has no spec file
- **When** the audit runs
- **Then** `reports` is flagged DV7

### Requirement: DV8 and DV11 — specs that never learned about shipped features

The system SHALL flag DV11 for every spec area whose provenance-derived flag is `false` or absent, and SHALL flag DV8 (advisory) when a spec map exists and a feature with coarse status `done` and at least one linked task appears in no spec's provenance list — except when the feature's decision history carries a `no spec surface` line, and never against areas flagged DV11. A DV8 finding SHALL report the area's unresolved count whenever it is non-zero and SHALL point at `/specs regen --feature FEATURE-NNN`.

#### Scenario: Provenance never computed

- **Given** area `auth` has `shaped-by: []` and no provenance-derived flag
- **When** the audit runs
- **Then** `auth` is flagged DV11 and no DV8 is raised against `auth`

#### Scenario: Shipped feature missing from specs

- **Given** FEATURE-040 is `done` with two linked tasks, every area has derived provenance, and no area lists FEATURE-040
- **When** the audit runs
- **Then** DV8 is raised for FEATURE-040 with the fix `/specs regen --feature FEATURE-040`

#### Scenario: Docs-only carve-out

- **Given** FEATURE-041 is `done` and its decision history contains a `no spec surface` line
- **When** the audit runs
- **Then** DV8 is not raised for FEATURE-041

#### Scenario: Weak evidence disclosed

- **Given** DV8 fires for FEATURE-042 and the relevant area reports 9 unresolved tasks
- **When** the finding is printed
- **Then** the unresolved count 9 is shown alongside it

### Requirement: DV9 — ledger does not know its own task

The system SHALL flag DV9 when a task carries `feature: FEATURE-NNN` but no decision row in that feature's ledger lists the task in its tasks column, including a task that inherited its link from a parent.

#### Scenario: Inherited link not backfilled

- **Given** TASK-400 inherited `feature: FEATURE-043` from its story and no decision row lists TASK-400
- **When** the audit runs
- **Then** DV9 is raised for TASK-400

### Requirement: DV10 — the spec layer is silently absent

The system SHALL flag DV10 (advisory, fix `/specs init`) when the repository has behaviour to specify but there is no spec map, or the map's `areas:` list is empty, unless the map declares `coverage: not-applicable`, which ends the check before anything else is evaluated.

#### Scenario: Empty map in a repo with code

- **Given** the spec map holds `areas: []` and no coverage declaration, and the repository has behavioural code
- **When** the audit runs
- **Then** DV10 is raised with the fix `/specs init`

#### Scenario: Declared not applicable

- **Given** the spec map holds `areas: []` and `coverage: not-applicable`
- **When** the audit runs
- **Then** DV10 is not raised

### Requirement: DV10 — what counts as code

The system SHALL decide whether a repository has behaviour to specify by asking, in order and stopping at the first that answers: the spec map's own `ignore:` list (tracked files it does not exclude); what the repository's own gate runs over (a CI workflow or task-runner target's inputs); a source tree or a build manifest. When none answers, it SHALL stay silent and say the check could not decide, never raising a finding.

#### Scenario: Markdown project answered by its gate

- **Given** a repository with no source tree and no build manifest, whose CI workflow lints the markdown under one folder, and no spec map
- **When** the audit runs
- **Then** DV10 is raised, because the gate declares that folder as source

#### Scenario: Conventional project

- **Given** no spec map, no CI workflow, and a build manifest with tracked source files
- **When** the audit runs
- **Then** DV10 is raised on the strength of the manifest

#### Scenario: Undetermined repository

- **Given** a notes repository with no spec map, no gate, no source tree and no manifest
- **When** the audit runs
- **Then** no DV10 finding is raised and the output says the check could not decide

### Requirement: DV12 — findings filed but never scheduled

The system SHALL flag DV12 when a story under an epic with `kind: review-intake` has unticked checklist lines in its body and no open task — all its children `done` or `cancelled`, or no children at all — and SHALL point at `/tasks intake --epic` or `/tasks new` as the fix.

#### Scenario: Drained-looking story with leftovers

- **Given** STORY-070 under a review-intake epic has two unticked lines and its only task is `done`
- **When** the audit runs
- **Then** STORY-070 is flagged DV12

#### Scenario: Work still open

- **Given** STORY-071 under a review-intake epic has unticked lines and one `todo` task
- **When** the audit runs
- **Then** DV12 is not raised

### Requirement: Full render with verification debt first

The system SHALL render the full view by listing features in phase `review` first as outstanding verification debt; then grouping by epic, newest-active first, with fully `done`/`cancelled` epics collapsed into a tail, each feature on one line with its phase, tasks done over total and a sync mark (`✓ synced`, or `⚠ DV<n> <short reason>`); then a divergence audit with one line per finding naming the rule and its concrete fix path, or `Divergences: none — the two trees agree.`; then the DV5 items under a "Tracked in one tree only" heading.

#### Scenario: Review-phase feature leads

- **Given** FEATURE-050 is in phase `review` and FEATURE-051 is in phase `building`
- **When** the user runs `/roadmap`
- **Then** FEATURE-050 is listed as verification debt before any other feature

#### Scenario: Clean audit

- **Given** no rule fires
- **When** the full render finishes
- **Then** the audit reads `Divergences: none — the two trees agree.`

#### Scenario: Finding with fix path

- **Given** FEATURE-052 is flagged DV4
- **When** the audit is printed
- **Then** its line names DV4 and the fix `/feature decide FEATURE-052`

### Requirement: Compact slice for the task snapshot

The system SHALL, when called for the task skill's bare snapshot, render only a feature count with one bucket per phase (zero-count buckets omitted, `dropped` and `superseded` appended when non-zero, so the buckets sum to the total and the `review` count leads), a divergence line listing each finding or `✓ in sync`, a stale-spec count omitted when there are no specs or none are stale, and a pointer to `/roadmap` for the full view.

#### Scenario: Snapshot with drift

- **Given** five features — one `review`, two `building`, two `done` — and FEATURE-060 flagged DV2
- **When** the task snapshot renders the slice
- **Then** it shows 5 features with buckets for review, building and done only, a divergence line naming FEATURE-060 DV2, and the pointer to `/roadmap`

#### Scenario: In sync, specs fresh

- **Given** no divergences and every spec area fresh
- **When** the slice renders
- **Then** the divergence line reads `✓ in sync` and the specs line is omitted

### Requirement: Read-only and stdout-only

The system SHALL write no file in any mode — the roadmap is printed on demand, never saved as a roadmap document — leaving any hand-maintained roadmap document untouched and leaving the persistent drift signal to the task dashboard.

#### Scenario: Hand-maintained roadmap untouched

- **Given** the project has a hand-maintained roadmap document
- **When** the user runs `/roadmap --fix`
- **Then** the output appears on screen only and no file, including that document, is changed
