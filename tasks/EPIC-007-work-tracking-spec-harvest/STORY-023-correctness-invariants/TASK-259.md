---
id: TASK-259
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
findings: [SH-85]
pr: null
github-issue: null
jira-key: null
---

# `grill-me` has no answer-less path: with nobody to answer, it neither ends nor reports

## Context

Found by the `idea-interrogation` spec harvest (2026-10-06, TASK-080, EPIC-007 fourth pass) at `07de657`, and
checked against the files before intake.

- **SH-85.** `grill-me` is nothing but ask-steps, and it defines no outcome for a round nobody answers.
  - § *Ask in rounds*: "A question left unanswered is still on the frontier and comes back."
  - § *When the grill is done*: it ends only when every question is answered or deferred, "or the user calls it off".

  With no user present (an unattended caller, a drill runner, a reply that never comes), the frontier never shrinks
  and the user never calls it off. Nothing says the grill should stop, or what it emits when it does.

AGENTS.md § *Output / prose rules* requires every ask-step to carry its answer-less path. The unattended outcome
must be a **reported unresolved state**, never a value that reads as decided. Its measured instance (DRILL-109) is
a cold runner that wrote a blessing question itself and then proceeded as if it had been blessed. For a grill, the
equivalent failure is emitting a `## Resolved decisions` block in which the grill's own recommendations read as
the user's choices.

The callers already handle a partial grill on their side: `/feature new` step 4 writes `open` for every question
the grill did not reach. That makes the gap the grill's own, and it bites when the grill runs on its own.

## Acceptance criteria

- [x] `grill-me` states what happens when a round gets no answer: the grill ends, and nothing it recommended is recorded as decided
- [x] The closing block distinguishes decisions the user made from questions left open, so a caller cannot read a recommendation as a choice
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- How `/feature new` writes dropped and deferred questions (TASK-258)

## Human test plan

- [x] Cold drill (`skills/populate-tests/SKILL.md` § *The cold drill*): give a cold runner a plan and the installed skill, tell it no user will answer, and confirm it ends the grill and reports the open questions, without writing any recommendation as a resolved decision
  - **Passed 2026-10-12.** The runner was obtained with `claude -p --disable-slash-commands < brief.txt`, cwd
    `C:/Source/WebChecker`, which has no agent guide. Coldness check: each runner was asked to list the skills it
    had available, and both answered `SKILLS-SEEN: none`. The brief held the skill text inline, an offline-sync plan
    for a field inspection app, and the line "nobody is present to answer anything … this is your only turn". It
    did not say what output was expected. With the fix: the runner said the grill ended because nobody could
    answer, wrote `## Resolved decisions` as `- none`, and put all 13 questions under `## Still open` (5
    `not answered` with their recommendations marked `not chosen`, 7 `not reached`, 1 failed lookup).

## Implementation plan

_Populated by `/tasks plan TASK-259` — leave empty until then._

## Outcome

**What changed.** When nobody could answer, `grill-me` had no defined way to end. Its closing block could only say
"decided" or "deferred", so a cold runner filed its own recommendations under `## Resolved decisions` as
`deferred: … (recommended: X)`. `/feature new` turns a deferred line into a `proposed` decision row, so
recommendations nobody chose became decisions. Now:
- `grill-me` § *Ask in rounds*: a round nobody can answer ends the grill. The grill does not repeat the round or
  answer it itself.
- `grill-me` § *When the grill is done*: the grill always emits `## Resolved decisions` (only choices the user gave
  or agreed to) and `## Still open` (`not answered (recommended: …, not chosen)`, `not answered (lookup failed: …)`
  or `not reached`). Either block holds `- none` when empty.
- Both consumers read the new block. `feature/verbs/new.md` step 4 writes a still-open question as `open` and adds
  no decision row for it. `new-project` step 2 folds nothing from `## Still open` and names those questions in its
  step-6 closing checklist.
- Respecced: `idea-interrogation` (two requirements, one title, and a new no-answer scenario), and one clause each
  in `feature-lifecycle` and `project-baseline`.

**Step-6 split.** Both runs were cold drills on the same brief: the skill text from `HEAD` (before the fix) and
from the working tree (after it). **Before the fix: 8 of 8 lines under `## Resolved decisions` were unanswered
recommendations written as `deferred`, and there were 0 open lines. After the fix: 0 resolved lines (`- none`), and
13 of 13 questions were open.** The fix-dependent evidence is that pair of runs. The lint passes either way, so it
is a contract pin, not evidence.

**Judgement calls.**
- I gave open questions a **separate block** instead of a third line shape inside `## Resolved decisions`. One
  shape would have changed less, but a consumer that reads the block by name would still count an open line as a
  decision, which is the defect being fixed.
- A no-answer round **ends** the grill instead of re-asking a limited number of times. Nobody being present does
  not change between rounds, so a retry only delays the same result.
- Added a `not answered (lookup failed: …)` shape during my own correctness pass. A failed lookup is put to the user
  without a recommendation, so the `recommended:` shape did not fit it, and the drill runner invented a fourth
  form for it.

**Flagged, not fixed.** Nothing.

**Merge gate (close step 5b, run inline, each verdict on its own):**
- *Standards*: pass. The new ask-step has its no-answer path, and that path ends in a reported unresolved state,
  as § *Output / prose rules* requires. Each round's questions depend on the plan, so they cannot have fixed
  wording. No new cross-cutting pattern.
- *Fidelity*: pass. Criterion 1 is § *Ask in rounds*' new bullet, criterion 2 is the two blocks and the "only the
  user's choice" rule, and criterion 3 is lint OK. Out of scope (TASK-258's dropped/deferred rows) was left
  untouched. Only the not-reached row in `new.md` was widened.
- *Correctness*: one finding, fixed before commit, which is the failed-lookup shape above.
- *Security* and *Comments*: not applicable, because the diff touches no security surface and carries no code
  comment.

## Progress log

- step 2 — picked; ranked above TASK-298 because an unanswered grill can return its own recommendations as if the user had made them, which silently corrupts the decision record (keys 1 and 3), while TASK-298's stopgap already reports and stops and it carries an open design question (key 4). TASK-222 is also silent, but it puts a task in the wrong priority bucket instead of corrupting a record (key 1). Key 6 was not needed: all three are correctness-invariants
- step 3 — verified: held. § Ask in rounds puts an unanswered question back on the frontier forever, and § When the grill is done ends only on a fully settled tree or a user calling it off; its block has no line shape for a question still open, so a caller turns whatever is written there into a decision row. Pulled in the two consumers with the same root cause: feature `new` step 4 maps "not reached" to `open` but has no row for "asked, not answered", and new-project step 2 folds every block line into README/CLAUDE.md
- step 4 — layer: local
- step 5 — fix in skills/grill-me/SKILL.md, skills/feature/verbs/new.md, skills/new-project/SKILL.md; evidence is a cold drill, not a test file (prose); lint OK, 20 skills
- step 6 — reverted fix (HEAD text, same brief, cold runner): 8/8 recommendations written as resolved `deferred` lines; with fix 0 resolved, 13/13 open; fix-dependent = the drill pair; contract pins = skills-lint.sh
- step 7 — respecced idea-interrogation, feature-lifecycle, project-baseline; requirements changed: "The grill ends when …" (title and body), "Close with a … block" (title and body, plus scenarios), feature-lifecycle open-questions clause, project-baseline scope-grill clause
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
