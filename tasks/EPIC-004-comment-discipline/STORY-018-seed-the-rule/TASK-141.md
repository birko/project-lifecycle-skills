---
id: TASK-141
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
priority: P1
assignee: unassigned
created: 2026-09-18
depends-on: [TASK-140]
blocks: [TASK-146]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Adopt the comment rule in this repo, with the lint-script measurement that protects it

## Context

Implements FEATURE-002 **D10, D11**. AGENTS.md states that this repo eats its own cooking: *"Every
rule below is a rule these skills impose on their consumers. If a rule is impractical here, that is
evidence the rule is wrong — fix the skill, don't exempt the repo."* So the rule TASK-140 ships to
consumers belongs in this repo's own § Conventions too.

**The two halves must land in the same change, and that is the whole point of this task.** Adding
the rule means the next `/verify-conventions` run judges this repo's own scripts by it — and
`.github/workflows/skills-lint.sh` is 288 lines with 123 comment lines (42%) and one unbroken
35-line block. Under a length cap it is a pile of violations. Under this rule it passes, because
nothing else in the repository records what those lines say: the comment at `skills-lint.sh:222`
explaining why `##` and not `#` is used for prefix removal is what FEATURE-001's worktree-location
design was reasoned from.

So the measurement is recorded **as a measurement**, not as an exemption. An exemption would say
*this file is special*; the record says *this file was measured against the rule and passes*, which
is a claim a later reader can re-check and, if the rule changes, must re-run rather than re-quote.

Registering the rule here is also the register-on-introduce convention doing its job: a
cross-cutting pattern introduced by a change gets recorded in § Conventions in that same change.

## Acceptance criteria

- [x] `AGENTS.md` § Conventions carries the rule, in the same shape TASK-140 wrote for consumers — no second, drifting copy of the wording.
- [x] The entry follows this file's own convention for rulebook entries: rationale inline, and it says whether it has a decision record (it does — FEATURE-002) rather than leaving a reader to wonder.
- [x] The `AGENTS.md` copy is delimited by the **same `<!-- comment-rule:start/end -->` markers** as `templates/CONVENTIONS-universal.md` (repointed at close: TASK-140 shipped them in `CLAUDE.seed.md`, from where TASK-147 moved them). Without them TASK-146's check finds a block on one side only — which its own criterion says must fail loudly, so the gate would block on a gap this task was never told to close.
- [x] The `skills-lint.sh` measurement is recorded with its numbers (288 lines / 123 comment lines / 42% / longest block 35 lines) and the date measured, plus the statement that it **passes** the rule and why.
- [x] The record says explicitly that a change to the rule's wording invalidates the measurement and requires re-running it, not re-quoting it.
- [x] The rule is applied to this repo's scripts **directly**, per file, with the verdict and the reason recorded. (Repointed at close. As written this criterion asked for `/verify-conventions` to report no finding against `skills-lint.sh` — which it never could, because it lints **the diff** and that file is not in it. The criterion passed trivially, testing nothing. Third instance of this shape in EPIC-004, after TASK-140's "the only numeral" and TASK-147's "all six rules present", which the control also passed.)
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The consumer template — TASK-140.
- Actually editing any comment in `skills-lint.sh`. The measurement's conclusion is that it needs no change; a diff that touches it has misread the task.
- Building the command — STORY-019.

## Human test plan

- [ ] Run `/verify-conventions` over this diff. Expected: it reports the new convention as registered, and raises **no** comment finding against `skills-lint.sh` or `install.sh`.
- [ ] Ask a cold runner (same acquisition rules as TASK-140) to apply this repo's `AGENTS.md` § Conventions to `.github/workflows/skills-lint.sh` and report violations. Expected: none, and the reasoning cites that nothing else records what those comments say — not the recorded measurement, which the runner should not need in order to reach the same verdict.
- [ ] Expected failure mode to watch for: the runner passes the file only because it read the measurement. That means the rule alone does not actually exonerate the file, and the rule — not the record — is what needs fixing.

