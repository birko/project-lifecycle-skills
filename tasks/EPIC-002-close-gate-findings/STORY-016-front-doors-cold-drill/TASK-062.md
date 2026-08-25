---
id: TASK-062
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
picked-by: fix-next
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-2]
pr: null
github-issue: null
jira-key: null
---

# The test-harness ladder reports `missing` on the repo that ships it

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance).

`LAYER.md:111` gives the evidence order for the test-harness row: *"a test runner in the manifest
(xunit, vitest, pytest, `go test`); then `*.Tests`/`*_test.*`/`*.spec.*`/`*Test*.cs` files **anywhere**;
then a runner config."*

**This repo has no manifest and matches none of those globs.** Its suite is
`.github/workflows/skills-lint-test.sh` — hyphen-`test`, not underscore; `.sh`, not a recognised test
extension. Applied literally, the ladder returns **`missing`** for the test harness of the repo that
defines the ladder.

That is the exact **false-`missing`** the whole § *Detect what the repo has* section exists to prevent,
and the section names why it is the dangerous direction: *"Fill acts on the survey, so 'missing' invites
writing."* Here it would invite `populate-tests` to wire a runner over a working 36-case suite.

**What actually saved the drill was the prose**, not the ladder: `LAYER.md:107`'s *"detect by
**evidence**, not by path"*. The agent followed the preamble over the table and reported `present`. So
the mechanism is one sentence of judgement standing between the table and a wrong answer — fine for an
attentive reader, and exactly the kind of thing that fails under time pressure or on a less careful pass.

**Sibling, not duplicate: TASK-025.** That task is DV10's *"real code"* test failing to see a repo whose
code is prose, in `roadmap`. This is the same blind spot in `LAYER.md`'s ladder. Same root idea, two
different files and two different consumers — **cross-reference, do not merge**, and check the other
direction while here: are there further detection rules that assume a compiled language?

## Acceptance criteria

- [x] The ladder's evidence recognises a script-based suite invoked by CI — this repo's own is the test case, and it must come out `present`
- [x] The generalisation is deliberate, not a glob bolted on for `.sh`: state what class of evidence the new entry covers, so the next non-compiled stack is not another special case
- [x] The "detect by evidence, not by path" preamble is still the governing rule — the table gets closer to it rather than replacing it
- [x] TASK-025 is cross-referenced from this task and this task from TASK-025, with a line on why they stay separate
- [x] Other detection rules in `LAYER.md` are checked for the same compiled-language assumption; each is either fixed here or spawned, and the sweep's outcome is stated either way
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `roadmap`'s DV10 — **TASK-025** owns it.
- Widening `populate-tests`' own stack detection — **condition evaluated, and it fired: deferred to TASK-072.** Its `adopt` mode scaffolds "a pinned dev-dep on the runner", which presumes a package manager a prose repo has not got.
- The other drill findings — separate tasks under STORY-016.

## Human test plan

- [x] Run `adopt-project`'s survey against **this repo** and confirm the test-harness row reports `present`, reached from the ladder rather than from the preamble rescuing it
- [x] Run it against a repo with a conventional suite (`Birko/Consumers/WorkoutTracker` has xUnit + Playwright) and confirm the generalisation did not break the ordinary case

## Implementation plan

_Populated by `/tasks plan TASK-062` — leave empty until then._

**What was run, precisely:** a scripted application of the **ladder itself** over three repos, not a full
`adopt-project` survey. The ladder is the thing under test and the plan asks only what the row reports, so
this is the substance rather than a proxy — but it is not an end-to-end drill, and the difference is stated
rather than glossed. A fresh-agent survey would additionally exercise how the *report* words it.

## Outcome

**What was broken.** `adopt-project`'s survey decides whether a repo has a test harness by walking an
evidence ladder in `LAYER.md`. Every entry asked for a *declaration* — a runner named in a manifest, a file
named `*_test.*`/`*.spec.*`/`*.Tests`/`*Test*.cs`, a runner config — and **none asked what the repo's gate
actually runs.** This repo has no manifest and its suite is `.github/workflows/skills-lint-test.sh`, which
matches no glob (hyphen-`test`, and `.sh`). So the ladder returned **`missing`** for the test harness of the
repo that defines the ladder, with a 36-case suite CI runs on every push.

