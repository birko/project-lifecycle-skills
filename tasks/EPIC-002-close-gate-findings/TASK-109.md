---
id: TASK-109
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: in-progress
priority: P1
assignee: agent
created: 2026-09-08
depends-on: []
blocks: [TASK-126]
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [CR-3, CR-5]
pr: null
github-issue: null
jira-key: null
---

# Two templates ship a live value their own rules say must be chosen, so a faithful render mints it

## Context

**From a [[code-review]] pass on 2026-09-08.** Two findings, filed as one task because they are one
root cause: **a template ships a live value for a field the surrounding rules say must be *declared* or
*derived*, so an agent rendering the template faithfully creates the very state the rules forbid.**
Filed at epic level because the fix spans two skills and neither owns it alone.

### CR-3 — `skills/specs/templates/map.yml:20`

The template hard-codes `coverage: verified` beside `tracked-files-at-scan: 0` — a combination
`init.md` step 4's own verdict table declares **impossible**, since `verified` requires a non-empty scan
set. Step 6 says *"No `.map.yml` on disk → render `templates/map.yml`"*, so any render that does not
overwrite these keys ships exactly the *"map that looks populated and blessed while nothing checked
it"* state the `coverage` key was added to prevent.

**Unlike `example-capability`, `verified` does not look like a placeholder** — which is what makes it
survive review. A reader scanning the rendered file sees a plausible verdict, not an obvious stub.

### CR-5 — `skills/tasks/templates/config.yml:12`

The comment directly above it says `/tasks init` *"only writes it once someone has actually chosen"*
and that *"the line ABSENT … means undeclared"* — while the template ships `integration: pr-per-task`
as a live line. `init.md` step 3's Absent branch says *"write it from the template"*, so a faithful
render **mints a declaration nobody made.**

This is precisely the DRILL-053-6 defect — `integration: pr-per-task` in a repo with no git — that the
surrounding prose was written to kill. The prose landed; the template it points at did not change, so
the defect is reachable by following the instructions correctly.

### Why one task

Both are the same failure with the same shape and the same fix-shape: **make the template's value
absent or unambiguously a token, so that rendering cannot assert what only a run can determine.** Fixed
separately, the second one is likely to be fixed differently — and the principle is what needs to hold.

## Acceptance criteria

- [x] `templates/map.yml` cannot render a map claiming a coverage verdict nothing computed — the value
      is absent, `unverified`, or a `{{TOKEN}}` the renderer must fill
- [x] `templates/config.yml` cannot render an `integration:` declaration nobody chose — the line is
      commented out or tokenised, so **absent** means undeclared exactly as its own comment promises
- [x] Each template agrees with the prose that points at it; where the two disagreed, the fix names
      which one was wrong rather than quietly changing both
- [x] The rule behind both is recorded once, where it belongs — a template must not ship a live value
      for a field its own skill says is declared or derived
- [x] A faithful render of each template is exercised and inspected, not reasoned about
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Re-litigating `integration:` as a declaration rather than a derivation** — settled by TASK-021 and
  TASK-023; this task fixes the template that undercuts them.
- Changing what `coverage:` means or how many keys the contract has — TASK-033 and TASK-079 own that.
- Auditing every other template for the same shape. If the rule is worth stating, that sweep is its own
  task; say so rather than widening this one. **Deferred to TASK-126** — the rule was worth stating, so the
  sweep is owed; that task carries the nearest neighbour already found (`mode:` on line 4 of the same
  `config.yml`) and the reason it was not changed here.

## Human test plan

- [x] Render each template into a throwaway repo exactly as its skill instructs, with no manual
      correction. Expected: the resulting `.map.yml` claims no coverage verdict, and the resulting
      `.config.yml` has no `integration:` declaration. Both currently arrive populated.

## Implementation plan

_Drafted 2026-09-16 by `/tasks plan TASK-109` (Plan subagent). Line references spot-checked against
the working tree before writing._

