---
id: TASK-256
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `adopt-project` adds the seed's missing sections with their tokens unrendered

## Context

Spawned from TASK-242 (2026-10-04), which fixed this defect in [[new-project]] (SH-70) and found the same one
through the other door.

`skills/new-project/LAYER.md`'s agent-guide row tells the adopter to **"Merge by section. Add missing `##`
sections"**, and § *Matching a guide's sections* takes the inventory from `templates/CLAUDE.seed.md`'s own headings.
Two of those sections carry a token as their whole body: `## Architecture` (`{{ARCHITECTURE_NOTES}}`) and
`## Commands` (`{{BUILD_RUN_COMMANDS}}`), each with an `<!-- e.g. … -->` hint under it. Nothing in
`skills/adopt-project/` (SKILL.md, INFER.md) says how to fill a section it adds, so a repo whose guide lacks either
section gets the token and the hint verbatim. An adopted repo already *has* code, so both have a real source, its
build files and structure, which makes leaving them unrendered the less excusable case.

TASK-242's fix is in `new-project/SKILL.md` step 5 (a table of each token's source and its no-source outcome, then a
grep for `{{`). That is the scaffolder's own step, so the adopter does not inherit it.

## Acceptance criteria

- [x] When the adopter adds a seed section carrying a token, the token is filled from evidence in the repo or the section states plainly that nothing was found — never shipped unrendered, and never filled by a guess
- [x] The hint comments under those tokens never reach an adopted repo
- [x] The rule is stated once and shared, not copied: either the token table moves where both front doors read it (`LAYER.md`), or the adopter points at the scaffolder's
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The scaffolder's side (TASK-242)
- The `## Conventions` block, which the adopter fills through `INFER.md`

## Human test plan

- [x] Run `/adopt-project` from a cold runner on a repo whose guide has neither `## Architecture` nor `## Commands`, then grep the guide for `{{`. Expected: none, and both sections say something true about the repo or say plainly that nothing was found

## Implementation plan

Decided at step 4, before any edit (`/fix-next` runs no `/tasks plan`, TASK-135).
1. Take the criterion's first exit: move new-project step 5's token table into `skills/new-project/LAYER.md` as one section both front doors read, with a scaffolder column, an adopter column and a no-source outcome per token. The two doors have different evidence (a skeleton just written vs a repo that already has code), so one source column cannot serve both.
2. Pull in the third token with the same root cause: `{{STAKEHOLDERS}}` sits in the seed's `## How we work`, which the adopter can also add.
3. new-project step 5 points at the moved table and keeps its grep; `adopt-project` step 3 gains one bullet pointing at it, with its own grep; the LAYER guide row says added sections are rendered.
4. Respec `project-scaffolding` (or whichever area maps these files), then a cold drill of an adoption on a guide missing both sections, run on the old and the new text.

## Outcome

