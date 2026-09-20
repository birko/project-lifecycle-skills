---
id: TASK-160
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [DRILL-159-1]
pr: null
github-issue: null
jira-key: null
---

# The eight sites D15 made reportable

## Context

**These exist because a decision was taken, not because a sweep was rerun.** FEATURE-002 **D15**
(approved 2026-09-20, TASK-159) added a sixth destination to the comment test — *the project's own
guide* — and with it, eight comments in `.github/workflows/skills-lint.sh` went from unreportable to
reportable in one step. Every one restates `AGENTS.md` § Conventions; none was catchable by the five
previous rows.

Found by TASK-159's two verification readers, on a fixture carrying the six-row rule and the guide
**minus the measurement table only**, so neither could see any prior verdict about the file.

| Site | Restates | Found by |
|---|---|---|
| `:2` | § Testing — *"the repo's only automated gate"* | M |
| `:4-5` | § *Defer to a shared inventory — never restate its lists* | M |
| `:11` | § Commands / § Testing — *"Run locally: …"* (also TASK-158, whose code half stands separately) | M |
| `:104-107` | § *A format one skill reads is a contract* | **both** |
| `:113-117` | § *Defer to a shared inventory* | M |
| `:118-119` | § *A format one skill reads is a contract* — the *every flag* rule | N |
| `:144-148` | the same bullet's anchored-flag rule **and** its `--unattend`/`--unattended` example | **both** |
| `:247-249` | § *Defer to a shared inventory* | M |

### `:4-5` is this feature's own prose, and that is the point

TASK-157 replaced a stale check enumeration with *"those banners are the inventory — do not restate
them here, because a copy goes stale the next time a check is inserted."* The **instruction** is local
and stays. The **reason** attached to it is the guide's, and until D15 no row covered it.

So the sixth row caught a comment written under this feature three commits earlier. That is the
strongest available evidence the row does work rather than decorate the table — and it sets the shape
for the whole sweep: **keep the local consequence, point at the shared rationale.**

## Acceptance criteria

- [x] Each of the eight is acted on or dismissed **with a reason recorded**; "left as is" alone does not close this.
- [x] Each fix **keeps the local consequence and relocates only the shared rationale.** A fix that deletes the instruction along with its reason has removed the thing that stops the original defect returning — `:4-5` is the worked example.
- [x] `:144-148` keeps the `grep -qF` prefix-matching mechanic; only the restated rule and its example go. That mechanic lives nowhere else.
- [x] Every deletion names the **section** that holds the content, verified by reading it — not by trusting the heading's name, per the guide row's own instruction in [[review-comments]] § *The only copy*.
- [x] Pointers added here are checked against the same run: a pointer is never a finding, and the sweep must not end with more findings than it started.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- `:22` (`RUNTIME_REFS`), `:166`, `:149`, `:295-296` — **TASK-158**; different destinations, filed before D15.
- `:15-17`'s *"checks 2 and 3"* factual error — **fixed in TASK-159**, where it was found, because it is the same restated-list pattern that task's own header fix was meant to end.
- `:217`'s backwards run-order premise — **TASK-081**, confirmed independently again by reader M.
- The `ARG_RE` block's rationale-essay question — **TASK-158**; the tally is now **4:2**, not 5:1.

## Human test plan

- [x] Two cold readers on the same six-row fixture. Expected: these eight gone, the three pointers (`:160`, `:199`, `:208`) still unreported, and the four TASK-151 survivors still protected.
- [x] Expected failure to watch for: the sweep converts eight restatements into eight pointers and the file now says less than the guide requires a reader to know locally. The test is whether someone editing a check can still tell what it does to the build — the same question TASK-154's script-alone readers answered, and worth re-asking once eight more pointers exist.

## Implementation plan

_Populated by `/tasks plan TASK-160` — leave empty until then._

## Implementation plan

_Drafted at `/tasks pick` 2026-09-20. All eight destinations verified by **reading the section**, per
criterion 4. Two things the verification itself turned up, before any edit:_

