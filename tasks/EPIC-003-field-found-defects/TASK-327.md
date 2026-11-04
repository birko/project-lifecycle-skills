---
id: TASK-327
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-298-1]
pr: null
github-issue: null
jira-key: null
---

# `/fix-next`'s empty-pool messages have no case for a backlog that has been fully drained

## Context

Found by TASK-298's cold drill (2026-10-14). Both runners reached an empty pool after the only task was cancelled. `skills/fix-next/SKILL.md` step 1 names two causes of an empty pool and an offer for each: *"No review has been filed"* and *"A review backlog exists but predates the stamp"*, plus a third, every pool task blocked. A review that was filed, stamped and fully worked off fits none of them. The runner said so: *"A review was filed and is now fully drained, so neither of step 1's 'empty pool' messages fits exactly."* So the run either invents a message, or picks one that tells the user to run a review or adopt an epic that is already stamped.

## Acceptance criteria

- [x] Step 1 names the drained case (`kind: review-intake` epics exist, and no task in the pool is `todo` or blocked) with its own line, and offers nothing that would create scope
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The other three empty-pool causes, which are correct as written

## Human test plan

- [x] On a fixture whose only review-intake epic has every task `done` or `cancelled`, run `/fix-next`. Expected: the run reports the backlog as drained and offers no review, adoption or intake.
  - **Passed 2026-11-04:** the runner printed the drained line and offered nothing, quoting "Offer nothing that creates scope".

## Outcome

**What was fixed.** `/fix-next` step 1 named three causes of an empty pool, each with its own message: no review filed, a backlog that predates the `kind: review-intake` stamp, and every task blocked. A review that was filed, stamped and fully worked off fits none of them, so a run reaching that state either invented a message or told the user to run a review or adopt an epic that was already stamped. Step 1 now names the drained case: defect work is filed, but none of it is `todo` or blocked. It has its own line, lists any task awaiting verification, and offers nothing that creates scope.

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills): a contract pin, not evidence. The Human test plan's fixture run is the evidence and has not been run.

**Judgement calls.**
- **Drained includes tasks awaiting verification.** A `verify` task is not in the pool, so a backlog whose last fixes await sign-off is drained from this skill's side. Listing those tasks keeps the remaining human work visible instead of letting "drained" read as "finished".
- **The condition is read off declared fields** (the stamp or `findings:`), like the pool itself, never off an epic's title.

**Respec.** `defect-draining`, requirement *An empty pool stops the run without inventing scope*: states the drained case, plus one scenario. The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-323 because a drained backlog is reached by every drain that finishes its job and currently gets a message offering to create scope (keys 2, 3), while TASK-323 still carries an undecided ordering question (key 4); key 6 inert — both sit under EPIC-003 with no theme
- step 3 — verified: held. skills/fix-next/SKILL.md step 1 lists "no review has been filed", "predates the stamp" and "every task blocked"; a stamped backlog whose tasks are all done or cancelled matches none, and the first two offers would create scope or re-stamp an epic already stamped
- step 4 — layer: local (skills/fix-next/SKILL.md)
- step 5 — fix in skills/fix-next/SKILL.md (step 1, empty-pool causes); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan fixture run, not run
- step 7 — respecced defect-draining; requirements changed: An empty pool stops the run without inventing scope (+1 scenario); intended anyway — TASK-327's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
- 2026-11-04 — **Human test plan — cold drill, passed.** Fixture: `repo/` with one `kind: review-intake` epic, two stories and four `findings:` tasks, three done and one cancelled; skills `fix-next`, `tasks`, `roadmap`. Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, cwd `%LOCALAPPDATA%\Temp\d327`, which holds the committed fixture `repo/` and copies of the named skill folders under `skill/`. The brief told the runner it was a drill, barred history and planning docs, told it to write any question verbatim and continue unanswered, and asked for: the output, the questions, what was left undecided, what was settled, what was inferred, what it read unsent, and its skill list. It never stated an expected outcome. Task-specific ask: "Run /fix-next. Give its closing report verbatim, including every offer it makes." **Coldness:** it listed no skills. **Result:** the runner printed the drained line and offered nothing, quoting "Offer nothing that creates scope". Also raised, outside this task and offered as follow-ups: **DRILL-327-1:** step 1 says "Two causes, two different offers" above four bullets, and the drained line's fixed text says "or awaiting verification" when nothing is; **DRILL-327-2:** "say so and stop" leaves open whether step 9's report, which says "Either way, name the next pick", still runs. → `verify` → **done**.
