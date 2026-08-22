---
id: TASK-054
parent: STORY-003
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-21
depends-on: [TASK-052]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Backfill the decision records this repo already owes

## Context

**A group task, deliberately.** These are individually small, share one shape, and splitting them would
bury the connection that makes them cheap to write together — the repo's own *group rather than
fragment* rule.

`AGENTS.md § Conventions` says an ADR that hardens into a standing rule gets a one-line entry pointing
back at it, with the ADR carrying the trade-off and the alternatives. This repo has the **inverse**: rule
entries carrying their reasoning inline, because there was nowhere to put it. Eight records are owed.

**Four named by STORY-003**, all pre-dating `docs/adr/`:

| # | Decision | Why it clears the three-part bar |
|---|---|---|
| 1 | Bash + a CI harness in a repo whose stack rule says *markdown only, no new language without an ADR* | the stack rule explicitly demands one; hard to reverse once CI depends on it |
| 2 | `AGENTS.md` canonical with a one-line `CLAUDE.md` import bridge | surprising without context — every reader meets `CLAUDE.md` first |
| 3 | `integration: single-branch` for this repo | hard to reverse (history shape), and it hid the TASK-050 defect |
| 4 | Reimplementing the yolobox ideas against our artifact model rather than porting them | the trade-off that defines EPIC-001 |

**Four more created 2026-08-20/21**, each currently a `§ Conventions` bullet carrying its own trade-off:

| # | Standing rule | The trade-off it is carrying inline |
|---|---|---|
| 5 | Independent review axes are never merged or reranked | one ranked list is easier to read, and that ease is the harm |
| 6 | A shared vocabulary has one owning file, expanded in place | the two consumers use the list for different jobs, which is what makes a copy look justified |
| 7 | A flag declaring an absent capability must cover every point needing it | scoping it narrowly looks safer and blocks in the untested configuration |
| 8 | A ranking key that cannot discriminate must say so | silent degeneracy is indistinguishable from the key having worked |

**The list was short by one, found while drilling TASK-052.** The decision that
`close --unattended` **merges** is a ninth owed record, and the strongest candidate of the set: unlike
these eight it has a real decider, an explicit question, and two rejected alternatives on record. It is
already written — `docs/adr/0001-unattended-close-merges.md`, produced as TASK-052's drill — and it is
the only **contemporaneous** record here, so use it as the shape the eight retroactive ones aim at.

Two consequences for this task: the count below is **eight remaining, nine total**, and numbering starts
at `0002`.

## Acceptance criteria

- [ ] Eight further records exist under `docs/adr/` (numbered from `0002`), each carrying context, the
      decision, the **rejected** alternatives, and consequences
      — ⚠ **NOT MET as written: six stand (0002–0005, 0007, 0008).** One declined at writing under AC 5; one more (0006) written, then deleted after the cold read found it failed the same test. Not softened; see below.
- [x] Each is **dated honestly** — the date the decision was made, not the date it was written down, with
      the retroactive authorship stated so nobody reads it as contemporaneous
- [x] Each of rules 5-8 has its `§ Conventions` bullet **trimmed to the enforceable one-liner plus a
      pointer**, with the trade-off moved into its record — the split the convention itself mandates
      — rules 5, 6 and 8 trimmed. **Rule 7's bullet is deliberately unchanged**: its record was declined, so
      there is nothing to point at and its reasoning has nowhere else to live. Trimming it would have
      deleted the rationale rather than relocating it.
- [x] Records 1-4 are written from evidence in the repo (commits, `EPIC.md` bodies, `.config.yml`), and
      where the reasoning cannot be reconstructed the record **says so** rather than inventing a rationale
- [x] Every record clears the three-part bar; if one does not on a closer read, it is **not written**, and
      the task says which and why
- [x] `bash .github/workflows/skills-lint.sh` passes

### Bar applied first, before anything was written (AC 5)

