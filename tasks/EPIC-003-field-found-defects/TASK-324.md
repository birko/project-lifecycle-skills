---
id: TASK-324
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-317-1]
pr: null
github-issue: null
jira-key: null
---

# A re-close that parks a `done` task at `verify` never rolls its parents up

## Context

Found by TASK-317's close review (2026-10-14). [[tasks]] SKILL.md § *Roll status up to parents* lists "reopened by `close`" among the triggers of the reopening direction. The only `close` path that actually takes a task out of `done` is `skills/tasks/verbs/close.md` step 4's interactive "reopen and re-close", when the re-close then parks the task at `verify` in step 5 because a test step did not pass. Neither step says to roll the parents up. So a `done` story stays `done` over a `verify` child, and with an upstream nobody runs the unlanded `record/<ID>` check either.

TASK-317 tried a fix and reverted it. Running the rollup in step 4 writes before step 4b has settled where the close runs. It sits above the `--unattended` refusal. And it is usually undone in the same run, because a re-close that ends `done` makes step 12's "now has an open child" line false. The rollup belongs at the moment the task actually leaves `done`, which is the step-5 park, and it has to respect step 10's table of what may be written where (nothing on the default branch with an upstream).

## Acceptance criteria

- [x] A re-close that parks a previously `done` task at `verify` runs the reopening direction of SKILL.md § *Roll status up to parents* at the park, where step 10's table allows the write
- [x] With an upstream it runs the unlanded-record check, and step 12 reports each reopened container and each `record/<ID>` line
- [x] A re-close that ends `done` reopens nothing and reports no record line
- [x] `--unattended` behaviour is unchanged (step 4 still refuses a closed record)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `move`, `new`, `spawn`, `decide` (TASK-317) and the chaining verbs (TASK-325)

## Human test plan

- [x] On a fixture with a `done` story over one `done` task, re-close the task interactively and report a test step as failed. Expected: the task reads `verify`, the story reopens with its dated line, and the confirmation names it.
  - Passed 2026-10-14 as a cold drill (`skills/populate-tests/SKILL.md` § *The cold drill*). Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)"`, brief on stdin. The cwd was a fresh no-remote git fixture in the scratchpad, `d324-fixed` (`single-branch`, a `done` story over a `done` task with a ticked plan), holding copies of `SKILL.md` and `close.md`. The brief scripted the user's answers (reopen: yes; the step: failed) and withheld the expected result. Coldness: the runner reported no skills. Result: the task went to `verify` with its step unticked and a `Failed` line; STORY-001 went to `in-progress` with `> Reopened 2026-10-14 — TASK-001 is now verify (close)`; both rode in one park commit; and the confirmation printed `STORY-001 reopened: TASK-001 is now verify`. The drill ran on the first version of the fix. The review edits that followed widened the rule (cancelled, epic parents, the no-commit row, resume) and did not change this path.

## Implementation plan

Written by `/fix-next` after step 3, before the edits (it runs no `/tasks plan`):

1. `close.md` step 5: a park bullet ahead of the park commit. When the task read closed before this close, roll its parents up at the park; place the writes by step 10's table; with an upstream, run the unlanded-record check.
2. `close.md` step 12: report reopened / not-reopened containers and record lines.
3. Lint, a cold revert-and-split drill, respec `work-tracking`.

## Outcome

- **The fix.** Reopening a closed task and re-closing it can end at `verify` when a test step now fails. That left its story reading `done` over a task that is not, a state the story's own close gate would refuse, and nothing reported it. Now `close` rolls the parents up at that park. Where the reopened files go follows step 10's table:
  - in the park commit, on a default branch with no upstream;
  - written and left uncommitted, then named, when the close commits nothing;
  - nowhere on a task branch or with an upstream, where the confirmation reports each container as not reopened, with the reason.

  With an upstream it also runs the unlanded-record check. A re-close that ends `done` reopens nothing. Files: `skills/tasks/verbs/close.md` (steps 5 and 12), `skills/tasks/SKILL.md` (the trigger list now names the park, not every reopen), and the `work-tracking` spec.
