---
id: TASK-216
parent: EPIC-002
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [VC-059, VC-060]
pr: null
github-issue: null
jira-key: null
---

# Two cross-skill rules in use are missing from AGENTS.md § Conventions

## Context

Found by the register-on-introduce confirmation in `/feature review FEATURE-003` (2026-10-03). AGENTS.md
§ *Keeping conventions current* says a new cross-skill protocol is recorded in § Conventions in the same change.
Two are not:

- **VC-059 — readers accept both forms of a renamed value permanently; only writers switch.** Applied by
  FEATURE-003 across 5 skills and 14 files (`tasks`, `feature`, `fix-next`, `roadmap`, `specs`). The doctrine
  predates the feature (`skills/tasks/slicing.md` § *Wide refactors*), and the forms are tabled once in
  `skills/tasks/SKILL.md` § Lifecycle → *Reading a task's status* — but § Conventions names neither, so a
  future rename has no standing rule to follow.
- **VC-060 — every `^id:` pattern ends `[[:space:]]*$`, never a bare `$`.** Introduced by TASK-206 and
  enforced by lint check 7 (four cases in `skills-lint-test.sh`). § Conventions mentions checks 1, 4, 5 and 6
  and not 7, and § Testing's description of the lint still lists only frontmatter, links and referenced files.

## Acceptance criteria

- [x] § Conventions has a one-line-plus-reason entry for each rule, each a **pointer** to its owner
      (`slicing.md` § *Wide refactors* and `tasks/SKILL.md` § *Reading a task's status*; `tasks/SKILL.md`
      § *ID generation*), not a second copy
- [x] § Testing's description of what the lint checks names check 7
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Moving the anchored `^status:` read, now restated in `specs` regen and `init` 3b, to a single owner — a
  separate refactor if wanted

## Human test plan

N/A — rulebook text, checked by reading; `/verify-conventions` reads it on every later change.

## Implementation plan

Inline: two pointer entries in § Code structure & patterns, and the lint's nine checks named in § Testing.

## Outcome

**The fix (`AGENTS.md`).**
- **VC-059:** § Code structure & patterns gains *A renamed value is read in both forms permanently; only writers
  switch*, pointing at `slicing.md` § *Wide refactors* for the sequencing and at `tasks/SKILL.md` § *Reading a task's
  status* for the forms in force. Its parenthetical restates `slicing.md`'s out-of-reach rule in one clause, which is
  why the alias is permanent here.
- **VC-060:** the same section gains *Every `^id:` pattern ends `[[:space:]]*$`*, pointing at `tasks/SKILL.md` § *ID
  generation* for the measurement and at lint check 7.
- **§ Testing** now names all nine lint checks, not three. Check 7 is among them, and so are 8 and 9, added since this
  task was filed.

**Human test plan:** N/A as filed. Checked by reading: both entries are pointers, and each owner section exists at the
name given.

**Close gate (inline; one rulebook file):**
- **Standards:** pointers, not copies, per § *Defer to a shared inventory*.
- **Intent:** all criteria met.
- **Correctness:** by reading. A heredoc turned the two `\r` escapes into line breaks; they were caught in the diff and
  restored before commit.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** none harvests `AGENTS.md`, so there is no respec.

## Progress log

- step 2 — picked; ranked above TASK-241 because a rule missing from the rulebook is one `/verify-conventions` cannot enforce on any later change, where TASK-241's are three stale words in one skill; EPIC-002 already in-progress
- step 3 — re-verified: neither rule in § Conventions; § Testing named three of nine checks
- step 5 — fixed in AGENTS.md
- step 6 — by reading (rulebook text, plan N/A); lint passes
- step 7 — no spec harvests AGENTS.md
- step 8 — closed inline; commit in git log