> ⚠ **Acceptance criteria question — unresolved, for the human.** Criterion 1 permits `unverified` as
> the map template's value, while criterion 4's rule — *"a template must not ship a live value for a
> field its own skill says is declared or derived"* — reads, taken literally, as forbidding **any**
> value for `coverage:`, which is derived. The plan below resolves the tension by wording the recorded
> rule as ***a template ships nothing a render cannot make true*** (a schema's own "not determined"
> state is safe; a determination is not), which keeps both criteria satisfiable. **If the stricter
> "absent only" reading was intended for `coverage:`, step 2 changes shape.**

### Step 1 — `skills/tasks/templates/config.yml`: comment the `integration:` line out (CR-5)

Lines 6-12. Replace the live line 12 with a commented one carrying **no copyable value**, and reword
the comment block above it to describe what the template now does. Two details are load-bearing:

- The commented line carries a **choice placeholder** (`# integration: <pr-per-task|single-branch>`),
  **not** `# integration: pr-per-task`. Leaving the concrete value re-creates the trap one keystroke
  away: a renderer that "just uncomments the example" mints the same declaration.
- The existing `# external:` block at the bottom of this same file is already the repo's idiom for
  *a field written only when a condition holds*. This makes `integration:` consistent with its own
  file rather than novel.

This edit also closes a second render path nobody otherwise touches: `skills/tasks/verbs/new.md:117`
(*"Write `tasks/.config.yml` from templates/config.yml"*) is a bare render with **no integration guard
at all**. That is the strongest evidence the template is the side to fix.

### Step 2 — `skills/specs/templates/map.yml`: ship the null verdict, not a computed one (CR-3)

Lines 8-22. `coverage: verified` becomes `coverage: unverified`. `tracked-files-at-scan: 0` and
`coverage-drift: []` become **commented out**. Keep the existing three-key documentation verbatim; add
a note that the template ships `unverified` because that is the only verdict a render can make true
(rendering scans nothing), and that init step 4 overwrites all three keys.

`tracked-files-at-scan: 0` must go in the same edit — it is half of the impossible combination the
finding names, and it is the half that looks most like a measurement.

### Step 3 — reconcile the prose that points at each template, naming which side was wrong (criterion 3)

**Both findings are template-wrong, prose-right.** Named explicitly rather than quietly changed:

