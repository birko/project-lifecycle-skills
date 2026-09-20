---
id: TASK-154
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [DRILL-151-2]
pr: null
github-issue: null
jira-key: null
---

# Two check headers in `skills-lint.sh` argue a case the rulebook already settled

## Context

Found by `/review-comments --all` run as **TASK-151**'s human test plan, on the working tree after
that task's fixes had landed. Both sites are judgement calls (⚠), neither is one of TASK-151's four
named findings, and filing them rather than absorbing them is what kept that task inside its
acceptance list.

**They are one task, not two, because a half-fix is worse than either.** The two comments sit above
adjacent checks and answer the same question — *is this check a gate, and why?* Fixing one leaves the
two headers disagreeing about how much a check explains itself, which is the inconsistency that
invites the next person to "restore" the deleted half.

### Site 1 — `skills-lint.sh:199-205`, destination *a decision record*

> `# ADVISORY — this check never touches `fail` and can never change the exit code. Two reasons, and`
> `# the first is the real one: a missing junction is fixed by re-running an installer, which lives`
> `# OUTSIDE this repo, so no diff can clear the finding and a repo gate must not block on it. Second,`
> `# the roots do not exist on the CI runner, so a fatal check here would make this gate's meaning`
> `# depend on which machine ran it.`

`AGENTS.md:355-358` carries **both reasons, in the same order, in near-identical words**:

> *"A check whose remedy lives **outside the repo** … cannot be a blocker: no diff can clear it, and
> the roots do not exist on the CI runner, so making it fatal would leave the gate meaning different
> things on different machines."*

This is the closest thing to a verbatim duplicate in the repository.

### Site 2 — `skills-lint.sh:159-162`, destination *a decision record*

> `# … Neither can point at the other — a consumer install cannot see this repo — so the only thing`
> `# keeping them from drifting is this check. Fatal, not advisory: the remedy is a diff here, unlike`
> `# check 6's installer re-run.`

That is FEATURE-002 **D13** restated — *"No pointer between them is possible — a consumer install
cannot see this repo"* — and `AGENTS.md` § *Where the same prose must exist in two files* carries the
same reasoning again.

**The counter-argument, recorded so it is answered rather than ignored.** A reader editing a gate
arguably needs to know why it is fatal or advisory without leaving the file — and if they do not, the
next "helpful" change makes check 6 fatal and breaks CI on a machine with no install roots. That is
real, and it is exactly what the rule's *"delete it, **or leave one line pointing at the record**"*
clause is for. The pointer is the fix, not deletion.

**One clause at site 2 is not a duplicate and must survive:** *"unlike check 6's installer re-run"*
is a contrast between two checks in one file, which no record carries and which is the thing a script
editor actually needs.

## Acceptance criteria

- [x] Both sites either point at their record — `AGENTS.md` § Testing for site 1, FEATURE-002 D13 for site 2 — or keep the prose with a recorded reason. "Left as is" alone does not close this.
- [x] Each check's *verdict* still reads off the script: a reader must be able to see that check 6 is advisory and check 5 is fatal without opening another file. It is the **argument** that relocates, never the fact.
- [x] Site 2's `"unlike check 6's installer re-run"` contrast survives — it lives nowhere else.
- [x] The two headers end up consistent with each other about how much a check explains itself.
- [x] `bash .github/workflows/skills-lint.sh` and `bash .github/workflows/skills-lint-test.sh` both pass.

## Out of scope

- Making check 6 fatal, or check 5 advisory — `AGENTS.md` § Testing settles both, and this task only moves prose.
- The four survivors TASK-151 named (`:124-133`, `:256-259`, `:43-44`, `:14-16`) — measured as living nowhere else, twice.
- The 8-of-39 copy in `skills-lint-test.sh` — **TASK-153**; the installer why-clause — **TASK-148**.
- **To TASK-158** — check 5's header says `FATAL` flatly, but its no-pair branch prints and passes, so the claim holds for three of its four branches; and `set -u` on an unset `$HOME` can abort inside the advisory section before `exit "$fail"`. Both found by the script-alone readers, neither introduced here.
- **The `:124-133` 🛑 and the rulebook-as-destination question** — dismissed and recorded above; both are about the rule's boundaries, not this task's two sites.

## Human test plan

- [x] Run `/review-comments --all` and confirm both sites are gone, or reported with the recorded reason standing.
- [x] Hand someone the script alone and ask which checks can fail the build. Expected: they answer correctly from the script. If the relocation took the fact out along with the argument, this is where it shows.

## Implementation plan

_Populated by `/tasks plan TASK-154` — leave empty until then._

## Implementation plan

_Drafted at `/tasks pick` 2026-09-20. Destinations verified first: `AGENTS.md` § Testing carries site
1's two reasons in the same order; § *Where the same prose must exist in two files* and FEATURE-002
**D13** carry site 2's. Neither cut is an only copy._

