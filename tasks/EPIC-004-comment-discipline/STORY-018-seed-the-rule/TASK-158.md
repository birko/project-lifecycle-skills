---
id: TASK-158
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-20
depends-on: [TASK-159]
blocks: []
findings: [DRILL-157-1]
pr: null
github-issue: null
jira-key: null
---

# Four more restatements in `skills-lint.sh`, and two comments that should exist and don't

## Context

Found by TASK-157's verification run — two cold readers applying this project's comment rule to
`.github/workflows/skills-lint.sh` on a fixture carrying the whole guide **minus the measurement table
only**, so no record of any prior verdict about the file was visible to them.

They are one task because they are one sweep of one file. The first is a different *kind* of defect
from the other four and is called out as such below, but splitting it would lose that both readers
found it independently in the same pass.

### The one that is not a restatement — `:22`, and **both readers found it**

```sh
RUNTIME_REFS=" init update-config Explore "
```

Check 2 accepts these three names as valid `[[link]]` targets with no skill folder behind them.
**Why lives nowhere** — not in the code, not in the banner, not in `AGENTS.md`. The rule's `nowhere`
row says that is the one case which survives, *"at whatever length it takes"* — so here it should be
**written**, not deleted.

**Reader I declined to draft it, and the reason is the point:** the fixture held only the guide and
the lint, so it could not verify what actually links to `init`, `update-config` and `Explore`, and
*"guessing it into the file would be worse than the gap."* That is the only-copy discipline applied to
a comment that does not exist yet. Whoever takes this needs to establish what those three names are
and why they have no folder — `init` and `update-config` are runtime-provided Claude Code skills and
`Explore` is an agent type, but **that must be confirmed, not assumed from this sentence.**

### A second comment that should exist and doesn't — the `\r` in `rule_block()`

> **Corrected 2026-09-20, before acting on it.** This section first called the `\r` *load-bearing* —
> that it is what lets check 5 match its end marker across a CRLF template and an LF `AGENTS.md`.
> **That was asserted, not measured, and it is wrong.** The criterion below demands verification, so
> the claim got the same treatment and did not survive it.

`skills-lint.sh`'s `rule_block()` reads:

```
function bare(x) { gsub(/^[ \t]+|[ \t\r]+$/, "", x); return x }
```

The trailing class is space, tab, **carriage return**. What that CR actually does, measured:

| Question | Answer |
|---|---|
| Does the template's marker region carry CRs today? | **No.** The file is *mixed* — 17 CRs in 48 lines — but TASK-159 spliced the block from `AGENTS.md`, so both extracted blocks have **0** |
| Does removing the `\r` change extraction on a CRLF file? | **No.** Tested both ways against an LF and a CRLF fixture: 3 lines out, every time |
| Why not? | **This `awk` strips CR before `$0`.** `od` shows `\r\n` in the file; GNU Awk 5.0.0 under MSYS reports `length($0)` = 27 for a 27-character marker |
| Does CI reach the CRLF case? | **No.** `.gitattributes` is `* text=auto eol=lf`, so a Linux runner checks out LF |

**So it is defence-in-depth currently unreachable on both platforms** — dead against this `awk`, moot
under this `.gitattributes`. It would matter only on an `awk` that does *not* strip CR, reading a file
that *is* CRLF.

**It still earns a comment, for the opposite reason to the one first claimed.** Its purpose lives
nowhere, so the next reader meets an inexplicable `\r` in a character class and either deletes it as
noise or trusts it as an active guard. Both are wrong, and the comment has to say which.

**The hazard that found it is real even though the claim was not.** A text-mode read of this file
converts that lone CR to a newline and splits the `awk` program mid-regex. When that happened during
TASK-160, `awk` tolerated the mangled class, check 5 still printed *"agree"*, and the lint **exited
0**. Only a comment-only diff assertion caught it. A gate that cannot detect its own extractor
breaking is the argument for the comment; the CR's supposed importance never was.

### Four restatements

