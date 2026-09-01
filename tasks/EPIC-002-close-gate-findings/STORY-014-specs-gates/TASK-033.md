---
id: TASK-033
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-08-19
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs init`'s coverage check can pass vacuously

## Context

Filed by TASK-020's `close` step 5d sweep (2026-08-19). It had been sitting in that task's
`## Out of scope` as *"`/specs init`'s vacuous coverage check from the same run — a specs-skill
defect, not filed here"* — unowned work wearing a boundary's clothing, which is exactly what the sweep
exists to catch. Confirmed unowned before filing: nothing else in `tasks/` covers it (TASK-002's
"vacuous pass" fix is a different defect, in `skills-lint.sh`).

**Observed** during the `adopt-project` drill on `Presenter`, 2026-08-18, in the same run that produced
TASK-020 and TASK-021.

`/specs init` step 4 checks coverage: *"any source file matching neither an area nor `ignore` → list as
unmapped and either extend an area or add one."* That check has no floor. If the scan set comes back
empty — no area glob matches anything, or the source discovery finds nothing — then "no unmapped files"
is trivially true and the step reports full coverage having verified nothing. It is the same shape as
the vacuous-pass defect already fixed in `skills-lint.sh` under TASK-002, which is grounds for
believing the fix shape is known even though this instance is not yet reproduced.

**What is not known, and must not be guessed:** the specifics of the Presenter instance were never
written down — only that a defect was seen here. So step one of this task is to **reproduce it**, not
to fix from this description. If reproduction shows the check is sound and something else misfired,
that finding closes the task just as well; do not bend the repro to fit this write-up.

### Reproduced 2026-08-31 (`/fix-next` step 3) — holds, with a different mechanism and a precedent

The filing named two ways the scan set can be empty. Tracing step 4's literal instruction — *"any source
file matching neither an area nor `ignore` → list as unmapped"* — over three repo shapes separates them:

| Shape | What step 4 does | Verdict |
|---|---|---|
| Sources exist, **proposed globs match none of them** | every source file matches neither an area nor `ignore`, so **all of them are listed as unmapped**. The check fires correctly | **not the defect** — the filing's first disjunct is wrong |
| **Discovery returned nothing** (wrong roots, an unusual stack, a repo whose product is prose) | there are no source files to be unmapped, so "no unmapped files" is trivially true and step 4 reports coverage having examined **nothing** | **the defect** |
| Genuinely code-free repo | identical output to the row above, and legitimate | **the reason the defect is invisible** |

So the mechanism is not "the map matched nothing" — it is **step 4 has no floor**: it never asks whether
the scan set was non-empty, and the two rows that produce identical output are exactly the ones that must
be told apart.

**The same defect was already found, measured and fixed in the sibling verb.** `regen.md:102-104`:
*"A polyrepo aggregator has no sources of its own. Globbing the project root there finds **zero** files, so
the check reports 'nothing unmapped' on every run, forever — a silent pass that reads as coverage.
Measured: 0 own sources, while the map's globs reached 97 sibling projects."* And `regen.md:117-118` carries
the general principle init is missing: *"Report the count in step 7 even when it is zero — a check whose
output is invisible when it passes is indistinguishable from one that never ran."*

That is much stronger evidence than the filing had: this is not a speculative defect, it is a known one
with a measured instance, applied to `regen` and never applied to `init`.

**Boundary with TASK-025, checked and unchanged.** Deciding *whether prose counts as source* stays
TASK-025's. This task does not need that answer: whatever discovery returned, `init` must not report
verified coverage over an empty scan set.

## Acceptance criteria

