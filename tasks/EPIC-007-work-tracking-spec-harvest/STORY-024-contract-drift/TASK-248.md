---
id: TASK-248
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
findings: [SH-57, SH-58, SH-59, SH-60, SH-61]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# The seed templates describe a project that `new-project` does not build

## Context

Found by the project-baseline spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second
reader against the files at `adc4c27`. All five are in `skills/new-project/templates/`, the text every scaffolded
repo receives, and would be fixed in one pass over those files.

- **SH-57 — README.seed.md** says "`/feature review` gates on code review + manual-test verification + stakeholder
  sign-off". `CLAUDE.seed.md`, `CONVENTIONS-universal.md` and `feature/verbs/review.md` all say it is a
  completeness check, not a code re-review.
- **SH-58 — CLAUDE.seed.md's UI/UX comment** says "Delete this subsection for headless/library/CLI projects".
  - `new-project` step 3 deletes the subsection only for kinds with no human-facing surface. A CLI/TUI keeps it,
    retitled **Output / UX rules**.
  - The comment ships into the consumer's guide, so a kept subsection tells its reader to delete it.
- **SH-59 — CLAUDE.seed.md's Code structure comment** says "in step with ## Architecture below", but `## Architecture`
  is above it.
- **SH-60 — CLAUDE.seed.md § Testing** is untokened, so it is copied verbatim. It says "Automated tests live in
  `tests/`". But the scaffolder seeds Go `*_test.go` beside source and TS `src/**/*.test.ts`, and LAYER.md calls
  sibling `X.Tests` projects the .NET convention.
- **SH-61 — `pick` always cuts a branch.** CONVENTIONS-universal.md § Working rules says `/tasks pick` "cuts the
  task branch", with no condition.
  - `new-project/SKILL.md` makes the same claim ("`/tasks pick` cuts `task/TASK-NNN`").
  - But `single-branch` is offered at intake, and `pick` cuts no branch under it.
  - The text sits outside the comment-rule markers, so the byte-identity check (lint check 5) does not constrain it.

## Acceptance criteria

- [x] README.seed.md describes `/feature review` as the other seeded files do
- [x] The UI/UX comment agrees with step 3 on which kinds keep the subsection
- [x] The Architecture pointer points the right way
- [x] § Testing no longer states one location for every stack
- [x] Both statements of what `pick` does are conditioned on `pr-per-task`
- [x] `bash .github/workflows/skills-lint.sh` passes, including check 5

## Out of scope

- This repo's own AGENTS.md wording, which is not a seed
- Token fill rules (TASK-242)

## Human test plan

N/A — template text, checked by scaffolding a Go CLI and reading the generated guide's Testing, UI/UX and Working-rules sections.

> **Checked 2026-11-12 by reading the templates, not by a scaffold run.** All three sections reach a generated guide
> unrendered: § Testing's prose and the UI/UX comment are untokened in `CLAUDE.seed.md`, and § Working rules is
> `CONVENTIONS-universal.md`, spliced byte for byte. So the generated text is the template text. A Go CLI keeps the
> UI/UX subsection (step 3, retitled), and the new comment now says so. § Testing names no single location. Working
> rules conditions the cut.

## Implementation plan

Drafted 2026-11-12 by `/fix-next` (no grill: nobody to answer one). Triggers: four files, six criteria.

1. **SH-57** — `README.seed.md`: describe `/feature review` as the completeness gate the other seeded files describe.
2. **SH-58** — `CLAUDE.seed.md` UI/UX comment: delete only with no human-facing surface; a CLI/TUI keeps it as
   Output / UX rules, as `new-project` step 3 says.
3. **SH-59** — `CLAUDE.seed.md` Code structure comment: `## Architecture` is above.
4. **SH-60** — `CLAUDE.seed.md` § Testing: tests live where the stack keeps them, as the tokened Tests line records
   (a `tests/` tree, beside source, or a sibling project). Also fix the ledger bullet's "co-located with `tests/`".
5. **SH-61** — `CONVENTIONS-universal.md` § Working rules and `new-project/SKILL.md`'s scaffold-commit bullet:
   condition the branch cut on `integration: pr-per-task`. The universal edit sits outside the comment-rule markers,
   so lint check 5 is unaffected.
