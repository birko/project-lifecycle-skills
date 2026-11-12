---
id: TASK-274
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-98, SH-99, SH-101, SH-102]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `roll-changelog`: a dangling skeleton link, two definitions of its boundary, an undeclared flag, and an empty release

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-98:** `skills/roll-changelog/SKILL.md:20` links `[Keep a Changelog](#file-shape)`; no "File shape" section exists. `new-project/SKILL.md:112` and `LAYER.md:29` only say "a stub", and no template defines the skeleton, so the three seeders can write different stubs.
- **SH-99:** `:16` says gather work "since the last recorded entry"; `:42` says "since the most recent release tag/date". `:48`'s "don't clobber" is not a de-duplication rule, so a second roll before a release re-gathers work already rolled. This repo is in that state now.
- **SH-101:** `--date` is used at `:61` and `:71`, but the args list (`:14-18`) does not declare it.
- **SH-102:** cutting a release from an empty `## [Unreleased]` has no defined outcome (`:59-64`), and version inference (`:52-55`) has no case for empty buckets.

Related to TASK-024 (reconciling an older CHANGELOG's shape), not a duplicate of it.

## Acceptance criteria

- [x] The changelog skeleton is defined once (a section or a template) and every seeder points at it; the `#file-shape` anchor resolves
- [x] One boundary rule: a roll gathers only work not already in `## [Unreleased]`, stated so a second roll adds nothing it already holds
- [x] `--date` is declared in the args list
- [x] Cutting a release from an empty Unreleased has a stated outcome (refuse and report, for example)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ask-steps (TASK-273), and the shadowing claim (TASK-237)

## Human test plan

- [x] Roll twice in a scratch repo with no new commits between, and confirm the second roll adds nothing
  - **Passed 2026-11-12:** fixture `%LOCALAPPDATA%/Temp/d274`, with `skill/roll-changelog` copied from this fix. `rolled/` is a git repo whose `CHANGELOG.md` has `## [0.1.0] - 2026-11-01` and an `## [Unreleased]` already holding "Export the report as a CSV file." from the first roll. Its commits are the release, "Add a CSV export of the report", and "changelog: roll unreleased", with nothing new after. `empty/` has an empty `## [Unreleased]`. The brief (`brief.txt` there) ran `/roll-changelog` on `rolled/` and `/roll-changelog release 0.2.0 --date 2026-11-12` on `empty/`, and withheld both expected outcomes. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, cwd the fixture root. **Result:** the second roll added nothing, quoting "then drop every item `## [Unreleased]` already describes" for the CSV commit. The empty release printed `release not cut: [Unreleased] is empty — nothing to release`. Both files unchanged, both repos clean. Coldness: no skills listed. **It found two gaps in the new rule, fixed before close:** a roll that adds nothing had no stated output, and "since its date" was ambiguous for a release commit made on that date (a bare `--since` date takes the current time of day). The boundary is now a commit (the tag, else the commit that wrote the release section), and the no-op roll prints `nothing rolled: everything since <the boundary> is already in [Unreleased]`

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Triggers: three files, five criteria.

1. **SH-98** — a `## File shape` section in `roll-changelog`, the row's owner per LAYER.md, holds the skeleton.
   `new-project/SKILL.md` and LAYER.md's `CHANGELOG.md` row point at it, and the `#file-shape` anchor resolves.
2. **SH-99** — one boundary rule in § *Roll* step 1: the work after the most recent release section, less what
   `## [Unreleased]` already describes; a doubtful item is left out and reported. The Verbs line and step 5 defer to it.
3. **SH-101** — declare `--date YYYY-MM-DD` in the args list.
4. **SH-102** — an empty `## [Unreleased]` is never cut (§ *Cut a release* step 1), and version inference says so.
5. Respec `changelog-maintenance`.

## Outcome

**The fix.** `roll-changelog` had four gaps:
- **Skeleton:** linked a `#file-shape` section it did not have, so three seeders could write three different
  skeletons. The skeleton is now defined once there, and the seeders point at it.
- **Boundary:** stated its boundary two ways, so a second roll re-gathered work already rolled. One rule now gathers the
  work after the last release, less what `## [Unreleased]` already describes. The boundary is a commit, never a date.
- **`--date`:** used `--date` without declaring it. It is declared now.
- **Empty release:** had no outcome for cutting a release from an empty Unreleased. It now refuses and reports.

**Step 6 split.** 4 of 4 assertions failed on HEAD's copy and pass on the fix, all fix-dependent: the skeleton section,
the single boundary rule, the declared flag, and the empty-release outcome. Contract pin, **not evidence**: skills-lint
passes on both. The no-op line and the commit boundary were added after the split, from the drill, whose readings are
their evidence.

**Judgement calls.**
- **The skeleton lives in `roll-changelog`, not a new template file.** LAYER.md already names `roll-changelog` as the
  row's owner, and AGENTS.md § *A vocabulary shared by several skills has one owning file* says expand the existing
  owner. A section also made the dangling `#file-shape` anchor resolve, with no new file for the lint to check.
- **The skeleton claims no versioning scheme.** The usual Keep a Changelog header promises Semantic Versioning. Seeding
  it would state a policy nobody chose, which AGENTS.md § *A template ships nothing a render cannot make true* forbids.
  The first release settles the scheme.
- **A doubtful duplicate is left out and reported, not written.** A duplicated bullet is published text stating a
  change twice. A missing one is recovered by the next roll. That is the same fail-safe direction as every other
  answer-less path in the skill.
- **The boundary became a commit after the drill.** The runner showed `git log --since=<date>` reads the current time
  of day into a bare date, so a same-day release commit is included or not depending on when the roll runs. The tag,
  or the commit that wrote the release section, has no such dependence.
- **Spec** `changelog-maintenance`: the seeding requirement (the skeleton's content), the boundary requirement
  (retitled, one rule, the commit boundary, the no-op line, and its "rolling twice" scenario, which recorded the
  ambiguity as unsettled), the merge requirement, and the cut requirement (`--date`, the empty refusal). Restamped.
  `shaped-by` unchanged: the one intervening commit (222c36d, TASK-273) is not feature-linked.
- **Close gate ran inline** on a ~50-line prose diff.
  - Standards: no finding.
  - Intent: all four content criteria met.
  - Correctness: the second source bullet's leftover "since the date" was aligned with the commit boundary.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Nothing.

## Progress log

- step 2 — picked; ranked above TASK-139 because SH-102 leaves a release cut from an empty `## [Unreleased]` with no defined outcome, a write to CHANGELOG.md whose result nobody stated (key 1), while TASK-139's tie leaves a "Next up" order unstable but writes nothing. Number 4 in the re-ranked order, after TASK-250, TASK-275 and TASK-065. Key 6 would favour TASK-139 (`correctness-invariants`), but key 1 separated them first
- step 3 — verified: held, all four. `#file-shape` links to no section; the Verbs line says "since the last recorded entry" while step 1 says "since the most recent release"; `--date` is used but not declared; § *Cut a release* has no empty case
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: three files, five criteria)
- step 4 — layer: local
- step 5 — fix in skills/roll-changelog/SKILL.md (§ File shape, the boundary rule as a commit, the no-op line, `--date`, the empty refusal), skills/new-project/SKILL.md and LAYER.md (point at § File shape)
- step 6 — reverted fix (HEAD's copy): 4/4 assertions failed; fix-dependent = all four; contract pins = skills-lint (passes on both); the two drill-found additions' evidence is the drill
- step 7 — respecced changelog-maintenance (surgical); requirements changed: seeding, boundary (and its rolling-twice scenario), merge, cut; intended — TASK-274's criteria plus the drill's two. shaped-by unchanged: intervening 222c36d (TASK-273) is feature: null
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