| # | Decision | Hard to reverse | Surprising | Real trade-off | Outcome |
|---|---|---|---|---|---|
| 1 | Bash lint harness in a markdown-only repo | yes — CI depends on it | yes — the stack rule forbids a language without an ADR | yes — no gate / Node / inline YAML | **ADR 0002** |
| 2 | `AGENTS.md` canonical + `CLAUDE.md` bridge | yes — CI asserts the bridge; every reference moves | strongly — readers meet a one-line file first | yes — CLAUDE-only / duplicate / AGENTS-only | **ADR 0003** |
| 3 | `integration: single-branch` | yes — history shape cannot be retrofitted | yes — the documented default is the opposite | yes — and it hid the TASK-050 defect | **ADR 0004** |
| 4 | Reimplement yolobox rather than port | yes — the prose is now ours | yes — why not copy a working set? | yes — copy / wholesale-adopt / glossary-only | **ADR 0005** |
| 5 | Review axes never merged | marginal — gates and consumers now depend on three verdicts | yes — one ranked list is the obvious design | yes — merge / weight / report-failures-only | **ADR 0006** |
| 6 | One owning file per shared vocabulary | yes — moving a list breaks its readers | yes — differing jobs make a copy look justified | yes — copy / neutral home / partial copy | **ADR 0007** |
| 7 | A flag must cover every point needing it | **no** | mildly | **no** | **DECLINED** |
| 8 | Declare a ranking key; announce degeneracy | yes — a frontmatter field now carries it | yes — "degeneracy is fine, silence is the defect" | yes — infer / row-number / skip silently | **ADR 0008** |

### Why #7 was declined — naming the tests it failed

The human test plan asked for the weakest of the eight to be argued against the bar out loud, and this is
it. **`--unattended` must define behaviour at every step that would otherwise ask** fails two of three:

- **Hard to reverse — fails.** It is a discipline about how to document a flag. Reversing it costs edits to
  one table in one verb file, which is the bar's own stated fail condition (*"changing your mind later costs
  a line"*).
- **Real trade-off — fails, and this is the decisive one.** The bar fails when *"there was no rejected
  alternative — the only option that worked."* The supposed alternative here, scoping the flag to one step,
  **shipped and was broken** (TASK-050: the merge question still fired on `pr-per-task` projects). That is a
  defect, not a road not taken. A record whose rejected alternative is "the bug we fixed" cannot prevent
  re-litigation, because nobody will argue for the bug.
- Surprising without context — partially passes. Narrow scoping does look safer. Not enough on its own; the
  bar is a conjunction.

It stays a `§ Conventions` rule with its reasoning inline, and that is the correct home: the reasoning is
*explanation of an enforceable rule*, not a settled trade-off between live options.

**This is the bar working, and writing it anyway was the real risk.** `domain` says a `docs/adr/` nobody
reads is worse than none, because the next reader learns the directory is noise. Eight was a count guessed
before the bar was applied — treating it as a target would have been the quiet waving-through the plan
explicitly warned against.

### Dates are honest, and provenance is graded (AC 2 + AC 4)

Every record carries the date the decision was **made**, from `git log`, not today. Records 0002–0004 all
trace to `1886df7` (2026-08-18); 0006 and 0007 to 2026-08-21; 0008 to 2026-08-20.

The **Decided by** line grades its own reliability rather than flattening it, which AC 4 required:

- **0002, 0003, 0004** — *"reconstructed … from the repo's own evidence. No contemporaneous discussion
  survives."* The reasoning is inferred from what the commit did and what rule it had to satisfy. 0004 goes
  further and says the config records a rationale for `mode:` but **not** for `integration:`, so that half is
  genuinely reconstructed.
- **0005** — retroactively *filed*, not invented: the reasoning was written into `EPIC-001` § Provenance at
  the time, and the record consolidates it. Says so explicitly.
- **0006, 0007, 0008** — the reasoning existed as the § Conventions bullet being trimmed, so these are
  relocations. Each names the task it came from (049, 048, 044).

Nothing reads as contemporaneous except `0001`, which is.


## Out of scope

- The ADR shape and the three-part bar — TASK-052 owns both; this task applies them.
- Any decision made *after* this task is picked. Those go through `domain` normally; a backfill that
  keeps growing never closes.
- Consumer-repo ADRs. Their decisions are theirs.

## Human test plan

- [x] Read records 5-8 cold and confirm each explains a rule whose § Conventions line no longer carries
      its own justification — the two halves must compose without repeating
