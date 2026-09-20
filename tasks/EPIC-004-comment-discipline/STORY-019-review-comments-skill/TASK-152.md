---
id: TASK-152
parent: STORY-019
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-19
depends-on: []
blocks: []
findings: [DRILL-143-1]
pr: null
github-issue: null
jira-key: null
---

# `review-comments` promises a `PATH` argument and never defines it

## Context

Found while building TASK-143's drill fixture, not by a review pass.

`skills/review-comments/SKILL.md`'s invocation block offers three forms:

```
/review-comments [PATH …]        the current diff (default)
/review-comments --all           the whole repository
/review-comments --all --batch N print batch N of the same ordering
```

**`PATH` appears exactly once in the whole file — on that line.** Nothing says what passing a path
does. Step 2 defines two scopes only, the diff and `--all`, so a caller who writes
`/review-comments src/mill.ts` gets whatever the reader improvises: the diff *restricted* to that path,
that whole file swept regardless of the diff, or the path ignored.

**This is the same defect class the skill itself refuses for `--batch`.** That flag is refused by name
where it cannot apply, on the stated grounds that *"a flag silently dropped by one path is worse than
one that never existed, because the caller reads the promise and not the scope."* `PATH` is a promise in
the invocation block with no scope behind it at all.

**It bit during the drill and that is how it was found.** TASK-143's fixture needed a run that is scoped
but not diff-bound — `--all` deliberately asks nothing, so the only-copy question cannot be exercised
there. A path argument is the obvious way to get one, and it turned out to be undefined, so the fixture
was rebuilt to make the comments an unstaged diff instead. That worked, but it means **the only-copy
question has only ever been exercised through the diff scope.**

**The third form matters most and is the least defined.** A whole-file sweep of one file is exactly what
someone reaching for this command wants — *"check the comments in the file I am about to work in"* —
and today that is the one thing the invocation block appears to offer and does not.

## Acceptance criteria

- [x] Step 2 defines what a `PATH` argument does, in the same terms as the other two scopes, or the form is removed from the invocation block.
- [x] If defined: it says whether the path restricts the diff or sweeps the whole file regardless of the diff. One reading, not a sentence admitting both.
- [x] If it sweeps whole files, it says whether the only-copy question is asked there — `--all` suppresses it, and a path scope is not `--all`, so the answer cannot be inferred from either existing rule.
- [x] Generated-file exclusion and `git ls-files` membership apply to a path scope too, or the file says why they do not.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The two defined scopes — TASK-142, working.
- The only-copy rule — TASK-143, working; this task only widens where it can be reached.
- **Deferred to TASK-156** — two round-4 residuals: the header's surrounding prose still varies between readers (the mandatory `N of M tracked` fragment landed 2 of 2; the sentence around it did not), and the `PATH` + `--all` refusal was written in the review-fix pass and exercised by no round.
- **Deferred to TASK-155** — the 5:1 severity divergence this task's own drill measured (six runners, one rendering ⚠ where five rendered 🛑, on a case the severity table's always-violation row names). Scope resolution was 6 of 6; severity assignment is a different rule and a different task.

## Human test plan

- [x] Run `/review-comments <one file>` on the TASK-143 fixture (`scratchpad/drill-143`, resettable with `git reset --hard && git clean -fd`) with a **clean** tree, so the diff is empty. Expected: the file is swept and the header names the path scope. Today an empty diff and a path argument cannot be told apart in the output.
- [x] Run it twice with the same arguments. Expected: the same scope both times. An undefined form invites two readers to improvise differently, which is the defect rather than a side effect of it.

## Implementation plan

_Drafted at `/tasks pick` 2026-09-20. Design settled in the same sitting: `PATH` **sweeps the named
files in full, ignoring the diff**, and **asks** the only-copy question._

**The file already argued for this reading, which is why the decision was cheap.** § *The only copy*
says relocation *"belongs to **a scoped run where a person is looking at one file**"*, and the `--all`
report's held line reads `run scoped to act on it`. Both sentences presuppose a scope that exists and
asks — and neither could refer to anything, because the only two defined scopes are the diff (not
"one file") and `--all` (which explicitly does not ask). So this is not new design; it is writing
down the scope two other sections already depend on.

