---
id: TASK-313
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-WT-1]
pr: null
github-issue: null
jira-key: null
---

# A new task under an open story whose epic is cancelled leaves open work under the cancelled epic, unreported

## Context

Raised by the spec harvest of work-tracking (`/specs regen`, 2026-10-13). `skills/tasks/verbs/new.md` step 10 checks the epic above a parent story and says a `cancelled` one "asks first, as step 4 does". Step 4's question and its answer-less path ("file under the nearest ancestor that is not cancelled") are written for a cancelled **parent**. Here the parent story is open, so the item lands in it, and with no answer the cancelled epic is left over open work with nothing defining the outcome or reporting it.

## Acceptance criteria

- [x] Step 10 states the question for a cancelled epic above an open parent story, verbatim
- [x] It states the answer-less outcome, and that outcome is reported, never silent
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- A cancelled direct parent (TASK-308 covers it)

## Human test plan

- [x] A cold runner files a task in an open story under a cancelled epic with nobody to answer. Expected: it quotes the question and reports what it left, and the epic is not silently left `cancelled` over open work without a report.
  Passed 2026-10-14: fixture `%TEMP%\d313`, cancelled EPIC-002 over `in-progress` STORY-002, `/tasks new task` under STORY-002 with nobody to answer. The runner quoted step 10's question word for word, left EPIC-002 `cancelled`, filed TASK-003 in STORY-002, and printed `EPIC-002 is cancelled over open work — TASK-003 filed under STORY-002; nothing chose to reopen it.` Runner: cold `claude -p --disable-slash-commands` in the fixture dir, skills granted by `--add-dir` on `~/.claude/skills` and `skills/`; probe listed no skills or slash commands.

## Outcome

**The fix.** `skills/tasks/verbs/new.md` step 10 now carries its own question for a cancelled epic above an open
parent story ("EPIC-NNN … is cancelled (won't-do), and <new id> goes into STORY-NNN, an open story under it.
Reopen EPIC-NNN?"), with two answers, and an answer-less path: do not reopen, still file the item in its story,
and report `EPIC-NNN is cancelled over open work — <new id> filed under STORY-NNN; nothing chose to reopen it …`.
It used to say "asks first, as step 4 does", but step 4's question and fallback are about a cancelled *parent*,
which does not fit here. Spec `work-tracking` respecced (requirement text + one scenario).

**Step-6 split: 0/0.** No automated test reads verb prose. The lint run (OK, 20 skills) is a contract pin, not
evidence. The guard is the human test plan's cold drill, not run, so the task parks at `verify`.

**Judgement calls.**
- *File the item in its story either way; ask only about the epic.* Rejected: reusing step 4's "file under the
  nearest ancestor that is not cancelled". The story is open and owns the work. Moving the item out because of
  the epic would lose its placement to resolve a question about a different container.
- *No reopen command in the report.* Rejected: naming `/tasks move STORY-NNN --to EPIC-NNN`. That moves a story
  into the epic it is already in, which `move` does not define, and no verb reopens an epic directly. The report
  says the cancel is a person's call and names `/tasks move <new id>` for re-homing the task, which is defined.

**Flagged, not fixed.** No verb reopens a cancelled container on its own; the only ways are side effects of
`move` and `new`. Existing gap, not created here; TASK-314 already owns the related SKILL.md/new.md mismatch,
so nothing new was filed.

**Close review (2026-10-14, `verify → done`).** All three passes reported pass with notes. Two gaps in this change were fixed in this close: step 13's confirmation now has a slot for the cancelled-epic report line, which a run following step 13 could otherwise drop; and the line's reason no longer claims `audit` flags the contradiction, which audit.md's `contradiction` row does not cover. The drill also found that `plan.md`'s grill question has no answer-less path; that went to TASK-318.

## Implementation plan

_Populated by `/tasks plan TASK-313` — leave empty until then._

## Progress log

- step 2 — picked; ranked above TASK-298 because key 3 (silence): the cancelled epic over open work is left unreported, while TASK-298's run stops and names every uncommitted file. Key 4 also favours it (one paragraph in one verb; TASK-298 carries an open design question about where the record goes). Key 6 inert: TASK-313 is parented straight to EPIC-003, so it declares no theme
- step 3 — verified: held. `skills/tasks/verbs/new.md` step 10, third bullet: "A `cancelled` one asks first, as step 4 does." Step 4's question names a cancelled *candidate parent* and its answer-less path files elsewhere; neither applies when the story is the open parent and only the epic above it is cancelled, so the run has no question text and no answer-less outcome
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/new.md step 10; no automated test applies — prose verb; lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed; fix-dependent = none; contract pins = skills-lint.sh run; evidence is the human test plan's cold drill, not run
- step 7 — respecced work-tracking; requirements changed: "New work under a closed container" (+ scenario for an open story under a cancelled epic)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