## Implementation plan

**Deliberately skipped, not forgotten.** The shape was fully determined before work started by this
task's own criteria plus D13: copy the delimited block from `templates/CONVENTIONS-universal.md`
byte-for-byte, add the measurement, place it to mirror the seed's position. A plan would have restated
the criteria. Recorded here because `pick` flipping a task to `in-progress` over a placeholder plan is
otherwise indistinguishable from skipping the gate by accident — raised by `/code-review` at this
close, and a fair catch.

## Progress log

- 2026-09-20 — **Reopened `done` → `review` on the user's instruction**, after `/feature status FEATURE-002` surfaced that this task closed with all three of its manual checks unticked. Not a hand-flip of a status: the reopen is recorded here with its reason, and the task re-closes only through `/tasks close` once the plan has actually been run.
  - **Why this one matters more than an ordinary skipped check.** Step 2 asked a cold reader to apply the rule to `skills-lint.sh` and report violations. It was never run. Run months later under TASK-151, that same check found **four** real findings in that exact file — one of them (`the header enumerating four of six checks`) already wrong on the day this task closed. TASK-154 still holds two more. So the skipped step is not hypothetical debt; it is the specific test that would have caught the specific defects that shipped.
  - **The expected result recorded in the plan is now known to be wrong.** It says *"Expected: none."* That expectation was the thing under test and it failed. Re-running is therefore not a formality — the question is whether the **rule alone**, without this repo's measurement table, reaches the same verdict a reader reaches with it.

### Test plan run — 2026-09-20

**Step 1 — `/verify-conventions` over `4d40e2a`. Half passes; the other half could never have failed.**

- *"reports the new convention as registered"* — **pass.** The diff adds § Comments to `AGENTS.md`
  between the `comment-rule` markers and registers it in the same change, which is what
  register-on-introduce asks for.
- *"raises **no** comment finding against `skills-lint.sh` or `install.sh`"* — **vacuous, not passing.**
  `4d40e2a` touches `AGENTS.md`, two feature docs, two task files and `tasks/README.md`. It does not
  touch either script. `verify-conventions` is diff-scoped by construction, so it was never capable of
  reporting on those files, and this clause would have read "pass" no matter what state they were in.

**That vacuity is the finding, and it is the same blind spot twice.** A diff-scoped check cannot see a
file nobody is changing — which is the gap [[review-comments]] was later built to close, and the reason
step 2 below asks a reader to look at the whole file instead. A test plan step whose expected result is
unreachable by the tool it names is not a weak test; it is a test that reports success without having
run. Worth carrying into how such steps are written, not just this one.

**Step 2 — design, stated before the results so the verdict cannot be fitted to them.**

The step asks a cold reader to apply the rule to `skills-lint.sh`. Step 3 names the failure mode to
watch for: *"the runner passes the file only because it read the measurement."* That is only
detectable by **varying the measurement**, so two runners were given deliberately different guides:

| Runner | Guide | Mentions of `skills-lint.sh` in it |
|---|---|---|
| A | `## Conventions` + the comment rule spliced from `CONVENTIONS-universal.md`, nothing else | **0** |
| B | this repo's whole `AGENTS.md`, measurement table included | **12** |

Both got the identical brief, `--disable-slash-commands` so neither could reach for
[[review-comments]] and test the command instead of the rule, and `--permission-mode plan` so neither
could edit. **The expected result recorded in this plan — "none" — is already known to be false**
(TASK-151 found four, TASK-154 holds two still open), so the live question is no longer *does the file
pass* but *does the rule alone reach the same verdict as the rule plus the record*.

**Step 2 + 3 — result. The recorded expectation was false, and the failure mode step 3 named did not occur.**

| | Runner A (rule only) | Runner B (full guide) |
|---|---|---|
| verdict on the file | **violations found** | **violations found** |
| count | 4 + 1 accuracy aside | 3 + 3 minor + 1 accuracy aside |

