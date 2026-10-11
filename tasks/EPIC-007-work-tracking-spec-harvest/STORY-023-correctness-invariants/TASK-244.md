---
id: TASK-244
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
findings: [SH-62, SH-63]
pr: null
github-issue: null
jira-key: null
---

# The adopter's inference rules leave one case unruled, and write where they say to write nothing

## Context

Found by the project-baseline spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second
reader against the files at `adc4c27`. Both are in `skills/adopt-project/INFER.md`.

- **SH-62 — a threshold gap.** § *Convention or accident?* gives three rows:
  - "~80%+ **and** at least 5 files" → propose
  - "roughly 20–80%" → ask
  - "under 20%, or fewer than 3 files" → silent

  A pattern at 80% or more across 3 or 4 files falls into no row.
- **SH-63 — glossary candidates are written on the path that writes nothing.** § *Glossary candidates* says, with
  no condition, "Record them in the agent guide meanwhile, under its § Conventions › Naming subsection". § *When the
  rulebook already answers it* says "All covered → skip the round … and write nothing", and on that skip path
  candidates are "reported, not asked". The unconditional write also skips the confirmation that "propose, never
  assert" requires.

## Acceptance criteria

- [x] Every combination of share and file count maps to exactly one of propose / ask / silent
- [x] Glossary candidates are written to the guide only when a round runs and the user confirms; on the skip path they are reported only
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The inference skip rule's subsection count (TASK-028)

## Human test plan

- [x] Walk the threshold table for 2, 3, 4 and 5 files at 85%, and at 50% and 10% with 10 files: each lands in one row.
  - **Passed 2026-10-11:** 2 files → row 1 (silent); 3 and 4 files at 85% → row 4 (ask); 5 files at 85% → row 3
    (propose); 10 files at 50% → row 5 (ask); 10 files at 10% → row 2 (silent). Exactly one row each.
- [x] Run `/adopt-project` unattended on a repo whose rulebook covers every subsection and whose code holds a
      `User`/`Account` synonym. Expected: the synonym is reported, and the guide gains no candidate list.
  - **Passed 2026-10-11:** `%TEMP%\d244`, two fresh `claude -p` runs. Both skipped the round, reported User/Account
    as a possible synonym for `/domain`, and left `AGENTS.md` without a candidate list. The brief said only that the
    run was unattended. The runner holds the installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-244` — leave empty until then._

## Outcome

**The fix.** `adopt-project`'s `INFER.md` had a gap in its threshold table: 80%+ across 3 or 4 files matched no
row. The table is now five ordered rows where the first match wins. Row 4, 80%+ across 3 or 4 files, **asks**: the
shape is consistent, but the sample is too small to call it a rule. The glossary rule said to record candidates in
the guide unconditionally, which contradicted the skip path's "write nothing" and *propose, never assert*.
Candidates are now written only when a round runs and the user confirms the list. Otherwise they are reported only.

**Step 6 split, stated exactly because it is weak.** Before the fix, both runs on the same fixture also left the
guide alone: the skip-path paragraph won over the unconditional sentence. So the drill is a **contract pin, not
evidence**. The threshold gap is not observable on a skip-path fixture, and was checked by walking the table
(test plan step 1). The fix rests on removing two contradictions in the text.

**Judgement calls.**
- *3–4 consistent files ask rather than propose or stay silent.* Proposing would assert a rule from a sample a
  rename could flip. Silence would drop real evidence. Asking costs one line in a round that is already running.

**Flagged, not fixed.** Nothing new. One fixed run noticed the fixture breaks its own "one test per module"
rule, which is fixture noise.

## Progress log

- step 2 — picked; ranked above TASK-245 because the adopter writes glossary candidates into a consumer's rulebook unconfirmed on the path that promises to write nothing (key 1: an unasked write into another repo's guide; key 3: it reads as an agreed convention), reached on every adoption whose rulebook already covers the inferred rows (key 2), and both gaps sit in one file (key 4); TASK-245's verify-conventions contradictions are internal. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. The three rows leave 80%+ over 3–4 files unmatched; § *Glossary candidates* writes to the guide unconditionally while § *When the rulebook already answers it* says the skip path writes nothing and reports candidates only
- step 4 — layer: local (`skills/adopt-project/INFER.md`)
- step 5 — fix in `skills/adopt-project/INFER.md`: five ordered threshold rows, first match wins, row 4 (80%+ over 3–4 files) asks; glossary candidates written only after a round's confirmation, reported only otherwise. Lint green; drill 2/2 on `%TEMP%\d244` plus a table walk
- step 6 — reverted: pre-fix 2/2 also wrote no candidates on the skip path. Contract pins only; fix-dependent = none observed; threshold gap checked by table walk. The fix rests on removing the two contradictions
- step 7 — respecced project-baseline (threshold requirement: the ordered table; glossary requirement: written only on a confirmed round; scenario "Candidates on the skip path are not written"); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
