---
id: TASK-159
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: [TASK-158]
findings: [DRILL-154-1]
pr: null
github-issue: null
jira-key: null
---

# The destination table has no row for the project's own guide

## Context

Surfaced by TASK-154's verification run and then confirmed textually. **Unblocked 2026-09-20 — D15 is stamped `approved`.** It was
held at `blocked` while `proposed`, because the fix edits `CONVENTIONS-universal.md`, which ships
byte-identical to every consumer and is asserted by lint check 5; implementing an undecided row is the
violation this repo names as coding without a task. **The decision is now made and the work is
defined:** add a sixth row — *in the project's own guide — delete it, or leave one line pointing at the
section* — to **both** copies, byte-identical.

### The gap, checkable in three steps

1. **The table has five rows and the guide is not one of them:** *in the code itself* · *in version
   history* · *in the ticket* · *in a decision record — `docs/adr/`, the feature's `decisions.md`* ·
   *nowhere*.
2. **The rule text never mentions it.** Inside the `comment-rule` markers there is no occurrence of
   `CLAUDE.md`, `AGENTS.md`, *guide*, *rulebook* or *convention*. Verified by grep over `AGENTS.md`
   `:371-400`.
3. **This repo's own five-records table makes the guide a *distinct* record** from both `docs/adr/`
   and `docs/features/*/decisions.md` — *"`AGENTS.md § Conventions` | what we do now | the standing
   rule"* — and § Conventions states that rulebook entries mostly have **no** decision record, because
   *"a convention's footprint is the prose it will shape."*

So content living in the guide **has a home** — it is not *nowhere*, and the rule is explicit that
*nowhere* means no home rather than nobody-wrote-it-down — **yet no row says what to do about it.**

### Three readers have split on it, and one of them was me

| Reader | Handling |
|---|---|
| TASK-141 reader B | reported `:199-203`, destination **"a decision record"**, citing `CLAUDE.md:355-358` — i.e. mapped guide → decision record |
| TASK-157 reader I | reported `:10` as a violation citing `CLAUDE.md` § Commands |
| TASK-154 step-1 reader | **declined to report** `:11`, stating the guide is not one of the five rows and noting the five-records table puts § Conventions outside `docs/adr/` |

**And the mis-classification is already committed.** TASK-154 (`1932557`) relocated check 6's argument
to `AGENTS.md § Testing` and recorded the destination as *"a decision record"*. `### Testing` sits under
`## Conventions` — it is a rulebook entry, not a decision record. **The relocation is right; the row it
was filed under does not exist.** Present state of the script shows the split cleanly:

| Comment | Points at | Row that covers it |
|---|---|---|
| `:199` | `AGENTS.md § Testing` | **none** |
| `:160` | § *Where the same prose…* **+ FEATURE-002 D13** | half — D13 only |
| `:208` | `ADR 0010` | decision record ✓ |

### Why this is not cosmetic

Most cross-cutting content in this repo lives in the guide, by design — § Conventions is the record for
*what we do now*. Under the strict five-row reading, a comment may duplicate the rulebook indefinitely
and the check can never say so, which removes the axis from the majority of what it would otherwise
catch. Under the loose reading, every such finding is filed against a row that the project's own
taxonomy says is a different record.

## Acceptance criteria

