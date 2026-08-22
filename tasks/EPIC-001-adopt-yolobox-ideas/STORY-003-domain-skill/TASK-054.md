---
id: TASK-054
parent: STORY-003
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: review
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
      — ⚠ **NOT MET as written: seven written (0002–0008), one declined under AC 5.** Not softened; see below.
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

- [ ] Read records 5-8 cold and confirm each explains a rule whose § Conventions line no longer carries
      its own justification — the two halves must compose without repeating
- [ ] Confirm no record reads as contemporaneous when it was written retroactively
- [ ] Pick the weakest of the eight and argue it against the three-part bar out loud; if it fails, delete
      it and record that it failed. A backfill that quietly waves the bar through discredits the bar

## Implementation plan

_Populated by `/tasks plan TASK-054` — leave empty until then._
