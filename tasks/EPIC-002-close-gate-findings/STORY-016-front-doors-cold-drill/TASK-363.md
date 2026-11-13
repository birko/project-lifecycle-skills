---
id: TASK-363
parent: STORY-016
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
findings: [DRILL-362-1, DRILL-362-2, DRILL-362-3]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Three more adoption readings that a second cold runner has now raised

## Context

Filed 2026-11-13 at TASK-362's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d362`, `report.md`, § 7)
against the session's other drills under `%LOCALAPPDATA%/Temp/`. Each was recorded as a one-runner reading on an
earlier task, and d362 raised it again, which meets FEATURE-002 D10's bar.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-362-1 | `adopt-project`'s re-run wording, "write each one as `missing — this repo was adopted <date>…`": whether it covers `missing, not offered` rows (the CI gate) too. Both runners applied it to plain `missing` only | d357, d362 |
| DRILL-362-2 | `populate-tests`' § Testing question says "with tests in `<path>`", but no tests exist yet: a repo with nothing testable (d072/b), or a harness about to be wired (d362). Runners wrote "none" or the directory adopt would create | d072/b, d362 |
| DRILL-362-3 | the features index's drift note: its template says "If `/roadmap --check` would flag **feature↔task** drift", while its hint lists `specs/.map.yml` and `specs/<area>` as targets. Whether spec-layer findings (DV7, DV10) belong in it is unstated | d357, d362 |

## Acceptance criteria

- [x] DRILL-362-1 … 3 each have one stated answer, in the file that owns the rule (`adopt-project`,
      `populate-tests`, `feature`'s index template or `status` verb)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Everything TASK-356, TASK-357, TASK-361 and TASK-362 settled

## Human test plan

- [x] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      none of DRILL-362-1 … 3 in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d363`: a fresh copy of `d065/adopted`, `skills/` at this fix, and the
    d065b full brief, run with d065b/full's runner command.
    - **Coldness:** no skills listed and no Skill tool.
    - **What the run did:**
      - the CI row read `missing, not offered — this repo was adopted 2026-08-18, so the layer gained it since or it
        was removed; nothing to run yet`;
      - the § Testing question read "with tests in tests/";
      - both dashboards' drift notes carried the spec findings (DV10 → DV7).
    - **None of DRILL-362-1 … 3 is in its undecided list.**
    - **Cross-drill:** its points 1 (the `## Commands` offer against rendering last: d357 and d362 too) and 2
      (`.pytest_cache/` foreseeable at step 1: d361 too) are filed as TASK-364.
    - **Recorded here, one runner each:**
      - two wordings for the workspace line;
      - what counts as a template "field";
      - the § Testing question firing beside a guide that declares the stack;
      - whether "nothing inferable" is a skip;
      - dotfiles in `tracked-files-at-scan`;
      - the drift line's short reason in the features index;
      - the features index's timestamp format;
      - an empty `tests/` being untrackable.

## Implementation plan

_Populated by `/tasks plan TASK-363` — leave empty until then._

## Outcome

**The fix.** Three more adoption readings now have one answer each:
- **`missing, not offered` takes the re-run wording**, with its reason after it.
- **`populate-tests`' § Testing question names where tests will go** when none exist, or says there is nothing to
  test.
- **The features index's drift note carries every finding `/roadmap --check` reports**, spec-layer targets included,
  which its own hint already listed.

**Step-6 split.**
- **Text assertions:** 3 of 3 fail on `HEAD`'s copies and pass on the fix, all fix-dependent. The script is
  `task363-check.sh` in the session scratchpad.
- **Behaviour:** d363 settled all three.
- **Contract pin, not evidence:** skills-lint.

**Judgement calls.**
- **No decision was asked.** Each answer is the one both runners already took, or the one the existing text implied
  (the template's hint already listed spec targets).
- **Spec stamps.** `project-baseline` and `feature-lifecycle` are restamped. `test-authoring` was not edited, because
  it does not state the question's wording, and its stamp stays for TASK-359.

**Close gate (inline, about 8 lines over three files):**
- **Standards:** each answer sits in its owner.
- **Intent:** criteria met.
- **Correctness:** none found.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-364**, filed: two readings at the seam of TASK-102's round and TASK-354's ordering.
- **One-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked; last of the 2026-11-13 adoption groups (correctness-invariants, key 6 inert), three two-runner readings with no open design question (keys 4–5)
- step 3 — verified: held, all three open in the text
- step 4 — layer: local
- step 3b — not planned separately: three one-sentence answers in three files
- step 5 — fix in adopt-project/SKILL.md (re-run wording on `missing, not offered`), populate-tests/SKILL.md (the § Testing question's `<path>` with no tests), feature/templates/README.md.tmpl (drift note carries spec-layer findings)
- step 6 — reverted fix (HEAD copies): 3/3 assertions failed; fix-dependent = M1–M3; contract pins = skills-lint
- step 7 — respecced project-baseline and feature-lifecycle, surgical, restamped. test-authoring not edited: it does not state the question's wording, and its stamp stays for TASK-359
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
