---
id: TASK-229
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-25, SH-30]
pr: null
github-issue: null
jira-key: null
---

# `fix-next`'s ask-steps carry no question and no answer-less path, in a skill built to run unattended

## Context

Found by the defect-draining spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). AGENTS.md § Output /
prose rules: an ask-step states the question actually put **and** what the run does when no answer comes. This
skill is the one most often run with nobody present (`--loop`, and unattended progress is its stated purpose).

- **SH-25 — three ask-steps lack both halves** in `skills/fix-next/SKILL.md`:
  - step 1, *Verification debt comes first*: "Offer to clear them first";
  - step 2: "Do stop and ask only if the top two are genuinely inseparable on every key above". Key 8's own text says
    this branch is routinely reachable, because `created` is a date and an intake files a whole pass on one day;
  - *Guardrails*: "a decision only the user can make … stop and ask with a concrete recommendation".
- **SH-30 — the verification-debt offer under `--loop` is undefined.** The loop continues "unless … a question is
  pending", and nothing says whether this offer is a pending question that halts the loop or is skipped.

## Acceptance criteria

- [x] Each of the three ask-steps states its question verbatim and its unattended outcome, which is a **reported
      unresolved state**: never a value that reads as decided, never silence
- [x] The inseparable-top-two path picks or stops deterministically when nobody answers, and says which key it ended on
- [x] Step 9's `--loop` stop conditions say whether the verification-debt offer counts as a pending question
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `/tasks pick`'s ask-steps — TASK-182
- `/fix-next`'s missing plan offer — TASK-135

## Human test plan

- [x] Cold drill, no user present: an invented fixture whose top two candidates tie on every key, plus one `verify`
      task. Two runners record the same outcome at each ask, and neither invents an answer
  - **Passed 2026-10-11:** `%TEMP%\d229` (TASK-003 and TASK-004 tie on keys 1–8; TASK-002 at `verify`). Two fresh
    `claude -p` runs, briefed only that the run is unattended. Both took TASK-003 with the log line `keys 1–8
    exhausted; took the lower id — nobody chose`, left TASK-002 at `verify` with nothing ticked and reported it as
    not cleared, and invented no answer. The runner holds the installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-229` — leave empty until then._

## Outcome

**The fix.** `/fix-next` had three points where it asked the user something without saying what to ask or what to
do when nobody answers. That matters most in this skill, which is built to run with nobody present. Each ask now
carries its question word for word and an outcome for when no answer comes:
- **Verification debt (step 1):** go on to the next defect and report each `verify` task as
  `awaiting verification, not cleared`. Never tick a step nobody ran. Asked once per invocation under `--loop`.
- **A tie on every key (step 2):** take the lower id and write `keys 1–8 exhausted; took the lower id — nobody
  chose`.
- **A decision only the user can make (§ Guardrails):** record the question, options and recommendation in the
  task, block it `decision pending`, and end the run through § *A run that ends without a fix*. The commit is
  `TASK-NNN: blocked — decision pending`, registered in AGENTS.md. Never apply the recommendation.

Step 9 now names which questions halt `--loop`: a scope escalation and a pending decision. The other two never
halt it.

**Step 6 split, stated exactly because it is weak.** Before the fix, both runs on the same fixture also took the
lower id and left TASK-002 alone. They worked out unattended answers of their own, one quoting "the skill says to
ask … nobody could answer". So the outcomes are **contract pins, not evidence**. **Fix-dependent:** only the
recorded wording, which matched across both fixed runs and was made up differently in each pre-fix run. The
decision path was not reached by any run, so it rests on the text. The fix rests mainly on the text itself: the
rule that an ask-step names its question and its unattended outcome is met only by writing them down.

**Judgement calls.**
- *The tie falls back to the lower id rather than stopping.* Stopping halts an unattended run on a coin-flip
  that has no wrong answer. The fallback is recorded as "nobody chose", the shape AGENTS.md § *Output / prose
  rules* gives for a value that must be written.
- *A pending decision blocks the task, not just the run.* Without the block, step 0 would resume the task next
  session and meet the same question again. Blocked, it shows up as `not resumed … decision pending: …` until a
  person answers.

**Flagged, not fixed.** Nothing new. Both fixed runs spawned a task about `RangeError` on huge arrays in the
fixture, which is fixture noise.

## Progress log

- step 2 — picked; ranked above TASK-230 because this skill is the one most often run with nobody present, so its three unworded asks are where an unattended run either stalls or invents an answer (keys 1, 3: an invented answer reads as decided), and the tie branch is reached routinely (key 2: key 8's dates tie across a whole intake); TASK-230's `/specs regen` asks run attended. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. Step 1 "offer to clear them first", step 2 "stop and ask only if … inseparable", and Guardrails "stop and ask with a concrete recommendation" carry no question text and no unattended outcome; step 9 names only a scope-escalation ask as halting `--loop`
- step 4 — layer: local (`skills/fix-next/SKILL.md`; `AGENTS.md` commit-subject contract)
- step 5 — fix in `skills/fix-next/SKILL.md`: verbatim questions and no-answer outcomes for the verification-debt offer, the tie, and the user-only decision (which blocks the task `decision pending` and ends through § *A run that ends without a fix* with commit `TASK-NNN: blocked — decision pending`); step 9 and Modes name which questions halt `--loop`. `AGENTS.md`: seven further commits. Lint green; drill 2/2 on `%TEMP%\d229`
- step 6 — reverted `SKILL.md`: pre-fix 2/2 also took the lower id and left the `verify` task alone, improvising the unattended answers; fixed 2/2 wrote the identical recorded line. Fix-dependent = the recorded wording only; contract pins = both outcomes; decision path not reached
- step 7 — respecced defect-draining (verification debt: question and unattended outcome + scenario "Nobody is present to answer"; ranking: tie question and lower-id fallback recorded as nobody chose; loop: which questions halt it; ending without a fix: the pending-decision exit and its commit); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