- **The fix:** when `/adopt-project` adds a section the agent guide is missing, it now fills every placeholder in it from what the repo holds, or writes a fixed "nothing found" line, and deletes the template's hint comment. Previously nothing said how to fill one, so `{{ARCHITECTURE_NOTES}}`, `{{BUILD_RUN_COMMANDS}}` and `{{STAKEHOLDERS}}` could ship raw. The token table now lives once, in `LAYER.md` § *Filling a seed section's tokens*, with a column per front door; `new-project` step 5 and `adopt-project` step 3 both point at it.
- **Step-6 split:** on the second drill pair, hint comments: old 1 leaked, new 0; raw tokens: 0 in both (the old runner filled them unprompted). Fix-dependent: the hint-comment check. Contract pins, not evidence: the token grep and the lint. **The filed symptom (raw tokens) was not reproduced by a cold runner**, so its closure rests on the rule, not on a failing-then-passing drill. The human test plan's expectation (no `{{`, both sections true) held on the new text. The drill ran before the review fixes below; those only narrow the grep and rename a column, and change nothing on that fixture.
- **Judgement calls:** the criterion's first exit (move the table) was taken over pointing the adopter at the scaffolder's table, because the scaffolder's sources (a skeleton just written, a scope grill) do not exist in an adopted repo; a pointer would have handed the adopter sources it cannot read. `{{STAKEHOLDERS}}` was pulled in as the same root cause (it sits in `## How we work`, which the adopter can add). The adopter's stakeholders no-source value reads clumsily mid-sentence (`rollup for stakeholders not yet named:`), accepted because it reads as unresolved, which is the point.
- **Flagged, not fixed:** nothing. `new-project` step 3's two earlier lines that name which tokens wait for step 5 are pre-existing and agree with the table.
- **Close gate (step 5b), each axis on its own:**
  - **Correctness:** one blocking defect, fixed: the adopter grepped the whole guide for `{{`, so a repo whose own guide documents a template engine would have its sections flagged and, to clear them, edited; the grep is now scoped to the sections the run added (LAYER, adopt-project, spec). Two minor, fixed: step 3's copy rule allowed deleting only `e.g.` hints while the Architecture hint is not one (now "the hint comment"); step 5 said "four tokens" without naming them.
  - **Standards:** warn, no blocker. Fixed its one warning: naming the four tokens in step 5 restated the table's list, so the table's scaffolder column now names the step that fills each row and step 5 points at the `step 5` rows. This also settles correctness's "four tokens" point without a copy. Two infos accepted: the grep rationale restated as a load-bearing invariant; the stakeholders wording above.
  - **Fidelity:** pass. Its whole-guide grep finding was the correctness blocker, already fixed; its "two homes for the stakeholders default" note is a pointer, accepted.
  - **Security / comments:** not applicable.
  - **Out of scope (5d):** 2 boundaries (the scaffolder's side, TASK-242, done; the Conventions block, owned by `INFER.md`), 0 spawned.

## Progress log

- step 2 — picked; ranked above TASK-253 because it writes wrong content into a consumer repo's agent guide (key 1: a write, above TASK-253's wrong gate result), reached from any `/adopt-project` on a guide lacking `## Architecture` or `## Commands`. Key 6 inert: both declare `correctness-invariants`.
- step 3 — verified: held, and wider. `LAYER.md`'s guide row says "Add missing `##` sections" and nothing in `skills/adopt-project/` says how to fill one. The seed's `## Architecture` and `## Commands` are a bare token plus a hint comment, and `## How we work` carries `{{STAKEHOLDERS}}` twice, so the same defect reaches a third token; pulled in (same root cause, same function). The `## Conventions` tokens stay out (INFER fills them, per Out of scope).
- step 4 — layer: local (the rule is missing from the shared inventory both doors read).
- step 5 — fix in `skills/new-project/LAYER.md` (new § *Filling a seed section's tokens*: the token table moved from new-project step 5, with a scaffolder column, an adopter column and a no-source outcome per door, plus `{{STAKEHOLDERS}}`; the guide row now says added sections are rendered), `skills/new-project/SKILL.md` step 5 (points at the table, keeps its grep), `skills/adopt-project/SKILL.md` step 3 (one bullet: render from the adopter's column, delete the hint, grep for `{{`). Lint OK.
- step 6 — reintroduce-and-confirm, as two cold drills on one fixture (`%TEMP%\d256\repo-old`, `repo-new`: a Node/TS repo with a CI workflow running build and test, a README naming "warehouse stocktakers", and a `CLAUDE.md` holding only `# stockcount` and a two-rule `## Conventions`). One runner reads the pre-fix `adopt-project` + `new-project` copies, the other the fixed ones. Command, in each fixture's cwd: brief on stdin to `claude -p --disable-slash-commands --permission-mode acceptEdits --add-dir %TEMP%\d256\<old|new>`. Coldness: both runners listed **no** skills. The first pair was void: the brief left every offer unanswered, so neither run added a guide section and the path under test never ran. The second pair answered **yes** to adding missing guide sections and nothing else. (The brief's paths lost backslashes to `printf` escapes; the old runner said so and recovered the folder, the new one read its files, so both ran on their intended text.) **Split:** both runs added `## How we work`, `## Architecture` and `## Commands`. **Tokens: 0 left raw in either run**: the old runner filled all three unprompted, from the CI file and the README, so this drill does not show raw tokens leaking. **Hint comments: old 1 leaked** (`<!-- Filled from the optional scope grill at scaffold time; … -->` left under `## Architecture`), **new 0**. Fix-dependent: the hint-comment check. Contract pins, not evidence: the token grep (passes before and after on this fixture) and the lint. The filed defect (tokens shipped raw) stays uninduced by a cold runner; the fix closes it by rule, and its evidence here is the hint comment only.
- step 7 — respecced project-baseline (its stamp 18ff189 is TASK-242's tree, and TASK-243's `b40dac5` already re-harvested it, so nothing else was pending); requirements changed: added *A seed section the adopter adds is rendered, never copied raw* with scenario *Guide missing Architecture and Commands*. The scaffolder's requirement *Templates are copied and only their tokens change* still holds word for word (its sources moved files, its behaviour did not), so it is untouched.
- step 8 — closed done; committed as `TASK-256: …` on main (single-branch), sha in `git log`.