- [x] The Presenter-run behaviour is reproduced against a repo where the area globs match nothing, and what actually happens is recorded — including "the check is fine" if that is the answer — **and "the check is fine" is exactly the answer for that shape**; the real mechanism is recorded beside it. *Reproduction was a desk trace of step 4's instruction over three fixture shapes, not a live run; the run is the human test plan.*
- [x] If confirmed: an empty scan set is a **failure**, not a pass — `/specs init` says it could not establish coverage rather than reporting coverage it did not verify
- [x] The distinction between *nothing to map* (a genuinely code-free repo) and **discovery returned nothing** (wrong roots, an unrecognised stack) is stated, since the first is legitimate and the second is the defect. *Rescoped at step 3: the filing named "the mapping matched nothing" as the defect, and that case is handled — unmatched sources are listed as unmapped. The two shapes that produce identical output are code-free versus discovery-failed.*
- [x] Whatever the outcome, the `.map.yml` written by a run that could not verify coverage does not read as validated
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- DV10's blind spot on repos whose code is prose — TASK-025 owns that; a repo with no detectable source is that task's subject, not this one's.
- The empty-`areas:` seed in this repo's own `.map.yml` — STORY-008 fills it.
- `/specs regen`'s provenance attribution — TASK-026, already done.

## Human test plan

*Amended at close, because the original plan asserted the opposite of what this task established.* Item 1
read *"sources exist but the proposed globs match none of them → confirm the run refuses to claim
coverage."* The step-3 reproduction found that shape is **not** the defect: every unmatched source is
correctly listed as unmapped, so the shipped step 4 will not refuse there, and a closer running the old
plan would have recorded a false failure or "fixed" a check that works. Amending a **test plan** to match
verified behaviour is not the forbidden move — that is rewriting an *acceptance criterion* after the fact
to fit a result. The criteria are untouched.

Three drills, one per `coverage:` verdict, each run end-to-end against a real repo:

- [ ] **`unverified`** — a repo whose sources exist but that discovery does not recognise (an unusual stack, or roots pointed wrong). Confirm the run reports the scan-set count as 0, says coverage could not be established, and does **not** write a populated map that reads as blessed
- [ ] **`not-applicable`** — a genuinely code-free repo. Confirm it is allowed through, reported distinctly from the case above, and makes no claim of coverage
- [ ] **`verified`** — an ordinary repo whose proposed globs match none of its sources. Confirm the run lists them all as unmapped (this shape is **not** a defect) and only reaches `verified` once they are mapped or the decline is recorded as `unverified`
- [ ] Re-run `init` on the `unverified` repo with discovery fixed, and confirm the key flips to `verified` on its own — the self-clearing property is the whole reason it is written every run

**Withhold these expected outcomes from whoever runs the drill** — per TASK-068, a plan handed over with
its answers becomes a confirmation rather than a test. The brief is *"run `/specs init` on each repo and
report the verdict you assigned and why."*

## Outcome

**What the fix was.** `/specs init` step 4 checked coverage by listing source files that matched neither an
area nor `ignore`. With an empty scan set that condition is vacuously satisfied, so the step reported full
coverage having examined nothing — and wrote a `.map.yml` that read as blessed. Step 4 now always reports
the scan-set count and ends with one of three **total** verdicts (`verified` / `not-applicable` /
`unverified`), step 6 writes that verdict as a real `coverage:` key on every run, and step 2 reads it so a
re-discovery cannot treat never-validated areas as a baseline.

**The filing named the wrong mechanism, and finding that was most of the value.** It said the scan set goes
empty when *"no area glob matches anything, or the source discovery finds nothing"*. Traced over three
fixture shapes, the first is fine — every unmatched source **is** listed as unmapped, so the check fires
correctly. The two shapes that collapse are **genuinely code-free** and **discovery returned nothing**:
identical output, and only one is an answer. Criterion 3 was rescoped before any code was written; the
human test plan was amended at close, because it still asked a drill to confirm the shape that works.

**This defect had already been solved once, on the sibling verb.** `regen` step 6 carries the same check
*with* a floor and a measured instance — 0 own sources while the map's globs reached 97 sibling projects —
plus the general rule (*report the count even when it is zero*) that `init` lacked. Nothing in this repo
notices when a rule fixed in one verb is missing from its twin; that observation went to **TASK-084** as a
second measured instance rather than a new task.

