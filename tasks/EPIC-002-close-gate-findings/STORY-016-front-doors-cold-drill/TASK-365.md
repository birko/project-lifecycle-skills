---
id: TASK-365
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
picked-by: fix-next
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-364-1, DRILL-364-2, DRILL-364-3, DRILL-364-4]
pr: null
github-issue: null
jira-key: null
---

# Four more adoption readings that a second cold runner has now raised

## Context

Filed 2026-11-13 at TASK-364's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d364`, `report.md`, § 7) against
d362 and d363. Each meets FEATURE-002 D10's two-runner bar. **Filed, not worked**: the user agreed TASK-364 would end
the session's run of `adopt-project` fixes. These are small wording gaps, and a later batch is cheaper than chasing
them one drill at a time.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-364-1 | `present — <verb> answers in step 3` covers present rows only. A **missing** row whose owner verb will create it (`docs/specs/.map.yml` → `/specs init`) has no stated table form | d362, d364 |
| DRILL-364-2 | `tracked-files-at-scan` and the three dotfiles `specs` skips "without being named" (`.gitignore`, `.gitattributes`, `.editorconfig`): whether they count in the tree size | d363, d364 |
| DRILL-364-3 | two wordings for one fact: `/tasks init` reports *workspace undeclared — tasks work in place*, while `adopt-project` adds `(not asked: single-branch)`. Runners printed one, or both | d363, d364 |
| DRILL-364-4 | `/tasks init`'s "every field the template declares": whether the template's header comment lines, and the `# local \| hybrid` comment on `mode:`, are "fields" to add | d363, d364 |

## Acceptance criteria

- [x] DRILL-364-1 … 4 each have one stated answer, in the file that owns the rule (`adopt-project`, `specs`
      SKILL.md, `tasks` `init`)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Everything TASK-356, 357 and 361 to 364 settled

## Human test plan

- [x] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      none of DRILL-364-1 … 4 in its "left undecided" section
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d365` (`claude -p --disable-slash-commands`, cwd holding only
    `skill/` at the fix, the d065b brief and a fresh copy of `d065/adopted`; the runner listed no skills). None of
    DRILL-364-1 … 4 in its § 7: `.map.yml` read `missing — … /specs init creates it in step 3`; `tracked-files-at-scan:
    14` (7 tracked, `.gitignore` included, plus 7 written); the workspace line printed once, in the stated form, in the
    table and in the report; `/tasks init` added four commented fields and nothing for header lines.

## Implementation plan

Inline: one stated answer per reading, in the file that owns each rule.

## Outcome

**One answer each, in the owning file:**
- **DRILL-364-1 (`adopt-project` SKILL.md):** a missing row whose cell has a verb create it reads `missing — <verb>
  creates it in step 3`, the twin of the present form.
- **DRILL-364-2 (`specs` SKILL.md):** the three dotfiles skipped from mapping still count in `tracked-files-at-scan`,
  so the size is what `git ls-files` counts (plus a caller's written paths).
- **DRILL-364-3 (`tasks` `init`, `adopt-project`):** `init` itself now reports the single-branch skip as *workspace
  undeclared — tasks work in place (not asked: single-branch)*, the front door's words, and the front door prints the
  fact once.
- **DRILL-364-4 (`tasks` `init`):** a field is a key, live or a commented example, with its comment block; header lines
  and a comment trailing a value are not fields.

**Found by this task's drill, fixed in it:** d365 § 7 raised two points about the new DRILL-364-1 sentence: how it joins
the re-run's dated `missing` wording, and whether "today `.map.yml`" limited it to one row. It now covers every row whose
cell names its creating verb, after the dated wording and `; `, the shape the runner chose. Checked by reading.

**One-runner readings left unfiled** (FEATURE-002 D10): d365 § 7's other eight (the blessing question's verdict before
blessing, `/tasks init`'s dashboard against a re-run writing nothing, the drift callout's position against the
`_Generated_` line, populate-tests' fixed wording where the guide states the stack, where the `unverified` reason goes,
`tests/` as a package, one letter per guide section, one state for two files in a row).

**Close gate (inline; four skill files plus three specs):**
- **Standards:** each answer lives in the verb that owns the rule; the front door reuses the owner's wording.
- **Intent:** all criteria met.
- **Correctness:** d365.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

## Progress log

- step 2 — picked; ranked above TASK-349 because both are P3 drill-reading batches and every one of these four leaves a line two runners print differently on every adoption, where TASK-349's are `/specs` rendering details on rarer paths; parent STORY-016 already in-progress
- step 3 — re-verified: none of the four has a stated answer at HEAD
- step 5 — fixed in adopt-project, specs SKILL.md and tasks init
- step 6 — behavioural: d365 (none of the four undecided; two new readings on the new sentence, fixed)
- step 7 — respecced project-baseline, specs-from-code, work-tracking; restamped
- step 8 — closed inline; commit in git log