- **CR-5** — `skills/tasks/verbs/init.md:31` is the correct rule and **stays verbatim**. But one clause
  at **:30** becomes stale: *"A caller's answer overrides **the template's default** — writing
  `pr-per-task` verbatim over a passed `integration=single-branch`…"* presupposes a live default that
  will no longer exist. Rewrite that clause to point at the commented example (*"the template's
  commented example is not a value to copy; write the caller's answer, or nothing"*), keeping the
  sentence's point about never re-asking a resolved question.
- **CR-5, second** — add one clarifying sentence to the **Present/reconcile** branch (**:32**): a field
  the template declares **commented out** is added to an older config **as its comment block**, never
  uncommented with a value. Reconciliation adds documentation; it does not decide. Without this,
  *"every field the template declares and the file lacks is added, carrying the template's own
  comment"* is ambiguous about a commented field — and that ambiguity is exactly what re-mints the
  declaration.
- **CR-3** — no change to `skills/specs/verbs/init.md`; its step 4 verdict table was right. One caption
  change in `skills/specs/SKILL.md:43-48`, where *"Shape (see templates/map.yml):"* is followed by a
  sample carrying `coverage: verified` / `tracked-files-at-scan: 3884`. After Step 2 the pointer and
  the sample disagree in exactly the way criterion 3 forbids. Fix with one clause — the block shows a
  **populated map after a run**, while the template ships no verdict. **Do not change the sample's
  values**: a real map does carry `verified`, and blanking it teaches the wrong shape.

### Step 4 — record the rule once, in `AGENTS.md` § Conventions (criterion 4)

Insert as a new bullet in **### Code structure & patterns**, immediately after *"A derived state must
never be cached as a decision"* (ends line 176).

Routing, by the five-records table's own test (`AGENTS.md:56-69`):

| Candidate | Test | Verdict |
|---|---|---|
| `docs/glossary.md` | *what a word means* | no — not vocabulary |
| `docs/adr/` | *why we chose it*, **all three** of hard-to-reverse / surprising / real trade-off | **no** — the conjunction fails on hard-to-reverse: what is produced under this decision is prose, and reversing it is editing two template lines. § Conventions' own preamble (97-104) says a rulebook entry whose footprint is the prose it shapes correctly has no record |
| `AGENTS.md § Conventions` | *what we do now*, linted by `/verify-conventions` | **yes** — a standing rule binding every future template change, and cross-skill, which is why neither `skills/specs/` nor `skills/tasks/` can own it |
| `docs/features/*/decisions.md` | *what was agreed*, per-feature | no — this task carries `feature: null` |
| `docs/specs/` | *what the code does*, harvested | no |

Register-on-introduce (`AGENTS.md:282-285`) makes this mandatory **in the same change**, not a
follow-up. Load-bearing clauses for the bullet: the two rules above it govern the *run*, this governs
the *file the run renders from*; a plausible value is minted by a **correct** render, not a mistake,
which is why it survives review where an obvious stub would not; where the schema encodes "nobody
chose" as **absence**, ship the field commented out; where the schema has its own **"not determined"
value**, ship that and never a determination; **not machine-checkable** without a marker convention
and false positives, so it is on the reviewer — the same disposition § Output/prose rules gives
unrendered tokens; and a `{{TOKEN}}` is right in a markdown template and wrong in YAML, where
unrendered it is a parse error rather than a readable gap.

Record it **only** here. Do not also add it to `skills/write-a-skill/` — that is the shipped product
teaching consumers, and a copy there is the restated-list defect two neighbouring bullets exist to
prevent. A product-side rule is its own task.

### Step 5 — (recommended, minimal) keep the map template's *second* renderer honest

`skills/new-project/SKILL.md:97` also renders this template. Add a half-sentence to
**`skills/new-project/LAYER.md` row 27** (`docs/specs/.map.yml`) — not to `new-project/SKILL.md` —
that the seed leaves the coverage keys as the template ships them, because the scaffold scanned
nothing. LAYER.md is the shared inventory both front doors consume, so per the layer-parity rule this
is the only place that does not create a copy; it needs no `adopt-project` twin, since the sentence
constrains creation rather than reconciliation. Strictly optional for the criteria — the template fix
alone satisfies criterion 1 — but it is what stops a scaffolder from "helpfully" filling the verdict.

### Step 6 — say so rather than widening (out-of-scope bullet 3)

**→ spawned as TASK-126.** *Audit every `skills/*/templates/*` for a shipped live value the owning
skill says must be declared or derived.* Name the nearest neighbour found while planning so the sweep
starts with evidence: **`mode: local` on line 4 of the same `config.yml`**. It is defensible today
(init step 2 always resolves `mode`, via arg or a documented detection flow, with a documented
fallback), so it is deliberately **not** changed here — but it is the same shape and the sweep should
adjudicate it. Record that judgement here so the next reader does not redo it.

### Step 7 — exercise and inspect a faithful render of each template (criterion 5)

See § *Render evidence* below. Run **after** steps 1-2 and before close.

### Step 8 — gates

- `bash .github/workflows/skills-lint.sh` (criterion 6). Expect no interaction: checks 1-3 read `*.md`
  (check 3 excludes `templates/` outright), check 4 greps `skills/` for a skill-verb-flag invocation,
  check 5 is advisory, and the `AGENTS.md` edit is outside both linted trees. The lint is a
  **confirmation** here, not a design constraint.
- `/verify-conventions` + `/verify-intent` + `/code-review` on the diff, then `/tasks close`.

### Critical files

| File | Lines | What changes |
|---|---|---|
| `skills/tasks/templates/config.yml` | 6-12 | `integration:` commented out with a choice placeholder; comment block reworded |
| `skills/specs/templates/map.yml` | 8-22 | `coverage: verified` to `unverified`; two companions commented out; note added |
| `skills/tasks/verbs/init.md` | 30, 32 | drop "the template's default"; state that a commented template field reconciles as a comment |
| `AGENTS.md` | after 176 | the new § Conventions bullet (criterion 4) |
| `skills/specs/SKILL.md` | 43-48 | caption: the sample is a populated map, the template ships no verdict |
| `skills/new-project/LAYER.md` | 27 | optional (Step 5) |

Read-but-unchanged, worth the implementer's eye: `skills/specs/verbs/init.md:29-31, 51-65` (the verdict
table and the "always write the three keys" rule the fix must not contradict);
`skills/tasks/verbs/new.md:117` (the unguarded second render path); `skills/tasks/verbs/init.md:31`
(the correct rule — keep verbatim).

