---
id: TASK-371
parent: STORY-013
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
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

- [ ] DV7's in-repo baseline is `/specs verify`'s rule, stated by pointing at it, not restated, so the two checks
      agree on every spec
- [ ] Run on this repo, DV7 flags no spec whose every source commit since its stamp also changed the spec
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Respeccing the genuinely stale specs: TASK-372 and TASK-359
- DV7's external-repo branch (`source-commits`)

## Human test plan

- [ ] Re-run `/feature status` (all features) on a fresh clone of this repo with `skills/` at the fix, using a cold
      runner. Expected: the drift note lists DV7 only for specs a source commit has changed without changing the spec

## Implementation plan

_Populated by `/tasks plan TASK-371` — leave empty until then._