- **`:11` is carried twice in the guide, not once.** § Testing's *first* bullet ends *"Run it locally
  with `bash .github/workflows/skills-lint.sh`"*, and § Commands carries it again at `:486`. So
  deleting it also settles **TASK-158's `:10` finding**, whose guide half was the part blocked on D15
  and whose code half stood anyway. One cut closes both.
- **`:2`'s claim is in the guide but is also the file's identification line.** § Testing establishes
  `skills-lint.sh` as the repo's test gate. Deleting the line outright leaves the script opening on a
  bare shebang. The rule's own action gives the third way: *delete it, **or leave one line pointing at
  the section***. It becomes a pointer, and a pointer is never a finding.

**The shape for all eight, and the reason it is one shape.** The test plan's named failure is *"the
sweep converts eight restatements into eight pointers and the file now says less than a reader needs
locally."* That is avoided by what criterion 2 already demands: **only the shared half moves.** Every
one of these comments is a general rule *plus* its application to this code, and the application is
what lives nowhere. Six of the eight keep most of their text and lose a clause.

| Site | Cut (lives in the guide) | Kept (lives nowhere) |
|---|---|---|
| `:2` | *"the repo's only automated gate"* | the identification, now carrying the pointer |
| `:4-5` | the *why a copy goes stale* reason | **the instruction** — do not restate the banners |
| `:11` | the whole line — § Testing **and** § Commands both carry it | nothing; also closes TASK-158's `:10` |
| `:104-107` | the first two sentences (the contract bullet states them) | preventive-not-remedial + the TASK-045 pointer |
| `:113-117` | *"the restated-list defect this repo lints for elsewhere"* — a **vague** pointer, replaced by a named one | the design: match any word, let `skills/<word>/` decide; and that a fixture with other names could not exercise a hard-coded list |
| `:118-119` | *every flag* / *arguments may sit between* — verbatim in the bullet | the `grep -o` mechanic below it |
| `:144-148` | the anchored rule **and** its `--unattend`/`--unattended` example, both verbatim in the bullet | **the mechanic** — `grep -qF` prefix-matches; bind both sides by the flag's character class (criterion 3) |
| `:247-249` | the general never-restate-a-list rule | the design (derive the tree from the path) and its local consequence — *this check would keep passing while missing it* |

**`:113-117` is the instructive one.** Its reason already *was* a pointer — *"the restated-list defect
this repo lints for elsewhere"* — but an unnamed one. § *The only copy* calls that shape out:
*"`// see the ticket` is a second thing to go looking for."* Naming the section is the fix, not
deleting the clause.

**Verify:** both gates, then two cold readers on the six-row fixture — the eight gone, the three
pointers still unreported, the four TASK-151 survivors still protected.

## Progress log

