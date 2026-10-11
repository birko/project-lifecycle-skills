---
id: TASK-223
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
findings: [SH-11]
pr: null
github-issue: null
jira-key: null
---

# A taken task is "shown as in progress", but no index says where it is counted

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). `tasks/SKILL.md` § Collection pass says a
`todo` task whose `task/TASK-NNN` branch exists elsewhere is **taken**: "count it and show it as in progress, and
never offer it as next work". But `inProgressTasks[]` is defined as `status: in-progress` only, and the counts
bucket by the file's `status:`. So the snapshot's `in-progress` count and "In progress" list either omit a taken
task, contradicting the sentence, or include it with nothing saying how — two runs can render it differently.

## Acceptance criteria

- [x] The Collection pass states which index and which count a taken task lands in, and the snapshot and
      `triage` render it the same way (for example, listed under "In progress" with its owning branch)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- How a task becomes taken — `pick`'s own rules

## Human test plan

- [x] On an invented tree with a `todo` task whose branch exists, the bare `/tasks` snapshot shows it once, as
      the Collection pass says, and not under "Next up"
  - **Passed 2026-10-11:** on `%TEMP%\d223` (TASK-002 `todo` with `origin/task/TASK-002` pushed, TASK-004
    `in-progress`, TASK-003 `todo`), two fresh `claude -p` runs of bare `/tasks` both printed `in-progress: 2`,
    `todo: 1 (1× P2)`, TASK-002 once under "In progress" as `taken: origin/task/TASK-002`, and only TASK-003 under
    "Next up". A third run of `/tasks triage` wrote the same counts and the same marker in "In progress now" and the
    tree. The brief was the bare command. The runner holds the installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-223` — leave empty until then._

## Outcome

**The fix.** The Collection pass said to "count and show" a taken task as in progress, but its own counting rule
bucketed by the file's `status:`, which still reads `todo`. Its in-progress list took only files reading
`in-progress`. So the rule and the rest of the section disagreed. A taken task now counts in `in-progress`, not
`todo`, so it stays out of the `todo` priority line. It is listed in `inProgressTasks[]` and shown once, marked
`taken: <branch>` with the branch as found. The snapshot template and `triage`'s "In progress now" and tree markers
render that marker.

**Step 6 split, stated exactly because it is weak.** Before the fix, the two runs on the same fixture also counted
TASK-002 in progress and left it out of "Next up". The sentence alone carried the intent well enough. So the counts
and "Next up" are **contract pins, not evidence**. The one thing that differed was the rendering. The pre-fix runs
printed `← taken: origin/task/TASK-002 (file still reads todo)` and `(taken: branch origin/task/TASK-002)`, and one
sorted TASK-002 after a P2 task. The fixed runs printed the identical `taken: origin/task/TASK-002`, in priority order.
**Fix-dependent:** the single marker shape only. The fix rests mainly on the text, which had contradicted itself.

**Judgement calls.**
- *Count it in `in-progress`, not in both.* The `blocked` row may overlap other rows because it is a flag rather
  than a state. A taken task has a single state, and counting it twice would make the rows sum past the total
  with nothing explaining why.
- *Mark it rather than hide the difference.* A reader seeing `todo` in the file and `in-progress` on the
  dashboard needs the branch to tell the two apart.

**Flagged, not fixed.** Nothing new. All four drill runs also noticed that the fixture's TASK-001 was `done` with
an unticked box, which is fixture noise.

## Progress log

- step 2 — picked; ranked above TASK-228 because two runs can render a taken task differently in the snapshot and the dashboard (key 3: a plausible wrong count, nothing reports it), reached on every clone of a project with an upstream where another clone picked work (key 2), and it is fixable in one section (key 4); TASK-228 is an unstated route after a non-fix outcome that a run surfaces by stopping. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. The taken bullet says "count it and show it as in progress", but step 4 buckets by the file's `status:` (so a taken task counts in `todo` and in the `todo` priority line) and `inProgressTasks[]` holds `status: in-progress` only, so neither the snapshot's "In progress" nor triage's "In progress now" includes it
- step 4 — layer: local (`skills/tasks/SKILL.md`, `skills/tasks/verbs/triage.md`)
- step 5 — fix in `skills/tasks/SKILL.md` (Collection pass step 4: a taken task counts in `in-progress`, not `todo`; step 5: `inProgressTasks[]` includes taken tasks, each marked `taken: <branch>`; snapshot template line) and `skills/tasks/verbs/triage.md` (step 3 and the tree markers). Lint green; drill 2/2 snapshot + 1 triage on `%TEMP%\d223`
- step 6 — reverted `SKILL.md`: pre-fix 2/2 runs already counted TASK-002 in progress and kept it out of Next up, so the counts are contract pins; the renderings differed (two marker shapes, one out of priority order) where fixed runs printed one. Fix-dependent = marker shape only
- step 7 — respecced work-tracking ("Taken tasks derived from branches": counted in `in-progress`, listed once marked `taken: <branch>`, same in snapshot and dashboard; scenario "A taken task is counted once, as in progress"); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
