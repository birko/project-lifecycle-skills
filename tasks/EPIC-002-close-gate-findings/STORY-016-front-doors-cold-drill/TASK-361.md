---
id: TASK-361
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-360-1]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `/specs init` inside an adoption cannot see the files the same run wrote

## Context

Filed 2026-11-13 from a cross-drill comparison. Three cold full-adoption runners hit it, each from a different side:

| Drill (under `%LOCALAPPDATA%/Temp/`) | What the runner saw |
|---|---|
| `d102b` (point 11) | "the scan is **every file git tracks**". Nothing this run wrote was committed, so the scan saw only the original 7 files |
| `d360` (point 15) | the same: 5 tracked files, while the run had created the guide, `tasks/`, `docs/` and more |
| `d072/a` (point 9) | files created after `specs init` (`pytest.ini`, `CHANGELOG.md`) are not in the map's `ignore` list, and will show as unmapped once committed |

**The mechanism.** `/specs init`'s scan universe is the tracked files, which is right in general and keeps a
working copy's junk out. An adoption chains `specs init` in the middle of a run that writes files and commits
nothing until its closing offer. So the map is built over a repo that no longer exists, and the first commit makes
it report drift that the same run created. Whatever this run created is either unmapped or never considered for
`ignore`.

## Acceptance criteria

- [x] What `specs init` scans when chained from an adoption is stated. Options include the tracked files plus the
      paths this run created, or running `specs init` after every other fill, or reporting the gap explicitly as
      part of its `coverage:` verdict
- [x] Layer files the adoption itself creates (the guide, `tasks/`, `docs/`, `CHANGELOG.md`, the harness) do not
      show up as unmapped drift on the first commit, or the report says that they will and why
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `specs init`'s scan rule outside an adoption: the tracked-files universe is settled (TASK-033)

## Human test plan

- [x] Run a cold full adoption of a fresh copy of `%LOCALAPPDATA%/Temp/d065/adopted`, then commit everything it
      wrote and run `/specs verify`. Expected: no unmapped drift caused by the adoption's own files, or a report
      line the adoption printed naming them in advance
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d361`: a fresh copy of `d065/adopted` and `skills/` at this fix. One
    cold runner did three things in order:
    1. a full `/adopt-project`;
    2. `git add -A` and one commit, `adoption`;
    3. `/specs verify`.

    **Coldness:** no skills listed and no Skill tool.
    - **What `/specs init` printed:** `scan: 7 tracked + 6 written this run by adopt-project (docs/features/README.md,
      CHANGELOG.md, .gitattributes, .editorconfig, pytest.ini, tests/README.md)`.
    - **After the commit, `/specs verify` reported no unmapped files.** Of its 14 tracked files:
      - `src/app.py` is in an area;
      - `.gitignore`, `.gitattributes` and `.editorconfig` are skipped without needing an ignore entry;
      - every other file matches an `ignore` entry the map wrote from the adoption's own files.
    - **Four points from this task's own wording, and from TASK-357's, fixed at the close and not re-drilled:**
      - **1:** moving `specs init` after the fills left both dashboards' drift callouts stale. 3c now names the
        map → dashboards edge.
      - **2:** `tracked-files-at-scan` counts the written files too.
      - **3:** "written" means created and untracked. A tracked file the run changed is already in the scan.
      - **10:** a bare `_None_` under the features table header was a broken row. It is now a `_None_` table row.
      - **Also fixed, its 5:** `missing, not offered` counts as missing in the verdict.
    - **Cross-drill:** its point 4, whether `specs init` must ask before ignoring housekeeping files, matches d356/f,
      and is added to TASK-362 as DRILL-357-5.
    - **Recorded here, one runner each:**
      - **7:** `.pytest_cache/` is arguably foreseeable at step 1;
      - **9:** the harness was wired on a stack nobody confirmed;
      - **11:** `verify` suppresses zero counts while `regen` step 6 prints them.
      - **6 and 8** are TASK-362's.

## Implementation plan

_Populated by `/tasks plan TASK-361` — leave empty until then._

## Outcome

**The fix.** `/specs init`, chained by an adoption, now sees the repo the adoption commit will make:
- **Adoption hands it the paths this run created.** None of them is committed yet.
- **`init` counts those paths with the tracked files** and says so: `scan: <n> tracked + <m> written this run by
  <caller>`. The shared rule stays "every file git tracks", with this one named exception.
- **LAYER's Ordering runs `specs init` after the other fills**, so the list is complete. Step 3c re-runs both
  dashboards afterwards, because the new map feeds their drift callouts.

**Step-6 split.**
- **Text assertions:** 4 of 4 fail on `HEAD`'s copies and pass on the fix, all fix-dependent. The script is
  `task361-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** on the old text, three runners (d102b, d360, d072/a) had the map miss the run's own files.
  - **After:** the d361 runner's map covered them, and `verify` after the commit found nothing unmapped.
- **Contract pins, not evidence:** skills-lint, and TASK-357's checks, which still pass after its `_None_` wording
  changed.

**Judgement calls.**
- **Rejected: `git add -N` (intent-to-add) to make the files "tracked".** It would satisfy the rule mechanically, but
  it writes the user's git index unasked, and leaves it changed if the commit offer is declined.
- **Rejected: widening the shared rule to include untracked files.** `verify` and `regen` would then count build
  junk. The exception is named, caller-supplied and reported.
- **Ordering over refreshing.** `specs init` runs once, after the fills, rather than twice. The two dashboards it
  makes stale are re-run by 3c, which is cheap and already the mechanism for that.
- **Spec stamps.** `specs-from-code` is restamped: its one later source change (TASK-238) had respecced it without
  restamping. `project-baseline` is restamped. `feature-lifecycle` was restamped at TASK-357, and only this task's
  `_None_` sentence has changed since.

**Close gate (inline, about 25 lines over five files):**
- **Standards:** the shared scan rule has one owner (specs SKILL.md), and `init` and adoption point at it. Layer
  parity holds: `new-project` never chains `specs init`.
- **Intent:** criteria met.
- **Correctness:** four follow-ups from the drill were fixed before the close.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-362** gained DRILL-357-5.
- **One-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked; ranked above TASK-362 and TASK-099 (same story, correctness-invariants, key 6 inert) because three runners raised it and its effect is a spec map that reports drift the same run created, on every full adoption (keys 1–3)
- step 3 — verified: held; specs SKILL.md § The area map fixes the universe as tracked files, and LAYER § Ordering runs specs init before the later fills
- step 3b — planned inline (four files, three criteria). Rejected: `git add -N` to make the files tracked — it writes the user's index unasked. Chosen: a named exception (a caller passes the paths it wrote), plus ordering specs init after the other fills
- step 4 — layer: local
- step 5 — fix in skills/specs/SKILL.md (scan exception), skills/specs/verbs/init.md (count the passed paths, say so), skills/new-project/LAYER.md (§ Ordering: specs init after the other fills), skills/adopt-project/SKILL.md (hand the paths over)
- step 7 — respecced specs-from-code (scan universe) and project-baseline (fill order), surgical, both restamped — specs-from-code's one later source change (TASK-238) had respecced it without restamping
- step 6 — reverted fix (HEAD copies): 4/4 assertions failed; fix-dependent = K1–K4; contract pins = skills-lint, task357-check 7/7
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
