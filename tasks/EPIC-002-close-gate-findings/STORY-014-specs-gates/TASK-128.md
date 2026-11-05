---
id: TASK-128
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: verify
priority: P2
assignee: agent
created: 2026-09-16
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-109-3, DRILL-033-2, DRILL-109-4]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# Step 4 offers two exits for an unmapped file and the paragraph below it defines a third

## Context

**From the cold drill run for TASK-109 on 2026-09-16** (B2 — `/specs init` against a three-file Python
fixture, runner confirmed cold). The runner hit a direct contradiction inside one step and reported which
way it went:

> *"Step 4's two remedies for an unmapped file omit the one I used. **'any source file matching neither an
> area nor `ignore` → list as unmapped and either extend an area or add one.'** Neither branch is 'add an
> `ignore` entry' — yet the classification paragraph four lines later defines exactly that exit (**'Into
> `ignore` — it was never project source'**), and step 6 expects **'any `ignore:` entries step 4's
> reconciliation added'**. The sentence and the paragraphs around it disagree; I followed the paragraphs."*

So one step states a two-way choice, the prose immediately below states a three-way one, and a *later* step
depends on the third way having been available. The runner resolved it correctly — but by choosing which of
two contradictory instructions to obey, which is not a thing a reader should have to do.

### Why this matters more than a wording slip

The third exit is the one that carries a **judgement**. `coverage-drift` is defined as the paths that were
real source all along, as opposed to housekeeping sent to `ignore` — so the `ignore` exit is precisely where
a file is classified as *not behaviour*. A reader who obeys the two-way sentence literally has nowhere to put
a non-source file except into an area, which would fold prose and build furniture into the behavioural map
and inflate every later `coverage-drift` reading.

In this drill the file in question was `README.md`, and the runner sent it to `ignore` with a recorded
reason — the right answer, reached against the instruction rather than because of it.

**Adjacent, same step, do not lose it:** the runner also flagged that step 4 asks it to state a close
classification call, and did so. That part worked and is evidence the surrounding design is sound; it is the
enumeration of exits that is wrong.

### Merged in 2026-09-26: TASK-088 — Nothing says whether one source file may belong to two capability areas

_Merged because all three are /specs init step 4 remedies and area-granularity rules for unmapped or oddly-sized sources. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-088.md`._

**Raised by both 2026-09-01 cold drills of `/specs init`**, independently.

Step 4's remedy for an unmapped file is *"extend an area or add one"* — singular, and the template's
examples never test the case. But the situation is real and already shipped in two consumer maps:

- **WorkoutTracker** does it deliberately and says so: `ProgressEndpoints.cs` appears under both
  `exercise-progress` and `training-activity`, with a comment explaining that one file hosts two read
  models. The same map now also shares `plans-segments.ts` between `plan-hierarchy` and
  `exercise-library` — one segment bar rendered by two surfaces.
- **Presenter**'s drill put `appsettings.json` in **three** areas, because its `Fetch.*`, `Session.*` and
  `Database.*` sections are consumed by three different capabilities.

Both drills flagged the same gap: the practice exists, it looks correct, and no rule sanctions it.

**What has to be decided, and it is not obvious.** Sharing is right when one file genuinely hosts several
capabilities, and wrong when it means the areas are drawn around files instead of behaviour. Consequences
travel downstream: `/specs regen` harvests each area from its `sources:`, so a shared file is read once
per area and can produce two specs asserting overlapping things; `verify`'s staleness check will mark
**every** sharing area stale on one edit; and `coverage-drift`'s list may name a path already present
elsewhere.

### Merged in 2026-09-26: TASK-129 — A project with fewer capabilities than the floor has no stated answer, so the guidance invites padding

_Merged because all three are /specs init step 4 remedies and area-granularity rules for unmapped or oddly-sized sources. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-129.md`._

**From the cold drill run for TASK-109 on 2026-09-16** (B2 — `/specs init` against a three-file Python
fixture with two genuine capabilities, runner confirmed cold):

