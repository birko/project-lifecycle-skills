---
id: TASK-247
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-76]
pr: null
github-issue: null
jira-key: null
---

# The review axes ask the user things with no question text and no unanswered path

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. AGENTS.md § Output/prose rules requires an ask-step to carry the question it
actually puts, and what the run does when no answer comes. Two kinds of ask-step in the change-review skills carry
neither:

- **No intent source.** `skills/verify-intent/SKILL.md`'s intent table says "Nothing, and no task in flight → ask
  the user what the change was meant to do, in one line". `close.md` says that branch cannot fire inside `close`, but
  that leaves standalone and `/fix-next` runs uncovered.
- **Not git-tracked.** "Not git-tracked → ask which files to judge" appears in `verify-intent` step 1,
  `verify-conventions` step 1, `review-comments` step 2 and `skills-pi/code-review` step 1.

## Acceptance criteria

- [x] Each ask-step quotes the question it puts
- [x] Each states its answer-less outcome as a reported unresolved state (e.g. "no intent source — nothing judged"), never a guessed scope
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other skills' ask-steps

## Human test plan

- [x] Run `/verify-intent` from a cold runner in a folder that is not a git repo, with no task in flight, and say nothing. Expected: the run reports the unresolved state rather than choosing files or an intent
  - **Passed 2026-10-11:** two fresh `claude -p` runs in `%TEMP%\d247` (no git, no tasks), briefed only that the run
    was unattended. Both printed `no diff — not a git repository and no files named; nothing judged`, chose no files
    and no intent, and said it was not a pass. The runner holds the installed skills, which this behaviour drill
    needs

## Implementation plan

_Populated by `/tasks plan TASK-247` — leave empty until then._

## Outcome

**The fix.** Five ask-steps in the review axes now carry their question word for word and an outcome for when no
answer comes.
- **No git repository** (`verify-intent`, `verify-conventions`, `review-comments`, `skills-pi/code-review`): ask
  which files. With no answer, report `no diff — not a git repository and no files named; nothing <checked>` and
  stop, never choosing files.
- **No intent** (`verify-intent`, no task named or in progress): ask what the change was meant to do. With no
  answer, report `Intent: none`, skip the criteria-based classes, and still run the spec baseline. Never write an
  intent from the diff.

**Step 6 split, stated exactly because it is weak.** Before the fix, both runs on the same folder also stopped,
reported the scope as unresolved and chose nothing. Runners already decline to guess here. So the drill is a
**contract pin, not evidence**. **Fix-dependent:** only the fixed report line. The fix rests on AGENTS.md's rule
that an ask-step names its question and its unattended outcome, which can only be met by writing them down.

**Judgement calls.**
- *Edit `skills-pi/code-review` despite the freeze.* ADR 0010 freezes the tree against new skills, not against
  fixes to the three it holds. Its drift from the axes it stands in for is TASK-250's subject.

**Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-258 because the review axes run unattended from `/tasks close` and `/fix-next`, and with no question text a runner guesses a file scope or an intent and reports a verdict over it (key 3: a verdict over a guessed scope reads as a real pass), reached on every non-git or task-less run (key 2), and the five sites share one fix (key 4); TASK-258 is a lost grill question. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. Four "not git-tracked → ask which files" sites and verify-intent's "ask … in one line" carry no question text and no unattended outcome
- step 4 — layer: local (`skills/verify-intent`, `skills/verify-conventions`, `skills/review-comments`, `skills-pi/code-review`)
- step 5 — fix at all five sites: the question verbatim and the no-answer outcome (non-git → report, stop, choose no files; no intent → `Intent: none`, criteria classes skipped, baseline still run). Lint green; drill 2/2 on `%TEMP%\d247`
- step 6 — reverted `verify-intent`: pre-fix 2/2 also reported unresolved and chose nothing. Contract pins; fix-dependent = the fixed report line only
- step 7 — respecced change-review (diff precedence: the non-git question and outcome + scenario "Not a git repository, nobody to ask"; intent sources: the no-intent question and outcome); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