**Step-6 split — weaker than the previous two tasks', and labelled as such.** `/specs init` is prose an
agent executes; there is no runner, so no test can fail without the fix. What exists:

- **Mechanical**: the old step 4 mandated the scan-set count **0** times; the new one **2**. A run's
  transcript is checkable for it, which it was not before.
- **Fixtures**: a code-free repo and a prose repo both yield **0** conventionally-discovered source files,
  demonstrating the collapse the fix exists to separate.
- **Contract pins, not evidence**: `skills-lint` OK (18 skills) and 43/43 lint-test cases. Neither reads
  this prose; they pin only that nothing structural broke.
- **The real test is the drill**, unrun — which is why this task is `review`, not `done`.

**Judgement calls, and why the stricter option was rejected.**

- **A key written every run, not a stamp added on failure.** My first attempt wrote a
  `# coverage: unverified` **comment**, only when the check failed. Three defects in one: a comment is
  what any re-serialization drops and nothing can branch on; nothing ever removed it, so a repo whose
  discovery was later fixed would carry a permanently stale caveat indistinguishable from a live one; and
  it had **no reader** — step 2 was never updated, so the next re-discovery would treat unvalidated areas
  as a blessed baseline. Writing a key unconditionally fixes all three at once: it is branchable, it
  self-clears, and `regen`'s `shaped-by-derived` is the existing precedent for exactly this.
- **`unverified` is the catch-all, deliberately.** My first version listed three cases and presented them
  as exhaustive; they were not — a "minimal map" written on the *nothing-to-map* branch matched none, and
  neither did a non-empty scan with unmapped files the user declined to map. The ways to fail are
  open-ended and the ways to succeed are not, so `verified` and `not-applicable` are the narrow ones and
  everything else falls through.
- **Rejected: forbidding the write outright.** Step 4 first said *"fix the discovery before writing
  anything"* while step 6 explained how to write anyway — a contradiction resolved by whichever sentence
  an agent read last. `init` is chained by `new-project` / `adopt-project`, so a hard prohibition strands
  those runs. It is now a stated preference, with the verdict recorded either way.
- **Not extended to consumers.** `roadmap`'s DV rules and `feature review` could branch on `coverage:`,
  and deliberately do not yet — adding audit rules is a different change with its own review. Step 2 is
  the one consumer this task owed, since without it the key had no reader at all.

**Flagged, not fixed:** `docs/specs/.map.yml` in this repo still carries `areas: []` and now also predates
the `coverage:` key — which reads as `unverified`, correctly. **TASK-079** (`/specs init`) is the run that
will set it, and this change is what makes that run's verdict meaningful.

## Drill results — 2026-09-01 — FAILED, and the failure is in this task's own fix

Two cold drills, both with expected answers withheld: one over four throwaway fixtures (full path,
including the write), one over five real Birko consumer repos (BardStudio, Latent, Presenter,
WorkoutTracker, Symbio — read-only, steps 1-4).

**Verdict: the human test plan does not pass.** The fix stops `init` reporting coverage it never
checked, but replaces it with a verdict that is neither reproducible nor informative.

### Defect A — the verdict's *moment* is unspecified, and it flips four of five repos

Step 4 both defines the verdict off "is anything left unmapped" **and**, in the same step, instructs
the agent to fix unmapped files by extending an area or the ignore list. Nothing says which moment the
verdict describes.

- Read as the **first pass**: Latent, Presenter, WorkoutTracker and Symbio are all `unverified`.
- Read as the **state after step 4's own remediation**: all five are `verified`.

Same repos, same instructions, opposite answers. The drill reported both numbers per repo rather than
choose. This is the defect the whole task was about — a verdict nobody can reproduce — reintroduced one
level up.

### Defect B — one word cannot carry what it is being asked to carry

