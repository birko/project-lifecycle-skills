---
id: TASK-068
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: agent
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

- [ ] The cold-drill method is written down where a reader of a task's `## Human test plan` will find it — what it is, and that the brief withholds the plan's expected answers
- [ ] The distinction between **the plan** (states the expected outcome, for the author) and **the drill brief** (withholds it, for the runner) is explicit, with the reason
- [ ] A stated test for **when** it is warranted, and when it is over-ceremony — not "always"
- [ ] The brief shape is recorded concretely enough to reuse: execute-and-report, report where the instructions were ambiguous, report what had to be inferred. The last two produced the ten findings and are the part most likely to be dropped
- [ ] `DRILL-*` is either registered as a finding prefix (`intake`'s table **and** `AGENTS.md`'s list, in the same change — the field is shared) or the existing `DRILL-053-*` ids are remapped, with the choice reasoned
- [ ] Wherever it lands, it does not restate what `populate-tests` or `close` step 5 already own — a pointer, not a third copy of the human-test-plan rules
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The seven drill findings themselves — TASK-061 to TASK-067 under STORY-016.
- Automating the drill. Whether a verb should orchestrate it is a separate question, and answering it before the method is even written down is the wrong order.
- Changing `close` step 5's existing automate-before-you-accept-a-manual-step rule. This is about how a step that stays manual gets run, not about which steps qualify.

## Human test plan

- [ ] Take an unrelated task with a real human test plan, write a drill brief from it using only what this change records, and confirm the brief withholds the expected answers without losing what must be exercised
- [ ] Have someone who did not write this read the method and say when they would *not* use it — if that answer is "never", the warranted-when test is not doing its job

## Implementation plan

_Populated by `/tasks plan TASK-068` — leave empty until then._
