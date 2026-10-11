---
id: TASK-233
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-19]
pr: null
github-issue: null
jira-key: null
---

# `/roadmap --across` does not say how it combines with an epic scope, or what it prints when nothing is found

## Context

Found by the project-roadmap spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-19.** `skills/roadmap/SKILL.md` § *Verbs / args* defines `--across` and says `--fix` is refused with it. Two
  combinations are left open:
  - **`/roadmap EPIC-NNN --across`.** Across-mode qualifies ids as `<repo>/TASK-NNN` because ids collide between sibling
    projects (AGENTS.md § Code structure records 343 colliding ids across seven trees). A bare `EPIC-NNN` then names
    several epics, and nothing says whether the scope matches all of them, takes a qualified `<repo>/EPIC-NNN`, or is
    refused.
  - **No tree anywhere.** "If neither tree exists, print one line … and exit" is written for one repo. Under `--across`
    it is not said whether the line is about this repo, any sibling, or none of them, and what happens when this repo
    has neither tree but siblings do.

## Acceptance criteria

- [x] `EPIC-NNN` with `--across` has a stated behaviour (accept a qualified id, match every repo, or refuse by name, as
      § Conventions requires for a switch that cannot apply)
- [x] The empty-tree line states its scope under `--across`
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The Collection pass's walk itself — owned by [[tasks]] step 1b
- A feature with no `status.md` — linked to TASK-207 (SH-20)

## Human test plan

- [x] In a three-project family where `alpha` and `beta` each hold an unrelated `EPIC-001` (`siblings.root: ..`), run
      `/roadmap EPIC-001 --across` from `alpha` in two fresh sessions. Expected: both give the same scoped result.
  - **Passed 2026-10-11:** `%TEMP%\d233`. Both runs rendered nothing and printed
    `EPIC-001 is ambiguous across projects: alpha/EPIC-001, beta/EPIC-001 — pass one of these.` The brief was the
    bare command. The runner holds the installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-233` — leave empty until then._

## Outcome

**The fix.** `/roadmap --across` combined with an epic scope, and the "no trees" line, were both undefined. Under
`--across`, `<repo>/EPIC-NNN` now scopes to that repo's epic. A bare `EPIC-NNN` is resolved against every
participating project on each run:
- exactly one has it → scope to it, and print `scope: <repo>/EPIC-NNN`;
- several have it → refuse by name, listing the qualified ids;
- none has it → say so.

The empty-tree line now covers the whole set under `--across`. A repo with neither tree just doesn't participate,
so the siblings still render.

**Step 6 split.** Pre-fix, 2 runs: **both rendered both unrelated `EPIC-001`s together** as one scope. Each added
a note that they were different epics. Fixed, 2 runs: **both refused** with the ambiguity line. **Fix-dependent:**
the refusal. **Contract pins:** participation (gamma left out) and the per-repo join. The empty-tree branch was not
drilled, so it rests on the text.

**Judgement calls.**
- *Refuse an ambiguous scope rather than render every match.* Both pre-fix runners chose "match all", which is
  internally consistent. But a scope promises one epic, and two unrelated epics rendered under one header read as
  one piece of work. The refusal costs one rerun and names the exact ids to pass.
- *Accept a bare id that only one project has.* This is recomputed every run, so a sibling adding the same id
  later turns the result into the refusal rather than silently changing the scope.

**Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-244 because a bare `EPIC-NNN` under `--across` names several epics in a measured family with colliding ids, so two runs can scope to different trees and render a plausible but different roadmap (key 3), on every scoped across-run (key 2), with both gaps in one args section (key 4); TASK-244's adopter inference gap needs a design question first. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. § Verbs / args defines `EPIC-NNN` and `--across` separately and the empty-tree line names "this project" only; nothing covers either combination
- step 4 — layer: local (`skills/roadmap/SKILL.md`)
- step 5 — fix in `skills/roadmap/SKILL.md` § Verbs / args: epic scope under `--across` (qualified id; bare id → one match scopes and prints it, several → refuse listing them, none → say so; never by invoking repo or order) and the empty-tree line's scope under `--across`. Lint green; drill 2/2 on `%TEMP%\d233`
- step 6 — reverted: pre-fix 2/2 rendered both `EPIC-001`s merged; fixed 2/2 refused with the ambiguity line. Fix-dependent = the refusal; contract pins = participation, per-repo join; empty-tree branch not drilled
- step 7 — respecced project-roadmap (empty-tree requirement scoped under `--across`; new requirement "An epic scope across repositories names its repository" + scenario); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
