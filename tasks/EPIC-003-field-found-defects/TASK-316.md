---
id: TASK-316
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-DD-1]
pr: null
github-issue: null
jira-key: null
---

# fix-next's tie scenario never states what happens when nobody answers

## Context

Raised by the spec harvest of defect-draining (2026-10-13). `skills/fix-next/SKILL.md` step 2 states the tie question and its answer-less path (take the lower id, log that nobody chose). The harvested scenario *Keys exhausted* says the run "stops to ask which to take" and never states the unattended outcome, which the source does define. The harvester kept it verbatim under the stable-wording rule; the gap is that the source's own example of the tie reads as a halt.

## Acceptance criteria

- [x] The source states the tie's unattended outcome where it describes the tie, so a regenerated scenario carries it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ranking keys themselves

## Human test plan

N/A — wording only; fix-next's tie path is unchanged.

## Outcome

**What was fixed.** `/fix-next` step 2 already defined what happens when its top two candidates tie on every ranking key and nobody answers the tie question: take the lower id and log that nobody chose. But key 8's paragraph, where the source first describes the tie, said only "reach it and *say* the keys were exhausted". A harvest of that paragraph then produced the spec scenario *Keys exhausted*, which read "stops to ask which to take", a halt that contradicted its own requirement. Key 8's paragraph now states that the run asks one question and, with nobody to answer, takes the lower id without halting, pointing at the branch below for the question and log line.

**Step-6 split: 0/0.** The change is wording only and the behaviour is unchanged, as the `N/A` test plan says. `skills-lint.sh` passes (20 skills): a contract pin, not evidence.

**Judgement calls.**
- **A pointer, not a copy.** Key 8's sentence names the outcome and points at the branch that owns the question text and log line. Repeating them there would make a second copy to drift.
- **The spec scenario was fixed in the same change**, not left for the next harvest. It contradicted its own requirement, so the spec was wrong now, not merely stale. I added a separate scenario for the no-answer case instead of rewording the interactive one away.

**Respec.** `defect-draining`: scenario *Keys exhausted* now says the run asks, naming its fallback, and *Keys exhausted with nobody to answer* is new. The requirement text was already correct. The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-314 because a scenario that reads as a halt contradicts its own requirement and misleads every reader of the spec (key 3: a plausible wrong answer), while TASK-314 is a one-sentence alignment with no reader yet misled; key 6 inert — both sit under EPIC-003 with no theme
- step 3 — verified: held, narrower than titled: SKILL.md step 2 already defines the answer-less path (take the lower id, log it) and the spec requirement states it; the gaps are key 8's paragraph, which describes the tie as "reach it and say the keys were exhausted" with no outcome, and the harvested scenario *Keys exhausted*, which still reads "stops to ask"
- step 4 — layer: local (skills/fix-next/SKILL.md)
- step 5 — fix in skills/fix-next/SKILL.md (step 2, key 8); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — wording only, behaviour unchanged; fix-dependent = none; contract pins = skills-lint.sh
- step 7 — respecced defect-draining; requirements changed: none (scenario *Keys exhausted* corrected, +1 scenario); intended anyway — TASK-316's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
