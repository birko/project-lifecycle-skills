---
id: TASK-308
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# A new task filed under a `done` story or epic goes there and reopens it, instead of going to `_loose/`

## Context

Field report (2026-10-13, consumer repo): an agent filing a task said *"Filing this as TASK-588 under
tasks/_loose/ since EPIC-009 is already complete."* The work belonged to EPIC-009. The user's ruling:
**reopen** the epic.

Cause: `skills/tasks/SKILL.md` § *Roll status up to parents* lists three triggers for reopening a `done`
container: a child parked `done → verify`, a child reopened by `close`, and an open task moved in by
`move`. It does not list a task **created** under the container (`new`, `spawn`, `intake`). With no rule
saying a `done` parent may take a new child, the agent treated `done` as closed to new work and dropped the
task into `_loose/`. That loses its placement, and a loose task is unranked
(§ *A task outside a pool*). The same section already says epics and stories are open-ended areas that gain
work over time, so the right placement is the parent, and the roll-up rule reopens it.

## Acceptance criteria

- [x] § *Roll status up to parents*'s reopen direction lists a new open child created under the container
      (by `new`, `spawn` or `intake`) as a trigger, with the same dated `> Reopened` line and report
- [x] `new.md` step 4 lists `done` epics and stories as parent candidates, marked so, and says that
      choosing one reopens it. `spawn.md`'s placement does the same, or points at it
- [x] A parent's `done` status is named as **not** a reason to file a task in `_loose/`
- [x] Where a parent is `cancelled`, the behaviour is stated (reopen by the same rule, or ask)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Reopening a signed-off **feature** (already covered by `spawn.md` § Edge cases and `/feature pick`)
- `new.md`'s other questions (title, parent, priority, draft) have no question text or answer-less path — TASK-309 (DRILL-308-1)

## Human test plan

- [x] On a fixture with a `done` epic whose area clearly owns the new work, ask a cold runner to file a
      task for that work. Expected: the task lands under the epic, the epic reads `in-progress` with a
      dated `> Reopened` line, and the run reports it. It does not land in `_loose/`.
  - **Passed 2026-10-13:** filed TASK-004 under the `done` STORY-001; STORY-001 and EPIC-001 both went to
    `in-progress` with `> Reopened 2026-10-13 — …` lines, reported in the run's summary; nothing in `_loose/`.

## Implementation plan

⚠ Acceptance criteria question: AC1 says "a new open child", while AC2 names only step 4's **task**
branch. A `/tasks new story` under a `done` epic is the same defect one level up. The plan treats both
branches alike.

**Cancelled parent: ask; unanswered, don't reopen.** `move` reopens a cancelled container because the
user named the target. At creation the parent is often inferred (spawn inherits it), and a cancel is a
recorded won't-do, so reopening one on an inference overrides a decision nobody revisited. A `done`
container has no decision behind it — its status is derived from its children.

1. `skills/tasks/SKILL.md` § *Roll status up to parents*, reopen bullet: add creation by `new`/`spawn`/
   `intake` as a trigger; say a `done` parent is never a reason to file elsewhere; say a `cancelled` one
   asks first at creation (new.md step 4). Generalise `TASK-NNN` to the child's id.
2. `skills/tasks/verbs/new.md` step 4: a table keyed on candidate status (open / `done` / `cancelled`)
   for both the story and task branches, with the cancelled question and its answer-less path; one line
   that `done` is not a reason to pick `none`.
3. new.md step 10: reopen the parent in the same change as the write; step 13 reports it.
4. new.md § Edge cases: one line pointing at step 4.
5. `skills/tasks/verbs/spawn.md` step 4 parent default and § Edge cases *No origin task*: a `done`
   parent is still the parent.
6. `skills/tasks/verbs/intake.md` § Edge cases: repoint the re-open sentence from § *Lifecycle* to
   § *Roll status up to parents* (small, outside the ACs strictly; named in the commit).
7. `skills/feature/verbs/decompose.md`: no edit, it chains `/tasks new`; confirm its wording doesn't
   exclude `done` parents.
8. Lint.

## Outcome

**The fix.** Creating an open child under a `done` story or epic now files it there and reopens the
container (`SKILL.md` § *Roll status up to parents*; `new.md` steps 4, 10, 13). A `cancelled` parent asks
first; unanswered, the cancel stands and the item goes to the nearest ancestor that is not cancelled.
`spawn.md` keeps a `done` parent as its default, `intake.md` points at the rule.

**Drill.** Fixture `%TEMP%/d308`: a git repo, `mode: local`, `integration: single-branch`, EPIC-001
*Authentication* `done` over STORY-001 *Password login* `done` (TASK-001, TASK-002 `done`), and EPIC-002
*Reporting* `in-progress`. Runner, from that directory:
`claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" --add-dir
~/.claude/skills C:/Source/project-lifecycle-skills`, brief on stdin. The brief named the skill's path and
the bug ("password reset email sent twice"), said nobody would answer, and did not mention done parents,
reopening or `_loose/`. **Coldness check:** asked to list its skills first, the runner reported none.
Granting the repo directory costs coldness about this repo's prose, which is acceptable for a behaviour
drill. The drill ran before the correctness fixes below; they leave the drilled path (an open task
under a `done` story) unchanged, so it was not re-run.

**Review passes.**
- Standards (verify-conventions): pass, no findings.
- Fidelity (verify-intent): pass; all five criteria met, nothing unasked-for.
- Correctness: 5 findings, all fixed: step 10 reopened even for a closed new child (`import` of a closed
  issue); a `done` epic over a `planned` story was not re-checked; the cancelled question was reachable
  under `close --unattended` but absent from its contract table and from `fix-next`'s loop list; a story
  under a cancelled epic had no executable fallback, and a loose finding had no id step; `SKILL.md`
  restated a list of creator verbs.
- Security, comments: not applicable (Markdown prose, no comment in range).

**Judgement calls.**
- *Cancelled asks, `done` does not.* A cancel is a recorded decision and a creation-time parent is often
  inferred; a `done` status is derived from the children, so nothing is overridden.
- *Story creation included.* The criteria named the task branch; a story under a `done` epic is the same
  defect one level up.

**Spec.** `docs/specs/work-tracking.md`'s reopen scenario now covers less than the skill does; a scoped
`/specs regen` at the next story close picks it up.