### Why the two templates get **different** answers

The two schemas encode "nothing chose this" differently, so one principle lands on different
mechanics. That difference is the substance of criterion 3's demand that the fix name a side.

**`integration:` — encoded as the line's absence.** **Commented out** is the recommendation, and the
only option that makes the file's own comment literally true after a render (*"the line ABSENT (this
comment left in place) means undeclared"*), preserves the documentation the reconcile branch must
carry, matches the existing `# external:` idiom, and is YAML-safe. *Absent entirely* loses the reader's
cue that a decision is outstanding. *A token* is permitted by criterion 2 but is **not valid YAML**
unrendered, and worse implies the field must be filled when the documented honest outcome is to
**omit** it — contradicting `init.md:31` directly. *A live "null" value* invents a fourth enum value,
which is out of scope.

**`coverage:` — encoded as a three-value enum whose catch-all *is* "not established".**
**`unverified`** is the recommendation, exactly true of a bare render — step 4's table makes it the
catch-all for "the run did not establish coverage", and a render establishes nothing. Self-clearing,
since every init run overwrites all three keys. Explicit beats absent because *absent* is defined as
"predates the field", which a file rendered today does not; and it keeps the key that `/roadmap` DV10
and init step 2 read. *Absent* is second choice — honest, but conflates two origins. *A token* has the
same YAML problem and contradicts step 6's "always write the three keys". *`verified`* and
*`not-applicable`* are the defect and a different defect — `not-applicable` is a **positive finding** a
render cannot have made. The two companions are **commented, not deleted**: the prose already defines
absent as *not computed* and `[]` as *a finding*, while `0` is a measurement nobody took — and
commenting keeps the contract's key count untouched, which the out-of-scope line requires.

### Risks, and what could not be determined

- **The lint is not a guard here, and should not be forced into one.** The invariant needs "what the
  skill says about the field", which is prose. A checkable version exists — a marker comment above such
  a key, keyed on the marker rather than a hard-coded skill list, plus a failing case in
  `skills-lint-test.sh` per the repo's rule. **Recommended not here**: it introduces a repo-wide
  convention token to protect two lines, and belongs to the Step-6 sweep where it would guard a
  population instead of a pair. Say this in the convention bullet so the next reader does not
  re-derive it.
- **A commented field and the reconcile branch** is the main behavioural risk of Step 1: a future
  reader of `init.md:32` may treat a commented template field as "not a field the template declares"
  and stop carrying its comment forward. Step 3's added sentence closes this — do not drop it as
  tidy-up.
- **The uncomment trap** — see Step 1. The placeholder must not be softened back to a concrete value.
- **This repo's own artifacts stay untouched.** `tasks/.config.yml` here declares `single-branch` (a
  real choice) and `docs/specs/.map.yml` is a hand-owned map `/specs init` step 6 forbids re-rendering.
  Neither is in this diff. This repo's own config predates the "ABSENT means undeclared" paragraph;
  backfilling it is a reconcile-branch matter, not this task.
- **Coldness is the hard part of criterion 5, not the render.** Per `AGENTS.md:278-280` and
  `skills/populate-tests/SKILL.md` § *Acquiring a cold runner*, this repo's skills are installed at
  **user level**, so every agent on this machine holds the vocabulary; a subagent in-repo and a session
  in an unrelated repo are both measured contaminated. Plan for the drill to be **discounted and said
  to be discounted** if a genuinely cold runner cannot be acquired — a caveat beside a ticked box is
  what that section warns against.
- **Undetermined:** whether the companions should be *commented* rather than *deleted* (both satisfy
  the criteria; the out-of-scope line about key count pushed toward commenting), and whether `mode:` is
  in scope (read as excluded — flagged for the sweep).

### Render evidence (how criterion 5 is satisfied)

Two renders, both inspected on output, neither reasoned about. Everything lands in the session
scratchpad — **outside the repo**, so nothing can be swept up by a bulk `git add`.

