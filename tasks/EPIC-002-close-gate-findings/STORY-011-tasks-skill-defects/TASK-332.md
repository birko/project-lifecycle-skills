---
id: TASK-332
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
findings: [DRILL-212-1, DRILL-212-2]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/tasks block` leaves where its two writes go, and their order, to the reader

## Context

Found by TASK-212's cold drill (2026-11-04, recorded on TASK-212), in `skills/tasks/verbs/block.md`:

- **DRILL-212-1:** `blocked:` goes "after the `status:` line and every indented `#` line continuing its comment". But the template's next line is the unindented `# blocked: <reason> — set by /tasks block …` comment, so above or below it reads both ways. "Append a body note" names no place; the runner put it after `## Implementation plan`, where it reads as part of the plan.
- **DRILL-212-2:** step 4 writes `blocked: <reason>`, but step 5 is where the reason is settled when `--reason` is absent.

## Acceptance criteria

- [x] `block` states where `blocked:` goes relative to the template's `# blocked:` comment line
- [x] It states where in the body the `> Blocked …` note goes
- [x] The reason is settled before the step that writes it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed
- Six further readings this task's drill raised (one runner) in `block`'s confirmation and the dashboard it chains — TASK-348

## Human test plan

- [x] Re-run the originating drill's brief (recorded on that task's Progress log) on a freshly built fixture with a cold runner. Expected: its "left undecided" section no longer lists these findings
  - **Passed 2026-11-12:** fresh fixture `%LOCALAPPDATA%/Temp/d332`, a clone of TASK-212's committed fixture (`d212/repo`, commit `6ac3843 fixture`, origin removed; `d212` itself left untouched). `skill/tasks` copied from this fix, and TASK-212's `brief.txt` used unchanged. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, cwd the fixture root. It put the reason question verbatim, then wrote `blocked: reason unknown` **directly below the template's `# blocked:` comment line** and the note `> Blocked 2026-11-12 — reason unknown; nobody gave one when it was blocked.` **directly under `# Add CSV format to export`**, with `status: todo` unchanged. It listed both placements under "settled for me", and neither DRILL-212-1 nor -2 appears among its undecided points. Coldness: it listed no skills (only agent types). Six further readings, one runner, → TASK-348

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). All in `skills/tasks/verbs/block.md`.

1. **DRILL-212-2** — lift the no-`--reason` branch out of step 5 into a new step 3b, *Settle the reason*, ahead of
   step 4's write. Step 4 and step 5 then both write "the reason step 3b settled". Move the already-blocked stop from
   step 4 into step 3, or a run without `--reason` asks why before discovering it is already blocked.
2. **DRILL-212-1, field** — `blocked:` goes directly below the template's own `# blocked:` comment line when present;
   otherwise after `status:` and its indented continuation lines, as now.
3. **DRILL-212-1, note** — the `> Blocked …` note goes directly under the task's `# Heading`, above any earlier note:
   outside every `##` section, newest first. Readers find the note by date, so its position changes no reading.
   Place unblock's note the same way, so the two never land in different places.
4. Respec `work-tracking` § *Blocking and unblocking*.

## Outcome

**The fix.** `/tasks block` left three things to the reader, all in `skills/tasks/verbs/block.md`:
- **Field placement:** where the `blocked:` line goes relative to the task template's own `# blocked:` comment.
- **Note placement:** where the `> Blocked …` body note goes. A runner put it after the plan, where it reads as part of
  the plan.
- **Order:** step 4 wrote `blocked: <reason>` before step 5 worked out the reason when `--reason` was missing.

Now:
- **Reason first:** a new step 3b settles the reason before anything is written.
- **Field:** it goes directly below the template comment.
- **Note:** it goes directly under the task's `# Heading`, newest first. Unblock's note is placed the same way.

**Step 6 split.** 3 of 3 assertions failed on HEAD's `block.md` and pass on the fix. All three are fix-dependent: the
reason question precedes step 4's write, the field placement names the template comment, and the note placement names
the heading. Contract pin, **not evidence**: skills-lint passes on both. The evidence for the readings is the drill.

**Judgement calls.**
- **The already-blocked stop moved from step 4 to step 3.** It was not one of the findings. But with the reason now
  settled at 3b, leaving the check at 4 would have a run without `--reason` ask *why* a task is blocked before finding
  out it already is. Same root cause (checks and writes ordered after the reason), so folded in rather than spawned.
- **Note under the heading, not at the end of the file.** The end of the file is where existing notes sit (TASK-124's
  is there) and is what "append" meant. But it is exactly where the drill runner's note landed inside the plan. The
  readers find the note by date, not position (init step 3b, export, fix-next), so moving new notes changes no reading,
  and existing files need no migration.
- **Unblock's note placed the same way**, though only `block` was in the findings. Two notes one verb pair writes, in
  two different places, is the same ambiguity one step over.
- **Field below the template comment**, rather than between `status:` and it. The comment documents the field, as the
  `# status` comment above `status:` does. The other reading splits a comment from what it describes.
- **Fresh fixture by cloning**, not by resetting `d212`, because resetting would destroy that drill's evidence (AGENTS.md
  § *Never force, prune or delete what this run did not create*).
- **Close gate ran inline** on a ~30-line prose diff.
  - Standards: no finding. The ask-step keeps its question and answer-less path, now in 3b.
  - Intent: all four criteria met, plus the already-blocked move above.
  - Correctness: no remaining reference to the reason being settled in step 5 (step 3b's fallback now points to step 5
    for the note it writes). `block.md`'s steps are cited nowhere else.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Six single-runner readings from the drill → TASK-348, P3, grouped.

## Progress log

- step 2 — picked; ranked above TASK-347 because both are readings in a `tasks` verb (key 1 wrong results, key 2 routine verbs), but `block`'s step 4 writes a reason that step 5 settles only afterwards, so a run without `--reason` writes the field before it has a value (key 3: a plausible wrong line, silent), while TASK-347's readings change only output order. Key 6 did not separate them: both `correctness-invariants`
- step 3 — verified: held. The task template puts an unindented `# blocked: <reason> — …` comment directly after `status:`, so "after the `status:` line and every indented `#` line continuing its comment" places `blocked:` either side of it; "append a body note" names no place; step 4 writes `blocked: <reason>` while step 5 settles the reason when `--reason` is absent. Also found: the already-blocked stop sat in step 4, after the reason question — folded in, same root cause (writes and checks ordered after the reason)
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (trigger: four acceptance criteria)
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/block.md (new step 3b settles the reason before step 4; already-blocked stop moved to step 3; field placement relative to the template's `# blocked:` comment; body note placed under the `# Heading`, newest first; unblock's note placed the same way); no test file (prose repo: the guard is the step-6 check and the drill)
- step 6 — reverted fix (HEAD's block.md): 3/3 assertions failed; fix-dependent = reason question before step 4's write, field placement names the template comment, note placement names the heading; contract pins = skills-lint (passes on both); evidence for the readings = the Human test plan drill
- step 7 — respecced work-tracking (surgical); requirements changed: "Blocking and unblocking" (already-blocked stops before asking; reason settled before it is written; field and note placement; unblock note placed the same way); intended — TASK-332's criteria. shaped-by unchanged: the only intervening skills/tasks commit (4f2779c, TASK-330) is feature: null
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
