---
id: TASK-249
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-64, SH-68]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# The adopter's files cite rules a consumer does not have, and miscount their own buckets

## Context

Found by the project-baseline spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second
reader against the files at `adc4c27`.

- **SH-64 — citations that dangle in a consumer install (partly).**
  - `adopt-project/INFER.md` cites "AGENTS.md § *The five records*".
  - `new-project/LAYER.md` cites "`AGENTS.md` § *A template ships nothing a render cannot make true*".
  - In four more places, LAYER.md points at a rule "in the consuming project's guide" (derived state never cached;
    read the declaration, never infer it).

  No seed template carries any of these, so for a scaffolded repo "the consuming project's guide" is false. Every
  citing site still states its operative instruction inline, so nobody needs the cited rule to act. This is a reader
  trap, not a broken instruction.
- **SH-68 — count.** `adopt-project/SKILL.md` § 4 says "Three buckets for what this run **did**" and "the three
  above". The table has four: created, amended, left alone, regenerated.

## Acceptance criteria

- [x] No citation in `skills/adopt-project/` or `skills/new-project/LAYER.md` sends a consumer to a guide section their install does not carry. Each one either names this skill set as its source or carries the one-clause rationale inline
- [x] § 4's bucket count matches its table, or the count is dropped
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- LAYER.md's survey-state list and its stale TASK-112 pointer (TASK-085)

## Human test plan

N/A — reference and count text, checked by grepping both skills for `AGENTS.md` and "consuming project's guide".

## Implementation plan

_Populated by `/tasks plan TASK-249` — leave empty until then._

## Outcome

**The fix.** The adopter's and LAYER.md's prose no longer sends a consumer to guide sections their install does not
carry. Six citations were changed:
- **Two named `AGENTS.md` sections** (*The five records*, and *A template ships nothing a render cannot make true*).
- **Four that pointed at a rule "in the consuming project's guide"** (*a derived state is never cached as a
  decision*, twice; *read the declaration, never infer it*, twice).

**What each became.** Each now carries its one-clause reason inline, and the operative instruction beside it is
unchanged. None of these rules is in `new-project`'s seed templates, so for a scaffolded repo the pointer led
nowhere.

**The count.** § 4 now reads "Four buckets" and "the four above", matching its table (created, amended, left alone,
regenerated).

**Step-6 split.** Not a behaviour change. The check is the plan's grep: `AGENTS.md §` and "consuming project's guide"
now appear nowhere in `skills/adopt-project/` or `skills/new-project/LAYER.md`. The two `AGENTS.md § Conventions` hits
left in `skills/` are `verify-conventions`' sample report lines naming a repo's own rulebook, not citations.

**Judgement calls.**
- **Inline reasons, not "this skill set's AGENTS.md says".** A consumer cannot open this repo's guide either, so a
  re-pointed citation would dangle the same way. The reason is short enough to carry.
- **The count was corrected, not dropped.** TASK-353's d353 runner also tripped on "three buckets" heading four.

**Close gate (inline, 8 sentences over three files):**
- **Standards:** no restatement of a list; each site keeps one clause.
- **Intent:** criteria met.
- **Correctness:** none found.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

## Progress log

- step 2 — picked; contract-drift (theme 4), ranked first of what remains because it reaches every consumer install: a guide citation no consumer has (key 1 wrong reference, key 2 every adoption), and it is self-contained (key 4)
- step 3 — verified: held; six citations, none carried by new-project's seed templates, and § 4's count says three over four rows
- step 3b — not planned: wording in three files
- step 4 — layer: local
- step 5 — fix in adopt-project/INFER.md (one citation), new-project/LAYER.md (five), adopt-project/SKILL.md (the count)
- step 6 — grep check per the plan: no `AGENTS.md §` or "consuming project's guide" left in either skill
- step 7 — no spec change: no spec states these citations or the bucket count
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
