---
id: TASK-292
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-161-1]
picked-by: fix-next
pr: null
github-issue: null
jira-key: null
---

# An in-place `close` regenerates `tasks/README.md` after its own commit and leaves it uncommitted

## Context

Seen while running TASK-161's human test plan (2026-10-08). A real `/tasks close TASK-001 --unattended`
on a throwaway `single-branch` fixture (no worktree, no remote) parked the task at `verify`, committed the
work and the task file in `d819001`, and then left `?? tasks/README.md` behind. The runner's report quoted
the reason: the close only commits the dashboard for worktree closes.

That matches `skills/tasks/verbs/close.md`: step 10 regenerates the dashboard after step 7's commit (or after
step 5's `verify` park), and step 10b, which commits what 10–11 wrote, applies to "worktree closes with no
upstream only", with "In-place projects keep today's behaviour". Nothing says what that behaviour is. The
next `close`'s clean-tree checks, and [[fix-next]]'s *Verify the reset really is safe*, then meet a dirty
tree that no step owns.

A container close does the same: TASK-221's fixture run of `/tasks close --story` (2026-10-09, single-branch)
ended with the regenerated `tasks/README.md` and the story file both uncommitted, and said so. The acceptance
criteria below cover task closes; a container close is the same question.

Established at pick (2026-10-09): the `done` path does not differ. Step 7 commits before step 10
regenerates, on both paths, and this repo's closes carry `tasks/README.md` only because the agent
regenerated it before committing, off-script. A container close has no commit step at all, so its flipped
STORY.md or EPIC.md floats too. An in-place PR-per-task close is unowned as well: step 10 would write the
dashboard on the checked-out task branch.

## Acceptance criteria

- [x] `close.md` states, for an in-place project, which commit (if any) carries the regenerated dashboard and feature rollups, on both the `done` path and the `verify` park
- [x] An in-place close on a `single-branch` fixture ends with `git status --short` clean, on both paths
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Worktree closes and closes with an upstream — step 10b and step 10 already define them

## Human test plan

- [x] On a `single-branch` fixture, close one task to `done` and park another at `verify`. Expected: `git status --short` is empty after each.
  - **Passed 2026-10-09:** fixture `%TEMP%\d292` (`single-branch`, no remote, one story, two in-progress tasks), `echo "/tasks close TASK-00N --unattended" | claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" … --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills`. TASK-001 → `done` in `c540b94`, TASK-002 → `verify` in `861d56b`; each commit carried `tasks/README.md` (and TASK-001's carried the TASK-003 its 5d sweep spawned), and `git status --short` was empty after each

## Outcome

**What was fixed:** `/tasks close` now says which commit carries the dashboard and feature rollups it
regenerates, keyed on where the close commit landed (`close.md` step 10's table). In place on the default
branch (`single-branch`), steps 10–11 run *before* the close commit (step 7, or step 5's `verify` park
commit) and ride in it. After a step-8 merge with no upstream, in place or in a worktree, step 10b's
`chore: dashboard and rollups after TASK-NNN` commits them. A close left unmerged on a task branch writes
neither. `--no-pr`, step 7's Skip, or no git leaves them uncommitted and the confirmation names them. A
container close gains its own commit step, `chore: close STORY-NNN`, since it had none and its flipped
STORY.md floated too. Step 7's staging now names step 5d's spawned task files.

**Step 6 split — 3/3 fix-dependent.** Cold A/B: one reader each on the HEAD and post-fix `close.md`,
`cd C:/Source/WebChecker && claude -p --disable-slash-commands --add-dir <scratchpad> < brief`; coldness
not separately confirmed. Brief: a `single-branch` unattended close, asked for every commit, its files and
the final `git status --short`.
- *close to `done`*: old text → ` M tasks/README.md` ("In-place projects keep today's behaviour"); new → empty.
- *`verify` park*: old → ` M tasks/README.md`; new → empty.
- *story close*: old → no commit, STORY.md and README dirty; new → `chore: close STORY-002`, empty.
No contract pins. Both readers raised step 5d's spawned task files as unstated in the commit; that one is now in step 7's staging.
The real fixture run (Human test plan) confirmed the `done` and `verify` paths behaviourally.

**Judgement calls:**
- *One commit on the default branch, not a follow-up chore commit like 10b.* The follow-up terminates and
  matches the worktree path, but doubles the commit count of every single-branch close — the cost step 7
  already cites against a SHA follow-up — and this repo's own closes already carry the dashboard in one
  commit. The follow-up is kept only where the default branch is reached by a merge.
- *An in-place close on an unmerged task branch writes nothing*, rather than committing the dashboard on that
  branch: the checkout *is* the task branch, so a regen there is the per-task conflict step 4b forbids in a
  worktree. This changes the previously unowned in-place PR-per-task behaviour; nobody here runs that
  configuration, so it is unmeasured.
- *Container close commits under `chore:`, not `STORY-NNN: …`*: it changes no code, so [[specs]] should
  attribute nothing to it; registered in AGENTS.md's commit-shape contract.

**Flagged, not fixed:** a container close *with an upstream* now names its flipped files as uncommitted for
a PR, the same as step 10's rule for the dashboard. Whether a status flip should travel that way is not
measured on any upstream repo here, so the text leaves it on that rule and adds nothing new.

## Implementation plan

_Populated by `/tasks plan TASK-292` — leave empty until then._

## Progress log

- step 2 — picked; ranked above TASK-220 because both are silent tree-state defects (keys 1-3 tie: no wrong answer is printed, the damage surfaces at the next run), but TASK-292 is reached by every in-place close — this repo's own configuration, and every /fix-next run here — and was observed in two real runs (key 5, verified), while TASK-220 needs a block-then-close sequence; key 4 also favours it: one verb file, no open design question. Keys 6-8 not reached.
- step 3 — verified, wider than filed: step 7 commits at line 366, step 10 regenerates after it, and 10b's commit covers "worktree closes with no upstream only", so an in-place close leaves the dashboard uncommitted on **both** paths (the `verify` park "skips to step 10" after its own commit). This repo's closes carry `tasks/README.md` (e9cc2c7, d2e9efb, 0050c43, aabc0e4) only because the agent regenerated it before committing, off-script. A container close has no commit step at all, so the flipped STORY.md/EPIC.md floats too. In-place PR-per-task also unowned: step 10 would write the dashboard on the checked-out task branch. Context rescoped below; criteria unchanged.
- step 4 — layer: local (`skills/tasks/verbs/close.md`)
- step 5 — fix in `skills/tasks/verbs/close.md` (step 10's table of where the close commit landed → which commit carries steps 10–11; step 7 and step 5's park run 10–11 before a default-branch commit; 10b widened to in-place step-8 merges; new container-close step 5 commit `chore: close STORY-NNN`) and `AGENTS.md` (commit-shape contract names the new subject); prose skill, no suite — lint OK
- step 6 — cold A/B, pre-fix (HEAD) vs post-fix `close.md`: 3/3 fix-dependent — `done` close, `verify` park, story close (each ` M tasks/README.md` or more → clean); contract pins: none. Real fixture `%TEMP%\d292`: both paths clean
- step 7 — `docs/specs/work-tracking.md` regen: "Post-close tracker sync and hints" gains the commit rule and scenario "Single-branch close leaves a clean tree"; "Closing stories and epics" gains the container commit; stamped `aabc0e4`
- step 8 — Outcome written; handing to `/tasks close TASK-292 --unattended`