| Site | Finding | Found by |
|---|---|---|
| `:166` | `# $1 = file` restates the signature; `[ -f "$1" ]` on the next line already says it. Not a doc comment, so the published-output carve-out does not apply. **The second sentence — that empty output means "no delimited block here" — is real content and stays** | I |
| `:10` | `# Run locally: bash .github/workflows/skills-lint.sh` — recoverable from the shebang plus the file's own path. **Confirmed on both halves.** D15 (approved 2026-09-20) makes the guide a destination, so *also in `AGENTS.md` § Commands* now catches it as well as the code-restatement half. Action per the new row: delete, or leave a one-line pointer | I |
| `:149` | first clause restates `:117-121`, which **explicitly claims ownership** of that mechanic. Only the first clause duplicates — the `well--known` false positive is new and must stay | I |
| `:295-296` | the closing sentence restates the branch below it | J |

### Added 2026-09-20 from TASK-160's verification — four readers over that file

| Site | Finding | Reader |
|---|---|---|
| `:126` | its four alternatives **are** `ARG_RE`'s four alternations on the line below, in order (`<…>`, `{{…}}`, `[A-Z0-9]…`, `\.\.\.`) — destination *the code itself* | Q |
| `:77` | *"Aliased links … never skipped"* — `cut -d'|' -f1` on the next line says the first half. Q's own call: trim to the invariant, do not delete | P |
| `:123-129` | narrates its measurement with **no pointer**, where `:105` and `:117` both use one — the file is internally inconsistent about measurements | P |
| `:23` | `RUNTIME_REFS`' **surrounding spaces are load-bearing** for the `*" $link "*` match at `:81` — a detail no earlier reader found | P |

**`:126` reframes the block's long-running dispute and should be taken first.** Five readers split
4:2 on *"is `:122-131` a rationale essay"*, which is an argument nobody can settle. Q's claim is
different in kind: **one sentence lists, in order, exactly what the next line of code says.** That is
row 1 and it is verifiable in ten seconds. Settling it may dissolve the rest — and note **both** P and
Q explicitly cleared the block *for length*, quoting the carve-out, so length was never the question.

**Carry this into the sweep:** cutting a restatement can **strand the sentence after it**. TASK-160
removed a line that was both a genuine duplicate *and* the antecedent telling a reader which axis the
next sentence addressed; the result read as a contradiction until a reader caught it. Check what each
cut was holding up.

## Acceptance criteria

- [x] **`:10` is judged against D15** — stamped `approved` 2026-09-20, so both halves of the finding stand: it restates the code *and* the guide.
- [x] The **CR** in `rule_block()`'s trailing character class gains a comment saying **what it is for and why it is kept rather than deleted as dead**. **Corrected twice, and the second correction came from a reader — also, the first correction silently failed to apply and this line still carried the original wording until the close.** It first demanded *"what breaks without it"*: nothing does. I rewrote it to *"what it is for and that it is currently unreachable"* — and reader R showed that second half is a **QA log**: *"which platforms currently cannot trigger this"* is that row exactly, and it asserts the state of `.gitattributes` and the awk build with nothing re-checking either. The measurement is now a pointer; the comment keeps purpose and why-kept.
- [x] `:22` gains a comment stating why those three names resolve without a skill folder, **verified against what actually links to them** — not inferred from this task's own parenthetical.
- [x] Each of the four restatements is acted on or dismissed **with a reason recorded**; "left as is" alone does not close this.
- [x] `:166` keeps its second sentence, `:149` keeps the `well--known` case. A fix that deletes the whole comment at either site has removed content that lives nowhere.
- [x] Every deletion names the destination that holds the content, **verified rather than asserted** — TASK-157 found two of its six destinations mis-filed in its own context table, so this is not a formality.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- `:158-161` and `:198-202` — **TASK-154**, confirmed independently by both readers on a fixture with no record of that verdict.
- The six sites TASK-157 cut, and the header contradiction it introduced and fixed in the same task.
- `AGENTS.md`'s stale *"check 5"* for install-root drift — **TASK-081**.

## Human test plan

> **Corrected 2026-09-20, before running.** The first expectation read *"TASK-154's two still
> reported"* — written while TASK-154 was open. It is now `done` and both its sites are pointers that
> three readers have already cleared. Running against the original wording would have manufactured a
> failure out of work that succeeded. **This is TASK-141's defect exactly** — an expectation recorded
> at filing time and not reconciled before the run — and the reason TASK-161 exists.

