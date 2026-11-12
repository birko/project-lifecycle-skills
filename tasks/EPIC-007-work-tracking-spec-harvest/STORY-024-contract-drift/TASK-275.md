---
id: TASK-275
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-93, SH-94, SH-96]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `domain` is told it audits ADR drift but has no pass for it, and two of its pointers are wrong

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-93:** `skills/new-project/LAYER.md`'s `docs/adr/` row says ADR drift "belongs" to `/domain`'s cross-reference pass. `skills/domain/SKILL.md:34-35` and `:52` define that pass as glossary versus code only. No pass reads ADRs, so the drift LAYER says was measured has no owner.
- **SH-94 (partly confirmed):** `:139`'s "Live instance: `0006` was withdrawn" omits `0007`, which `docs/adr/0000-retired.md` also retires, and ships this repo's history inside a generic skill. (The `0005, 0007` example at `:136` is hypothetical, which is fine.)
- **SH-96 (partly confirmed):** `:90` says "read the standing-rule paragraph below"; no paragraph has that name. The content it means is the scope check directly below (`:94-107`).

SH-93 needs a decision: either `domain` gains an ADR pass, or LAYER.md stops assigning one to it.

## Acceptance criteria

- [x] LAYER.md and `domain` agree on who checks ADRs against the code: either `domain` has a stated pass for it, or LAYER.md names no owner it lacks
- [x] The live-instance note is generic or removed, so no repo-specific history ships in the skill
- [x] `:90`'s pointer names the paragraph it means
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `domain`'s ask-steps (TASK-273) and its AGENTS.md citations (TASK-271)
- Whether `domain` should gain an ADR-drift pass at all — TASK-352, a decision

## Human test plan

N/A: wording and ownership, checked by reading LAYER.md and `domain` side by side.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Triggers: two files, four criteria.

1. **SH-93** — take the reversible half the criterion allows: LAYER.md's `docs/adr/` row says no skill audits ADR
   drift today, instead of assigning it to a `domain` pass that reads only the glossary. Keep its measurement, which
   is the reason the gap matters. Whether `domain` should gain a pass is new scope and a decision, so it is filed
   separately.
2. **SH-94** — drop the "Live instance: `0006` …" note from `domain`; the hypothetical `0005, 0007` example stays.
3. **SH-96** — the "standing-rule paragraph below" pointer names the scope check it means.
4. Respec `project-baseline` (LAYER.md) and `glossary-and-adrs` (`domain`) only if a requirement restates these.

## Outcome

**The fix.**
- **ADR drift:** `LAYER.md`'s `docs/adr/` row said ADR drift (a decision record that still has all its parts but no
  longer matches the code) "belongs" to `/domain`'s cross-reference pass. That pass reads only the glossary against
  the code, so the assignment named an owner that does nothing. The row now says no skill audits ADR drift today.
- **Repo history:** `domain` shipped this repo's own record history (`0006` withdrawn on 2026-08-22) as a "live
  instance". It is removed.
- **Broken pointer:** "the standing-rule paragraph below", which names nothing, now names the scope check it means.

**Step 6 split.** 3 of 3 assertions failed on HEAD's copies and pass on the fix, all fix-dependent. Contract pin,
**not evidence**: skills-lint passes on both.

**Judgement calls.**
- **"Nobody audits it" rather than a new pass.** The task's own Context says SH-93 "needs a decision", and the
  criterion accepts either outcome. Stating the gap truthfully is reversible and adds no scope. Adding a pass is a new
  capability whose false-positive profile needs weighing (it is a judgement over prose), so it is filed as
  TASK-352 with both arguments, and not decided here by default.
- **The measurement stays in LAYER.md** ("a cold read of seven records found three such drifts"). It is the reason
  the gap is worth stating, and the same row already carries it.
- **Layer parity:** LAYER.md is the single inventory both `new-project` and `adopt-project` read, so editing the row
  updates both, which is what the parity rule asks.
- **No spec change.** `project-baseline` and `glossary-and-adrs` restate neither the ownership claim nor the history
  note.
- **Close gate ran inline** on a ~6-line prose diff.
  - Standards: no finding.
  - Intent: all three content criteria met.
  - Correctness: the sentence first added "report it as nobody's" was trimmed, because no adoption report covers
    this content.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Whether `domain` gains an ADR-drift pass → TASK-352 (P3, a decision).

## Progress log

- step 2 — picked; ranked above TASK-065 because both leave a reader acting on a rule nobody carries out (key 1), but SH-93's ADR-drift audit is assigned to `/domain` by the shared layer inventory and performed by nothing, so its absence is silent (key 3), while TASK-065's missing state is visible in the report a runner has to improvise. Number 2 in the re-ranked order, after TASK-250 (closed). Key 6 would favour TASK-065 (`correctness-invariants`), but key 3 separated them first
- step 3 — verified: held, all three. LAYER.md's `docs/adr/` row assigns ADR drift to `/domain`'s cross-reference pass, which `domain` defines as glossary versus code only; `domain` carries "Live instance: `0006` … 2026-08-22"; "the standing-rule paragraph below" names no paragraph
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: two files, four criteria)
- step 4 — layer: local
- step 5 — fix in skills/new-project/LAYER.md, skills/domain/SKILL.md; spawned TASK-352 for the pass question
- step 6 — reverted fix (HEAD's copies): 3/3 assertions failed; fix-dependent = all three; contract pins = skills-lint (passes on both)
- step 7 — project-baseline and glossary-and-adrs: neither restates these lines; unchanged
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
