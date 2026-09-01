---
id: TASK-068
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
picked-by: fix-next
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# The cold drill — write down the one test method that works on prose

## Context

**Filed at epic level, not under STORY-016**, because this is method rather than a defect in one
subject: it changes how *every* skill's human test plan gets run.

### What happened

TASK-053's `## Human test plan` was run on 2026-08-22 as a **cold drill**: a fresh agent was given the
repo and told to *execute* the changed skills as written — with the test plan's **expected answers
withheld** — then to report what the prose led it to, plus every place it had to decide something the
instructions did not settle.

All four drills passed. The pass **additionally surfaced ten defects** in the surrounding skills, seven
of which are now TASK-061 to TASK-067, one appended as evidence to TASK-035, and this one.

### Why the method matters more than that yield

This repo's product is **prose an agent reads**. The failure mode is therefore not a crash — it is a
sentence that carries its meaning only for someone who already knows the intent. **The author cannot test
for that**, because they cannot un-know the intent. Measured instance from the same gate: the author's own
pass over the `(lazy)` rows reached the right answer and would have reached it whether or not the prose
earned it; the cold agent's arrival at `not applicable yet` from the table marker alone is what actually
established that the traversal works.

**Withholding the expected answers is the whole mechanism.** TASK-053's plan said *"confirm the survey
says `not applicable yet` rather than `missing`"*. Handed to the drill verbatim, that sentence converts
the test into a confirmation — the agent knows the target and reports hitting it. Rewritten as *"carry out
the survey and report the state you assigned to each row"*, the same run becomes evidence. The plan and
the brief are therefore **two different documents**, and nothing currently says so.

### What it costs, honestly

One subagent run per drill, several minutes, and a brief that has to be written rather than pasted. That
is not free, and it is not warranted for every task — a six-word deletion does not need a cold reader.
The judgement about **when** it earns its cost is the interesting part of this task and should not be
skipped in favour of "always do it".

### A brief-construction rule the 2026-09-01 drills produced

**A rule that cites a named file in a named repo cannot be independently drilled on that repo.** The
`/specs init` coverage rules justify a classification with a measured example — *"an `appsettings.json`
carrying `Fetch.*`, `Session.*` and `Database.*` settings consumed by three existing areas is defensibly
either"*. That example describes **one real file in `Presenter`**. A cold drill run against Presenter then
met the exact file the instructions had already adjudicated, and said so: the instructions *"pre-loaded
the example I was being asked to classify"*, so its judgement was not independent.

**The fix is not to strip the example.** Measured justification is this repo's whole style and the example
earns its place — it is what stopped `coverage-drift` being a bare count. The rule belongs to the *brief*:
when drilling a rule that names a repo, pick a different one, and say in the report which repo the rule
already speaks about. That is one more thing the drill brief has to decide, alongside withholding the
expected answers.

**Cheap to get wrong in the other direction, too.** Two of this session's drills were run on fixtures the
author built to exhibit the defect; one of them (an `engine/*.rules` repo meant to defeat source
discovery) simply failed to — the runner read the README and recovered. A fixture built by the author
tests the author's model; a real repo the rule does not name is the stronger instrument.

### The loose thread

The ten findings were given ids `DRILL-053-*`, and `DRILL-*` is **not** one of the four prefixes
`intake` defines (`CR-*` / `SEC-*` / `SH-*` / `VC-*`) or that `AGENTS.md § Working rules` lists. A drill
is genuinely a different source from a diff read — it produces behavioural findings by execution — so
either the prefix gets registered or the ids get remapped. Leaving an unregistered prefix in shipped
frontmatter is the register-on-introduce gap this repo lints for.

## Acceptance criteria

