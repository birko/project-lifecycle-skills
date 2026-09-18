---
id: TASK-147
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: unassigned
created: 2026-09-18
depends-on: []
blocks: [TASK-145]
findings: [DRILL-145-1]
pr: null
github-issue: null
jira-key: null
---

# The scaffolder paraphrases the seed's universal rules instead of copying them

## Context

Found by TASK-145's human test plan on 2026-09-18, then narrowed by a second measurement. **The
defect is that the scaffolder does not render `CLAUDE.seed.md` — it composes a guide of its own,
using the seed as inspiration. What survives varies run to run.**

**Two data points, and they disagree, which is the finding.**

| Run | The three static subsections | Fidelity of what survived |
|---|---|---|
| `flappy-dragon`, scaffolded 2026-07-17 (a real consumer repo) | all present | **paraphrased** — 7 of the seed's 8 Working-rules bullets, sentences rewritten, *"Task-first gate (hard):"* against the seed's *"(hard rule):"* |
| cold drill, 2026-09-18 (`claude -p`, empty directory, TypeScript CLI) | **all three absent** | n/a — `## Conventions` held five subsections, all token-bearing ones, filled with real content |

So the earlier claim on this task — *"every project scaffolded by this skill to date is affected"* —
was **wrong, and is corrected here**. It was written from the drill alone, before the consumer repo
was checked.

**What the drill dropped**, measured by grep, zero hits each: the Comments block TASK-140 had just
shipped, `### Keeping conventions current (register-on-introduce)`, `### Working rules`, and with the
last of those the task-first gate, plan-before-implementing, the generated-files rule, the
status-changes rule and the no-`Co-Authored-By` rule.

**Why non-determinism is worse than consistent failure, not better.** A guide that always lost its
working rules would have been found years ago by the first person who looked. A guide that usually
keeps a close paraphrase and occasionally drops three subsections produces repos that differ from each
other for no recorded reason, and nothing detects it: [[verify-conventions]] lints against whatever the
guide happens to say, so a missing task-first gate simply never enforces one, and a *paraphrased* rule
still lints — against subtly different words than every other project in the fleet.

**The preserve-list's wording was never the mechanism.** TASK-145 was filed on the premise that
`SKILL.md`'s *"leave the register-on-introduce + working-rules sub-blocks as-is"* named two sub-blocks
and would go one short now a third exists. The reasoning is sound and the reworded sentence is already
in, and it changes nothing here: in the drill run both sub-blocks it named **by name** were dropped
too. An instruction to leave something as-is has no effect on an agent that is not copying in the first
place.

**One thing the drill run got right, worth not breaking while fixing this**: told *"don't ask me
questions, pick sensible answers"*, the runner still refused to default `integration:` and reported it
unresolved instead. That is TASK-127's fix working under exactly the pressure it was built for.

## Acceptance criteria