- **Step-6 split (cold drill, original vs fixed `SKILL.md`/`close.md`, no-upstream fixture):** 0 of 3 outcomes flip. The original runner also reopened the story and committed it with the park, because it applied SKILL.md's rule whole. Contract pins: the task at `verify`, the story reopened with its dated line, both in one park commit, and the reopen in the confirmation. Nothing proves the fix on this fixture, which is the same finding as TASK-317. What the fix settles is when the rollup runs and where its writes go. The fixed runner listed those as settled; the original runner inferred them.
- **Judgement calls.**
  - The rollup runs at the park, not at step 4's reopen. Step 4 runs before 4b settles where the close runs, and before anyone knows the re-close won't end `done`; TASK-317's attempt failed there.
  - The review widened the rule to everything SKILL.md's own trigger covers: a `cancelled` task, a task filed directly under an epic, the no-commit case, and a park resumed after a crash. The fidelity pass called these scope creep. They are kept because each is a case where the narrower text left a container contradicting its child, which is the defect this task fixes.
  - On a task branch nothing is reopened, and no reopen is suggested. The default branch still reads the task `done`, so its parents are right there. Telling a person to reopen would write the file this rule forbids, or leave a story `in-progress` over all-`done` children.
- **Specs.** Respecced by `/fix-next` step 7: a targeted edit under the stable-wording rule, `generated-at` restamped, `shaped-by` carried (`feature: null`). Changes are *intended anyway — TASK-324's criteria, answered by /fix-next*, plus the widened cases above.
- **Review gate.** Standards: pass. Its warnings were the empty plan (filled, and labelled as written by `/fix-next`) and the not-reopened line naming only stories (now `<ID>`), both fixed. Fidelity: nothing missing or wrong; 5 scope-creep notes, all review fixes, recorded above. Correctness: 5 findings plus one minor, none blocking, all fixed (no-commit row, task-branch advice, `cancelled`, epic parent, resumed park, SKILL.md trigger wording). Security and review-comments: not applicable.
- **Flagged, not fixed.** Both runners found that `close` step 4's "reopen and re-close" never says what reopening resets. By the letter, a re-close over a ticked plan goes straight back to `done` and never reaches this park. Filed as TASK-326.

## Progress log

- step 2 — picked; ranked above TASK-298 because key 3 (silence): a re-close parked at `verify` leaves a `done` story over a `verify` child with no report, a state its own close gate would refuse, while TASK-298's unwritable record makes `/fix-next` stop and name every file (self-reporting). Both found by a close review or drill (key 5)
- step 3 — verified: held. `close.md` step 5's park bullets (commit, PR, 5b, 5a, 5d, worktree) never roll parents up, and step 11 rolls up only the feature. The one park that leaves `done` is a re-close after step 4's reopen, since every other close starts from an open status
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/close.md (step 5 park bullet: roll up when the task read `done` before this close, writes placed by step 10's table, upstream check; step 12 report line); test = lint OK + cold drill (step 6)
- step 6 — reverted fix (cold runners, original vs fixed `SKILL.md`/`close.md`, no-upstream fixture: `done` story over a `done` task, re-closed with the test step reported failed): 0/3 outcomes flip — both parked the task at `verify`, reopened STORY-001 with its dated line in the park commit, and reported the reopen; the original runner reached it by reading SKILL.md's rule whole ("Reopening means running the close again … with no intermediate status written" listed as inferred). fix-dependent = none proven on this fixture; contract pins = task `verify`, story reopened, both in one park commit, reopen line in the confirmation. The fixed runner listed the timing as settled ("at the park, not at step 4 … into that same commit"). Both runners raised one gap outside this task: reopen never resets a ticked plan, so by the letter a re-close over `[x]` goes straight to `done` and never reaches this park (spawned TASK-326)
- step 7 — respecced work-tracking; requirement changed: "Parents rolled up after child changes" (a re-close parked at `verify` reopens at the park, writes placed by where the park commit lands); scenario added: a re-close whose test fails reopens the story
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
