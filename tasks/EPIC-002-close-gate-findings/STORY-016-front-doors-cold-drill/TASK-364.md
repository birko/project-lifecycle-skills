---
id: TASK-364
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
findings: [DRILL-363-1, DRILL-363-2]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Two rules set today meet at the `## Commands` offer and at a runner's `.gitignore` line

## Context

Filed 2026-11-13 at TASK-363's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d363`, `report.md`, § 7)
against the session's other drills. Both readings sit where two rules made today meet, and both now meet FEATURE-002
D10's two-runner bar.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-363-1 | TASK-102 puts every foreseeable offer in step 2's round, and TASK-354 renders `## Commands` after every fill. So the round offers a section whose content cannot exist yet. Runners gave it its own letter rendered from step-1 evidence, folded it into the guide-section offer, or noted the conflict. Related: whether a runner config (`pytest.ini`) counts as a source for the `## Commands` token, which names CI and manifests only | d357, d362, d363 |
| DRILL-363-2 | a test runner's output directory (`.pytest_cache/`) is arguably foreseeable at step 1, since step 1 already knows the stack and that the harness is missing. Adopt's exception still names `populate-tests`' `.gitignore` lines as found after the round. Both runners followed the named example and said it read oddly | d361, d363 |

## Acceptance criteria

- [x] The guide-section offer states how `## Commands` is offered when its content is rendered after the round:
      offered by name only, with content rendered later; or offered with the content step 1 can see, marked as a
      preview; or another stated form. The `## Commands` token's source column says whether a runner config counts
- [x] Whether a runner's ignore lines are foreseeable at step 1 is stated, and adopt's "found after the round" example
      agrees with it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where fill offers go in general: TASK-102 (done)

## Human test plan

- [x] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      neither DRILL-363-1 nor 2 in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d364`: a fresh copy of `d065/adopted`, `skills/` at this fix, and the
    d065b full brief, run with d065b/full's runner command.
    - **Coldness:** no skills listed and no Skill tool.
    - **The fill item:**
      - `c) add ## Commands to CLAUDE.md — filled in at the end of this run from what the repo then has`;
      - `e) add .env.* and .pytest_cache/ to .gitignore`. When `/populate-tests adopt` later wanted
        `.pytest_cache/`, the runner noted it was "already in letter e".
    - **Neither DRILL-363-1 nor 2 is in its undecided list.**
    - **Cross-drill:** four of its points match d362 or d363 and are filed as TASK-365, filed and not worked: the
      table form for a missing owner row, dotfiles in `tracked-files-at-scan`, the two workspace wordings, and
      template header comments as "fields".
    - **Recorded here, one runner each:**
      - recommendations for the licence and the fill item under grill-me's rule;
      - one letter per guide section;
      - three INFER rules on too-little code;
      - whether the verdict counts survey or final states;
      - the CI rule's two clauses (it chose correctly);
      - the seed's opening block;
      - `__init__.py` for a pytest `tests/` package;
      - `.env` and `.env.*` as two checks.

## Implementation plan

_Populated by `/tasks plan TASK-364` — leave empty until then._

## Outcome

**The fix (the user's decision on the first point, 2026-11-13).**
- **`## Commands` is offered by name in adoption's opening checklist**, "filled in at the end of this run from what
  the repo then has". The person approves the section, and the report shows the text written.
- **A runner config now counts as a source for its commands** (`pytest.ini` → `pytest`).
- **A test runner's output-directory ignore lines are foreseeable** when step 1 knows the stack and finds no
  harness, so they join the checklist's `.gitignore` letter. "Found after the round" is narrowed to a line step 1
  could not predict.

**Step-6 split.**
- **Text assertions:** 3 of 3 fail on `HEAD`'s copies and pass on the fix, all fix-dependent. The script is
  `task364-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** three runners (d357, d362, d363) and two (d361, d363) raised the two readings.
  - **After:** d364 settled both.
- **Contract pins, not evidence:** skills-lint, and the TASK-354 and TASK-102 checks.

**Judgement calls.**
- **The `## Commands` form was asked.** Each option trades something visible: exact text, one round, or approving a
  section by name. The user took "by name".
- **Foreseeable output dirs needed no question:** both runners read it that way, and only the old example contradicted
  them.

**Close gate (inline, about 12 lines over two files):**
- **Standards:** layer parity holds (the guide row and the token table are in LAYER), and every ask keeps its stated
  form.
- **Intent:** criteria met.
- **Correctness:** none found.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-365**, filed and not worked, by the user's agreement to end the `adopt-project` run here.
- **One-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked by the user's go-ahead ("ok continue") after TASK-363 named it next; correctness-invariants, two readings at the seam of two of today's rules
- step 3 — verified: held. adopt step 2 puts every foreseeable offer in the round; LAYER § Ordering renders `## Commands` after every fill; the `{{BUILD_RUN_COMMANDS}}` adopter source names CI and manifest entry points only; adopt's late-offer example names populate-tests' `.gitignore` lines
- step <guardrail> — decision put to the user (2026-11-13): the `## Commands` item is offered by name, filled in at the end of the run; recommendation taken. Settled without asking: a runner's output-dir ignore line is foreseeable when step 1 knows the stack and finds the harness missing (both runners' reading), and a runner config counts as a `## Commands` source
- step 4 — layer: local
- step 3b — not planned separately: two short answers in two files, set by the decision
- step 5 — fix in new-project/LAYER.md (guide row: `## Commands` offered by name; `{{BUILD_RUN_COMMANDS}}` adopter source adds a runner config) and adopt-project/SKILL.md (runner output dirs foreseeable; the late case narrowed)
- step 6 — reverted fix (HEAD copies): 3/3 assertions failed; fix-dependent = N1–N3; contract pins = skills-lint, task354 and task102 checks
- step 7 — respecced project-baseline, surgical, restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
