---
id: TASK-228
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-26, SH-27, SH-29]
pr: null
github-issue: null
jira-key: null
---

# `fix-next` does not say where a run goes after an outcome that is not a fix

## Context

Found by the defect-draining spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). Three places in
`skills/fix-next/SKILL.md` end a step without a fix and leave the next move unstated. One root cause: the loop
defines only the path on which the defect is fixed in this repo.

- **SH-26 — step 4, upstream fix.** "Symptom here, defect upstream" records the decision, flags the user and marks
  the local task blocked, and stops there. It does not say whether the run then stops, closes anything, or returns to
  step 1. Step 0 then reports this skill's own blocked task as `not resumed` on every later run, and nothing says
  that is the expected end state.
- **SH-27 — every task blocked.** Step 2 says an all-blocked pool "is an empty pool for step 1's purposes: report the
  blocked tasks and stop". Step 1's empty-pool branch lists exactly two causes with two messages (no review filed; a
  backlog that predates the stamp). Neither fits, so a reader of step 1 alone has no message for this case.
- **SH-29 — step 3, not a defect.** A rejected finding is cancelled and the run "returns to step 1 for the next
  candidate", on a bare run too. A bare run's contract (step 9, *What this skill does NOT do*) is one defect per
  invocation. Nothing says whether a rejected false positive counts as that one defect.

## Acceptance criteria

- [x] Step 4's upstream path names what the run does next, in bare and `--loop` mode, and step 0 says a blocked run
      of this skill's own is the expected result of that path
- [x] Step 1's empty-pool branch covers the all-blocked case or points at step 2's rule, so the two do not disagree
- [x] Step 3 states whether a rejected finding uses up a bare run's one defect, with the reason
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ask-steps in the same skill — TASK-229
- Changing the ranking keys
- Deferred to TASK-298 — where a cancel or block is committed when the pick cut a task branch

## Human test plan

- [x] On an in-place fixture whose top pool task is a false positive and whose second is a real defect, run bare
      `/fix-next` in two fresh sessions. Expected: each run ends after the first task with the tree clean, and
      both runs agree.
  - **Passed 2026-10-11:** `%TEMP%\d228` (single-branch; TASK-001 claims `exportRows` drops the last row, which it
    does not; TASK-002's `average([])` NaN is real). Both runs cancelled TASK-001, committed it as
    `TASK-001: cancelled — not a defect`, left TASK-002 `todo` and named it as the next pick, with a clean tree. The
    brief was the bare command. The runner holds the installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-228` — leave empty until then._

## Outcome

**The fix.** `/fix-next` only defined the path on which a defect is fixed. A rejected finding sent the run "back to
step 1", so a bare run went on to a second defect. An upstream fix left the task blocked with no next step. An
all-blocked pool had no message in step 1. A new section, *A run that ends without a fix*, covers both non-fix
exits:
- they count as the bare run's one defect, because the run has already done a defect's work;
- the run commits the record, since neither `cancel` nor `block` commits and step 9 needs a clean tree, as
  `TASK-NNN: cancelled — not a defect` or `TASK-NNN: blocked — fix belongs upstream`;
- then it goes to step 9.

Step 0 now says its `not resumed` line is the expected result of the upstream path. Step 1's empty-pool branch
names the all-blocked case. The two new commit subjects are registered in AGENTS.md's commit-subject contract.

**Step 6 split.** Pre-fix text, 2 runs: **both went on to TASK-002 after cancelling TASK-001**. One fixed it, and
the other started it and blocked it on a question, ending with two commits and a task left `in-progress`.
Fixed text, 2 runs: **both stopped after the cancel** and named TASK-002 next. **Fix-dependent:** stopping after
a rejection. **Contract pins, not evidence:** the rejection itself and a clean tree, the same in all four runs
(the pre-fix runs also committed their cancel, under subjects they made up: `TASK-001: cancel — …`). The
upstream and all-blocked exits were not drilled. They rest on the text.

**Judgement calls.**
- *A rejection uses up the run.* "A correct no is a deliverable" was already the skill's own line. Continuing is
  what produced a second, unrelated change in one bare session, the thing the one-defect boundary exists to stop.
- *Commit in place, and stop where the commit has no defined home.* With a task branch, a cancel committed there
  never reaches the default branch, so the next run would rank the finding again or hide it as taken. That
  needs its own answer → TASK-298, rather than a guess here.
- *The subjects lead with the id,* like `pick`'s, because they touch only the task tree, so [[specs]] attributes
  no behaviour to them.

**Flagged, not fixed.** TASK-298 (spawned): where the record goes when the pick cut a task branch.

## Progress log

- step 2 — picked; ranked above TASK-229 because three exits of the loop leave the next move unstated, so two runs that meet the same false positive or upstream defect can do different amounts of work (key 3: a run that silently drains a second defect, or stops early, reads as normal), reached on every rejected finding (key 2), and all three sit in one file (key 4); TASK-229's missing question texts surface by stalling. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held, and one gap wider. All three exits are as filed. Also: neither `/tasks cancel` nor `/tasks block` commits, so a run that ends at step 3 or 4 fails step 9's own clean-tree check with nothing saying what to commit. In place that is fixed here; when step 2 cut a task branch, where the record belongs is a separate question → spawned TASK-298
- step 4 — layer: local (`skills/fix-next/SKILL.md`; `AGENTS.md` commit-subject contract)
- step 5 — fix in `skills/fix-next/SKILL.md` (step 0: `not resumed` is the expected end of the upstream path; step 1: all-blocked bullet; steps 3 and 4 end via the new § *A run that ends without a fix*: counts as the one defect, commit in place as `TASK-NNN: cancelled — not a defect` / `blocked — fix belongs upstream`, stop uncommitted on a task branch → TASK-298, then step 9; final report lines 1–2; guardrail wording) and `AGENTS.md` (commit-subject contract: six further commits). Lint green; drill 2/2 on `%TEMP%\d228`
- step 6 — reverted `SKILL.md`: pre-fix 2/2 runs went on to TASK-002 after cancelling TASK-001 (one fixed it, one blocked it mid-run); fixed 2/2 stopped after the cancel. Fix-dependent = stopping after a rejection; contract pins = the rejection and a clean tree. Upstream and all-blocked exits not drilled
- step 7 — respecced defect-draining (blocked-run requirement: the expected end of the upstream path; empty pool: all-blocked case + scenario; re-verify and layer requirements end the run; new requirement "A run that ends without a fix still ends clean" + scenario); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
