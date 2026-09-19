---
id: TASK-141
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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