- [x] The cold-drill method is written down where a reader of a task's `## Human test plan` will find it — what it is, and that the brief withholds the plan's expected answers
- [x] The distinction between **the plan** (states the expected outcome, for the author) and **the drill brief** (withholds it, for the runner) is explicit, with the reason
- [x] A stated test for **when** it is warranted, and when it is over-ceremony — not "always"
- [x] The brief shape is recorded concretely enough to reuse: execute-and-report, report where the instructions were ambiguous, report what had to be inferred. The last two produced the ten findings and are the part most likely to be dropped
- [x] ~~`DRILL-*` is either registered as a finding prefix (`intake`'s table **and** `AGENTS.md`'s list, in the same change — the field is shared) or the existing `DRILL-053-*` ids are remapped, with the choice reasoned~~ **Corrected 2026-09-01 before any editing** — `AGENTS.md` carries **no** prefix list (its only `findings:` mention, at `:290`, is the outside-a-pool rule and names no prefixes). The list actually lives in **three** places, all under `skills/tasks/`: `verbs/intake.md:52-55` (the table), `templates/TASK.md:12` (the frontmatter comment) and `SKILL.md:273` (the owned-fields list). So the criterion was one location short *and* wrong about one it named. Replaced by the two rows below.
- [x] `DRILL-*` is registered, or the existing ids remapped, with the choice reasoned — and the registration reaches **every** place the list is currently written, not the two the original criterion guessed
- [x] The list has **one owner** afterwards and the other places point at it, since three copies is why adding a fifth prefix is a three-file change — the repo's own *never restate a shared inventory's lists* rule applied to itself
- [x] Wherever it lands, it does not restate what `populate-tests` or `close` step 5 already own — a pointer, not a third copy of the human-test-plan rules
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The seven drill findings themselves — TASK-061 to TASK-067 under STORY-016.
- Automating the drill. Whether a verb should orchestrate it is a separate question, and answering it before the method is even written down is the wrong order.
- Changing `close` step 5's existing automate-before-you-accept-a-manual-step rule. This is about how a step that stays manual gets run, not about which steps qualify.

## Human test plan

- [x] Take an unrelated task with a real human test plan, write a drill brief from it using only what this change records, and confirm the brief withholds the expected answers without losing what must be exercised
- [x] Have someone who did not write this read the method and say when they would *not* use it — if that answer is "never", the warranted-when test is not doing its job

## Implementation plan

_Populated by `/tasks plan TASK-068` — leave empty until then._

## Outcome

**What the fix was.** This repo's `AGENTS.md § Testing` has always required a **drill** as a skill's real
test, and never said what one is. Nine drills this session produced the method by practice; it is now written
down in `skills/populate-tests/SKILL.md` § *The cold drill*, beside § *Prove the guard can fail* because they
are siblings and explicitly not the same act — one proves a **regression test** can fail, the other proves the
**prose** can be followed. And `DRILL-*` is registered as a finding prefix, which it had needed since the
first drill and needed six more times this session.

**The mechanism, stated as the mechanism.** A `## Human test plan` says *"confirm the survey reports X"*;
handed to a runner verbatim, that converts the test into a confirmation. So **the plan and the brief are two
different documents** — the plan states the expected outcome because that is what makes it checkable, the
brief never does. Everything else in the section follows from that one asymmetry.

**Registration beat remapping, and not narrowly.** The four existing prefixes each name the *pass* that
produced a finding — a code review, a security review, a spec harvest, a conventions lint. A drill produces
findings by **executing the prose against a reader denied the answer**, which none of those describes.
Remapping would have filed nine drills' findings under a pass that never ran, and lost provenance on roughly
thirty ids across five tasks. Registering cost three files today and one from now on, because the list got an
owner.

**The step-6 split is mechanical on the registration half:** prefix-list copies went from **3 at `HEAD` to 1**
(`intake.md` keeps the table; `templates/TASK.md` and `tasks/SKILL.md` are pointers). A sixth prefix is now one
row, and adding `DRILL-*` was the demonstration. `skills-lint` OK (18 skills), `skills-lint-test` 43/43 —
neither can observe a prose rule, so both are **contract pins, not evidence**.

**Two criteria were wrong and were corrected before any editing.** The task required registering in
*"`intake`'s table and `AGENTS.md`'s list"*. `AGENTS.md` has no such list. The list lived in **three** places,
none of them `AGENTS.md`. So the criterion was wrong about one location and short by two — amended on the
task, before code, rather than quietly building something else. That triplication was itself a live instance
of this repo's *never restate a shared inventory's lists* rule applied to itself, and fixing it was in scope
because registering a fifth prefix is what exposed it.

**The drill of the method found five holes in it, all fixed here.** Both plan items passed — the runner wrote
a usable brief that withheld every expected answer while keeping everything that had to be exercised, and
answered *when would you not use this* with **nine** concrete cases, each sourced from the text with an
alternative. But writing that brief forced it to invent five things I had claimed were covered:

1. **"Reusable as it stands" was an overclaim.** The five rows are prompts, not text. The heading says so now.
2. **A setup step can leak the axis on its own**, and my withholding rule covered only the expected outcome
   and target contamination. *"Make an unrelated edit, staged and again unstaged"* announces the subject, and
   the state cannot be built without saying so. The line that works: **provenance mechanically, never the
   classification**.
3. **"Has not seen the change" is a starting state, not a prohibition** — and, in the runner's words, it
   *"expires at the first `git log`"*. Now an explicit bar, audited by row 5.
4. **Nothing said what a runner does with a question the prose raises.** The supplied plan turned on an
   *offer*; a runner that actually asks either stalls or is handed the answer. Now: write it out verbatim and
   continue as if unanswered — often the question is the finding.
5. **Matching the report back to the plan is the author's step, and nothing said it exists.** It is also where
   a discounted result must stay **unticked** rather than ticked with a caveat beside it, because *"a caveat
   disappears, an unticked box does not"* — the runner's phrasing, kept.

Plus a sixth, which matters because I have been doing it all session without writing it down: **leave the
target as you found it.** Four of five consumer repos here carry someone's uncommitted work, so a drill that
must dirty the tree takes a clone or worktree, and one that only reads says read-only in the brief.

**Judgement calls, and the stricter option rejected.**

- **The method landed in `populate-tests`, not in `close` or `tasks`.** `close` step 5 *runs* a human test
  plan; `populate-tests` owns how tests get made — so the method is a sibling of *Prove the guard can fail*
  and both gates point at it. Rejected putting it in `close`: a gate carrying its own method is how `close`
  grew the duplicate copies this repo keeps trimming.
- **Two pointers, not one.** The TASK template's `## Human test plan` note is where a reader of a plan
  actually looks; `close` step 5 is where the gate decides. Criterion 1 named the first; the second is where
  the decision happens.
- **The warranted-when test is a question, not a checklist.** *Could a careful reader, without knowing what I
  intended, reach a different answer?* Rejected a rule count for the reason TASK-095 warns against one: a
  threshold turns a judgement into a wrong answer with a number attached. The table gives both columns so the
  question has anchors.

**Flagged, not fixed.** Two of the runner's eight gaps were deliberately left: **whether one brief or three**
when a plan has several scenarios — it chose one, reasoning that cross-cutting questions asked three times let
the first answer contaminate the rest, which is sound and not yet worth a rule; and **how to enumerate
candidate targets**, which is fleet-specific and would date immediately. Recorded here rather than in the
section, because a rule invented for a case that has arisen once is the kind this repo keeps deleting.

## Progress log