- [x] Two cold readers on the minus-the-table fixture. Expected: **the five sites this task cut are gone**; `:22` and the `
` now carry comments and are not reported as gaps; TASK-154's two sites are **cleared as pointers**, not reported; TASK-151's and TASK-157's survivors untouched.
- [x] **`:22` is judged on accuracy, not presence.** The named failure is a comment that *sounds* authoritative about why those three names are exempt but was never checked. It was checked — against `new-project/SKILL.md:223`, `verify-conventions/SKILL.md:246`, `specs/verbs/init.md:29` — so the test is whether a reader with the repo in front of them agrees, including the `Explore`-is-an-agent-type distinction and the load-bearing spaces.
- [x] Expected failure to watch for: the `
` comment is now the **longest** thing attached to a one-line function, and it documents something unreachable. A reader may reasonably call it disproportionate. If two do, the comment is wrong even though the fact is right.

## Implementation plan

_Populated by `/tasks plan TASK-158` — leave empty until then._

## Progress log

- 2026-09-20 — Picked. Survey first: **`:10`/`:11` was already removed by TASK-160**, so criterion 1 is satisfied without work here — one cut settled both tasks' claim on it.
- 2026-09-20 — **`:22`'s destination verified against the linking sites, not inferred.** The task's own parenthetical said *"`init` and `update-config` are runtime-provided Claude Code skills and `Explore` is an agent type, but that must be confirmed"*. Confirmed: `[[init]]` ← `new-project/SKILL.md:223`, `[[update-config]]` ← `verify-conventions/SKILL.md:246,255`, `[[Explore]]` ← `specs/verbs/init.md:29`. The asymmetry is real and worth the comment — two are built-in **skills**, the third is an **agent type**, not a skill at all.
  - **Reader P's space detail confirmed by reading `:81`:** the test is `*" $link "*`, so the padding on `" init … Explore "` is what lets the first and last entries match. Written into the comment.
  - **The reference list is deliberately *not* in the comment.** Naming which files link to those three names would be a restated list that goes stale the day a reference moves — the defect this file already fixed twice. `grep` finds them.
- 2026-09-20 — **The `\r` comment says what it is, not what I first claimed.** Per the corrected criterion: it guards an `awk` that does **not** strip CR reading a CRLF file, and it is unreachable on both counts today. Kept but not trusted.
  - **And writing it injected the hazard it documents.** The literal `\r` in my edit script became a **real CR** in the file — CR count 316 → 326 against 324 lines. Caught by re-counting, fixed by writing `CR` in prose. Documenting a stray carriage return and adding one in the same edit is the clearest argument for the comment that could have been constructed on purpose.
- 2026-09-20 — Six cuts, each keeping what the code cannot say:

| Site | Cut — and the destination | Kept |
|---|---|---|
| `:77` | *"checked on the name half"* — `cut -d'\|' -f1` is the next line | the input shape and the **invariant** *never skipped* |
| `:126` | the three alternatives **are** `ARG_RE`'s alternations below, in order | the rejected first attempt, the measured false positive, the lowercase-word ceiling — none of which is in the regex |
| `:147` | *"EVERY flag … not just the first"* — the paragraph above **and** the guide | **SPACE-ANCHORED** and the `well--known` false positive |
| `:163` | `$1 = file` — `[ -f "$1" ]` is the very next line | the empty-output contract that `:180-188` branches on |
| `:290` | *"say what is not linked rather than that nothing is"* — the two branches below say it | **why the gate is absent**, which has no other home |

  - **`:126`'s antecedent was kept deliberately.** TASK-160 cut a restatement and stranded the sentence after it; here the replacement clause (*"ARG_RE below is what replaced it"*) exists only to keep *"Prose runs several lowercase words together"* anchored to something.
  - **Two readers split on `:163` and on `:290`, and both splits are recorded rather than resolved silently.** Reader P cleared `:163` (*"shell has no signature to restate"*) where TASK-157's reader I reported it; I cut it, because the rule's row 1 is *"the name, the type, the signature, **the line below**"*, and the line below is `[ -f "$1" ]`. Reader Q cleared `:290` where P reported it; I split the difference on the evidence — the branch description goes, the why stays.

### Reader S — criterion 2 cleared, and three findings against my own edits

**The `\r` comment passed, and S verified rather than accepted it:** *"I **hexdumped line 178** and
the CR is genuinely there (`[ \t\r]+$`), so the comment is accurate, and its 'unreachable on both
counts today, kept but not trusted' caveat has no other home."* **The disproportion failure I wrote
into the plan did not occur** — S read four lines above a one-line function and judged them earned.
`:22` was not reported either, so both written comments stand on one reader.