- 2026-09-20 — All eight destinations verified **by reading the section**, per criterion 4. Two findings from the verification itself: `:11` is carried **twice** in the guide (§ Testing's first bullet *and* § Commands), so cutting it also settles **TASK-158's `:10`**; and `:2`'s claim is in the guide but is the file's identification line, so it takes the rule's third option — become a pointer.
- 2026-09-20 — Eight applied, each keeping the local half. `:112` was the instructive one: its reason **already was a pointer** — *"the restated-list defect this repo lints for elsewhere"* — but an unnamed one, the shape § *The only copy* calls *"a second thing to go looking for."* Naming the section was the fix; deleting the clause would have been wrong.

### I corrupted the file, and the gates did not notice

The first pass wrote `skills-lint.sh` with a **text-mode read and a binary write**. The file is CRLF
**and carries one bare CR as data**; Python's universal-newline read turns that lone CR into `\n`,
which split `rule_block()`'s `awk` program across two lines, mid-regex.

**Every gate passed it.** `awk` tolerated the mangled character class, check 5 still printed
*"agree"*, and `skills-lint.sh` exited **0**. The only thing that caught it was the comment-only diff
assertion, which printed all 319 lines instead of nothing.

**The byte it destroyed is load-bearing.** `bare()`'s trailing class is `[ space, tab, \r ]`, and that
`\r` is what lets check 5 match its end marker across a CRLF template and an LF `AGENTS.md`. Invisible
in every editor, the only bare CR in the file (320 CRs, 319 terminators), and nothing says it is there.
Destination `nowhere` ⇒ the rule says **write it**. Filed to **TASK-158**, which is retitled *two*
comments that should exist and don't.

Reverted and redone in binary: CR count 320 → 316, accounting exactly for the four removed lines, the
`\r` verified byte-by-byte, and the diff genuinely comment-only (38 lines, not 319).

**Recorded rather than quietly fixed** because the interesting part is not the mistake — it is that a
repo whose only gate is this script cannot detect its own extractor being broken. That is a stronger
argument for the missing comment than the comment's absence was.

- 2026-09-20 — Gates: lint OK (19 skills); suite 56 passed, 0 failed.
- 2026-09-20 — **The sweep took the script from 3 `AGENTS.md §` pointers to 8**, which is the test plan's named risk stated as a number. Both steps now running: two comment readers, and two script-alone readers for the local-readability question TASK-154 first asked.

### Human test plan, step 2 — **pass, 2 of 2, and it was the step at risk**

The sweep took the script from **3 `AGENTS.md §` pointers to 8**, and the plan named the consequence
as the thing to watch: *"the file now says less than a reader needs locally."* Two readers were given
**the script and nothing else** — no guide, so neither could follow a single pointer.

| Required | Reader 1 | Reader 2 |
|---|---|---|
| names check 6 as unable to fail the build | ✅ | ✅ |
| names the other five as able | ✅ | ✅ |
| derives it from the code, not the comment | ✅ | ✅ |

Both reduced it to *"does this check body call `err` or `suberr`"*, traced `exit "$fail"` to its three
assignment sites, and noted the absence of `set -e`. Reader 2 put the relationship exactly the right
way round: ***"the banner and `:195` assert this, but the function body is the proof."*** The comment
is a signpost; the code carries the verdict. That is criterion 2 satisfied at the strongest reading.

**Both found nuances nobody prompted for**, which is how you tell a reader from a confirmer: check 5's
*no pair* branch prints and passes rather than erroring, and check 4 silently `continue`s when neither
`verbs/<verb>.md` nor `SKILL.md` exists for the referenced skill — so an invocation naming a
non-existent skill is skipped, not reported. Both also cited `:14-17`, the subshell comment TASK-159
repaired, as the explanation for the FAILFILE indirection.

**So eight pointers did not hollow the file out.** The reason is the shape criterion 2 forced: only
the *shared* half moved. `FATAL` and `ADVISORY` remain the first word of their headers, and the three
mechanics that live nowhere — `grep -qF` prefix-matching, `grep -o` stopping at the first flag, and
deriving the tree from the path — are all still local.

### Human test plan, step 1 — reader P: **all eight gone, pointers and survivors intact**

None of the eight appears in P's violations. It goes further and clears the things a naive read would
flag:

- **the three pointers** — *"the ADR-shaped content (ADR 0010 at `:205`, FEATURE-002 D13 at `:158`) appears as one-line pointers"*
- **TASK-151's four survivors** — `:122-131` cleared with the reasoning (*"the violation is nine of ten lines restating the name … a dense regex whose whole design is which tokens may sit between verb and flag is exactly that case. Not a finding. Length is never one."*), plus `:14`, `:44` and `:255` in its cleared list
- *"No changelog, no QA log, no rationale essay by the section's definitions. Nothing is dated."*

#### It caught a contradiction this task introduced, and the cause is instructive

`:114` reads *"Match any `/word verb --flag`"*; my rewritten `:117` read *"Matching **only**
`/skill verb --flag` missed …"*. Those are **different axes** — the first is the skill-name axis (any
word, not a hard-coded list), the second the argument-shape axis — but they use near-identical
notation three lines apart, and P read them as contradicting.

**The cause was removing a duplicate without checking what it was holding up.** The original sentence
*"An argument may sit BETWEEN the verb and its flag, and an invocation may carry MORE THAN ONE flag"*
was a genuine restatement of the guide and had to go — but it was also the **antecedent** that told a
reader which axis the next sentence was about. Cutting a restatement can strand the sentence after it.
Fixed by dropping the confusable token entirely: *"An earlier, narrower pattern required the flag to
follow the verb immediately and stopped at the first one."*

