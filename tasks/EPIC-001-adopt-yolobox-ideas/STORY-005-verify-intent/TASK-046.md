---
id: TASK-046
parent: STORY-005
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `verify-intent` — the fidelity axis, grounded in the task's acceptance criteria

## Context

STORY-005's core. The merge gate today answers two questions — *does this follow our documented
conventions* ([[verify-conventions]]) and *is this correct* ([[code-review]]) — and neither asks **did
this build what was asked**. Clean, conventional, correct code implementing the wrong thing passes both.

This task ships the skill with **one** source of truth: the closing task's `## Acceptance criteria`.
That is a complete, useful pass on its own — every task has acceptance criteria, and they are the most
specific statement of intent the repo holds. TASK-047 widens the sources to feature decisions and
`docs/specs/`; this task must be worth running without it.

Three finding classes, per the story:

- **Missing or partial** — a requirement asked for that the diff does not implement, or implements halfway.
- **Scope creep** — behaviour in the diff nobody asked for.
- **Wrong** — a requirement that looks implemented but does not do what was asked.

**Every finding quotes the line it came from.** That is what makes the axis auditable rather than an
opinion: a reader can check the quote against the diff without re-deriving the judgement.

**Named `verify-intent`, not `verify-spec`** — `/specs verify` already means staleness in this skill
set, and two "verify-spec"s would collide on the same repo. "Intent" also covers all three classes
where "scope" covers only two.

**Lands in `skills/`**, never `skills-pi/`, which is frozen — and TASK-037's shadow check now enforces
the consequence of getting that wrong.

## Acceptance criteria

- [ ] `skills/verify-intent/` exists with frontmatter whose `description` carries the trigger phrases,
      including the Slovak ones this team uses
- [ ] The three finding classes are defined with the branch conditions an agent decides on, as a table
      or short list — not prose
- [ ] Every reported finding quotes the acceptance-criteria line it came from, and cites `file:line`
      in the diff
- [ ] Runs standalone against the working tree or a named diff, with no task id required — half the
      value is asking "does this match what was asked?" mid-work, before any gate
- [ ] Given a task id, it reads that task's `## Acceptance criteria` and reports against them
- [ ] States what it does **not** do: it is not correctness ([[code-review]]) and not adherence
      ([[verify-conventions]]), matching how those two disclaim each other
- [ ] Resolvable wikilinks and present frontmatter, so the lint has an invariant to check
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Feature decisions and `docs/specs/` as sources** — TASK-047.
- **Wiring into `tasks/close` or `/feature review`** — TASK-049. This task's skill is standalone-only.
- **The smell baseline** — TASK-048; that is the other axis and belongs to `verify-conventions`.
- Auto-fixing findings. Same posture as `verify-conventions`: advisory, the developer applies them.

## Human test plan

- [ ] Run it on a real diff from this repo where the task's acceptance criteria were fully met, and
      confirm it reports clean rather than manufacturing findings
- [ ] Run it on a diff with a deliberately unimplemented criterion and confirm the **missing** class
      fires and quotes the criterion verbatim
- [ ] Run it on a diff carrying an unrelated extra change and confirm **scope creep** fires naming that
      change, and does not also report it as missing
- [ ] Run it standalone with no task id and confirm it still produces something useful

## Implementation plan

_Populated by `/tasks plan TASK-046` — leave empty until then._
