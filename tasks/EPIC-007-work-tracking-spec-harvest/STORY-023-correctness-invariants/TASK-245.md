---
id: TASK-245
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-72, SH-73, SH-74]
pr: null
github-issue: null
jira-key: null
---

# `verify-conventions` contradicts itself on the empty rulebook, drift severity, and where to register a pattern

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. All three are in `skills/verify-conventions/SKILL.md`.

- **SH-72 — the empty case.** § *What this skill does NOT do* says "No conventions written down → nothing to verify
  (and that's the finding)." But § *Finding the rulebook* says to "then run the smell baseline below", and the
  description promises "A project with no rulebook still gets a code-smell baseline".
- **SH-74 — register-on-introduce hard-codes one location.** Step 4's message is "…not recorded in CLAUDE.md §
  Conventions — add it…".
  - The rulebook ladder accepts `AGENTS.md`, `## Key Conventions`, a non-English heading, or rules woven through the
    guide.
  - The skill also says "Never suggest restructuring a guide to match the seed".
  - So in a repo whose rulebook lives elsewhere, the message points at a section that does not exist.
- **SH-73 — drift severity (partly).** Step 5 says "a stale architecture doc is a real defect, not
  stale-but-harmless". § Output format files architecture-doc drift under 💡 Suggestions. This is not a hard
  contradiction, since the skill never defines 💡 as "nice to have", but the two lines pull in opposite directions.

## Acceptance criteria

- [x] The "does NOT do" list says a project with no conventions gets the none-recorded finding plus the smell baseline
- [x] Step 4's message names the rulebook location step 2 found, not `CLAUDE.md` by default
- [x] Step 5 and § Output format agree on architecture-doc drift's severity, or step 5 no longer calls it a real defect
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ask-steps without a question (TASK-247)

## Human test plan

- [x] On a repo whose rules live under `## Key Conventions`, with an uncommitted change adding a read-through cache
      and leaving `## Architecture` stale, run `/verify-conventions` in two fresh sessions. Expected: the
      register-on-introduce finding names `§ Key Conventions`, and the architecture drift is ⚠.
  - **Passed 2026-10-11:** `%TEMP%\d245`. Both runs named `CLAUDE.md § Key Conventions` and reported architecture
    drift as ⚠ Warning. The brief was the bare command. The runner holds the installed skills, which this behaviour
    drill needs

## Implementation plan

_Populated by `/tasks plan TASK-245` — leave empty until then._

## Outcome

**The fix.** Three contradictions in `verify-conventions`:
- **Empty rulebook:** "does NOT do" said no conventions means nothing to verify. It now says the none-recorded
  finding *plus* the smell baseline, matching § *Finding the rulebook* and the description.
- **Register-on-introduce:** step 4 hard-coded `CLAUDE.md § Conventions`. It now names the rulebook location step 2
  found, never a section the guide lacks, and has its own wording when there is no rulebook. The description no
  longer says "in CLAUDE.md".
- **Architecture drift:** step 5 called it a real defect while § Output format filed it under 💡. It is now a ⚠
  Warning in both places.

**Step 6 split.** Pre-fix, 2 runs on the same fixture: **architecture drift under 💡 in both**. Fixed, 2 runs:
**⚠ in both**, so the severity is fix-dependent. **Contract pins, not evidence:** both pre-fix runs already named
`§ Key Conventions` rather than the hard-coded section. Runners adapted the message to the ladder anyway, so that
fix rests on the text. The empty-rulebook wording was not drilled.

**Judgement calls.**
- *⚠, not 🛑, for architecture drift.* The doc or the change may be the wrong one, and only a person can say which.
  That is the definition of ⚠. 💡 under-reported something step 5 calls a real defect.

**Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-246 because step 4's register-on-introduce message sends every repo whose rulebook is not `CLAUDE.md § Conventions` to a section that does not exist (key 3: a plausible wrong instruction), reached at every `/tasks close` that introduces a pattern (key 2), and all three fixes sit in one file (key 4); TASK-246's missing severity map is a vaguer report. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. "Does NOT do" says no conventions → nothing to verify, while § *Finding the rulebook* runs the smell baseline; step 4's message hard-codes `CLAUDE.md § Conventions` while the ladder accepts other homes and the description repeats it; step 5 calls architecture drift a real defect while § Output format files it under 💡
- step 4 — layer: local (`skills/verify-conventions/SKILL.md`)
- step 5 — fix in `skills/verify-conventions/SKILL.md`: "does NOT do" adds the smell baseline to the empty case; step 4 updates and names the rulebook location step 2 found (no rulebook → its own message); step 5 and § Output format put architecture drift under ⚠; the description drops "in CLAUDE.md". Lint green; drill 2/2 on `%TEMP%\d245`
- step 6 — reverted: pre-fix 2/2 filed architecture drift under 💡, fixed 2/2 under ⚠ (fix-dependent); both pre-fix runs already named `§ Key Conventions` (contract pin); empty-rulebook wording not drilled
- step 7 — respecced change-review (severity groups: architecture drift ⚠; register-on-introduce names the ladder's location; drift scenario expects ⚠; new scenario "Register-on-introduce names the guide's own section"); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
