---
id: TASK-265
parent: STORY-007
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: verify
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Rung 2 does not say whether a candidate outside the hot spots is raised, so two runs of one repo differ

## Context

Found while doing **TASK-263**, by its two cold runs on one `ClientApi.CSharp` clone (2026-10-06). Step 3's rung 2
scopes a run to "the hot spots from Step 2, examined first". Three cold readers read that three ways:

- **TASK-077's reader** read "first" as not exclusive, followed the co-change pairs outward, and found a class 1
  candidate (the CLI tester project files' shared build block) outside every hot spot.
- **TASK-263's run 1** did the same ("then repo-wide co-change pairs and fix landings") and raised that candidate.
- **TASK-263's run 2**, on the same repo with no change to those files, examined only the five hot spots, and did
  not raise it.

So one repo, scanned twice, produces different candidate lists, and the difference has nothing to do with the
code. Step 2 measures co-change pairs and fix landings over the whole repo whatever the rung, which makes the
"examined first" reading plausible; the word "first" implies a second, which the step never names.

## Acceptance criteria

- [ ] Rung 2 states whether candidates outside the hot spots are raised, and if they are, in what order they are reported relative to those inside
- [ ] The rung's header line in the report says which reading applied, so a reader can tell a hot-spot-only run from a wider one
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Rungs 1 and 3, which are unambiguous
- The candidate key and the re-check (TASK-263)
- Deferred to TASK-266 — classes 1 and 4 both fire on co-change across modules, and nothing says which wins

## Human test plan

- [ ] Two cold runs on one unchanged scratch clone produce the same candidate keys, including any candidate outside the hot spots — ⚠ NOT MET YET: the scope now matches exactly, but the keys still differ on a class 1 / class 4 overlap (→ TASK-266); re-drill after it

## Implementation plan

Drafted inline at pick, 2026-10-06. The choice is settled by the evidence on TASK-263 and TASK-077.

1. **Rung 2 has two tiers, both fixed lists:**
   - **first, the hot spots;**
   - **then every file outside them** that is in a co-change pair or touched by a fix landing. Step 2 already measures both over the whole repo, so the tier is a list, never a judgement.

   Two of the three cold readers read "examined first" this way unprompted, and it is what found the strongest class 1 candidate (6 → 1 files per change). Hot-spots-only was rejected: it discards measured evidence Step 2 already paid for, and the "change is coming" argument covers co-change too.
2. **Order:** in the report, candidates from the second tier are listed after the hot-spot ones, and are still keyed. This is a sort on the tier, not a ranking: strength and priority are untouched.
3. **Header:** names both tiers and their sizes (`hot spots: …; then N files from co-change pairs and fix landings`), so a reader can see the scope.
4. **Drill:** two cold runs on one unchanged clone; their candidate keys must match, including any second-tier candidate.

## Progress log

- 2026-10-06 — Picked; plan drafted inline. Rung 2 now has two fixed tiers: the hot spots, then every file outside them that is in a co-change pair or touched by a fix landing. The header names both, and the listing is by tier, then key. Lint OK.
- 2026-10-06 — **Drill: two cold runs in parallel** on the unchanged `%TEMP%/d077` (`claude -p --disable-slash-commands …`, separate output directories; both listed no skills).
  - **The scope now matches exactly:** both runs scanned the same five hot spots and the same `11 files from co-change pairs and fix landings`, and both raised a second-tier candidate on `Tester/SK/ApiDailyDiffTester/ApiDailyDiffTester.csproj`. That is this task's fix working.
  - **The keys still differ, for two reasons outside this task's criteria:**
    1. **The same file got a different class:** run A said class 4, run B class 1, so the keys are `4:…` versus `1:…`. Classes 1 and 4 both fire on co-change across modules, with no precedence; the TASK-076 and TASK-263 readers hit the same overlap. → TASK-266.
    2. **Reader recall:** run A raised `4:…CommonAbstractClient.cs#ComputeVerificationHash` and run B did not. Candidate recall varies between readers; that is inherent judgement, recorded and not legislated.
  - The test step stays unticked, and the task parks at `verify` until a re-drill after TASK-266.