- [x] Confirm no record reads as contemporaneous when it was written retroactively
- [x] Pick the weakest of the eight and argue it against the three-part bar out loud; if it fails, delete
      it and record that it failed. A backfill that quietly waves the bar through discredits the bar

### Cold read, 2026-08-22 — the third item did not pass, which is the point

Run by a fresh agent with the author's conclusions withheld: no access to `tasks/`, no `git log` subjects
or bodies (the commit message states the whole refusal), dates only. It was asked to find the bar and the
split **itself**, and to answer the inverse question — *is any bullet still owed a record?* — so the
refusal of #7 could be contradicted rather than confirmed.

**Items 1 and 2 passed.** The halves compose; each trimmed bullet is followable alone. Essentially nothing
was lost — the reader checked each dropped clause against the records and found them relocated, not
deleted, with one exception now fixed (0007's bullet had dropped *"for a repo that documented nothing"*).
And *"no record overstates what it knows"*: not one reads as minutes when it is a reconstruction.

**Item 3 failed, and the failure was mine.** Asked to pick the weakest and argue it, the reader chose
**0006 (review axes)** and concluded it does not clear the bar. Its argument is the table this task should
have built — *what was produced under each decision that reversal cannot undo*: 0001 → commits already
merged to `main`; 0004 → a linear history; 0007 → every reference into `tdd/refactoring.md`; 0008 →
`theme:` stamped across the tree; **0006 → nothing.**

**The inconsistency is the real finding.** #7 was declined because it is *"a discipline about how to
document a flag, and reversing it costs one table edit."* 0006 is a discipline about how one step prints
its output, reversible with two paragraph edits — and it was kept, with the bar's weak leg noted and waved
through (*"I'd say ✓ marginally"*). Same test, two answers. A bar applied inconsistently is not a bar.

**Acted on, per this plan's own instruction:** `0006` deleted, its weighted-merge argument — the sharpest
thing in it — folded back into the § Conventions bullet, and the bullet now states out loud why it carries
its reasoning. **`0006` is retired and must not be reused**; the gap is deliberate.

**The refusal of #7 survived, and the reader improved it.** It independently found that the reasoning
already lives in **ADR 0001** — whose header still read *"Rule it produced: none yet"* though the rule
hardened into a bullet the same day. So no new record was owed, but the bullet needed a pointer and 0001
needed correcting. Both done. That is a better answer than *"the reasoning stays inline"*.

**Four further repairs to this task's own work**, all from the same read: 0002's Decision sentence was
false as written (*"One Bash script… and no other executable code"* in a repo with seven scripts,
contradicted by its own Consequences) → corrected; 0005–0008 lacked a `Filed:` line so `Date:` could be
misread as the writing date → added to all; the *"one-line entry"* claim in three headers was untrue of
all three → corrected to say the split is about where the trade-off lives, not line count; and a doubled
bullet fragment in `AGENTS.md` (pre-existing) fixed in passing.

**Six records stand: 0002, 0003, 0004, 0005, 0007, 0008.** The reader ranked them and called 0004
marginal — *keep, but repair its hard-to-reverse claim and its thin second alternative* — which is left to
TASK-069, since it turns on the bar being fixed first.

### Three findings routed rather than absorbed

- **TASK-069** — the bar and the split **contradict each other** (the bar fails a prose rule; the split demands a record for any bullet carrying a trade-off; nearly every bullet is both), which is what made the inconsistency above reachable. Carries two more: `close.md` still says **two axes** where the rule says three, with a conditional fourth unslotted — a live defect in the gate every task here passes; and `LAYER.md`'s ADR row claims *"nothing to reconcile"*, which this read disproved three times over.
- **TASK-070** — the set is **missing** a record more clearly than it had a surplus one: the generated-file rule (184 words, an explicitly labelled rejected alternative, content deleted under it) and the declare-versus-derive pair as one record, killing a sentence currently triplicated across two bullets and 0004.
- **TASK-071** — the rulebook says wikilinks are resolved by CI; `skills-lint.sh` never scans `docs/`, where nine of them live.


## Implementation plan

_Populated by `/tasks plan TASK-054` — leave empty until then._