- [x] A scaffold run produces a `CLAUDE.md` whose `## Conventions` contains every subsection of **`templates/CONVENTIONS-universal.md`**, byte-identical and *inside* `## Conventions`. (Criterion repointed at close: it named `CLAUDE.seed.md`, which this same change emptied of those subsections — the same class of defect as TASK-140's criterion 5, a criterion written before the design it describes.)
- [x] The three token-bearing subsections are still filled with real, stack-appropriate content — the fix must not turn a rendered guide back into a template full of `{{…}}`.
- [x] The mechanism is stated in `SKILL.md` in a way that cannot be satisfied by writing a fresh guide that happens to cover similar ground: rendering the template is the instruction, not a suggested starting point.
- [x] `docs/BRIEF.md`, `README.md` and the other seeded artifacts are checked for the same defect — the template-vs-freehand question is not specific to `CLAUDE.md`, and assuming it is would leave the same bug in three more files.
- [x] Blast radius recorded — see § Context. One scaffolded consumer repo exists (`flappy-dragon`); it kept the subsections as a paraphrase rather than losing them, so no remediation pass is warranted on the fleet today. The other consumer repos were **adopted**, not scaffolded, and carry their own hand-written guides, so they are outside this defect entirely.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The preserve-list's wording — TASK-145, already done and correct; it stays.
- Backfilling already-scaffolded consumer repos — measured and **not needed**: the one scaffolded repo kept its rules, in paraphrase. Revisit only if a future scaffold ships and loses them.
- [[adopt-project]] — it reconciles artifact shape, not document prose (D5).

## Human test plan

- [x] Re-run TASK-145's drill: a cold `claude -p` scaffold into an empty directory, brief naming only the project. Expected: the generated `CLAUDE.md` carries `### Comments`, `### Keeping conventions current` and `### Working rules` with their text intact, **and** Framework/stack, Naming and Testing filled with real TypeScript content.
- [x] Repeat for a second, very different stack (a Python library, say). Expected: the same three static subsections survive byte-for-byte while the token-bearing ones differ completely. A fix that preserves them only for the stack it was tested on has not been tested.
- [x] Grep the generated guide for the six rules listed in § Context. Expected: all six present. This is the assertion that actually fails today — write it before the fix and watch it fail, per [[populate-tests]] § *Prove the guard can fail*.

### Attempt 1 — prose rule, 2026-09-18: **FAILED its own drill**

**What was tried.** A `- **"Render a template" means copy the file, then edit only its `{{…}}` lines**`
rule inserted in `skills/new-project/SKILL.md` ahead of the artifact list, governing every template,
with the 2026-09-18 measurement inline and a "diff what you wrote against the template" check.

**Bidirectional assertion, three runs scored on the same script.** Static subsections present, of the
seed's three; byte-identical, of three; and how many of the six universal rules appear anywhere.

| Run | Subsections | Byte-identical | Rules |
|---|---|---|---|
| BEFORE (the TASK-145 drill, pre-fix) | 0/3 | 0/3 | 0/6 |
| AFTER — TypeScript CLI | **0/3** | 0/3 | 2/6 |
| AFTER — Python library | **0/3** | 0/3 | 2/6 |

**The rule count moved 0 → 2 and the structural failure did not move at all.** Both runs invented
their own headings — TypeScript wrote `### Universal rules`, Python wrote `### Standing rules` under a
different `##` heading — and neither carries `### Comments`. The agent clearly *knows* universal rules
belong in the guide; it is writing them from `SKILL.md`'s description of the template rather than from
the template.

**Why the fix was insufficient, and what that rules out.** Prose telling the agent to copy is competing
with prose telling it to *fill each subsection with real content*, and the second is more specific,
more actionable, and sits closer to the work. Adding a third instruction saying "no, really, copy"
would be a fourth voice in the same argument. **Rewording alone is not the fix** — two stacks,
independently, ignored an instruction that was explicit, measured and placed first.

**Options not yet tried**, for whoever picks this up:
- Make the copy a **numbered, ordered step that happens before the guide's contents are described at
  all**, so the file exists on disk before anything invites composing.
- Remove the invitation: rewrite *"actively fill each subsection"* to name **only the token-bearing
  subsections**, so nothing licenses touching the others.
- Give the agent a literal command to run rather than an instruction to follow.
- Stop shipping the universal rules in the template at all — have the seeded guide reference them.
  Rejected on a first pass: a consumer install cannot see this repo, and a machine-local path is
  fragile. Recorded so it is not re-proposed without that objection.

The assertion script and all three generated guides are kept under the session scratchpad; the BEFORE
copy is `BEFORE-fail-CLAUDE.md`.

### Attempt 2 — shrink the instruction, 2026-09-18: **ALSO FAILED**

**What was tried**, on the diagnosis that `SKILL.md` described the template well enough to substitute
for reading it: deleted the content description, cut attempt 1's rule from twelve lines to two, made
the first action a literal `cp`/`Copy-Item` against the skill's own base directory, and scoped
*"actively fill each subsection"* to the token-bearing ones only. **`SKILL.md` got 17 lines shorter** —
the constraint set in advance, on the theory that adding prose was what failed the first time.

| Run | Subsections | Byte-identical | Rules | Leftover tokens |
|---|---|---|---|---|
| BEFORE (pre-fix) | 0/3 | 0/3 | 0/6 | 0 |
| attempt 1 — ts / py | 0/3 · 0/3 | 0/3 | 2/6 · 2/6 | 0 |
| **attempt 2 — ts / py** | **0/3 · 0/3** | 0/3 | 1/6 · 2/6 | 0 |

Attempt 2's TypeScript run scored **worse** on rules than attempt 1's (1/6 against 2/6). Both invented
top-level structure again: `## Non-negotiables`, `## Task-first gate` as an H2, `## Docs upkeep`,
`## Commits`.

**Conclusion, stated in advance of the run and now earned: prose cannot carry this.** Five runs, three
instruction shapes — describe-and-render, add an explicit copy rule, remove the description and command
the copy — and not one produced a copy. The scaffolder writes the guide from `SKILL.md` regardless of
what `SKILL.md` says about copying. Anyone reaching for a sixth wording is repeating a measured failure.

**Two mechanisms that are different in kind, neither tried:**

- **Split the template.** Move the token-free subsections into their own file with no tokens at all,
  copied wholesale into the new repo and pulled in by the guide (an `@import` line, the same bridge the
  AGENTS.md option already uses). A whole-file copy with nothing to edit is a far simpler instruction
  than "copy this and change fourteen lines", and the copy becomes trivially checkable. **This also
  answers the objection that killed the earlier version of this idea** — the file lands *in the
  consumer repo*, so nothing depends on a path back to this repo.
- **Verify at the end rather than instruct at the start.** Add a closing scaffold step that diffs the
  static part against the template and repairs any drift. Agents are markedly better at checking a
  finished artifact than at honouring a constraint while composing one, and every run above produced a
  guide that a two-line diff would have caught.

**Attempt 2's edits are left in the working tree**, not reverted: they are shorter, state the correct
intent, and are a strictly better starting point for either mechanism above. What they are not is
sufficient, and nothing here should read as though the defect is fixed.

### Attempt 3 — split the template, 2026-09-18: **PASSES**, and it invalidated attempts 1 and 2

**The harness was broken, and that is the headline.** A probe run
(*"read this path and say plainly whether you could"*) answered: **"Plainly: no, I was not able to
read it."** A child `claude -p` session may only touch its own cwd, so
`~/.claude/skills/new-project/templates/*` was refused on every attempt, and `-p` cannot prompt to
widen. **Every scaffold run above had no file to copy** — it composed from the injected `SKILL.md`
text because that was all it had. Which is why three different wordings scored identically: none of
them was testable. `--add-dir` fixes it, and **both** paths are needed, since `~/.claude/skills` is a
junction and reads resolve to `C:/Source/project-lifecycle-skills`. Recipe recorded in the
cold-runner memory.

**So this task's original premise was wrong, and the correction is the second one on this task.**
The claim was *"the scaffolder does not render the seed; every universal rule is dropped."* Under a
harness that can actually read the template, the **old** instruction already produced 3/3 subsections
and 6/6 rules. Nothing was being dropped in real use. `flappy-dragon` was the honest signal all along
and I discounted it.

**The real defect is paraphrase, and it reproduces.** Same read access, same brief, one variable:

| Run | Subsections | Verbatim | Rules |
|---|---|---|---|
| CONTROL — instruction at HEAD, TypeScript | 3/3 | **NO** | 6/6 |
| SPLIT — two templates, TypeScript | 3/3 | **YES** | 6/6 |
| SPLIT — two templates, Python | 3/3 | **YES** | 6/6 |

The control reproduces `flappy-dragon` exactly: every rule present, none of them in the seed's words.
Two independent observations three months apart, one of them today under controlled conditions.

**Why paraphrase is worth fixing even though nothing is missing.** [[verify-conventions]] lints each
project against the words its own guide happens to carry. Paraphrased rules mean every project in the
fleet is judged against slightly different text, and the divergence is invisible — each guide reads
perfectly well on its own. It also breaks D13's premise outright: a lint asserting two copies match is
worthless if consumers each hold a reworded third.

**The fix.** The token-free subsections moved to `templates/CONVENTIONS-universal.md` (no tokens at
all, nothing to fill), `CLAUDE.seed.md` keeps a marker where they belong, and `SKILL.md` states the
guide as two ordered file operations — copy-and-fill, then **append verbatim** — plus a closing diff
against the template. A whole-file append with nothing to edit removes the mixed-mode confusion that
produced the paraphrase.

**What is NOT claimed.** The split was not isolated from the closing verify step; both landed
together and the pair passes. Splitting them into separate assertions was judged not worth two more
scaffold runs, and this line exists so nobody later reads the result as attributing the effect to one
of them.

## Implementation plan

_Populated by `/tasks plan TASK-147` — leave empty until then._