- step 2 — picked, and the ranking genuinely changed rather than my having flagged it three times. This task kept losing on **key 4**: its central question — *when is a cold drill warranted, and when is it over-ceremony* — was an open judgement with no data, and `fix-next` prefers a defect with no open design question. **Nine drills this session answered it empirically**, so the thing that disqualified it is now the thing it can document. Secondary and self-inflicted: this session minted `DRILL-035-*`, `063-*`, `091-*`, `093-*`, `094-*` and `096-*` into shipped frontmatter against a prefix registered in neither `intake`'s table nor `AGENTS.md` — six violations of this repo's own register-on-introduce rule, all mine, in tasks I filed. **Honest counter-argument, recorded because it is real:** this is still not a defect, nothing produces a wrong answer, and on strict blast radius TASK-097 and TASK-086 both beat it. Chosen anyway because its cost is rising while its evidence decays — and because the evidence is nine independent runs that will not be reconstructible from five scattered task records.
- step 3 — verified: held, with **one criterion corrected before editing and one gap it did not know about.** The method is genuinely unwritten: `populate-tests/SKILL.md` has eight `##` sections and none is about drills; § *Prove the guard can fail* is about proving a **regression test** can fail, which is a different act from executing prose against a cold reader. **Correction:** the criterion named *"`AGENTS.md`'s list"* and there is no such list — `AGENTS.md:290` mentions `findings:` only in the outside-a-pool rule. **Gap it missed:** the prefix list has **three** copies (`intake.md:52-55`, `templates/TASK.md:12`, `SKILL.md:273`), so registering a fifth prefix is a three-file edit — and that triplication is itself a live instance of this repo's *defer to a shared inventory, never restate its lists* rule. Criteria amended accordingly, before code, per `fix-next` step 3.
- step 3a — **registration beats remapping, and the reasoning is not close.** The four existing prefixes name the *pass* that produced a finding: `CR-*` a code-review, `SEC-*` a security review, `SH-*` a spec harvest, `VC-*` a conventions lint. A drill finding is produced by **executing the prose against a reader who was denied the answer** — none of the four describes that, so remapping would file nine drills' worth of findings under a pass that never ran. The measured cost of registering is three files today and one after the list gets an owner; the cost of remapping is permanent provenance loss on 30-odd ids across five tasks.
- step 4 — layer: local.
- step 5 — fix in five files. **`skills/populate-tests/SKILL.md`** gains § *The cold drill*, placed beside § *Prove the guard can fail* because they are siblings and explicitly not the same act — one proves a regression test can fail, the other proves the **prose** can be followed. It carries: the plan-versus-brief table (the withholding mechanism); the brief's five-row shape, with rows 3-5 marked as where the yield is and the paired *what did the instructions settle for you* inverse that makes an absence meaningful; target selection, including that **contamination is per question, not per repo**, that an **A/B on one unchanged target** is the strongest form, and that a contaminated drill still yields a conclusive negative; and the warranted-when table plus its one-question test. **Registration:** `intake.md`'s table gains a `DRILL-*` row and is declared the **only** list, with `templates/TASK.md` and `tasks/SKILL.md` rewritten as pointers — so the three copies became one and a future prefix is one row. **Pointers, not copies:** the TASK template's `## Human test plan` note (where a reader of a plan actually looks) and `close` step 5 (the gate that runs it) both point at the method; `AGENTS.md § Testing` already mandated a drill without defining one and now points too.
- step 6 — reverted fix: **the registration half has a real mechanical split.** Prefix-list copies, measured across the three files: **3 at `HEAD`, 1 now** (`grep -c "SEC-\*"` → `intake.md:1`, `templates/TASK.md:0`, `tasks/SKILL.md:0`). So a sixth prefix is one row, where a fifth was three edits — and the `DRILL-*` row itself is the demonstration, since adding it touched exactly one list. `skills-lint` OK (18 skills). **The method half is prose and its guard is a drill of itself**, which is the human test plan; both plan items are folded into one run, because item 1 (write a brief from an unrelated plan using only what this records) and item 2 (a reader who did not write this says when they would *not* use it) test the same property — whether the record is sufficient without its author present.
- step 6a — drill brief design. Target is the **method section**, not a repo, so the fixture-contamination rule does not bite; what bites instead is that **I wrote it**, which is exactly what the method says an author cannot test around. Withheld: that "never" would be a failing answer to *when would you not use this* (asked flat, with no hint that a wrong answer exists); the plan supplied is `TASK-086`'s, chosen because it is **unrelated to drills** and concerns git porcelain states, so nothing in it rehearses the method; and the runner is told the target project's product is markdown instructions without being told which project or shown its tasks. Exercise 2 asks the contamination question **as a scenario** — *"what if the only suitable target were one the change's own text discusses by name"* — rather than asking whether such a rule exists, so a runner who missed the rule cannot pass by recognising the phrase.
- step 7 — respecced: skipped, documented branch. `docs/specs/.map.yml` carries `areas: []`; `/specs init` is TASK-079. Requirements changed: none.
- step 8 — three-axis gate. **standards — pass.** Rulebook `AGENTS.md § Conventions`, rung 1; five skill files plus `AGENTS.md`, 0 excluded. The change *removes* two restated lists rather than adding any, and every new cross-reference is a pointer. Layer parity n/a — no `LAYER.md` row changed. **Register-on-introduce: no new entry owed, and it was checked rather than assumed.** `AGENTS.md § Testing` already mandated the drill and now points at the method instead of gaining a second copy; `DRILL-*` needs no `AGENTS.md` row precisely because the prefix list now has one owner in `intake.md`. **fidelity — pass**, every criterion built including the two amended ones; the only scope beyond them is the three-copies collapse, which registering the prefix required. **correctness — five findings, all fixed inline** (see Outcome). **security-review — not applicable:** six markdown files; no auth, data access, input handling, crypto, secrets or dependency surface. 5c skipped — `integration: single-branch`. 5d: the `## Out of scope` bullets are boundaries naming TASK-061..067 plus two deliberate limits; nothing spawned.
- step 8a — drill passed both plan items; `in-progress` → `done`. Recursive by design, and it earned it: drilling the drill method found five holes in the method, which is the section's own *expect the drill to find something in the change itself* claim demonstrated on itself.
