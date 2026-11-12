---
id: TASK-346
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-255-1, DRILL-255-2, DRILL-255-3, DRILL-255-4]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/tasks pick`'s choice question has no answer-less path, and three more readings are left open

## Context

Raised by TASK-255's drill (2026-11-05, recorded on TASK-255), in `skills/tasks/verbs/pick.md`:

- **DRILL-255-1:** step 4 says only "Ask user to pick by number (or accept a TASK-NNN ID directly)". It has no
  question text and no answer-less path, against AGENTS.md's ask-step rule.
- **DRILL-255-2:** "With an upstream, fetch first (`git fetch --prune <remote>`), as 6b does" sits in the
  bullet for a named task, so whether a bare pick fetches before building the list (and its `taken (hidden)`
  line) reads two ways.
- **DRILL-255-3:** step 6's plan prompt has "the default set to yes", which leaves open whether silence takes
  the default and hands off to plan.md, or does nothing.
- **DRILL-255-4:** on the worktree path, 6b's "Match → print the in-a-worktree line and go to step 9" skips
  step 7, while 9b's contract table says step 7's `pr:` question is "asked here, before the offer".

## Acceptance criteria

- [x] Step 4 states its question and what happens with no answer
- [x] Whether a bare pick fetches before building the list is stated once
- [x] Step 6's plan prompt states its no-answer outcome
- [x] The worktree path and 9b's table agree on whether, and where, the `pr:` question is put
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The five readings TASK-255 settled
- Eight further readings both drill runners raised in `pick.md`'s list, hand-off and plan offer (and two raised by one) — TASK-347

## Human test plan

- [x] Re-run TASK-255's brief (on its Progress log) on a freshly built `d255` fixture with a cold runner. Expected: none of the four in its "left open" section
  - **Passed 2026-11-12:** TASK-255's `d255` fixture in `%LOCALAPPDATA%/Temp/d255`, **reused, not rebuilt**: its last run was read-only and `git -C repo status --porcelain` was empty, with the branches and worktrees TASK-255 recorded; `skill/tasks` re-copied from this fix. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep < brief.txt`, cwd the fixture root (no agent guide). **First run** (`report-346a.md`, on a copy made before the last edit) put step 4's question verbatim and took its no-choice line, read that a pick fetches (flagging only the brief's own no-fetch rule), took step 6's default with `--no-grill`, and put the `pr:` question at Match. But it read the `pr:` question and the upstream pick commit in either order. That edit, already made, settles the order, so the run was repeated. **Second run** (`report.md`, current text): none of DRILL-255-1…4 in its "left undecided" list; it put the `pr:` question after the pick commit and push. Coldness: both listed no skills and had no Skill tool. Ten further readings across the two runs → TASK-347

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). All edits in `skills/tasks/verbs/pick.md`.

1. **DRILL-255-1** — step 4: put the question in the bold-quote form the other ask-steps use. No answer: start
   nothing, write nothing, print `pick: no task chosen — nothing was changed`. Choosing for the user is the inference
   the ask-step rule forbids, and a pick is a write.
2. **DRILL-255-2** — move the upstream fetch out of the bare-ID bullet into its own paragraph at the end of step 2.
   It covers **every** pick, before the bare ID's taken check and before step 3 builds its list and `taken (hidden)`
   line, because a stale remote list hides another clone's branch in both places. Point the bare-ID bullet at it,
   and have 6b's upstream fetch say it does not run a second time in one pick.
3. **DRILL-255-3** — step 6: no answer takes the stated default. Hand off to `plan.md` with `--no-grill` (the grill
   is a conversation), and report `plan drafted — the default; nobody chose it`. This is the reading `/fix-next`
   step 3b already takes: a missing answer is not a decline.
4. **DRILL-255-4** — 6b's **Match** bullet: before going to step 9, put step 7's `pr:` question, the one part of
   step 7 the pick commit could not ask. An answer is written to the worktree's copy and rides to `close`. 9b's
   table row then names where the `pr:` question is put on the worktree path.

## Outcome

**The fix.** `/tasks pick` had four places a reader had to guess, all in `skills/tasks/verbs/pick.md`:
- **Choice question:** step 4 now states its question, and with no answer it starts nothing.
- **Fetch:** with an upstream, every pick fetches once before any taken check, for the list as much as for a named
  task. 6b no longer fetches a second time.
- **Plan prompt:** step 6's `[Y/n]` takes its default when nobody answers. It drafts the plan with `--no-grill` and
  says nobody chose it.
- **`pr:` question:** a worktree pick puts step 7's `pr:` question at 6b's Match, after the pick commit and push
  when there is an upstream, which is where 9b's table says it is asked.