> *"**Area count for a codebase too small to support the target.** 'Target granularity: **capability, not
> class** — ~5–20 areas.' This repo has two capabilities in two files. I wrote two and did not pad to five.
> The instructions never say what a project below the floor should do; the nearest counterweight is the edge
> case 'don't invent areas for a project with no observable behavior', which is about a different
> situation."*

The runner did the right thing. Nothing in the skill told it to, and the one nearby rule covers the
**zero**-capability case, not the *below-the-floor* case — so a reader who takes "~5-20" as a target rather
than a typical range has explicit permission to split by class until the count looks right.

#### Why the pull is toward the wrong answer

Splitting to hit a number is the easy move and it is invisible afterwards: five areas over two capabilities
reads as a well-decomposed map, not as padding, and every later consumer inherits the inflated shape.
`/specs regen` then generates five spec bodies where two belong, `/roadmap`'s DV7 reports staleness five
times for one behavioural change, and `shaped-by` provenance is spread across areas that were never real.
The failure is silent in the direction the range was meant to prevent — the whole point of *"capability, not
class"* is to stop exactly this, and the number sitting beside it undercuts it.

**The same sentence is fine at the top of the range**, which is why this is a one-sided fix: a project with
thirty capabilities genuinely should reconsider its granularity, and nothing here changes that.

## Acceptance criteria

- [x] Step 4's unmapped-file sentence enumerates **every** exit the step's own prose defines, including
      `ignore`, so no reader has to pick between two contradictory instructions
- [x] The fix names which side was wrong — the sentence or the paragraphs — rather than quietly editing both
      to meet in the middle
- [x] Step 6's expectation of *"any `ignore:` entries step 4's reconciliation added"* is reachable by
      following step 4 literally
- [x] The `coverage-drift` / `ignore` distinction stays exactly as documented — this task fixes which exits
      are listed, not what they mean
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-088:*

- [x] Whether a file may appear in more than one area's `sources:` is stated, with the test for when it should
- [x] The consequence for `regen` (one file harvested into several specs) is named, not left to be discovered
- [x] The consequence for `verify` (one edit marks several areas stale) is named
- [x] The existing deliberate instances are consistent with whatever is decided, or are called out as needing change — `ProgressEndpoints.cs`, `plans-segments.ts`, and Presenter's `appsettings.json` if that map is ever written
- [x] `bash .github/workflows/skills-lint.sh` passes

*From TASK-129:*

- [x] The granularity guidance states what a project **below** the range does, and says plainly that the
      range is descriptive of typical projects rather than a target to reach
- [x] A two-capability project is a legitimate, recorded outcome — not an edge case handled by silence, and
      not conflated with the existing zero-behaviour edge case, which stays as it is
- [x] The wording cannot be read as licence to split by class to reach a count; the *"capability, not
      class"* rule stays the stronger of the two statements
- [x] Wherever the range is restated across the skill, it is reconciled — the fix does not leave one copy
      saying "target" and another saying "typical"
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Redefining `coverage`, `coverage-drift` or `tracked-files-at-scan`** — TASK-033 and TASK-079 own the
  contract; this is about one enumeration being incomplete.
- The area-granularity floor — **TASK-129**, same drill, same step, different defect.
- The ask/blessing gaps — **TASK-127**.

*From TASK-088:*

- Re-drawing any consumer repo's areas. This decides the rule; applying it is that repo's own work.
- Whether config files count as behavioural source — that judgement is [[specs]]' `coverage-drift` classification, and TASK-033 settled that it is a judgement recorded as paths.

*From TASK-129:*

- **Changing what an "area" is.** Capability-not-class is the settled rule this task protects, not one it
  reopens.
- The unmapped-file exit contradiction — **TASK-128**, same drill, same step.
- The ask/blessing gaps — **TASK-127**.
- Whether `/specs init` should refuse to run below some floor. It should not, and nothing here proposes it;
  if that turns out to be arguable it is a decision, not a wording fix.

