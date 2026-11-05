---
id: TASK-345
parent: STORY-014
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: [TASK-128]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-128-1]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/specs init` stamps a repo with no code `unverified` because nobody blessed its empty map

## Context

Found by TASK-128's drill (2026-11-05, recorded on TASK-128, fixture `%LOCALAPPDATA%/Temp/d128z`).

**DRILL-128-1.** A repo whose five tracked files are all non-source (README, docs, `Makefile`, `pyproject.toml`, a
deploy script) wrote `areas: []` and `coverage: unverified # areas proposed but never blessed`.
`skills/specs/verbs/init.md` step 4's verdict table gives `not-applicable` for an empty scan set in a repo
with no behavioural code, and asks for no blessing; blessing is a precondition of `verified` only. But step 6
writes "the areas as § *Blessing* left them — blessed, or written unblessed and stamped `unverified`". That
applies to every map, so it overrides the table even when there are no areas to bless.

**A regression.** TASK-089's docs-only fixture reached `not-applicable` before the blessing rule (TASK-127)
existed. The runner also asked whether the scan set is measured before or after `ignore`, which the
`not-applicable` row needs.

## Acceptance criteria

- [x] A map with no areas in a repo with no behavioural code is written `not-applicable` with no blessing asked, and step 6 says so
- [x] The `not-applicable` row says whether its empty scan set is measured after `ignore`
- [x] `verified` still requires blessing
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- When step 4's reconciliation "needs the user" — TASK-127

## Human test plan

- [x] Re-run TASK-128's `d128z` drill (brief on its Progress log) with a cold runner. Expected: `coverage: not-applicable`, no blessing question. Then re-run TASK-128's last test-plan step and close it
  - **Passed 2026-11-05:** TASK-128's `d128z` brief verbatim ("Run /specs init against repo/. Give its output and the full contents of every file it wrote."), on the fixture rebuilt with `specs` copied after TASK-345: five tracked files, none code. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`. It wrote `coverage: not-applicable`, `areas: []`, `tracked-files-at-scan: 5`, `coverage-drift: []`, asked no question, and printed `No behavioural code found — wrote areas: [], coverage: not-applicable; ignored by this run: Makefile, pyproject.toml, README.md, docs/release.md, scripts/deploy.sh`. Coldness: it listed no skills

## Outcome

**What was fixed.** `/specs init` stamped a repo with no code `unverified`, "areas proposed but never blessed", because step 6 stamps every unblessed map. That overrode the verdict table's `not-applicable`, which needs no blessing. A regression from the blessing rule. Now:
- **A `not-applicable` map has no areas and nothing to bless.** It is written with `areas: []` and no question, and the confirmation names the paths the run ignored.
- **The empty scan set is measured after `ignore`,** this run's own entries included.
- **The no-code test reads every tracked file, ignored ones included,** so a broad `ignore` cannot claim the verdict.
- **`verified` still requires blessing.**

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill, which passed.

**Judgement calls.** The no-code half is judged over the whole tree, not the scan set. Otherwise the fix would let a sweeping `ignore` turn real source into `not-applicable`, the opposite failure.

**Review (close step 5b, inline).** Adherence: no question was added, and the run's own judgement stays visible as paths. Fidelity: all four criteria are met. Correctness: the edge case no longer says "(or nothing)" against step 6's "always write".

**Flagged, not fixed.**
- When step 4's reconciliation "needs the user" is still undefined (TASK-127). Read as "always ask", the no-answer path would make `not-applicable` unreachable whenever a housekeeping file is tracked.
- Step 7's harvest offer is unconditional, though a map with no areas has nothing to harvest.

## Implementation plan

### Steps
1. Step 4's `not-applicable` row: the scan set is measured **after `ignore`**, counting this run's own reconciliation entries. The no-code half is judged over every tracked file, ignored ones included, which is what stops a broad `ignore` from claiming the verdict. Line 71's one question is asked of the whole tree.
2. Step 6 and § *Blessing*: a `not-applicable` map has no areas and nothing to bless, so it is written with `areas: []` and no blessing question. The confirmation names the paths the run ignored, keeping its own judgement visible. "Blessing is a precondition of `verified`" is unchanged, plus "`not-applicable` needs none".
3. The edge case says what is written (`areas: []`, `coverage: not-applicable`, the other two keys), no longer "a minimal map (or nothing)", which contradicted step 6's "always write".
4. Spec `specs-from-code`: Init ends with exactly one coverage verdict (+1 scenario: sources swept into ignore are `unverified`; the docs-only scenario updated), and Blessing gates writing a verified map (no question on `not-applicable`).

### Risks
- A wrongly broad `ignore` is caught only if the runner reads the ignored files; the rule says it must.

## Progress log

- step 2 — picked; ranked above TASK-028 because key 1: every repo with no code gets a wrong verdict (`unverified` for `not-applicable`), silently; key 5: drill-verified (d128z); it also blocks TASK-128
- step 3 — verified: held. init.md step 6 writes "the areas as § Blessing left them — blessed, or written unblessed and stamped `unverified`" for every map, overriding step 4's table row for `not-applicable` (empty scan set, no behavioural code, no blessing named)
- step 3b — planned: /tasks plan --no-grill (four criteria); no split signal
- step 4 — layer: local
- step 5 — fix in skills/specs/verbs/init.md (the not-applicable row measured after ignore with the no-code test over the whole tree; line 71; step 6's exception; § Blessing's no-areas paragraph; "not-applicable needs none"; the edge case's written map); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill
- step 7 — respecced specs-from-code; requirements changed: Init ends with exactly one coverage verdict (+1 scenario, docs-only scenario updated), Blessing gates writing a verified map; intended — TASK-345's criteria
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