- [x] **D15 is stamped** by `/feature decide` before any file changes — `approved` 2026-09-20, action *delete-or-pointer*.
- [x] Whichever way it goes, the rule says it **explicitly** — a reader must not have to infer from the absence of a row whether the guide counts.
- [x] If a row is added: it goes in `CONVENTIONS-universal.md` **and** `AGENTS.md`, between the markers, byte-identical, or check 5 fails. That is the mechanism, not an afterthought.
- [x] If a row is added: its action is stated (delete outright, or delete-or-pointer) — the existing rows differ on this and the difference is load-bearing.
- [x] TASK-154's recorded destination for `:199` is corrected to match the settled answer, and TASK-158's `:10` finding is either confirmed or withdrawn on the same basis.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- The **content** of any relocation already made — TASK-154's two pointers are correct as pointers; only their classification is in question.
- Whether `§ Conventions` should be folded into `docs/adr/` — the five-records table settles that, and reopening it is a `domain` question, not this one.
- The split on whether the `ARG_RE` block is a rationale essay — **TASK-158**. **The tally moved during this task: 4:2, not 5:1** — reader N joined TASK-154's step-1 reader in calling part of it a rejected-alternative essay. Recorded against my dismissal of it in TASK-154, not beside it.
- **The eight sites D15 made reportable — TASK-160.** Created by this decision rather than found by a sweep, and kept out of TASK-158 because that task's acceptance list was written for five specific sites.
- `:217`'s backwards run-order premise — **TASK-081**, independently confirmed again by reader M.

## Human test plan

- [x] After the rule changes, two cold readers on a fixture whose guide carries a comment-duplicating passage. Expected: both reach the same verdict on it, in whichever direction D15 settled.
- [x] Expected failure to watch for: adding the row makes *every* pointer-to-the-guide reportable, including the ones this feature deliberately created. A rule that indicts its own remedy is worse than the gap.

## Implementation plan

_Populated by `/tasks plan TASK-159` once D15 is stamped — leave empty until then._

## Implementation plan

_Drafted at `/tasks pick` 2026-09-20, after D15 was stamped `approved`._

**The row is two lines; the whole risk is the ripple.** A survey found five dependents before any
edit, two of them inside the marker block where a mismatch fails check 5 fatally.

1. **Add the row to `AGENTS.md` first**, between *a decision record* and *nowhere* — order matters,
   because `nowhere` must stay last for the sentence that follows the table to read correctly.
   Action text mirrors the decision-record row exactly, per D15: *delete it, or leave one line
   pointing at the section*.

2. **Fix the sentence the table feeds.** *"Content belonging in one of the **first four rows** goes
   there first"* becomes **five**. This is inside the markers, so it is not optional tidying — and it
   is the kind of dependent count that goes stale silently, which is the defect this whole feature
   exists to catch.

3. **Regenerate the template's marker region from `AGENTS.md`'s, rather than re-typing it.**
   `CONVENTIONS-universal.md` is **47 lines**, not 30 — the markers wrap only its first section, and
   lines 31-47 carry § *Keeping conventions current* and § *Working rules*, which must survive
   untouched. Splicing the block in guarantees byte-identity by construction; typing the same edit
   twice is what check 5 exists to catch, and there is no reason to hand it the opportunity.

