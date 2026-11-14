---
id: TASK-371
parent: STORY-013
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
picked-by: fix-next
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-067-3]
pr: null
github-issue: null
jira-key: null
---

# `/roadmap`'s DV7 measures staleness from `generated-at` alone, where `/specs verify` takes the spec's own commit

## Context

Found 2026-11-13 at TASK-067's close. Two cold runs of `/feature status` on a clone of this repo
(`%LOCALAPPDATA%/Temp/d067r`, `report-run1.md` and `report-run2.md`) both rendered a drift note listing **13 of 15**
spec areas as DV7-stale.

**The two checks answer one question with two baselines:**
- [[roadmap]]'s DV7 measures "a spec's `sources` changed since its baseline — `generated-at` for in-repo sources".
- `/specs verify` (`skills/specs/verbs/verify.md`, step 1) takes the **later** of `generated-at` and `SPEC_COMMIT`,
  the spec file's own last commit, when the stamp is its ancestor, and "equal dates take `SPEC_COMMIT`".

**A spec respecced in the same commit as its source change is therefore fresh to `verify` and stale to `roadmap`.**
Its stamp names the commit before the one that changed both. Counted against git on 2026-11-13: of the 13 flagged,
**8 have no source commit since their stamp that did not also change the spec**. They are fresh under `verify`'s rule
and reported stale only by DV7. The other 5 are genuinely behind (TASK-372, TASK-359).

The cost is the one DV7's own text names: a check that reports most of the tree as stale gets read past, and the 5
real ones are buried among 8 false ones.

## Acceptance criteria

- [x] DV7's in-repo baseline is `/specs verify`'s rule, stated by pointing at it, not restated, so the two checks
      agree on every spec
- [x] Run on this repo, DV7 flags no spec whose every source commit since its stamp also changed the spec
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Respeccing the genuinely stale specs: TASK-372 and TASK-359
- DV7's external-repo branch (`source-commits`)

## Human test plan

- [x] Re-run `/feature status` (all features) on a fresh clone of this repo with `skills/` at the fix, using a cold
      runner. Expected: the drift note lists DV7 only for specs a source commit has changed without changing the spec
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d371` (`claude -p --disable-slash-commands`, runner listed
    no skills). The index drift note went from 16 findings to 6: DV7 on feature-lifecycle, glossary-and-adrs,
    idea-interrogation, specs-from-code and test-authoring, and FEATURE-005's DV8. The runner measured from the later
    of each stamp and the spec's own commit, as § 2b now points it to.

## Implementation plan

_Populated by `/tasks plan TASK-371` — leave empty until then._

## Outcome

**The fix.** [[roadmap]] § 2b no longer restates the staleness diff from `generated-at`. It points at `/specs verify`'s
canonical definition and names its in-repo anchor (the later of the stamp and the spec's own commit). The DV7 row names
the same anchor. The two checks now agree on every spec: at HEAD, 5 stale under both, where DV7 used to flag 15.

**Step-6 split.** Text assertions: the `generated-at`-only phrasings match twice at HEAD and never at the fix. Behavioural,
by the d371 drill under Human test plan.

**Judgement call.** The anchor is named in one clause rather than only pointed at, because the restated diff was what
misled the runners. A pointer with the one fact that differs from the obvious reading is still a pointer.

**Close gate (inline, one file of skill text plus one spec sentence):**
- **Standards:** defer-to-the-owner is now true in fact, not only in wording.
- **Intent:** all three criteria met.
- **Correctness, security, comments:** not applicable beyond the drill.
- **CI:** the local lint passes.

**Flagged.** TASK-373, filed: five `/feature status` rendering choices that three runners each named undecided.

## Progress log

- step 2 — picked; ranked above TASK-370 and the older P2s because it is a silent wrong result (a plausible stale list) on every dashboard drift note, verified by hand against git at TASK-067's close, and fixable in one place (roadmap § 2b and the DV7 row) with no open question
- step 3 — verified: at HEAD, diffing from `generated-at` flags 15 of 15 spec areas; `/specs verify`'s anchor flags 5 (feature-lifecycle, glossary-and-adrs, idea-interrogation, specs-from-code, test-authoring), exactly TASK-372's four and TASK-359's one
- step 3b — planned inline: roadmap § 2b's parenthetical restated the diff from `generated-at`; replace it and DV7's row with a pointer to verify's canonical definition, anchor named
- step 4 — layer: local
- step 5 — fix in skills/roadmap/SKILL.md (§ 2b and the DV7 row)
- step 6 — text: old phrasings 2 at HEAD, 0 at fix; behavioural: d371, drift note 16 → 6, exactly the genuinely stale specs plus DV8
- step 7 — respecced project-roadmap (the collection requirement names the anchor), restamped; no unspecced source change since its stamp
- step 8 — closed inline; commit in git log
