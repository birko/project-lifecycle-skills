---
id: TASK-309
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
findings: [DRILL-308-1]
pr: null
github-issue: null
jira-key: null
---

# `/tasks new`'s title, parent, priority and draft questions carry no question text and no answer-less path

## Context

Found by TASK-308's cold drill (2026-10-13). The runner, told nobody would answer, reported that
`skills/tasks/verbs/new.md` step 3 (*Ask the title*), step 4 (*Ask for parent*), step 5 (*Ask priority
and assignee*) and step 9 (*offer to draft body sections*) each describe a question without stating
it, and none says what the run does with no answer. It invented the wording and chose for itself each
time. That breaks AGENTS.md § Output/prose rules, *An ask-step carries the question it puts and the
answer-less path*. Step 4's new cancelled-parent question (TASK-308) already has both; the rest of the
step does not.

Unattended callers reach these steps: `spawn` from `close --unattended` step 5d, and `intake`.

## Acceptance criteria

- [x] Steps 2, 3, 4, 5 and 9 each state the exact question put (step 2 added at pick, before any work: it
      asks for the level when none is passed, and has the same gap)
- [x] Each states its answer-less outcome, and where the field must exist (title, parent, priority) a
      fallback written **with a record that nothing chose it**, per the convention's two shapes
- [x] A step already pre-filled by a caller (`spawn`'s defaults, `--from-feature`, `intake`) says it
      asks nothing
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Ask-steps in other verbs (each is its own finding if a drill raises it)
- The cancelled-parent question (TASK-308)
- Step 8's `affects:` question, and surfacing the mark — TASK-310 (CR-309-1, CR-309-2)

## Human test plan

- [x] A cold runner files a task with nobody to answer. Expected: it quotes each question verbatim
      from `new.md`, and the report names every value that was defaulted rather than chosen.
  - **Passed 2026-10-13:** all five questions (steps 2, 3, 4, 5, 9) quoted word for word from `new.md`;
    TASK-004 written with `> Filed with nobody to answer — inferred, not chosen: level, title, parent,
    priority, assignee, body sections.` and the report repeats it.

## Implementation plan

Drafted inline at pick; the design was settled while closing TASK-308.

**One recording shape for every unattended fallback.** These fields must exist (level, title, parent,
priority, assignee), so the convention's write-and-mark shape applies, never leave-absent. The mark is one
line under the new file's heading, written only when something was inferred:
`> Filed with nobody to answer — inferred, not chosen: <fields>.` Step 13 repeats it. A value a caller
passed (`spawn`'s parent and priority, `--from-feature`, `intake`) is the caller's choice, not an inference,
so it asks nothing and is not marked.

1. Step 2: the question (epic / story / task); unanswered, apply the decision test, mark `level`.
2. Step 3: the question; unanswered, a short noun phrase from the request, mark `title`.
3. Step 4: the parent question, listing step 4's table; unanswered, the candidate that owns the subject,
   else for a task `_loose/` (a finding gets its `FIELD-NNN`, as the cancelled path already says), for a
   story not created. Mark `parent`.
4. Step 5: the question; unanswered, P1 and `ai`, mark `priority, assignee`.
5. Step 9: the question; unanswered, draft when the request supports it and mark `body sections`, else
   leave the placeholders and report them unfilled.
6. Step 13: report the mark line. `close.md`'s `--unattended` table: generalise TASK-308's 5d row to
   new.md's questions.
7. Lint.

## Outcome

**The fix.** `new.md` steps 2, 3, 4, 5 and 9 each put a stated question and say what happens with no
answer. A field that must exist takes the step's fallback and is named in one mark line under the new
file's heading (§ *Unanswered questions*), and step 13 repeats it. A story no epic owns is not created.
A field a calling verb sets is never asked for or marked; `spawn` now puts its own confirmation question,
and with no answer its defaults stand unmarked. An inferred placement that reopens a `done` container says
so on that container's `> Reopened` line. `close`'s `--unattended` table names both questions.

**Drill.** The TASK-308 fixture (`%TEMP%/d308`) reset to its initial commit, same runner command
(`claude -p --disable-slash-commands … --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills`,
brief on stdin, cwd the fixture). The brief gave a vague request ("the PDF footer shows last month's
date"), said nobody would answer, and asked the runner to quote each question and say where its wording
came from. It did not mention the mark or any step. **Coldness check:** the runner listed no skills. It
filed TASK-004 under EPIC-002 Reporting. The drill ran before the review fixes below, which add only the
caller exemptions and spawn's question; the unattended path it exercised is unchanged.

**Review passes.**
- Correctness: 7 findings. Fixed: batch callers' defaults would have been marked, spawn's confirm step
  was lost, an inferred parent's reopen read as decided, step 9 would have offered sections a flag already
  drafts, the close row misnamed spawn's fields, and the scope sentence was incomplete. Spawned as
  TASK-310: step 8's `affects:` ask (my fix was reverted as outside the criteria) and the mark being
  write-only.
- Standards: 3 warnings and 1 suggestion, all fixed: spawn's confirmation had no question text, the
  batch-caller sentence named a statement no caller makes, and the close row and the section's step range
  restated lists.
- Fidelity: criterion 3 was wrong as first built (spawn still confirmed inside `new`); fixed by moving the
  confirmation to spawn, so `new`'s steps ask nothing for a set field. Two scope-creep notes: the
  `affects:` change was reverted to TASK-310. The inferred-reopen note stays as part of criterion 2:
  without it, an answer-less placement writes a `> Reopened` line that reads as decided.
- Security, comments: not applicable.
