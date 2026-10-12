---
id: TASK-273
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-90, SH-95, SH-100]
pr: null
github-issue: null
jira-key: null
---

# Ask-steps in `tdd`, `populate-tests`, `domain` and `roll-changelog` state no question or no answer-less path

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

AGENTS.md § *Output / prose rules* requires every ask-step to carry the question actually put **and** what the run does when no answer comes.
- **SH-90 (partly confirmed):** `skills/tdd/SKILL.md:83-90` has its question text (`:90`) but no answer-less path. `skills/populate-tests/SKILL.md:15` ("offer to seed the convention first") has neither.
- **SH-95:** `skills/domain/SKILL.md:36` ("offer to start one") and `:85` ("Offer one") have no question text and no answer-less path. `:50` has its question but no answer-less path.
- **SH-100:** `skills/roll-changelog/SKILL.md:20`, `:44`, `:52`, `:57`, `:61` and `:65` ask with no question text and no answer-less path. `:44` ("ask the user what shipped") is the riskiest: with no answer, the run has no source of work at all.

The same defect class as TASK-229, TASK-230, TASK-247 and TASK-259, in four more skills; one PR can fix all four.

## Acceptance criteria

- [x] Every ask-step in the four skills quotes the question it puts
- [x] Every ask-step states what the run does when no answer comes, as a reported unresolved state, never a value that reads as decided
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ask-steps in other skills (their own tasks)

## Human test plan

- [x] Run `/roll-changelog` in a scratch repo with nobody answering, and confirm it ends in the stated unresolved state rather than stalling or inventing an answer
      **Passed 2026-10-12** as a cold drill. Command: `claude -p --disable-slash-commands < brief.txt`, run from `C:/Source/WebChecker`, which has no agent guide. Coldness check: `SKILLS-SEEN: none`. The skill text was inline in the brief, and the repo was described rather than built: not git-tracked, a `CHANGELOG.md` with one Unreleased `Added` bullet over `## [1.4.0] - 2026-08-30`, every task `todo`, no date given, and nobody answering. The runner ran `/roll-changelog` and then `/roll-changelog release`. It ended with `nothing rolled: no record of shipped work since [1.4.0] - 2026-08-30` and `release not cut: 1.5.0 suggested, nobody confirmed`. It wrote nothing, invented nothing and did not stall. The repo was described, not built, because the plan's subject is what the run decides with nobody answering, and that needs no file the runner could actually write.

## Implementation plan

_Populated by `/tasks plan TASK-273` — leave empty until then._

## Outcome

**What changed.** Eleven ask-steps cited by the harvest, and two more found beside them, either gave no question text, gave no outcome for a run where
nobody answers, or both. AGENTS.md § *Output / prose rules* requires both. Each one now quotes its question and
ends without an answer in a reported state with no write:
- `tdd`: the plan question now carries the agent's own proposal. With no answer, it writes no test and reports
  `not confirmed: …`. This also covers the checklist's "Get user approval on the plan", which is the same ask.
- `populate-tests`: the offer to seed the testing convention. With no answer, it seeds nothing, carries on with
  the inferred stack, and reports `§ Testing: absent, not seeded; …`.
- `domain`: the cold path's offer to start a glossary (with no ambiguous term found, there is no offer). The
  same-or-different question, which reports the pair unresolved. The ADR offer, now placed after the tests table
  it depends on, which reports `ADR candidate, not written: …`.
- `roll-changelog`: the offer to seed a missing CHANGELOG, the "what shipped" question, the suggested version,
  the version-scheme question, the date, and the tag offer. Each ends in a named `not …` report and no write. The
  "what shipped" step now reads the trackers first and asks only when they show nothing. A version passed to
  `release` is the user's statement and is no longer confirmed a second time.
- Respecced: `changelog-maintenance` (six clauses and one scenario), `test-authoring` (two clauses; the plan
  requirement's "the prose defines no outcome" sentence is now the outcome), and `glossary-and-adrs` (three
  clauses).

