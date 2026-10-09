---
id: TASK-161
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-20
depends-on: []
blocks: []
findings: [FIELD-003]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# A human test plan that ran and failed cannot be told from one that never ran

## Context

Found by running `/feature review FEATURE-002` on 2026-09-20 — by using the skills, not by reviewing
them, which is this epic's remit. `feature: null` deliberately: the defect is in the **`tasks` and
`feature` skills**, not in the feature whose review exposed it.

**The state that has no representation.** TASK-141's `## Human test plan` has three steps. All three
were executed. Step 2 — *ask a cold runner to apply the rule to `skills-lint.sh` and report
violations* — **ran and failed**: its recorded expectation was *"Expected: none"* and two independent
readers found nine things between them. The findings were filed (TASK-157, TASK-158, TASK-160) and the
task correctly sits at `review`.

Both gates read that plan as a binary:

| Source | Says |
|---|---|
| [[feature]] `review` Gate B | *"Each plan must be either: all steps checked `[x]` (manually run), or explicitly `N/A — fully covered by automated tests`."* |
| [[tasks]] `close` step 5 | *"If it has real steps with unchecked `[ ]` boxes, **don't close to `done`**"* — and `review → done` only *"after the human step is checked off"* |

So there are two writable states and three real ones:

| Real state | Box | What a reader concludes |
|---|---|---|
| never run | `[ ]` | correct |
| ran, passed | `[x]` | correct |
| **ran, failed, findings filed** | `[ ]` or `[x]` | **both wrong** — untick says nobody tested it; tick says it passed |

**Ticking is the tempting reading and it is the worse one.** `close.md`'s gloss is *"(manually run)"*,
not *"(passed)"*, so the letter permits it. But `close`'s own rule then reads *"`review` → `done` only
after the human step is checked off"* — so a ticked box is the thing that lets a task close, and
ticking a failed step makes a failing test into a closure permit. TASK-141 would have closed today on
a test that found nine defects.

**Leaving it unticked is what this repo did, and it is also wrong.** `/feature review` Gate B just
reported TASK-141 as *"3 unrun steps"* alongside five tasks whose plans genuinely have never been run.
The one plan in the feature that **was** executed — at real cost, six cold runners across two rounds —
is indistinguishable in that report from five that were not.

**Why this is not cosmetic.** A failed test is the ordinary outcome of testing; it is the outcome that
produces work. A convention that can only record *pass* or *absent* pushes every failure into one of
two lies, and the lie is load-bearing in both directions — it gates closure on one side and it
misreports verification debt on the other.

## Acceptance criteria

- [x] The plan format can express **ran and failed** distinctly from **never run** — a third marker, a required outcome line per step, or whatever shape survives the drill below. One shape, stated once, in whichever file owns it.
- [x] `close` cannot flip `review → done` on a step recorded as run-and-failed. The current rule keys on the box; whatever replaces it must key on the outcome.
- [x] `/feature review` Gate B reports the three states separately. *"3 unrun steps"* for a plan that was run is the report this task exists to stop.
- [x] Both files agree — [[tasks]] `close` step 5 and [[feature]] `review` Gate B state the same rule today and must still state the same rule afterwards, or a task and its feature will disagree about whether it can close.
- [x] The change is **recorded in `AGENTS.md` § Conventions** if it establishes a new cross-cutting pattern — register-on-introduce applies to a convention about how every consumer records verification.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass.

## Out of scope

- TASK-141's own status — it stays at `review` until the file it was meant to exonerate is clean; that is correct under either convention.
- The findings that run produced — TASK-157 (done), TASK-158, TASK-160.
- Whether an automated check should replace the manual step — `close` step 5 already owns *automate before you accept a manual step*, and this one cannot be automated: it needs a reader who does not already know the answer.
- Whether Gate A lets a `verify` task through to Gate B, which decides whether Gate B's failed branch is reachable from a task parked at `verify`. TASK-235 owns it.
- An in-place close leaving the regenerated `tasks/README.md` uncommitted, seen in this task's fixture run. TASK-292 owns it.

## Human test plan

- [x] Write a task whose plan has one step, mark it run-and-failed in the new shape, and run `/tasks close` on it. Expected: it refuses `done` and says why, naming the failed step.
  - **Passed 2026-10-08:** fixture `%TEMP%\d161` (`single-branch`, no remote), command `echo "/tasks close TASK-001 --unattended" | claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" … --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills`. Ended at `verify`, box left unticked, report named the failed step and its task. Not a cold runner and did not need to be: this step tests behaviour, not wording. A first attempt without `--add-dir` could not read `close.md` and stopped, which is a harness failure, not a result. The run also left `tasks/README.md` uncommitted → TASK-292
- [x] Run `/feature review` over a feature holding one never-run plan, one passed plan and one run-and-failed plan. Expected: three distinct lines. Today two of the three collapse.
  - **Not run as written.** Evidence short of it (2026-10-08): a cold reader applied Gate B's text verbatim to exactly these three plans (step 6 of the Progress log), and printed three distinct lines and failed the gate on the failed step, where the pre-fix text gave "2 of 3 plans have unchecked steps". A real `/feature review` run on a fixture feature is still owed.
  - **Passed 2026-10-09:** fixture `%TEMP%\d161r` (`single-branch`, FEATURE-001 with three `done` tasks: TASK-001 all passed, TASK-002 never run, TASK-003 one passed and one `Failed 2026-10-05` → TASK-004), `echo "/feature review FEATURE-001" | claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" … --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills`. Gate B printed `2/0/0`, `0/0/2` and `1/1/0` (passed/failed/not run) on separate rows, listed the failed step with its date and TASK-004, said re-running it would not help until TASK-004 lands, and failed the gate. Fixture compromises, both caught by the runner: the tasks read `done` despite unrun and failed steps, a pre-rule state, so that Gate A would let Gate B run (TASK-235 owns whether a `verify` task reaches Gate B); and TASK-004 was unlinked from the feature for the same reason, which the runner flagged as hiding an open blocker. It also left its History line in `decisions.md` uncommitted