#### Findings routed, not absorbed

| Finding | Owner |
|---|---|
| `:214` names check 4 where it means this check, and check 6 is what runs last | **TASK-081** — and P adds the sharpest evidence yet: *"This is the single numbered one, and it is the single wrong one"*, every other cross-reference in the file having been converted to names |
| `:290`'s closing clause restates the `if`/`else` below it | **TASK-158** (its `:295-296`, offsets moved) |
| `:77` *"Aliased links … never skipped"* — `cut -d'|' -f1` on the next line says the first half | **TASK-158**, new; P's own call is trim to the invariant, not delete |
| `:123-129` narrates its measurement with **no pointer**, where `:105` and `:117` both use one | **TASK-158**, and this is a **better framing of the 4:2 dispute** than "is it a rationale essay": the file is internally inconsistent about measurements, which is checkable |
| `:23` `RUNTIME_REFS` — and **the surrounding spaces are load-bearing** for the `*" $link "*` match at `:81` | **TASK-158**, a detail neither earlier reader found |

### Reader Q — step 1 confirmed, and two more defects in this session's own work

None of the eight appears. Q names **`:104`, `:156-158`, `:195-196`, `:205-207` as *"the model"*** —
instruction plus a named section, no restated rationale — which are precisely the sites TASK-154 and
this task rewrote. It also clears the `ARG_RE` block for length, quoting the carve-out.

**Q found the fix inconsistent with itself.** I made two corrections for the *same* rule in one
sitting, and they diverged:

| Site | Shape |
|---|---|
| `:244-246` | pointer, **then only** the local consequence — Q calls this *"the compliant shape"* |
| `:112` (before) | pointer **plus** *"would go quietly stale the day a skill is added"* — which is the guide's rationale, restated beside the pointer meant to replace it |

Q caught it by citing my own `:244` back at me. **A rule applied twice in one file, ten minutes apart,
came out two different ways** — which is what criterion 2 exists to prevent, arriving from inside the
fix rather than from the code being fixed. `:112` now matches `:244`.

**And `:9`'s back-reference was wrong on arrival.** TASK-159 added *"Named, not numbered, for the
reason two lines above."* Two lines above is the **fenced-block** paragraph; the reason is the
inventory paragraph four lines up. A positional reference that rotted before it was ever read — in
the same header whose subject is that positional references rot. Now: *"for the same reason the
banners are not restated above."*

#### Three self-inflicted defects, one per verification pass

| Defect | From | Caught by |
|---|---|---|
| `:114`/`:117` notation collision | **this task** | P |
| `:9` back-reference to the wrong paragraph | TASK-159 | Q |
| `:112` pointer *plus* the rationale it replaces | **this task** | Q |

The first has the most transferable cause: **cutting a restatement stranded the sentence after it.**
The removed line was a genuine duplicate *and* the antecedent that told a reader which axis the next
sentence was about. Worth carrying into TASK-158's sweep, which removes more of the same shape.

#### Routed, not absorbed

- **`:126`'s four alternatives are the four alternations of `ARG_RE` on the line below, in order** —
  destination *the code itself*. **This is a sharper framing of the 4:2 dispute than five earlier
  readers reached**: not *"is this a rationale essay"* (unresolvable by argument) but a specific,
  checkable claim about one sentence. → **TASK-158**, which owns that block.
- `:214` — Q independently confirms the hazard runs the **other way**: `check_root` assigns both in
  its own loops, so without `local` it is this function that clobbers the outer ones. → **TASK-081**.
- `:9` and `:112` fixed here; both are this session's own output.

### Verdict — human test plan passes, 4 readers

| Step | Result |
|---|---|
| 1 · the eight gone, pointers unreported, survivors intact | ✅ **2 of 2** |
| 2 · a reader with the script alone can still tell what gates the build | ✅ **2 of 2**, both deriving it from the code and not the label |
