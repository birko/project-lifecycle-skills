---
id: TASK-269
parent: STORY-025
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
picked-by: fix-next
assignee: agent
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [IA-2]
pr: null
github-issue: null
jira-key: null
---

# `adopt-project` changes with `new-project`'s LAYER.md in 19 commits, and both keep needing fixes

## Context

Filed by `/improve-architecture` (EPIC-008, author run at `30f9716`).

Candidate key: 4:skills/adopt-project/SKILL.md — IA-2

- **Files:** `skills/adopt-project/SKILL.md` (main) and `skills/new-project/LAYER.md`, in two skill folders.
- **Problem:** class 4, leaky seam, `4, co-change`. The pair changed together in 19 commits, out of 24 for `adopt-project/SKILL.md` and 33 for `LAYER.md`, and `adopt-project` reads `LAYER.md` by path, an internal reference across folders.
- **Solution:** move the logic to where the data lives, or ask the owning module for what is wanted (Step 4's class 4 move). Here: whatever `adopt-project` restates about the layer's rows (the survey states, the conditional and lazy markers) moves into `LAYER.md`, and `adopt-project` asks `LAYER.md` rather than duplicating it.

  `Gate: not a shallowness claim — 4, co-change`. **Tension to weigh first:** AGENTS.md § *Layer parity* requires a layer change to update `new-project` and `adopt-project` together, through `LAYER.md`. So co-change through `LAYER.md` is intended; co-change of `adopt-project/SKILL.md` itself is the share to remove.
- **Benefits:**
  - Leverage: not measured, because which `adopt-project` lines restate `LAYER.md` is a reading.
  - Locality: 2 → 1 files per layer change, in the 19 commits where both changed.
- **Before/after:** before, two folder frames (`adopt-project`, `new-project`) with a co-change edge labelled 19 and a reference arrow from `adopt-project/SKILL.md` to `LAYER.md`. After, the same reference arrow, and the co-change edge gone.
- **Strength:** `strong`, because fix landings in its own files corroborate a candidate raised on co-change: `LAYER.md` 24, `adopt-project/SKILL.md` 18.

## Acceptance criteria

- [x] Every rule `adopt-project/SKILL.md` restates about the layer's rows (survey states, the `(lazy)` and `(conditional)` markers) is listed in this task, and each is replaced by a pointer to the `LAYER.md` section that owns it
- [x] `adopt-project/SKILL.md` names no layer row's state or marker except through such a pointer (checked by grepping it for each marker and state name)
- [x] `bash .github/workflows/skills-lint.sh` passes

> Criteria rewritten 2026-10-06, before work started: a cold reader found "a later run no longer reports this pair" uncheckable at merge time, and the "or records why" clause let the criterion pass with no change (TASK-078's test plan).

## Out of scope

- The layer parity rule itself (AGENTS.md)

## Human test plan

N/A: a prose restructuring verified by the lint and a later run's co-change figures.

  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d269` (`claude -p --disable-slash-commands`, cwd holding only
    `skill/` at the fix, the d065b brief and a fresh copy of `d065/adopted`; the runner listed no skills). Every row's
    state matched d365's, run on the same fixture before the change: both lazy rows `not applicable yet`, `LICENSE`
    `unknown`, `.env.example` and `Dockerfile` `not applicable`, the same `missing` rows. No undecided point touched the
    removed rules.

## Implementation plan

Inline: list every restatement in `adopt-project/SKILL.md`, replace each copy with a pointer to `LAYER.md`'s state table, keep what is this skill's own.

## Outcome

**Inventory: every place `adopt-project/SKILL.md` stated a layer state or marker, and what happened to it.**

| Where | What it stated | Class | Done |
|---|---|---|---|
| step 1, bullet *When in doubt, `unknown` — never `missing`* | `unknown` over `missing`, and why | copy of LAYER.md's `unknown` row and *When in doubt, report unknown* | **removed**: the step points at the state table |
| step 1, bullet *Present but thin is `present`, with the gap named* | thin-but-present | copy of the `present, outdated` guard | **removed**; its two back-references now name that guard |
| step 1, bullet *A lazy row's absence is not a gap* | `(lazy)` ⇒ `not applicable yet`, no fill, no offer | copy of the `not applicable yet` row | **removed** |
| step 1, bullet *A conditional row's absence depends on that row's own condition* | `(conditional)` ⇒ `missing`, `not applicable` or `unknown` | copy of the `not applicable` row and § *Conditional rows* | **removed** |
| step 1, *three rows above are conditional* | a count of conditional rows | copy that goes wrong when a row is added | **reworded**: "the conditional rows" |
| step 3, *An `unknown` row is not filled* | `unknown` suppresses the fill | the step's own action, resting on LAYER's suppression | **kept**, now pointing at the table |
| step 4, `present, elsewhere` entry | never offer a second one | the report's own line, resting on LAYER's guard | **kept**, now pointing at the guard |
| step 1, *From outside you cannot see a version* | `present — <verb> answers in step 3`, `missing — <verb> creates it` | this skill's table forms | **kept** |
| § *Scoped runs* | `present, owner not asked`, the verdict line | this skill's own; LAYER.md's row points here | **kept** |
| step 1, re-run wording; step 2's round; step 3's per-state actions; step 3b; step 3c; step 4's report legend | what this run does or prints for a state | this skill's own output | **kept** |

**Criterion 2, read as checked:** every state name left in the file is LAYER.md's vocabulary, used under step 1's
pointer ("classify every artifact by the states its § *Detect what the repo has* defines"). No definition, guard or
marker rule is stated here any more without a pointer to LAYER.md. A grep for each state and marker name returns only
the kept lines in the table above.

**Also filed, not fixed:** TASK-378 (DRILL-269-1). d269 and d365 both met `/specs init`'s blessing question printing
`1 areas`, outside the count rule TASK-349 set.

**Close gate (inline; one skill file plus a restamp):**
- **Standards:** § *Defer to a shared inventory — never restate its lists*.
- **Intent:** all criteria met.
- **Correctness:** d269 against d365, row for row.
- **Layer parity:** LAYER.md unchanged; `new-project` untouched.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** project-baseline restamped with no content change, since the adopter's behaviour is unchanged.

## Progress log

- step 2 — picked; ranked above TASK-268 on key 4 (self-containment): two files in two folders against 26 files in seven; both P2 class-4 seams, neither silent nor security-relevant
- step 3 — re-verified: step 1 restated four LAYER.md rules and counted the conditional rows; STORY-025 and EPIC-008 started
- step 5 — copies removed or pointed; this skill's own forms kept
- step 6 — behavioural: d269 matches d365 row for row; TASK-378 filed from it
- step 7 — project-baseline restamped, no content change
- step 8 — closed inline; commit in git log
