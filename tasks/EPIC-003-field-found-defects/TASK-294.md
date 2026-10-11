---
id: TASK-294
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-09
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-161-2]
pr: null
github-issue: null
jira-key: null
---

# `/feature review` writes its result into `decisions.md` and leaves it uncommitted

## Context

Seen while running TASK-161's human test plan (2026-10-09). A real `/feature review FEATURE-001` on a
throwaway `single-branch` fixture (`%TEMP%\d161r`, no remote) failed Gates A and B, appended a History line
to `docs/features/FEATURE-001-csv-export/decisions.md`, and ended with ` M …/decisions.md` and the report
"I didn't commit it".

That matches `skills/feature/verbs/review.md`: Gate B says "note it in the feature's `decisions.md` History
log", Gate C records sign-off as a History line, and step 5 writes `idea.md`'s `status:` and runs
`/feature status` (which writes `status.md` and the features index). No step commits any of it. The next
`/tasks close` clean-tree check and [[fix-next]]'s *Verify the reset really is safe* then meet a dirty tree
that no step owns.

The same defect TASK-292 fixed in `/tasks close`, in a second verb. TASK-292's answer — every file a step
writes is committed by a named step, or the confirmation names it as uncommitted — is the shape to match.

Not yet established: whether `/feature decide`, `/feature status` and `/feature decompose` leave the same
residue when run alone. Check them before fixing, and file what you find rather than widening this task.

## Acceptance criteria

- [x] `review.md` states which commit carries the History line, `idea.md`'s status change and the
      `/feature status` rollup, or that they are left uncommitted and named in step 6's confirmation
- [x] A `/feature review` on a `single-branch` fixture ends with `git status --short` clean (or with the
      residue named in its report, if that is the chosen shape), on both a failing and a passing review
- [x] The other `/feature` verbs are checked for the same residue, and any found are filed — checked; none is
      this defect (authoring verbs leave their edit for the user, as `pick`, `cancel` and `block` do — see Outcome)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Projects with an upstream — whether a review's writes travel through a PR there is the same open question
  TASK-292's Outcome flagged for a container close; both are TASK-296
- Gate A's handling of `verify` tasks — TASK-235

## Human test plan