**Step-6 split.** Both runs were cold drills (`claude -p --disable-slash-commands`, run from
`C:/Source/WebChecker`, both `SKILLS-SEEN: none`) on one brief: an unattended `/roll-changelog` and then
`/roll-changelog release` on a described repo with no git history, nothing done, and no date. The brief carried
`roll-changelog/SKILL.md` from `HEAD` (before the fix) or from the working tree (after it). **The write outcome
did not split: both runners wrote nothing on both invocations.** What split was what each runner had to supply
itself:
- **Before:** the runner invented its own question wording (version and date merged into one question). It
  flagged two gaps ("the skill doesn't say what to do when a required confirmation never comes") and reported in
  its own words.
- **After:** the runner put the stated questions, reported in the stated shapes, and flagged no gap in the
  no-answer behaviour.

So the fix-dependent evidence is the two flagged no-answer gaps and the invented question text, not a wrong write.
This runner already played it safe, and another runner given the old text might not. The lint passes either way,
so it is a contract pin, not evidence. The `tdd`, `populate-tests` and `domain` changes were checked by reading
against the rule, not drilled.

**Judgement calls.**
- **Every no-answer path in `roll-changelog` writes nothing.** A changelog is published text, and the gentler
  alternative of writing a value marked as unconfirmed (the shape the ask-step rule allows for a field that
  cannot be absent) does not apply. No line of a changelog has to exist, and a marked line still reads as a claim
  about what shipped.
- **`populate-tests` carries on with the inferred stack instead of stopping.** The stack is derived from files
  the repo holds, while the convention is a rulebook somebody has to approve. So only the seeding waits for a
  person, and the report says the stack was inferred.
- **`tdd` stops before RED instead of testing its own proposal.** A test fixes the interface as a contract, and
  that is the decision the question exists to hand to the user.

**Flagged, not fixed.** Both runners noticed an existing Unreleased bullet that nothing backs. That is not a
defect: the skill traces the bullets it writes, and an entry already there is someone else's statement. TASK-274
owns how a roll treats bullets already in Unreleased. Nothing was spawned.

**Merge gate (close step 5b, run inline, each verdict on its own):**
- *Standards*: pass. Each ask-step has both halves, and each no-answer outcome is a reported unresolved state.
  Placeholders in question text are named tokens, not unrendered template tokens. No new cross-cutting pattern.
- *Fidelity*: pass. Criteria 1 and 2 cover every cited line plus the two pulled-in asks, and criterion 3 is lint
  OK. Out of scope (ask-steps in other skills) was left untouched.
- *Correctness*: one finding, fixed before commit. The ADR offer first sat between the bar sentence and the
  table defining the bar, and it now follows the table.
- *Security* and *Comments*: not applicable, because the diff touches no security surface and carries no code
  comment.

## Progress log

- step 2 — picked; ranked above TASK-299 because with nobody to answer roll-changelog has no source of work and can invent what shipped into a published changelog, reachable on every unattended run of four skills (keys 1-3), and it was checked by a second reader (key 5); TASK-299 is a round-trip gap on hybrid Jira projects only. Key 6 not needed: both correctness-invariants
- step 3 — verified: held at every cited line (tdd :90 has its question, no answer-less path; populate-tests :15, domain :36 and :85, roll-changelog :20 :44 :52 :57 :61 :65 have neither; domain :50 has its question only). Pulled in, same root cause in the same files: tdd's checklist item "Get user approval on the plan" (the same ask as :90) and roll-changelog's confirm when `release` is given a version
- step 4 — layer: local
- step 5 — fix in skills/tdd/SKILL.md, skills/populate-tests/SKILL.md, skills/domain/SKILL.md, skills/roll-changelog/SKILL.md; evidence is a cold drill, not a test file (prose)
- step 6 — reverted fix (HEAD roll-changelog text, same brief, cold runner): no write either way; before = invented question wording + 2 flagged no-answer gaps, after = stated questions + stated report shapes, 0 gaps; fix-dependent = that pair; contract pins = skills-lint.sh; tdd/populate-tests/domain checked by reading only
- step 7 — respecced changelog-maintenance, test-authoring, glossary-and-adrs; requirements changed: seed offer, boundary order (and its scenario), semver suggestion, cut a release, tag offer; plan-with-the-user, read the convention; cold path, sharpen synonyms, offer a record
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
