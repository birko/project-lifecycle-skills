---
id: TASK-069
parent: STORY-016
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: in-progress
priority: P1
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-054-1, DRILL-054-2, DRILL-054-3]
pr: null
github-issue: null
jira-key: null
---

# The ADR bar contradicts the split rule, and `close.md` contradicts the axis rule

## Context

**From a cold read of `docs/adr/` on 2026-08-22** — the human test plan of TASK-054, run by a fresh agent
with the author's conclusions withheld. Three findings, filed together because the first two are one
argument and the third is what the first two let through.

### DRILL-054-1 — the bar and the split disagree, and nothing says which wins

Both rules live in `skills/domain/SKILL.md`.

**The bar** requires all three of *hard to reverse*, *surprising without context*, *the result of a real
trade-off* — and its fail table's first row reads:

> | Hard to reverse | changing your mind later costs a line | **a prose rule in one skill file** |

**The split** says: *"A convention carrying its own trade-off inline is the inverse of this… Where you find
one, the fix is to write the record and trim the line."*

**Almost every `AGENTS.md § Conventions` bullet is a prose rule whose reversal costs a line.** So the bar
forbids recording it while the split instructs you to record any such bullet that grew an argument. The
two rules cover the same population and give opposite answers.

**This is not academic — it is the defect that produced the other two findings.** Writing TASK-054's
backfill, the author declined one record on the hard-to-reverse test and kept a structurally identical one,
because both readings were available. The cold read caught the inconsistency; the contradiction is why it
was reachable.

**The cold reader's proposed resolution, which is worth starting from rather than reinventing:** for a
*convention*, measure "hard to reverse" by **what was produced under the rule** — stamped fields, migrated
files, history that now exists — not by the cost of editing the sentence. Applied to the current directory
that test keeps 0007 (every reference points into `tdd/refactoring.md`) and 0008 (`theme:` stamped across
the tree) and drops the deleted 0006 (nothing was produced under it). It also explains 0001 and 0004, whose
own records already argue in exactly those terms.

**A second, smaller tension in the same family**, worth settling in the same breath:
`AGENTS.md § Output / prose rules` says *"State the rationale for a non-obvious rule inline, briefly."* The
split says a trade-off inline is a defect. Both are defensible — *brief rationale in, full trade-off out* —
but nobody wrote that reconciliation down, and it is the exact judgement the trimming exercise turns on.

### DRILL-054-2 — the axis rule counts three; the step it governs still says two

`AGENTS.md` and the § Conventions bullet name **three** passes at `close` step 5b — standards
([[verify-conventions]]), fidelity ([[verify-intent]]), correctness ([[code-review]]). The verb itself
still says two:

| `skills/tasks/verbs/close.md` | Text |
|---|---|
| ~106 | "**The two axes** are reported side by side and never merged or reranked into one list." |
| ~109 | "so: **two verdicts**, each with its own findings and its own severity ordering" |
| ~128 | "**State both gate verdicts** in the question" |

…while the same step's own heading reads *"Standards + fidelity + correctness — the merge gate"* and lists
three passes below it. `verify-intent` was added as a third axis (TASK-046 to 049) and the arity prose was
never updated.

**And step 5b runs a conditional fourth**, [[security-review]], with no verdict slot at all. The deleted
ADR 0006 had warned about precisely this — *"it puts a real obligation on whoever adds a fourth axis: it
needs its own verdict slot"* — while the **third** axis had never got one.

**This is a live defect in the gate every task in this repo passes through.** A closer following `close.md`
literally reports two verdicts and has documented permission to omit one.

### DRILL-054-3 — `LAYER.md` claims ADRs need no reconciliation, and this read disproves it

`skills/new-project/LAYER.md`'s `docs/adr/` row (added at TASK-053) says:

> Present → **leave it, and it is current**: each record's parts are checked when that record is written, so
> there is no sweep to run and nothing to reconcile.

The cold read found three drifts a parts-check cannot catch, because none is a missing part:

- **0002's Decision sentence was false** — *"One Bash script… and no other executable code in the repo"*,
  in a repo with seven scripts, contradicted by its own Consequences two paragraphs later.
- **0006's rule contradicted `close.md`** (DRILL-054-2).
- **0001's *"Rule it produced: none yet"*** was stale — the rule hardened into a bullet the same day.

All three are now fixed. The point that survives is the **claim**: a record's four parts being present is
not the same as the record still agreeing with the rule and the code it cites. That is exactly the
distinction `AGENTS.md § Conventions` draws elsewhere — *"An owner verb reconciles; it does not assume…
Existing is not current"* — and the ADR row asserts the opposite.

**The honest fix may be to narrow the claim rather than build a sweep.** Nobody wants adoption auditing
whether someone's ADR still matches their code; that is the content audit `LAYER.md` deliberately refuses.
But *"nothing to reconcile"* overstates it, and TASK-063 is already reopening what that row can honestly
promise.

## Acceptance criteria