That is the **false `missing`** the section itself calls the dangerous direction: fill acts on the survey, so
`missing` invites [[populate-tests]] to wire a runner over a working suite. Only the section's prose preamble
(*"detect by evidence, not by path"*) saved the earlier cold drill — a preamble is not a ladder.

**The fix.** A new **first** entry: *what the gate actually runs* — read the CI workflow or task-runner
target and see what it invokes. Placed first because the other three are declarations of *intent* while this
is **observed execution**: if CI runs it, the suite exists, whatever it is called. That direction cannot
false-positive, which is the argument for the ordering.

**Step 6 — the guard can still fail.** Three repos, and the negative case is the point:

| Repo | Before | After | Role |
|---|---|---|---|
| this repo — script suite, no manifest | `missing` (verified by hand: no manifest, 0/4 globs matched) | **`present`** via entry 1 | **fix-dependent** |
| `drill-a` — docs-only, no tests, no CI | `missing` | **`missing`** | **proves the guard can still fail** — the generalisation is not a rubber stamp |
| `WorkoutTracker` — xUnit + Playwright | `present` | `present` via entry 2, path unchanged | **contract pin, not evidence** |

**Judgement calls, and why the stricter option was rejected.**

- **Rejected: adding `*-test.sh` to the glob list.** Strictly smaller and it would have fixed this repo. Rejected because it fixes one filename and leaves the next non-conventional stack — a `Makefile` target, a `just` recipe, a compiled test binary — to rediscover the same false `missing`. The task's own criterion demanded the generalisation be deliberate rather than bolted on.
- **Rejected: putting the new entry last.** Safer-looking, and wrong: the ladder is ordered by strength of evidence, and observed execution is the strongest thing available. Leaving it last would mean a repo with a stale manifest entry outranks one whose gate demonstrably runs.
- **Kept: the "detect by evidence, not by path" preamble as the governing rule.** The table now moves closer to it instead of relying on it as a rescue.

**AC 5 sweep — other rows checked for the same compiled-language assumption.** Rulebook (defers to
[[verify-conventions]]'s ladder), Docs (*"`docs/` is a convention, not a requirement"*), Changelog
(`CHANGELOG`/`HISTORY`/`NEWS`/README section), Task tracking (`tasks/`, Issues, Jira) — all already
stack-agnostic. § *CI a repo cannot pass* is entirely MSBuild/Cargo/npm/Python, but it already says
*"Other ecosystems: unverified"* and its outcome for a build-less repo is correct (nothing escapes the root,
so CI is offerable). **The test-harness row was the only one carrying the assumption.** Nothing spawned.

**Flagged, not fixed.** Nothing new. The sibling blind spot in `roadmap`'s DV10 is **TASK-025**, now
cross-referenced both ways with a line on why the two stay separate — and a note that the
observed-execution move may apply there too.

**Step 7.** No usable spec map (`areas: []`), so no regen. Said, not skipped silently.

## Progress log

- step 2 — picked; ranked above TASK-057 because a false `missing` invites a **fill that writes over a working setup**, which `LAYER.md` itself calls "the dangerous direction"; TASK-057's worst case is a wrong gate verdict with no destructive path. Key 6 (theme) was **inert** — all seven EPIC-002 stories declare `correctness-invariants`, the "every candidate declares the same one" case.
- step 3 — verified: **held as written.** No manifest present; all four globs return NO MATCH against `.github/workflows/skills-lint-test.sh`.
- step 4 — layer: **local.** The ladder is this repo's own file; no upstream.
- step 5 — fix in `skills/new-project/LAYER.md` (new first ladder entry + a rationale paragraph). No automated test exists for ladder semantics — the lint does not read the table — so the check is the three-repo application recorded above.
- step 6 — applied the ladder to 3 repos: **fix-dependent** = this repo (`missing`→`present`); **guard can still fail** = `drill-a` stays `missing`; **contract pin** = WorkoutTracker unchanged via entry 2.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep fired on the conditional `populate-tests` bullet → spawned **TASK-072**. Gate: standards pass, intent pass, correctness pass; security not applicable (prose, no surface). Layer parity verified — neither front door restates the ladder, so one edit covers both.