**Render A — the worst-case faithful render** (deterministic, fast, run first). Literally the failure
mode the finding describes: an agent that renders the template and overwrites nothing. Copy
`templates/config.yml` to a scratch `tasks/.config.yml` and `templates/map.yml` to a scratch
`docs/specs/.map.yml`, then inspect and paste the output into this task:

- grep for a line-initial `integration:` in the rendered config — **no match** (a match is a fail)
- grep for a line-initial `coverage:` in the rendered map — `coverage: unverified` (`verified` is a fail)
- grep for line-initial `tracked-files-at-scan:` or `coverage-drift:` — **no match**
- `cat` both in full and read as a stranger would: does either look decided?
- Confirm both still parse as YAML.

**Run Render A once BEFORE the edits** to capture the failing baseline — the Human test plan's *"Both
currently arrive populated"* is the claim under test, and a before/after pair is what turns "inspected"
into "exercised".

**Render B — the faithful render *through the verb*, cold** (the drill the Human test plan describes).
Two throwaway fixtures outside the repo:

- **B1 — `/tasks init`, no git, unattended.** A directory with a couple of files and **no git repo**,
  reproducing DRILL-053-6's shape. Brief withholds the change: *"Set this project up for task tracking
  using the /tasks skill. No one is available to answer questions — if the instructions have you ask
  something, write the question out verbatim and continue as if unanswered."* Inspect: the resulting
  `.config.yml` has **no live `integration:` line**, *and* the run's own confirmation step named
  `integration:` as unresolved. The second half matters as much as the first — an absent field nobody
  reported is a different defect.
- **B2 — `/specs init` with no `.map.yml`.** A directory with a small amount of real source, driven
  down step 6's *"No `.map.yml` on disk, render templates/map.yml"* branch. Inspect: the `coverage:`
  value is the one step 4 computed **and stated in the run's output**; if the run computed nothing the
  file says `unverified`, not `verified`. A run that legitimately reaches `verified` passes too,
  provided the output shows the scan set that earned it.
- **Coldness, per `AGENTS.md:280`:** record the command used to obtain the runner, its working
  directory, and the result of the coldness check. If contaminated, say which question is contaminated
  and discount that part rather than ticking the box.

## Progress log

- **2026-09-16 — ⚠ acceptance-criteria question resolved by the user: option A.** The map template ships
  `coverage: unverified` rather than omitting the key. Reasoning accepted: `unverified` is the one verdict a
  bare render can make true, it self-clears on every init run, and it keeps the key `/roadmap` DV10 and
  `/specs init` step 2 both read — where an *absent* key is already defined as "predates the field", which a
  file rendered today does not. The recorded rule is therefore worded *a template ships nothing a render
  cannot make true*, not *a template ships no value*.
- **2026-09-16 — steps 1-5 of the plan applied.** One deviation, recorded below.
- **2026-09-16 — Render A run before and after the edits** (§ Render A evidence).
- **2026-09-16 — `skills-lint.sh` OK (18 skills), exit 0.**

### Deviation from the plan — `init.md:31` was edited, where the plan said keep it verbatim

The plan ruled line 31 *"the correct rule and stays verbatim"*, and the rule itself was indeed right. But its
wording pointed at a thing step 1 deleted: *"omit the line — do not write the template's `pr-per-task`"*,
when the template no longer ships `pr-per-task` at all. Leaving it would have violated criterion 3 — each
template agreeing with the prose that points at it — from the opposite direction to the defect being fixed.
Changed to *"do not fill in the template's commented example"*, which preserves the rule and the sentence's
force while naming what is actually there now. The rule was not weakened and the DRILL-053-6 citation after
it is untouched.

## Render A evidence — the worst-case faithful render

Both templates copied verbatim into a throwaway tree outside the repo, nothing overwritten — literally the
failure mode CR-3 and CR-5 describe. Run **before** the edits to capture the failing baseline, then again
after. Commands and output verbatim.

**BEFORE (baseline — the defect, reproduced):**

```
--- live integration: line in rendered .config.yml ---
12:integration: pr-per-task       # pr-per-task | single-branch
--- live coverage: line in rendered .map.yml ---
20:coverage: verified
--- live companions in rendered .map.yml ---
21:tracked-files-at-scan: 0
22:coverage-drift: []
```