All four existing-map repos collapse to the same literal verdict for four unrelated reasons:

| Repo | Unmapped at scan | What it actually means |
|---|---|---|
| Latent | 39 / 63 (62%) | the map never covered the repo — the entire non-`src` side was unaccounted for |
| Presenter | 3 / 102 | a carefully-built 11-area map missing two host-config files and a `.gitkeep` |
| WorkoutTracker | 11 / 558 | **6 are real capability source files that shipped after the map was last touched** — genuine behavioural drift |
| Symbio | 29 / 3874 | numerically the largest and **100% non-behavioural** (deploy scripts, committed `.claude/skills/*.md`, root docs); zero real drift in 32 areas |

"This map missed real behaviour" (WorkoutTracker) and "this map needs three lines of housekeeping"
(Symbio) are the two a reader most needs told apart, and they read identically.

### Defect C — the scan's universe is undefined, found independently by both drills

Step 4 counts "source file[s]", and nothing says what the scan walks. The fixture drill excluded
`README.md` "with no textual basis". The real-repo drill inferred *whole tracked repo* only from
indirect evidence — that the four shipped maps reach zero-unmapped only by explicitly ignoring
`docs/**`, `tasks/**`, `*.md`, `*.csproj`, which is meaningless unless those were in scope.
**Every verdict is a function of this undefined term.**

### Defect D — glob semantics unstated, and the choice moves real files

`**/*.props` under strict POSIX `fnmatch` requires a literal `/` and does **not** match a root-level
`Directory.Build.props`; under gitignore/minimatch semantics `**/` matches zero directories and it
does. That single unstated choice flips 3 files in Presenter and 3 in Latent between mapped and
unmapped.

### Defect E — dot-prefixed paths, and the repos disagree

Nothing says whether `.claude/`, `.editorconfig` or `.gitignore` are scannable. WorkoutTracker's own
map carries an explicit `.claude/**` ignore rule — proof its author found it necessary — while no map
ignores `.gitignore`. Reading `.claude/` as in-scope is what surfaced Symbio's 12 unmapped committed
skill files.

### Two adjacent gaps, not this task's

- **A file legitimately owned by two areas.** Step 4's "extend an area or add one" presumes one home.
  WorkoutTracker's map has a deliberate precedent (`ProgressEndpoints.cs`, shared, with a comment) and
  the newly-drifted `plans-segments.ts` is shared the same way.
- **No defined behaviour when nobody blesses the map.** Steps 5-6 speak of "the blessed areas"; an
  unattended run has no textual instruction for who decides.

### What the fixtures did establish, and what they failed to

`not-applicable` was reached correctly and reported **distinctly** from an empty result (fixture B,
scan-set 0), which is the collapse this fix exists to separate. Step 2 read the `coverage:` key on
re-discovery as intended.

**But no fixture reached `unverified`.** Fixture A was built as "sources exist, discovery does not
recognise them" — `.rules` files, no conventional stack. The runner read the README, understood the
sources, and returned `verified` with a scan set of 3. The assumption that an unusual extension defeats
discovery was simply wrong, so the fix's central path went unexercised there; on the real repos it was
reachable only under the ambiguous reading of Defect A.

### Findings about the target repos themselves (not defects in this skill)

Worth passing to whoever owns them: **WorkoutTracker** has 6 real source files no area covers
(`ReplacedPeriod.cs`, `RestPrescription.cs`, `active-plan-mirror.ts`, `session-day-mirror.ts`,
`plans-segments.ts`, `vh-debug.ts`); **Symbio** commits `.claude/skills/*.md` its map never ignores;
**Latent**'s ignore list never covered the non-`src` side of its repo.

## Progress log

