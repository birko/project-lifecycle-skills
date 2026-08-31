---
id: TASK-084
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-31
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-027-1]
pr: null
github-issue: null
jira-key: null
---

# A documented probe-and-read rule has nothing that can pin it, and this one has been wrong twice

## Context

**Spawned from TASK-027's close gate on 2026-08-31.**

`LAYER.md`'s `present, uncommitted` state tells an agent to run a **concrete command** and read its output
by a **stated rule**. That pair is not prose in the ordinary sense — it is executable, and its correctness
is checkable by a machine. Nothing checks it, and the consequence is measured rather than theoretical:

- **TASK-018** fixed the rule, and it was still one column short.
- **TASK-027** fixed it again — the shapes list covered `??` and ` M` (unstaged only) while `A `, `M ` and
  `R ` (staged) fell straight through to plain `present`, silently dropping work that the next clone would
  not have.

Twice is a pattern, and the third recurrence has nothing standing in its way.

**The evidence already exists** — TASK-027's step-6 check built exactly the pin this task should make
permanent. Classifying seven real porcelain outputs under the old rule and the new one:

| Case | Porcelain | Old rule | New rule |
|---|---|---|---|
| new file, staged | `A  tasks/config.yml` | ❌ present | ✅ uncommitted |
| tracked modified, staged | `M  README.md` | ❌ present | ✅ uncommitted |
| staged rename | `R  a -> b` | ❌ present | ✅ uncommitted |
| modified, unstaged | ` M README.md` | ✅ | ✅ |
| untracked | `?? docs/BRIEF.md` | ✅ | ✅ |
| git-ignored | *(empty)* | ✅ present | ✅ present |
| no repo | *(empty)* | ✅ present | ✅ present |

**Split: old 4/7, new 7/7.** That ran once, in a scratch directory, and then vanished.

**A second instance, added 2026-08-31 from TASK-033's close.** `/specs init` step 4's coverage check had
the same shape: an instruction naming a scan and a rule for reading its result, with no floor, so an empty
scan set reported full coverage having examined nothing. The identical defect had already been found,
**measured** and fixed on the sibling verb (`regen` step 6: 0 own sources while the map's globs reached 97
sibling projects) and simply never applied to `init`. Nothing could have caught that — there is no
mechanism in this repo that notices when a rule fixed in one verb is missing from its sibling. Two
instances in two different skills is the argument for this task, not one.

**The hard part is deciding where such a check lives, and that is the actual work.** `skills-lint-test.sh`
tests the *lint*, not skill semantics, so dropping a git fixture in there needs a stated reason or it
becomes a junk drawer. Two shapes worth weighing, and the answer may be "neither, and here is why":
a third script alongside the lint (a `skills-behaviour-test.sh` for rules that are executable), or a
narrow lint assertion that this specific bullet states a non-empty rule rather than a prefix list.

**Scope it deliberately — do not turn this into a harness for prose in general.** The category is narrow
and worth naming precisely: *a skill instruction that names a shell command and a rule for reading its
output*. Most skill prose is judgement and cannot be pinned; this kind can, and conflating the two is how
the task becomes unshippable.

## Acceptance criteria

- [ ] The seven-case classification is executable and runs in CI, or a **stated, reasoned decision** records why it should not be — silence is not an outcome
- [ ] If it runs: it fails when the reading rule is reverted to a prefix list (the split above is the acceptance evidence, not a nice-to-have)
- [ ] The category it covers is defined narrowly enough that the next reader knows what does **not** belong in it
- [ ] Whatever is chosen, `AGENTS.md` § Testing says it exists — a second test entry point nobody records is a gate nobody runs
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- Re-fixing the porcelain rule — **TASK-027** did that; this is only about what stops it regressing.
- A general test harness for skill prose. See the scoping paragraph above; this covers command-plus-reading-rule instructions only.
- **TASK-029** (nothing records what the lint's own cases pin). Adjacent — both are "our tests do not explain themselves" — but that one is about documenting existing cases and this is about a category with none. Cross-reference; do not merge.

## Human test plan

- [ ] Revert `LAYER.md`'s reading rule to the prefix list and confirm whatever was built goes red
- [ ] Confirm it stays green with the rule as it stands

## Implementation plan

_Populated by `/tasks plan TASK-084` — leave empty until then._