1. **Rewrite the invocation block so all three forms read the same way.** Today `[PATH …]` sits on the
   *default* line, which is itself part of the defect — it renders as a modifier of the diff rather
   than a scope of its own. Give it its own line, and add the one-line gloss the other two already
   have.

2. **Step 2 gains a third scope, written at the same altitude as the other two.** Not a footnote on
   the diff paragraph — a peer. It must state, in one reading:
   - the named paths are swept **in full**, and the diff is **not consulted at all**;
   - membership is `git ls-files`, exactly as `--all` does it, and for the identical reason already
     recorded there — an untracked scratch file must not produce a finding nobody else can reproduce.
     A path argument naming an untracked file is therefore **reported, not swept**, and saying which
     is the difference between a scope and a silent no-op;
   - a directory argument expands to the tracked files under it (`[PATH …]` already promises more than
     one argument, so the plural and the directory case both need an answer rather than an assumption);
   - the generated/vendored exclusion ladder applies unchanged — and, per that ladder's own rule, an
     **explicitly named** path that looks generated is still reported rather than silently dropped,
     since naming it is the strongest possible signal the user meant it.

3. **State that the only-copy question IS asked here, and say why in one clause.** This cannot be
   inferred from either existing rule and the criterion says so: `--all` suppresses the question
   because a census asking three hundred times is unusable, and the diff scope asks because a person
   is present. A path scope is **not** `--all` — it is the scoped run § *The only copy* already names
   — so it asks. Put the sentence in § *The only copy*, where the `--all` suppression lives, so the
   two rules sit together rather than a reader finding one and assuming the other.

4. **Refuse `--batch` with a path, by name.** `--batch` is already refused without `--all` on the
   stated grounds that *"a diff-scoped run is not paged"*. A path run is not paged either, and the
   existing sentence says "without `--all`", which technically already covers it — **verify that
   reading holds and leave it alone if it does.** Adding a second refusal sentence for a case one
   sentence already covers is the restated-list defect this repo lints for. Record the check either
   way; a criterion answered by "the existing wording already does this" still has to be answered.

5. **Header line.** The report header names the scope on every run (§ *Output format*'s worked
   example prints `Scope:`). A path run must render distinguishably from an empty diff run — that is
   the task's own second human-test step, and it is the failure that makes this bug invisible today.