**All five cuts hold.** None is reported; only `:82`, my trimmed aliased-links line, is called
borderline.

#### Three of S's findings are mine, and all three verify

| Site | What S says | Verified |
|---|---|---|
| `:122-123` | *"narrates code that no longer exists"* — **written in this task** | ✅ I replaced a guide-restatement with a **history narration**. Both are restatements; I swapped one destination for another |
| `:9` | *"second copy of a pointer"* — **written in TASK-160** | ✅ *"for the same reason the banners are not restated above"* — that reason is already at `:4-5`, as a pointer to the same section |
| `:189-190` | restates § *An owner verb reconciles* | ✅ `AGENTS.md:158`: *"a caller cannot tell 'your file is fine' from 'I declined to look' when both print the same line"*. `:189` is the same sentence with local nouns — **and TASK-160's eight-site sweep missed it** |

**`:122-123` is the sharper lesson.** TASK-160 taught that *cutting* a restatement can strand the
sentence after it. This is the inverse: **rewriting** one to avoid a stale reference moved it from the
guide's destination to version history's. I checked the new text against the rule I was applying and
not against the other four rows.

#### The `ARG_RE` block is now 4:3, not 4:2 or 5:1

S is the **third** reader to call part of `:127-135` a rationale essay (with TASK-154's step-1 reader
and N), against four who protected it. It proposes the same split Q's evidence implies from a
different angle — **the rejected-attempt narrative out, the live constraint plus a pointer in**. Two
independent routes to one answer is the strongest signal yet that the block should be split rather
than argued about. Still **TASK-158's** to settle, and now with a concrete shape.

**Holding for reader R before acting on any of it** — one reader is not a result, and I have twice
this session found a single reader's confident finding needed the second run to size correctly.

### Reader R — and the split on my own comment

**R contradicts S on the CR comment, and R is right.** S hexdumped it and cleared the whole thing.
R called the unreachability half a **QA log**: *"which platforms currently cannot trigger this"* is
that row exactly, its home is the ticket the comment already cites — *"and it rots quietly: it
asserts the state of another file with nothing re-checking it."*

**Taken on R's reading, not by vote.** R names a specific row, identifies a rot mechanism S did not,
and independently matches the failure written into this plan **before** either result arrived. The
purpose sentence and the why-kept stay; the measurement is a pointer.

**`:122-123` is 2 of 2 against my own edit in this task.** R: *"its technical content is stated
again, and better, by the very next sentence, which declares its own nowhere-ness."* I had replaced a
guide-restatement with a history narration — swapped destination, did not remove one.

**R explicitly cleared the `ARG_RE` block**, calling it the one it *"looked hardest at"*. With S
reporting it, the tally is **4 clear : 3 report**.

#### Applied from both readers

| Site | Finding | Readers |
|---|---|---|
| `:122-123` | history narration restated by the line below | R + S |
| `:175-176` | the unreachability half is a QA log that asserts another file's state | R |
| `:189-190` | restates `AGENTS.md:158` § *An owner verb reconciles* — **TASK-160's sweep missed it** | S |
| `:9` | second copy of the pointer already at `:4-5` — **written in TASK-160** | S |

#### Test plan outcome, stated against what was predicted

- **Predicted failure occurred, in R's reading.** The plan said *"if two readers call the CR comment
  disproportionate, the comment is wrong even though the fact is right."* One did, on a sharper
  basis than the one predicted. Acted on rather than discounted as 1-of-2 — the test found what it
  was built to find.
- `:22` — **not reported by either reader.** Judged on accuracy as the corrected plan required.
- The five cuts — **none reported.** `:82` called borderline by S only.

#### Two process failures in this task's own record

1. **A correction to an acceptance criterion silently failed to apply.** The earlier `python` used an
   asserted `replace` for the heading and an **unasserted** one for the criterion; the criterion
   never changed, and the line still carried its original wording until the close. It reported
   success. Every subsequent edit in that script now asserts.
2. **A literal carriage return was injected into prose three times** — twice into the script, once
   into this task file — by writing a backslash-r inside an edit script. Caught each time only by
   counting CRs. The rule has no row for *"the tool you edit with can corrupt what you write about"*;
   what it has is the habit of counting, which is what worked.
