---
id: TASK-067
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-10]
pr: null
github-issue: null
jira-key: null
---

# Nobody says what the empty case looks like, so every agent invents one

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance). Two unstated defaults the drill had to
invent, grouped because the fix is one pass: *what does the degenerate case render as?*

### (a) `## Conventions` when the stack is "none"

`new-project/SKILL.md:75` says to *"seed the stack's idiomatic defaults"* and gives examples for
TS / Python / .NET / Go. `:79` says every subsection *"either carries a real rule or is removed — never
a dangling token."* With stack `none yet / docs-only` there are no idioms, so the two rules leave no
legal output.

The drill wrote real markdown-repo rules (kebab-case files, resolving relative links, id formats) and a
Testing line stating plainly that there is no runner **and** that wiring one is part of the change that
picks a stack. It rejected deleting the subsections wholesale on the grounds that it would leave
`/verify-conventions` nothing to lint — which is `:79`'s own stated rationale, so the reasoning is sound
and it should not have had to derive it.

### (b) No documented empty render for a generated file

Neither `/feature status` step 7 nor `tasks triage` step 7 says what a **zero-item** render looks like.
Triage covers the omit-when-empty sections, but not the tree with no epics or the index with no features.
The drill invented placeholder prose for both.

**This is why this repo's own features index carries a hand-written line.** `docs/features/README.md` has
`_No features yet._ See EPIC-001 in tasks/ — the current work is deliberately task-only.` — not derivable
from the template's three tokens, and forbidden by `AGENTS.md`'s *"nothing goes in a generated file that
its verb cannot derive."* It exists because there was no defined empty render, so somebody wrote one.

**Two independent passes reached that line from opposite directions** at TASK-053's gate: the cold drill
flagged the line itself, and `/code-review` caught the same line being used as *justification* for
suppressing the dashboard's DV5 drift callout. That is the cost of an undefined degenerate case — it does
not stay a formatting question, it becomes evidence somebody reasons from.

### Why one task

Both halves are "the generator was specified for the populated case only". One pass through
`new-project` step 3, the `feature status` template and `triage` fixes both, and splitting them invites
two different answers to the same question.

## Acceptance criteria

- [ ] `## Conventions` has a defined shape for a project with no stack — real rules, no dangling token, and something for `/verify-conventions` to lint
- [ ] `/feature status` and `tasks triage` each document their **zero-item** render, so it is derivable rather than invented
- [ ] This repo's `docs/features/README.md` no longer carries the hand-written line: either the empty render covers it, or the content moves to the EPIC body's `§ State as of` where non-derivable commentary belongs
- [ ] Regenerating both files on this repo produces exactly what is on disk — the test that the render is now derivable
- [ ] The chosen empty renders say something useful; a blank section that reads as a bug is not a fix
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The BRIEF conditionality and the missing purpose question — **TASK-064**. Same drill, same file, but those are about intake and conditionality rather than what a generator emits.
- The record-routing table in the seed guide — **TASK-056**.
- `tasks/README.md`'s dashboard template gaining a priority breakdown — **TASK-039**.
- The other drill findings — separate tasks under STORY-016.

## Human test plan

- [ ] Scaffold a docs-only project with no stack and read its `CLAUDE.md § Conventions`: every subsection carries a real rule or is gone, and `/verify-conventions` has something to check
- [ ] Run `/feature status` on this repo (zero features) and `git diff` — must be empty, proving the render is derivable
- [ ] Run `/tasks triage` on a scratch tree with no epics and confirm the output reads as deliberate rather than broken

## Implementation plan

_Populated by `/tasks plan TASK-067` — leave empty until then._
