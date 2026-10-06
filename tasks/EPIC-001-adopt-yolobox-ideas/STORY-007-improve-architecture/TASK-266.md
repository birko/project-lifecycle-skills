---
id: TASK-266
parent: STORY-007
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
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

# Classes 1 and 4 both fire on co-change across modules, so one finding gets two different keys

## Context

Found while doing **TASK-265**, by its two parallel cold runs on one unchanged `ClientApi.CSharp` clone
(2026-10-06). The same co-changing files, the CLI testers' project files that share one build block, were raised
as **class 4** (leaky seam) by one run and **class 1** (concept scatter) by the other. The class is the first part of
the key (`<n>:<path>`), so the two runs' keys differ, and a later run cannot match the finding to an earlier one.

It is the third reader to hit this. TASK-076's drill reader and TASK-263's run 1 both listed it among their
guesses ("Class 1 versus class 4": raised class 1, rejected the class 4 versions as `signal fails`).

The overlap is in `skills/improve-architecture/SKILL.md` Step 4's table:
- **class 1** is "following one use case touches four or more files, each adding a few lines, and those files
  form co-change pairs";
- **class 4** is "a co-change pair that crosses a module boundary, or one module reading another's internals".

A set of four or more co-changing files across projects satisfies both, and nothing says which wins.

## Acceptance criteria

- [x] Step 4 states which class a candidate takes when both signals hold, so one set of files always gets one class
- [x] The rule is decidable from what Step 2 and Step 4 already collect, not a fresh judgement per run
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Reader recall: a candidate one cold reader finds and another misses. That is judgement, not a definition gap
- Rung 2's scope (TASK-265)
- Deferred to TASK-267 — whether a candidate concerns one member is still a judgement, so the `#<member>` suffix varies between readers

## Human test plan

- [x] The re-drill TASK-265 is parked on (two cold runs, one unchanged clone) gives the testers' shared build files the same key in both runs

## Implementation plan

Drafted inline at pick, 2026-10-06: a single precedence rule in Step 4, decided by data the pass already collects.

1. **When a co-changing set fits both classes, the dependency decides.** If any file in the set is among another's callers (Step 4's callers set), the change follows a dependency across a seam, so it is class 4. Otherwise the same edit is repeated in independent places, so it is class 1. The testers' copied build block, where no project calls another, is class 1.
2. **The set's main file** is its most-touched file in Step 2's window, ties broken by path order. This pins the key's path, which one earlier reader had to guess.
3. **Drill:** the same two-run re-drill that TASK-265 is parked on.

## Progress log

- 2026-10-06 — Picked; plan drafted inline. The first rule was "the dependency decides; the main file is the most-touched one".
- 2026-10-06 — **Re-drill 1, two cold runs in parallel on `%TEMP%/d077`:** both gave the testers' build files `1:Tester/SK/ApiDailyDiffTester/ApiDailyDiffTester.csproj`. Their other keys differed only by recall.
- 2026-10-06 — **Close gate on the first rule:**
  - **Standards:** pass. One note: "path order" was unspecified.
  - **Fidelity:** criterion 2 was **partly wrong**: the per-file dependency was not collected data.
  - **Correctness:** 6 findings. The dependency data was not collected; incomplete callers were unhandled; the main file drifted as the window slid; the rule contradicted the module definition; "set" was undefined and 2–3-file sets had no rule; the gate never re-checked the class.
- 2026-10-06 — **Redesigned** as a decision table:
  - **The set:** a co-change set is the transitive group of Step 2's pairs, and each set collects its *internal references*.
  - **The class:** module boundary first, then the reference. One module with four or more files is class 1, and fewer is not a candidate. Across modules with a reference is `4, co-change`. Across modules with none is class 1 at four or more files; fewer is duplicated code, not a candidate.
  - **The main file:** first path in `git ls-files` order.
  - **An unknown reference** counts as none, and makes the candidate `tentative`.
- 2026-10-06 — **Re-drill 2, two cold runs, same clone:** both put the co-changing project files, the testers' build files included, in one set keyed `4:FinStatApi/FinStatApi.csproj` (it has internal references). Both scanned the same scope, and three candidates matched key for key. The remaining differences:
  - `ResponseItem.cs` keyed with and without `#BasicResponse` → TASK-267;
  - one run raised `4:…CommonAbstractClient.cs` and the other did not: recall.
- 2026-10-06 — **Re-check of the redesign:** five of six earlier findings fixed and #2 mostly. New leftovers, all fixed:
  - Step 4's class table now points at the decision table (rows 1 and 4);
  - class 1's move fits a single module;
  - the slot of a co-change set is every other file of the set;
  - reading storage or config counts as a reference, and such a set is raised once, never again as `4, internals`;
  - "never changes a key" is restated as a limit: set membership comes from the window, and only the ordering is fixed;
  - "path set" is disambiguated;
  - stale trace mentions are gone.

  These final edits do not change re-drill 2's key for the build files, a set with internal references either way. Security and comments are not applicable. Out of scope (5d): 2 boundaries, 1 spawned (TASK-267).
