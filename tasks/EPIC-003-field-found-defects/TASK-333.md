---
id: TASK-333
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-327-1, DRILL-327-2]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/fix-next`'s empty-pool branch miscounts its cases and leaves the final report undefined

## Context

Found by TASK-327's cold drill (2026-11-04, recorded on TASK-327), in `skills/fix-next/SKILL.md` step 1:

- **DRILL-327-1:** "Two causes, two different offers:" heads four bullets. The drained case's fixed line says "every filed finding is closed or awaiting verification" even when nothing awaits verification.
- **DRILL-327-2:** "Empty pool → say so and stop" leaves open whether step 9's report runs. Step 9 says "Either way, name the next pick", and § *Verify the reset really is safe* is part of it.

## Acceptance criteria

- [x] The lead-in matches the number of empty-pool cases, or names none
- [x] The drained line names awaiting-verification tasks only when there are some
- [x] Step 1 says whether step 9's report runs after an empty-pool stop, and what it contains
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [x] Re-run the originating drill's brief (recorded on that task's Progress log) on a freshly built fixture with a cold runner. Expected: its "left undecided" section no longer lists these findings
  - **Passed 2026-11-05:** TASK-327's brief verbatim on a rebuilt `%LOCALAPPDATA%/Temp/d327` (one intake epic, four `findings:` tasks done or cancelled, none at verify; `fix-next`, `tasks` and `roadmap` copied after this fix). Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`. It printed `the review backlog is drained — every filed finding is closed; nothing to fix`, ran step 9 in its empty-pool form ending `4. next pick: none — the backlog has been drained`, and offered nothing; `git status` was empty. None of DRILL-327-1 or -2 is in its "left undecided" section. Coldness: it listed no skills

## Outcome

**What was fixed.** `/fix-next`'s empty-pool branch:
- Its lead-in claimed "Two causes, two different offers" over four cases. It now says "Say which case it is; each gets its own line", with no count to go stale.
- The drained line said "closed or awaiting verification" even when nothing was at `verify`. It now says "closed", and adds "or awaiting verification" with the list only when a task is there.
- An empty-pool stop now still runs step 9's report and the reset check, in a stated form: the case's line, no split, the debt, blocked tasks and unscheduled findings, and `next pick: none — <case>`.

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill, which passed.

**Judgement calls.**
- **Step 9 runs on an empty pool,** because step 1's verification-debt rule sends its lines to step 9's report. Skipping the report would drop exactly the debt this branch must surface.
- **The lead-in carries no count,** since a count of a growing list is a restated list.

**Review (close step 5b, inline).** Adherence: no restated count; the drained line's condition sits in the same sentence. Fidelity: all four criteria are met. Correctness: `--loop` still ends on an empty pool; the new paragraph only says the report runs.

**Flagged, not fixed.**
- When the drained case and DV12 both apply, DV12's offer of `/tasks intake --epic` meets the drained case's "offer nothing". Item 3 only reports the stories.
- The runner's minor readings: whether the case line prints once or also as item 1; what an empty item 3 says; whether the debt question is put at n = 0.

## Implementation plan

### Steps
1. Step 1's lead-in: "Say which case it is; each gets its own line:". It gives no count, since the list grows and a count restates it, and it no longer claims each case gets an offer.
2. The drained line says "closed" when no task is at `verify`, and "closed or awaiting verification" (listing them) when one is. The condition sits in the same sentence as the line.
3. A new paragraph says an empty-pool stop still runs step 9 and the reset check, and gives each report item's empty-pool form: the case's line; none; debt, blocked tasks and DV12 stories; `next pick: none — <case>`. Step 9's "name the next pick" and item 4 say `none` with the case. The reset check notes its second item has nothing to read when nothing was picked.
4. Spec `defect-draining` (An empty pool stops the run without inventing scope, +1 scenario). Lint, then re-run TASK-327's brief.

### Risks
- DV12's offer of `/tasks intake --epic` meets the drained case's "offer nothing that creates scope" when both apply. Item 3 only reports DV12 stories, and the conflict itself is flagged, not settled here.

## Progress log

- step 2 — picked; ranked above TASK-334 because key 1: the drained line asserts verification debt that may not exist, a plausible wrong statement in every empty-pool report, where TASK-334 is template gaps both runners resolved alike; keys 5 and 7 tie (drill-verified, P3)
- step 3 — verified: held. fix-next step 1 heads its empty-pool bullets "Two causes, two different offers:" over four bullets; the drained line's fixed text says "closed or awaiting verification" whatever the count; "Empty pool → say so and stop" sits against step 9's "Either way, name the next pick" with no rule for which applies
- step 3b — planned: /tasks plan --no-grill (three criteria); no split signal
- step 4 — layer: local
- step 5 — fix in skills/fix-next/SKILL.md (step 1 lead-in without a count; the drained line conditional on a verify task; empty-pool stop runs step 9 in a stated form; step 9's next pick and the reset check say so); lint OK (20 skills). Decision recorded: step 9 runs, because step 1's debt rule sends its lines to that report
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill
- step 7 — respecced defect-draining; requirements changed: An empty pool stops the run without inventing scope (conditional drained wording; the final report and reset check still run; +1 scenario); intended — TASK-333's criteria
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
