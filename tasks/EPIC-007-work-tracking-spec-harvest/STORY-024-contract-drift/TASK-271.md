---
id: TASK-271
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
findings: [SH-88, SH-91, SH-92]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Three shipped skills point at things a consumer install does not have

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-88:** `skills/populate-tests/SKILL.md:219` cites "`AGENTS.md` § *An owner verb reconciles; it does not assume*". No seed template carries that section, and AGENTS.md itself says a skill file cannot point back at it.
- **SH-91:** `skills/tdd/SKILL.md:32-33` sends the reader to "the built-in `verify`/`run` skills". There is no built-in `verify` (Claude Code lists only `run`), and pi has neither.
- **SH-92 (partly confirmed):** `skills/domain/SKILL.md:79` (§ *The five records*) and `:174` (§ *Output / prose rules*) cite sections a seeded guide does not have. `:155`'s § Conventions does exist in the seed, but in `CLAUDE.md` by default, so only the file name is wrong.

The same root cause as TASK-249 (adopt-project and LAYER.md citations), in other skills; that task's scope does not reach these.

## Acceptance criteria

- [x] No citation in `skills/populate-tests/`, `skills/tdd/` or `skills/domain/` names a guide section or a skill a consumer install lacks. Each either carries its one-clause rationale inline, or names the project's own guide generically (§ Conventions in whichever file holds it)
- [x] `tdd` names only skills that exist in both runtimes, or says which runtime a named built-in belongs to
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The same defect in `adopt-project` and `new-project/LAYER.md` (TASK-249)

## Human test plan

N/A: citation wording, checked by grepping the three skills for `AGENTS.md` and for skill names absent from `skills/`.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Trigger: three files.

Line numbers in the findings had drifted, so the citations were located by text.
1. **SH-88** — `populate-tests/SKILL.md` § *Acquiring a cold runner*: replace the `AGENTS.md` § *An owner verb
   reconciles* citation with its one-clause reason inline (a record that exists does not show that it answers the
   question).
2. **SH-91** — `tdd/SKILL.md`: name Claude Code's built-in `run` as that runtime's, and give the fallback (the
   project's own browser harness). Drop `verify`, which no runtime ships.
3. **SH-92** — `domain/SKILL.md`, in three places:
   - *Which record is which*: settle it by the question each record answers, deferring to the project guide's own list
     where it has one.
   - *When a record hardens*: the project guide's § Conventions, in whichever file holds it.
   - *Brief rationale*: state the rule inline instead of citing § *Output / prose rules*.
4. Respec `glossary-and-adrs`, which restated both `domain` citations. `test-authoring` restated neither change.

## Outcome

**The fix.** Three shipped skills sent a reader in a consumer's repository to things that install does not have:
- **`populate-tests`:** cited `AGENTS.md` § *An owner verb reconciles*, a section only this repo's guide carries.
- **`tdd`:** pointed at "the built-in `verify`/`run` skills". No runtime ships a `verify`, and pi ships neither.
- **`domain`:** cited `AGENTS.md § The five records` and `§ Output / prose rules` (absent from the seeded guide), and
  `AGENTS.md § Conventions`, where a seeded project keeps § Conventions in `CLAUDE.md`.

Each now either states its reason inline or names the project guide generically, and `tdd` names `run` as Claude
Code's with a fallback.

**Step 6 split.** 2 of 2 assertions failed on HEAD's copies and pass on the fix. Both are fix-dependent: there is no
guide-section citation a consumer lacks (4 before, 0 after) in the three skills, and `tdd` names no built-in that
does not exist. Contract pin, **not evidence**: skills-lint passes on both (it resolves `[[links]]`, not `§`
citations). This is the grep the task's `N/A` human test plan names, so the plan is satisfied by the same check.

**Judgement calls.**
- **Inline rationale over a generic pointer for SH-88 and § Output.** "See the project's guide" would point a consumer
  at a section their guide may not have either. Both reasons fit in one clause, which AGENTS.md's rule against
  pointing back at this file prefers.
- **`domain`'s five-records pointer kept a deferral**, "where the project's own guide lists its written records, that
  list wins", rather than being dropped. This repo's guide does list them, and a consumer that adopts the same table
  should have it win over the skill's short version.
- **`tdd` keeps `run`, scoped to Claude Code.** Dropping it would lose the concrete instrument where it exists. The
  criterion allows a named built-in when the runtime is said.
- **The swept-but-kept citations:** `§ Testing` (seeded in `CLAUDE.md`), `§ Conventions` (seeded), and the
  skill-internal sections (`§ Acquiring a cold runner`, `§ Prove the guard can fail`, `REFERENCE.md § Adopt`,
  [[adopt-project]] § *Glossary candidates*) all resolve in a consumer install.
- **Spec.** `glossary-and-adrs` changed in two requirements and was restamped. Its `shaped-by` was not re-derived,
  because the only intervening `skills/domain` commit (222c36d, TASK-273) is not feature-linked and its behaviour is
  already in the spec. `test-authoring` was left as it was: it restates neither changed sentence.
- **Close gate ran inline** on a ~20-line prose diff.
  - Standards: no finding. This is the rule AGENTS.md states, that a skill file cannot point back at it.
  - Intent: both content criteria met.
  - Correctness: every remaining `§` citation in the three skills resolves in a consumer install.
  - Security: not applicable.
  - Comments: not applicable.

**Flagged, not fixed.** Nothing.

## Progress log

- step 2 — picked; ranked above TASK-226 because both send a reader in every consumer install to something absent (key 1 wrong results, key 2 reachable from shipped prose), but SH-91 points `tdd` at a built-in `verify` skill that exists in no runtime, so that step is skipped without a word, while TASK-226's dangling citations are noticed by whoever follows them (key 3, silence). Key 6 did not separate them: both `contract-drift`
- step 3 — verified: held, all three (line numbers drifted; located by text). Seed `CLAUDE.seed.md` has no § *The five records*, § *Output / prose rules* or owner-verb section, and keeps § Conventions in `CLAUDE.md`; no runtime ships a `verify` skill
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (trigger: three files)
- step 4 — layer: local
- step 5 — fix in skills/populate-tests/SKILL.md, skills/tdd/SKILL.md, skills/domain/SKILL.md; every other `§` citation in the three skills swept and found resolvable in a consumer install
- step 6 — reverted fix (HEAD's copies): 2/2 assertions failed (4 consumer-absent citations → 0; built-in `verify` named → not); fix-dependent = both; contract pins = skills-lint (passes on both)
- step 7 — respecced glossary-and-adrs (surgical); requirements changed: the ADR path requirement (which record is which, settled by the question, deferring to the guide's list) and the hardening requirement (§ Conventions in whichever guide file holds it); test-authoring unchanged (restates neither sentence); intended — TASK-271's criteria. shaped-by unchanged: intervening skills/domain commit 222c36d (TASK-273) is feature: null and already specced
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