- [ ] The bar-versus-split contradiction is resolved **in `skills/domain/SKILL.md`**, with the losing reading explicitly disowned so it cannot be picked again
      — ⚠ **NOT MET.** Partly done: the fail-table row that stated the losing reading is rewritten, the scope clause widened, the mirror turned into a pointer. But the cold read found three ambiguities that still hand the verdict to the reader — see below. The contradiction is narrowed, not resolved.
- [ ] The resolution is tested against the current directory: state, per record, whether it still clears the bar under the new reading — including the already-deleted 0006 and the already-declined flag rule
      — ⚠ **NOT MET as a *test*.** A table was produced (below) but a cold reader applying the same rule reached different verdicts on 0003, 0007 and 0001, so the table records the author's reading rather than the rule's. That is the criterion's whole point.
- [x] The brief-rationale-inline versus trade-off-out tension is reconciled in one sentence, wherever it belongs
- [x] `close.md`'s axis arity matches reality: three named passes, plus a stated answer for the conditional [[security-review]] — either its own slot or an explicit reason it has none
- [x] No remaining text in `close.md` says "two axes" / "two verdicts" / "both verdicts"
- [x] `LAYER.md`'s `docs/adr/` row no longer claims there is nothing to reconcile, **or** states precisely what it does and does not check — coordinated with TASK-063, which is reopening the same row's neighbours
- [x] `bash .github/workflows/skills-lint.sh` passes

### The resolution — "hard to reverse" reads differently for a standing rule (AC 1, 3)

`skills/domain/SKILL.md` now says, before the fail table is applied to any convention: **for a standing
rule, "hard to reverse" means what was *produced* under it, not the cost of editing the sentence.** The
literal reading disqualified nearly every rulebook entry while the split rule demanded a record for any
that grew a trade-off — both readings available, which is precisely how one person applied the bar two ways
in one sitting. The measured instance is named in the rule itself.

The useful corollary is stated too: **length is not evidence.** A 200-word bullet that produced nothing
fails; a one-line bullet that stamped a field across the tree passes.

**The split gained the precondition it was missing:** it assigns *where* reasoning goes and never licenses a
record — run the bar first. And when the bar fails, the reasoning **stays in the bullet and the bullet says
so**, naming the failed test, which is the same *decline out loud* discipline the bar already demanded.

**The `§ Output / prose rules` tension is reconciled in one sentence** (AC 3): brief rationale — *why this
rule* — stays inline always, because a rule an agent does not understand is one it routes around. What moves
out, and only when the bar passes, is the **trade-off**: *why not the other options*.

### Applied to the whole directory (AC 2)

| Record | What exists that reversal would not undo | Verdict |
|---|---|---|
| 0001 unattended close merges | commits an autonomous loop already merged to `main` | **clears** |
| 0002 Bash lint harness | the harness, its 36-case suite, a CI workflow, a stack rule written around the exception | **clears** |
| 0003 `AGENTS.md` canonical | the bridge file and a CI assertion policing it | **clears** |
| 0004 `integration: single-branch` | ~100 commits of linear history | **clears** |
| 0005 reimplement, don't port | five reimplemented stories; a licensing line not crossed | **clears** |
| 0007 one owning file per vocabulary | the reference graph pointing into `tdd/refactoring.md` — reversal means migrating readers | **clears** |
| 0008 declare the ranking key | `theme:` stamped across STORY frontmatter | **clears** |
| ~~0006 review axes~~ (deleted) | nothing | **fails — deletion confirmed** |
| flag-covers-every-point (declined) | a contract table, i.e. prose only | **fails — refusal confirmed** |

**The new reading is consistent with both earlier decisions and kills no survivor** — which is the result
that matters, because a reading invented to justify a deletion would be worthless. It also **strengthens
0004**, the one the cold read called marginal on exactly this test: a linear history is durable, so it
clears cleanly rather than barely.

### The live defect (AC 4, 5)

`close.md` step 5b no longer hard-codes a count. It reports **one verdict per pass that ran**, names the
three unconditional passes, and gives [[security-review]] its answer: **its own verdict when it runs, and
an explicit *not applicable* line with the reason when it does not** — silence cannot be told apart from a
skip. The rationale explains why it is a rule and not a number, without quoting the stale strings, so a
grep for them stays clean.

### The over-claim (AC 6)

`LAYER.md`'s `docs/adr/` row no longer says *"nothing to reconcile."* It now says adoption has **no shape**
to reconcile and runs no sweep, then states plainly that this is **narrower than "current"**: a record can
carry all four parts and still cite a rule that changed or a decision the code no longer matches, which a
parts-check cannot see because nothing is missing. Content goes to `/domain`'s cross-reference pass, per the
same file's presence-versus-content line, with the measured instance cited.

**The glossary row was checked and deliberately left alone.** It uses similar wording but already carries
the distinction — it hands content currency to `/domain` in the same cell — and for free prose "no shape to
be outdated" is simply true. Narrowing it further would be churn. Coordinated with TASK-063, which is
reopening what the neighbouring rows can honestly promise.


## Out of scope

- Re-writing the records themselves. The three drifts the cold read found are already fixed under TASK-054; this task is about the rules that let them happen.
- The two records the cold read says are **owed** — **TASK-070**.
- The lint's blindness to `docs/` — **TASK-071**.
- Deciding whether 0004 should survive. The cold read called it marginal and said keep; if the new reading kills it, that is this task's second criterion doing its job, and the deletion belongs here.

