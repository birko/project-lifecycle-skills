---
id: TASK-151
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-19
depends-on: []
blocks: []
findings: [DRILL-142-1]
pr: null
github-issue: null
jira-key: null
---

# The `AGENTS.md` comment measurement was under-evidenced, and this repo has real findings

## Context

Found by `review-comments` on its first real run — `--all` over this repository, as TASK-142's drill.
The skill was pointed at the repo that wrote it and found four comment findings inside
`skills-lint.sh`, a file `AGENTS.md` § Comments explicitly blesses.

**The measurement is not wrong about what it measured; it measured the wrong thing.** Its argument is
framed around line count — *"`skills-lint.sh` looks like a flagrant violation by line count while being
compliant by the test"* — and on that axis it holds: **not one of the ten findings is a length
finding.** What TASK-141 did was count lines and read the two largest blocks for *rationale*. What it
never did was the test's actual question: **search whether the content lives somewhere else.** The
skill ran that search and it does.

**The findings, as reported.** One is excluded: `skills-lint.sh:228-229`'s wrong-check comment is
already TASK-081's, and the skill said so rather than re-filing it.

| Site | Destination | Note |
|---|---|---|
| `skills-lint.sh:4-7` | the code itself | The header enumerates the checks, and **is already wrong** — it lists 1, 2, 3, 5 and omits checks 4 and 6, so a reader counting it finds four checks in a script that runs six. A restated list that went stale exactly as this repo's own rule predicts |
| `skills-lint.sh:107-111` | version history | A superseded measurement kept as a record of the comment's own revision. **Not called 🛑, correctly** — TASK-108:179-180 records deliberately keeping it, so the ⚠ exists to make that decision visible rather than to overturn it |
| `skills-lint.sh:123-128` | the ticket | The 8-of-39 measurement is a **third** copy — TASK-108 carries it at `:39`, `:114` and `:172`, and `AGENTS.md:279` carries it again. Keep the design reasoning at `:130-139` (that lives nowhere else); reduce the measurement to a pointer |
| `skills-lint-test.sh:50` + one more | version history / the code | The renumbering TASK-146 caused, contradicted 23 lines later in its own file |

