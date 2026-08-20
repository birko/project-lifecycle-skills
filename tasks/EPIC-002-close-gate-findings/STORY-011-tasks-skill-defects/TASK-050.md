---
id: TASK-050
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `--unattended` promises what it does not deliver — `close` still stops to ask in three other places

## Context

Filed by `/code-review` at TASK-046's close gate, against TASK-015's shipped work.

TASK-015 gave `close` an `--unattended` flag defined as **"no user is present to answer anything"**, and
then scoped its effect to one step: *"Today it changes exactly one step — 5d."* Those two sentences
contradict each other, and the gap is reachable on a **default-configured** consumer repo:

- **Step 5c** (`close.md:82`) issues a mandatory `AskUserQuestion` — *"Merge `task/TASK-NNN` into the
  default branch as part of this close?"* It is skipped only for `--no-pr`, a non-git repo,
  `integration: single-branch`, or when not on a task branch.
- **PR-per-task is the documented default**, and [[fix-next]] cuts a `task/TASK-NNN` branch on exactly
  those projects (`fix-next/SKILL.md:160`) before passing `--unattended` unconditionally at step 8.

So an unattended drain on a default-configured repo reaches 5c and **blocks on a question nobody is
there to answer** — the "hangs on an offer nobody can take" failure the flag's own rationale names. This
repo never sees it because `.config.yml` declares `integration: single-branch`, which is precisely why
it shipped: the one configuration that hides the defect is the one it was written on.

Two more asks have the same shape: step 5's *"Let the user proceed or pause"* on an unfilled Human test
plan (`close.md:27`), and step 4's *"reopen and re-close?"* on an already-`done` task.

**The second half of the finding, same root cause.** The unattended branch says the three outcomes are
unchanged and only the *work* branch differs — which leaves **"decided not to do"** available to an
unwatched run. An agent can confidently classify "the retry path is also broken" as decided-not-to-do,
rewrite the bullet, and destroy the finding with no id and nobody consulted. TASK-015 accepted
auto-spawning only because *a spare task is cheap*; discarding is not cheap, and it is the exact
evaporation step 5d exists to prevent.

**The merge question is the hard one and needs deciding, not defaulting.** Unattended, "don't merge"
sends every drained task to `blocked` and makes the loop useless; "merge" means an autonomous agent
writes to the default branch. The gates have already passed by that point, which is the argument for
merging — but it is a real decision about autonomy and belongs to whoever owns that policy, not to
whoever happens to implement this.

## Acceptance criteria

- [ ] Every `close` step that can stop for input has a stated `--unattended` behaviour, or the flag's
      opening sentence is narrowed so it stops promising coverage it does not have — **not both**
- [ ] The merge decision at 5c is settled explicitly for unattended runs, with the rejected option and
      the reason recorded; if the answer is "merge", it says so in the flag's own definition rather than
      leaving it to be inferred at the call site
- [ ] The unattended branch of 5d forbids the **decided-not-to-do** outcome, or folds it into
      *cannot confidently classify → spawn*
- [ ] Step 5's unfilled-plan branch and step 4's already-`done` branch state what an unattended run does
- [ ] [[fix-next]] and `close` agree in writing about what the flag covers — the defect is that they
      currently do not
- [ ] The interactive path stays unchanged, as TASK-015 required

## Out of scope

- Whether `fix-next` should ever stop for a user at all — the broader autonomy question, which
  TASK-015 already ruled out of scope and this task does not reopen.
- Adding `--unattended` to verbs other than `close`.
- Changing what `done` means. If the answer at 5c is "do not merge", the existing `blocked` semantics
  already cover it; this task decides which answer, not what the answer implies.

## Human test plan

- [ ] On a fixture repo configured `integration: pr-per-task`, run `/fix-next` end to end and confirm
      it completes without stopping — this is the case that fails today and the only one that proves
      the fix
- [ ] Confirm on this repo (`single-branch`) that behaviour is unchanged, since it never reached 5c
- [ ] Close a task interactively on a PR-per-task repo and confirm the merge question still appears
- [ ] Give a task an `## Out of scope` bullet that reads like a deliberate non-goal and confirm an
      unattended run does not silently rewrite it away

## Implementation plan

_Populated by `/tasks plan TASK-050` — leave empty until then._
