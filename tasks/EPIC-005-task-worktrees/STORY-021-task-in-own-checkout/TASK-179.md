---
id: TASK-179
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: in-progress
priority: P1
assignee: human
created: 2026-09-24
depends-on: [TASK-175, TASK-176, TASK-177, TASK-181]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# End-to-end drill: pick → work → close in a worktree on a real consumer

## Context

FEATURE-001 D1 treats the worktree as a first-class workspace. The per-task human test plans exercise
each verb; this drill runs the whole loop once, cold, on a real `pr-per-task` project — which this repo
is not (it declares `integration: single-branch`, so the path is unreachable here).

Obtain the runner per `skills/populate-tests/SKILL.md` § *Acquiring a cold runner* — a subagent is never
cold in this environment, because these skills are installed at user level — and record the command,
working directory and coldness check (AGENTS.md § Testing).

## Acceptance criteria

- [ ] Drill run and recorded on this task: runner, cwd, coldness check, brief, outcome.
- [ ] One run covers: undeclared root → question asked; worktree created outside the repo; move proved; a second task picked while the first is open (the parallelism D1 claims); close merges, removes, deletes; main copy on the default branch throughout.
- [ ] Every defect found is filed as its own task (`/tasks spawn`), not fixed inside this one.

## Out of scope

- Fixing what the drill finds.

## Human test plan

- [ ] Brief (withholding expected outcomes): "On <consumer>, declare `workspace: worktree`, pick task A, make a small change and commit it, pick task B, close task A." Expected, kept here and not in the brief: A gets its own folder outside the repo; B gets another; closing A merges it into the default branch in the main copy and removes A's folder and branch; B's worktree is untouched.

## Implementation plan

_Populated by `/tasks plan TASK-179` — leave empty until then._

**Trial run (2026-09-24), in the main interactive Claude Code session — not a cold runner.** A `-p` runner can
neither approve `EnterWorktree` nor move, so this path has no cold channel (see TASK-174's drill record).
The author ran it, and the stakeholder answered the one question `pick` asks.

**Target:** a clone of the real consumer **Presenter** (real history, real task tree, `integration: pr-per-task`),
placed in this repo's gitignored `scratch/trial179/` so it is a repo nested inside the session's launch
directory, which is where `EnterWorktree` accepts a worktree from. Its `origin` was removed so `main` tracks no
remote (D23). The real Presenter was not touched; its main copy sits on someone's `task/TASK-006`.
**Setup by hand:** `workspace: worktree` declared, root left undeclared, and two throwaway tasks, TASK-012 and TASK-013.

| # | Step | Outcome (read from git) |
|---|---|---|
| 1 | `pick TASK-012` | the root question was put to the stakeholder **verbatim**. They asked whether they could choose the folder name, were told any path works and only the per-task folder name is fixed (D13), and answered `../wt`. The answer was held through all five checks, then committed inside `TASK-012: pick` (exactly `.config.yml`, the task file, `tasks/README.md`). The worktree was created at `scratch/trial179/wt/Presenter-TASK-012` |
| 2 | enter + prove | `EnterWorktree path=` succeeded; a separate `--show-toplevel` returned the worktree in **Bash and PowerShell**; branch `task/TASK-012` |
| 3 | work | committed in the worktree; main copy untouched |
| 4 | `pick TASK-013` **while TASK-012 was open** | from the main copy, which read TASK-012 as `in-progress` (D17 holds). No question this time (root now declared). The second worktree was created, entered and proved |
| 5 | switch B → A directly | **refused by the tool** outside `.claude/worktrees/`, as its contract says. The fix is exit to the main copy, then enter A |
| 6 | `close TASK-012` as then written | step 4b detected the worktree correctly, then **`git -C <main copy> status` was refused**: Claude Code's worktree isolation blocks every reach into the main copy, reads included. **D7 could not run in the one runtime where pick really enters a worktree** → D7/D8 **changed** (stakeholder decision): leave first, then merge in the main copy |
| 7 | `close TASK-012`, revised text | `done` committed in the worktree → `ExitWorktree keep` → leave proved in both shells → main checked clean → `merge --no-ff --no-commit` with `pr: fd66ec6` written inside the merge — **clean over TASK-013's pick commit**, which had landed on `main` in between → worktree removed → branch deleted → `chore: dashboard and rollups after TASK-012` committed alone; TASK-013's worktree untouched |
| 8 | `close TASK-013` with an untracked `stray-notes.txt` left in its worktree | merged (`done`, `pr: 1ab56d7`), then removal **refused, not forced**, the dirty path named, the registration intact (not partial) and the branch kept. The outstanding commands worked once the human dealt with the file |

**End state:** `main` holds both merges and both refresh commits; worktree list = main copy only; branch list = `main`; clean throughout.

**After the trial (2026-09-24).** A correctness review of the D7/D8 change found:
- Re-closing an unmerged close **from the main copy** could not reach the merge. Step 4b, step 4 and step 8's skip-line all stopped it.
- A parked close still reached the main copy from inside an isolated session.
- The 4b skip covered more than isolation blocks.
- An isolated session that left in only one shell was misclassified.
- The resume check did not say how to read the file.

All five were fixed, and D18 became `changed` too, because only the **clean** check moves after leaving. The first finding was then run **live** in the trial clone: TASK-014 was left with `done` on its branch and unmerged, and was closed **from the main copy**. `git show` read both copies. 4b's resume row sent it to step 8.2, and it merged cleanly with `pr: fb8d239`, removed the worktree, deleted the branch, and left main clean. The other four are text-only fixes and were not re-reviewed by a separate pass.

**pi runtime:** not run. `pi -p` ran 10 minutes silent on the pick brief, and answers even a one-word prompt with `404 {"detail":"Not Found"}` from its model provider. It is misconfigured on this machine, outside this repo.

**Status: stays `in-progress`.** Every acceptance criterion above is met by the trial. But this task also depends on TASK-177 (the setup tools) and TASK-181 (resuming a task in a new session). Its end-to-end run should cover both once they land, and neither exists yet.
