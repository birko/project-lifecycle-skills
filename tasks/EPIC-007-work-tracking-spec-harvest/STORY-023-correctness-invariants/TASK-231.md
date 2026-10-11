---
id: TASK-231
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
findings: [SH-14]
pr: null
github-issue: null
jira-key: null
---

# `roadmap` states DV10's trigger twice, and the two statements contradict

## Context

Found by the project-roadmap spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-14.** `skills/roadmap/SKILL.md` step 2b says that when the spec map is absent or still the empty seed, DV10
  fires "if the project has real code (a `src/` tree or a build manifest with tracked source files)". The section
  *DV10: what counts as code* opens with "**Do not ask for a `src/` tree or a build manifest**" and puts that test
  third on a four-rung ladder, after the map's `ignore:` list and what the repo's gate runs over, ending in silence.
  The DV10 table row itself points at the ladder section. A reader of step 2b alone gets the test the ladder was
  written to replace, and this repo is the measured case where that test never fires (source is `skills/**/*.md`).

## Acceptance criteria

- [x] Step 2b defers to *DV10: what counts as code* rather than restating a trigger, so DV10's condition is stated in
      one place
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The other DV rules in this pass — TASK-232 (DV5), TASK-207 (DV1/DV4)

## Human test plan

- [x] On a repo whose code is in `lib/`, run by its CI, with no `src/`, no manifest and no spec map, run
      `/roadmap --check` in two fresh sessions. Expected: both raise DV10 with the fix `/specs init`, citing the gate.
  - **Passed 2026-10-11:** `%TEMP%\d231`. Both runs raised DV10 → `/specs init`, naming CI's `node lib/test.js` as
    the evidence. The brief was the bare command. The runner holds the installed skills, which this behaviour
    drill needs

## Implementation plan

_Populated by `/tasks plan TASK-231` — leave empty until then._

## Outcome

**The fix.** `roadmap` step 2b restated DV10's trigger as "a `src/` tree or a build manifest", which is the test
the § *DV10: what counts as code* ladder was written to replace. Step 2b now says to evaluate DV10 and defers to
that section, so the condition lives in one place.

**Step 6 split, stated exactly because it is weak.** Before the fix, both runs on the same fixture also raised
DV10 from the CI gate. They followed the DV10 table row to the ladder and ignored step 2b's narrower wording. So
the drill is a **contract pin, not evidence**. The fix rests on the text: two statements of one condition
disagreed, and this repo is the measured case where the narrower one never fires.

**Judgement calls.**
- *No respec.* `docs/specs/project-roadmap.md` already states DV10's condition only through the ladder; it never
  carried step 2b's restatement.

**Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-232 because a reader of step 2b alone gets the `src/`-or-manifest test the ladder replaced, so DV10 stays silent on a repo whose code is not in `src/` (key 3: a silent miss, measured on this repo), reached on every repo with no usable spec map (key 2), and the fix is one pointer (key 4); TASK-232's DV5 over-reports, which is loud. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. Step 2b says to flag DV10 when "the project has real code (a `src/` tree or a build manifest …)"; the ladder section says not to ask for either and ranks them third
- step 4 — layer: local (`skills/roadmap/SKILL.md`)
- step 5 — fix in `skills/roadmap/SKILL.md` step 2b: evaluate DV10 and defer to § *DV10: what counts as code*; no restated trigger left (grep). Lint green; drill 2/2 on `%TEMP%\d231`
- step 6 — reverted: pre-fix 2/2 also raised DV10 from the CI gate, reading the ladder through the table row. Contract pins only; fix-dependent = none observed. The fix rests on removing the contradicting restatement
- step 7 — no respec: `project-roadmap` states DV10 only through the ladder already
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