## Human test plan

- [x] Cold-drill `/specs init` on a fixture containing at least one clearly non-source tracked file, and
      confirm the run reaches `ignore` by following step 4 rather than against it
  - **Passed 2026-11-05:** fixture `%LOCALAPPDATA%/Temp/d128`: a Python repo with two capabilities (`src/notes.py`, `src/export.py`) and five clearly non-source tracked files (README, `docs/release.md`, `Makefile`, `pyproject.toml`, `scripts/deploy.sh`), no map; skill `specs` copied after this fix. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, brief "Run /specs init against repo/. Give its output and the full contents of every file it wrote." (shared preamble and closing asks; no expected outcome). It resolved all five non-source files into `ignore` by step 4's own list (build files, docs, deploy scripts), and mapped two areas for the two capabilities. Coldness: it listed no skills
- [x] Confirm the run's reported `coverage-drift` still distinguishes housekeeping from real source
  - **Passed 2026-11-05:** the same run wrote `coverage-drift: []`: no real source was unmapped, and the housekeeping went to `ignore`, not to drift

*From TASK-088:*

N/A — the deliverable is a stated rule plus two named consequences, checkable by reading it against the
three existing instances. No run exercises "is this rule wise"; the next re-discovery of WorkoutTracker's
map is where it gets used in anger.

*From TASK-129:*

- [x] Cold-drill `/specs init` on a fixture with two clear capabilities and confirm the run writes two
      areas and says why that is correct, rather than padding or apologising for the count
  - **Passed 2026-11-05 (second run):** `d128` rebuilt after the amended step 4. It wrote two areas and printed `2 areas — one per capability found; fewer than the typical range, which describes projects and is not a target`. The first run wrote two areas without padding, but did not say why, because init gave it no such line; that was added
- [ ] Confirm a fixture with no behavioural code still reaches the existing `not-applicable` verdict
      unchanged
  - **Failed 2026-11-05:** `d128z` (five tracked files, none code: README, docs, Makefile, pyproject, a deploy script) wrote `areas: []` with `coverage: unverified # areas proposed but never blessed`. Step 6 stamps every unblessed map `unverified`, which overrides the verdict table's `not-applicable` (no blessing required) even with nothing to bless. This predates this task: it came with the blessing rule after TASK-089's docs-only drill reached `not-applicable` → TASK-345

## Outcome

