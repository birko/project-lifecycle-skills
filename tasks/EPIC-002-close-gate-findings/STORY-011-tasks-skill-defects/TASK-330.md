---
id: TASK-330
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/tasks migrate` prompts for the repo or project with no question text and no answer-less path

## Context

Spawned 2026-11-04 from TASK-218, whose plan found it while fixing `migrate`'s other ask-steps. It is not one of
TASK-218's four findings, so it was filed rather than folded in.

`skills/tasks/verbs/migrate.md` step 2: `--repo owner/name` (GH) or `--project KEY` (Jira) "overrides interactive
prompt". The prompt itself is never worded, and nothing says what a run does when nobody answers it. AGENTS.md
§ Output/prose rules requires both. The safe unattended outcome is the one step 4 now takes: push nothing,
write nothing, report that the run did not migrate because no target was given.

## Acceptance criteria

- [x] Step 2 states the question it puts when `--repo`/`--project` is absent, in the form the other ask-steps use
- [x] It states what happens when nobody answers: nothing pushed, nothing written, the report names the missing target
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Step 4's confirmation, dry run, milestone linkage and the export hand-off — TASK-218

## Human test plan

N/A — wording of one ask-step; the reviewer check against the AGENTS.md rule at close covers it.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Trigger: three acceptance criteria.

1. `skills/tasks/verbs/migrate.md` step 2: word one question per provider in the bold-quote form, put before step 3,
   `--dry-run` included (its plan and pre-flight name the target). No answer: stop before step 3, push nothing, write
   nothing, and print a `Not migrated — no target given …` line in the shape step 4's refusal uses. Say why a git remote
   is not a substitute.
2. Step 6's hand-off to export passes the target as `--repo`/`--project` whichever source named it, so export's
   "the caller's `--repo`" stays true.
3. Respec `work-tracking` § *Migrating to hybrid mode*, whose "`--dry-run` … ask nothing" the new question contradicts.

## Outcome

**The fix.** `/tasks migrate` said `--repo`/`--project` "overrides interactive prompt", but never worded the prompt or
said what happens when nobody answers. An unattended run was left to invent a push target, which means writing issues
into a tracker nobody named. Step 2 now puts one worded question per provider before inventory. With no answer it
stops, pushes and writes nothing, and prints `Not migrated — no target given (pass --repo owner/name or --project KEY);
nothing pushed, tasks/.config.yml still mode: local.`

**Step 6 split.** 2 of 2 assertions failed on HEAD's `migrate.md` and pass on the fix. Both are fix-dependent: a worded
question for both providers, and a no-answer line that stops and names the missing target. Contract pin, **not
evidence**: skills-lint passes on both.

**Judgement calls.**
- **The question runs under `--dry-run` too**, which the spec said "asks nothing". A dry run prints a plan and a
  pre-flight that both name the target, so without one it has nothing true to print. The alternative was a placeholder
  target in the dry run, which would print a pre-flight that never ran. The spec now reads "ask nothing but that
  target question".
- **A git remote is explicitly not a fallback target.** It is the tempting inference, and the rejected one: a remote is
  evidence consistent with several trackers (or none), and AGENTS.md § *Read the declaration, never infer it* covers
  exactly this.
- **Step 6's export hand-off reworded** so an answered target is passed as `--repo`/`--project`. Export reads
  "the caller's `--repo`", which an answer alone would not have satisfied. Found in the inline correctness pass.
- **Close gate ran inline** on a ~15-line prose diff.
  - Standards: no finding.
  - Intent: all three criteria met; the export hand-off line is needed for criterion 2's "nothing pushed" to hold on
    the answered path.
  - Correctness: one finding (the hand-off), fixed.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Nothing.

## Progress log

- step 2 — picked; ranked above TASK-332 because both are `tasks` verb defects (key 1 wrong results, key 2 a routine verb), but `migrate`'s unworded prompt with no answer-less path leaves an unattended run to invent a push target, a write to an external tracker, while `block`'s readings misplace a line in a local file (key 1 within the bucket: an unbounded external write outranks a local misplacement). TASK-347, filed last run, is P3 readings and ranks below both. Key 6 did not separate them: all `correctness-invariants`
- step 3 — verified: held. `migrate.md` step 2 said only "overrides interactive prompt": no question text, no answer-less path
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (trigger: three acceptance criteria)
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/migrate.md (step 2 question and no-target stop; step 6 passes an answered target as `--repo`/`--project`); no test file (prose repo: the guard is the step-6 check)
- step 6 — reverted fix (HEAD's migrate.md): 2/2 assertions failed; fix-dependent = worded question for both providers, no-answer stop naming the missing target; contract pins = skills-lint (passes on both)
- step 7 — respecced work-tracking (surgical); requirements changed: "Migrating to hybrid mode" (target question with its no-answer stop; `--dry-run` asks only that); intended — TASK-330's criteria. shaped-by unchanged: the only intervening skills/tasks commit (0d263da, TASK-346) is feature: null
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
