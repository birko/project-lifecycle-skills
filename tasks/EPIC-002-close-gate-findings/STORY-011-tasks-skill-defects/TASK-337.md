---
id: TASK-337
parent: STORY-011
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
findings: [DRILL-182-1, DRILL-182-2, DRILL-182-3]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/tasks pick` on a bare id leaves debt surfacing and plan age unclear, and 9b's offer says "1 steps"

## Context

Found by TASK-182's two-runner drill (2026-11-04, recorded on TASK-182). Both runners raised all three, in `skills/tasks/verbs/pick.md`:

- **DRILL-182-1:** step 2 says a bare id jumps "to step 5 — after step 3's taken check". Read literally, that skips step 2b's verification-debt surfacing, yet 9b's contract table lists 2b among the asks that came before.
- **DRILL-182-2:** step 6 says to note a plan's age and flag one that predates changes to the code it references. A plan carries no date, and nothing says where its date comes from, or what to do when the paths it names do not exist.
- **DRILL-182-3:** 9b's offer template renders "Ends at verify: 1 manual test steps".

## Acceptance criteria

- [x] Step 2 says whether 2b runs on a bare-id pick
- [x] Step 6 names the source of a plan's date and the reading when its referenced paths are absent
- [x] 9b's offer reads correctly for one step
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [x] Re-run TASK-182's drill brief (on its Progress log) with one cold runner. Expected: none of the three appears in its "left undecided" section
  - **Passed 2026-11-05 (second run):** TASK-182's brief verbatim on a rebuilt `%LOCALAPPDATA%/Temp/d182c` (`pr-per-task`, no `workspace:`, TASK-001 todo with a committed plan naming two never-existing paths, TASK-002 at `verify`; `tasks` copied after the amended fix). Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`. The bare-id pick printed `⚠ 1 in review awaiting sign-off: TASK-002` first, worked out the plan's line range itself, printed nothing about the age (correctly: nothing changed), and the offer read `Ends at verify: 1 manual test step.` None of the three is in its "left undecided" section. The first run (`d182c-run1`) failed on the plan-age command; see the Progress log. Coldness: neither run listed skills

## Outcome

**What was fixed.** Three gaps in `/tasks pick`:
- A task picked by id now gets the same verification-debt line as one picked from the list, after the taken check.
- A plan's age now has a source, recomputed each run: the last commit that changed the plan section, found with `git log -L` over a line range read from `HEAD`'s copy. There is a stated reading for no git, an uncommitted plan, and paths that are missing (deleted or renamed counts, never-existed does not).
- The subagent offer and the `parked:` line read correctly for one step.

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill. It failed on its first run, on this task's own new command, and passed on the second after the fix.

**Judgement calls.**
- **The regex range was replaced by a computed line range.** The plan agent proposed `-L '/^## Implementation plan/,/^## /'` on the claim that a section always follows the plan. It does not: the template ends with the plan, so the regex fails with "No match" on most task files. The first drill run caught it, and the line-range form was checked on a plan-last file here before the second run.
- **A path the plan names that never existed is "to be created", not stale.** Only a deletion or rename in the diff shows the plan went out of date.
- **The `parked:` line's plural was folded in.** It is the same defect, in the same verb, with the same wording.

**Review (close step 5b, inline).** Adherence: the age is a derived state and is not cached; no new ask-step. Fidelity: all four criteria are met. Correctness: the failed command was found and fixed before close.

**Flagged, not fixed** (the second runner's other readings, outside this task):
- 2b's template says "in review" for a task at `verify`.
- How to find the default branch with no remote is unstated.
- Step 7 lists the status edit before the branch cut, so the edit rides onto the branch uncommitted.

## Implementation plan

### Step 1 — a bare-id pick runs 2b
- Step 2's bare-id route becomes: after step 3's taken check, then step 2b. The taken check comes first because a refusal writes nothing. Naming a task skips the list, not the rule that debt comes before new scope. The named task is not counted in its own debt. 9b's contract row is then true as written.

### Step 2 — the plan's age has a source
- The age is recomputed every run and never recorded (a derived state).
- Three cases: no git → `plan age not checked — no git history`; uncommitted plan → newer than every commit, not flagged; committed → the first line of `git log -1 -s --format='%H %cs' -L '/^## Implementation plan/,/^## /:<task file>'`.
- Changed paths: `git diff --name-status <plan sha> HEAD` or `git status --porcelain` on the paths the plan names. A path absent now counts only as `(deleted)` or `(renamed → …)`; one that never existed is to be created, not stale. The existing question and its no-answer line are unchanged.

### Step 3 — the 9b offer reads for one step
- `1 manual test step` / `N manual test steps`. The report line `parked: verify — <n> manual steps` has the same defect and is folded in (same verb, same wording).

### Step 4 — spec and lint
- `work-tracking` § *Picking a task*: the debt clause and the plan-age sentence, plus two scenarios. Lint; then re-run TASK-182's brief.

### Risks
- `-L`'s range needs a section after the plan. The template provides one.
- Treating a never-existing path as "to be created" is a judgement; only a deletion or rename shows a plan is stale.

## Progress log

- step 2 — picked; ranked above TASK-338 because keys 1, 3, 5 and 6 tie (silent wrong readings, drill-verified, correctness-invariants) and key 5 leans here: two independent cold runners agreed on all three gaps, where TASK-338 rests on one runner plus the author's reading; key 7 ties (P3)
- step 3 — verified: held. pick.md:26 sends a bare id to step 5 after step 3's taken check, passing over 2b (which 9b's contract table counts among the asks put before the offer); step 6 dates a plan with no stated source and has no reading for paths that do not exist; 9b's offer template renders "1 manual test steps"
- step 3b — planned: /tasks plan --no-grill (four criteria); no split signal (the `parked:` line's plural folded in as the same defect in the same verb)
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/pick.md (bare id runs 2b after the taken check; plan age recomputed from `git log -L` with no-git, uncommitted and missing-path readings; 9b offer and `parked:` line read for one step); `git log -L` checked on two committed task files here (returns the commit that wrote each plan); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill
- step 7 — respecced work-tracking; requirements changed: Picking a task (debt on a bare-id pick; plan age source and path readings; +2 scenarios); intended — TASK-337's criteria
- step 5 (amended after the first drill run) — the first re-run of TASK-182's brief (fixture d182c-run1) showed the debt line on a bare-id pick and the one-step wording working, but the plan-age command failed: `-L '/^## Implementation plan/,/^## /'` returns "No match" when the plan is the last section, which the template makes the usual case (the plan's claim that `## Progress log` follows was wrong; only fix-next adds it). Replaced with a line range computed from HEAD's copy, ending at the next `## ` heading or the file's last line, and checked on TASK-330 (plan last), which returned 5ea5dd3. The runner also could not tell "deleted" from "never existed" when the plan's commit is HEAD, so that sentence now reads "not shown deleted or renamed by the diff", and the not-stale case prints nothing. Lint OK; drill re-run on a rebuilt fixture
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
