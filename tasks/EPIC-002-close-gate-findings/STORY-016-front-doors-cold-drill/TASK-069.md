---
id: TASK-069
parent: STORY-016
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
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
- [ ] The resolution is tested against the current directory: state, per record, whether it still clears the bar under the new reading — including the already-deleted 0006 and the already-declined flag rule
- [ ] The brief-rationale-inline versus trade-off-out tension is reconciled in one sentence, wherever it belongs
- [ ] `close.md`'s axis arity matches reality: three named passes, plus a stated answer for the conditional [[security-review]] — either its own slot or an explicit reason it has none
- [ ] No remaining text in `close.md` says "two axes" / "two verdicts" / "both verdicts"
- [ ] `LAYER.md`'s `docs/adr/` row no longer claims there is nothing to reconcile, **or** states precisely what it does and does not check — coordinated with TASK-063, which is reopening the same row's neighbours
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Re-writing the records themselves. The three drifts the cold read found are already fixed under TASK-054; this task is about the rules that let them happen.
- The two records the cold read says are **owed** — **TASK-070**.
- The lint's blindness to `docs/` — **TASK-071**.
- Deciding whether 0004 should survive. The cold read called it marginal and said keep; if the new reading kills it, that is this task's second criterion doing its job, and the deletion belongs here.

## Human test plan

- [ ] Apply the resolved bar to all seven surviving records without reading their verdicts first; confirm the outcome is stable rather than re-argued each time
- [ ] Run `/tasks close` on any task and confirm the number of verdicts reported matches the number of passes run
- [ ] Hand the resolved bar to a fresh reader with one borderline candidate and confirm they reach the same verdict the rule intends — a bar that needs its author present has not been fixed

## Implementation plan

_Populated by `/tasks plan TASK-069` — leave empty until then._
