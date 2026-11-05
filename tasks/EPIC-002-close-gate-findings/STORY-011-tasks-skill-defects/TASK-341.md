---
id: TASK-341
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-337-1, DRILL-337-2, DRILL-337-3]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/tasks pick` calls a `verify` task "in review", cannot find the default branch with no remote, and flips the status before cutting the branch

## Context

Raised by the second TASK-337 drill run (2026-11-05, recorded on TASK-337), in `skills/tasks/verbs/pick.md`:

- **DRILL-337-1:** step 2b's debt line template reads `⚠ 2 in review awaiting sign-off: …`, and a runner kept "in review" for a task at `status: verify`, which is the current name. It is the older name, still read as an alias.
- **DRILL-337-2:** steps 6b and 7 turn on "the default branch" and `<default>@{upstream}`, but nothing says how to find the default branch when there is no remote or `origin/HEAD`. Both TASK-182 runners took the only checked-out branch, by inference.
- **DRILL-337-3:** step 7 lists the status edit (`todo` → `in-progress`) before "Cut the task branch". An in-place run edits on the default branch and carries the change onto the new branch uncommitted. Nothing says whether that order is intended, or which step 8 row then applies.

## Acceptance criteria

- [x] 2b's debt line names the state the tasks carry (`verify`, or `review` for the older form), or says why "in review" covers both
- [x] The default branch's source is stated, including a repo with no remote
- [x] Step 7 states the order of the status edit and the branch cut, and step 8's row for the result is unambiguous
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [x] Re-run TASK-182's brief (on TASK-337's Progress log) with a cold runner. Expected: none of the three in its "left undecided" section
  - **Passed 2026-11-05:** TASK-182's brief verbatim, runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, on two fixtures built after the fix. `d182c` (`pr-per-task`, no remote, one branch `main`, TASK-002 at verify): `⚠ verification debt: 1 at verify awaiting sign-off: TASK-002`, `main` derived, `task/TASK-001` cut, then flipped. `d182d` (the same plus a local `dev`, rebuilt after the amended step 5): the stated default-branch question, `default branch: not determined — 2 candidate branches and no remote HEAD; no branch was cut and nothing was committed`, the flip left uncommitted on `main`, no dashboard. None of DRILL-337-1…3 in either "left undecided" list. Coldness: neither listed skills

## Outcome

**What was fixed.**
- `/tasks pick`'s debt line now names the state as `verify`, not "in review".
- "The default branch", which `pick`, `close` and `fix-next` all act on, is now defined once, in `tasks/SKILL.md` § *The default branch is derived*. It is recomputed every run from a remote's HEAD, else the only local branch outside `task/*` and `record/*`, else an unborn repo's HEAD. With several candidates it asks a stated question. With no answer it records nothing, cuts nothing, commits nothing, and prints that the default branch was not determined.
- Step 7 now cuts the task branch first and flips the status second, so the flip is made where it stays. Step 8's rows are keyed on where the checkout ended up, including one that is not, or may not be, the default branch.

**Step-6 split:** 0/0, because this is prose only. Evidence is two fixtures, one determined and one not. The first not-determined run found two gaps in this task's own new text, both fixed and re-run.

**Judgement calls.**
- **No `default-branch:` config field.** Asking covers the one undetermined case without touching the template, `init` or the layer. A declaration would be a user decision. The cost is that an unattended run on a repo with several branches and no remote reports "not determined" every time and cuts nothing, which is the outcome AGENTS.md requires.
- **The checked-out branch is never evidence,** since during a task it is the task branch.
- **An answer is used for that run only,** because remembering it would record a decision nobody declared.

**Review (close step 5b, inline).** Adherence: one definition with pointers, no list restated, and the new ask-step has its question and no-answer path. Fidelity: all three criteria are met. Correctness: the two drill-found gaps are fixed. `fix-next` step 2's lines still ride where they did, plus the in-place clause.

**Flagged, not fixed.**
- 2b's three-or-more ask ("Clear verification debt first?") has no stated no-answer path.
- On a repo with several branches and no remote, unattended runs will always report "not determined". A `default-branch:` declaration is the user's call.

## Implementation plan

### Approach
The default branch is defined once, in a new § of `tasks/SKILL.md` that `pick`, `close` and `fix-next` point at. No `.config.yml` field is added: the ask path covers the one case that is only consistent with several answers, so the template, `init` reconciliation and the layer stay as they are.

### Steps
1. `pick` 2b: `⚠ verification debt: 2 at verify awaiting sign-off: …`, and a sentence that `verify` names both spellings of the state.
2. `SKILL.md` § *The default branch is derived*, recomputed every run:
   - a remote's `refs/remotes/<r>/HEAD` (all remotes that answer must agree);
   - else `git ls-remote --symref <r> HEAD`, read-only;
   - else the only local branch outside `task/*` and `record/*`;
   - else an unborn repo's HEAD;
   - else ask. The question is stated. With no answer, write nothing, cut nothing, and print `default branch: not determined — …`; an answer is used for this run only and never recorded.
   - Pointers in `pick` 6b, `close` and `fix-next`.
3. `pick` step 7: cut first, then flip, so the flip is made where it stays. Step 8's rows are keyed on where step 7 left the checkout. `fix-next` step 2 gains the in-place clause (its lines ride with the flip, after the cut).
4. Specs `work-tracking` (Picking a task; Task branch per integration policy, +1 scenario) and `defect-draining` (the in-place clause). Lint; drill.

### Risks
- With several local branches, no remote and nobody present, every unattended run reports "not determined" and cuts nothing. That is correct under AGENTS.md, but it recurs. A `default-branch:` declaration would be a user decision with its own task.
- `ls-remote` is a network call; offline it falls through to the local rows.
- Out of scope: 2b's three-or-more ask ("Clear verification debt first?") states no no-answer path. Offer a spawn.

## Progress log

- step 2 — picked; ranked above TASK-343 because key 1: an inferred default branch decides where pick commits and which step-8 row applies, where TASK-343 is question wording; key 5: both TASK-182 runners hit DRILL-337-2 and -3; keys 6 and 7 tie
- step 3 — verified: held, DRILL-337-2 wider than filed. 2b's template says "in review" for a `verify` task; "the default branch" drives pick 6b/7/8, close and fix-next and is defined nowhere in skills/; step 7 lists the status edit before the branch cut. Criteria unchanged; criterion 2's fix is expected to be one definition the verbs point at
- step 3b — planned: /tasks plan --no-grill (three criteria, four files); no split signal (the 2b ask-step gap is outside the criteria, offered as a spawn)
- step 4 — layer: local
- step 5 — fix in skills/tasks/SKILL.md (§ The default branch is derived: evidence order, the stated question, no-answer path), skills/tasks/verbs/pick.md (2b line names verify; 6b pointer; step 7 cuts then flips; step 8 rows by where the checkout is), skills/tasks/verbs/close.md and skills/fix-next/SKILL.md (pointers; fix-next's in-place clause); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill, plus a second fixture with two local branches for the not-determined path
- step 7 — respecced work-tracking (Picking a task: debt names verify, cut then flip; Task branch per integration policy: the default branch derivation and the not-determined path, +1 scenario) and defect-draining (in-place lines ride with the flip); intended — TASK-341's criteria
- step 5 (amended after the first drill pair) — d182c (one branch, no remote) passed: `⚠ verification debt: 1 at verify …`, `main` derived, branch cut, then flip; none of DRILL-337-1…3 in its undecided list. d182d (branches `main` and `dev`, no remote) took the not-determined path as written: it asked the stated question, printed `default branch: not determined — 2 candidate branches …` and cut nothing. But it found two gaps in this task's new text: "write nothing" read either as "record nothing" or "flip nothing", and step 8 had no row for a checkout that is not, or may not be, the default branch. Fixed: the no-answer path records no default branch and lets the rest of the pick (the flip included, uncommitted) go on in the current checkout; step 8 gains a "write nothing" row for that checkout. d182d rebuilt and re-run
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