- [x] On a `single-branch` fixture, run `/feature review` on a feature that fails Gate B, then on one that
      passes every gate. Expected: `git status --short` is empty after each, or the report names every file
      it left uncommitted.
  - **Passed 2026-10-11:** cold `claude -p` runs on `%TEMP%\d294` (fixture corrected so Gate A passes and the
    `N/A` plan is true). FEATURE-001 (Gate B: one step not run) → `chore: review FEATURE-001`, 5 files, tree
    clean. FEATURE-002 (all three gates passed, signed off) → `chore: review FEATURE-002`, 4 files, status
    `done`, tree clean. Brief: the bare `/feature review FEATURE-NNN`, plus the product owner's sign-off for
    FEATURE-002; nothing about committing. Runner: `claude -p --permission-mode acceptEdits --allowedTools
    "Bash(git:*)" "Bash(node:*)" Read Grep Glob Edit Write --add-dir C:/Users/FinStat/.claude/skills
    C:/Source/project-lifecycle-skills`, from the fixture's directory. Coldness: the brief withheld the
    expected result. The runner holds the installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-294` — leave empty until then._

## Outcome

**The fix.** `/feature review` used to write its record (History lines in `decisions.md`, `idea.md`'s status,
task files parked at `verify`, the rollup and index) and commit none of it, so the record of a sign-off sat in a
dirty tree until it rode into some unrelated commit or was lost. A new step 5b commits exactly those files as
`chore: review FEATURE-NNN` on a project with no upstream, whichever way the gates went, and commits nothing with
an upstream or without git. Step 6 now always names either the commit or every uncommitted file. `AGENTS.md`'s
commit-subject contract lists the new subject beside `close`'s two.

**Step 6 split.** On a single-branch fixture (`%TEMP%\d294`), with the fix: a Gate-B-unmet review of
FEATURE-001 and a signed-off review of FEATURE-002 each ended clean with one `chore: review` commit (1 and 4
files). With `review.md` reverted: the signed-off FEATURE-002 review left 3 files dirty and reported "Nothing is
committed" — **fix-dependent**. The reverted FEATURE-001 review stopped at Gate A and wrote nothing, so it is a
**contract pin, not evidence**: it ends clean either way. (Gate A failed there because the fixture's
`src/export.js` has a stray line break inside a string — a fixture flaw, not a finding.)

**Judgement calls.**
- *Commit, rather than only naming the residue.* The criterion allowed either. Committing follows the precedent
  TASK-292 set for the other gate (`close` and a container close commit their own record); naming alone leaves
  a sign-off one `git checkout .` from lost. With an upstream the rule falls back to naming, because a default
  branch that mirrors its remote takes no local commit (FEATURE-001 D26).
- *The other `/feature` verbs are not this defect.* `new`, `decide`, `decompose`, `prototype`, `pick` and
  `status` also commit nothing, which is the documented norm for authoring verbs (`close.md` step 4 says the
  same of `pick`, `cancel` and `block`): their edit is the user's work. Only a gate writing a verdict owns its
  commit. So nothing was filed for them; the stricter option, a commit in every verb, was rejected because it
  would commit half-authored work the user has not reviewed.
- *A spec regen run from Gate A is not committed by review.* Its diff is the user's to accept, so the
  confirmation names those files instead.

**Flagged, not fixed.**
- With an upstream, whether a review's record should travel through a PR remains the open question TASK-292's
  Outcome raised for a container close → TASK-296, spawned by the close sweep, covering both gates.
- The drills disagreed on whether a `done` task whose `N/A` plan turns out false goes back to `verify` (the fixed run
  parked TASK-002, the reverted run declined): step 5's parking rule is read two ways → TASK-295.
- `change-review`'s spec still predates TASK-293's UX baseline in `/verify-conventions`; the regen offered at
  STORY-028's close (`/specs regen change-review feature-lifecycle --story STORY-028`) covers it.

## Progress log

- step 2 — picked; ranked above TASK-133 because every `/feature review` on a single-branch project leaves its sign-off record uncommitted and unreported (keys 1, 3), it was observed in a real run (key 5), and TASK-292 gives the fix its shape (key 4); TASK-133 is equally silent but needs a loose origin and was never observed (key 2). Key 6 inert: the pool separated on keys 1–5
- step 3 — verified: held as written. `review.md` writes `decisions.md` History lines (Gates A–C), `idea.md`'s `status:` (step 5) and, via `/feature status`, `status.md` and the features index; no step commits any of them. The other `/feature` verbs (`new`, `decide`, `decompose`, `prototype`, `pick`, `status`) also commit nothing, but that is the documented norm for authoring verbs (`close.md` step 4: `pick`, `cancel` and `block` do not commit), so not this defect; only a gate writing a verdict owns its commit, as `close` and a container close do since TASK-292
- step 4 — layer: local (`skills/feature/verbs/review.md`)
- step 5 — fix in `skills/feature/verbs/review.md` (new step 5b, step 6 names the commit or every uncommitted file) and `AGENTS.md` (the commit-subject contract gains `chore: review FEATURE-NNN`); tests: drill on a single-branch fixture (%TEMP%\d294) — failing review (FEATURE-001) and signed-off review (FEATURE-002) each ended clean with one `chore: review FEATURE-NNN` commit; lint green. The FEATURE-002 run also committed the task file it parked at `verify`, which the list in 5b did not name, so 5b now names it
- step 6 — reverted fix (pre-fix `review.md` restored for one run, then put back): 1/2 reverted runs reproduce — the signed-off FEATURE-002 review left 3 files dirty (`decisions.md`, `idea.md`, `docs/features/README.md`) and said "Nothing is committed", where the fixed run committed 4 files as `chore: review FEATURE-002` and ended clean. fix-dependent = the signed-off review; contract pin, not evidence = the FEATURE-001 reverted run, which stopped at Gate A (the fixture's `src/export.js` has a stray line break) and wrote nothing, so it passes with or without the fix
- step 7 — respecced feature-lifecycle; requirements changed: new "Review commits its own record" (two scenarios); "Prototype builds a stakeholder artifact…" gains the UX-baseline check TASK-293 shipped without a regen (one scenario); `generated-at` restamped. `shaped-by` unchanged: neither task links a feature
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