- step 2 - picked; ranked above TASK-025 on key 3 (silence): a vacuous coverage check reports success having verified nothing and leaves a .map.yml that reads as validated, where DV10's blind spot is a visible under-report. Key 5 argues AGAINST this pick - the finding is explicitly unreproduced - but the task makes reproduction criterion 1 and blesses 'the check is sound' as a closing outcome, so the risk is bounded. Key 6 degenerate (pool is all correctness-invariants).
- step 3 - verified: HOLDS, rescoped before coding. Mechanism is not 'globs match nothing' (that case fires correctly) but 'step 4 has no floor for an empty scan set'. Found precedent: regen.md:102-104 documents the identical defect with a measured instance (0 own sources, 97 sibling projects) and regen.md:117 carries the report-even-when-zero principle init lacks. Criterion 3 rescoped.
- step 4 - layer: local.
- step 5 - fix in skills/specs/verbs/init.md (steps 2, 4, 6), skills/specs/templates/map.yml, skills/specs/SKILL.md. Lint OK (18 skills), lint-test 43/43.
- step 6 - no runner exists for this prose, so no fix-dependent test. Mechanical: mandated scan-set-count outputs 0 -> 2. Fixtures: code-free and prose repos both yield 0 discovered sources. Lint + 43 cases are contract pins, NOT evidence.
- step 5b - standards OK, intent OK, correctness found SEVEN defects in my own diff (no consumer for the stamp, no way to clear it, non-partitioning cases, a trigger state step 4 never emitted, a write prohibition contradicting a write fallback, comment-instead-of-key, and a test plan asserting the shape my own reproduction disproved). All seven fixed here.
- step 5d - 3 boundaries, 0 spawned; the sibling-verb observation recorded on TASK-084.
- step 7 - respec skipped: areas: [] (TASK-079).
- step 8 - parked at REVIEW, not done: four drill steps in the human test plan are real and unrun, and per TASK-068 the author running them is a confirmation, not evidence.
- DRILL 2026-09-01 - FAILED. Two cold drills (4 fixtures full-path, 5 real Birko repos read-only). Five defects in this task's own fix: verdict moment unspecified (flips 4/5 repos), one word cannot separate real drift from housekeeping, scan universe undefined (found by both drills independently), glob semantics unstated, dot-path handling unstated. Two adjacent gaps to spawn. status review -> in-progress.
- 2026-09-01 - fixed drill defects C, D, E. All three land in SKILL.md's shared `Rules:` block (one home, read by init/regen/verify) with init step 4 pointing at them: the scan is every file git tracks; every glob is matched with `:(glob)`; a dot-prefixed path is an ordinary scan member. D was NOT restated - verify.md already owned it with a measurement, so the rule points there; recorded as a third instance on TASK-084. Lint OK (18 skills), 43/43.
- STILL OPEN: defects A (the verdict's moment is unspecified - flips 4 of 5 real repos) and B (one word cannot separate real drift from housekeeping). The task cannot close until these are settled; the verdict remains unreproducible without A.
- 2026-09-01 - fixed drill defects A and B, the two that made the verdict unreproducible.
  A (which moment does the verdict describe): settled as the map AS WRITTEN, after step 4's own reconciliation - grading before the fix would mark a run `unverified` for a gap it went on to close. The earlier moment is not discarded, it becomes a number.
  B (one word carrying four meanings): every file unmapped at first scan is now classified by HOW it left the set - folded into an area (behavioural drift) or into `ignore` (housekeeping) - and `coverage-drift` counts only the first. Measured justification: Symbio 33 unmapped / 0 drift and Latent 42 / 0 are pure tidying, while WorkoutTracker's 14 / 6 was real shipped behaviour invisible to every regen. Raw count ranks those backwards, which is the whole argument for the field.
  Three keys now: `coverage`, `coverage-scanned`, `coverage-drift`. Absent companions read as NOT COMPUTED, never zero. Lint OK (18 skills), 43/43.
- status in-progress -> review: all five drill defects are fixed, so the code is complete, but the human test plan has not been re-run against the changed prose. The previous drill FAILED; a fix for a failed drill is not done until the drill runs again.