4. **Outside the markers — `review-comments`:**
   - § *The only copy* has a four-row verification table (*"Destination the finding named | What to
     check"*). It needs a fifth: the guide. Without it, the skill can name a destination it has no
     instruction for checking, which is the state that produced this task.
   - Two sample report headers read `Destinations: 5 rows.` Update to 6. **They are samples, and the
     skill already guards against reading a count off itself** — *"If the guide's table carries more
     rows than you expect, the table wins"* — so this is consistency, not a second source of truth.

5. **Verify byte-identity explicitly**, then both gates, then the human test plan's real question:
   does the new row indict this feature's own pointers? It must not — the action is
   delete-**or-pointer**, and *a pointer is never a finding* is stated separately — but that is an
   argument, and the test plan asks for evidence.

**Not doing:** widening the row to name AGENTS.md by filename. A consumer's guide is `CLAUDE.md`;
this repo reaches the same content through the import bridge. The row names the guide by role so it
is true in both, which the other rows already do for `tasks/` and `docs/adr/`.

## Progress log

- 2026-09-20 — Picked after D15 stamped. **Surveyed dependents before editing** — five, two of them inside the markers where a mismatch fails check 5 fatally.
- 2026-09-20 — Row added to `AGENTS.md` between *a decision record* and *nowhere*, action mirroring the decision-record row per D15.
- 2026-09-20 — **The template is 47 lines, not 30.** The markers wrap only its first section; §§ *Keeping conventions current* and *Working rules* sit below them. So the block was **spliced from `AGENTS.md`'s extracted region** rather than re-typed — byte-identity by construction, which is what check 5 exists to catch and no reason to hand it the opportunity. Everything outside the markers preserved verbatim; verified by heading survey afterwards.
- 2026-09-20 — **The dependent that mattered was inside the markers.** *"Content belonging in one of the **first four rows** goes there first"* feeds directly off the table and would have silently become wrong — a stale count inside the rule that bans stale counts. Now *five rows*, in both copies.
- 2026-09-20 — Outside the markers, `review-comments`: § *The only copy* gained a guide row (*"Read the section, do not trust the name — a pointer at a section that no longer says it is an only copy wearing a citation"*), and the two sample headers moved 5 → 6. The skill's existing guard — *"the table wins"* — is why a sample count is not a second source of truth.
- 2026-09-20 — Gates: lint OK (19 skills), check 5 agrees at **31 lines** (was 30); suite 56 passed, 0 failed.

### Human test plan — reader N

**The named failure mode did not occur.** The plan's own risk was *"adding the row makes every
pointer-to-the-guide reportable, including the ones this feature deliberately created."* Reader N
reported **none** of the three: `:160` (§ *Where the same prose…* + D13), `:199` (§ Testing), `:208`
(ADR 0010). The `delete-or-pointer` action plus *a pointer is never a finding* held.

**And the row is catching what it was added for.** Two of N's four findings were **unreportable
before D15** — `:144-147` restating `CLAUDE.md:279`'s anchored-flag rule *and* its
`--unattend`/`--unattended` example, and `:118-119` restating the same bullet's *every flag* rule.
Both are comments duplicating § Conventions, which had no row until today. Filed to **TASK-158**.

**The `ARG_RE` tally has shifted and is no longer 5:1.** Counting every reader this feature has run
over that block: four left it alone or protected it explicitly (*"protected at any length"*), and
**two** now call part of it a rejected-alternative essay — TASK-154's step-1 reader and reader N
here, independently. **4:2, not 5:1.** That materially strengthens TASK-158's case that the boundary
between *rationale essay* and *why the obvious implementation is wrong* is under-specified, and
weakens my own dismissal of it in TASK-154. Recorded against that dismissal rather than beside it.

### Human test plan — reader M, and the verdict

**Both readers left all three pointers alone.** `:160`, `:199`, `:208` appear in neither report.
The plan's named failure mode — *"the row makes every pointer-to-the-guide reportable, including the
ones this feature deliberately created"* — **did not occur, 2 of 2.** `delete-or-pointer` plus
*a pointer is never a finding* is what holds it.

**The row immediately caught prose this feature wrote.** Reader M reports `:4-5` — TASK-157's header
fix — as restating § *Defer to a shared inventory — never restate its lists*. It is right: the
instruction (*do not restate them here*) is local and stays; the **reason** attached to it is the
guide's, and before today no row covered that. The new row caught a comment written under this
feature three commits ago, which is the strongest evidence available that it is doing work rather
than decorating the table.

**And M found a live factual error neither the header fix nor six previous readers caught.** `:15-17`
says failures use a temp file *"because **checks 2 and 3** run inside `find | while` subshells"*.
**Verified against the code: `suberr` is called by checks 2, 3 *and* 4.** Check 4 was added later and
the sentence never caught up — a restated list gone wrong, sitting three lines below the header
TASK-157 rewrote for precisely this, and missed because the fix was scoped to the enumeration rather
than to the pattern.

#### Measured consequence of D15

**Eight sites in one file moved from unreportable to reportable**: `:2`, `:4-5`, `:11`, `:104-107`,
`:113-117`, `:118-119`, `:144-148`, `:247-249`. Every one is a comment restating § Conventions, and
before today the table had no row that caught any of them. That is the size of the gap D15 closed,
and it is larger than the argument for closing it predicted — worth stating plainly, because a
decision whose consequences are bigger than forecast deserves the number rather than a shrug.
