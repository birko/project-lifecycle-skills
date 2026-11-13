---
id: TASK-358
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-348-1, DRILL-348-2]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# The `tasks/README.md` dashboard template leaves two rendering details to the reader

## Context

Filed 2026-11-13 from TASK-348's two cold drills, `%LOCALAPPDATA%/Temp/d348` and `d348b`, with reports kept there.
Each ran `/tasks block` on a fresh copy of `d212/repo`, which chains `triage`. **Both runners raised these two**,
the agreement bar FEATURE-002 D10 sets. They were recorded on TASK-348 as one-runner readings before the two
reports were compared. Both are in `skills/tasks/verbs/triage.md` and its template `templates/README.md.tmpl`.

- **DRILL-348-1 — blank lines around an omitted section.** The template places `{{INREVIEW_SECTION}}`,
  `{{LOOSE_SECTION}}` and `{{COMPLETED_SECTION}}` between blank lines, and triage says "entire section omitted". It
  does not say whether the surrounding blank lines go too. Both runners collapsed them, each by its own reasoning.
- **DRILL-348-2 — tree rows and priority.** Step 3's in-progress bullet shows `(P1, ai)`, while step 4's tree
  example (`- [ ] TASK-003 Rate limit`) shows neither priority nor assignee. Both runners asked whether tree rows
  carry them, and both left them out by following the example.

## Acceptance criteria

- [x] Triage states what happens to the blank lines around an omitted section
- [x] Triage states which fields a tree row carries
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The bare `/tasks` snapshot's template: TASK-355 (done)
- Column padding after a placeholder fills, and the timestamp's time zone: one runner each (TASK-348's record)

## Human test plan

- [x] Re-run TASK-212's brief on a fresh copy of `d212/repo` with `skills/` at the fix, using a cold runner. Expected:
      neither DRILL-348-1 nor 2 in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d358`: a fresh copy of `d212/repo`, `skills/` at this fix, and
    TASK-212's brief, run with TASK-212's runner command plus `Write` and `Edit`.
    - **Coldness:** no skills listed and no Skill tool.
    - **The dashboard it wrote** has no doubled blank line, and its tree rows carry only id, title and markers.
    - **Tree-row fields are not among its undecided points.**
    - **Fixed at the close, not re-drilled:** it asked which blank line an omitted *trailing* section takes, and
      ended the file after the tree, as intended. The rule now names it: the one before it, with a single final
      newline.
    - **Cross-drill:** its column-padding and time-zone points match d348b's, and are filed as TASK-366.
    - **Recorded here, one runner each:**
      - the `uncommitted: <files>` format;
      - whether an unanswered question counts as printed output;
      - `{{PROJECT_NAME}}` against the README's own title;
      - creating an absent dashboard counting as "regenerate".

## Implementation plan

_Populated by `/tasks plan TASK-358` — leave empty until then._

## Outcome

**The fix.** `/tasks triage` now states:
- **Tree rows carry the id, the title and the markers, and nothing else.** Priority and assignee stay in the lists
  that already print them.
- **An omitted section takes the blank line before it**, so sections stay one blank line apart and the file ends
  with a single newline.

**Step-6 split.**
- **Text assertions:** 2 of 2 fail on `HEAD`'s copy and pass on the fix, both fix-dependent. The script is
  `task358-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** the d348 and d348b runners both raised these.
  - **After:** d358 did not, and its file has no doubled blank line.
- **Contract pins, not evidence:**
  - skills-lint;
  - this repo's own dashboard, which already met both rules.

**Judgement calls.**
- **Both answers are what both runners already did**, and what this repo's own dashboard shows. No decision was
  needed.
- **Spec:** `work-tracking` is restamped. Its one source change since the last stamp, TASK-357's, was respecced in
  that commit.

**Close gate (inline, 6 lines in one file):**
- **Standards:** the rule sits in the owning verb.
- **Intent:** criteria met.
- **Correctness:** the blank-line ambiguity from the drill was fixed.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-366**, filed: column padding and the timestamp's time zone (two runners).
- **One-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked; first correctness-invariants task outside the paused adopt-project run: two two-runner readings, self-contained in one verb (keys 4–5)
- step 3 — verified: held; triage step 7 omits sections without saying what happens to their blank lines, and step 4's tree example shows no priority while step 3's list does
- step 3b — not planned: one file, two criteria
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/triage.md (tree rows: id, title, markers only; an omitted section takes one blank line)
- step 6 — reverted fix (HEAD copy): 2/2 assertions failed; fix-dependent = O1, O2; contract pins = skills-lint. This repo's own dashboard already meets both
- step 7 — respecced work-tracking (Generated dashboard), surgical, restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