**Step 6 split.** 4 of 4 assertions failed on HEAD's `pick.md` and pass on the fix. All four are fix-dependent: step 4
has a quoted question and a no-answer line, the fetch is a step-2 paragraph naming step 3's list, step 6 states its
no-answer default, and Match puts the `pr:` question with 9b's row naming it. Contract pin, **not evidence**:
skills-lint passes on both. The evidence for the readings themselves is the drill (Human test plan): two cold runs, the
second clean.

**Judgement calls.**
- **No answer at step 4 starts nothing, rather than taking the top of the list.** A pick writes a status and may cut a
  branch. Taking the first entry would be the inference AGENTS.md's ask-step rule forbids, and a cold runner left with
  no answer is exactly the case the rule exists for.
- **No answer at step 6 drafts the plan, rather than proceeding unplanned.** The prompt's own default is yes, and
  `/fix-next` step 3b already reads a missing answer that way. Proceeding unplanned would turn silence into a decline.
  The plan runs `--no-grill` because a grill is a conversation.
- **6b fetches when step 2 did not, rather than never.** My first wording ("already run, not repeated") would have left
  `/fix-next`, which enters 6b directly without pick's step 2, with no fetch at all. That was caught in the inline
  correctness pass, before the drill.
- **The `pr:` question goes after the upstream pick commit.** Before it, an answer would ride in a commit described as
  carrying only the pick. The first drill run raised the ordering; the edit settling it was made before that report
  came back, and the second run confirmed it.
- **Fixture reused, not freshly built**, against the plan's wording. The last run on it was read-only, and its state
  was checked unchanged. Rebuilding would have reproduced the same refs at more cost. Recorded so the next reader can
  disagree.
- **Respec was surgical.** Two requirements in `work-tracking` were contradicted. Nothing was re-derived, because the
  only intervening `skills/tasks` commit is not feature-linked.
- **Close gate ran inline** on a ~40-line prose diff.
  - Standards: no finding. The questions use the bold-quote form, and every no-answer line is a reported unresolved
    state or a default that names itself as unchosen.
  - Intent: all five criteria met. The one addition beyond them, 6b's fetch wording, is required by criterion 2's
    "stated once".
  - Correctness: one finding, the `/fix-next` fetch regression above, fixed.
  - Security: not applicable.
  - Comments: not applicable, no comment in range.

**Flagged, not fixed.** Ten further readings from the two drill runs (eight raised by both) → TASK-347, P3, grouped.

## Progress log

- step 2 — picked; ranked above TASK-330 because both are ask-steps with no answer-less path in a `tasks` verb (key 1 wrong results, key 2 equal), but `pick` runs on every task start while `migrate` runs once per tree (key 2, reachability). TASK-239, ranked above this last run, closed in 8815b8b. Key 6 did not separate them: both `correctness-invariants`
- step 3 — verified: held, all four. DRILL-255-1: step 4 is "Ask user to pick by number", with no question and no answer-less path. DRILL-255-2: the fetch sits in the bare-ID bullet, and the Collection pass never fetches, so a bare pick's list reads unfetched remote refs. DRILL-255-3: "[Y/n]" with "default set to yes" and no no-answer line. DRILL-255-4: 6b Match → step 9 skips step 7's `pr:` question while 9b's table says it is "asked here, before the offer"
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: 5 acceptance criteria)
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/pick.md (step 4 question and no-choice line; the upstream fetch lifted to a step-2 paragraph covering every pick, 6b fetching only when step 2 did not, which keeps /fix-next's direct entry to 6b fetching; step 6's no-answer path; 6b Match puts step 7's `pr:` question; 9b's table row names it); no test file (a prose repo: the guard is the step-6 check and the drill)
- step 6 — reverted fix (HEAD's pick.md): 4/4 assertions failed; fix-dependent = step 4 carries a quoted question and a no-answer line, the fetch is a step-2 paragraph naming step 3's list, step 6 states its no-answer default, Match puts step 7's `pr:` question and 9b's row names Match; contract pins = skills-lint (passes on both, checks none of this); evidence for the readings themselves = the Human test plan drill
- step 7 — respecced work-tracking (surgical, stable wording); requirements changed: "Picking a task" (no choice ⇒ nothing started; every pick with an upstream fetches once, the worktree step not again; plan offer's no-answer default) and "Task branch per integration policy" (`pr:` offer on a worktree pick comes once the worktree is entered); intended — TASK-346's criteria. generated-at → 8815b8b. shaped-by unchanged: the only commit to skills/tasks since the last stamp (1913051, TASK-255) is feature: null
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
