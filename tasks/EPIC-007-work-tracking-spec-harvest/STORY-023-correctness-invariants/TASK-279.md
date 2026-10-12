---
id: TASK-279
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-118, SH-119, SH-123]
pr: null
github-issue: null
jira-key: null
---

# `improve-architecture`'s records line cannot say what happened when filing fails or nothing is found

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-118:** `skills/improve-architecture/SKILL.md`'s records-line templates (the page header and stdout) give two forms. Step 7 adds a third ("not filed — no task tree; …") that neither lists, and "not filed yet — this report is the only copy" is unreachable, because Step 7 files before the report is written.
- **SH-119:** a failed or partial `/tasks intake` has no defined outcome; the unused "not filed yet" form is its natural home.
- **SH-123 (weak):** a run with no candidate and no rejection: intake's "write it `done`" sits inside its dropped-finding bullet, so this run's epic status is covered only by extension.

## Acceptance criteria

- [x] The records line has one list of forms, used by both the page and stdout, covering filed, no task tree, intake failed (with what was and was not filed) and nothing to file
- [x] An intake that fails part-way has a stated outcome
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The gate and decision-record outcomes (TASK-280)

## Human test plan

N/A: report wording, checked by reading Step 7 against both templates.

## Implementation plan

_Populated by `/tasks plan TASK-279` — leave empty until then._

## Outcome

**What changed.** `improve-architecture`'s records line, the one line saying whether a run's findings became
tracked tasks, had two forms in its templates. One of them could never be reached, and Step 7 used a third form
that neither template listed. Nothing covered an intake that fails part-way or a run with nothing to file, so a
run could leave findings unfiled with no true line to say so. Now:
- Step 7 owns **one table of five forms**: filed, not filed with no task tree, not filed because intake failed,
  filed in part, and nothing to file. The page header and stdout both print from it. The unreachable
  `not filed yet …` form is gone.
- **An intake that stops part-way** keeps what it wrote, is not retried in the same run, and names every unfiled
  finding by key. It also names every rejection when the epic's dropped list was not written, because the next
  run reads that list as the whole set of standing rejections. `--epic` on this run's own epic is allowed, as
  the one exception to Step 7's always-a-new-epic rule.
- **A run with nothing to file** creates no epic. The "write the list whatever the run's size" sentence now names
  that as its one exception.
- Respecced `code-shape-review`: the no-task-tree requirement became the five-form requirement (title and body),
  the page-output requirement no longer lists the old form, and there is a new scenario, *Intake stops
  part-way*.

**Step-6 split.** Both runs were cold drills (`claude -p --disable-slash-commands < brief.txt`, run from
`C:/Source/WebChecker`, both `SKILLS-SEEN: none`) on one brief with two Step-7 situations: (A) intake creates the
epic, files two of three candidates, then fails on a permission error; (B) no candidate, no rejection, no
earlier run. The brief carried the skill from `HEAD` (before) or from the working tree (after), and did not say
what was expected.
- **Before the fix:** both records lines were invented. A's began `filed into EPIC-014 — partial…`, which reads
  as filed to anything matching the defined form. Both were flagged as not covered by the skill.
- **After the fix:** both lines were the defined forms (`filed in part into EPIC-014 — not filed: …` and
  `nothing to file — …`).

So 0 of 2 used a defined form before the fix and 2 of 2 after, and both cases depend on the fix. The lint passes
either way, so it is a contract pin, not evidence.

**Found by the drill and fixed before commit.** Both runners saw that a part-way intake may not have written the
dropped list, which loses the run's rejections. The new runner also saw that "write the list whatever the run's
size" contradicted the new nothing-to-file row. Both were fixed (above) after the drill. The drill was not re-run
on those two sentences.

**Judgement calls.**
- **No retry within the run.** A retry that fails the same way leaves two partial epics, and the next run's Step
  1 would read the wrong one. Instead the line carries the exact command to finish the epic.
- **Nothing to file creates no epic.** An epic with no finding and no rejection records nothing a later run reads,
  and it would show as a finished review in the dashboard.

**Flagged, not fixed.** Nothing. The gate and decision-record outcomes are TASK-280 (Out of scope).

**Merge gate (close step 5b, run inline, each verdict on its own):**
- *Standards*: pass. The list of forms has one owner (Step 7), and the templates point at it instead of copying
  it. No new cross-cutting pattern.
- *Fidelity*: pass. Criterion 1 is the five-form table used by both templates, criterion 2 is the part-way rule,
  and criterion 3 is lint OK. TASK-280's gate and ADR outcomes were left untouched.
- *Correctness*: two findings, both fixed before commit. These are the drill findings above.
- *Security* and *Comments*: not applicable.

## Progress log

- step 2 — picked; ranked above TASK-280 because a failed intake leaves the report's records line with no true form to print, so findings can go unfiled while the run reports nothing wrong (keys 1 and 3), where TASK-280 leaves a gate result unmapped; TASK-300 sits below on key 4 (open design question). Key 6 not needed: all correctness-invariants
- step 3 — verified: held. Step 7 defines `not filed — no task tree; …`, which neither the page's records line nor the stdout template lists; both offer `not filed yet — this report is the only copy …`, unreachable because Step 7 files first; neither Step 7 nor intake defines an intake that fails or stops part-way; a run with no candidate and no rejection has no stated form
- step 4 — layer: local
- step 5 — fix in skills/improve-architecture/SKILL.md (Step 7 records-line table, part-way rule, nothing-to-file; page and stdout templates point at it); evidence is a cold drill (prose)
- step 6 — reverted fix (HEAD text, same brief, cold runner): 0/2 records lines in a defined form (both invented, one reading as filed); with fix 2/2; fix-dependent = both cases; contract pins = skills-lint.sh. Both runners found unwritten rejections lost on a part-way intake, and the new runner a contradiction with 'write the list whatever the run's size'; both fixed after the drill, not re-drilled
- step 7 — respecced code-shape-review; requirements changed: no-task-tree requirement became 'The records line says what filing did, in one of five forms' (title and body; new scenario: Intake stops part-way), page-output requirement's records-line clause
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