**The shape both headers converge on — fact, then pointer.** Criterion 2 is the constraint that
decides everything here: *the verdict reads off the script, the argument relocates*. So each header
keeps its one-line statement of **what the check does to the build** and hands the **why** to the
record. That also satisfies criterion 4 by construction — two headers built to one shape cannot
disagree about how much a check explains itself.

1. **Site 1 (check 5's ADVISORY block)** — keep *"never touches `fail`, so it cannot change the exit
   code"*, which is the fact and is also checkable against the code three lines down. Replace the
   five-line argument with a pointer at § Testing. **`:204-205` stays untouched** — that roots are
   overridable *because the regression suite must fabricate them* is a why with no other home, and
   both TASK-151's reader and TASK-141's reader B said so independently.

2. **Site 2 (check 5's fatal block)** — keep **fatal** as the fact, keep the contrast with the
   advisory check (criterion 3: it lives nowhere else), and point the two-copies reasoning at its
   section plus D13.

3. **Name the other check, do not number it.** The contrast currently reads *"unlike check 6's
   installer re-run"*. TASK-157 removed a hard-coded check list from this file's header one commit
   ago and replaced it with *"named, not numbered"*; a bare `check 6` here would re-introduce exactly
   what that established, and TASK-081 exists because check numbers in this repo have moved twice.
   Write *"the advisory install-roots check"*.

4. **Verify.** Both gates, then the human test plan — `/review-comments --all`, and the
   read-the-script-alone test that catches a relocation which took the fact out with the argument.

**Anticipated objection, answered rather than left implicit.** This makes the script terser about its
own design, and a maintainer who never opens `AGENTS.md` learns less from it. That is the trade the
rule's *"delete it, or leave one line pointing at the record"* clause already makes, and criterion 2
is the guard against it going too far: the **consequence** for the build stays in the file, so nobody
can make check 6 fatal by accident without first reading the line that says it must not be.

## Progress log

- 2026-09-20 — Picked; destinations verified first. `AGENTS.md` § Testing carries site 1's two reasons in the same order; § *Where the same prose must exist in two files* and FEATURE-002 **D13** carry site 2's. Neither cut is an only copy.
- 2026-09-20 — Both headers rewritten to one shape — **fact, then pointer** — which is what makes criterion 4 hold by construction rather than by inspection: two headers built to the same shape cannot disagree about how much a check explains itself.
  - `FATAL` and `ADVISORY` are the **first word** of their respective headers, so criterion 2's requirement (the verdict reads off the script) is not merely satisfied but hard to miss.
  - `:204-205` untouched — roots being overridable *because the regression suite must fabricate them* has no other home, and two independent readers said so before I did.
- 2026-09-20 — **Named, not numbered.** The surviving contrast reads *"unlike the advisory install-roots check below"* rather than *"unlike check 6"*. A bare number would have re-introduced exactly what TASK-157 removed from this file's header one commit earlier, and TASK-081 exists because these numbers have moved twice already.
- 2026-09-20 — Gates: lint OK (19 skills); suite 56 passed, 0 failed. Change verified **comment-only**.
- 2026-09-20 — `AGENTS.md`'s measurement table re-run for the **third** time: 321/126/30 → **318/123/30**, shebang-excluded 125 → 122, verdict row now naming TASK-158's five as what remains.
  - **And the survivor citations stopped being line numbers.** They had gone stale *twice inside the commits that set them* — TASK-157 repointed them, then TASK-157's own header fix shifted one again. They now name the blocks (*"the block above `ARG_RE`"*, *"the `##`-not-`#` note in `check_root`"*), which no edit above them can move. Third instance of this failure in the session, counting TASK-081's `:477`; repointing was treating the symptom.

### Human test plan — step 2 design, recorded before the answers

Step 2 is the one that can fail: *"hand someone the script alone and ask which checks can fail the
build."* Its fixture is therefore **the script with no guide at all** — not the repo, not a cut-down
guide. Both pointers added here lead to `AGENTS.md`, so a reader who cannot answer without following
one has been handed a relocation that took the **fact** out along with the **argument**, which is
precisely what criterion 2 forbids and what this step exists to detect.

Two readers, `--disable-slash-commands`, `--permission-mode plan`, captured whole. **Expected: both
name check 6 as unable to fail the build and the other five as able, citing the script** — the
`advise()` helper, the absence of any `fail` assignment in `check_root`, and the `ADVISORY` line
itself. A reader who says "the comment says so" without the corroborating mechanism is a weaker pass
and is recorded as such.

### Step 2 — result: **pass, at the strongest reading available**

Two readers, the script and nothing else — no guide, no repo, so both pointers added here lead
somewhere they could not follow.

| Required | Reader K | Reader L |
|---|---|---|
| names check 6 as unable to fail the build | ✅ | ✅ |
| names the other five as able | ✅ | ✅ |
| **derives it from the code, not the label** | ✅ | ✅ |

**Neither took `ADVISORY` on trust, and both said so unprompted.** K: *"Two supporting details confirm
the advisory status of check 6 **rather than relying on its label** … the comment says the same thing,
but the code is independently checkable."* L: *"`advise()` … never assigns `fail` and never writes to
`$FAILFILE`. That's the whole difference from the other five."* Both traced `exit "$fail"` to its only
three assignment sites and reduced the question to *does this section call `err` or `suberr`*.

**So the relocation did not take the fact out with the argument** — which is the single thing
criterion 2 exists to prevent, and the reason this step's fixture was the bare script rather than a
cut-down guide.

**Two things the readers found that I did not know and had not designed for**, recorded because they
are evidence the readers were reading rather than confirming:

- **Check 5 has a *third* outcome.** When **neither** file carries the block it prints and passes —
  loud, but not fatal. The header now calls check 5 `FATAL` without qualification, which is true of
  three of its four branches. Not a defect in this task's change (the previous wording said the same),
  but it is a live inaccuracy in a line this task touched, so it is going to **TASK-158** rather than
  being quietly absorbed or quietly ignored.
- **`set -u` on an unset `$HOME`** can abort inside the advisory section before `exit "$fail"` is
  reached — a script death, not a check failing, but it means "check 6 cannot fail the build" has one
  environmental caveat. Also to TASK-158.

### Step 1 — result: **both sites confirmed gone**

`/review-comments` run with the **`PATH` scope** rather than `--all` — the honest scope for one file,
and it exercises TASK-152's work for real on a clean tree, where an empty diff would otherwise prove
nothing. Header rendered `paths (diff not consulted) — … 1 of 1 tracked. Named explicitly by path.`

Both sites appear under **Left alone**: *"`:159-161`, `:198-199`, `:208-210` — pure pointers
(AGENTS.md § Testing, FEATURE-002 D13, ADR 0010). **A pointer is never a finding.**"* TASK-157's
`:4-5` is cleared in the same list — *"a comment whose whole content is why a copy is absent; there is
nothing to relocate."*

#### The run raised a 🛑 against the block `AGENTS.md` names as its compliant exemplar

`:124-133`, the `ARG_RE` block. The reader calls `:124-127` and `:132-133` a **rationale essay above a
declaration** — an always-violation — arguing a *rejected first attempt*, while keeping `:128-131`,
which decodes the regex, as destination `nowhere`.

**I am dismissing it, and recording the reason rather than the verdict.** The rule's own text protects
*"a thirty-line block explaining a non-obvious algorithm, a protocol quirk, or **why the obvious
implementation is wrong**"* — and `:124-127` is precisely that: the obvious implementation (any bare
word between verb and flag) was tried, and it read ordinary prose as an invocation. Removing it is how
someone re-widens the regex and reopens a false positive on a **fatal** check.

**The tally is 5:1, and it is the second 5:1 of this feature.** Five readers across TASK-141 and
TASK-157 protected this block explicitly and unprompted — one called it *"the likeliest thing to
over-report … protected at any length"*. This one splits it. **That the two 5:1 splits land on
different questions (severity in TASK-155, scope-of-block here) is the argument that the rule's
boundary between *rationale essay* and *why the obvious implementation is wrong* is genuinely
under-specified**, not that either reader is careless. Filed, not absorbed.

#### A rule-level observation worth more than the findings

The reader declined to report `:11` (*"Run locally: …"*, which duplicates `AGENTS.md` § Commands)
**because the guide is not one of the destination table's five rows** — and noted this repo's own
five-records table puts § Conventions outside `docs/adr/`. So a comment restating the **rulebook** is
caught by no row.

**That directly contradicts a finding this feature already acted on.** TASK-157's reader I reported
`:10` as a violation citing § Commands, and TASK-158 now carries it. One of the two readings is wrong,
and the rule does not say which.

### Correction — the destination this task recorded does not exist

Filed after close, against work already committed in `1932557`, because it is a defect in the
**record** rather than the change: site 1's destination was written up as **"a decision record"**,
pointing at `AGENTS.md` § Testing. `### Testing` sits under `## Conventions` — by this repo's own
five-records table it is a **rulebook entry**, a record *distinct* from `docs/adr/` and
`decisions.md`, and § Conventions says such entries mostly have no decision record at all.

**The relocation stands; the row it was filed under is not in the table.** The pointer is correct and
both script-alone readers confirmed the verdict survived it. What is wrong is the classification, and
it is wrong because the table has no row that fits — which is now **FEATURE-002 D15** (`proposed`) and
**TASK-159**, blocked on it. Corrected there rather than silently here, since the same gap produced a
finding on TASK-158 and a declined finding in this task's own verification run.