## Human test plan

- [ ] Apply the resolved bar to all seven surviving records without reading their verdicts first; confirm the outcome is stable rather than re-argued each time
- [x] Run `/tasks close` on any task and confirm the number of verdicts reported matches the number of passes run
      — verified on this close: three passes ran, three verdicts reported, and [[security-review]] got its explicit *not applicable* line rather than silence
- [ ] Hand the resolved bar to a fresh reader with one borderline candidate and confirm they reach the same verdict the rule intends — a bar that needs its author present has not been fixed

**Parked at `review`: items 1 and 3 require a reader who is not me.** Both ask whether the resolved bar
produces a *stable* verdict for someone who has not seen the verdicts — and I wrote the table above, so my
re-deriving it proves nothing. This is the same asymmetry the TASK-053 and TASK-054 drills established: the
author cannot test whether a rule is followable without knowing what it was meant to say. A cold read with
the verdict table withheld is what clears these.

### Cold read #2, 2026-08-22 — the fix does not pass its own test

Third cold run of the session, briefed to apply the resolved bar to every record and every trade-off-bearing
bullet, with the verdict table withheld. Verdict: **"more stable than the literal reading it replaced, and it
still does not settle a large minority of cases without the author present."** It decided about half the
candidates and handed back the rest.

**Three ambiguities, each independently fatal to stability:**

1. **"Produced" is undefined for a repo whose product is prose.** The sentence *"a rule that has produced
   nothing but its own wording is reversible"* has no boundary here, because everything this repo produces is
   wording. Two readings, opposite directories: count downstream prose edits and `0007` clears along with four
   declined bullets; require non-prose artifacts and `0007` fails along with `0005`'s main leg. **Same
   sentence, both verdicts.**
2. **Prospective versus retrospective is never chosen.** *"What **now** exists"* is retrospective, but the
   skill fires *during* a grill or design — so at decision time **every** decision fails the test, nothing
   having been produced yet. `0001` was written the day its decision was taken. The rule either demands a
   forecast it does not constrain, or forbids the record at the one moment the reasoning is fresh.
3. **The revision made the false-negative direction worse.** A rule about *not* persisting, *not* moving,
   *not* creating, *not* merging produces nothing **by construction** — and the four longest bullets in
   § Conventions are all that shape. So the bar's letter now mandates precisely the outcome the companion rule
   calls the defect: *"the rule list becomes an essay collection."*

**The inconsistency this task existed to kill is reproducible today.** Three structurally identical rules —
reject the tidier arrangement because a second copy diverges silently — with all three possible treatments:
`ADR 0007` (recorded), *independent review axes* (declined out loud), *nothing goes in a generated file*
(no record, no clause, and stronger durable production than 0007). Test 1 does not discriminate between them,
so the discriminator is still the author's intuition.

### Fixed in this pass — the unambiguous half

- **The fail table no longer contradicts the gloss.** It stated the losing reading as its example while prose
  three paragraphs later disowned it — and by this repo's own § Output/prose rules the *table* is what an agent
  branches on. Row rewritten; the correction is no longer buried in prose.
- **The scope clause is widened.** It said *"for a standing rule"*, yet `0001`, `0004` and `0005` are not
  standing rules and each clears only on this reading. A clause that excluded them disowned three records.
- **The `AGENTS.md` mirror is now a pointer**, not a second copy that taught only the disowned reading.
- **The ADR 0001 pointer exists.** `0001`'s header claimed *"that bullet points back here"* and no such
  pointer was in `AGENTS.md` — an earlier edit had silently failed to match. Exactly the staleness that
  header was congratulating itself for having fixed.
- **`docs/adr/0000-retired.md`** now records why `0006` is missing. *Never reused* means a deletion leaves a
  permanent gap, and from the directory alone nobody could tell declined from deleted from lost — the same
  *decline out loud* failure one level up. `domain` § Shape gained the rule.

### Blocked on a decision that is not the implementer's

The three ambiguities above cannot be closed by better wording; each needs a **choice**, and two of them
**change existing verdicts**:

- **Define "produced" for a prose repo.** The cold reader's proposal — *state a future reader would find and
  have to reason about even after the rule is deleted*, explicitly excluding a pointer or a restatement —
  is coherent and testable. It also **inverts two settled outcomes**: recorded verdicts in closed task files
  would count, bringing the review-axes rule back in (un-retiring `0006`), while `0007` would fail and be
  withdrawn. Adopting it means accepting that flip.
- **Choose prospective or retrospective**, and if prospective, say what a forecast may rely on.
- **Decide whether hard-to-reverse is the right first test for a convention at all**, given that it
  structurally excludes every *don't-do-X* rule. This is the one that might mean redesigning the bar rather
  than glossing it.

Not resolved here deliberately: picking any of them silently would repeat this task's own defect at a larger
blast radius, with two records flipping on an implementer's reading.

## Implementation plan

_Populated by `/tasks plan TASK-069` — leave empty until then._
