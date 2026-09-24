---
id: TASK-166
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-24
depends-on: []
blocks: [TASK-141]
findings: [DRILL-165-1]
pr: null
github-issue: null
jira-key: null
---

# Clear the three findings every reader pair agrees on, before TASK-141's re-run

## Context

TASK-141 re-closes on a re-run with two cold readers, where clean means *no finding both readers raise*
(defined 2026-09-24 by the stakeholder). Across the four reader pairs run that day (TASK-162, -163, -164,
-165), **three findings were raised by both readers in every pair** — so a re-run today would fail on
them:

| Finding | Readers | Prior handling |
|---|---|---|
| `pi-install.sh:3` / `pi-install.ps1:2` — *"skills-pi/ is never linked into ~/.claude/skills."* describes what a **different** script must never do, one line above the pointer to its source (ADR 0010) | 8 of 8 | TASK-141 reduced it to the bare fact and kept it as *"an instruction at the point of danger"* |
| `skills-lint.sh` `ARG_RE` block — the rejected first attempt, retold | every pair | TASK-141 recorded that the block duplicates the test file and quotes its fixture — destination *the code itself* — and left acting on it "for whoever takes it" |
| `skills-lint-test.sh` EVIDENCE/PIN lines — *"passes against the old lint"* read as a QA log: a past run, against a version not in the tree | every pair since TASK-153 | accepted as by-design on TASK-153 |

**The third was re-decided 2026-09-24 by the stakeholder**: rewrite each line as what the case
*detects*, in the present tense — the mechanism a test proves, which the rule explicitly allows —
instead of what a past run printed. Same fact, no longer a log.

**Why the first reverses TASK-141's "point of danger":** the danger is in `install.sh`, which is where
someone would add `skills-pi/`; `pi-install.sh` cannot commit the mistake it warns about. The fact lives
in § Architecture and ADR 0010, and the pointer to both is the next line.

## Acceptance criteria

- [x] Both `pi-install` headers lose the restated line; the ADR 0009 / ADR 0010 pointer line stays.
- [x] The `ARG_RE` block keeps what the regex cannot show — what an argument may be, the one-lowercase-word ceiling, and why raising it reopens the false positive — and loses the rejected-attempt narrative, which TASK-108 holds and the test pins.
- [x] Every EVIDENCE/PIN line in `skills-lint-test.sh` says what the case detects, in the present tense; no line refers to "the old lint" or a past run. The EVIDENCE-vs-PIN distinction survives in all four blocks.
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass, case count unchanged; every changed script line a comment.
- [x] `AGENTS.md` § Comments table re-measured; `pi-install` rows' counts and verdict updated.

## Out of scope

- The re-run itself and the sign-off — **TASK-141**.
- Single-reader items recorded on TASK-165 (`skills-lint.sh:142-145`, `:156`, `:288-290`) — below TASK-141's bar by definition.

## Human test plan

N/A as a separate step — **TASK-141's re-run is this task's test**: two cold readers over all six scripts,
and TASK-141 does not close unless none of these three is raised by both. Running a second drill here
first would measure the same thing twice.

## Implementation plan

| Site | Change |
|---|---|
| `pi-install.sh:3`, `pi-install.ps1:2` | delete the line |
| `skills-lint.sh` `ARG_RE` block (`:119-131`) | merge `:119`'s TASK-108 pointer into the block; keep a gloss of what `ARG_RE` admits, the ceiling, and the reopen-the-false-positive reason; cut the first-attempt story and the quoted prose sentence (it is `m_flagprose`'s fixture — point there) |
| test, block 1 | *"the first passes against the old lint"* → *"the first fails only while the pattern admits an argument before the flag"* |
| test, block 2 | *"passes against the old lint"* → fails only while every flag on the match is checked; the fixture note's *"the old lint"* → *"a first-flag-only match"* |
| test, block 3 | *"errors against a bare-word ARG_RE"* → passes only while `ARG_RE` rejects a bare lowercase word |
| test, block 4 | *"neither fails against the old lint"* → no defect added them; each fails only if `templates/` is skipped or the scan is narrowed to `*.md` |

**Outcome (2026-09-24).** All five criteria met. `pi-install.sh` 42 → 41, `pi-install.ps1` 37 → 36,
`skills-lint.sh` 315 → 311 (longest comment run 26 → 22 — the `ARG_RE` block was it); no "old lint" left
in the test file. `skills-lint.sh`'s committed CRLF endings preserved. The `install.*` table rows'
*"same shape, same change"* now named a change they never had — corrected in the same pass.

**Gate, inline** — comment lines only across four scripts plus the table: standards ✅ · fidelity ✅
criteria 1-5 · correctness ✅ zero executable lines changed, 56/56, lint exit 0 · comments ✅ each rewrite
states a mechanism or a pointer; the full check is TASK-141's re-run, by design (Human test plan).
Security: not applicable.
