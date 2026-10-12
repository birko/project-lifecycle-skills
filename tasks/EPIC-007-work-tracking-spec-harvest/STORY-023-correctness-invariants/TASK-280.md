---
id: TASK-280
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
findings: [SH-120, SH-121, SH-122]
pr: null
github-issue: null
jira-key: null
---

# `improve-architecture`: the item 4 gate maps no result, and a held move whose ADR is gone has no outcome

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-120 (partly confirmed):** `Item 4: <n> implementation(s) — <result>` maps to neither candidate nor rejected. interface-design item 4 implies the mapping (one implementation: collapse it; two or more, including a test double at a boundary: a real seam), but the skill never states it.
- **SH-121:** Step 1 skips superseded and retired records, but Step 6 recomputes every `held by ADR` entry. A held entry whose ADR has since been superseded or retired has no defined outcome.
- **SH-122 (partly confirmed):** class 5 maps to the `docs-i18n-coverage` theme with no stated reason, while interface-design calls its signal an interface defect. Arguable, not wrong, but fix-next ranks that theme last.

## Acceptance criteria

- [x] Step 5 maps each item 4 result to candidate or rejected, as the deletion test's table does
- [x] Step 6 states what happens to a held entry whose ADR is superseded or retired
- [x] Step 7 states why class 5 takes its theme, or moves it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The records line (TASK-279)

## Human test plan

N/A: mapping tables, checked by reading against `skills/tdd/interface-design.md` item 4.

## Implementation plan

_Populated by `/tasks plan TASK-280` — leave empty until then._

## Outcome

**What changed.** Three places in `improve-architecture` left a finding's fate to each run's reading:
- **Item 4 now has a mapping table** (Step 5). One implementation, with no test double at a system boundary, is a
  **candidate**: depend on the concrete type, or return the result instead of a callback. Two or more, with a
  boundary test double counting as one, is **rejected** as a real seam. A mock of an internal collaborator does
  not count. A result outside the table is reported by its own name and left undecided, as the deletion test's
  table already did.
- **A hold whose ADR is gone is released** (Step 6). When the ADR a `held by` entry names is superseded or
  retired, the run reports `hold released: <key> — ADR NNNN superseded by MMMM | retired (since <commit>)`. If the
  superseding record also contradicts the move, Step 6 is applied to that record instead. Otherwise the move goes
  through Step 5's gate. The old hold is never carried forward.
- **Class 5 moves to `correctness-invariants`** (Step 7), and the reason is stated. Item 5 calls the signal an
  interface defect, which is a broken architectural rule fixed in place, while `docs-i18n-coverage` covers
  audits that spawn work. This raises class-5 findings in fix-next's ranking, because that theme's row was last.
- Respecced `code-shape-review`: the gate requirement (item 4 mapping), the decision-records requirement (hold
  release), and the filing requirement (class 5 theme, with its reason).

**Step-6 split.** Both runs were cold drills (`claude -p --disable-slash-commands < brief.txt`, run from
`C:/Source/WebChecker`, both `SKILLS-SEEN: none`) on one brief with four situations. The brief carried the skill
from `HEAD` (before) or from the working tree (after), plus `tdd/interface-design.md`, and did not say what was
expected.
- **Item 4, `INotifier`, mocked in tests:** rejected both times. Both runners counted the mock as a boundary
  double. My fixture was ambiguous about whether email is the boundary, so this case tested nothing.
- **Item 4, `IClock`, with a `FakeClock`:** rejected both times. The old runner derived the mapping from item 4
  unaided.
- **Hold under a superseded ADR:** the old runner invented a `not carried forward: … superseded …` line and
  flagged the gap. The new runner used the stated `hold released: …` line.
- **Class 5 theme:** `docs-i18n-coverage` "with no stated reason" before the fix, `correctness-invariants` with the
  reason after.

So **2 of 4 cases depend on the fix** (the hold release and the theme). The two item-4 cases are contract pins:
they show the new table agrees with what a careful reader already concluded, which is evidence the mapping is
right but not that the old text failed. The lint is a contract pin too.

**Judgement calls.**
- **Moved class 5 instead of only explaining it.** The criterion allowed either. The ladder row it sat in
  describes a different kind of finding, so explaining that placement would have meant defending a mismatch.
  Moving it changes how fix-next ranks every class-5 finding, which is the point.
- **A released hold goes through the gate, not straight to candidate.** The ADR's absence removes the reason the
  move was held, not the need to judge whether the move is worth making.

**Flagged, not fixed.** The new runner noted that `(since <commit>)` in the `hold released` line does not say
which commit belongs there. The `rejected file gone` lines this copies have the same shape, so I made no change
and opened no task: if it is a defect, it is one about all three lines together.

**Merge gate (close step 5b, run inline, each verdict on its own):**
- *Standards*: pass. Item 4 owns the count, and the table only maps it, which matches the deletion test's
  pattern and the shared-inventory rule. No new cross-cutting pattern.
- *Fidelity*: pass. Criteria 1–3 are the three changes, and criterion 4 is lint OK. TASK-279's records line was
  left untouched.
- *Correctness*: no finding.
- *Security* and *Comments*: not applicable.

## Progress log

- step 2 — picked; ranked above TASK-300 because an item 4 result that maps to neither candidate nor rejected, and a held move whose ADR is gone, leave a finding's fate to each run (keys 1 and 3) with a self-contained fix, where TASK-300 carries an open design question (key 4). Key 6 not needed: both correctness-invariants
- step 3 — verified: held. Step 5 gives `Item 4: <n> implementation(s) — <result>` with no mapping to candidate or rejected, though interface-design item 4 implies one; Step 1 skips superseded and retired records while Step 6 recomputes every `held by ADR` entry with no rule for a record that is gone; Step 7 maps class 5 to `docs-i18n-coverage`, whose ladder row covers audits that spawn work, while item 5 calls the signal an interface defect
- step 4 — layer: local
- step 5 — fix in skills/improve-architecture/SKILL.md (Step 5 item 4 table, Step 6 hold release, Step 7 class 5 theme with reason); evidence is a cold drill (prose)
- step 6 — reverted fix (HEAD text, same brief, cold runner): 2/4 cases split (hold release: invented line and flagged gap vs stated form; class 5 theme: docs-i18n-coverage without reason vs correctness-invariants with it); fix-dependent = those two; contract pins = the two item 4 cases (same verdict both ways) and skills-lint.sh
- step 7 — respecced code-shape-review; requirements changed: the gate requirement (item 4 mapping), decision records (hold release), filing (class 5 theme)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