**What was fixed** (three merged findings, all in `/specs init` step 4 and the map's rules):
- **TASK-128:** step 4's sentence offered two exits for an unmapped file while the step's own paragraphs and step 6 rely on a third, `ignore`. The sentence was the defect. It now lists extending an area, adding an area, or adding an `ignore` entry, and the paragraph keeps what each means.
- **TASK-088:** a file may sit in several areas' `sources:` when it genuinely implements more than one capability. The test is that each area is a capability without it. Regen harvests it into each spec and verify stales each area on one edit, both named as intended.
- **TASK-129:** the 5–20 range describes typical projects and is not a target. A project with two capabilities maps two areas, recorded by the map itself and stated by the run, and never splits by class to reach a count. SKILL.md owns the range; init, the template and this repo's map point at it.

**Step-6 split:** 0/0, because this is prose and template comments only. Evidence is the drill, which passed on both test-plan steps. The lint passed, and the lint's own tests ran (see the log).

**Judgement calls.**
- **One owner for the range,** because identical wording in three places is how "target" and "healthy" drifted apart.
- **The shared-file rule documents existing practice** rather than inventing one: the known deliberate instances fit it, except `plans-segments.ts`, which is WorkoutTracker's call.

**Review (close step 5b, inline).** Adherence: one owner, pointers elsewhere, and the template claims nothing a render cannot make true. Fidelity: all fifteen criteria across the three blocks are met. Correctness: the quoted old phrase is gone too.

**Parked at `verify`:** TASK-129's no-code step failed on a regression that predates this task → TASK-345. It leaves `verify` when TASK-345 lands and that step re-runs.

**Flagged, not fixed.** When step 4's reconciliation "needs the user" is undefined, and the two paths give different maps. That is TASK-127's ask/blessing ground, out of scope here.

## Implementation plan

### Decisions
- **TASK-128: the two-way sentence was the defect.** The classification paragraph and step 6 both depend on an `ignore` exit, so they were right. The sentence now lists the three exits inline (extend an area, add an area, add an `ignore` entry), and the paragraph keeps what each means. The line quoting the old phrase is reworded too, or the two-exit reading would survive as a quote.
- **TASK-088: a file may sit in several areas** when it genuinely implements more than one capability. The test: each sharing area must be a capability without that file. The consequences are named and intended: regen harvests the file into each spec, and verify stales each area on one edit. The rule lives once, in SKILL.md § *The area map*; init step 4 and the template's `sources:` comment point at it; regen and verify are unchanged, since their behaviour already gives both consequences.
- **TASK-129: SKILL.md owns the range,** stated as typical, not a target. Fewer capabilities map exactly that many; a two-area map is the record, and the run states it. Never split by class to reach a count. Init's "Target granularity", the template comment and this repo's own map comment become pointers.

### Steps
1. init.md step 4: the sentence, the quoted phrase, and the granularity bullet.
2. SKILL.md: the granularity bullet and the shared-file bullet.
3. templates/map.yml: two comments. docs/specs/.map.yml: its comment.
4. Spec `specs-from-code`: The area map (shared files), the Granularity guidance scenario, and Init presents the map (three exits).
5. Lint and the lint tests; then the drill.

### Instance check (TASK-088)
- `ProgressEndpoints.cs` (two read models) and Presenter's `appsettings.json` (sections consumed by separate capabilities) are consistent with the rule.
- `plans-segments.ts` is consistent only if the segment bar carries behaviour each area specifies; otherwise it belongs to one area. That call is WorkoutTracker's own work.

## Progress log

- step 2 — picked; ranked above TASK-028 because key 1: a reader following step 4's two-way sentence literally folds non-source files into behavioural areas and silently inflates coverage-drift, a wrong result; key 4: one step of one verb; key 5: drill-verified (TASK-109's B2); TASK-089 dropped below on key 4 (a research task), TASK-092 on key 4 (an undecided flag design)
- step 3 — verified: held. init.md:42 "either extend an area or add one" omits the `ignore` exit that line 67 defines and step 6 expects; the merged TASK-088 (one file in several areas) and TASK-129 (projects below the 5–20 range) remain unaddressed in the file
- step 3b — planned: /tasks plan --no-grill (fifteen criteria across three merged findings); no split signal; "recorded" read as the map listing exactly the areas found, with the run stating it, so no new map key
- step 4 — layer: local
- step 5 — fix in skills/specs/verbs/init.md (three exits; the quoted phrase; granularity points at SKILL.md), skills/specs/SKILL.md (range descriptive; fewer is legitimate; the shared-file rule with its test and consequences), skills/specs/templates/map.yml and docs/specs/.map.yml (comments point at SKILL.md); the two-way sentence was the defect, the paragraphs and step 6 were right; lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose and template comments only; fix-dependent = none; contract pins = skills-lint.sh and skills-lint-test.sh; evidence = the Human test plan drill
- step 7 — respecced specs-from-code; requirements changed: The area map declares capabilities (shared files), the Granularity guidance scenario (count follows capabilities), Init presents the map (three exits); intended — TASK-128's criteria
- step 5 (amended after the drill) — init step 4 now has the run state a below-range count (`<n> areas — one per capability found; fewer than the typical range…`), since SKILL.md said "the run states" and init never told it to; d128 re-run passed. d128z (no code) failed to reach `not-applicable`, a regression from the blessing rule → TASK-345
- step 8 — handed to /tasks close --unattended; parked at verify on the failed step; outcome in status:, commit in git log
