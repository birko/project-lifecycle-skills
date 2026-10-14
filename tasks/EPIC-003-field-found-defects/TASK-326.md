---
id: TASK-326
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-324-1]
pr: null
github-issue: null
jira-key: null
---

# `close`'s "reopen and re-close" never says what reopening resets, so a re-close over a ticked plan goes straight back to `done`

## Context

Found by TASK-324's cold drill (2026-10-14). Both runners raised it independently. `skills/tasks/verbs/close.md` step 4 says only *"Already `done` → warn, ask "reopen and re-close?" or abort."* Nothing says what reopening writes, or whether it resets the Human test plan. Step 5 asks *"Did you run "<step>"?"* only for steps that *"are not run"*, and a `[x]` step reads as passed. So by the letter, a re-close of a `done` task whose steps are all ticked goes straight back to `done`, and the user's fresh result (often the reason for reopening) is never asked for. Both runners worked around it by treating the user's report as a re-run. SKILL.md's *"Reopening resets the plan"* rule covers a feature change landing on a closed feature, not this case.

This is also the only path into TASK-324's park rollup, so as written that rollup is reachable only when a step already reads unrun.

## Acceptance criteria

- [x] `close.md` step 4 says what "reopen and re-close" changes before step 5 runs: which test-plan steps it resets to not run, if any, and why
- [x] A re-close in which the user reports a fresh failure reaches step 5's failed case by the text, not by inference
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The park rollup itself (TASK-324)

## Human test plan

- [x] Re-close a `done` task whose plan is ticked and say the step now fails. Expected: the run asks about the step, records the failure, and parks at `verify`, with no inference needed.
  - Passed 2026-10-14 as a cold drill (`skills/populate-tests/SKILL.md` § *The cold drill*), re-run on the final text after the review moved the reset into step 5. Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)"`, brief on stdin. The cwd was a no-remote scratchpad fixture, `d326-final`, holding copies of `SKILL.md` and `close.md`. The scripted user reports the failure only when asked, and the brief withheld the expected result. Coldness: the runner reported no skills. Result: it put "Did you run …?" (citing step 5's reset rule) and recorded `Reopened` then `Failed`. TASK-001 is now `verify`, and STORY-001 was reopened in the park commit.

## Implementation plan

Written by `/fix-next` after step 3, before the edits (it runs no `/tasks plan`):

1. `close.md`: a reopen resets every ticked step to not run with a dated `Reopened` line, reusing SKILL.md's reset, so step 5's existing question and its answer-less path do the rest. No new question.
2. Lint, a cold drill whose scripted user reports the failure only if asked, respec `work-tracking`.

## Outcome

- **The fix.** Reopening a closed task to re-close it used to leave every ticked test step ticked, so the close took the old passes as current, never asked whether anything had been re-run, and closed `done` again. Now, once the close has settled where it runs, reopening resets every ticked (or failed) step to *not run* with a dated `Reopened` line, and step 5's existing question asks about each one. Its answer-less path (*not run* → `verify`) is the safe outcome. Files: `skills/tasks/verbs/close.md` (step 4 pointer and no-answer path, step 5 reset), `skills/tasks/SKILL.md` § *Lifecycle* (one pointer), and the `work-tracking` spec.
- **Step-6 split (cold drill, original vs fixed `SKILL.md`/`close.md`; the scripted user reports the failure only if asked):** 3 of 3 outcomes flip. The fix-dependent ones are the step-5 question, the `verify` status, and the story reopen. The original runner closed `done` on the old tick and said why: "A `[x]` is passed … That rules out the test question entirely." Contract pins: the reopen question, the `ci:` line, the 5d count. A re-run on the final text gave the fixed result again.
- **Judgement calls.**
  - The fix resets every step instead of asking which ones to re-test. SKILL.md's reset rule already says a step you cannot tell about is reset, and a re-close says nothing about what moved. Rejected: a new "which steps are you re-running?" question. It would be one more ask-step to keep unattended-safe, while step 5's question already exists and fails safe.
  - The reset runs at the start of step 5, not in step 4. Review: step 4 runs before 4b, which promises nothing is written before it settles where the close runs (the same reason TASK-324 put its rollup at the park).
  - A step an automated check proved is re-run by the close rather than asked; a fresh pass gets a dated `Passed` line so the last line stays the current state; and a resumed re-close keeps today's passes. All three came from the correctness review.
  - Step 4's "reopen and re-close?" gained its no-answer path (abort, write nothing). That is a pre-existing gap on the same line, required by § *An ask-step carries … the answer-less path*.
- **Specs.** `work-tracking` respecced by `/fix-next` step 7 as a targeted edit, `generated-at` restamped, `shaped-by` carried (`feature: null`). Changes are *intended anyway — TASK-326's criteria, answered by /fix-next*, plus the review additions above.
- **Review gate.** Standards: pass. Its suggestions were applied: shorter marker wording, the SKILL.md pointer, and the no-answer path. Fidelity: criteria 1–2 built and no scope creep; criterion 3 (lint) was unchecked there and verified here as OK. Its minor note on a failed step was applied (failed steps reset too). Correctness: no blocker. Four smaller findings, all fixed: the reset now runs after 4b, a resumed re-close keeps its fresh passes, automated steps are re-run by the close, and a fresh pass gets a `Passed` line. Security and review-comments: not applicable.
- **Flagged, not fixed.** Every drill runner on this path noticed one more thing: an acceptance box stays ticked beside a failed test of the same behaviour. Nothing says whether a failed re-test should untick it. It is a judgement about what acceptance ticks mean, not a defect in this path, so it is recorded here and not filed. A person who disagrees can `/tasks new` it.

## Progress log

- step 2 — picked; ranked above TASK-298 because key 3 (silence): a re-close over a ticked plan closes `done` again on the old pass without asking for the fresh result, the same "an old pass counts" defect TASK-319 removed for decide, while TASK-298 stops and names its files (self-reporting). Key 7 would favour TASK-298 (P2 over P3); keys 1–3 settle it first
- step 3 — verified: held. `close.md` step 4 says only "Already `done` → warn, ask "reopen and re-close?" or abort." and writes nothing; step 5 asks "Did you run…?" only for steps that "are not run", so a ticked plan passes straight to `done` on the old ticks. SKILL.md's reset rule ("Reopening resets the plan") is scoped to a feature change
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/close.md step 4 (reopening resets every ticked step to not run with a dated `Reopened` line before step 5 reads the plan); test = lint OK + cold drill (step 6)
- step 6 — reverted fix (cold runners, original vs fixed `SKILL.md`/`close.md`, no-remote fixture: `done` story over a `done` task with a ticked plan; scripted user reports the failure only if asked): 3/3 flip. Fixed: the step is reset, the run asks "Did you run …?", the task parks at `verify`, STORY-001 reopens, one park commit. Original: no test question is ever put ("A `[x]` is **passed** … That rules out the test question entirely"), the task stays `done` on the old tick, nothing is committed. fix-dependent = the step-5 question, the `verify` status, the story reopen; contract pins = the reopen question itself, the `ci:` line, the 5d boundary count
- step 7 — respecced work-tracking; requirement changed: "Human test plan decides verify or done" (a reopened task's ticked steps reset before the plan is read); scenario added: a re-close re-asks every step
- step 7 (amended after review) — reset moved into step 5; requirement text now says it runs once the close has settled where it runs, automated steps re-run, fresh passes dated
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
