---
id: TASK-108
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: agent
created: 2026-09-08
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [CR-1]
pr: null
github-issue: null
jira-key: null
---

# Check 4 only sees a flag that immediately follows the verb, so a fifth of real invocations are unchecked

## Context

**From a [[code-review]] pass on 2026-09-08**, filed via `/tasks intake` alongside CR-3 to CR-7.

`.github/workflows/skills-lint.sh:120` matches cross-skill invocations with
`/[a-z][a-z-]* [a-z][a-z-]* --[a-z-]+` — a flag **immediately** after the verb. Every invocation that
carries an argument between the two is invisible to the gate:

| Invocation | Where |
|---|---|
| `/specs regen <areas> --story` | `specs/SKILL.md:174`, `tasks/verbs/close.md:272` |
| `/tasks move <ids> --to` | `intake.md:151` — a verb added in this same epic |
| `/tasks plan {{ID}} --replan` | `plan.md` |
| `/tasks block <origin> --on` | ×2 |
| `/tasks export <ID> --to` | `export.md` |
| `/tasks new task --from-feature … --no-plan` | `intake.md` |

**8 of 39 real invocations — roughly 20% — silently unchecked.** And because `grep -o` ends each match
at the first flag, a **second** flag on the same invocation (`--no-plan` above) is never checked either,
even when the first one matched.

### Why this is worse than an ordinary gap

`AGENTS.md:216` asserts, of the flag contract, *"the lint enforces it"*. That sentence is now false for a
fifth of the cases it claims to cover, and the failure is silent in the direction that matters: rename
`--to` on `move.md` today and the gate stays green. A check believed to be enforcing is worse than a
check known to be absent — the same argument this repo already made about muted checks, arriving from
the other side.

**No test case pins the arg-then-flag form**, which is why the gap survived TASK-045 (which added the
check) and TASK-082 (which tightened it).

## Acceptance criteria

- [ ] Check 4 matches an invocation with arguments between the verb and the flag, and matches **every**
      flag on one invocation rather than stopping at the first
- [ ] All 8 invocations listed above are checked — verified by making one of them reference a flag the
      receiving verb does not declare and watching the lint fail
- [ ] Matching stays **anchored** on the flag name, so `--unattend` still does not satisfy a receiver
      declaring `--unattended` (the property TASK-082 established — do not regress it)
- [ ] `skills-lint-test.sh` gains cases that **fail without the fix**: one arg-then-flag invocation, one
      multi-flag invocation, and one negative case proving the anchoring still holds
- [ ] The false claim is resolved: either `AGENTS.md:216` is true after the fix, or it is amended to say
      what is actually enforced
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- **The check-4 / check-5 numbering contradiction** — **TASK-081** owns it; CR-2 was linked there rather
  than re-filed.
- Widening check 4 to verify flag *semantics*. It checks existence only, deliberately.
- Any other lint check.

## Human test plan

- [ ] Rename `--to` in `skills/tasks/verbs/move.md`'s declaration without touching the caller, and run
      the lint. Expected: it fails and names the caller. Before this fix it passes.