6. Respec `project-baseline` only if a requirement restates one of these.

## Outcome

**The fix.** Five statements in the text every scaffolded project receives contradicted what `new-project` builds,
or what the skills do:
- **`/feature review`:** the README seed called it a code review. It is a completeness gate.
- **UI/UX comment:** told CLI projects to delete a subsection step 3 keeps for them, and the comment ships into
  their guide.
- **Code structure comment:** pointed "below" at an Architecture section that sits above it.
- **§ Testing:** told every stack its tests live in `tests/`, although Go, TypeScript and .NET keep them elsewhere,
  and `populate-tests` reads that section to decide where to write.
- **`pick`:** was said to always cut a branch, which is not true under `single-branch`.

All five are corrected in the templates and in `new-project/SKILL.md`.

**Step 6 split.** 6 of 6 assertions failed on HEAD's copies and pass on the fix, all fix-dependent, one per corrected
statement: README review wording, the UI/UX deletion rule, the Architecture direction, the single test location, and
the unconditional cut in both the universal rules and SKILL.md. Contract pin, **not evidence**: skills-lint, including
check 5, passes on both.

**Judgement calls.**
- **§ Testing defers to its own Tests line** (`{{TEST_CONVENTION}}`), rather than gaining a new token. The section's
  prose is copied verbatim, and a token would be TASK-242's territory (token fill rules, out of scope). The tokened line
  directly above is already where a stack's convention is recorded.
- **The scaffold-commit sentence keeps its reason on single-branch projects** ("`pick` does [the commit] on an unborn
  HEAD") rather than dropping the warning. `pick` needs a born HEAD whichever integration is declared, so only the
  branch half was conditional.
- **Universal edit outside the comment-rule markers.** Lint check 5 compares only the marked block, so this repo's
  `AGENTS.md` (a different Working-rules text, and not a seed) needs no matching change. The task's Out of scope says
  the same.
- **Human test checked from the templates, not a scaffold run.** All three sections in question reach a generated guide
  unrendered. Recorded in the plan section, since it is a substitution for the named method.
- **No spec change.** `project-baseline` restates none of the five lines.
- **Close gate ran inline** on a ~15-line prose diff.
  - Standards: no finding. Seeds now agree with `new-project` step 3 and with `feature review`.
  - Intent: all six criteria met.
  - Correctness: the re-worded scaffold-commit sentence was re-read in full. The first edit left a dangling "; and",
    which was fixed.
  - Security: not applicable.
  - Comments: the two template comments changed are instructions shipped to consumers. Each now matches the behaviour
    it describes, and neither restates a destination.

**Flagged, not fixed.** Nothing.

## Progress log

- step 2 — picked; ranked above TASK-225 because both make an agent act on a stale rule silently (keys 1 and 3), but SH-60's "Automated tests live in `tests/`" is copied verbatim into every scaffolded project's guide, and `populate-tests` reads that section to decide where tests go, while TASK-225's stale deferral sentence is reached only when a merge is deferred (key 2, reachability). Key 6 did not separate them: both `contract-drift`
- step 3 — verified: held, all five. README.seed.md:26 "gates on code review"; CLAUDE.seed.md UI/UX comment "Delete … for headless/library/CLI"; Code structure comment "## Architecture below" (it is above); § Testing "Automated tests live in `tests/`" untokened; CONVENTIONS-universal Working rules and new-project/SKILL.md's scaffold-commit bullet say `pick` cuts a branch unconditionally (SKILL.md's intake line 57 already scopes it)
- step 3b — planned: drafted inline as `/tasks plan --no-grill` would (triggers: four files, six criteria)
- step 4 — layer: local
- step 5 — fix in skills/new-project/templates/README.seed.md, CLAUDE.seed.md, CONVENTIONS-universal.md (outside the comment-rule markers), skills/new-project/SKILL.md
- step 6 — reverted fix (HEAD's copies): 6/6 assertions failed; fix-dependent = all six, one per corrected statement; contract pins = skills-lint incl. check 5 (passes on both)
- step 7 — project-baseline: no requirement restates these lines; unchanged
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
