---
id: TASK-287
parent: STORY-026
feature: FEATURE-004
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen` flags a requirement it writes or rewrites past ~500 characters

## Context

FEATURE-004 D1. Measured 2026-10-08: 131 of the 383 requirements in `docs/specs/` run past 500 characters, the longest at 1,576. OpenSpec v1.14.1 warns past 500 and fails under `--strict`. The owner chose to flag only what a regen writes or rewrites, and never to split untouched requirements, so the spec diff stays reviewable.

## Acceptance criteria

- [x] Regen flags each requirement it adds or changes whose statement exceeds the threshold, and suggests a split — `regen` step 4: the statement (heading to first scenario) past 500 characters, with a suggested split
- [x] An untouched requirement is never flagged, so the flag never pushes against the stable-wording rule — stated with its reason
- [x] The threshold and the reason for it are stated once, in the verb that owns them — in `regen` step 4 alone
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- Splitting existing long requirements in bulk (out of scope for FEATURE-004)

## Human test plan

- [x] Drill: install the changed skill and run `/specs regen <area>` on a real area of this repo, or on a fixture spec staged to exercise the change. Record how the runner was obtained (AGENTS.md § Testing); a long new requirement is flagged, and a long untouched one is not
  - **Passed 2026-11-15**, three cold runners: `claude -p --disable-slash-commands --permission-mode acceptEdits`, each
    cwd holding only `brief.txt`, `skill/specs` at the fix and a fixture cloned from d349's `mapped/` with a 620-character
    `Division` requirement added; each report says no skills were loaded.
    - `%LOCALAPPDATA%/Temp/d287` (code adds `clamp`, `Division` untouched): `Division` not flagged; `Clamp` written at
      ~250 characters, so nothing flagged.
    - `d287b` (div changed in two behaviours): the runner rewrote `Division` to 493 characters, under the threshold.
    - `d287c` (div changed in one clause, so stable wording keeps the rest): `long requirement: "Division" — 660
      characters; consider splitting into quotient rounding (Euclidean), divide-by-zero panic, MIN / -1 overflow
      panic, and no rounding/saturation/wrapping`.
    The flag is not among any runner's undecided points; d287b asked how characters are measured (trimmed text),
    recorded here only.

## Implementation plan

Not planned: one file (`regen` step 4), four criteria, no unknowns.

## Outcome

**What was built:** `/specs regen`'s review flags a requirement it adds or changes whose statement runs past 500
characters, with a suggested split, and never flags one it leaves untouched (FEATURE-004 D1).

**Judgement calls:**
- The statement is measured from the heading to the first scenario, so scenarios never count toward it.
- The flag informs and never blocks acceptance: a long statement is a reading problem, not a wrong one.

**Close gate (inline; one skill file, one spec):** standards and intent met; correctness by d287/b/c; layer parity,
security, comments not applicable; local lint passes; specs-from-code gained the requirement and a scenario.

## Progress log

- picked 2026-11-15 in FEATURE-004's build (user's order: 289 and 287 first)
- built in skills/specs/verbs/regen.md step 4; drilled d287 (untouched not flagged), d287b (rewritten under 500), d287c (flagged); closed inline
