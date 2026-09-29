---
id: TASK-192
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: unassigned
created: 2026-09-29
depends-on: []
blocks: []
findings: [FIELD-005]
pr: null
github-issue: null
jira-key: null
---

# `export` and `pick` take a task's title from a `#` comment inside its frontmatter

## Context

Reported from real use on 2026-09-26: `/tasks export` pushed 14 issues to GitHub (FlowerFurStudio
#67–#82) all titled `status — one of: todo, in-progress, …`.

`export.md` step 5 and `pick.md` step 3 said to take the title "from first `# Heading`". Every
EPIC, STORY and TASK template carries `# status — …` comment lines inside the frontmatter. A
first-`#`-line match lands on one of those, not on the body's heading. Measured on this repo: the
old rule returns the `# status` comment for every template and for every task file checked. The new
rule returns the real heading.

`tasks/SKILL.md` line 167 already says "the first `# Heading` line **of the body**", which is
correct, and `roadmap` reads `idea.md`, whose template has no such comment. Neither needed a change.

## Acceptance criteria

- [x] `export.md` step 5 says to take the title from the first `# Heading` after the closing `---` of the frontmatter, and to check the title before `gh issue create`.
- [x] `pick.md` step 3 says the same, in one clause.
- [x] No other skill takes a title from the first `#` line of a file that has frontmatter.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The 14 mistitled issues in FlowerFurStudio. They are fixed in that repo, not here.
- A lint check for the wording. It would need to recognise a *title extraction instruction* in prose, which is the kind of prose detector § Framework / stack measured and rejected. Decided not to do.

## Human test plan

- [x] N/A — the rule is deterministic, so a script checks it instead of a person. On `tasks/EPIC-003-field-found-defects/TASK-190.md`, `grep -m1 '^# '` (the old rule) returns `# status — one of: todo, …`. The new rule, `awk '/^---$/{n++; next} n>=2 && /^# /{print; exit}'`, returns `# pi refuses six skills: …`. The old rule also fails on all three templates in `skills/tasks/templates/`, so the check is capable of failing.

## Progress log

- 2026-09-26 — Edited before the task existed: the `export.md` and `pick.md` changes were made in the working tree while the FlowerFurStudio export was being cleaned up, and left uncommitted. Filed afterwards with honest status, per the task-first gate's backfill rule.
- 2026-09-29 — Filed and closed. Swept `skills/` for other title-extraction instructions: only `tasks/SKILL.md` (already says "of the body") and `roadmap` (reads `idea.md`, no `#` comment in frontmatter). Lint OK (19 skills).
- 2026-09-29 — Close review. Standards: pass; the measured instance is inline with the rule, as § Output / prose rules asks. Intent: pass, all criteria met. Correctness: pass; a heading written before any frontmatter is not a case any template produces. Security: not applicable, no security surface. Comments: not applicable, no code comments in the diff.
