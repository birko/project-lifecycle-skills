---
id: TASK-050
parent: STORY-011
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
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

- [x] Every `close` step that can stop for input has a stated `--unattended` behaviour, or the flag's
      opening sentence is narrowed so it stops promising coverage it does not have — **not both**
- [x] The merge decision at 5c is settled explicitly for unattended runs, with the rejected option and
      the reason recorded; if the answer is "merge", it says so in the flag's own definition rather than
      leaving it to be inferred at the call site
- [x] The unattended branch of 5d forbids the **decided-not-to-do** outcome, or folds it into
      *cannot confidently classify → spawn*
- [x] Step 5's unfilled-plan branch and step 4's already-`done` branch state what an unattended run does
- [x] [[fix-next]] and `close` agree in writing about what the flag covers — the defect is that they
      currently do not
- [x] The interactive path stays unchanged, as TASK-015 required

## Out of scope

- Whether `fix-next` should ever stop for a user at all — the broader autonomy question, which
  TASK-015 already ruled out of scope and this task does not reopen.
- Adding `--unattended` to verbs other than `close`.
- Changing what `done` means. If the answer at 5c is "do not merge", the existing `blocked` semantics
  already cover it; this task decides which answer, not what the answer implies.

## Human test plan

- [x] On a fixture repo configured `integration: pr-per-task`, run `/fix-next` end to end and confirm
      it completes without stopping — **drilled**: zero asks, branch merged, work bullet spawned
- [x] Confirm on this repo (`single-branch`) that behaviour is unchanged — this close is that test.
      It never reaches 5c; it *does* reach step 7, which is why that row mattered
- [x] Close a task interactively on a PR-per-task repo and confirm the merge question still appears —
      verified by diff: 5c's ask has zero deletions, and every change in `close.md` is additive except
      the false-promise sentence itself
- [x] Give a task an `## Out of scope` bullet that reads like a deliberate non-goal and confirm an
      unattended run does not silently rewrite it away — same fixture run; it got an id

## Implementation plan

_Populated by `/tasks plan TASK-050` — leave empty until then._

## Progress log

- step 2 — picked 2026-08-21. Named as the next pick at TASK-046's close: P1, and it blocks unattended
  drains on any repo using the documented default branch model.
- step 3 — verified: held, both halves. `close.md:82`'s merge question is skipped only for `--no-pr`,
  a non-git repo, `integration: single-branch`, or when not on a task branch — so PR-per-task reaches it.
  `fix-next/SKILL.md:160` cuts the branch on exactly those projects and passes the flag unconditionally
  at step 8. Step 5d's unattended branch does leave *decided not to do* available. Confirmed by reading.
- step 4 — layer: local. Both sides are skills in this repo.
- step 5 — blocked on the 5c policy decision; everything downstream of it is written but the flag's
  definition cannot be finished without it. Asked the user rather than defaulting, per the guardrail
  that a decision only they can make gets a concrete recommendation and a stop.
- step 5 — decision taken (user, 2026-08-21): **unattended merges**. Both alternatives recorded at 5c
  with reasons. Fix in `close.md` (arg table, steps 4/5/5c/5d/7/11 and the Jira edge case) and
  `fix-next/SKILL.md` (step 8 points at the table rather than restating its scope).
- step 6 — the lint half is pinned: **36/36 green; reverting `skills-lint.sh` fails exactly the two new
  cases** (`shadow-only root collapses, precisely`, `repo name repeated in the target path`). The prose
  half has no guard to fail — nothing reads a verb's step branching — so its evidence is the fixture
  drill below, recorded as a drill and not as a test.
- step 7 — no usable spec map (`docs/specs/.map.yml` has `areas: []`). Nothing to respec.
- step 8 — `/code-review`: 7 findings, all confirmed, all fixed. See Outcome.

## Outcome

**What was broken.** `--unattended` promised "no user is present to answer anything" and delivered it at
one step. The review found the promise broken at **six** more, and one of them fires on *every* run:
step 7 asks what to do about uncommitted changes, and step 6 has just rewritten the task's frontmatter —
so `git status --porcelain` is never clean there. Every unattended close blocked, on every project
shape, including the `single-branch` repos that never reach the 5c ask this task was filed for.

**The fix.** The flag's definition now carries a table of every step it governs — 4, 5, 5's `review`
park, 5c, 5d, 7 dirty, 7 clean, the STORY spec-regen prompt, and the Jira auth pause — and states that
an ask reachable unattended and absent from that table is *a defect in the table, not a judgement call
to improvise*. `fix-next` points at the table rather than restating its scope, which is how the first
version drifted.

**The decision, and what was rejected.** Unattended merges: the gates have all run by then, `done`
already means merged, and `fix-next` states that `close` settles the merge and merges. Ending at
`blocked` was rejected — it makes the drain pointless and overloads `blocked` with "waiting on a
dependency" and "waiting on a human". A per-repo `unattended-merge:` field was rejected too: it needs a
default, and the default would be this.

**A second evaporation path, closed.** The `review` park says "skip to step 10", and 5d sits between 5c
and 6 — so the out-of-scope sweep was skipped whenever a task parked at `review`, while the same
sentence claimed only steps 6-9 were skipped. Worse there than at a `done` close: nobody returns to a
`review` task's Out of scope section. 5d now runs before parking.

**Judgement call: fix the wording, not the condition.** An earlier review had me gate the "nothing is
linked into it" collapse on `shadow -eq 0`. This review showed that trades one wrong line for
seventeen — a root with a stale shadow and nothing else linked took the per-skill branch, printing the
wall of text the collapse was measured to remove, and reachable in precisely the TASK-037 situation. The
contradiction was always in the *wording*, so the collapse stays and now says what is not linked rather
than that nothing is.

**Also fixed, from the same review:** `${t#…}` took the *first* occurrence of the repo name while the
comment two lines above claimed the tail — so a worktree at `<repo>/wt/<repo>` or a clone at
`~/src/<r>/<r>` reported every in-repo junction as a shadow. `fix-next`'s "the only key that can never
tie" was false, since `created` is date-only and twelve tasks here share one date, which made the
"genuinely inseparable" branch read as dead prose when it is reachable. And `verify-intent`'s step 5
said unmatched criteria are "missing or wrong" while its own table defines Wrong as *matched* and
divergent — following the step literally would have emptied the class.

**Drilled on the shape that hid the defect.** A scratch repo with `integration: pr-per-task`, a task on
a `task/TASK-001` branch, walked end to end under `--unattended`: **zero asks**, branch merged, and an
`## Out of scope` bullet reading *"also wrong, but not here"* — work wearing a boundary's clothing —
spawned rather than discarded. Built rather than skipped, because skipping it is how this shipped.
