---
id: TASK-025
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# DV10's "real code" test cannot see a repo whose code is prose

## Context

Found running `/roadmap` on this repo for TASK-002's drill (2026-08-18).

DV10 exists so the spec layer cannot go silently missing: *"the project has real code (a `src/` tree
or build manifest with tracked sources) but no `docs/specs/.map.yml` — **or the map's `areas:` list is
empty** … every spec check skips when the map is missing/empty, so nothing else will ever surface
this."*

This repo is exactly the situation DV10 is for. `docs/specs/.map.yml` exists with `areas: []`, seeded
empty and never filled; STORY-008 exists to harvest the specs and has not been started; sixteen
skills' worth of behaviour is unspecified. And DV10 **does not fire**, because the repo has no `src/`
tree and no build manifest — its source is `skills/**/*.md`. The rule's own escape hatch reads
"tracked sources", but the two detectors offered for it are both artifacts of compiled/packaged
projects.

So the check that exists to catch a silently-absent spec layer is itself silently absent, on the repo
that ships it. Worth fixing rather than noting, because the failure is invisible by construction: a
project of this shape gets a clean `/roadmap` forever, and `docs/specs/` stays a scaffold nobody is
reminded about.

The same blind spot hits any docs-first or config-first repo — a documentation site, a Terraform
module collection, a prompt library, an ADR archive.

## Acceptance criteria

- [ ] DV10's code-detection test recognises a repo whose tracked source is neither a `src/` tree nor a build manifest. What counts as "real code" is the judgement to make explicitly — a candidate is *tracked files that the spec map's own `ignore:` list does not exclude*, which for this repo is `skills/**` and nothing else
- [ ] The rule reads off the map's `ignore:` list rather than a second hard-coded notion of source, so a project that already told the spec layer what its source is does not have to tell `roadmap` again
- [ ] DV10 fires on **this** repo until `areas:` is filled, and stops firing once STORY-008 lands
- [ ] It does **not** fire on a genuinely source-free repo — a notes vault, a fresh scaffold with nothing but the layer — where the absent spec map is correct rather than a gap
- [ ] Whatever the test becomes, it lives in [[roadmap]]'s Cross-tree pass, which owns the divergence rules; [[tasks]] and [[feature]] render slices and must not carry a second copy
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Filling `areas:` for this repo — that is STORY-008, and this task only makes the reminder work.
- The other divergence rules' heuristics; DV5's "one tree only" behaviour on this repo is correct and reported as by-design.
- `/specs init`'s own area-discovery for prose repos. If it turns out `specs` cannot map a markdown skill library either, that is a second finding and gets its own task.

## Human test plan

- [ ] Run `/roadmap` on this repo and confirm DV10 fires with a pointer to `/specs init`
- [ ] Fill `areas:` in a throwaway copy and confirm DV10 goes quiet
- [ ] Run it on a notes-only fixture (markdown, no skills, no manifest) and confirm DV10 stays silent — the false positive is the failure mode that would make the rule ignorable
- [ ] Run it on a normal `src/`-tree project and confirm the existing behaviour is unchanged

## Implementation plan

_Populated by `/tasks plan TASK-025` — leave empty until then._
