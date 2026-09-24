---
id: TASK-165
parent: STORY-018
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-24
depends-on: []
blocks: []
findings: [DRILL-164-1]
pr: null
github-issue: null
jira-key: null
---

# Three comments that restate the line beside them

## Context

Found while doing **TASK-164**, by its human test plan: two cold readers (G, H) on the TASK-162 brief and
fixture shape. All three are the rule's first destination row — the content already lives in the code —
and all three are minor. Verified against the tree 2026-09-24.

| Site | Comment | Already carried by | Readers |
|---|---|---|---|
| `skills-lint.sh:81` | *"Aliased links ([[name\|text]]) are never skipped."* | `cut -d'\|' -f1` on the next line keeps the name half; `m_aliasbad` pins it | G, H — and C in TASK-162's re-run: **three readers** |
| `skills-lint.sh:100` | *"A leading / is repo-root-relative, not a child of this file's directory."* | `case "$path" in /*) full=".${path}"` below it | G |
| `skills-lint-test.sh:200` | *"A flag aimed at something that is not a skill must be ignored, not reported."* | `case_is "flag aimed at a non-skill path" 0 m_flagforeign` | H |

**The case for keeping each is real and should be weighed, not assumed away.** `:81` may be saying the
opposite of what a reader expects — that aliased links are *checked*, not skipped as decoration — which
the `cut` alone does not announce. `:100`'s "not a child of this file's directory" names the mistake the
line avoids, which the `case` does not. Dismissing any of them with that reason recorded closes the row.

## Acceptance criteria

- [ ] Each row is acted on or dismissed with a reason recorded.
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass, case count unchanged.
- [ ] `AGENTS.md` § Comments table re-measured if either script's counts move.

## Out of scope

- The EVIDENCE/PIN lines G and H read as QA logs — accepted as by-design on **TASK-153**.
- `skills-lint.sh:144-146`'s ANCHORED mechanic (G) — kept deliberately on **TASK-163**: it is the mechanism at the line where it bites; `AGENTS.md:279` states the rule.
- `skills-lint.sh:218-219` — **TASK-081**; `ARG_RE` block and `pi-install` headers — **TASK-141**.

## Human test plan

- [ ] Two cold readers, same fixture shape as TASK-163's. Expected: none of the three reported, or reported and the recorded reason explains why it stands.

## Implementation plan

_Populated by `/tasks plan TASK-165` — leave empty until then._