- [x] Expected failure to watch for: the new marker is added to the format and neither gate reads it, so the state is now writable and still unenforced — which is worse than the binary, because it reads as handled.
  - **Passed 2026-10-08:** both gates read it: the real close above parked at `verify` on it, and the Gate B drill counted it as failed.

## Outcome

**The fix.** A Human test plan step now has three recorded states instead of two. `[x]` means it passed.
A step that ran and failed stays `[ ]` and gets a nested `**Failed YYYY-MM-DD:**` line that says what
happened and which task holds the findings. Any other `[ ]` means it was not run. `/tasks close` reads all
three and parks a failed step at `verify`, never `done`. `/feature review` Gate B prints passed, failed and
not-run counts per task and fails the gate on a failed step. The shape is defined once, in
`skills/tasks/SKILL.md` § Lifecycle. Both gates and the TASK template point at it, and `AGENTS.md`
§ Conventions registers it.

**Step-6 split.** 2/2 observations fix-dependent in the cold A/B (Gate B report, and close on "yes, I ran
it"); see the Progress log for the quotes. The real `/tasks close` run on a fixture passed. Contract pins
only: the lint and its tests.

**Judgement calls.**
- *Unticked plus an outcome line, not a third marker such as `[!]`.* The marker was the shape the task
  floated first. It was rejected because it fails open: a plan whose only step reads `[!]` has no unchecked
  box, so a reader that predates the rule finds nothing blocking `done`. Unticked plus a line fails safe:
  an old reader still refuses `done`, and only misreports the failure as not run.
- *"The last nested line is the current state."* A re-run appends and never deletes, so the history of a
  step that failed and later passed stays readable, and the state is still one line to check.
- *The old "user confirms they just ran it → tick" ask was replaced, not patched.* "I ran it" says nothing
  about the result, and the drill's pre-fix runner showed the letter of the old rule leads to `done` on a
  failed step. The new question asks for the result, and gives the answer-less path (leave it not run) as
  § Output/prose rules requires.
- *Gate B does not let a failed step clear by re-running it unchanged.* The work its line names has to land
  first, or the re-run is the same test on the same code.
- *Examples are invented (an export with an empty date range, TASK-041), not TASK-141's real record*, per
  the rule TASK-210 is filing.

**Flagged, not fixed.**
- Human test plan step 2 (a real `/feature review` run on a fixture) was not run at first close, so this task
  parked at `verify`. Run and passed 2026-10-09; closed `verify → done`.
- TASK-292: an in-place close leaves the regenerated `tasks/README.md` uncommitted. Seen in the fixture run.

## Implementation plan

_Populated by `/tasks plan TASK-161` — leave empty until then._

## Progress log

- step 2 — picked; ranked above TASK-221 because key 1: a run-and-failed manual step can be ticked into `close`'s `verify → done` permit (a merge-gate bypass) and is otherwise misreported as unrun, where TASK-221 is a container getting the wrong terminal status; key 5 also favours it (found in real use, not a harvest). Key 6 inert: TASK-161 is parented to its EPIC, so no theme by construction
- step 3 — verified: held. `close.md` step 5 still keys `done` on unchecked boxes and offers "user confirms they just ran it → check the boxes"; `feature/verbs/review.md` Gate B still reads "all steps checked `[x]` (manually run)". No reader anywhere distinguishes a failed run. Also stale with it: `tasks/SKILL.md`'s snapshot row "awaiting verification: … the manual step unrun", which a failed step also lands in
- step 4 — layer: local (the shape and both gates live in this repo's `tasks` and `feature` skills)
- step 5 — fix in `skills/tasks/SKILL.md` (§ Lifecycle: the three-state table, the shape and why it fails safe; the status-reading row), `skills/tasks/verbs/close.md` (step 5 reads three states, a failed step parks at `verify`, the ask carries its question and its unattended path; step-2 table row 5; the park commit wording), `skills/feature/verbs/review.md` (Gate B reports three states, fails on a failed step), `skills/tasks/templates/TASK.md`, `AGENTS.md` § Conventions. No automated test can hold a prose rule; lint + lint tests green
- step 6 — cold A/B, same brief on the pre-fix (HEAD) and post-fix text of Gate B and close step 5: 2/2 observations fix-dependent. Gate B report: pre-fix collapses the failed and the never-run plan ("2 of 3 plans have unchecked steps"); post-fix prints three separate counts and fails the gate on the failed step. Close with "yes, I ran it" on a failed step: pre-fix runner said "read word for word, the rule points to `done`" and reached `verify` only by overriding the text; post-fix reaches `verify` from the letter. Contract pins, not evidence: skills-lint.sh, skills-lint-test.sh. Runner: `cd C:/Source/WebChecker && claude -p --disable-slash-commands < brief-{old,new}.txt` (guide-free cwd); coldness not separately confirmed (the runner was not asked to list its skills)
- step 7 — respecced work-tracking (requirement *Human test plan decides verify or done*: three states, a failed step reported; new scenario *Failed manual step*) and feature-lifecycle (requirement *Review is a three-gate completeness check*: Gate B's three counts; new scenario *A failed step is not reported as unrun*). Diff reviewed: nothing unintended. Stamped `b94dd8c`; feature-lifecycle's previous stamp `d97f2f9` was safe to advance because both later `skills/feature` commits re-committed that spec
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
