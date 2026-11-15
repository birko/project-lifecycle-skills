---
id: TASK-084
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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
picked-by: fix-next
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

**A third instance, 2026-09-01.** `verify.md` § *Pathspecs are not globs* has owned the `:(glob)` rule
since it was written, with its own measurement — 47 of 74 source globs in one aggregator had files at their
root, 124 files the check could never see. `init` and `regen` resolve globs too and were never told. A cold
drill hit it from the other side: `**/*.props` matches a root-level `Directory.Build.props` under
gitignore semantics and not under strict `fnmatch`, which flipped 3 files in Presenter and 3 in Latent
between mapped and unmapped. **Three instances now, in three different verbs of two skills, all the same
shape: a rule established with evidence in one place and absent from its siblings.** That is the argument
for this task; the porcelain case was never the whole of it.

**The hard part is deciding where such a check lives, and that is the actual work.** `skills-lint-test.sh`
tests the *lint*, not skill semantics, so dropping a git fixture in there needs a stated reason or it
becomes a junk drawer. Two shapes worth weighing, and the answer may be "neither, and here is why":
a third script alongside the lint (a `skills-behaviour-test.sh` for rules that are executable), or a
narrow lint assertion that this specific bullet states a non-empty rule rather than a prefix list.

**Scope it deliberately — do not turn this into a harness for prose in general.** The category is narrow
and worth naming precisely: *a skill instruction that names a shell command and a rule for reading its
output*. Most skill prose is judgement and cannot be pinned; this kind can, and conflating the two is how
the task becomes unshippable.

## Decision (2026-11-15, the user)

**No CI check; the reason recorded; and a rule aimed at the pattern all three instances share.**
- **Why not CI:** the rule is prose an agent reads, and CI cannot run prose. A script (option A) would test its own
  shell copy of the rule and stay green while `LAYER.md` regressed. A lint tripwire on the sentence (option B) would
  catch a literal revert but fail every legitimate rewording. A command-plus-reading-rule instruction is pinned by
  a cold drill against its recorded cases, and for the porcelain rule those are the seven in the table above.
- **The rule that targets the pattern:** a rule fixed in one verb is searched for in its siblings in the same change.
  The `init` floor and the `:(glob)` rule were each fixed in one verb and missing from its siblings, and the
  porcelain rule was fixed one part at a time.

## Acceptance criteria

- [x] The seven-case classification is executable and runs in CI, or a **stated, reasoned decision** records why it should not be — silence is not an outcome — the stated, reasoned decision above: not in CI
- [x] If it runs: it fails when the reading rule is reverted to a prefix list (the split above is the acceptance evidence, not a nice-to-have) — not applicable: nothing runs in CI, by decision
- [x] The category it covers is defined narrowly enough that the next reader knows what does **not** belong in it — `AGENTS.md` § Testing: an instruction naming a shell command and a rule for reading its output, *not skill prose in general*
- [x] Whatever is chosen, `AGENTS.md` § Testing says it exists — a second test entry point nobody records is a gate nobody runs — it does, and names the seven cases as the porcelain rule's drill
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass — lint OK (20 skills), lint tests 90/90

## Out of scope

- Re-fixing the porcelain rule — **TASK-027** did that; this is only about what stops it regressing.
- A general test harness for skill prose. See the scoping paragraph above; this covers command-plus-reading-rule instructions only.
- **TASK-029** (nothing records what the lint's own cases pin). Adjacent — both are "our tests do not explain themselves" — but that one is about documenting existing cases and this is about a category with none. Cross-reference; do not merge.

## Human test plan

_Rewritten 2026-11-15 by the Decision. The two steps it replaces ("revert the rule and confirm what was built goes
red", "confirm it stays green") tested a CI mechanism, and none was built._

- [x] Give a cold runner a task fixing a rule in one verb, in a repo where the same rule sits in sibling verbs, and
      confirm it finds and fixes them
  - **Passed 2026-11-15**, cold runner: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d084`, the cwd holding only `brief.txt` and an invented repo (this `AGENTS.md`; a `digest`
    skill whose `daily` and `weekly` verbs, and a separate `standup` skill, all count commits by a `feat:`/`fix:`
    prefix; a task naming `daily` alone); the coldness probe listed no skills. It fixed all three, citing the rule.
    Its one reading, that the rule pulls against *never widen the task in hand*, was settled in the same change: a
    sibling fix is the same fix, named in the task's Outcome.

## Implementation plan

Inline, from the decision above.

## Outcome

- **`AGENTS.md` § Working rules:** *a rule fixed in one verb is searched for in its siblings, in the same change*,
  with the three measured instances, and the line saying it does not widen the task.
- **`AGENTS.md` § Testing:** a command-plus-reading-rule instruction is pinned by a cold drill, never by CI, with why,
  and with this task's seven cases as the porcelain rule's drill.
- **No CI change, no skill file changed.**

**Close gate (inline; `AGENTS.md` only):**
- **Standards:** two rulebook entries, each with its reason inline.
- **Intent:** all criteria met, two by the decision.
- **Correctness:** d084.
- **Layer parity, security, comments:** not applicable.
- **CI:** lint and lint tests pass locally; main is unpushed.
- **Specs:** none affected.

## Progress log

- step 2 — picked; a decision task, in the user's order (after TASK-001)
- step 4 — decided by the user 2026-11-15: option C
- step 5 — two AGENTS.md entries
- step 6 — behavioural: d084 (the scope tension settled after it); lint and lint tests green
- step 7 — no spec affected
- step 8 — closed inline; commit in git log