This is the claim the Human test plan makes — *"Both currently arrive populated"* — measured rather than
asserted. A faithful render declared a PR-per-task policy and a blessed coverage verdict, with nothing having
chosen or scanned anything.

**AFTER:**

```
--- live integration: ---
(no match)
--- live coverage: ---
24:coverage: unverified
--- live companions: ---
(no match)
```

**Both rendered files still parse as YAML** (guards against a stray edit; commenting a line cannot break
parsing, but the check is cheap and the failure mode is silent):

```
tasks\.config.yml     -> parses OK; top-level keys: ['mode']
docs\specs\.map.yml   -> parses OK; top-level keys: ['areas', 'coverage', 'ignore']
```

The key list is the substantive result, not the parse: `integration` is **absent** from the rendered config
exactly as that file's own comment promises, and `tracked-files-at-scan` / `coverage-drift` are **absent**
from the rendered map, leaving `coverage: unverified` as the only stamp — a state `/specs init` step 4
overwrites on its first real run.

**Read as a stranger would:** neither file now looks decided. The config poses `integration:` as an open
question via its commented `<pr-per-task|single-branch>` choice; the map says outright that nobody has
checked.

## Drill record — Render B, cold, 2026-09-16

### How the runner was acquired, and the coldness result

| | |
|---|---|
| Command | `claude -p --disable-slash-commands "$(cat <brief>)"` |
| Working directory | a per-drill scratch root outside the repo, holding only `instructions/` (a copy of the skill) and `project/` (the fixture). No agent guide, no `.claude/`, no git history of this repo. |
| Coldness check | **passed, both runs.** B1: *"None. The list is empty… No `tasks` skill, no project-lifecycle skills, nothing preloaded that could tell me what task tracking should look like."* B2: *"None. There is no `.claude/skills` directory…, no skill-invocation tool in my tool list, and no skill was preloaded."* |

Both channels closed per `populate-tests` § *Acquiring a cold runner*: the flag closes the user-level
installed roster, the scratch cwd closes the project guide. **A first attempt run from a guide-free
consumer repo was scoped out of the drill paths and produced no evidence** — the coldness check still
passed there, which is a third confirmation of the recipe. The instructions were **copied** to the scratch
root rather than read in place, so no `git log` of this repo was reachable even by accident.

**Brief hygiene:** neither brief contains the words `integration`, `coverage`, `verified`, `unverified`,
`pr-per-task` or `template` — grepped to zero before each run. The discriminating question was
deliberately indirect: *"for EACH field you wrote, where did that value come from — an instruction that
named it, a file you copied it from, something you measured, or something you chose?"*

**Limitation, recorded rather than smoothed over:** writes were refused by the sandbox in both runs, so
the rendered files exist as the runner's verbatim reported contents, not as files on disk. That is weaker
than an on-disk artifact. It is not fatal to the finding, because what is under test is *which value the
run decided to write and why*, and the provenance tables answer that directly. Render A (below) covers the
on-disk half.

### B1 — `/tasks init` on a fixture with no git, no user

**Result: pass, on both halves.** The config the run produced carries **no live `integration:` key**, and
the run's closing report named the field unresolved, exactly as `init.md` step 5 requires:

> *"Unresolved field: **`integration:`** — no `integration=` arg was passed and no user was available to
> ask, so the line was left out (its comment block carried forward). Consumers apply the `pr-per-task`
> default; `/adopt-project` can backfill it."*

The provenance table is the evidence that the **fix** drove this rather than luck — the runner attributed
the field to an **instruction**, quoting the post-fix wording, where the pre-fix template would have
yielded "copied from a file":

> *`integration:` — left as the template's commented block, no live value — **Instruction**, `init.md`
> step 3: "With no `integration=` and nobody asked, omit the line — do not fill in the template's commented
> example … leave the field out and report it unresolved."*

For contrast, the same table attributes the file skeleton and `mode: local` to **copied** and **measured**
respectively — so the runner was discriminating between the categories, not labelling everything the same.

### B2 — `/specs init` on a fixture with three tracked files of real source