6. **Verify.** `bash .github/workflows/skills-lint.sh` passes (the skill's links must still resolve).
   Then the human test plan on the TASK-143 fixture, with a **clean** tree so the diff is empty.

**Out of scope, held deliberately:** the two defined scopes (TASK-142) and the only-copy rule itself
(TASK-143). This task widens *where* the rule can be reached; it does not change the rule.

## Progress log

- 2026-09-20 — Picked; design settled in the same sitting (path = **whole-file sweep, diff not consulted, only-copy question asked**). The file had already argued for it: § *The only copy* says relocation *"belongs to a scoped run where a person is looking at one file"* and its `--all` held line reads `run scoped to act on it`. Both sentences depended on a scope the file never defined, so this was writing down an existing dependency rather than new design.
- 2026-09-20 — Step 1: `PATH` moved off the **default** line onto its own. That placement was itself part of the defect — on the default line it read as a modifier of the diff, so the three scopes never looked like peers and nothing was obliged to define the third.
- 2026-09-20 — Step 2: third scope written at peer altitude, with the four questions a reader would otherwise improvise — `git ls-files` membership (untracked path ⇒ **reported, not swept**), directory expansion, the generated-file ladder, and a pointer to the only-copy answer.
  - **One deliberate exception recorded:** an explicitly named path that *looks* generated is swept anyway, with the header saying so. Naming a file is the strongest signal the caller meant it, and silently sweeping nothing in response to an explicit argument is this task's own defect wearing a different hat.
- 2026-09-20 — Step 3: the only-copy answer stated in § *The only copy*, beside the `--all` suppression, because the two rules are told apart only by sitting together. A path run shares the *person* with the diff scope and the *whole-file reach* with `--all`, so a reader reaching for the nearest rule can land either way — and the two answers differ by whether anything is relocated at all.
- 2026-09-20 — **Step 4 revised against the plan, and the plan was half right.** It predicted the existing `--batch` refusal already covered a path run, since its condition reads *"without `--all`"*. The **condition** did; the **quoted sentence the agent must say** did not — it named only *"a diff-scoped run"*, so a path-scoped caller would have been told something false about their own invocation. Fixed the message, left the condition alone. Recorded because "the wording already covers it" was the answer the plan expected and would have shipped the gap.
- 2026-09-20 — Also updated two enumerations this change invalidated: the frontmatter `description` listed two of three scopes, and § *Where this runs* said *"pointed at an area you are about to work in"* — a phrase that until now named no mechanism.
- 2026-09-20 — `bash .github/workflows/skills-lint.sh` OK (19 skills).

### Drill record — 2026-09-20, round 1 of 2

**Runner acquisition.** `claude -p` (CLI 2.1.278, `--permission-mode acceptEdits`, `--add-dir` for the
skills link and its junction target), two processes on **independent copies** of the fixture, run
concurrently. Coldness: the brief withheld the whole subject — *"Use the review-comments skill on
`src/ledger.ts` in this repo and give me its report."* It names a path and says nothing about what a
path should mean, which is the question under test. Neither runner's context held TASK-152. The skill
itself resolves through the user-level junction, so both read the **edited** `SKILL.md`, which is the
point: the test is whether the written definition is unambiguous, not whether I can follow my own.

**Fixture** at `scratchpad/drill-152`: a TypeScript repo carrying the rule at rung 0 (spliced verbatim
from the shipped template, markers intact), an open `TASK-007`, an `ADR 0003`, and three comment blocks
**committed** — so the tree is clean and the diff is empty. That is the condition the task says cannot
today be told apart from a path run.

| Required | Runner 1 | Runner 2 |
|---|---|---|
| sweeps the file with an empty diff | ✅ | ✅ |
| header names the path scope, distinguishably | `paths (diff not consulted) — src/ledger.ts swept in full; 1 of 1 tracked` | same line, verbatim |
| ADR-backed rationale ⇒ found, record named | 🛑, `ADR 0003:3-4` | 🛑, `ADR 0003:3-4` |
| ticket-backed defect note ⇒ found, task named | ⚠, `TASK-007` | ⚠, `TASK-007` |
| destination-`nowhere` block ⇒ kept | kept, and **not** reported for length | kept, same reasoning |
| nothing edited without asking | ✅ | ✅ |

**Criterion 2's substance is met by measurement, not assertion: two independent readers resolved the
scope identically — whole-file sweep, diff not consulted, both saying so on the header.** Claims about
the header's exact *wording* are corrected in the round-3 verdict below; this round's capture was
truncated and cannot support one.

**Round 1 had a hole, and it is the same hole TASK-143 hit.** Every finding had a **populated**
destination, so the only-copy question could not fire — which means round 1 could not exercise
criterion 3, the one rule this scope was defined to make reachable. The fixture reproduced TASK-143's
cases (a), (c) and (d) and omitted its case (b): a defect note whose destination is **empty**. Recorded
rather than quietly rescored, exactly as TASK-143 recorded its own miscategorised case. Round 2 adds
case (b) and re-runs on two fresh copies.

### Drill record — 2026-09-20, round 2 of 3

**Fixture** `drill-152c` / `-152d`: round 1's repo plus TASK-143's missing **case (b)** — a
reconciliation defect described in a comment that **no task and no ADR carries**, committed so the tree
stays clean. Same brief, same acquisition, two fresh copies.

| Required | Runner 3 | Runner 4 |
|---|---|---|
| header names the path scope | `paths (diff not consulted) — src/ledger.ts swept in full; 1 of 1 tracked` | same |
| the two populated-destination findings | both, destinations verified | both, destinations verified |
| destination-`nowhere` block kept | ✅ | ✅ |
| **only-copy case ⇒ held, question put** | **held**, question verbatim, `unresolved (1)` | **held**, question verbatim |
| answer-less path ⇒ nothing deleted, nothing created | ✅ | ✅ |

**Criterion 3 is met by measurement.** A path-scoped run reaches the only-copy question — the rule that
until now had only ever been reachable through the diff scope, which is the gap TASK-143 recorded and
the reason this task exists. Runner 3 went further than required and checked `git log` before calling
the destination empty, which is what separates *"nobody wrote it down"* from *"I did not look"*.

**One divergence, recorded because a drill that only reports agreement is not evidence.** Runners 1-3
called the ADR-backed rationale **🛑**; runner 4 called it **⚠**, while explicitly noting *"the rule also
names a rationale above a declaration as always a violation"* — so it read the rule correctly and still
rendered a different severity. That is 3:1 on **severity assignment**, not on scope: all four resolved
the path scope identically. **Out of scope here** — this task defines a scope, it does not touch the
severity table — and flagged rather than absorbed.

**Criterion 4 was still unexercised after round 2** and is not claimed on the strength of being written
down: the fixture had no untracked path and nothing generated. Round 3 adds both.

### Drill record — 2026-09-20, round 3 of 3 — criterion 4

**Fixture** `drill-152e` / `-152f`: round 2's repo plus `.gitattributes` declaring `*.gen.ts
linguist-generated`, a generated `src/schema.gen.ts` carrying a **changelog** comment (an
always-violation), and an **untracked** `src/scratch.ts`. Brief named all three paths explicitly and
said nothing about how any of them should be treated.

| Required | Runner 5 | Runner 6 |
|---|---|---|
| untracked path ⇒ reported, not silently ignored | `not tracked, not swept: src/scratch.ts` | same, plus `2 of 3 tracked` on the header |
| explicitly-named generated file ⇒ swept anyway, header says so | *"declared linguist-generated … swept anyway because you named it explicitly"* | *"would normally be excluded — swept because you named it explicitly"* |
| the generated file's changelog found | 🛑 row 2 | 🛑 row 2 |
| only-copy cases held, questions put | 2 held, both questions verbatim | 2 held, both questions verbatim |
| nothing edited | ✅ | ✅ |

**Criterion 4 is met by measurement, and the exception is the part that was actually at risk.** The rule
says an explicitly-named path is swept *even when it looks generated*, because naming a file is the
strongest signal the caller meant it. Both runners applied it and **said so on the header** — had the
exception been wrong or unclear, they would have silently swept nothing in response to an explicit
argument, which is this task's own defect one level down.

**Both runners independently reached a composition the fixture did not design for.** The changelog in
the generated file is an always-violation whose destination (version history) is **empty** — the repo's
history begins after both dated events — *and* it sits in a file that must not be hand-edited. Each
concluded, separately, that the line is held from deletion **and** that the real fix belongs in the
codegen template rather than the checked-in output. Neither rule says that; it falls out of two rules
composing. Recorded because it is the strongest available evidence that the written scope is understood
rather than pattern-matched. Both also caught that `scratch.ts` misattributes the reconcile bug to
TASK-007 — a wrong cross-reference, not a filing.

### Drill verdict — PASS, 6 runners over 3 rounds

| Criterion | Evidence |
|---|---|
| 1 — Step 2 defines the scope at peer altitude | written; rounds 1-3 all resolved it without improvising |
| 2 — one reading, not a sentence admitting both | **6 of 6** resolved the scope identically (whole-file sweep, diff not consulted). **Not "to the wording"** — see the correction below |
| 3 — only-copy question asked in a path scope | **4 of 4** in rounds 2-3: held, question verbatim, nothing created |
| 4 — `git ls-files` membership + generated exclusion | **2 of 2**: untracked reported, named-generated swept with the header saying so |
| 5 — lint passes | `skills-lint.sh` OK (19 skills) |

**Correction — the first verdict written here overstated its own evidence, twice.**

1. It claimed the six scope lines matched **"to the wording"**. They did not. Runner 6 emitted
   `2 of 3 tracked` on its header where runner 5's line did not carry the fragment — recorded in the
   round-3 table four rows above the claim, and contradicting it. That fragment is part of the scope
   line, so this is a divergence in **exactly** the quantity criterion 2 measures.
2. Worse, and self-inflicted: rounds 1 and 3 were captured with `tail -60` / `tail -70`, which **cut the
   top of two runners' headers**. So "to the wording" was asserted over output that had not been seen
   in full. The capture command is part of a drill's method, and one that truncates the artifact under
   test invalidates the claim rather than weakening it.

**What the evidence does support:** 6 of 6 resolved the *scope* identically — every runner swept the
named paths in full, ignored the diff, and said so. That is criterion 2's substance. The header's exact
shape was **not** uniform, and the skill has been amended to require the `N of M tracked` fragment
unconditionally, so the next run has one shape rather than two.

**Two divergences total, both filed rather than absorbed.** The header fragment, fixed in this task
because it is scope-line wording and therefore criterion 2's own subject. And severity: runner 4
rendered the ADR-backed rationale **⚠** where 1, 2, 3, 5 and 6 rendered **🛑** — 5:1 — while quoting the
rule that names it an always-violation. That one is not this task's and is **TASK-155**.

**Method note for whoever runs the next drill: capture the runner's output whole.** `tail -N` on a
report whose header is the thing under test is how a drill comes to certify a claim it never saw.

### Drill record — 2026-09-20, round 4 — the post-review rules

**Why a fourth round.** `/code-review` at the close gate found eight defects, six in the skill itself,
and fixing them **changed the rules the first three rounds had tested**. A drill verdict carried over a
changed subject is not evidence, so the three new rules were re-run: the directory/"named explicitly"
distinction, the mandatory `N of M tracked` fragment, and the `PATH` + `--all` refusal.

**Fixture** `drill-152g` / `-152h` (copies of `-152e`), invoked on the **directory** `src/`, which holds
a tracked source file, a tracked file declared `linguist-generated`, and an untracked file. **Captured
whole — no `tail`**, which is the method fix this task's own correction demands.

| Required by the post-review rules | Runner 7 | Runner 8 |
|---|---|---|
| generated file reached by **expansion** ⇒ excluded (not "named") | ✅ *"reached by directory expansion, not named by its own path, so the exclusion applies"* | ✅ excluded, declaration cited |
| untracked file under an expanded directory ⇒ skipped **silently** | ✅ no report line | ✅ no report line |
| `N of M tracked` present unconditionally | ✅ `2 of 2 tracked` | ✅ `2 of 2 tracked` |
| only-copy held, question put, nothing created | ✅ | ✅ |

**The directory rule flipped the outcome from round 3, which is the evidence that it is doing work.**
The same `schema.gen.ts` was **swept** in round 3 (named by its own path) and **excluded** in round 4
(reached by expansion). Two runners, opposite handling, each correct — the ambiguity `/code-review`
found is resolved rather than merely worded around.

**Residual, recorded rather than iterated on: the header's prose is not byte-identical.**
`src/ swept in full; 2 of 2 tracked` vs `src/ expanded; 2 of 2 tracked, 1 swept in full`. The mandatory
fragment is in both, so the fix did what it specified. But runner 8's line is the better one — it keeps
*tracked* and *swept* separate, where runner 7's says "swept in full" of a set from which it then
excludes a member. **The skill requires the fragment and does not prescribe the surrounding sentence**,
and whether it should is a judgement about how far to standardise a human-readable header, not a defect
in this scope. Left for a decision rather than settled unasked.

**Untested and not claimed: the `PATH` + `--all` refusal.** Written in the same pass, never exercised —
no round invoked both. It is one sentence of the same shape as the `--batch` refusal beside it, but
"resembles a tested rule" is not a measurement.
