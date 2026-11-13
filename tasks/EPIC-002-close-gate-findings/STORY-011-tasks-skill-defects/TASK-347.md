---
id: TASK-347
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-346-1, DRILL-346-2, DRILL-346-3, DRILL-346-4, DRILL-346-5, DRILL-346-6, DRILL-346-7, DRILL-346-8, DRILL-346-9, DRILL-346-10]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/tasks pick` leaves eight more readings open in its list, its hand-off and its plan offer

## Context

Spawned 2026-11-12 from TASK-346's Human test plan drill: two cold runs of TASK-255's brief on the `d255` fixture
(`%LOCALAPPDATA%/Temp/d255`, reports kept there as `report-346a.md` and `report.md`). This is a **group**: every
reading is in `skills/tasks/verbs/pick.md` or the `plan.md` hand-off it chains, each is small, and they share one
fixture and one drill, so they are cheaper done and re-drilled together.

**Raised by both runners independently** (the agreement bar FEATURE-002 D10 uses):

- **DRILL-346-1:** step 3's `taken (hidden)` line goes "under the list", but the list and its question are step 4. Before or after the question is unstated.
- **DRILL-346-2:** step 3 captures "parent IDs (story + epic)", while step 4's example renders titles (`EPIC-001 Authentication → STORY-001 Password login`). Both runners read the titles to match the example.
- **DRILL-346-3:** the multiple-in-progress warning prints "after the choice", with no position relative to steps 5–9.
- **DRILL-346-4:** step 9's dispatch bullet ends by putting the 9b offer, but the `github-issue:` and boundary bullets come after it. Their order relative to the offer is unstated.
- **DRILL-346-5:** step 6's "touches more than one file" trigger cannot be judged before a plan exists, and "its Context names unknowns" is undefined.
- **DRILL-346-6:** 9b's T1 ("names what decides it") was judged to fail on "visible in the CLI output" by both runners, but each called it a judgement, against the test's claim that two readers reach the same answer.
- **DRILL-346-7:** the in-progress line's `<worktree path>`: git's absolute path, or the declared relative form.
- **DRILL-346-8:** a verify-on-branch check reads `git show task/TASK-NNN:…`, which has no local ref for a remote-only task. It made no difference on this fixture.

**Raised by one runner** (recorded, not held to the bar; fold them in if the fix reaches them):

- **DRILL-346-9:** `plan.md` chained from `pick` prints its own confirmation, including "Start work with `/tasks pick`", mid-pick; only a chain from `new` is exempted. Its grilling field has no value for `--no-grill`.
- **DRILL-346-10:** step 8's rows for "anywhere, with an upstream" and "in a worktree … never reached here" both seem to apply to a worktree pick with an upstream. Separately, when 6b restores the main copy's task file relative to the commit and push is unstated.

## Acceptance criteria

- [x] DRILL-346-1 … 8 each have one stated answer in `pick.md` (or in `plan.md` where the reading is plan's)
- [x] DRILL-346-9 and 10 are either answered or recorded on this task as not reproduced by a second runner
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The four readings TASK-346 settled (step 4's question, the fetch, step 6's no-answer path, the `pr:` question at 6b Match)

## Human test plan

- [x] Re-run TASK-255's brief on the `d255` fixture with a cold runner (recipe on TASK-255). Expected: none of DRILL-346-1 … 8 in its "left undecided" section
  - **Passed 2026-11-13.** Fixture `%LOCALAPPDATA%/Temp/d255`, unchanged since TASK-346 (worktrees for TASK-011 and
    TASK-012, TASK-014 only on the remote, TASK-013 free). Its `skill/` was replaced with `skills/` at this fix. The
    346 copy is kept as `skill-346/`.
    - **Brief and command:** the brief was `brief.txt`, unchanged, and the runner command was TASK-255's. The report
      is `report-347.md`.
    - **Coldness:** no skills listed and no Skill tool.
    - **Repo state:** clean afterwards, and every branch unchanged.
    - **None of DRILL-346-1 … 8 is in its undecided list.** Its "settled for me" list names the line order (debt,
      in-progress, list, tie line, taken, question), the worktree path's form, the triggers judged from the task
      file, and T1 read by form. T1 failed on *"visible in the CLI output"* because the item names no command and no
      file.
    - **DRILL-346-10 was not reproduced:** this runner skipped step 8 entirely on the worktree path.
    - **Two readings came from this task's own wording and were fixed at the close:**
      - the plan-lines bullet and the inferred-values bullet both said "first". The plan bullet now follows, without
        "first";
      - the TASK-139 tie line did not say what "the cut" is for a list with no length limit. It now names the view's
        own limit, and excludes tasks left out as taken, blocked or awaiting verification.
    - **One-runner readings, pre-existing, recorded here and not filed:**
      - a pick whose fetch the brief forbade;
      - whether a task that is both taken and awaiting verification is a candidate;
      - a line break inside the in-progress line's template;
      - both a plan-default line and `grilling: skipped — --no-grill` printing;
      - the boundary and work-brief text not being fixed;
      - where the `pr:` question falls relative to the upstream line;
      - the warning counting a worktree that may be another session's;
      - 9b's template ending in a literal `[Y/n]`.

## Implementation plan

Drafted 2026-11-13 by `/fix-next`, as `/tasks plan --no-grill` would write it (triggers: three files, three
criteria). One stated answer per reading:

| Reading | Answer | Where |
|---|---|---|
| 346-1 | `taken (hidden)` prints after step 4's list and its tie line, before the question | `pick.md` steps 3–4 |
| 346-2 | the list renders ids **and** titles. Step 3 captures both | `pick.md` steps 3–4 |
| 346-3 | the warning prints right after the choice, before step 5 reads the file | `pick.md` § Edge cases |
| 346-4 | step 9's other bullets run first, in order. The dispatch runs last, since its offer or wait ends the pick | `pick.md` step 9 |
| 346-5 | both triggers are read off the task file alone: "more than one file" means it names two or more paths, and "unknowns" means named markers | `pick.md` step 6 |
| 346-6 | T1 is read by form: an item passes only when it carries a backticked command, path, file, field or section name, or a `§` reference | `pick.md` 9b |
| 346-7 | `<worktree path>` is the absolute path `git worktree list --porcelain` prints | `pick.md` step 3 |
| 346-8 | a branch that exists only on a remote is read as `<remote>/task/TASK-NNN` | `SKILL.md` § Collection pass, which owns the check `pick` step 2b reads |
| 346-9 | `plan.md` chained from `pick` prints no confirmation of its own. `--no-grill` reports `grilling: skipped — --no-grill` | `plan.md` steps 7–8 |
| 346-10 | left for the re-drill: one runner, and a second one reproducing it is the bar | — |

**346-8 is answered at the owner and not in `pick.md`.** `pick.md` step 2b defers to the Collection pass's
`inReviewTasks[]`, which is where the branch read is written. A second copy in `pick.md` is what § *Defer to a shared
inventory* forbids.

## Outcome

**The fix.** `/tasks pick` now states one answer for each of the ten points two cold runners had to settle for
themselves:
- the order of the lines under the list: tie line, then `taken (hidden)`, then the question;
- parents printed with titles (`EPIC-001 CLI → STORY-001 Export command`);
- where the multiple-in-progress warning prints;
- step 9 runs its bullets as written, with the dispatch on `assignee:` last;
- the plan triggers are judged from the task file alone;
- 9b's T1 is read by the criterion's form, not by judgement;
- the in-progress line's path is git's absolute path;
- a branch that exists only on a remote is read as `<remote>/task/TASK-NNN`;
- `plan` chained from `pick` prints its lines inside `pick`'s hand-off, without the "Start work with `/tasks pick`"
  hint, and reports `skipped — --no-grill`.

**Step-6 split.**
- **Text assertions:** 9 of 9 fail on `HEAD`'s copies and pass on the fix, one per reading from 346-1 to 346-9, all
  fix-dependent. The script is `task347-check.sh` in the session scratchpad.
- **Behaviour:** TASK-346's cold drill raised 346-1 to 8 from both runners. On the fixed text the same brief and
  fixture leave none of them open.
- **Contract pins, not evidence:** skills-lint, and the TASK-139 and TASK-355 assertions, which still pass after
  these edits.

**Judgement calls.**
- **346-8 was answered at its owner, `SKILL.md` § *Collection pass*, not in `pick.md`.** The criterion names
  `pick.md`, but step 2b only points at the Collection pass. A copy there is what § *Defer to a shared inventory*
  forbids.
- **The plan triggers became markers a reader can find.** Two or more named paths, or an `Open decision`, a `?`, or
  *unknown/unclear/undecided/TBD*. Rejected: "use judgement", since that is the reading two runners split on.
  The cost: a task that needs a plan but names no path and asks nothing will not trigger the recommendation. The
  offer still defaults to yes either way.
- **T1 is read by form.** That makes it stricter: a criterion that is really checkable but names no command or file
  now fails, and the offer defaults to `[y/N]`. That is the safe direction for an unattended run.
- **346-9 was folded in** (one runner) because the fix is one exemption beside `new`'s, of the same shape.
  **346-10 was left alone:** not reproduced.

**Close gate (inline, about 45 lines of prose over three files):**
- **Standards:** one owner per rule, and pointers elsewhere. The 346-8 placement is above.
- **Intent:** criteria 1–3 met, and 346-10 is recorded as not reproduced.
- **Correctness:** two problems came from this change and were fixed before the close: the two "first" bullets, and
  the tie line's cut.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged, not fixed.** The eight one-runner readings under the Human test plan. Each predates this task and none
met the two-runner bar, so they are recorded there and not filed.

## Progress log

- step 2 — picked; ranked above TASK-348 because both are correctness-invariants groups of drill readings (key 6 inert), but `pick` runs on every task start while `block`'s confirmation runs only when work is blocked (key 2), and eight of these ten readings met the two-runner agreement bar (key 5). TASK-139 and TASK-355, which ranked above it, are closed
- step 3 — verified: held. DRILL-346-1 … 8 are all still open in the current text, and 346-9's plan.md exemption names only `new`
- step 3b — planned: drafted inline as /tasks plan --no-grill (three files, three criteria)
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/pick.md (steps 3, 4, 6, 9, 9b, § Edge cases), skills/tasks/verbs/plan.md (step 8: --no-grill value, pick-chain exemption), skills/tasks/SKILL.md (§ Collection pass: remote-only branch read); assertions in scratchpad task347-check.sh
- step 6 — reverted fix (HEAD copies): 9/9 assertions failed; fix-dependent = one per reading 346-1 … 9; contract pins = skills-lint. Behaviour: cold re-drill of TASK-255's brief on d255 running (report-347.md)
- step 7 — respecced work-tracking (surgical); requirements changed: Picking a task (taken-line position, triggers from the task file, T1 read by form), Implementation plans (--no-grill value, pick chain); intended — TASK-347 criteria 1–2
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