**Result: pass.** The run reached `coverage: verified` with `tracked-files-at-scan: 3` — and that is the
**correct** outcome, not a regression. It is an *earned* verdict: the run scanned, printed the area table,
mapped both source files, reconciled the one unmapped file into `ignore`, and stated the scan set that
earned it. The defect this task fixes is a verdict **nothing computed**; a verdict something did compute is
the feature working.

The two halves together are a stronger test than either alone: **Render A proves the bare template claims
no verdict; B2 proves a real run still claims the verdict it earns.** Nothing was broken on the way.

### What the drill found that the author did not — two defects in this very change

Both were found by the drill, both fixed here, and both are the same shape as the defect under repair —
which is the argument for having run it at all.

1. **The create branch never said to keep the comment block** (found by B1, listed under *"things I
   inferred"*): *"I read 'omit the line' as 'write no live `integration:` key' and kept the commented
   documentation. **The create branch never states this directly.**"* The runner got it right by inference —
   the thing this repo forbids. Had it inferred the other way it would have deleted the comment that
   *defines* the undeclared state, defeating criterion 2. Fixed: `init.md:31` now says the comment block
   stays, and says why.
2. **Both templates carried prose about the template, which is false once rendered** (found by B2): *"The
   template's 'This template ships `unverified`…' and 'The two companions stay COMMENTED OUT until it does'
   describe the un-rendered template state and are false once written. Nothing in the instructions says
   whether a render keeps or drops them."* This is the task's own rule violated in prose instead of in a
   value — a maintainer's note shipped into a consumer's file. Fixed by deleting the transient notes from
   **both** templates, folding the one fact not already documented into `map.yml`'s permanent key docs, and
   leaving the maintainer-facing rule where it belongs, in `AGENTS.md` § Conventions. **B1's runner copied
   the same prose without objecting**, so only B2's reading exposed it; a single drill would have missed it.

### Findings outside this task's scope — routed, not fixed here

Neither run's remaining findings belong to TASK-109; they are recorded so they do not evaporate:

| # | Finding | Disposition |
|---|---|---|
| D-1 | `triage.md` step 7 defines the empty render for `{{INPROGRESS_LIST}}` and the omit-when-empty sections, but says nothing for `{{TREE_VIEW}}` — the runner invented `_None_` | **Duplicate of TASK-067**, which owns the zero-item render. Linked, not re-filed |
| D-2 | Three steps tell the run to *ask the user* and supply **no question wording** — `new.md` mode detection step 2, `init.md` step 3's `integration:`, `SKILL.md` § Shape detection step 4 | filed as **TASK-127** (`DRILL-109-1`) |
| D-3 | `/specs init`'s **blessing has no wording and no mechanism**, and nothing says what to do when it is not forthcoming | filed as **TASK-127** (`DRILL-109-2`) — same root cause as D-2 |
| D-4 | `/specs init` targets *"~5–20 areas"* with no guidance for a codebase below the floor; the fixture had two capabilities and the runner declined to pad | filed as **TASK-129** (`DRILL-109-4`) |
| D-5 | `/specs init` step 4's two stated remedies for an unmapped file **omit the `ignore` exit** that the paragraphs four lines below define, and that step 6 then expects — an internal contradiction the runner followed the paragraphs to resolve | filed as **TASK-128** (`DRILL-109-3`) |
| D-6 | `templates/map.yml` ships five `ignore:` globs (`**/bin/**`, `**/obj/**`, `**/node_modules/**`, two test patterns) that a faithful render carried into a Python project where none match | recorded on **TASK-126**'s sweep as adjacent evidence; not separately filed |

## Close gate — three axes, reported side by side

Per `AGENTS.md` § *Independent review axes are reported side by side and never merged or reranked*, each
verdict stands on its own. They disagreed usefully: **standards found a blocker while fidelity found
none**, and correctness found two HIGH defects both other axes passed over.

| Axis | Verdict |
|---|---|
| standards — [[verify-conventions]] | 1 blocker (found and fixed in-pass), 1 suggestion, 1 close call cleared |
| fidelity — [[verify-intent]] | no *missing*, no *wrong*; 2 scope-creep items; 2 criteria unverifiable from the diff |
| correctness — [[code-review]] | **7 findings, 2 HIGH — all 7 addressed** |

### standards

**🛑 Blocker, fixed in-pass.** The dashboard's in-progress row was rendered `[~] … **in-progress**`;
`triage.md:34` specifies `[ ] … ← in-progress`. Producing output the owning verb would not produce is a
hand-edit wearing a regeneration's clothes — and it is the *same* defect TASK-067 exists for, committed
while regenerating a file whose verb does document the shape.

**Close call, cleared and recorded so the judgement is auditable:** `# integration:
<pr-per-task|single-branch>` reaches a consumer's repo unfilled, which brushes against § *Ship no
unrendered placeholder tokens*. Read as **choice notation inside a comment** rather than a substitution
token — this repo's substitution marker is `{{TOKEN}}`, and criterion 2 explicitly permitted "commented
out or tokenised".

### fidelity

Criteria 1-4 met against the diff rather than against their checkboxes. Criteria 5 and 6 recorded
**unverifiable from the diff** — their evidence is a drill record and a run result, neither of which is a
hunk. Two scope-creep items, both legitimate but uncovered by any criterion: the `LAYER.md` coverage-keys
sentence (**since reverted** — correctness independently found it contradictory, see F3), and the
spawn/intake artifacts sharing the working tree.

### correctness — the axis that earned the gate

Two HIGH findings would have shipped a regression, and **neither was visible to the other two axes**: the
change was faithful to its criteria and compliant with the rulebook while breaking a contract one layer
out.

| # | Severity | Finding | Fix |
|---|---|---|---|
| F1 | HIGH | The reconcile branch's new rule was unconditional, so it would swallow a caller-supplied `integration=` — and that is the branch [[adopt-project]] **always** lands on, since an adopted repo has a config by definition. The `Presenter` case this whole chain exists to fix is exactly that branch | scoped the sentence to *"when nothing has answered it"*, and stated that a caller's arg still writes a live key here |
| F2 | HIGH | Shipping `integration:` as a **commented** line makes the field textually present in every config the skills create. `LAYER.md:80` defines the declaration probe as answerable by *"anybody with a grep"* and `:93` says a carried declaration is **settled, do not ask** — so the survey would report settled, the frontier round would never ask, and `adopt-project:386`'s backfill would never fire. This **generalises** the defect from configs predating the field to every repo these skills scaffold | stated the contract on the **reading** side: `LAYER.md` § *Carries means a live, uncommented key*, matching `^integration:` anchored and reading a commented line as absent |
| F3 | MED | The `LAYER.md` coverage-keys sentence contradicted `/specs init`, which must write all three keys from a real scan — and the adopter walks that row against a repo **with** code. It also forced `unverified` where an empty scan set in a repo with no behavioural code is `not-applicable`, a distinction init.md calls *"the whole check"* | reverted the sentence |
| F4 | MED | The new `specs/SKILL.md` caption claimed the template *"ships no verdict"* while the same commit made it ship `coverage: unverified` — and `unverified` **is** one of the three verdicts | reworded to *"makes no determination"* |
| F5 | MED | The commented companion keys would become permanent litter: step 6 is an **edit** whose rule is *"what survives is every line you did not deliberately change"*, so a real run would leave `# coverage-drift: []` sitting beside a populated live list | dropped both commented companions; the permanent key docs already define their absence |
| F6 | LOW | Markdown lazy continuation put the closing paragraph **inside** the second sub-bullet, scoping the reviewer-disposition clause to the specs case alone — in a repo whose product is prose an agent reads | blank line inserted |
| F7 | LOW | The rule said *"the two live cases encode it differently"*, but `map.yml` uses **both** shapes at once — a value for `coverage:`, absence for its companions. A reader applying it to a mixed schema could mint `tracked-files-at-scan: 0` again, the exact value it cites as the original defect | restated the rule as **per field, not per file** |

**F1 and F2 are the same shape as the defect under repair, arriving one layer out** — a writing-side change
that broke a reading side. `AGENTS.md` § *A format one skill reads is a contract the writing skill must
state too* is the rule that names it, and this change violated it while fixing its sibling.

**Worth recording about the gate, not just the findings.** Correctness was stopped on its first run over
the full 845-line diff and re-run scoped to the six product files. The scoped run is what produced all
seven. A gate run over a diff mostly composed of task prose is a gate looking in the wrong place.