**Step 3's question answers cleanly, and in the rule's favour.** The failure mode to watch for was
*"the runner passes the file only because it read the measurement."* **Neither runner passed it.** A had
**zero** mentions of `skills-lint.sh` in its guide and still indicted the file on the rule alone. So the
rule is doing the work; what failed was the *measurement* claiming the file passed, and the skipped test
that would have said so a month earlier.

**Step 2's recorded expectation — "Expected: none" — is now measured false twice over.** It was written
believing the file compliant. It never was.

#### My A/B contrast is confounded, and the confound is mine

**Fixture A removed more than the measurement: it removed the rest of the rulebook.** A's guide was
`## Conventions` + the comment rule and nothing else — so § Testing, § Architecture and D13 were absent,
and a comment "restating § Testing" had nothing to restate *from*. That fully explains why B found
`:199-203` and `:159-162` (TASK-154's two) and A did not: those destinations did not exist in A's repo.
It is **not** evidence that B was reading the answer off the measurement table.

The clean design isolates one variable: **the whole `AGENTS.md` minus the measurement table only.**
Recorded rather than quietly re-run, because the headline result does not depend on it — both runners
indicted the file — and because a confounded comparison presented as a clean one is the same defect as
a vacuous step reported as a pass.

#### The two disagree about a comment I wrote, in opposite directions

`skills-lint.sh:4-5`. **A calls it version history** — *"'went stale twice … four of six' is `git log`"*.
**B explicitly keeps it** — *"a prospective rule against re-adding the check list, not a changelog"*.

**A is right, and the line is mine.** TASK-151 deleted a stale check enumeration and replaced it with a
sentence recording *that it had gone stale twice and how*. That is a changelog, written into the same
commit whose subject was comment discipline, and it passed three close-gate axes plus a
`/review-comments --all`. A cold reader with no context caught it in one pass.

#### New findings neither TASK-153 nor TASK-154 owns

| Site | Destination | Found by |
|---|---|---|
| `:4-5` | version history — **introduced by TASK-151** | A |
| `:105-106` | the ticket / git — state at introduction | **both** |
| `:108-109` | the rulebook (`AGENTS.md:279`) and `:146-148`, where it is already a proper pointer | B |
| `:212-214` | § Architecture / ADR 0010 — same class the table hands TASK-148 for `pi-install.sh`, in a file nobody had checked for it | B |
| `:259` | provenance — *"which is what the comment above has always claimed"* | A |
| `:290-292`, `:296-297` | the drill measurement, stated twice six lines apart | **both** |

**`:290` is live-wrong, not merely restated:** it says *"Naming all 16 skills"* and the lint prints
**19**. A restated count that has already gone stale — the defect this repo lints for, sitting inside
the lint.

#### TASK-081's premise is backwards, and both runners found it independently

`:222` justifies two `local` declarations with *"so check 4 cannot clobber them"*. **Check 4 never
touches `tree` or `d`** — they are loop variables at `:51` and `:60`, and the exposure runs the other
way: an unlocalised `check_root` would clobber *them*. TASK-081's criterion assumes the run-order claim
is **stale**; it is **wrong**, which is a different fix. Two independent readers reached this with no
shared context.

#### Where the run leaves this task

**Stays at `review`.** The three steps have now genuinely been executed and their results recorded,
including that step 1's second clause was unfalsifiable and step 2's recorded expectation was false.
But this task's purpose was to establish that `skills-lint.sh` is compliant, and it is not: six sites
go to **TASK-157**, two remain with **TASK-154**, and one accuracy defect amends **TASK-081**. Closing
to `done` now would re-assert exactly the claim this run disproved.

It closes when those are drained and a re-run finds the file clean — on a fixture carrying the whole
guide **minus the measurement table only**, which is the isolation this run did not achieve.

## Out of scope

- The six new comment findings — **TASK-157**.
- `:159-162` and `:199-205` — **TASK-154**, confirmed again by runner B.
- `:222`'s backwards run-order premise — **TASK-081**, criterion amended rather than re-filed.
- The comment rule's wording — FEATURE-002 D1/D2, settled.

### Why the three boxes above stay unticked — TASK-161

The plan **was run**, in full, and step 2 **failed**: it expected *"none"* and two readers found nine
things. The boxes stay `[ ]` because ticking them is what lets `close` flip `review → done`, and a
ticked box on a failed step would have closed this task today on a test that found nine defects.

Leaving them unticked is also wrong, and knowingly so: `/feature review` Gate B now reports this task
as *"3 unrun steps"*, beside five tasks whose plans genuinely have never been run. The one plan in
this feature that **was** executed is indistinguishable from the five that were not.

**The convention has two writable states and three real ones.** Filed as **TASK-161** against the
skills themselves rather than worked around here — it governs how every consumer records
verification, so a local fix would leave the ambiguity in every repo that installs these skills.


## Re-run — 2026-09-20, after the blockers cleared

TASK-157, TASK-158, TASK-160 and TASK-148 are all `done`, which is the condition this task recorded
for its own closure. Re-running the plan against the current tree.

### Step 1 — settled as **structurally vacuous**, not re-run

The first run recorded that *"raises **no** comment finding against `skills-lint.sh` or `install.sh`"*
names two files absent from the diff, checked by a diff-scoped tool. **That is a property of the
step, not of the tree**, so re-running it would produce the same non-answer. It is answered instead
by widening step 2 below, which is what the clause was reaching for.

The other half — *"reports the new convention as registered"* — passed on the first run and the
convention has been in `AGENTS.md § Comments` under the markers ever since; lint check 5 asserts it
byte-for-byte on every run since TASK-146.

### Step 2 — widened to the scope step 1 named, and then some

**Fixture** `t141re-t` / `-u`: the whole `AGENTS.md` **minus lines 403-447 only** (the measurement
table), plus **all six scripts** — `skills-lint.sh`, `skills-lint-test.sh` and the four installers.

**Two reasons for the wider scope.** Step 1 named `install.sh` and no cold reader has ever been shown
the installers — TASK-148 changed all four headers on my reading of two ADRs, with no independent
check. And TASK-141's own measurement table covered six scripts, so a re-run scoped to one would
re-commit the original error of asserting more than was examined.

**What the first run's expectation was, and why it is not restated here.** It said *"Expected: none."*
That was false then — nine findings — and predicting *none* now would repeat the mistake, not correct
it. The honest expectation is: **the sites those four tasks fixed do not come back, and anything new
is new.** Four readers have swept `skills-lint.sh` since; the last pair still found three things, all
since fixed but never re-verified together.

**Step 3 remains the thing to watch**, and the fixture is built for it: with the measurement table
removed, a reader cannot pass the file by citing a verdict someone else recorded.

### Re-run, reader U — three findings, two verified, one a question about work committed an hour ago

**The `ARG_RE` deadlock is broken, and not by argument.** Five readers had split **4:3** on whether
`skills-lint.sh:123-131` is *"a rationale essay above a declaration"* — a judgement neither side could
settle. U found something checkable instead: **the block duplicates the test file.**

| U's claim | Verified |
|---|---|
| the fixture pins the very sentence the comment quotes | ✅ `skills-lint-test.sh:175` is `The /beta go step runs before the --nosuch cleanup in your log.`; `skills-lint.sh:127` quotes it |
| the test's own comment carries the same reasoning | ✅ `skills-lint-test.sh:169-170` — *"This check is fatal, and prose is not a diff anyone can fix, so a false positive here is worse than the gap being closed"* — which is `skills-lint.sh:123-124` almost word for word |

So the destination is **the code itself**: the rejected alternative, its failing sentence, and the
reason it fails all live in `m_flagprose` and its comment. That is a row-1 finding, and it makes the
essay question moot rather than resolving it.

**A QA log nobody had reported, in the file TASK-141's own measurement blessed.**
`skills-lint-test.sh:6`: *"A review of the first version found eight defects; every one has a case
here."* A past review event and its count — the QA-log row exactly. Six readers have looked at these
scripts and none flagged it, because none had been asked to read `skills-lint-test.sh`. **That is the
cost of the original scope error**, and the reason this re-run was widened.

**And U challenges TASK-148, committed an hour ago.** It reports `pi-install.sh:3-4` /
`pi-install.ps1:2-3` as *"content restated above its own pointer"* — the `must NEVER be linked into
~/.claude/skills` sentence sitting directly above `Why that tree is pi-only and frozen: ADR 0010`.

**U put it as a question rather than a verdict**, which is the right shape: *"cut it to the pointer,
or keep it as a deliberate exception because it sits where the mistake would be made?"* TASK-148's
criterion 2 asserted the constraint *"must survive in full"* — **U is challenging that criterion's
premise, not just my edit.** Held for reader T rather than answered alone.

**One non-finding, correctly caught by U as a fixture artifact:** 29 `AGENTS.md §` pointers with no
`AGENTS.md` in the tree. It exists in the real repo; U flagged it as needing confirmation rather than
reporting it, which is the right call on a partial checkout.

### Re-run, reader T — confirms U, and finds five more nobody had looked for

**2 of 2 on the `pi-install` header**, which reverses a criterion I wrote. T: *"restates ADR 0010 one
line above the pointer to it … by the guide's test it is a copy with the pointer already present."*

**TASK-148's criterion 2 said the constraint "must survive in full". It was wrong**, and I was the
one who wrote it. The *fact* survives — `skills-pi/` is never linked into `~/.claude/skills` — but
*"where the real built-ins live"* is § Architecture's and ADR 0010's, sitting directly above the
pointer to both. Reduced in both files. Reversing my own criterion on two independent readers is the
correct weight; reversing it on one would not have been.

**T confirms the QA log and catches that it has rotted**, which U did not: *"the first version"*
against `:271`'s **"Regressions from the second review pass"**, and *"eight defects"* against a suite
that now runs **56** cases. Verified both.

**Five more, all in `skills-lint-test.sh`** — `:4-5`, `:41-42`, the negative-assertion rationale at
three sites, `:284-286`, `:50-52` — plus two comments naming things that do not exist
(`check_silent` for `case_silent`; "check 4" where `case_silent` greps check 6). All verified. Filed
as **TASK-162**.

### Verdict — this task does not close

Its own condition was *"a re-run finds the file clean"*. It does not. **Nine findings survived six
previous readers**, and the reason is the one thing this re-run changed: every earlier sweep was
scoped to `skills-lint.sh`, while TASK-141's measurement claimed **six scripts examined**.

**That is the defect this task has been carrying all along**, and it is larger than any comment in
it: the measurement asserted more than was examined, and no gate could see the difference. The
original run found the *table* answered the wrong question; this run finds it also answered it over
the wrong scope.

`blocks: TASK-141` is recorded on TASK-162. This task re-closes when that drains and a third re-run
finds all six scripts clean — **not when the count reaches zero on one of them.**

**"Clean" defined, 2026-09-24, by František Bereň:** *no finding raised by both of the two cold
readers.* A finding one reader raises and the other passes is recorded here, not filed as a blocker.
Why the definition was needed: four drills in one day (TASK-162, -163, -164) each surfaced new items,
each round smaller than the last — the last round's were comments restating the line beside them. Read
as "zero findings from anyone", the condition measures how much a reader can find to say at the
margin, and never terminates. Agreement between two independent readers is what separates a finding
from a taste. Status of the dependencies at the time: TASK-162, TASK-153, TASK-163, TASK-164 and
TASK-081 done; TASK-165 open.

### The `ARG_RE` block — settled by evidence, for whoever takes it

Five readers split 4:3 on *"is it a rationale essay"*. U found the checkable answer instead: the
block duplicates `skills-lint-test.sh`'s own comment at `:169-170` and quotes the fixture sentence at
`:175`. Destination **the code itself**. The judgement question is moot, and the evidence is in this
record rather than in anyone's opinion.