**The ripple nobody has finished.** TASK-146 inserted a new check 5 and renumbered install-roots to 6.
That renumber has now been chased through `AGENTS.md` twice (once at TASK-142's start) and it is still
moving: **TASK-081's own acceptance criteria cite `skills-lint.sh:159` and call the enclosing block
"check 5"** — both now one renumbering behind. A task whose criteria describe a line that moved is a
task that will be closed against the wrong site.

## Acceptance criteria

- [x] Each finding above is acted on or dismissed **with a reason recorded** — "left as is" alone does not close this.
- [x] `skills-lint.sh`'s header stops enumerating the checks, or the enumeration is made complete and something keeps it that way. Do not simply add the two missing rows: that restores a list that will go stale again on the next check added.
- [x] TASK-081's acceptance criteria are repointed at the current line and check number, or TASK-081 is closed/cancelled if TASK-146 already resolved it.
- [x] `AGENTS.md` § Comments' measurement table is **re-run against the real test** — for each block, does its content live elsewhere? — and the table says which question it answered. Its own note already says a changed rule invalidates it; a changed *method* does too.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- `skills-lint.sh:228-229` — already TASK-081's.
- The comment rule's wording — settled, FEATURE-002 D1/D2.
- `review-comments` itself — TASK-142; this task is what its first run found.
- **Deferred to TASK-153** — a fifth copy of the 8-of-39 measurement at `skills-lint-test.sh:137-140`, found by this task's own block walk. Outside the four sites named above, and genuinely borderline: the comment rule protects a test comment that names the finding it pins.
- **Noted on TASK-148, not fixed here** — `install.sh:3` and `install.ps1:2` carry the same single-source-of-truth why-clause that TASK-148 was filed against in the two `pi-install` scripts. TASK-148's scope is two files; the clause is in four.
- `AGENTS.md:182`'s wrong check number — TASK-081's, repointed by this task rather than fixed (see step 5 of the plan).
- **Deferred to TASK-154** — two check headers in `skills-lint.sh` (`:159-162`, `:199-205`) restate reasoning held in `AGENTS.md` § Testing and FEATURE-002 D13. Found by this task's own human test plan; filed rather than absorbed.
- **`AGENTS.md:366`'s stale case count** (says 47; the suite runs 56) — **TASK-029** already owns it, and its criterion *"whether the guide should carry a raw count at all"* is the right fix. Linked there as a data point rather than spawned, and deliberately not hand-patched: hand-syncing the number re-arms the defect.

## Human test plan

- [x] Re-run `/review-comments --all` on this repo after the fixes. Expected: the acted-on findings are gone, and every dismissed one is absent *because the comment changed*, not because the check stopped looking.
- [x] Confirm the four survivors it named are still left alone — the ARG_RE design argument, the `##`-not-`#` note, the case-exact existence test and the `mktemp` subshell note. A "fix" that silences the report by making the check less discriminating is the failure mode here, and these four are how it would show. **Named by content, not by offset:** the plan was written at `:130-139`, `:262-266`, `:45-46`, `:16-18` and the fixes moved all four to `:124-133`, `:256-259`, `:43-44`, `:14-16`, so a re-runner following the original numbers would open the wrong lines — `:16-18` no longer even matches a block boundary.

## Implementation plan

_Drafted at `/tasks pick` 2026-09-20. Evidence re-verified against the working tree first: every
line number in `## Context` had moved, so the numbers below are current and the ones above are not._

**Standing constraint for every step.** `AGENTS.md:371-400` is the `comment-rule:start`/`end` region
check 5 asserts byte-identical against `skills/new-project/templates/CONVENTIONS-universal.md`. The
measurement table lives at `:402` onward, *outside* it. No step here may edit inside the markers — if
one appears to need to, that is a signal the change belongs in the rule rather than in the
measurement, which is FEATURE-002 D1/D2 and out of scope.

1. **`skills-lint.sh:2-12` — delete the enumeration, leave a pointer.** The header lists four of six
   checks. The criterion forbids adding the two missing rows, and rightly: this is the restated-list
   shape § *Defer to a shared inventory* names — it goes wrong silently the next time a check is
   added, which has now happened twice. The `printf '== N. name =='` banners **are** the list, so the
   header keeps its purpose line, the fenced-block note and the run-local line, and replaces the
   enumeration with one line saying the checks announce themselves. Pointer, not copy.

2. **`:105-111` — drop the superseded count, keep what it was evidence for.** Two things are tangled
   here: the *number* (30 invocations, superseded by 39 at `:124`) and the *finding* it supported —
   that there were **0 mismatches**, so the check is prophylactic rather than remedial. The second
   lives nowhere else and stays. Deleting the stale number also deletes the `SUPERSEDED` note, which
   exists only to manage the contradiction.
   - **This overrides a recorded decision**: TASK-108:179-180 deliberately kept the superseded text as
     a record of the comment's own revision. `review-comments` called it ⚠ not 🛑 for exactly that
     reason. The override is defensible — version history holds the revision — but it gets a line in
     this task's close notes, not a silent edit.

3. **`:124-128` — reduce the 8-of-39 measurement to a pointer.** Fourth copy of a number that
   TASK-108 carries at `:39`, `:114` and `:172` and `AGENTS.md:279` carries again. Destination: the
   ticket. **Keep `:130-139` untouched** — the argument about what an argument may look like, and why
   the one-lowercase-word ceiling is deliberate, lives nowhere else and is one of the four survivors.

4. **`skills-lint-test.sh:50` — fix the wrong claim, don't just renumber.** It says *"Check 5 is
   advisory and never touches the exit code"*. Check 5 (universal-conventions copies) is **fatal**;
   check 6 (install roots) is the advisory one, as `:71` and `:73` already say correctly 23 lines
   later. This is a factual error about which check is a gate, not a stale ordinal.

5. **Repoint TASK-081 — do not fix it here.** TASK-146 inserted a new check 5 and pushed install-roots
   to 6, so TASK-081 is one renumbering behind everywhere: its criteria cite `AGENTS.md:214`/`:265`,
   `skills-lint.sh:159` and `skills-lint-test.sh:70`, and call drift "check 5". Current sites:
   `AGENTS.md:182` (**wrong — still says check 5 for drift**) and `:477` (correct), `skills-lint.sh:228-229`,
   `skills-lint-test.sh:73`. Its criterion *"no single check number refers to two different checks"*
   is **still unmet** — `check 5` names drift at `:182` and the conventions copies at `:335` — so
   TASK-146 did **not** resolve it and it is repointed, not closed.
   - The one-word fix at `AGENTS.md:182` is TASK-081's, not this task's. Leaving it is deliberate;
     taking it would widen an in-flight task past its acceptance list.

6. **Re-run the measurement table against the real test — this is the task's centre.** TASK-141
   counted lines and read the two largest blocks for rationale. The test's actual question is *delete
   the line, then ask where its content already lives*. For each of the six scripts, walk its comment
   blocks and answer that question per block, then:
   - Rewrite the table so it **states which question it answered**, per the criterion. The line-count
     columns may stay as context, but the verdict column must be the destination search.
   - Re-measure the numbers **after** steps 1-4 land, since those change three of the six rows.
   - Re-run the counts with the same command the note names (`wc -l`, `grep -cE '^[[:space:]]*#'`,
     shebang included) or the table is not comparable to its own caveat.
   - Fix the two stale citations in the surrounding prose: the `##`-not-`#` note is at `:262-266`, not
     `:221-224`; verify the 35-line block's range and longest-run claim rather than re-quoting it.

7. **Verify.** `bash .github/workflows/skills-lint.sh` and `bash .github/workflows/skills-lint-test.sh`
   both pass. Then the human test plan: `/review-comments --all`, confirming the acted-on findings are
   gone *because the comment changed* and the four survivors (`skills-lint.sh:130-139`, `:262-266`,
   `:45-46`, `:16-18`) are untouched.

**Split signal watched for, none found.** Step 6 is the largest unit but cannot be separated — the
table is the artifact steps 1-4 invalidate, so closing them without it leaves the repo asserting a
measurement its own scripts no longer match.

## Progress log

- 2026-09-20 — Plan drafted at `/tasks pick`; every line number in `## Context` had moved and was re-verified against the working tree first.
- 2026-09-20 — Step 1: `skills-lint.sh` header enumeration deleted, replaced by a pointer at the `== N. name ==` banners.
- 2026-09-20 — Step 2: superseded 30-invocation count removed; the finding it supported (0 mismatches ⇒ preventive, not remedial) kept. **Overrides TASK-108:179-180's deliberate keep** — version history holds the revision, and removing the stale number also removes the `SUPERSEDED` note that existed only to manage the contradiction.
- 2026-09-20 — Step 3: the 8-of-39 measurement reduced to a pointer at TASK-108; the `grep -o` mechanic kept, since it lives nowhere else. `:130-139` untouched.
- 2026-09-20 — Step 4: `skills-lint-test.sh:50` said *"Check 5 is advisory"*; check 5 is fatal and check 6 is the advisory one. Corrected — a wrong claim about which check is a gate, not a stale ordinal.
  - **The row's "+ one more" site is `:70-73`, and it is dismissed rather than changed.** That is the half the finding said was *"contradicted 23 lines later in its own file"* — and the later half is the **correct** one: its parenthetical reads `(check 6 here)` and its assertion greps `'== 6. install roots'`. TASK-146 fixed that site and left `:50` behind, so the contradiction was one-sided. Recording the dismissal rather than leaving the row half-answered, since "left as is" without a reason does not close criterion 1.
- 2026-09-20 — Step 5: TASK-081 **repointed, not fixed**. Verified 4 of its 5 criteria still unmet, so TASK-146 did not resolve it; criterion 4 cleared incidentally and is ticked. Its ordinals and line numbers restated against the working tree.
- 2026-09-20 — Step 6: measurement table re-run against the destination search. Counts re-measured (the 2026-09-19 row for `skills-lint.sh` had already gone stale at 288/123/35 vs 323/128/31 before this task touched anything — recorded, because it is the second argument against a count carrying a verdict). Table now states which question it answered. Verified the edit sits outside the `comment-rule` markers; lint check 5 confirms the two copies still agree.
- 2026-09-20 — Two discoveries filed rather than absorbed: **TASK-153** spawned (fifth copy of the 8-of-39 measurement at `skills-lint-test.sh:137-140`); **TASK-148** given a scope correction (the same why-clause is in `install.sh`/`install.ps1`, so its "fix both or neither" spans four files, not two); **TASK-029** given a data point (the suite runs 56 cases, `AGENTS.md:366` says 47 — deliberately not hand-patched, since that re-arms the defect TASK-029 exists to settle).
- 2026-09-20 — Ledger reconciled: TASK-151 and TASK-153 appended to FEATURE-002 D10's `→ Tasks`, with a History line recording that D10's *verdict* changed while the decision itself did not.
- 2026-09-20 — Gates: `skills-lint.sh` OK (19 skills); `skills-lint-test.sh` 56 passed, 0 failed.
- 2026-09-20 — Close gate, three axes reported side by side, none merged or reranked. **Standards** ([[verify-conventions]]): pass, 2 ⚠ — `tasks/README.md` regenerated by targeted edit rather than full re-render, and `skills-lint.sh` changed with no new lint case (verified comment-only: filtering every non-comment `+`/`-` line leaves nothing in both scripts). **Fidelity** ([[verify-intent]]): pass; found criterion 1 half-answered — the finding row's *"+ one more"* site was unaddressed — which was closed before reporting. **Correctness** ([[code-review]]): **5 findings, all real, all fixed.**
- 2026-09-20 — What correctness caught that the other two axes could not, recorded because it is the argument for keeping the axes separate:
  - `tasks/README.md` was regenerated **before** TASK-154 was spawned, so it shipped 58 todo against a tree of 59 and omitted the new row. Re-derived: 59 todo, `1× P1 · 44× P2 · 14× P3`.
  - The same regeneration had been inheriting two older gaps: `TASK-150` counted but absent from the tree, and `TASK-138` rendered `[~] review` while the file says `done`. STORY-012's header read `(4/10)` against an actual 6 of 12. Fixed — a regeneration that reproduces its predecessor's omissions is not a regeneration.
  - **TASK-081's repoint cited `AGENTS.md:477`, and that citation went stale inside this very commit** — the § Comments rewrite added five net lines above it, moving the check-6 line to `:482`. A task whose whole subject is citations being one renumbering behind shipped one. Both its criteria now cite **by section heading and quoted text**, which no edit above them can move.
  - This task's own human-test bullet named the four survivors at their **pre-edit** offsets, ticked as run *after* the edits. Now named by content, with the offsets recorded as having moved.
  - `AGENTS.md` held up `:103-133` — the whole comment *run*, which is where the longest-run column's 31 comes from — as the untouched survivor, when the surviving argument is `:124-133` and `:103-123` is prose this diff rewrote. Corrected to `:124-133`, which is what TASK-151 and TASK-154 both already used.
